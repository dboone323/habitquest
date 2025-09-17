#!/usr/bin/env bash
set -euo pipefail

# Find repo root regardless of invocation directory
ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(dirname "$0")/../.." && pwd))
CONFIG="$ROOT_DIR/Tools/Config/UNIFIED_SWIFTFORMAT_ROOT"

if ! command -v swiftformat >/dev/null 2>&1; then
  echo "swiftformat not installed" >&2
  exit 0
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "SwiftFormat config not found: $CONFIG" >&2
  exit 70
fi

swiftformat . --config "$CONFIG"
