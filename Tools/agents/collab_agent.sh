#!/bin/bash
# Collaboration Agent: Coordinates all agents, aggregates plans, and ensures best practice learning

AGENT_NAME="collab_agent.sh"
LOG_FILE="$(dirname "$0")/collab_agent.log"
PLANS_DIR="/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/plans"
STATUS_FILE="$(dirname "$0")/agent_status.json"
PID=$$

SLEEP_INTERVAL=900 # 15 minutes
MIN_INTERVAL=300
MAX_INTERVAL=3600

function update_status() {
  local status="$1"
  local timestamp
  timestamp=$(date +%s)

  # Simple file locking with retry (macOS compatible)
  local lockfile="${STATUS_FILE}.lock"
  local max_attempts=5
  local attempt=0

  while [[ ${attempt} -lt ${max_attempts} ]]; do
    if [[ ! -f ${lockfile} ]]; then
      # Create lock file with current timestamp
      echo "$$" >"${lockfile}"
    else
      # Check if lock file is older than 30 seconds
      local lock_timestamp
      lock_timestamp=$(stat -f %m "${lockfile}" 2>/dev/null || echo 0)
      local current_timestamp
      current_timestamp=$(date +%s)
      local time_diff=$((current_timestamp - lock_timestamp))

      if [[ ${time_diff} -gt 30 ]]; then
        # Create lock file with current timestamp
        echo "$$" >"${lockfile}"
      else
        # Lock file exists and is recent, wait and retry
        sleep 1
        ((attempt++))
        continue
      fi
    fi

    # Ensure status file exists and is valid JSON
    if [[ ! -s ${STATUS_FILE} ]]; then
      echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
    fi

    # Use jq with proper escaping to avoid JSON parsing errors
    if command -v jq &>/dev/null &&
      jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
        '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
        "${STATUS_FILE}" >"${STATUS_FILE}.tmp" &&
      [[ -s "${STATUS_FILE}.tmp" ]]; then
      mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
      rm -f "${lockfile}"
      return 0
    else
      local current_time
      current_time=$(date)
      echo "[${current_time}] ${AGENT_NAME}: Failed to update status file" >>"${LOG_FILE}"
      rm -f "${STATUS_FILE}.tmp"
    fi # Release lock
    rm -f "${lockfile}"
    return 0
  done

  local current_time
  current_time=$(date)
  echo "[${current_time}] ${AGENT_NAME}: Could not acquire lock for status update after ${max_attempts} attempts" >>"${LOG_FILE}"
}

mkdir -p "${PLANS_DIR}"

trap 'update_status stopped; exit 0' SIGTERM SIGINT

while true; do
  update_status "running"
  next_sleep=$((SLEEP_INTERVAL + 300))
  if [[ ${next_sleep} -gt ${MAX_INTERVAL} ]]; then
    next_sleep=${MAX_INTERVAL}
  elif [[ ${next_sleep} -lt ${MIN_INTERVAL} ]]; then
    next_sleep=${MIN_INTERVAL}
  fi

  {
    current_time=$(date)
    echo "[${current_time}] ${AGENT_NAME}: Aggregating agent plans and results..."
    cat "${PLANS_DIR}"/*.plan 2>/dev/null
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/plugins/collab_analyze.sh
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/auto_generate_knowledge_base.py
    echo "[${current_time}] ${AGENT_NAME}: Collaboration and learning cycle complete."
    # shellcheck disable=SC2312
    printf '[%s] %s: Sleeping for %s seconds.\n' "$(date)" "${AGENT_NAME}" "${next_sleep}"
  } >>"${LOG_FILE}" 2>&1

  SLEEP_INTERVAL=${next_sleep}
  update_status "idle"
  sleep "${SLEEP_INTERVAL}"
done
