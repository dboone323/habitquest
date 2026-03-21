#!/bin/bash
# Deterministic multi-platform builder with centralized build/test outputs.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${PROJECT_DIR}/.." && pwd)"
PROJECT_FILE="$(cd "${PROJECT_DIR}" && ls -1 *.xcodeproj 2>/dev/null | head -n1)"

if [[ -z "${PROJECT_FILE}" ]]; then
	echo "No .xcodeproj found in ${PROJECT_DIR}"
	exit 1
fi

PROJECT_NAME="${PROJECT_FILE%.xcodeproj}"
SCHEME_ARG="${1:-}"
ACTION_ARG="${2:-build}"

if [[ "${SCHEME_ARG}" == "build" || "${SCHEME_ARG}" == "test" ]]; then
	ACTION_ARG="${SCHEME_ARG}"
	SCHEME_ARG=""
fi

SCHEME="${SCHEME_ARG}"
if [[ -z "${SCHEME}" ]]; then
	SCHEME="$(xcodebuild -list -project "${PROJECT_FILE}" 2>/dev/null | awk '/Schemes:/{flag=1;next} flag && NF {gsub(/^[[:space:]]+/, "", $0); print; exit}')"
fi

if [[ -z "${SCHEME}" ]]; then
	echo "Unable to resolve a build scheme for ${PROJECT_FILE}"
	exit 1
fi

DERIVED_DATA_PATH="${PROJECT_DIR}/.build/DerivedData"
RESULT_ROOT="${WORKSPACE_ROOT}/outputs/${PROJECT_NAME}"
mkdir -p "${DERIVED_DATA_PATH}" "${RESULT_ROOT}"

PBXPROJ_PATH="${PROJECT_DIR}/${PROJECT_FILE}/project.pbxproj"
SUPPORTS_IOS=false
SUPPORTS_MACOS=false
if grep -Eq "IPHONEOS_DEPLOYMENT_TARGET|iphoneos|iOS" "${PBXPROJ_PATH}" 2>/dev/null; then
	SUPPORTS_IOS=true
fi
if grep -Eq "MACOSX_DEPLOYMENT_TARGET|macosx|macOS" "${PBXPROJ_PATH}" 2>/dev/null; then
	SUPPORTS_MACOS=true
fi

if [[ "${SUPPORTS_IOS}" == false && "${SUPPORTS_MACOS}" == false ]]; then
	SUPPORTS_IOS=true
fi

run_xcodebuild() {
	local destination="$1"
	local action="$2"
	local result_name
	result_name="$(echo "${destination}" | tr -c '[:alnum:]' '_')"

	local cmd=(
		xcodebuild
		-project "${PROJECT_FILE}"
		-scheme "${SCHEME}"
		-destination "${destination}"
		-derivedDataPath "${DERIVED_DATA_PATH}"
		-configuration Debug
	)

	if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
		cmd+=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="")
	fi

	if [[ "${action}" == "test" ]]; then
		cmd+=(-resultBundlePath "${RESULT_ROOT}/${result_name}.xcresult" test)
	else
		cmd+=(build)
	fi

	echo "Running ${action} for destination: ${destination}"
	"${cmd[@]}"
}

try_targets() {
	local action="$1"
	shift
	local destinations=("$@")
	local dest
	for dest in "${destinations[@]}"; do
		if run_xcodebuild "${dest}" "${action}"; then
			echo "Success: ${action} ${SCHEME} on ${dest}"
			return 0
		fi
		echo "Failed: ${action} ${SCHEME} on ${dest}"
	done
	return 1
}

declare -a targets=()
if [[ "${SUPPORTS_IOS}" == true ]]; then
	targets+=("platform=iOS Simulator,name=iPhone 17" "generic/platform=iOS Simulator")
fi
if [[ "${SUPPORTS_MACOS}" == true ]]; then
	targets+=("platform=macOS")
fi

if [[ ${#targets[@]} -eq 0 ]]; then
	echo "No valid build destinations detected."
	exit 1
fi

if try_targets "${ACTION_ARG}" "${targets[@]}"; then
	echo "Completed ${ACTION_ARG} for ${SCHEME}"
	echo "DerivedData: ${DERIVED_DATA_PATH}"
	echo "Outputs: ${RESULT_ROOT}"
	exit 0
fi

echo "All ${ACTION_ARG} strategies failed for ${SCHEME}"
exit 1
