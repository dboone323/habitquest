#!/bin/bash
# Quantum Automation Runner for PlannerApp

set -e

PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTOMATION_DIR="${PROJECT_PATH}/Tools/Automation"

echo "🤖 Running Quantum Automation for PlannerApp"

# Run AI enhancement analysis
if [[ -f "${AUTOMATION_DIR}/ai_enhancement_system.sh" ]]; then
  echo "🔍 Running AI enhancement analysis..."
  bash "${AUTOMATION_DIR}/ai_enhancement_system.sh" analyze "PlannerApp"
fi

# Run intelligent auto-fix
if [[ -f "${AUTOMATION_DIR}/simple_autofix.sh" ]]; then
  echo "🔧 Running simple auto-fix..."
  bash "${AUTOMATION_DIR}/simple_autofix.sh" "${PROJECT_PATH}"
elif [[ -f "${AUTOMATION_DIR}/intelligent_autofix.sh" ]]; then
  echo "🔧 Running intelligent auto-fix..."
  bash "${AUTOMATION_DIR}/intelligent_autofix.sh" fix "PlannerApp"
fi

# Run MCP workflow checks
if [[ -f "${AUTOMATION_DIR}/mcp_workflow.sh" ]]; then
  echo "🔄 Running MCP workflow checks..."
  bash "${AUTOMATION_DIR}/mcp_workflow.sh" status
fi

echo "✅ Quantum automation completed for PlannerApp"
