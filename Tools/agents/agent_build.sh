#!/bin/bash
echo "[$(date)] build_agent: Script started, PID=$$" >>"$(dirname "$0")/agent_build.log"
echo "[$(date)] build_agent: Auto-debug task creation enabled (max consecutive failures: ${MAX_CONSECUTIVE_FAILURES})" >>"$(dirname "$0")/agent_build.log"
# Build Agent: Watches for changes and triggers builds automatically

AGENT_NAME="agent_build.sh"
LOG_FILE="$(dirname "$0")/agent_build.log"
PROJECT="CodingReviewer"

SLEEP_INTERVAL=300 # Start with 5 minutes
MIN_INTERVAL=60
MAX_INTERVAL=1800

log_message() {
  local current_time
  current_time=$(date)
  echo "[${current_time}] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

STATUS_FILE="$(dirname "$0")/agent_status.json"
TASK_QUEUE="$(dirname "$0")/task_queue.json"
PID=$$
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=3
function update_status() {
  local status="$1"
  local timestamp
  timestamp=$(date +%s)

  # Ensure status file exists and is valid JSON
  if [[ ! -s ${STATUS_FILE} ]]; then
    echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
  fi

  # Use jq with proper escaping to avoid JSON parsing errors
  if command -v jq &>/dev/null; then
    jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
      '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp"

    if jq --arg agent "${AGENT_NAME}" --arg status "${status}" --argjson now "${timestamp}" \
      '.agents[$agent] = (.agents[$agent] // {}) | .agents[$agent].status = $status | .agents[$agent].last_seen = $now | .last_update = $now' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp" && [[ -s "${STATUS_FILE}.tmp" ]]; then
      mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
    else
      echo "[$(date)] ${AGENT_NAME}: Failed to update status file" >>"${LOG_FILE}"
      rm -f "${STATUS_FILE}.tmp"
    fi
  fi
}
trap 'update_status stopped; exit 0' SIGTERM SIGINT

# Create debug task for persistent build failures
create_debug_task() {
  local project="$1"
  local failure_description="$2"
  local timestamp
  timestamp=$(date +%s%N | cut -b1-13)
  local task_id="debug_build_failure_${timestamp}"
  local task_description="Investigate persistent build failures in ${project}: ${failure_description}"
  local priority=9
  local task

  log_message "Creating debug task for persistent build failures..."

  # Create task object
  task="{\"id\": \"${task_id}\", \"type\": \"debug\", \"description\": \"${task_description}\", \"priority\": ${priority}, \"assigned_agent\": \"agent_debug.sh\", \"status\": \"queued\", \"created\": $(date +%s), \"dependencies\": []}"

  # Add to task queue
  if ! command -v jq &>/dev/null; then
    log_message "jq not available, cannot create debug task"
    return 1
  fi

  if jq --argjson task "${task}" '.tasks += [$task]' "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" 2>/dev/null &&
    [[ -s "${TASK_QUEUE}.tmp" ]] &&
    mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"; then
    log_message "Debug task created: ${task_id}"
    return 0
  fi

  log_message "Failed to create debug task (jq error)"
  rm -f "${TASK_QUEUE}.tmp"
  return 1
}
trap 'update_status stopped; exit 0' SIGTERM SIGINT
while true; do
  update_status running
  log_message "Checking for build trigger..."
  # Check for queued build tasks
  HAS_TASK=$(jq '.tasks[] | select(.assigned_agent=="agent_build.sh" and .status=="queued")' "${TASK_QUEUE}" 2>/dev/null)
  if [[ -n ${HAS_TASK} ]] || grep -q 'ENABLE_AUTO_BUILD=true' "/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/project_config.sh"; then
    log_message "Creating multi-level backup before build..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/backup_manager.sh backup CodingReviewer >>"${LOG_FILE}" 2>&1 || true
    log_message "Running build..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/automate.sh build >>"${LOG_FILE}" 2>&1
    log_message "Running AI enhancement analysis..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/ai_enhancement_system.sh analyze CodingReviewer >>"${LOG_FILE}" 2>&1
    log_message "Auto-applying safe AI enhancements..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/ai_enhancement_system.sh auto-apply CodingReviewer >>"${LOG_FILE}" 2>&1
    log_message "Validating build and enhancements..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/intelligent_autofix.sh validate CodingReviewer >>"${LOG_FILE}" 2>&1
    log_message "Running automated tests after build and enhancements..."
    /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/automate.sh test >>"${LOG_FILE}" 2>&1
    if tail -40 "${LOG_FILE}" | grep -q 'ROLLBACK'; then
      log_message "Rollback detected after validation. Investigate issues."
      CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
      log_message "Consecutive failures: ${CONSECUTIVE_FAILURES}"
      SLEEP_INTERVAL=$((SLEEP_INTERVAL / 2))
      if [[ ${SLEEP_INTERVAL} -lt ${MIN_INTERVAL} ]]; then SLEEP_INTERVAL=${MIN_INTERVAL}; fi

      # Create debug task if failures are persistent
      if [[ ${CONSECUTIVE_FAILURES} -ge ${MAX_CONSECUTIVE_FAILURES} ]]; then
        create_debug_task "${PROJECT}" "Multiple rollbacks detected after validation failures"
        CONSECUTIVE_FAILURES=0 # Reset counter after creating task
      fi
    elif tail -40 "${LOG_FILE}" | grep -q 'error'; then
      log_message "Test failure detected, restoring last backup..."
      /Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/backup_manager.sh restore CodingReviewer >>"${LOG_FILE}" 2>&1
      CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
      log_message "Consecutive failures: ${CONSECUTIVE_FAILURES}"
      SLEEP_INTERVAL=$((SLEEP_INTERVAL / 2))
      if [[ ${SLEEP_INTERVAL} -lt ${MIN_INTERVAL} ]]; then SLEEP_INTERVAL=${MIN_INTERVAL}; fi

      # Create debug task if failures are persistent
      if [[ ${CONSECUTIVE_FAILURES} -ge ${MAX_CONSECUTIVE_FAILURES} ]]; then
        create_debug_task "${PROJECT}" "Persistent test failures detected after multiple build attempts"
        CONSECUTIVE_FAILURES=0 # Reset counter after creating task
      fi
    else
      log_message "Build, AI enhancement, validation, and tests completed successfully."
      if [[ ${CONSECUTIVE_FAILURES} -gt 0 ]]; then
        log_message "Reset consecutive failures counter (was: ${CONSECUTIVE_FAILURES})"
      fi
      CONSECUTIVE_FAILURES=0 # Reset counter on success
      SLEEP_INTERVAL=$((SLEEP_INTERVAL + 60))
      if [[ ${SLEEP_INTERVAL} -gt ${MAX_INTERVAL} ]]; then SLEEP_INTERVAL=${MAX_INTERVAL}; fi
    fi
  else
    update_status idle
    log_message "No build tasks found. Sleeping as idle."
    sleep 60
    continue
  fi
  log_message "Sleeping for ${SLEEP_INTERVAL} seconds."
  sleep "${SLEEP_INTERVAL}"
done
