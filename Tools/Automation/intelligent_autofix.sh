#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../../" && pwd)"

readonly REPO_ROOT
exec "${REPO_ROOT}/Tools/Automation/intelligent_autofix.sh" "$@"
