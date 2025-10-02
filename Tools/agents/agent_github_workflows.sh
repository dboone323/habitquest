#!/bin/bash
# GitHub Actions Workflow Automation Agent: Self-healing CI/CD management

AGENT_NAME="agent_github_workflows.sh"
LOG_FILE="$(dirname "$0")/agent_github_workflows.log"
STATUS_FILE="$(dirname "$0")/agent_status.json"
TASK_QUEUE="$(dirname "$0")/task_queue.json"
GITHUB_API_BASE="https://api.github.com"
REPO_OWNER="$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\).*/\1/' 2>/dev/null || echo 'unknown')"
REPO_NAME="$(git config --get remote.origin.url | sed 's/.*\/\([^/]*\)\.git$/\1/' 2>/dev/null || echo 'unknown')"
PID=$$

function log() {
  echo "[$(date)] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

function update_status() {
  local status="$1"
  local timestamp=$(date +%s)

  if [[ ! -s ${STATUS_FILE} ]]; then
    echo '{"agents":{},"last_update":0}' >"${STATUS_FILE}"
  fi

  if command -v jq &>/dev/null; then
    jq --arg agent "${AGENT_NAME}" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
      '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber)}' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp"

    if [[ $? -eq 0 ]] && [[ -s "${STATUS_FILE}.tmp" ]]; then
      mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
    else
      log "Failed to update status file"
      rm -f "${STATUS_FILE}.tmp"
    fi
  fi
}

function check_github_token() {
  if [[ -z ${GITHUB_TOKEN} ]]; then
    log "GITHUB_TOKEN not set. GitHub API access will be limited."
    return 1
  fi

  # Test token validity
  local response
  response=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${GITHUB_API_BASE}/user" 2>/dev/null)

  if echo "${response}" | jq -e '.login' >/dev/null 2>&1; then
    log "GitHub token validated successfully"
    return 0
  else
    log "GitHub token validation failed"
    return 1
  fi
}

function get_workflow_runs() {
  local status_filter="${1:-all}" # all, in_progress, completed, failure

  if ! check_github_token; then
    log "Cannot fetch workflow runs without valid GitHub token"
    return 1
  fi

  local api_url="${GITHUB_API_BASE}/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs"
  if [[ ${status_filter} != "all" ]]; then
    api_url="${api_url}?status=${status_filter}"
  fi

  local response
  response=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${api_url}")

  if echo "${response}" | jq -e '.workflow_runs' >/dev/null 2>&1; then
    echo "${response}"
    return 0
  else
    log "Failed to fetch workflow runs"
    return 1
  fi
}

function check_failed_workflows() {
  log "Checking for failed workflows..."

  local failed_runs
  failed_runs=$(get_workflow_runs "failure")

  if [[ $? -ne 0 ]]; then
    log "Could not retrieve failed workflow runs"
    return 1
  fi

  local failure_count
  failure_count=$(echo "${failed_runs}" | jq '.workflow_runs | length')

  if [[ ${failure_count} -gt 0 ]]; then
    log "Found ${failure_count} failed workflow runs"

    # Create healing tasks for each failure
    echo "${failed_runs}" | jq -r '.workflow_runs[] | "\(.id):\(.name):\(.conclusion):\(.html_url)"' | head -5 | while IFS=':' read -r run_id workflow_name conclusion url; do
      create_healing_task "${run_id}" "${workflow_name}" "${conclusion}" "${url}"
    done

    return 0
  else
    log "No failed workflows found"
    return 1
  fi
}

function create_healing_task() {
  local run_id="$1"
  local workflow_name="$2"
  local conclusion="$3"
  local url="$4"
  local task_id="github_heal_$(date +%s)_${run_id}"

  local description="Self-heal failed workflow: ${workflow_name} (${conclusion}) - ${url}"

  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE} ]]; then
    jq --arg id "${task_id}" \
      --arg type "github_heal" \
      --arg desc "${description}" \
      --arg priority "8" \
      --arg status "queued" \
      --arg created "$(date +%s)" \
      '.tasks += [{"id": $id, "type": $type, "description": $desc, "priority": ($priority | tonumber), "assigned_agent": "agent_github_workflows.sh", "status": $status, "created": ($created | tonumber), "dependencies": [], "metadata": {"run_id": "'"${run_id}"'", "workflow_name": "'"${workflow_name}"'", "url": "'"${url}"'"}}]' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Created healing task for workflow ${workflow_name}: ${task_id}"
  fi
}

