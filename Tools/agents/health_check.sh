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
  if [[ -n ${status} ]]; then
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
  if [[ -f ${pid_file} ]]; then
    pid=$(cat "${pid_file}" 2>/dev/null)
    if [[ -n ${pid} ]] && kill -0 "${pid}" 2>/dev/null; then
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
