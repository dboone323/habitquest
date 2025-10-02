#!/usr/bin/env bash
# Unified Dashboard Agent
# Ensures the dashboard API server is running and periodically updates agent status.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
# REPO_ROOT is the Tools directory
REPO_ROOT="${SCRIPT_DIR%/agents}"
AUTOMATION_DIR="${REPO_ROOT}/Automation/agents"
STATUS_FILE="${AUTOMATION_DIR}/agent_status.json"
STATUS_UTIL="${AUTOMATION_DIR}/status_utils.py"
LOG_FILE="${AUTOMATION_DIR}/unified_dashboard_agent.log"
PID_FILE="${AUTOMATION_DIR}/unified_dashboard_agent.pid"
AGENT_NAME="unified_dashboard_agent.sh"

DASHBOARD_SCRIPT="${AUTOMATION_DIR}/dashboard_api_server.py"
DASHBOARD_PID_FILE="${AUTOMATION_DIR}/dashboard_server.pid"

mkdir -p "${AUTOMATION_DIR}"
touch "${LOG_FILE}"

# Singleton guard: exit if already running
if [[ -f ${PID_FILE} ]]; then
  existing_pid=$(cat "${PID_FILE}" 2>/dev/null || true)
  if [[ -n "${existing_pid}" ]] && kill -0 "${existing_pid}" 2>/dev/null; then
    log "another instance already running pid=${existing_pid}; exiting"
    exit 0
  fi
fi

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [UnifiedDashboard] $*" | tee -a "${LOG_FILE}"
}

update_status() {
  local status="$1"
  local now
  now=$(date +%s)
  if [[ -f ${STATUS_UTIL} ]]; then
    python3 "${STATUS_UTIL}" update-agent \
      --status-file "${STATUS_FILE}" \
      --agent "${AGENT_NAME}" \
      --status "${status}" \
      --last-seen "${now}" >/dev/null 2>&1 || true
  else
    # minimal fallback
    if command -v jq >/dev/null 2>&1; then
      tmp="${STATUS_FILE}.tmp.$$"
      jq --arg agent "${AGENT_NAME}" --arg status "${status}" --argjson now "${now}" \
        '.agents[$agent] = (.agents[$agent] // {})
				 | .agents[$agent].status = $status
				 | .agents[$agent].last_seen = $now
				 | .last_update = $now' "${STATUS_FILE}" >"${tmp}" 2>/dev/null && mv "${tmp}" "${STATUS_FILE}" || true
    fi
  fi
  log "status=${status}"
}

ensure_dashboard() {
  if [[ -f ${DASHBOARD_PID_FILE} ]]; then
    local dpid
    dpid=$(cat "${DASHBOARD_PID_FILE}" 2>/dev/null || true)
    if [[ -n "${dpid}" ]] && kill -0 "${dpid}" 2>/dev/null; then
      return 0
    fi
  fi
  if [[ -f ${DASHBOARD_SCRIPT} ]]; then
    nohup python3 "${DASHBOARD_SCRIPT}" >>"${LOG_FILE}" 2>&1 &
    echo $! >"${DASHBOARD_PID_FILE}"
    log "dashboard started pid=$(cat "${DASHBOARD_PID_FILE}")"
    return 0
  fi
  log "dashboard script not found: ${DASHBOARD_SCRIPT}"
  return 1
}

graceful_exit() {
  update_status stopped
  rm -f "${PID_FILE}" || true
  log "exiting"
  exit 0
}
trap graceful_exit SIGINT SIGTERM

echo $$ >"${PID_FILE}"
update_status starting
ensure_dashboard || true

while true; do
  update_status available
  ensure_dashboard || true
  sleep 60
done
