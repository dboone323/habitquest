#!/bin/bash

# MCP GitHub Workflow Integration - Enhanced CI/CD with local automation
CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
  echo -e "${BLUE}[MCP-WORKFLOW]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check workflow status for a repository
check_workflow_status() {
  local project_path="$CODE_DIR"
  local repo_name=$(basename "$CODE_DIR")

  print_status "Checking workflow status for $repo_name..."

  # Check if this is a git repository with GitHub workflows
  cd "$project_path"
  if [[ ! -d ".github/workflows" ]]; then
    print_warning "No GitHub workflows found in $repo_name"
    return 0
  fi

  # List workflow files
  local workflow_files=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null)
  if [[ -z "$workflow_files" ]]; then
    print_warning "No workflow files found"
    return 0
  fi

  echo ""
  echo "📋 Workflow files found:"
  for workflow in $workflow_files; do
    local workflow_name=$(basename "$workflow" .yml)
    echo "  • $workflow_name: $workflow"
  done
}

case "${1:-status}" in
"status")
  check_workflow_status
  ;;
*)
  print_error "Unknown command: $1"
  ;;
esac
