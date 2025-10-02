#!/bin/bash
# Performance Monitoring Agent: Tracks system metrics and optimizes performance

AGENT_NAME="agent_performance.sh"
LOG_FILE="$(dirname "$0")/agent_performance.log"
STATUS_FILE="$(dirname "$0")/agent_status.json"
TASK_QUEUE="$(dirname "$0")/task_queue.json"
METRICS_FILE="$(dirname "$0")/performance_metrics.json"
PID=$$

# Performance thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
AGENT_RESPONSE_THRESHOLD=30

function log() {
  echo "[$(date)] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

function update_status() {
  local status="$1"
  local timestamp=$(date +%s)

  # Ensure status file exists and is valid JSON
  if [[ ! -s ${STATUS_FILE} ]]; then
    echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
  fi

  # Use jq with proper escaping to avoid JSON parsing errors
  if command -v jq &>/dev/null; then
    jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
      '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp"

    if [[ $? -eq 0 ]] && [[ -s "${STATUS_FILE}.tmp" ]]; then
      mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
    else
      log "Failed to update agent_status.json (jq or mv error)"
      rm -f "${STATUS_FILE}.tmp"
    fi
  else
    log "jq not available, using fallback status update"
  fi
}

function collect_system_metrics() {
  local timestamp=$(date +%s)
  local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
  local memory_usage=$(vm_stat | grep "Pages active" | awk '{print int($3)*4096/1048576}')
  local disk_usage=$(df / | awk 'NR==2 {print int($5)}' | sed 's/%//')

  # Agent performance metrics
  local active_agents=$(ps aux | grep -E "agent_" | grep -v grep | wc -l | tr -d ' ')
  local queued_tasks=$(jq '.tasks | length' "${TASK_QUEUE}" 2>/dev/null || echo 0)
  local completed_tasks=$(jq '.tasks[] | select(.status == "completed") | length' "${TASK_QUEUE}" 2>/dev/null || echo 0)

  # Create metrics entry
  local metrics_entry
  if command -v jq &>/dev/null; then
    jq --arg timestamp "${timestamp}" \
      --arg cpu "${cpu_usage:-0}" \
      --arg memory "${memory_usage:-0}" \
      --arg disk "${disk_usage:-0}" \
      --arg agents "${active_agents}" \
      --arg queued "${queued_tasks}" \
      --arg completed "${completed_tasks}" \
      '. += [{"timestamp": ($timestamp | tonumber), "cpu_usage": ($cpu | tonumber), "memory_usage": ($memory | tonumber), "disk_usage": ($disk | tonumber), "active_agents": ($agents | tonumber), "queued_tasks": ($queued | tonumber), "completed_tasks": ($completed | tonumber)}]' \
      "${METRICS_FILE}" >"${METRICS_FILE}.tmp" 2>/dev/null && mv "${METRICS_FILE}.tmp" "${METRICS_FILE}" || echo "[]" >"${METRICS_FILE}"
  fi

  log "Metrics collected - CPU: ${cpu_usage}%, Memory: ${memory_usage}MB, Disk: ${disk_usage}%, Agents: ${active_agents}, Tasks: ${queued_tasks} queued, ${completed_tasks} completed"
}

function check_performance_issues() {
  local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
  local memory_usage=$(vm_stat | grep "Pages active" | awk '{print int($3)*4096/1048576}')
  local disk_usage=$(df / | awk 'NR==2 {print int($5)}' | sed 's/%//')

  # Check for performance issues and create optimization tasks
  if [[ ${cpu_usage:-0} -gt ${CPU_THRESHOLD} ]]; then
    log "High CPU usage detected: ${cpu_usage}%"
    create_optimization_task "cpu" "High CPU usage: ${cpu_usage}%" 8
  fi

  if [[ ${memory_usage:-0} -gt ${MEMORY_THRESHOLD} ]]; then
    log "High memory usage detected: ${memory_usage}MB"
    create_optimization_task "memory" "High memory usage: ${memory_usage}MB" 8
  fi

  if [[ ${disk_usage:-0} -gt ${DISK_THRESHOLD} ]]; then
    log "High disk usage detected: ${disk_usage}%"
    create_optimization_task "disk" "High disk usage: ${disk_usage}%" 9
  fi
}

function create_optimization_task() {
  local issue_type="$1"
  local description="$2"
  local priority="$3"
  local task_id="perf_$(date +%s)_${issue_type}"

  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE} ]]; then
    jq --arg id "${task_id}" \
      --arg type "optimize" \
      --arg desc "${description}" \
      --arg priority "${priority}" \
      --arg agent "${AGENT_NAME}" \
      --arg status "queued" \
      --arg created "$(date +%s)" \
      '.tasks += [{"id": $id, "type": $type, "description": $desc, "priority": ($priority | tonumber), "assigned_agent": $agent, "status": $status, "created": ($created | tonumber), "dependencies": []}]' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Created optimization task: ${task_id}"
  fi
}

function optimize_system() {
  log "Running system optimization..."

  # Clean up old log files
  find "$(dirname "$0")" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true

  # Clean up temporary files
  find /tmp -name "*.tmp" -mtime +1 -delete 2>/dev/null || true

  # Restart unresponsive agents
  check_agent_responsiveness

  log "System optimization completed"
}

function check_agent_responsiveness() {
  local current_time=$(date +%s)

  if [[ -f ${STATUS_FILE} ]]; then
    while IFS= read -r agent_name; do
      local last_seen=$(jq -r ".agents[\"${agent_name}\"].last_seen // 0" "${STATUS_FILE}")
      local time_diff=$((current_time - last_seen))

      if [[ ${time_diff} -gt ${AGENT_RESPONSE_THRESHOLD} ]]; then
        log "Agent ${agent_name} unresponsive for ${time_diff} seconds"
        create_optimization_task "agent_restart" "Restart unresponsive agent: ${agent_name}" 7
      fi
    done < <(jq -r '.agents | keys[]' "${STATUS_FILE}" 2>/dev/null)
  fi
}

# Initialize metrics file
if [[ ! -f ${METRICS_FILE} ]]; then
  echo "[]" >"${METRICS_FILE}"
fi

# Main loop
trap 'update_status stopped; exit 0' SIGTERM SIGINT

log "Starting Performance Monitoring Agent"
update_status "starting"

while true; do
  update_status "running"

  # Collect system metrics
  collect_system_metrics

  # Check for performance issues
  check_performance_issues

  # Check for queued optimization tasks
  HAS_TASK=$(jq '.tasks[] | select(.assigned_agent=="'"${AGENT_NAME}"'" and .status=="queued")' "${TASK_QUEUE}" 2>/dev/null)
  if [[ -n ${HAS_TASK} ]]; then
    update_status "busy"
    optimize_system
  else
    update_status "idle"
  fi

  sleep 60 # Check every minute
done
