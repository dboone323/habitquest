#!/usr/bin/env bash
set -euo pipefail

# Generates consolidation status docs for the workspace.
# Safe: read-only scans, writes a markdown report.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
DOCS_DIR="${ROOT_DIR}/../Documentation"
REPORT_FILE="${DOCS_DIR}/WORKSPACE_CONSOLIDATION_STATUS.md"

mkdir -p "${DOCS_DIR}"

now() { date '+%Y-%m-%d %H:%M:%S %z'; }
hr() { printf '%*s\n' 80 "" | tr ' ' '-'; }

cd "${ROOT_DIR}/.."

count_matches() {
	local pattern="$1"
	# Use find with -name pattern; for glob-like patterns, prefer multiple invocations
	find . -type f -name "${pattern}" | wc -l | tr -d ' '
}

list_paths_sample() {
	local pattern="$1"
	local limit="${2:-20}"
	find . -type f -name "${pattern}" | head -n "${limit}"
}

# Counts
cspell_count=$(count_matches 'cspell.json')
sh_count=$(find . -type f -name '*.sh' | wc -l | tr -d ' ')
xcode_count=$(find . -type d \( -name '*.xcodeproj' -o -name '*.xcworkspace' \) | wc -l | tr -d ' ')
swift_count=$(find . -type f -name '*.swift' | wc -l | tr -d ' ')

# Snapshot-like folders
snapshots=$(find Tools -type d \( -path '*/Imported/*' -o -path '*/IMPORTS/*' -o -path '*/_merge_backups/*' \) 2>/dev/null | sort)

cat >"${REPORT_FILE}" <<EOF
# Workspace Consolidation Status

Generated: $(now)

## Summary Metrics
- cspell.json files: ${cspell_count}
- Shell scripts (*.sh): ${sh_count}
- Xcode projects/workspaces: ${xcode_count}
- Swift source files: ${swift_count}

## Snapshot/Backup Directories Detected
$(if [[ -n "${snapshots}" ]]; then
	echo "\n"
	echo "${snapshots}" | sed 's/^/- /'
else echo "\n- None"; fi)

## Samples
### cspell.json sample paths
$(list_paths_sample 'cspell.json' 25 | sed 's/^/- /')

### Shell scripts sample paths
$(find . -type f -name '*.sh' | head -n 25 | sed 's/^/- /')

EOF

echo "Wrote ${REPORT_FILE}" >&2
