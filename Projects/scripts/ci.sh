#!/usr/bin/env bash
set -euo pipefail

# Unified local CI runner for Projects/* apps.
# Runs pre-commit linters and Xcode builds. With DOCKER=1, runs non-Xcode tasks in containers to reduce load.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "${ROOT_DIR}"

# Run pre-commit if installed
if command -v pre-commit >/dev/null 2>&1; then
	# Prefer a valid root config; otherwise run per-project configs if present
	if [[ -f ".pre-commit-config.yaml" ]] && grep -qE '(^|[[:space:]])-\s+repo:' ".pre-commit-config.yaml"; then
		echo "Running pre-commit on all files (root config)..."
		pre-commit run --all-files --hook-stage=pre-commit || true
	else
		echo "No valid root pre-commit config; running per-project pre-commit where available..."
		for d in AvoidObstaclesGame CodingReviewer HabitQuest MomentumFinance PlannerApp; do
			if [[ -f "${d}/.pre-commit-config.yaml" ]]; then
				echo "→ pre-commit i${ }$d"
				(cd "${d}" && pre-commit run --all-files --hook-stage=pre-commit) || true
			fi
		done
	fi
else
	echo "pre-commit not found; skipping."
fi

# Optional: run containerized tasks
if [[ "${DOCKER:-0}" = "1" ]]; then
	if command -v docker >/dev/null 2>&1; then
		echo "Running containerized: inventory + docs + SwiftPM tests + cspell"
		docker compose -f "${ROOT_DIR}/../Tools/docker-compose.yml" run --rm tools || true
		docker compose -f "${ROOT_DIR}/../Tools/docker-compose.yml" run --rm swift || true
		docker compose -f "${ROOT_DIR}/../Tools/docker-compose.yml" run --rm cspell || true
	else
		echo "Docker not available; skipping containerized tasks."
	fi
fi

# Run SwiftPM tests for Shared package if present
if [[ -f "../Shared/Package.swift" ]]; then
	echo "Running SwiftPM tests for SharedKit..."
	(cd ../Shared && swift test)
fi

if [[ "${SKIP_XCODE:-0}" != "1" ]]; then
	# Try to build via xcodebuild if Xcode projects exist
	# Build list of Xcode projects (portable for macOS bash 3.2)
	projects=()
	while IFS= read -r p; do
		projects+=("${p}")
	done < <(find . -maxdepth 1 -type d \( -name 'AvoidObstaclesGame' -o -name 'HabitQuest' -o -name 'MomentumFinance' -o -name 'PlannerApp' -o -name 'CodingReviewer' \) | sort)

	# Resolve an available simulator name for tests
	select_sim() {
		local candidates=(
			"${IOS_DEST_NAME-}"
			# Use the specific Testing simulator (iPhone 17 with iOS 26) as preferred
			"Testing"
			# Fall back to other iPhone 17 devices if Testing isn't available
			"iPhone 17 Pro Max" "iPhone 17 Pro" "iPhone 17"
			# Fall back to iPhone 16 family
			"iPhone 16 Pro Max" "iPhone 16 Pro" "iPhone 16 Plus" "iPhone 16"
		)
		for name in "${candidates[@]}"; do
			[[ -z "${name}" ]] && continue
			if xcrun simctl list devices | grep -F "${name}" >/dev/null; then
				echo "${name}"
				return 0
			fi
		done
		return 1
	}

	SIM_NAME="$(select_sim || true)"

	detect_platform() {
		local proj="$1"
		local scheme="$2"
		# Ask xcodebuild what destinations are available for this scheme
		if xcodebuild -project "${proj}" -scheme "${scheme}" -showdestinations 2>/dev/null | grep -q 'platform:iOS Simulator'; then
			echo ios
		elif xcodebuild -project "${proj}" -scheme "${scheme}" -showdestinations 2>/dev/null | grep -q 'platform:macOS'; then
			echo macos
		else
			echo unknown
		fi
	}
	for p in "${projects[@]}"; do
		proj_file="${p}/$(basename "${p}").xcodeproj"
		scheme="$(basename "${p}")"
		if [[ -d "${proj_file}" ]]; then
			platform="$(detect_platform "${proj_file}" "${scheme}")"
			case "${platform}" in
			ios)
				echo "Building ${scheme} for iOS Simulator..."
				xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug -destination 'generic/platform=iOS Simulator' | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
				# Use the specific Testing simulator (iPhone 17, iOS 26.0) for tests
				TESTING_SIM_ID="43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF"
				if xcrun simctl list devices | grep -q "${TESTING_SIM_ID}"; then
					echo "Testing ${scheme} on Testing simulator (iPhone 17, iOS 26.0)..."
					if xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug -destination "platform=iOS Simulator,id=${TESTING_SIM_ID}" test 2>&1 | tee "/tmp/${scheme}_ios_test.log" | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat); then
						if grep -q "Test run with 0 tests in 0 suites" "/tmp/${scheme}_ios_test.log"; then
							echo "WARNING: No tests discovered for ${scheme} (iOS)."
						fi
					else
						echo "WARNING: Test run failed for ${scheme} on Testing simulator (continuing)."
					fi
				elif [[ -n "${SIM_NAME}" ]]; then
					echo "Testing simulator not available, falling back to ${SIM_NAME}..."
					if xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug -destination "platform=iOS Simulator,name=${SIM_NAME}" test 2>&1 | tee "/tmp/${scheme}_ios_test.log" | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat); then
						if grep -q "Test run with 0 tests in 0 suites" "/tmp/${scheme}_ios_test.log"; then
							echo "WARNING: No tests discovered for ${scheme} (iOS)."
						fi
					else
						echo "WARNING: Test run failed for ${scheme} on ${SIM_NAME} (continuing)."
					fi
				else
					echo "No suitable simulator found; skipping tests for ${scheme}."
				fi
				;;
			macos)
				echo "Building ${scheme} for macOS..."
				xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug -destination 'platform=macOS' | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
				echo "Testing ${scheme} on macOS (non-fatal)..."
				if xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug -destination 'platform=macOS' test 2>&1 | tee "/tmp/${scheme}_macos_test.log" | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat); then
					if grep -q "Test run with 0 tests in 0 suites" "/tmp/${scheme}_macos_test.log"; then
						echo "WARNING: No tests discovered for ${scheme} (macOS)."
					fi
				else
					echo "WARNING: macOS tests failed for ${scheme}; continuing."
				fi
				# Generic Info.plist validation for macOS app bundles
				APP_PATH="$(find ~/Library/Developer/Xcode/DerivedData -path "*${scheme}*/Build/Products/Debug/${scheme}.app" -maxdepth 5 -type d 2>/dev/null | head -n1 || true)"
				if [[ -n "${APP_PATH}" ]] && [[ -d "${APP_PATH}" ]]; then
					echo "Validating Info.plist for ${scheme}..."
					scripts/validate_plist.sh "${APP_PATH}" || {
						echo "Info.plist validation failed for ${scheme}" >&2
						exit 11
					}
				else
					echo "WARNING: Could not locate app bundle for ${scheme} to validate plist." >&2
				fi
				;;
			*)
				echo "Unknown platform for ${scheme}; attempting generic build..."
				xcodebuild -project "${proj_file}" -scheme "${scheme}" -configuration Debug | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
				;;
			esac
		else
			echo "Skipping ${p} (no .xcodeproj)"
		fi
	done
else
	echo "Skipping Xcode builds (SKIP_XCODE=1)."
fi

echo "CI run complete."
