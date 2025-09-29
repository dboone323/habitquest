#!/bin/bash
# Apple Pro Engineer Agent: Ensures code and project follow Apple best practices and advanced engineering standards

AGENT_NAME="apple_pro_agent.sh"
LOG_FILE="$(dirname "$0")/apple_pro_agent.log"
PROJECT="CodingReviewer"
STATUS_FILE="$(dirname "$0")/agent_status.json"
PID=$$

SLEEP_INTERVAL=3600 # 1 hour
MAX_INTERVAL=7200

function log_message() {
  echo "[$(date)] ${AGENT_NAME}: $1" >>"${LOG_FILE}"
}

function update_status() {
  local status="$1"
  local timestamp
  timestamp=$(date +%s)

  # Simple file locking with retry (macOS compatible)
  local lockfile="${STATUS_FILE}.lock"
  local max_attempts=5
  local attempt=0

  while [[ ${attempt} -lt ${max_attempts} ]]; do
    if [[ ! -f ${lockfile} ]] || [[ $(($(date +%s) - $(stat -f %m "${lockfile}" 2>/dev/null || echo 0))) -gt 30 ]]; then
      # Create lock file with current timestamp
      echo "$$" >"${lockfile}"

      # Ensure status file exists and is valid JSON
      if [[ ! -s ${STATUS_FILE} ]]; then
        echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
      fi

      # Use jq with proper escaping to avoid JSON parsing errors
      if command -v jq &>/dev/null; then
        jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
          '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
          "${STATUS_FILE}" >"${STATUS_FILE}.tmp"

        if command -v jq &>/dev/null && [[ -s "${STATUS_FILE}.tmp" ]]; then
          mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
          rm -f "${lockfile}"
          return 0
        else
          echo "[$(date)] ${AGENT_NAME}: Failed to update status file" >>"${LOG_FILE}"
          rm -f "${STATUS_FILE}.tmp"
        fi
      fi

      # Release lock
      rm -f "${lockfile}"
      return 0
    else
      # Lock file exists and is recent, wait and retry
      sleep 1
      ((attempt++))
    fi
  done

  echo "[$(date)] ${AGENT_NAME}: Could not acquire lock for status update after ${max_attempts} attempts" >>"${LOG_FILE}"
}

trap 'update_status stopped; exit 0' SIGTERM SIGINT

while true; do
  update_status "running"
  log_message "Running Apple Pro engineering checks..."
  # Run advanced SwiftLint, SwiftFormat, and Apple guidelines checks
  # shellcheck disable=SC2129
  /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/apple_pro_check.sh "${PROJECT}" >>"${LOG_FILE}" 2>&1
  # Suggest and optionally auto-apply advanced Apple best practices
  # shellcheck disable=SC2129
  /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/apple_pro_suggest.sh "${PROJECT}" >>"${LOG_FILE}" 2>&1
  # shellcheck disable=SC2129
  /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/apple_pro_apply.sh "${PROJECT}" >>"${LOG_FILE}" 2>&1
  log_message "Apple Pro engineering checks complete."
  SLEEP_INTERVAL=$((SLEEP_INTERVAL + 600))
  if [[ ${SLEEP_INTERVAL} -gt ${MAX_INTERVAL} ]]; then SLEEP_INTERVAL=${MAX_INTERVAL}; fi
  log_message "Sleeping for ${SLEEP_INTERVAL} seconds."
  update_status "idle"
  sleep "${SLEEP_INTERVAL}"
done
