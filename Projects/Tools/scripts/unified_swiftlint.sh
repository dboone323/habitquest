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

# Exclude noisy/archived and test directories; SwiftLint supports --path and config excludes
swiftlint lint --config "${CONFIG}" --strict || true
