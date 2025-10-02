#!/usr/bin/env bash
# Enhanced Startup Script for Autonomous Agent System
# Makes all scripts executable and starts the complete autonomous system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "🚀 Starting Quantum Workspace Autonomous Agent System"
echo "Workspace: ${WORKSPACE_ROOT}"
echo "Agents Directory: ${SCRIPT_DIR}"
echo ""

# Make all agent scripts executable
echo "🔧 Making agent scripts executable..."
find "${SCRIPT_DIR}" -name "*.sh" -exec chmod +x {} \;
find "${SCRIPT_DIR}" -name "*.py" -exec chmod +x {} \;

# Check for required dependencies
echo "🔍 Checking system dependencies..."

# Check Python3
if ! command -v python3 &>/dev/null; then
  echo "❌ Python3 is required but not installed"
  exit 1
fi

# Check if pip is available
if ! python3 -m pip --version &>/dev/null; then
  echo "❌ pip is required but not available"
  exit 1
fi

# Check/install Python dependencies
echo "📦 Checking Python dependencies..."
python3 -c "import flask" 2>/dev/null || {
  echo "⚙️  Installing Flask..."
  python3 -m pip install flask flask-cors --quiet
}

# Check for essential tools
if ! command -v curl &>/dev/null; then
  echo "❌ curl is required but not installed"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "⚠️  jq is not installed - some features may be limited"
  echo "   Install with: brew install jq"
fi

# Initialize directory structure
echo "📁 Initializing directory structure..."
mkdir -p "${SCRIPT_DIR}/communication"
mkdir -p "${SCRIPT_DIR}/logs"
mkdir -p "${WORKSPACE_ROOT}/Projects"

# Initialize configuration files if they don't exist
if [[ ! -f "${SCRIPT_DIR}/agent_status.json" ]]; then
  echo '{"agents": {}, "last_update": 0}' >"${SCRIPT_DIR}/agent_status.json"
fi

if [[ ! -f "${SCRIPT_DIR}/task_queue.json" ]]; then
  echo '{"tasks": [], "completed": [], "failed": []}' >"${SCRIPT_DIR}/task_queue.json"
fi

# Check if any agents are already running
echo "🔍 Checking for existing agent processes..."
existing_agents=()

