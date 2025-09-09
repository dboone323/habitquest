#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="Tools/Config"
SWIFTFORMAT_CONFIG="$CONFIG_DIR/UNIFIED_SWIFTFORMAT_ROOT"
SWIFTLINT_CONFIG="$CONFIG_DIR/UNIFIED_SWIFTLINT_ROOT.yml"

if ! command -v swiftformat >/dev/null 2>&1; then
	echo "swiftformat not installed (brew install swiftformat)" >&2
	exit 1
fi
if ! command -v swiftlint >/dev/null 2>&1; then
	echo "swiftlint not installed (brew install swiftlint)" >&2
	exit 1
fi

echo "Running swiftformat..."
swiftformat . --config "$SWIFTFORMAT_CONFIG"

echo "Running swiftlint (lint only)..."
swiftlint lint --config "$SWIFTLINT_CONFIG" || true

echo "Done."
