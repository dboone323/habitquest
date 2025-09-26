#!/bin/bash
# Trunk Integration Validation Script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

echo "🔧 Validating Trunk Integration Setup"
echo "======================================"

# Check if trunk.yaml exists at root
if [[ -f ".trunk/trunk.yaml" ]]; then
  echo "✅ Root .trunk/trunk.yaml found"
else
  echo "❌ Root .trunk/trunk.yaml missing"
  exit 1
fi

# Check if config files exist
config_files=(
  ".trunk/configs/.isort.cfg"
  ".trunk/configs/.markdownlint.yaml"
  ".trunk/configs/.shellcheckrc"
  ".trunk/configs/.yamllint.yaml"
  ".trunk/configs/ruff.toml"
)

for config in "${config_files[@]}"; do
  if [[ -f ${config} ]]; then
    echo "�${ $conf}ig found"
  else
    echo "�${ $conf}ig missing"
    exit 1
  fi
done

# Validate YAML syntax
echo "🔍 Validating YAML syntax..."
if python3 -c "import yaml; yaml.safe_load(open('.trunk/trunk.yaml'))" 2>/dev/null; then
  echo "✅ trunk.yaml has valid YAML syntax"
else
  echo "❌ trunk.yaml has invalid YAML syntax"
  exit 1
fi

# Check GitHub workflow
if [[ -f ".github/workflows/trunk.yml" ]]; then
  echo "✅ GitHub Actions trunk workflow found"
else
  echo "❌ GitHub Actions trunk workflow missing"
  exit 1
fi

# Count lintable files
swift_count=$(find . -name "*.swift" -not -path "./.git/*" | wc -l)
shell_count=$(find . -name "*.sh" -not -path "./.git/*" | wc -l)
python_count=$(find . -name "*.py" -not -path "./.git/*" | wc -l)
md_count=$(find . -name "*.md" -not -path "./.git/*" | wc -l)

echo ""
echo "📊 Repository Statistics"
echo "======================="
echo "Swift files:  ${swift_count}"
echo "Shell files:  ${shell_count}"
echo "Python files: ${python_count}"
echo "Markdown files: ${md_count}"

echo ""
echo "✅ Trunk integration setup validation complete!"
echo "🚀 Ready for merge queue integration"
