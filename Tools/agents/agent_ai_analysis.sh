#!/bin/bash
# AI-Enhanced Code Analysis Agent: Ollama integration for intelligent code review

AGENT_NAME="agent_ai_analysis.sh"
LOG_FILE="$(dirname "$0")/agent_ai_analysis.log"
STATUS_FILE="$(dirname "$0")/agent_status.json"
TASK_QUEUE="$(dirname "$0")/task_queue.json"
OLLAMA_ENDPOINT="http://localhost:11434"
AI_MODELS=("codellama" "deepseek-coder" "codegemma")
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

    if jq --arg agent "${AGENT_NAME}" --arg status "${status}" --argjson now "${timestamp}" \
      '.agents[$agent] = (.agents[$agent] // {}) | .agents[$agent].status = $status | .agents[$agent].last_seen = $now | .last_update = $now' \
      "${STATUS_FILE}" >"${STATUS_FILE}.tmp" && [[ -s "${STATUS_FILE}.tmp" ]]; then
      mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
    else
      log "Failed to update status file"
      rm -f "${STATUS_FILE}.tmp"
    fi
  fi
}

function check_ollama_availability() {
  if ! curl -s "${OLLAMA_ENDPOINT}/api/tags" >/dev/null 2>&1; then
    log "Ollama not available at ${OLLAMA_ENDPOINT}"
    return 1
  fi

  for model in "${AI_MODELS[@]}"; do
    if curl -s "${OLLAMA_ENDPOINT}/api/show" -d "{\"name\":\"${model}\"}" 2>/dev/null | grep -q "name"; then
      echo "${model}"
      return 0
    fi
  done

  log "No suitable AI models available"
  return 1
}

function analyze_code_with_ai() {
  local file_path="$1"
  local model

  model=$(check_ollama_availability)
  if ! curl -s "${OLLAMA_URL}/api/generate" -H "Content-Type: application/json" -d "${payload}" >"${response_file}"; then
    log "Cannot analyze code: Ollama unavailable"
    return 1
  fi

  if [[ ! -f ${file_path} ]]; then
    log "Code file not found: ${file_path}"
    return 1
  fi

  local code_content
  code_content=$(cat "${file_path}" | head -50)

  local prompt="Analyze this code for bugs, security issues, and improvements: ${code_content}"

  local response
  response=$(curl -s "${OLLAMA_ENDPOINT}/api/generate" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"${model}\", \"prompt\": \"${prompt}\", \"stream\": false}")

  if [[ $? -eq 0 ]] && echo "${response}" | jq -e '.response' >/dev/null 2>&1; then
    local ai_analysis
    ai_analysis=$(echo "${response}" | jq -r '.response')

    log "AI analysis completed for ${file_path}"
    create_tasks_from_analysis "${ai_analysis}" "${file_path}"

    echo "${ai_analysis}"
    return 0
  else
    log "Failed to get AI analysis response"
    return 1
  fi
}

function create_tasks_from_analysis() {
  local analysis="$1"
  local file_path="$2"

  if echo "${analysis}" | grep -qi "fix\|bug\|error\|issue"; then
    create_task "debug" "AI-detected issue in ${file_path}" 7
  fi

  if echo "${analysis}" | grep -qi "security\|vulnerability"; then
    create_task "security" "AI-detected security concern in ${file_path}" 9
  fi

  if echo "${analysis}" | grep -qi "performance\|optimize"; then
    create_task "optimize" "AI-detected performance issue in ${file_path}" 6
  fi
}

function create_task() {
  local task_type="$1"
  local description="$2"
  local priority="$3"
  local task_id="ai_$(date +%s)_${task_type}"

  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE} ]]; then
    jq --arg id "${task_id}" \
      --arg type "${task_type}" \
      --arg desc "${description}" \
      --arg priority "${priority}" \
      --arg status "queued" \
      --arg created "$(date +%s)" \
      '.tasks += [{"id": $id, "type": $type, "description": $desc, "priority": ($priority | tonumber), "assigned_agent": "agent_ai_analysis.sh", "status": $status, "created": ($created | tonumber), "dependencies": []}]' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Created AI-generated task: ${task_id}"
  fi
}

function process_ai_tasks() {
  local has_task
  has_task=$(jq '.tasks[] | select(.assigned_agent=="agent_ai_analysis.sh" and .status=="queued")' "${TASK_QUEUE}" 2>/dev/null)

  if [[ -n ${has_task} ]]; then
    local task_id
    task_id=$(echo "${has_task}" | jq -r '.id' | head -1)

    log "Processing AI task ${task_id}"

    jq --arg task_id "${task_id}" \
      '.tasks[] |= if .id == $task_id then .status = "completed" else . end' \
      "${TASK_QUEUE}" >"${TASK_QUEUE}.tmp" && mv "${TASK_QUEUE}.tmp" "${TASK_QUEUE}"

    log "Completed AI task ${task_id}"
    return 0
  else
    return 1
  fi
}

# Main execution
trap 'update_status stopped; exit 0' SIGTERM SIGINT

log "Starting AI-Enhanced Code Analysis Agent"
update_status "starting"

if ! check_ollama_availability >/dev/null; then
  log "Warning: Ollama not available. AI analysis features limited."
fi

while true; do
  update_status "running"

  if process_ai_tasks; then
    update_status "busy"
  else
    update_status "idle"
  fi

  sleep 60
done
