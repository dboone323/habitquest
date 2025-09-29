#!/bin/bash
# UI/UX Agent: Analyzes and suggests improvements for user interface and experience

AGENT_NAME="uiux_agent.sh"
LOG_FILE="$(dirname "$0")/uiux_agent.log"
PROJECT="CodingReviewer"
STATUS_FILE="$(dirname "$0")/agent_status.json"
PID=$$

SLEEP_INTERVAL=1800 # 30 minutes
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
      log_message "Failed to update status file"
      rm -f "${STATUS_FILE}.tmp"
    fi

    # Release lock
    rm -f "${lockfile}"
    return 0
  done

  log_message "Could not acquire lock for status update after ${max_attempts} attempts"
}

log_message() {
  local current_time
  current_time=$(date)
  echo "[${current_time}] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

trap 'update_status stopped; exit 0' SIGTERM SIGINT

while true; do
  update_status "running"
  log_message "Running UI/UX analysis..."
  {
    # Analyze SwiftUI and interface files for best practices
    /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/uiux_analysis.sh "${PROJECT}"
    # Suggest improvements and log them
    /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/uiux_suggest.sh "${PROJECT}"
    # Optionally auto-apply safe UI/UX enhancements
    /Users/danielstevens/Desktop/Code/Tools/Automation/agents/plugins/uiux_apply.sh "${PROJECT}"
  } >>"${LOG_FILE}" 2>&1
  log_message "UI/UX analysis and enhancement complete."
  SLEEP_INTERVAL=$((SLEEP_INTERVAL + 300))
  if [[ ${SLEEP_INTERVAL} -lt ${MIN_INTERVAL} ]]; then SLEEP_INTERVAL=${MIN_INTERVAL}; fi
  if [[ ${SLEEP_INTERVAL} -gt ${MAX_INTERVAL} ]]; then SLEEP_INTERVAL=${MAX_INTERVAL}; fi
  log_message "Sleeping for ${SLEEP_INTERVAL} seconds."
  update_status "idle"
  sleep "${SLEEP_INTERVAL}"
done