function rerun_failed_workflow() {
  local run_id="$1"

  if ! check_github_token; then
    log "Cannot rerun workflow without valid GitHub token"
    return 1
  fi

  local api_url="${GITHUB_API_BASE}/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${run_id}/rerun"

  local response
  response=$(curl -s -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${api_url}")

  if [[ $? -eq 0 ]]; then
    log "Successfully triggered rerun for workflow ${run_id}"
    return 0
  else
    log "Failed to rerun workflow ${run_id}"
    return 1
  fi
}

function monitor_workflow_health() {
  log "Monitoring workflow health..."

  # Check for workflows that have been running too long
  local running_workflows
  running_workflows=$(get_workflow_runs "in_progress")

  if [[ $? -eq 0 ]]; then
    local long_running_count
    long_running_count=$(echo "${running_workflows}" | jq '.workflow_runs | map(select((now - (.created_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime)) > 3600)) | length')

    if [[ ${long_running_count} -gt 0 ]]; then
      log "Found ${long_running_count} workflows running longer than 1 hour"
      create_monitoring_task "long_running_workflows" "Investigate workflows running longer than 1 hour" 6
    fi
  fi

  # Check workflow run frequency
  local total_runs
  total_runs=$(get_workflow_runs "all" | jq '.workflow_runs | length')

  if [[ ${total_runs} -gt 100 ]]; then
    log "High workflow run frequency detected: ${total_runs} recent runs"
    create_monitoring_task "high_frequency_runs" "Investigate high workflow run frequency" 5
  fi
}

function create_monitoring_task() {
  local issue_type="$1"
  local description="$2"
  local priority="$3"
  local task_id="github_monitor_$(date +%s)_${issue_type}"

  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE} ]]; then
    jq --arg id "${task_id}" \
      --arg type "github_monitor" \
      --arg desc "${description}" \
      --arg priority "${priority}" \
      --arg status "queued" \
      --arg created "$(date +%s)" \
      '.tasks += [{"id": $id, "type": $type, "description": $desc, "priority": ($priority | tonumber), "assigned_agent": "agent_github_workflows.sh", "status": $status, "created": ($created | tonumber), "dependencies": []}]' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Created monitoring task: ${task_id}"
  fi
}

function process_github_tasks() {
  local has_task
  has_task=$(jq '.tasks[] | select(.assigned_agent=="agent_github_workflows.sh" and .status=="queued")' "${TASK_QUEUE}" 2>/dev/null)

  if [[ -n ${has_task} ]]; then
    local task_id
    task_id=$(echo "${has_task}" | jq -r '.id' | head -1)

    local task_type
    task_type=$(echo "${has_task}" | jq -r '.type' | head -1)

    local task_description
    task_description=$(echo "${has_task}" | jq -r '.description' | head -1)

    log "Processing GitHub task ${task_id}: ${task_description}"

    # Mark task as in progress
    jq --arg task_id "${task_id}" \
      '.tasks[] |= if .id == $task_id then .status = "in_progress" else . end' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    # Process based on task type
    case "${task_type}" in
    "github_heal")
      local run_id
      run_id=$(echo "${has_task}" | jq -r '.metadata.run_id' | head -1)
      if rerun_failed_workflow "${run_id}"; then
        log "Successfully processed healing task for run ${run_id}"
      else
        log "Failed to process healing task for run ${run_id}"
      fi
      ;;
    "github_monitor")
      log "Processed monitoring task: ${task_description}"
      ;;
    *)
      log "Unknown GitHub task type: ${task_type}"
      ;;
    esac

    # Mark task as completed
    jq --arg task_id "${task_id}" \
      '.tasks[] |= if .id == $task_id then .status = "completed" else . end' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Completed GitHub task ${task_id}"
    return 0
  else
    return 1
  fi
}

# Main execution
trap 'update_status stopped; exit 0' SIGTERM SIGINT

log "Starting GitHub Actions Workflow Automation Agent"
update_status "starting"

log "Repository: ${REPO_OWNER}/${REPO_NAME}"

if ! check_github_token; then
  log "Warning: GitHub token not available. Automation features will be limited."
fi

while true; do
  update_status "running"

  # Process any GitHub automation tasks
  if process_github_tasks; then
    update_status "busy"
  else
    update_status "idle"

    # Periodic health checks every 10 minutes
    if (($(date +%s) % 600 < 60)); then
      log "Running periodic workflow health check"
      check_failed_workflows
      monitor_workflow_health
    fi
  fi

  sleep 60
done
