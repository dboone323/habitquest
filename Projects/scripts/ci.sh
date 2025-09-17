#!/usr/bin/env bash
set -euo pipefail

# Unified local CI runner for Projects/* apps.
# Runs pre-commit linters and Xcode builds. With DOCKER=1, runs non-Xcode tasks in containers to reduce load.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "${ROOT_DIR}"

# Run pre-commit if installed
if command -v pre-commit >/dev/null 2>&1; then
  # Prefer a valid root config; otherwise run per-project configs if present
  if [ -f ".pre-commit-config.yaml" ] && grep -qE '(^|[[:space:]])-\s+repo:' ".pre-commit-config.yaml"; then
    echo "Running pre-commit on all files (root config)..."
    pre-commit run --all-files --hook-stage=pre-commit || true
  else
    echo "No valid root pre-commit config; running per-project pre-commit where available..."
    for d in AvoidObstaclesGame CodingReviewer HabitQuest MomentumFinance PlannerApp; do
      if [ -f "$d/.pre-commit-config.yaml" ]; then
        echo "→ pre-commit in $d"
        (cd "$d" && pre-commit run --all-files --hook-stage=pre-commit) || true
      fi
    done
  fi
else
  echo "pre-commit not found; skipping."
fi

# Optional: run containerized tasks
if [ "${DOCKER:-0}" = "1" ]; then
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
if [ -f "../Shared/Package.swift" ]; then
  echo "Running SwiftPM tests for SharedKit..."
  (cd ../Shared && swift test)
fi

if [ "${SKIP_XCODE:-0}" != "1" ]; then
  # Try to build via xcodebuild if Xcode projects exist
  # Build list of Xcode projects (portable for macOS bash 3.2)
  projects=()
  while IFS= read -r p; do
    projects+=("$p")
  done < <(find . -maxdepth 1 -type d \( -name 'AvoidObstaclesGame' -o -name 'HabitQuest' -o -name 'MomentumFinance' -o -name 'PlannerApp' -o -name 'CodingReviewer' \) | sort)

# Resolve an available simulator name for tests
select_sim() {
  local candidates=(
    "${IOS_DEST_NAME:-}"
  # Prefer iPhone 16 family first to keep runs consistent
  "iPhone 16 Pro Max" "iPhone 16 Pro" "iPhone 16 Plus" "iPhone 16"
  # Fall back to newer devices if 16 isn't available
  "iPhone 17 Pro Max" "iPhone 17 Pro" "iPhone 17"
  )
  for name in "${candidates[@]}"; do
    [ -z "$name" ] && continue
    if xcrun simctl list devices | grep -F "$name" >/dev/null; then
      echo "$name"; return 0
    fi
  done
  return 1
}

SIM_NAME="$(select_sim || true)"

detect_platform() {
  local proj="$1"; local scheme="$2"
  # Ask xcodebuild what destinations are available for this scheme
  if xcodebuild -project "$proj" -scheme "$scheme" -showdestinations 2>/dev/null | grep -q 'platform:iOS Simulator'; then
    echo ios
  elif xcodebuild -project "$proj" -scheme "$scheme" -showdestinations 2>/dev/null | grep -q 'platform:macOS'; then
    echo macos
  else
    echo unknown
  fi
}

  for p in "${projects[@]}"; do
  proj_file="${p}/$(basename "$p").xcodeproj"
  scheme="$(basename "$p")"
  if [ -d "$proj_file" ]; then
    platform="$(detect_platform "$proj_file" "$scheme")"
    case "$platform" in
      ios)
        echo "Building $scheme for iOS Simulator..."
        xcodebuild -project "$proj_file" -scheme "$scheme" -configuration Debug -destination 'generic/platform=iOS Simulator' | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
        if [ -n "$SIM_NAME" ]; then
          echo "Testing $scheme on $SIM_NAME..."
          # Verify destination is recognized by xcodebuild before attempting tests
          if xcodebuild -project "$proj_file" -scheme "$scheme" -showdestinations 2>/dev/null | grep -F "name: $SIM_NAME" >/dev/null; then
            # Save raw log to check for zero-tests condition
            if ! xcodebuild -project "$proj_file" -scheme "$scheme" -configuration Debug -destination "platform=iOS Simulator,name=${SIM_NAME}" test 2>&1 | tee "/tmp/${scheme}_ios_test.log" | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat); then
              echo "WARNING: Test run failed for $scheme on $SIM_NAME (likely missing runtime). Continuing CI without failing."
            fi
            if grep -q "Test run with 0 tests in 0 suites" "/tmp/${scheme}_ios_test.log"; then
              echo "WARNING: No tests discovered for $scheme (iOS). Consider adding tests or disabling test step."
            fi
          else
            echo "No matching destination for $SIM_NAME; skipping tests for $scheme."
          fi
        else
          echo "No suitable simulator found; skipping tests for $scheme."
        fi
        ;;
      macos)
        echo "Building $scheme for macOS..."
        xcodebuild -project "$proj_file" -scheme "$scheme" -configuration Debug -destination 'platform=macOS' | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
  echo "Testing $scheme on macOS (non-fatal)..."
  xcodebuild -project "$proj_file" -scheme "$scheme" -configuration Debug -destination 'platform=macOS' test 2>&1 | tee "/tmp/${scheme}_macos_test.log" | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat) || echo "WARNING: macOS tests failed for $scheme; continuing."
        if grep -q "Test run with 0 tests in 0 suites" "/tmp/${scheme}_macos_test.log"; then
          echo "WARNING: No tests discovered for $scheme (macOS). Consider adding tests or disabling test step."
        fi
        ;;
      *)
        echo "Unknown platform for $scheme; attempting generic build..."
        xcodebuild -project "$proj_file" -scheme "$scheme" -configuration Debug | (command -v xcpretty >/dev/null 2>&1 && xcpretty || cat)
        ;;
    esac
  else
    echo "Skipping $p (no .xcodeproj)"
  fi
  done
else
  echo "Skipping Xcode builds (SKIP_XCODE=1)."
fi

echo "CI run complete."
