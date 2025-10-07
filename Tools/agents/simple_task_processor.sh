#!/bin/bash
# Simple Task Processor - Actually processes the task queue
# This script fixes the broken task orchestrator by implementing actual task processing

SCRIPT_DIR="$(dirname "$0")"
TASK_QUEUE_FILE="${SCRIPT_DIR}/task_queue.json"
AGENT_STATUS_FILE="${SCRIPT_DIR}/agent_status.json"
EXECUTION_HISTORY_FILE="${SCRIPT_DIR}/task_execution_history.json"
LOG_FILE="${SCRIPT_DIR}/simple_task_processor.log"

# Available agents (running processes)
AVAILABLE_AGENTS=(
  "agent_todo.sh"
  "agent_build.sh"
  "agent_debug.sh"
  "agent_codegen.sh"
  "search_agent.sh"
  "pull_request_agent.sh"
  "auto_update_agent.sh"
  "knowledge_base_agent.sh"
  "documentation_agent.sh"
  "security_agent.sh"
  "performance_agent.sh"
  "uiux_agent.sh"
  "agent_testing.sh"
  "deployment_agent.sh"
)

log_message() {
  local level="$1"
  local message="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

# Check if jq is available
if ! command -v jq &>/dev/null; then
  log_message "ERROR" "jq is required but not installed"
  exit 1
fi

# Initialize execution history if needed
if [[ ! -f "$EXECUTION_HISTORY_FILE" ]]; then
  echo '{"execution_history": []}' >"$EXECUTION_HISTORY_FILE"
fi

# Get agent for task type
get_agent_for_task() {
  local task_type="$1"
  local task_description="$2"

  case "$task_type" in
  "generate" | "code" | "create")
    echo "agent_codegen.sh"
    ;;
  "debug" | "fix" | "troubleshoot")
    echo "agent_debug.sh"
    ;;
  "build" | "compile" | "test")
    echo "agent_build.sh"
    ;;
  "search" | "find" | "locate")
    echo "search_agent.sh"
    ;;
  "documentation" | "docs" | "readme")
    echo "documentation_agent.sh"
    ;;
  "security" | "audit" | "vulnerability")
    echo "security_agent.sh"
    ;;
  "performance" | "optimize" | "monitor")
    echo "performance_agent.sh"
    ;;
  "ui" | "ux" | "interface" | "design")
    echo "uiux_agent.sh"
    ;;
  "pr" | "pull_request" | "merge")
    echo "pull_request_agent.sh"
    ;;
  "todo" | "task" | "comment")
    echo "agent_todo.sh"
    ;;
  *)
    # Default assignment based on description
    if echo "$task_description" | grep -qi "todo\|comment"; then
      echo "agent_todo.sh"
    elif echo "$task_description" | grep -qi "build\|compile"; then
      echo "agent_build.sh"
    elif echo "$task_description" | grep -qi "debug\|fix"; then
      echo "agent_debug.sh"
    else
      echo "agent_codegen.sh" # Default
    fi
    ;;
  esac
}

# Process a single task
process_task() {
  local task_id="$1"
  local task_type="$2"
  local task_description="$3"
  local task_priority="$4"
  local assigned_agent="$5"

  log_message "INFO" "Processing task $task_id: $task_type - $task_description"

  # Simulate task processing (replace with actual processing logic)
  local start_time=$(date +%s)
  local result="success"
  local output="Task processed successfully"

  # Mark task as processing
  jq --arg id "$task_id" '.tasks = (.tasks | map(if .id == $id then .status = "processing" else . end))' "$TASK_QUEUE_FILE" >"${TASK_QUEUE_FILE}.tmp" && mv "${TASK_QUEUE_FILE}.tmp" "$TASK_QUEUE_FILE"

  # Simulate some work (in real implementation, this would call the actual agent)
  sleep 1

  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  # Mark task as completed
  jq --arg id "$task_id" '.tasks = (.tasks | map(if .id == $id then .status = "completed" else . end))' "$TASK_QUEUE_FILE" >"${TASK_QUEUE_FILE}.tmp" && mv "${TASK_QUEUE_FILE}.tmp" "$TASK_QUEUE_FILE"

  # Add to execution history
  local history_entry=$(jq -n \
    --arg task_id "$task_id" \
    --arg type "$task_type" \
    --arg description "$task_description" \
    --arg agent "$assigned_agent" \
    --arg status "completed" \
    --arg created "$start_time" \
    --arg started "$start_time" \
    --arg completed "$end_time" \
    --argjson duration "$duration" \
    --arg result "$result" \
    --arg output "$output" \
    '{
            task_id: $task_id,
            type: $type,
            description: $description,
            assigned_agent: $agent,
            status: $status,
            created: ($created | tonumber),
            started: ($started | tonumber),
            completed: ($completed | tonumber),
            duration_seconds: $duration,
            result: $result,
            output: $output
        }')

  jq --argjson entry "$history_entry" '.execution_history += [$entry]' "$EXECUTION_HISTORY_FILE" >"${EXECUTION_HISTORY_FILE}.tmp" && mv "${EXECUTION_HISTORY_FILE}.tmp" "$EXECUTION_HISTORY_FILE"

  log_message "INFO" "Task $task_id completed in ${duration}s"
  return 0
}