for pid_file in "${SCRIPT_DIR}"/*.pid; do
  if [[ -f ${pid_file} ]]; then
    pid=$(cat "${pid_file}" 2>/dev/null || echo "")
    if [[ -n ${pid} ]] && kill -0 "${pid}" 2>/dev/null; then
      agent_name=$(basename "${pid_file}" .pid)
      existing_agents+=("${agent_name}")
    else
      # Clean up stale PID file
      rm -f "${pid_file}"
    fi
  fi
done

if [[ ${#existing_agents[@]} -gt 0 ]]; then
  echo "⚠️  Found existing agent processes:"
  for agent in "${existing_agents[@]}"; do
    echo "   - ${agent}"
  done
  echo ""
  read -p "Stop existing agents and restart? (y/N): " -n 1 -r
  echo ""
  if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    echo "🛑 Stopping existing agents..."
    "${SCRIPT_DIR}/agent_supervisor.sh" stop
    sleep 3
  else
    echo "ℹ️  Connecting to existing agent system..."
  fi
fi

# Show system information
echo "📊 System Information:"
echo "   OS: $(uname -s)"
echo "   Python: $(python3 --version)"
echo "   Available Memory: $(free -h 2>/dev/null | grep '^Mem:' | awk '{print $7}' || echo 'Unknown')"
echo "   Available Disk: $(df -h . | tail -1 | awk '{print $4}')"
echo ""

# Display agent configuration
echo "🤖 Configured Agents:"
echo "   Essential Agents:"
echo "     - agent_build.sh (Build & Test Management)"
echo "     - agent_debug.sh (Error Detection & Fixing)"
echo "     - agent_codegen.sh (Code Generation & Enhancement)"
echo "     - agent_todo.sh (TODO Processing & Task Creation)"
echo "     - task_orchestrator.sh (Task Distribution & Coordination)"
echo ""
echo "   Optional Agents:"
echo "     - uiux_agent.sh (UI/UX Improvements)"
echo "     - apple_pro_agent.sh (iOS/macOS Specific Tasks)"
echo "     - collab_agent.sh (Collaboration & Planning)"
echo "     - pull_request_agent.sh (Git & PR Management)"
echo "     - auto_update_agent.sh (Automated Updates)"
echo "     - knowledge_base_agent.sh (Learning & Documentation)"
echo ""

# Create a simple health check script
cat >"${SCRIPT_DIR}/health_check.sh" <<'EOF'
#!/usr/bin/env bash
# Quick health check for agent system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_URL="http://127.0.0.1:5005"

echo "🏥 Agent System Health Check"
echo "=========================="

# Check MCP Server
if curl -s --max-time 3 "${MCP_URL}/health" >/dev/null 2>&1; then
    echo "✅ MCP Server: HEALTHY"

    # Get detailed status
    status=$(curl -s --max-time 3 "${MCP_URL}/status" 2>/dev/null)
    if [[ -n "${status}" ]]; then
        agents=$(echo "${status}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('stats', {}).get('total_agents', 0))" 2>/dev/null)
        tasks=$(echo "${status}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('stats', {}).get('queued_tasks', 0))" 2>/dev/null)
        echo "   Registered Agents: ${agents}"
        echo "   Queued Tasks: ${tasks}"
    fi
else
    echo "❌ MCP Server: UNHEALTHY"
fi

# Check essential agents
essential_agents=("agent_build.sh" "agent_debug.sh" "agent_codegen.sh" "agent_todo.sh" "task_orchestrator.sh")
running_count=0

echo ""
echo "Essential Agents:"
for agent in "${essential_agents[@]}"; do
    pid_file="${SCRIPT_DIR}/${agent}.pid"
    if [[ -f "${pid_file}" ]]; then
        pid=$(cat "${pid_file}" 2>/dev/null)
        if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
            echo "   ✅ ${agent}: RUNNING (PID: ${pid})"
            ((running_count++))
        else
            echo "   ❌ ${agent}: STOPPED"
        fi
    else
        echo "   ❌ ${agent}: NOT STARTED"
    fi
done

echo ""
echo "System Status: ${running_count}/${#essential_agents[@]} essential agents running"

if [[ ${running_count} -eq ${#essential_agents[@]} ]]; then
    echo "🎉 All systems operational!"
    exit 0
else
    echo "⚠️  Some agents need attention"
    exit 1
fi
EOF

chmod +x "${SCRIPT_DIR}/health_check.sh"

# Final confirmation and startup
echo "🎯 Ready to start autonomous agent system!"
echo ""
echo "The system will:"
echo "   1. Start MCP communication server"
echo "   2. Launch essential agents automatically"
echo "   3. Begin autonomous TODO processing"
echo "   4. Monitor and restart failed agents"
echo "   5. Generate periodic status reports"
echo ""
echo "Commands available after startup:"
echo "   ${SCRIPT_DIR}/agent_supervisor.sh status   # Show system status"
echo "   ${SCRIPT_DIR}/agent_supervisor.sh stop     # Stop all agents"
echo "   ${SCRIPT_DIR}/health_check.sh             # Quick health check"
echo ""

read -p "Start the autonomous agent system now? (Y/n): " -n 1 -r
echo ""

if [[ ${REPLY} =~ ^[Nn]$ ]]; then
  echo "ℹ️  System ready but not started. Run the following when ready:"
  echo "   ${SCRIPT_DIR}/agent_supervisor.sh"
  exit 0
fi

echo "🚀 Starting Agent Supervisor in monitoring mode..."
echo "   Log file: ${SCRIPT_DIR}/agent_supervisor.log"
echo "   PID file: ${SCRIPT_DIR}/agent_supervisor.pid"
echo ""
echo "Press Ctrl+C to stop the system"
echo ""

# Start the supervisor
exec "${SCRIPT_DIR}/agent_supervisor.sh" monitor
