#!/usr/bin/env bash
# Agent Supervisor: Master controller that ensures all agents stay running and coordinated
# This is the main entry point for the autonomous agent system

set -euo pipefail

AGENT_NAME="AgentSupervisor"
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
AGENTS_DIR="$(dirname "$0")"
LOG_FILE="${AGENTS_DIR}/agent_supervisor.log"
STATUS_FILE="${AGENTS_DIR}/agent_status.json"
PID_FILE="${AGENTS_DIR}/agent_supervisor.pid"
MCP_URL="http://127.0.0.1:5005"
PID=$$

# Essential agents that must always be running
ESSENTIAL_AGENTS=(
  "agent_build.sh"
  "agent_debug.sh"
  "agent_codegen.sh"
  "agent_todo.sh"
  "task_orchestrator.sh"
)

# Optional agents that can be started on demand
OPTIONAL_AGENTS=(
  "uiux_agent.sh"
  "apple_pro_agent.sh"
  "collab_agent.sh"
  "updater_agent.sh"
  "search_agent.sh"
  "pull_request_agent.sh"
  "auto_update_agent.sh"
  "knowledge_base_agent.sh"
)

# Write PID file
echo "${PID}" >"${PID_FILE}"

# Trap signals for clean shutdown
trap 'shutdown_all_agents; exit 0' SIGTERM SIGINT

# Logging function
log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] [${AGENT_NAME}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Shutdown all agents gracefully
shutdown_all_agents() {
  log "INFO" "Shutting down all agents..."

  # Stop all agents by sending SIGTERM to their PIDs
  for agent in "${ESSENTIAL_AGENTS[@]}" "${OPTIONAL_AGENTS[@]}"; do
    local pid_file="${AGENTS_DIR}/${agent}.pid"
    if [[ -f ${pid_file} ]]; then
      local agent_pid
      agent_pid=$(cat "${pid_file}")
      if kill -0 "${agent_pid}" 2>/dev/null; then
        log "INFO" "Stopping ${agent} (PID: ${agent_pid})"
        kill -TERM "${agent_pid}" 2>/dev/null || true

        # Wait up to 10 seconds for graceful shutdown
        local wait_count=0
        while kill -0 "${agent_pid}" 2>/dev/null && [[ ${wait_count} -lt 10 ]]; do
          sleep 1
          ((wait_count++))
        done

        # Force kill if still running
        if kill -0 "${agent_pid}" 2>/dev/null; then
          log "WARN" "Force killing ${agent} (PID: ${agent_pid})"
          kill -KILL "${agent_pid}" 2>/dev/null || true
        fi
      fi
      rm -f "${pid_file}"
    fi
  done

  # Stop MCP server
  local mcp_pid_file="${AGENTS_DIR}/mcp_server.pid"
  if [[ -f ${mcp_pid_file} ]]; then
    local mcp_pid
    mcp_pid=$(cat "${mcp_pid_file}")
    if kill -0 "${mcp_pid}" 2>/dev/null; then
      log "INFO" "Stopping MCP server (PID: ${mcp_pid})"
      kill -TERM "${mcp_pid}" 2>/dev/null || true
      sleep 2
      kill -KILL "${mcp_pid}" 2>/dev/null || true
    fi
    rm -f "${mcp_pid_file}"
  fi

  # Clean up supervisor PID file
  rm -f "${PID_FILE}"

  log "INFO" "Agent supervisor shutdown complete"
}

# Check if an agent is running
is_agent_running() {
  local agent="$1"
  local pid_file="${AGENTS_DIR}/${agent}.pid"

  if [[ ! -f ${pid_file} ]]; then
    return 1
  fi

  local agent_pid
  agent_pid=$(cat "${pid_file}" 2>/dev/null)

  if [[ -z ${agent_pid} ]]; then
    return 1
  fi

  # Check if process is actually running
  if kill -0 "${agent_pid}" 2>/dev/null; then
    return 0
  else
    # Clean up stale PID file
    rm -f "${pid_file}"
    return 1
  fi
}

# Start an agent
start_agent() {
  local agent="$1"
  local agent_path="${AGENTS_DIR}/${agent}"
  local log_file="${AGENTS_DIR}/${agent}.log"
  local pid_file="${AGENTS_DIR}/${agent}.pid"

  if [[ ! -f ${agent_path} ]]; then
    log "ERROR" "Agent script not found: ${agent_path}"
    return 1
  fi

  if [[ ! -x ${agent_path} ]]; then
    log "WARN" "Making agent script executable: ${agent_path}"
    chmod +x "${agent_path}"
  fi

  log "INFO" "Starting agent: ${agent}"

  # Start agent in background
  nohup bash "${agent_path}" >>"${log_file}" 2>&1 &
  local agent_pid=$!

  # Write PID file
  echo "${agent_pid}" >"${pid_file}"

  # Wait a moment to see if it started successfully
  sleep 2

  if kill -0 "${agent_pid}" 2>/dev/null; then
    log "INFO" "Successfully started ${agent} (PID: ${agent_pid})"
    return 0
  else
    log "ERROR" "Failed to start ${agent}"
    rm -f "${pid_file}"
    return 1
  fi
}

# Main execution with autonomous monitoring
main() {
  local command="${1:-monitor}"

  case "${command}" in
  "start")
    log "INFO" "Starting all essential agents..."
    for agent in "${ESSENTIAL_AGENTS[@]}"; do
      if ! is_agent_running "${agent}"; then
        start_agent "${agent}"
      fi
    done
    ;;

  "stop")
    log "INFO" "Stopping all agents..."
    shutdown_all_agents
    ;;

  "status")
    log "INFO" "=== AGENT STATUS ==="
    for agent in "${ESSENTIAL_AGENTS[@]}"; do
      if is_agent_running "${agent}"; then
        local pid_file="${AGENTS_DIR}/${agent}.pid"
        local agent_pid
        agent_pid=$(cat "${pid_file}" 2>/dev/null)
        log "INFO" "${agent}: RUNNING (PID: ${agent_pid})"
      else
        log "INFO" "${agent}: STOPPED"
      fi
    done
    ;;

  "monitor" | *)
    log "INFO" "Starting Agent Supervisor in monitoring mode"
    log "INFO" "PID: ${PID}"

    # Initial startup of essential agents
    for agent in "${ESSENTIAL_AGENTS[@]}"; do
      if ! is_agent_running "${agent}"; then
        start_agent "${agent}"
      fi
    done

    # Continuous monitoring loop
    while true; do
      # Check essential agents
      for agent in "${ESSENTIAL_AGENTS[@]}"; do
        if ! is_agent_running "${agent}"; then
          log "WARN" "Essential agent ${agent} is not running, starting it"
          start_agent "${agent}"
        fi
      done

      sleep 30 # Check every 30 seconds
    done
    ;;
  esac
}

# Execute main function with all arguments
main "$@"
