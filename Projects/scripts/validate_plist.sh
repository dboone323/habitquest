#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <AppBundlePath> [ExpectedBundleID] [ExpectedDeploymentTarget]" >&2
	exit 1
fi
APP_PATH="$1"
shift || true
EXPECTED_BUNDLE_ID="${1-}"
[[ -n ${1-} ]] && shift || true
EXPECTED_DEPLOY="${1:-26.0}" || true

INFO_PLIST="${APP_PATH}/Contents/Info.plist"
[[ -f ${INFO_PLIST} ]] || {
	echo "Missing Info.plist at ${INFO_PLIST}" >&2
	exit 1
}

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "${INFO_PLIST}" 2>/dev/null || true)
DEPLOY=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "${INFO_PLIST}" 2>/dev/null || true)

if [[ -z ${BUNDLE_ID} ]]; then
	echo "CFBundleIdentifier missing" >&2
	exit 2
fi
if [[ -n ${EXPECTED_BUNDLE_ID} && ${BUNDLE_ID} != "${EXPECTED_BUNDLE_ID}" ]]; then
	echo "Unexpected CFBundleIdentifier: ${BUNDLE_ID} (expected ${EXPECTED_BUNDLE_ID})" >&2
	exit 3
fi
if [[ -n ${EXPECTED_DEPLOY} && ${DEPLOY} != "${EXPECTED_DEPLOY}" ]]; then
	echo "Unexpected LSMinimumSystemVersion: ${DEPLOY} (expected ${EXPECTED_DEPLOY})" >&2
	exit 4
fi
echo "Info.plist validation passed: bundle=${BUNDLE_ID} deploy=${DEPLOY}"
