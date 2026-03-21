#!/bin/bash

if [[ "${FLEET_INTERNAL}" != "1" ]]; then
  echo "❌ Error: Independent execution disabled. Please use 'python3 control/run_all.py' from the workspace root."
  exit 1
fi

# Quantum Automation Runner for HabitQuest

set -e

# shellcheck disable=SC2034
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTOMATION_DIR="${PROJECT_PATH}/Tools/Automation"

echo "🤖 Running Quantum Automation for HabitQuest"

# Run AI enhancement analysis
if [[ -f "${AUTOMATION_DIR}/ai_enhancement_system.sh" ]]; then
	echo "🔍 Running AI enhancement analysis..."
	bash "${AUTOMATION_DIR}/ai_enhancement_system.sh" analyze "HabitQuest"
fi

# Run intelligent auto-fix
if [[ -f "${AUTOMATION_DIR}/simple_autofix.sh" ]]; then
	echo "🔧 Running simple auto-fix..."
	bash "${AUTOMATION_DIR}/simple_autofix.sh" "${PROJECT_PATH}"
elif [[ -f "${AUTOMATION_DIR}/intelligent_autofix.sh" ]]; then
	echo "🔧 Running intelligent auto-fix..."
	bash "${AUTOMATION_DIR}/intelligent_autofix.sh" fix "HabitQuest"
fi

# Run MCP workflow checks
if [[ -f "${AUTOMATION_DIR}/mcp_workflow.sh" ]]; then
	echo "🔄 Running MCP workflow checks..."
	bash "${AUTOMATION_DIR}/mcp_workflow.sh" status
fi

echo "✅ Quantum automation completed for HabitQuest"
