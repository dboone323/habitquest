#!/bin/bash
# Quantum Workspace Dashboard Quick Access
# This script ensures the dashboard is always available at localhost:8004

DASHBOARD_SCRIPT="/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/start_dashboard.sh"

echo "🔍 Quantum Workspace Agent Dashboard"
echo "======================================"

# Ensure dashboard is running
if [[ -x "${DASHBOARD_SCRIPT}" ]]; then
  "${DASHBOARD_SCRIPT}" start
  echo ""
  echo "🌐 Dashboard URL: http://localhost:8004/dashboard"
  echo "📊 API Endpoint: http://localhost:8004/api/dashboard-data"
  echo ""
  echo "💡 Available commands:"
  echo "   ${DASHBOARD_SCRIPT} status   - Check dashboard status"
  echo "   ${DASHBOARD_SCRIPT} restart  - Restart dashboard"
  echo "   ${DASHBOARD_SCRIPT} stop     - Stop dashboard"
else
  echo "❌ Dashboard script not found at ${DASHBOARD_SCRIPT}"
  exit 1
fi
