#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/../../.." && pwd))
PROJECTS_DIR="${ROOT_DIR}/Projects"
CONFIG="${ROOT_DIR}/Tools/Config/UNIFIED_SWIFTFORMAT_ROOT"

if ! command -v swiftformat >/dev/null 2>&1; then
	echo "swiftformat not installed" >&2
	exit 0
fi

if [[ ! -f ${CONFIG} ]]; then
	echo "SwiftFormat config not found: ${CONFIG}" >&2
	exit 70
fi

cd "${PROJECTS_DIR}"

# When invoked by pre-commit, file paths are provided. Filter them.
if [[ $# -gt 0 ]]; then
	files=()
	for f in "$@"; do
		# Only Swift files, skip archived/merge backups/imports/tests
		case "${f}" in
		*Tools/Automation/* | *Archive/* | *Imported/* | *_merge_backups/* | *Tests/*)
			continue
			;;
		esac
		[[ ${f} == *.swift ]] || continue
		files+=("${f}")
	done
	if [[ ${#files[@]} -eq 0 ]]; then
		exit 0
	fi
	swiftformat "${files[@]}" --config "${CONFIG}"
else
	# Fallback: format the Projects tree but exclude heavy/archived and tests folders
	mapfile -t tracked_swift < <(git ls-files '*.swift')
	files=()
	for f in "${tracked_swift[@]}"; do
		case "${f}" in
		*Tools/Automation/* | *Archive/* | *Imported/* | *_merge_backups/* | */*Tests/* | */*Tests.swift)
			continue
			;;
		esac
		files+=("${f}")
	done
	if [[ ${#files[@]} -eq 0 ]]; then
		exit 0
	fi
	swiftformat "${files[@]}" --config "${CONFIG}"
fi
