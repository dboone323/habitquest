#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/../../.." && pwd))
CONFIG="${ROOT_DIR}/Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml"

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "swiftlint not installed" >&2
  exit 0
fi

if [[ ! -f ${CONFIG} ]]; then
  echo "SwiftLint config not found: ${CONFIG}" >&2
  exit 70
fi

if ! cd "${ROOT_DIR}"; then
  echo "Unable to enter repository root: ${ROOT_DIR}" >&2
  exit 1
fi

# Build file list either from pre-commit or from tracked files
files=()
if [[ $# -gt 0 ]]; then
  for f in "$@"; do
    case "${f}" in
    *Tools/Automation/* | *Archive/* | *Imported/* | *_merge_backups/* | */**Tests/** | */**Tests.swift)
      continue
      ;;
    esac
    [[ ${f} == *.swift ]] || continue
    files+=("${f}")
  done
else
  # Fallback: lint all tracked Swift files under repo respecting excludes in config
  mapfile -t tracked_swift < <(git ls-files '*.swift')
  for f in "${tracked_swift[@]}"; do
    case "${f}" in
    *Tools/Automation/* | *Archive/* | *Imported/* | *_merge_backups/* | */**Tests/** | */**Tests.swift)
      continue
      ;;
    esac
    files+=("${f}")
  done
fi

# If no Swift files are present for this hook invocation, exit successfully
if [[ ${#files[@]} -eq 0 ]]; then
  exit 0
fi

# Prepare multiple --path args for swiftlint
args=(lint --config "${CONFIG}" --strict)
for f in "${files[@]}"; do
  args+=(--path "${f}")
done

# Run SwiftLint; do not fail the hook on lint errors to allow autofixes to proceed in later hooks
swiftlint "${args[@]}" || true
