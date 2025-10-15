#!/bin/bash
# verify_essential_tools.sh - Verify essential tools are installed and working
# Part of the Quantum Workspace Tool Optimization Plan

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Essential tools that must be installed
readonly ESSENTIAL_TOOLS=(
  "swiftlint:SwiftLint - Code linting"
  "swiftformat:SwiftFormat - Code formatting"
  "xcodebuild:Xcode Build System - iOS builds"
  "swift:Swift Compiler - Core development"
  "fastlane:Fastlane - iOS deployment"
  "pod:CocoaPods - iOS dependencies"
  "git:Git - Version control"
  "python3:Python 3 - Automation scripts"
  "node:Node.js - Build tools"
  "npm:NPM - Package management"
  "jq:JQ - JSON processing"
  "ollama:Ollama - AI model serving"
)

# Optional but recommended tools
readonly RECOMMENDED_TOOLS=(
  "commitizen:Commitizen - Conventional commits"
  "cz:Commitizen CLI"
)

print_header() {
  echo -e "${BLUE}🔧 Quantum Workspace Tool Verification${NC}"
  echo "========================================"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

check_tool() {
  local tool_info="$1"
  local tool_name="${tool_info%%:*}"
  local description="${tool_info#*:}"

  if command -v "${tool_name}" &>/dev/null; then
    local version=""
    case "${tool_name}" in
      "swift")
        version=" ($(${tool_name} --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo "unknown"))"
        ;;
      "python3")
        version=" ($(${tool_name} --version 2>&1 | head -1 | cut -d' ' -f2 || echo "unknown"))"
        ;;
      "node")
        version=" ($(${tool_name} --version 2>/dev/null || echo "unknown"))"
        ;;
      "npm")
        version=" ($(${tool_name} --version 2>/dev/null || echo "unknown"))"
        ;;
      "ollama")
        if ${tool_name} list &>/dev/null; then
          local model_count
          model_count="$(${tool_name} list | tail -n +2 | wc -l | tr -d ' ')"
          version=" (${model_count} models available)"
        else
          version=" (installed but not running)"
        fi
        ;;
    esac
    print_success "${description}${version}"
    return 0
  else
    print_error "${description} - NOT INSTALLED"
    return 1
  fi
}

check_removed_tools() {
  print_header
  print_info "Checking for removed tools that should not be present..."

  local removed_tools=("trunk" "black" "ruff" "isort" "bandit")
  local found_removed=()

  for tool in "${removed_tools[@]}"; do
    if command -v "${tool}" &>/dev/null; then
      found_removed+=("${tool}")
    fi
  done

  if [ ${#found_removed[@]} -eq 0 ]; then
    print_success "No removed tools found (good!)"
  else
    print_warning "Found removed tools that should be uninstalled: ${found_removed[*]}"
  fi
}

check_essential_tools() {
  print_info "Checking essential tools..."

  local missing_tools=()
  local total_tools=${#ESSENTIAL_TOOLS[@]}
  local installed_tools=0

  for tool_info in "${ESSENTIAL_TOOLS[@]}"; do
    if check_tool "${tool_info}"; then
      ((installed_tools++))
    else
      missing_tools+=("${tool_info%%:*}")
    fi
  done

  echo ""
  print_info "Essential tools: ${installed_tools}/${total_tools} installed"

  if [ ${#missing_tools[@]} -gt 0 ]; then
    print_error "Missing essential tools: ${missing_tools[*]}"
    return 1
  fi

  return 0
}

check_recommended_tools() {
  print_info "Checking recommended tools..."

  local recommended_count=0

  for tool_info in "${RECOMMENDED_TOOLS[@]}"; do
    if check_tool "${tool_info}"; then
      ((recommended_count++))
    fi
  done

  echo ""
  print_info "Recommended tools: ${recommended_count}/${#RECOMMENDED_TOOLS[@]} installed"
}

check_workspace_config() {
  print_info "Checking workspace configuration..."

  local workspace_root="/Users/danielstevens/Desktop/Quantum-workspace"

  # Check for removed Trunk configuration
  if [[ -d "${workspace_root}/.trunk_disabled" ]]; then
    print_warning "Trunk configuration still exists (.trunk_disabled/) - should be removed"
  else
    print_success "Trunk configuration properly removed"
  fi

  # Check for consolidated requirements
  if [[ -f "${workspace_root}/requirements.txt" ]]; then
    print_success "Python requirements properly consolidated"
  else
    print_warning "Consolidated requirements.txt not found"
  fi

  # Check for VSCode extensions
  if [[ -f "${workspace_root}/.vscode/extensions.json" ]]; then
    print_success "VSCode extensions configured"
  else
    print_info "VSCode extensions not configured (minimal setup)"
  fi
}

show_installation_instructions() {
  cat << 'EOF'

🔧 Installation Instructions for Missing Tools:

# Essential Tools
brew install swiftlint swiftformat fastlane ollama jq

# Xcode (if not installed)
xcode-select --install

# Node.js tools (if needed)
npm install -g commitizen cz-conventional-changelog

# Python dependencies
cd Tools/Automation && pip install -r requirements.txt

# AI Models (after Ollama installation)
ollama pull llama3.2:3b

EOF
}

main() {
  print_header
  echo "Verifying Quantum Workspace tool optimization..."
  echo ""

  local all_checks_passed=true

  # Check for removed tools
  check_removed_tools
  echo ""

  # Check essential tools
  if ! check_essential_tools; then
    all_checks_passed=false
  fi
  echo ""

  # Check recommended tools
  check_recommended_tools
  echo ""

  # Check workspace configuration
  check_workspace_config
  echo ""

  # Summary
  echo "========================================"
  if [[ "${all_checks_passed}" == "true" ]]; then
    print_success "✅ All essential tools verified successfully!"
    print_info "Quantum Workspace is properly optimized."
  else
    print_error "❌ Some essential tools are missing or misconfigured."
    show_installation_instructions
    exit 1
  fi
}

# Execute main function
main "$@"
<parameter name="filePath">/Users/danielstevens/Desktop/Quantum-workspace/verify_essential_tools.sh