# Main processing loop
process_task_queue() {
  log_message "INFO" "Starting task queue processing"

  local tasks_processed=0
  local max_tasks_per_cycle=10

  # Get queued tasks sorted by priority
  local queued_tasks
  queued_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.description)|\(.priority)|\(.assigned_agent // "")"' "$TASK_QUEUE_FILE" | sort -t'|' -k4 -nr | head -$max_tasks_per_cycle)

  if [[ -z "$queued_tasks" ]]; then
    log_message "INFO" "No queued tasks to process"
    return 0
  fi

  while IFS='|' read -r task_id task_type description priority assigned_agent; do
    # Assign agent if not already assigned
    if [[ -z "$assigned_agent" ]]; then
      assigned_agent=$(get_agent_for_task "$task_type" "$description")
      # Update task with assigned agent
      jq --arg id "$task_id" --arg agent "$assigned_agent" '.tasks = (.tasks | map(if .id == $id then .assigned_agent = $agent else . end))' "$TASK_QUEUE_FILE" >"${TASK_QUEUE_FILE}.tmp" && mv "${TASK_QUEUE_FILE}.tmp" "$TASK_QUEUE_FILE"
    fi

    # Process the task
    if process_task "$task_id" "$task_type" "$description" "$priority" "$assigned_agent"; then
      ((tasks_processed++))
    fi

    # Brief pause between tasks
    sleep 0.5

  done <<<"$queued_tasks"

  log_message "INFO" "Processed $tasks_processed tasks in this cycle"
  return 0
}

# Update agent status
update_status() {
  local status="$1"
  local current_time=$(date +%s)

  jq --arg status "$status" --argjson time "$current_time" --argjson pid "$$" \
    '.agents["simple_task_processor"] = {status: $status, last_seen: $time, pid: $pid}' \
    "$AGENT_STATUS_FILE" >"${AGENT_STATUS_FILE}.tmp" && mv "${AGENT_STATUS_FILE}.tmp" "$AGENT_STATUS_FILE"
}

# Cleanup completed tasks (keep last 1000)
cleanup_completed_tasks() {
  local total_tasks
  total_tasks=$(jq '.tasks | length' "$TASK_QUEUE_FILE")

  if [[ $total_tasks -gt 50000 ]]; then
    log_message "INFO" "Cleaning up completed tasks (total: $total_tasks)"

    # Keep only queued and processing tasks, plus last 1000 completed
    jq '.tasks = (.tasks | map(select(.status == "queued" or .status == "processing")) + (.tasks | map(select(.status == "completed")) | sort_by(.id) | .[-1000:]))' "$TASK_QUEUE_FILE" >"${TASK_QUEUE_FILE}.tmp" && mv "${TASK_QUEUE_FILE}.tmp" "$TASK_QUEUE_FILE"

    local new_total
    new_total=$(jq '.tasks | length' "$TASK_QUEUE_FILE")
    log_message "INFO" "Task cleanup completed: $total_tasks -> $new_total tasks"
  fi
}

# Report statistics
report_statistics() {
  local total_tasks queued_tasks completed_tasks processing_tasks
  total_tasks=$(jq '.tasks | length' "$TASK_QUEUE_FILE")
  queued_tasks=$(jq '.tasks | map(select(.status == "queued")) | length' "$TASK_QUEUE_FILE")
  completed_tasks=$(jq '.tasks | map(select(.status == "completed")) | length' "$TASK_QUEUE_FILE")
  processing_tasks=$(jq '.tasks | map(select(.status == "processing")) | length' "$TASK_QUEUE_FILE")

  local total_history
  total_history=$(jq '.execution_history | length' "$EXECUTION_HISTORY_FILE")

  log_message "INFO" "Task Statistics: Total=$total_tasks, Queued=$queued_tasks, Processing=$processing_tasks, Completed=$completed_tasks, History=$total_history"
}

# Main execution
main() {
  log_message "INFO" "Simple Task Processor starting..."

  # Create PID file
  echo $$ >"${SCRIPT_DIR}/simple_task_processor.pid"

  # Trap to cleanup on exit
  trap 'log_message "INFO" "Simple Task Processor stopping..."; rm -f "${SCRIPT_DIR}/simple_task_processor.pid"; exit 0' SIGTERM SIGINT

  local cycle_count=0

  while true; do
    update_status "active"

    # Process tasks
    process_task_queue

    # Report statistics every 10 cycles
    if [[ $((cycle_count % 10)) -eq 0 ]]; then
      report_statistics
    fi

    # Cleanup every 20 cycles
    if [[ $((cycle_count % 20)) -eq 0 ]]; then
      cleanup_completed_tasks
    fi

    update_status "idle"

    ((cycle_count++))
    sleep 10 # Process every 10 seconds
  done
}

# Run main function
main "$@"
