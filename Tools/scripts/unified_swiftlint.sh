#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/../.." && pwd))
CONFIG="$ROOT_DIR/Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml"

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "swiftlint not installed" >&2
  exit 0
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "SwiftLint config not found: $CONFIG" >&2
  exit 70
fi

swiftlint lint --config "$CONFIG" --reporter github-actions-logging || true
