#!/bin/bash
# Updater Agent: Checks for and applies updates to tools, packages, and dependencies

AGENT_NAME="updater_agent.sh"
LOG_FILE="$(dirname "$0")/updater_agent.log"
STATUS_FILE="$(dirname "$0")/agent_status.json"
PID=$$

SLEEP_INTERVAL=43200 # 12 hours
MIN_INTERVAL=3600
MAX_INTERVAL=86400

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
      if command -v jq &>/dev/null && jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
        '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
        "${STATUS_FILE}" >"${STATUS_FILE}.tmp" && [[ -s "${STATUS_FILE}.tmp" ]]; then
        mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
        rm -f "${lockfile}"
        return 0
      else
        echo "[$(date)] ${AGENT_NAME}: Failed to update agent_status.json" >>"${LOG_FILE}"
        rm -f "${STATUS_FILE}.tmp"
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

log_message() {
  echo "[$(date)] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

run_with_logging() {
  local command_description="$1"
  shift
  log_message "Running: ${command_description}"
  "$@" >>"${LOG_FILE}" 2>&1
}

while true; do
  update_status "running"
  log_message "Checking for system and tool updates..."
  # Homebrew
  run_with_logging "brew update" brew update
  run_with_logging "brew upgrade" brew upgrade
  # Python
  run_with_logging "pip3 install --upgrade pip setuptools wheel" pip3 install --upgrade pip setuptools wheel
  # npm (use sudo to avoid EACCES errors)
  run_with_logging "sudo npm install -g npm" sudo npm install -g npm
  run_with_logging "sudo npm update -g" sudo npm update -g
  # macOS software
  run_with_logging "softwareupdate --install --all" softwareupdate --install --all
  # Xcode tools (ignore if already installed)
  if ! run_with_logging "xcode-select --install" xcode-select --install; then
    log_message "xcode-select --install returned non-zero status (likely already installed)."
  fi
  log_message "Update cycle complete."
  SLEEP_INTERVAL=$((SLEEP_INTERVAL + 3600))
  if [[ ${SLEEP_INTERVAL} -lt ${MIN_INTERVAL} ]]; then SLEEP_INTERVAL=${MIN_INTERVAL}; fi
  if [[ ${SLEEP_INTERVAL} -gt ${MAX_INTERVAL} ]]; then SLEEP_INTERVAL=${MAX_INTERVAL}; fi
  log_message "Sleeping for ${SLEEP_INTERVAL} seconds."
  update_status "idle"
  sleep "${SLEEP_INTERVAL}"
done
