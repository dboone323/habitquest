#!/bin/bash
set -euo pipefail

# Validate presence of Trunk configuration files and related assets.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

cd "${REPO_ROOT}"

info() {
  printf '[INFO] %s\n' "$1"
}

ok() {
  printf '[ OK ] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
}

section() {
  printf '\n%s\n' "$1"
  printf '%0.s-' $(seq 1 ${#1})
  printf '\n'
}

section "Validating Trunk integration setup"

if [[ -f ".trunk/trunk.yaml" ]]; then
  ok "Found .trunk/trunk.yaml"
else
  fail "Missing .trunk/trunk.yaml"
  exit 1
fi

missing_configs=0
while IFS= read -r config_path; do
  if [[ -f ${config_path} ]]; then
    ok "Found ${config_path}"
  else
    fail "Missing ${config_path}"
    missing_configs=$((missing_configs + 1))
  fi
done <<'EOF'
.trunk/configs/.isort.cfg
.trunk/configs/.markdownlint.yaml
.trunk/configs/.shellcheckrc
.trunk/configs/.yamllint.yaml
.trunk/configs/ruff.toml
EOF

if ((missing_configs > 0)); then
  fail "Configuration files missing (${missing_configs})."
  exit 1
fi

info "Validating trunk.yaml syntax"
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY'; then
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required to validate .trunk/trunk.yaml")

path = Path('.trunk/trunk.yaml')
with path.open('r', encoding='utf-8') as handle:
    yaml.safe_load(handle)
PY
    ok "trunk.yaml parsed successfully"
  else
    fail "trunk.yaml failed to parse"
    exit 1
  fi
else
  warn "python3 not available; skipping YAML validation"
fi

if [[ -f ".github/workflows/trunk.yml" ]]; then
  ok "Found .github/workflows/trunk.yml"
else
  fail "Missing .github/workflows/trunk.yml"
  exit 1
fi

section "Repository statistics"

count_files() {
  local pattern=$1
  find . -type f -name "${pattern}" -not -path '*/.git/*' | wc -l | tr -d ' '
}

printf 'Swift files:    %s\n' "$(count_files '*.swift')"
printf 'Shell files:    %s\n' "$(count_files '*.sh')"
printf 'Python files:   %s\n' "$(count_files '*.py')"
printf 'Markdown files: %s\n' "$(count_files '*.md')"

printf '\n[ OK ] Trunk integration setup validation complete\n'
