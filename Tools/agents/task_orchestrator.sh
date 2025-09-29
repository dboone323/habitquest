#!/bin/bash
# Task Orchestrator Agent: Central coordinator for all agents with intelligent task distribution

AGENT_NAME="TaskOrchestrator"
SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="${SCRIPT_DIR}/task_orchestrator.log"
TASK_QUEUE_FILE="${SCRIPT_DIR}/task_queue.json"
AGENT_STATUS_FILE="${SCRIPT_DIR}/agent_status.json"
COMMUNICATION_DIR="${SCRIPT_DIR}/communication"

# Agent capabilities and priorities - using functions for reliability
get_agent_capabilities() {
  local agent="$1"
  case "${agent}" in
  "agent_build.sh") echo "build,test,compile,xcode" ;;
  "agent_debug.sh") echo "debug,fix,diagnose,troubleshoot" ;;
  "agent_codegen.sh") echo "generate,code,create,implement" ;;
  "uiux_agent.sh") echo "ui,ux,interface,design,user_experience" ;;
  "apple_pro_agent.sh") echo "ios,swift,apple,frameworks" ;;
  "collab_agent.sh") echo "coordinate,plan,organize,collaborate" ;;
  "updater_agent.sh") echo "update,upgrade,modernize,enhance" ;;
  "search_agent.sh") echo "search,find,locate,discover" ;;
  "pull_request_agent.sh") echo "pr,pull_request,merge,review" ;;
  "auto_update_agent.sh") echo "auto_update,enhancement,best_practices" ;;
  "knowledge_base_agent.sh") echo "knowledge,learn,share,best_practices" ;;
  "documentation_agent.sh") echo "docs,documentation,readme,guides" ;;
  "deployment_agent.sh") echo "deploy,deployment,release,production" ;;
  "agent_performance.sh") echo "performance,optimize,monitor,metrics" ;;
  *) echo "" ;;
  esac
}

get_workflow_chain() {
  local task_type="$1"
  case "${task_type}" in
  "debug") echo "debug->test->build" ;;
  "fix") echo "debug->test->build" ;;
  "implement") echo "generate->test->build->docs" ;;
  "feature") echo "generate->test->build->docs->deploy" ;;
  "ui") echo "ui->test->build" ;;
  "security") echo "security->test->build->deploy" ;;
  "performance") echo "performance->optimize->test->build" ;;
  *) echo "" ;;
  esac
}

get_agent_priority() {
  local agent="$1"
  case "${agent}" in
  "agent_build.sh") echo "8" ;;
  "agent_debug.sh") echo "9" ;;
  "pull_request_agent.sh") echo "7" ;;
  "auto_update_agent.sh") echo "6" ;;
  "agent_codegen.sh") echo "5" ;;
  "uiux_agent.sh") echo "4" ;;
  "apple_pro_agent.sh") echo "4" ;;
  "collab_agent.sh") echo "3" ;;
  "updater_agent.sh") echo "3" ;;
  "search_agent.sh") echo "2" ;;
  "knowledge_base_agent.sh") echo "1" ;;
  *) echo "1" ;;
  esac
}

get_task_requirement() {
  local task_type="$1"
  case "${task_type}" in
  "build" | "test") echo "agent_build.sh" ;;
  "debug" | "fix") echo "agent_debug.sh" ;;
  "generate" | "create") echo "agent_codegen.sh" ;;
  "ui" | "ux") echo "uiux_agent.sh" ;;
  "ios" | "swift") echo "apple_pro_agent.sh" ;;
  "coordinate" | "plan") echo "collab_agent.sh" ;;
  "update") echo "updater_agent.sh" ;;
  "search") echo "search_agent.sh" ;;
  "pr") echo "pull_request_agent.sh" ;;
  "auto_update") echo "auto_update_agent.sh" ;;
  "knowledge") echo "knowledge_base_agent.sh" ;;
  *) echo "" ;;
  esac
}

# List of all available agents
ALL_AGENTS=("agent_build.sh" "agent_debug.sh" "agent_codegen.sh" "uiux_agent.sh" "apple_pro_agent.sh" "collab_agent.sh" "updater_agent.sh" "search_agent.sh" "pull_request_agent.sh" "auto_update_agent.sh" "knowledge_base_agent.sh" "documentation_agent.sh" "deployment_agent.sh" "agent_performance.sh")

# Initialize directories and files
mkdir -p "${COMMUNICATION_DIR}"

# Initialize task queue if it doesn't exist
if [[ ! -f ${TASK_QUEUE_FILE} ]]; then
  echo '{"tasks": [], "completed": [], "failed": []}' >"${TASK_QUEUE_FILE}"
fi

# Initialize agent status if it doesn't exist
if [[ ! -f ${AGENT_STATUS_FILE} ]]; then
  echo '{"agents": {}}' >"${AGENT_STATUS_FILE}"
fi

# Function definitions need to come before they are called
log_message() {
  local level="$1"
  local message="$2"
  echo "[$(date)] [${AGENT_NAME}] [${level}] ${message}" >>"${LOG_FILE}"
}

# Update agent status
update_agent_status() {
  local agent="$1"
  local status="$2"
  local last_seen
  last_seen=$(date +%s)

  # Simple approach: just log the status for now
  log_message "INFO" "Updated status for ${agent}: ${status}"
}

# Initialize all agents in the status file
initialize_agents() {
  for agent in "${ALL_AGENTS[@]}"; do
    update_agent_status "${agent}" "unknown"
  done
  log_message "INFO" "Initialized agent statuses"
}

# Queue management and limits
MAX_QUEUE_SIZE=${MAX_QUEUE_SIZE:-1000}               # Maximum total tasks in queue
MAX_QUEUED_TASKS=${MAX_QUEUED_TASKS:-500}            # Maximum queued tasks
MAX_COMPLETED_HISTORY=${MAX_COMPLETED_HISTORY:-1000} # Maximum completed tasks to keep
MAX_FAILED_HISTORY=${MAX_FAILED_HISTORY:-500}        # Maximum failed tasks to keep
TASK_RETENTION_DAYS=${TASK_RETENTION_DAYS:-7}        # Days to keep completed/failed tasks
TASK_EXPIRATION_HOURS=${TASK_EXPIRATION_HOURS:-168}  # Hours before queued tasks expire (7 days)

# Batch processing configuration
BATCH_SIZE=${BATCH_SIZE:-3}                                # Maximum tasks to process in a single batch
BATCH_INTERVAL=${BATCH_INTERVAL:-10}                       # Seconds between batch processing cycles
MAX_BATCHES_PER_CYCLE=${MAX_BATCHES_PER_CYCLE:-2}          # Maximum batches per orchestration cycle
BATCH_PROCESSING_ENABLED=${BATCH_PROCESSING_ENABLED:-true} # Enable/disable batch processing

# Task Batching Configuration
TASK_BATCHING_ENABLED=${TASK_BATCHING_ENABLED:-true}
MAX_BATCH_SIZE=${MAX_BATCH_SIZE:-5}
BATCH_SIMILARITY_THRESHOLD=${BATCH_SIMILARITY_THRESHOLD:-0.7}
BATCH_CREATION_INTERVAL=${BATCH_CREATION_INTERVAL:-300} # 5 minutes
MAX_ACTIVE_BATCHES=${MAX_ACTIVE_BATCHES:-10}

# Smart Assignment Configuration
SMART_ASSIGNMENT_ENABLED=${SMART_ASSIGNMENT_ENABLED:-true}
LOAD_BALANCING_ENABLED=${LOAD_BALANCING_ENABLED:-true}
PERFORMANCE_TRACKING_ENABLED=${PERFORMANCE_TRACKING_ENABLED:-true}
MAX_AGENT_LOAD=${MAX_AGENT_LOAD:-3}                        # Maximum concurrent tasks per agent
AGENT_PERFORMANCE_WINDOW=${AGENT_PERFORMANCE_WINDOW:-3600} # 1 hour performance tracking window
CAPABILITY_MATCH_WEIGHT=${CAPABILITY_MATCH_WEIGHT:-0.4}
LOAD_BALANCE_WEIGHT=${LOAD_BALANCE_WEIGHT:-0.3}
PERFORMANCE_WEIGHT=${PERFORMANCE_WEIGHT:-0.3}

# Health Checks Configuration
HEALTH_CHECKS_ENABLED=${HEALTH_CHECKS_ENABLED:-true}
AGENT_HEALTH_CHECK_INTERVAL=${AGENT_HEALTH_CHECK_INTERVAL:-60}                # Health check interval in seconds
AGENT_HEALTH_TIMEOUT=${AGENT_HEALTH_TIMEOUT:-30}                              # Health check timeout in seconds
AGENT_MAX_FAILURES=${AGENT_MAX_FAILURES:-3}                                   # Maximum consecutive failures before circuit breaker
ORCHESTRATOR_HEALTH_CHECK_INTERVAL=${ORCHESTRATOR_HEALTH_CHECK_INTERVAL:-300} # Orchestrator health check interval
CIRCUIT_BREAKER_RESET_TIME=${CIRCUIT_BREAKER_RESET_TIME:-7200}                # Circuit breaker reset time in seconds
HEALTH_CHECK_RETRIES=${HEALTH_CHECK_RETRIES:-2}                               # Number of health check retries
AUTO_RECOVERY_ENABLED=${AUTO_RECOVERY_ENABLED:-true}                          # Enable automatic agent recovery

# Retry Logic Configuration
RETRY_LOGIC_ENABLED=${RETRY_LOGIC_ENABLED:-true}
MAX_RETRY_ATTEMPTS=${MAX_RETRY_ATTEMPTS:-3}                                                     # Maximum number of retry attempts per task
RETRY_BASE_DELAY=${RETRY_BASE_DELAY:-60}                                                        # Base delay in seconds for exponential backoff
RETRY_MAX_DELAY=${RETRY_MAX_DELAY:-3600}                                                        # Maximum delay between retries (1 hour)
RETRY_BACKOFF_MULTIPLIER=${RETRY_BACKOFF_MULTIPLIER:-2}                                         # Exponential backoff multiplier
RETRY_JITTER_ENABLED=${RETRY_JITTER_ENABLED:-true}                                              # Add random jitter to retry delays
RETRY_JITTER_PERCENT=${RETRY_JITTER_PERCENT:-20}                                                # Jitter percentage (0-100)
RETRY_TRANSIENT_ERRORS=${RETRY_TRANSIENT_ERRORS:-"timeout,network,connection,temporary"}        # Comma-separated list of transient error types
RETRY_PERMANENT_ERRORS=${RETRY_PERMANENT_ERRORS:-"permission,authentication,invalid,not_found"} # Comma-separated list of permanent error types
RETRY_SUCCESS_RATE_THRESHOLD=${RETRY_SUCCESS_RATE_THRESHOLD:-0.3}                               # Minimum success rate for retry consideration (30%)
RETRY_AGENT_LOAD_THRESHOLD=${RETRY_AGENT_LOAD_THRESHOLD:-0.8}                                   # Maximum agent load percentage for retries (80%)
RETRY_QUEUE_BACKLOG_THRESHOLD=${RETRY_QUEUE_BACKLOG_THRESHOLD:-100}                             # Maximum queue size before reducing retries

# Queue Analytics Configuration
QUEUE_ANALYTICS_ENABLED=${QUEUE_ANALYTICS_ENABLED:-true}
ANALYTICS_COLLECTION_INTERVAL=${ANALYTICS_COLLECTION_INTERVAL:-300} # 5 minutes
ANALYTICS_RETENTION_DAYS=${ANALYTICS_RETENTION_DAYS:-30}
ANALYTICS_METRICS_FILE=${ANALYTICS_METRICS_FILE:-${SCRIPT_DIR}/queue_analytics.json}
ANALYTICS_REPORT_FILE=${ANALYTICS_REPORT_FILE:-${SCRIPT_DIR}/queue_analytics_report.md}
ANALYTICS_PERFORMANCE_WINDOW=${ANALYTICS_PERFORMANCE_WINDOW:-3600}     # 1 hour
ANALYTICS_UTILIZATION_THRESHOLD=${ANALYTICS_UTILIZATION_THRESHOLD:-80} # 80%
ANALYTICS_EFFICIENCY_THRESHOLD=${ANALYTICS_EFFICIENCY_THRESHOLD:-70}   # 70%

# Async Processing Configuration
ASYNC_PROCESSING_ENABLED=${ASYNC_PROCESSING_ENABLED:-true}
MAX_CONCURRENT_TASKS=${MAX_CONCURRENT_TASKS:-5}            # Maximum concurrent tasks per agent
ASYNC_QUEUE_SIZE=${ASYNC_QUEUE_SIZE:-50}                   # Maximum async operations queue
ASYNC_TIMEOUT=${ASYNC_TIMEOUT:-300}                        # Async operation timeout in seconds
ASYNC_RETRY_ATTEMPTS=${ASYNC_RETRY_ATTEMPTS:-2}            # Retry attempts for async operations
NON_BLOCKING_OPERATIONS=${NON_BLOCKING_OPERATIONS:-true}   # Enable non-blocking task operations
CONCURRENT_BATCH_SIZE=${CONCURRENT_BATCH_SIZE:-3}          # Concurrent tasks per batch
ASYNC_MONITORING_INTERVAL=${ASYNC_MONITORING_INTERVAL:-10} # Async monitoring interval

# Resource Limits Configuration
RESOURCE_LIMITS_ENABLED=${RESOURCE_LIMITS_ENABLED:-true}
MAX_SYSTEM_LOAD=${MAX_SYSTEM_LOAD:-80}                           # Maximum system load percentage (0-100)
MAX_MEMORY_USAGE=${MAX_MEMORY_USAGE:-85}                         # Maximum memory usage percentage (0-100)
MAX_CPU_USAGE=${MAX_CPU_USAGE:-90}                               # Maximum CPU usage percentage (0-100)
MAX_DISK_USAGE=${MAX_DISK_USAGE:-90}                             # Maximum disk usage percentage (0-100)
RESOURCE_CHECK_INTERVAL=${RESOURCE_CHECK_INTERVAL:-30}           # Resource check interval in seconds
THROTTLE_THRESHOLD=${THROTTLE_THRESHOLD:-70}                     # Threshold for throttling (percentage)
BURST_LIMIT=${BURST_LIMIT:-10}                                   # Maximum burst tasks when resources are available
RESOURCE_MONITORING_ENABLED=${RESOURCE_MONITORING_ENABLED:-true} # Enable resource monitoring

# Task Compression Configuration
TASK_COMPRESSION_ENABLED=${TASK_COMPRESSION_ENABLED:-true}       # Enable task compression
MAX_TASK_DESCRIPTION_LENGTH=${MAX_TASK_DESCRIPTION_LENGTH:-1000} # Maximum uncompressed description length
COMPRESSION_ALGORITHM=${COMPRESSION_ALGORITHM:-"gzip"}           # Compression algorithm (gzip, bzip2, xz)
COMPRESSION_LEVEL=${COMPRESSION_LEVEL:-6}                        # Compression level (1-9)
COMPRESSION_THRESHOLD=${COMPRESSION_THRESHOLD:-500}              # Minimum length to compress
AUTO_COMPRESS_OLD_TASKS=${AUTO_COMPRESS_OLD_TASKS:-true}         # Auto-compress old tasks
COMPRESSION_RETENTION_DAYS=${COMPRESSION_RETENTION_DAYS:-30}     # Days to keep uncompressed tasks
TASK_ARCHIVE_ENABLED=${TASK_ARCHIVE_ENABLED:-true}               # Enable task archiving
ARCHIVE_COMPRESSION_RATIO=${ARCHIVE_COMPRESSION_RATIO:-0.8}      # Target compression ratio

# Check and enforce queue size limits
enforce_queue_limits() {
  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)
  local retention_seconds=$((TASK_RETENTION_DAYS * 24 * 60 * 60))
  local cutoff_time=$((current_time - retention_seconds))

  log_message "INFO" "Enforcing queue limits (max: ${MAX_QUEUE_SIZE}, retention: ${TASK_RETENTION_DAYS} days)"

  # Get current queue statistics
  local total_tasks
  total_tasks=$(jq '.tasks | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
  local queued_count
  queued_count=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
  local completed_count
  completed_count=$(jq '.completed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
  local failed_count
  failed_count=$(jq '.failed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  log_message "INFO" "Queue status: ${total_tasks} total, ${queued_count} queued, ${completed_count} completed, ${failed_count} failed"

  # Clean up old completed tasks
  if [[ ${completed_count} -gt ${MAX_COMPLETED_HISTORY} ]]; then
    local tasks_to_remove=$((completed_count - MAX_COMPLETED_HISTORY))
    log_message "INFO" "Removing ${tasks_to_remove} old completed tasks"

    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --arg cutoff "${cutoff_time}" \
      '.completed = (.completed | map(select(.completed_at > ($cutoff | tonumber))) | sort_by(.completed_at) | reverse | .[0:'"${MAX_COMPLETED_HISTORY}"'])' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Cleaned up old completed tasks"
    else
      rm -f "${temp_file}"
    fi
  fi

  # Clean up old failed tasks
  if [[ ${failed_count} -gt ${MAX_FAILED_HISTORY} ]]; then
    local tasks_to_remove=$((failed_count - MAX_FAILED_HISTORY))
    log_message "INFO" "Removing ${tasks_to_remove} old failed tasks"

    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --arg cutoff "${cutoff_time}" \
      '.failed = (.failed | map(select(.failed_at > ($cutoff | tonumber))) | sort_by(.failed_at) | reverse | .[0:'"${MAX_FAILED_HISTORY}"'])' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Cleaned up old failed tasks"
    else
      rm -f "${temp_file}"
    fi
  fi

  # If queue is still too large, remove oldest queued tasks (lowest priority first)
  if [[ ${total_tasks} -gt ${MAX_QUEUE_SIZE} ]]; then
    local excess_tasks=$((total_tasks - MAX_QUEUE_SIZE))
    log_message "WARNING" "Queue size ${total_tasks} exceeds limit ${MAX_QUEUE_SIZE}, removing ${excess_tasks} oldest low-priority tasks"

    local temp_file="${TASK_QUEUE_FILE}.tmp"
    # Keep only the highest priority tasks, sorted by priority and creation time
    if jq '.tasks |= (sort_by(.priority, .created) | reverse | .[0:'"${MAX_QUEUE_SIZE}"'])' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Reduced queue size by removing lowest priority tasks"
    else
      rm -f "${temp_file}"
    fi
  fi

  # Clean up expired queued tasks (older than expiration threshold)
  local queued_expiration_seconds=$((TASK_EXPIRATION_HOURS * 60 * 60))
  local queued_cutoff_time=$((current_time - queued_expiration_seconds))

  if [[ ${queued_count} -gt 0 ]]; then
    local expired_queued_count
    expired_queued_count=$(jq '.tasks[] | select(.status == "queued" and .created < '"${queued_cutoff_time}"') | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

    if [[ ${expired_queued_count} -gt 0 ]]; then
      log_message "INFO" "Removing ${expired_queued_count} expired queued tasks (older than ${TASK_EXPIRATION_HOURS} hours)"

      local temp_file="${TASK_QUEUE_FILE}.tmp"
      if jq '.tasks = (.tasks | map(select(.status != "queued" or .created >= '"${queued_cutoff_time}"')))' \
        "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
        mv "${temp_file}" "${TASK_QUEUE_FILE}"
        log_message "INFO" "Cleaned up expired queued tasks"
      else
        rm -f "${temp_file}"
      fi
    fi
  fi
}

# Check if queue has capacity for new tasks
check_queue_capacity() {
  local requested_slots="${1:-1}"

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    return 0 # Assume capacity if can't check
  fi

  local current_queued
  current_queued=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local available_slots=$((MAX_QUEUED_TASKS - current_queued))

  if [[ ${available_slots} -lt ${requested_slots} ]]; then
    log_message "WARNING" "Queue capacity exceeded: ${current_queued}/${MAX_QUEUED_TASKS} queued, requested ${requested_slots} more slots"
    return 1
  fi

  return 0
}

# Add task to queue
add_task() {
  local task_type="$1"
  local task_description="$2"
  local priority="${3:-5}"
  local parent_task_id="${4-}" # Optional parent task for dependencies
  local assigned_agent=""
  local task_id
  # Generate unique task ID using date and random
  local timestamp
  timestamp=$(date +%s%N)
  task_id=${timestamp:0:13}

  # Enhanced duplicate detection with similarity and time windows
  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE_FILE} ]]; then
    local current_time
    current_time=$(date +%s)
    local twenty_four_hours_ago=$((current_time - 86400)) # 24 hours in seconds

    # Check for exact duplicates first (same type and description)
    local exact_duplicate=""
    local jq_exact_output
    jq_exact_output=$(jq --arg desc "${task_description}" --arg type "${task_type}" \
      '.tasks[] | select(.type == $type and .description == $desc and (.status == "queued" or .status == "assigned" or .status == "in_progress"))' \
      "${TASK_QUEUE_FILE}" 2>/dev/null)
    local jq_exact_exit=$?

    if [[ ${jq_exact_exit} -eq 0 ]] && [[ -n ${jq_exact_output} ]]; then
      exact_duplicate=${jq_exact_output}
    fi

    if [[ -n ${exact_duplicate} ]]; then
      log_message "INFO" "Skipping exact duplicate task: ${task_type} - ${task_description}"
      return 0
    fi

    # Check for similar tasks within 24-hour window (agent restart tasks, health checks, etc.)
    local jq_similar_output
    jq_similar_output=$(jq --arg desc "${task_description}" --arg type "${task_type}" --arg cutoff "${twenty_four_hours_ago}" \
      '.tasks[] | select(.created > ($cutoff | tonumber) and (.status == "queued" or .status == "assigned" or .status == "in_progress" or .status == "completed"))' \
      "${TASK_QUEUE_FILE}" 2>/dev/null)
    local jq_similar_exit=$?

    if [[ ${jq_similar_exit} -eq 0 ]] && [[ -n ${jq_similar_output} ]]; then
      # Parse similar tasks and check for similarity
      echo "${jq_similar_output}" | jq -r '.type + "|" + .description' | while IFS='|' read -r existing_type existing_desc; do
        # Skip if different types
        if [[ "${existing_type}" != "${task_type}" ]]; then
          continue
        fi

        # Calculate similarity score (simple word overlap for now)
        local similarity_score=0
        local desc_words_new
        local desc_words_existing

        # Convert to lowercase and split into words
        desc_words_new=$(echo "${task_description}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq)
        desc_words_existing=$(echo "${existing_desc}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq)

        # Count common words
        local common_words
        common_words=$(comm -12 <(echo "${desc_words_new}") <(echo "${desc_words_existing}") | wc -l)
        local total_words_new
        total_words_new=$(echo "${desc_words_new}" | wc -l)
        local total_words_existing
        total_words_existing=$(echo "${desc_words_existing}" | wc -l)

        if [[ ${total_words_new} -gt 0 && ${total_words_existing} -gt 0 ]]; then
          # Jaccard similarity coefficient
          local union=$((total_words_new + total_words_existing - common_words))
          if [[ ${union} -gt 0 ]]; then
            similarity_score=$((common_words * 100 / union))
          fi
        fi

        # Consider tasks similar if they share 70% or more words (adjustable threshold)
        if [[ ${similarity_score} -ge 70 ]]; then
          log_message "INFO" "Skipping similar task (similarity: ${similarity_score}%): ${task_type} - ${task_description}"
          return 0
        fi
      done
    fi

    # Special handling for agent restart tasks (very common duplicates)
    if [[ ${task_type} == "restart" || ${task_description} == *"restart"* || ${task_description} == *"agent"* ]]; then
      local recent_restart_tasks
      recent_restart_tasks=$(jq --arg cutoff "${twenty_four_hours_ago}" \
        '.tasks[] | select(.created > ($cutoff | tonumber) and (.type == "restart" or (.description | contains("restart")) or (.description | contains("agent")))) | length' \
        "${TASK_QUEUE_FILE}" 2>/dev/null)

      if [[ ${recent_restart_tasks} -gt 0 ]]; then
        log_message "INFO" "Skipping duplicate agent restart task within 24 hours: ${task_description}"
        return 0
      fi
    fi

    # Special handling for health check tasks
    if [[ ${task_type} == "health" || ${task_description} == *"health"* || ${task_description} == *"monitor"* ]]; then
      local recent_health_tasks
      recent_health_tasks=$(jq --arg cutoff "${twenty_four_hours_ago}" \
        '.tasks[] | select(.created > ($cutoff | tonumber) and (.type == "health" or (.description | contains("health")) or (.description | contains("monitor")))) | length' \
        "${TASK_QUEUE_FILE}" 2>/dev/null)

      if [[ ${recent_health_tasks} -gt 2 ]]; then # Allow max 2 health checks per 24 hours
        log_message "INFO" "Skipping excessive health check task: ${task_description}"
        return 0
      fi
    fi
  fi

  # Check queue capacity before adding task
  if ! check_queue_capacity; then
    log_message "WARNING" "Queue at capacity, skipping task: ${task_type} - ${task_description}"
    return 1
  fi

  # Determine best agent for task
  assigned_agent=$(select_best_agent "${task_type}") || true

  if [[ -z ${assigned_agent} ]]; then
    log_message "WARNING" "No suitable agent found for task type: ${task_type}"
    return 1
  fi

  # Create task object with dependencies
  local created
  created=$(date +%s)
  local dependencies='[]'

  # Set dependencies if parent task provided
  if [[ -n ${parent_task_id} ]]; then
    dependencies="[\"${parent_task_id}\"]"
  fi

  local task_json
  # Compress task description if it's too long
  local compressed_description="${task_description}"
  if [[ "${TASK_COMPRESSION_ENABLED}" == "true" ]] && should_compress_task "${task_description}"; then
    compressed_description=$(compress_task_description "${task_description}")
    if [[ -z "${compressed_description}" ]]; then
      log_message "WARNING" "Failed to compress task description for ${task_id}, using original"
      compressed_description="${task_description}"
    fi
  fi

  printf -v task_json '{"id": "%s", "type": "%s", "description": "%s", "priority": %s, "assigned_agent": "%s", "status": "queued", "created": %s, "dependencies": %s}' \
    "${task_id}" "${task_type}" "${compressed_description}" "${priority}" "${assigned_agent}" "${created}" "${dependencies}"

  # Add task to queue file atomically
  if command -v jq &>/dev/null; then
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --argjson task "${task_json}" '.tasks += [$task]' "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Added task ${task_id} (${task_type}) to queue assigned to ${assigned_agent}"
    else
      log_message "ERROR" "Failed to add task ${task_id} to queue file"
      rm -f "${temp_file}"
      return 1
    fi
  else
    log_message "WARNING" "jq not available, task added but not persisted to queue file"
  fi

  echo "${task_id}"

  # Check for workflow chain and create dependent tasks
  if [[ -n ${task_type} ]]; then
    # Check if workflow chain exists for this task type
    local workflow
    workflow=$(get_workflow_chain "${task_type}")

    if [[ -n ${workflow} ]]; then
      create_workflow_chain "${task_type}" "${task_id}" "${task_description}"
    fi
  fi

  # Notify assigned agent
  notify_agent "${assigned_agent}" "new_task" "${task_id}"

  echo "${task_id}" # Return task ID for chaining
}

# Create a chain of dependent tasks based on workflow with enhanced failure handling
create_workflow_chain() {
  local base_type="$1"
  local parent_id="$2"
  local base_description="$3"

  local workflow
  workflow=$(get_workflow_chain "${base_type}")
  if [[ -z ${workflow} ]]; then
    return 0
  fi

  log_message "INFO" "Creating enhanced workflow chain for ${base_type}: ${workflow}"

  # Parse workflow chain (format: "step1->step2->step3")
  IFS='->' read -ra WORKFLOW_STEPS <<<"${workflow}"
  local previous_task_id="${parent_id}"
  local chain_tasks=("${parent_id}") # Track all tasks in the chain

  for ((i = 1; i < ${#WORKFLOW_STEPS[@]}; i++)); do
    local step_type="${WORKFLOW_STEPS[i]}"
    local step_description="Workflow step ${i}: ${step_type} for: ${base_description}"
    local step_priority=$((8 - i)) # Decrease priority for later steps, but keep higher than regular tasks

    # Create dependent task with enhanced metadata
    local step_task_id
    step_task_id=$(add_dependent_task "${step_type}" "${step_description}" "${step_priority}" "${previous_task_id}" "${base_type}" "${i}")

    if [[ -n ${step_task_id} ]]; then
      log_message "INFO" "Created workflow step ${step_task_id} (${step_type}) dependent on ${previous_task_id}"
      chain_tasks+=("${step_task_id}")
      previous_task_id="${step_task_id}"
    else
      log_message "ERROR" "Failed to create workflow step ${i} (${step_type})"
      break
    fi
  done

  # Mark the chain as created for monitoring
  if [[ ${#chain_tasks[@]} -gt 1 ]]; then
    log_message "INFO" "Workflow chain created with ${#chain_tasks[@]} tasks: ${chain_tasks[*]}"
  fi
}

# Enhanced function to add dependent tasks with better metadata
add_dependent_task() {
  local task_type="$1"
  local task_description="$2"
  local priority="${3:-5}"
  local parent_task_id="$4"
  local workflow_type="$5"
  local step_number="$6"

  # Generate unique task ID
  local timestamp
  timestamp=$(date +%s%N)
  local task_id
  task_id=${timestamp:0:13}

  # Check queue capacity
  if ! check_queue_capacity; then
    log_message "WARNING" "Queue at capacity, skipping dependent task: ${task_type} - ${task_description}"
    return 1
  fi

  # Determine best agent for task
  local assigned_agent
  assigned_agent=$(select_best_agent "${task_type}")
  if [[ -z ${assigned_agent} ]]; then
    log_message "WARNING" "No suitable agent found for dependent task type: ${task_type}"
    return 1
  fi

  # Create task object with enhanced dependency metadata
  local created
  created=$(date +%s)
  local dependencies
  dependencies="[\"${parent_task_id}\"]"

  local task_json
  # Compress task description if it's too long
  local compressed_description="${task_description}"
  if [[ "${TASK_COMPRESSION_ENABLED}" == "true" ]] && should_compress_task "${task_description}"; then
    compressed_description=$(compress_task_description "${task_description}")
    if [[ -z "${compressed_description}" ]]; then
      log_message "WARNING" "Failed to compress dependent task description for ${task_id}, using original"
      compressed_description="${task_description}"
    fi
  fi

  printf -v task_json '{"id": "%s", "type": "%s", "description": "%s", "priority": %s, "assigned_agent": "%s", "status": "blocked", "created": %s, "dependencies": %s, "workflow_type": "%s", "step_number": %s, "parent_task_id": "%s"}' \
    "${task_id}" "${task_type}" "${compressed_description}" "${priority}" "${assigned_agent}" "${created}" "${dependencies}" "${workflow_type}" "${step_number}" "${parent_task_id}"

  # Add task to queue file atomically
  if command -v jq &>/dev/null; then
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --argjson task "${task_json}" '.tasks += [$task]' "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Added dependent task ${task_id} (${task_type}) to queue, blocked until ${parent_task_id} completes"
    else
      log_message "ERROR" "Failed to add dependent task ${task_id} to queue file"
      rm -f "${temp_file}"
      return 1
    fi
  else
    log_message "WARNING" "jq not available, dependent task added but not persisted to queue file"
  fi

  echo "${task_id}"
}

# Select best agent for task based on capabilities and current load
select_best_agent() {
  local task_type="$1"
  local best_agent=""
  local best_score=0

  # Check if task type has specific requirement
  local requirement
  requirement=$(get_task_requirement "${task_type}")
  if [[ -n ${requirement} ]] && [[ -f "$(dirname "$0")/${requirement}" ]]; then
    echo "${requirement}"
    return 0
  fi

  # Score agents based on capabilities and priority
  for agent in "${ALL_AGENTS[@]}"; do
    if [[ ! -f "$(dirname "$0")/${agent}" ]]; then
      continue
    fi

    local score=0
    local capabilities
    capabilities=$(get_agent_capabilities "${agent}")
    local priority
    priority=$(get_agent_priority "${agent}")

    # Check if agent has relevant capabilities
    if [[ ${capabilities} == *"${task_type}"* ]]; then
      score=$((score + 10))
    fi

    # Add priority score (convert string to number)
    local priority_num
    priority_num=${priority//[^0-9]/}
    if [[ -z ${priority_num} ]]; then
      priority_num=1
    fi
    score=$((score + priority_num))

    # Check agent status (prefer available agents)
    local agent_status
    agent_status=$(get_agent_status "${agent}")
    if [[ ${agent_status} == "available" ]]; then
      score=$((score + 5))
    elif [[ ${agent_status} == "busy" ]]; then
      score=$((score - 3))
    fi

    if [[ ${score} -gt ${best_score} ]]; then
      best_score=${score}
      best_agent="${agent}"
    fi
  done

  echo "${best_agent}"
}

# Get agent status
get_agent_status() {
  local agent="$1"
  echo "available" # Simplified for now
}

# Notify agent of new task or status change
notify_agent() {
  local agent="$1"
  local notification_type="$2"
  local task_id="$3"
  local notification_file
  notification_file="${COMMUNICATION_DIR}/${agent}_notification.txt"
  local timestamp
  timestamp=$(date +%s)

  echo "${timestamp}|${notification_type}|${task_id}" >>"${notification_file}"

  log_message "INFO" "Notified ${agent}: ${notification_type} (${task_id})"
}

# Process completed tasks and update agent status
process_completed_tasks() {
  # Check for completed task notifications
  for notification_file in "${COMMUNICATION_DIR}"/*_completed.txt; do
    if [[ -f ${notification_file} ]]; then
      local agent_name
      agent_name=$(basename "${notification_file}" "_completed.txt")
      local task_info
      task_info=$(tail -1 "${notification_file}")

      if [[ -n ${task_info} ]]; then
        local task_id
        task_id=$(echo "${task_info}" | cut -d'|' -f2)
        local success
        success=$(echo "${task_info}" | cut -d'|' -f3)

        # Use the new enhanced complete_task function
        complete_task_enhanced "${task_id}" "${agent_name}" "${success}"

        log_message "INFO" "Processed completion notification for task ${task_id} by ${agent_name}"
      fi

      # Clear notification
      : >"${notification_file}"
    fi
  done

  # Check for failed task notifications
  for notification_file in "${COMMUNICATION_DIR}"/*_failed.txt; do
    if [[ -f ${notification_file} ]]; then
      local agent_name
      agent_name=$(basename "${notification_file}" "_failed.txt")
      local task_info
      task_info=$(tail -1 "${notification_file}")

      if [[ -n ${task_info} ]]; then
        local task_id
        task_id=$(echo "${task_info}" | cut -d'|' -f2)
        local error_message
        error_message=$(echo "${task_info}" | cut -d'|' -f3)

        # Use the new enhanced fail_task function
        fail_task_enhanced "${task_id}" "${agent_name}" "${error_message}"

        log_message "INFO" "Processed failure notification for task ${task_id} by ${agent_name}"
      fi

      # Clear notification
      : >"${notification_file}"
    fi
  done

  # Check for task started notifications
  for notification_file in "${COMMUNICATION_DIR}"/*_started.txt; do
    if [[ -f ${notification_file} ]]; then
      local agent_name
      agent_name=$(basename "${notification_file}" "_started.txt")
      local task_info
      task_info=$(tail -1 "${notification_file}")

      if [[ -n ${task_info} ]]; then
        local task_id
        task_id=$(echo "${task_info}" | cut -d'|' -f2)

        # Use the new start_task function
        start_task "${task_id}" "${agent_name}"

        log_message "INFO" "Processed start notification for task ${task_id} by ${agent_name}"
      fi

      # Clear notification
      : >"${notification_file}"
    fi
  done

  # Check for batch completed notifications
  for notification_file in "${COMMUNICATION_DIR}"/*_batch_completed.txt; do
    if [[ -f ${notification_file} ]]; then
      local agent_name
      agent_name=$(basename "${notification_file}" "_batch_completed.txt")
      local batch_info
      batch_info=$(tail -1 "${notification_file}")

      if [[ -n ${batch_info} ]]; then
        local batch_id
        batch_id=$(echo "${batch_info}" | cut -d'|' -f2)
        local success
        success=$(echo "${batch_info}" | cut -d'|' -f3)

        # Complete the batch
        complete_task_batch "${batch_id}" "${agent_name}" "${success}"

        log_message "INFO" "Processed batch completion notification for batch ${batch_id} by ${agent_name}"
      fi

      # Clear notification
      : >"${notification_file}"
    fi
  done
}

# Update task status with proper JSON manipulation
update_task_status() {
  local task_id="$1"
  local status="$2"
  local success="$3"

  if command -v jq &>/dev/null; then
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    local current_time
    current_time=$(date +%s)

    # Create atomic update with proper error handling
    if jq --arg task_id "${task_id}" --arg status "${status}" --arg success "${success}" --arg current_time "${current_time}" \
      '(.tasks[] | select(.id == $task_id) | .status) = $status |
			 (.tasks[] | select(.id == $task_id) | .updated_at) = $current_time |
			 if $status == "completed" then
			 	.tasks = (.tasks | map(if .id == $task_id then . + {"completed_at": $current_time, "success": ($success == "true")} else . end)) |
			 	.completed += [{"id": $task_id, "success": ($success == "true"), "completed_at": $current_time}]
			 elif $status == "failed" then
			 	.tasks = (.tasks | map(if .id == $task_id then . + {"failed_at": $current_time, "error": $success} else . end)) |
			 	.failed += [{"id": $task_id, "error": $success, "failed_at": $current_time}]
			 else . end' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then

      # Atomic move
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Updated task ${task_id} status to ${status}"
    else
      log_message "ERROR" "Failed to update task ${task_id} status to ${status}"
      rm -f "${temp_file}"
      return 1
    fi
  fi
}

# Enhanced agent health monitoring with stability measures
monitor_agent_health() {
  local current_time
  current_time=$(date +%s)

  for agent in "${ALL_AGENTS[@]}"; do
    if [[ ! -f "$(dirname "$0")/${agent}" ]]; then
      continue
    fi

    local agent_status
    agent_status=$(get_agent_status "${agent}")
    local last_seen
    last_seen=$(get_agent_last_seen "${agent}")
    local time_diff=$((current_time - last_seen))
    local restart_count
    restart_count=$(get_agent_restart_count "${agent}")
    local last_restart
    last_restart=$(get_agent_last_restart "${agent}")
    local time_since_restart=$((current_time - last_restart))

    # Enhanced health checks
    local is_healthy=true
    local health_reason=""

    # Check if agent process is actually running
    local pid_file
    pid_file="$(dirname "$0")/${agent}.pid"
    if [[ -f ${pid_file} ]]; then
      local pid
      pid=$(cat "${pid_file}")
      if ! kill -0 "${pid}" 2>/dev/null; then
        is_healthy=false
        health_reason="Process not running (PID ${pid})"
      fi
    else
      is_healthy=false
      health_reason="No PID file found"
    fi

    # Check for excessive restarts (circuit breaker)
    if [[ ${restart_count} -gt 5 ]]; then
      local time_window=$((current_time - 3600)) # 1 hour window
      if [[ ${last_restart} -gt ${time_window} ]]; then
        log_message "ERROR" "Agent ${agent} has failed ${restart_count} times in the last hour - implementing circuit breaker"
        update_agent_status "${agent}" "circuit_breaker"
        is_healthy=false
        health_reason="Circuit breaker activated (${restart_count} restarts)"
      fi
    fi

    # Check for long periods of unresponsiveness
    if [[ ${time_diff} -gt 1200 && ${agent_status} != "circuit_breaker" ]]; then
      is_healthy=false
      health_reason="Unresponsive for ${time_diff}s"
    fi

    # Check agent log for recent errors
    local log_file
    log_file="$(dirname "$0")/${agent}.log"
    if [[ -f ${log_file} ]]; then
      local recent_errors
      recent_errors=$(tail -20 "${log_file}" | grep -c -i 'error\|exception\|failed\|crash')
      if [[ ${recent_errors} -gt 3 ]]; then
        is_healthy=false
        health_reason="${recent_errors} recent errors in log"
      fi
    fi

    if [[ ${is_healthy} == false ]]; then
      log_message "WARNING" "Agent ${agent} unhealthy: ${health_reason}"

      # Implement exponential backoff for restarts
      local backoff_time=60 # Base 1 minute
      if [[ ${restart_count} -gt 0 ]]; then
        backoff_time=$((backoff_time * (2 ** restart_count))) # Exponential backoff
        # Cap at 1 hour
        if [[ ${backoff_time} -gt 3600 ]]; then
          backoff_time=3600
        fi
      fi

      if [[ ${time_since_restart} -lt ${backoff_time} ]]; then
        log_message "INFO" "Waiting ${backoff_time}s before restart attempt ${restart_count} for ${agent}"
        continue
      fi

      # Attempt to restart agent with stability measures
      if restart_agent "${agent}"; then
        increment_agent_restart_count "${agent}"
        update_agent_status "${agent}" "restarting"
      else
        log_message "ERROR" "Failed to restart ${agent} - marking as failed"
        update_agent_status "${agent}" "failed"
      fi
    else
      # Agent is healthy, reset restart count if it was in circuit breaker
      if [[ ${agent_status} == "circuit_breaker" && ${time_since_restart} -gt 7200 ]]; then
        # Reset circuit breaker after 2 hours of stability
        reset_agent_restart_count "${agent}"
        update_agent_status "${agent}" "available"
        log_message "INFO" "Reset circuit breaker for ${agent} after successful recovery"
      fi
    fi
  done
}

# Health Checks Functions
# Comprehensive health monitoring with automatic recovery mechanisms

# Perform health check on a specific agent
perform_agent_health_check() {
  local agent="$1"
  local current_time
  current_time=$(date +%s)

  if [[ "${HEALTH_CHECKS_ENABLED}" != "true" ]]; then
    return 0
  fi

  log_message "DEBUG" "Performing health check on agent: ${agent}"

  # Initialize health status if not exists
  initialize_agent_health_status "${agent}"

  local health_status="healthy"
  local health_score=100
  local issues=()

  # Check 1: Process health
  local pid_file
  pid_file="$(dirname "$0")/${agent}.pid"
  if [[ -f ${pid_file} ]]; then
    local pid
    pid=$(cat "${pid_file}" 2>/dev/null)
    if ! kill -0 "${pid}" 2>/dev/null; then
      health_status="unhealthy"
      health_score=$((health_score - 50))
      issues+=("Process not running (PID ${pid})")
    fi
  else
    health_status="unhealthy"
    health_score=$((health_score - 30))
    issues+=("No PID file found")
  fi

  # Check 2: Responsiveness (last seen within timeout)
  local last_seen
  last_seen=$(get_agent_last_seen "${agent}")
  local time_since_last_seen=$((current_time - last_seen))

  if [[ ${time_since_last_seen} -gt ${AGENT_HEALTH_TIMEOUT} ]]; then
    health_status="unhealthy"
    health_score=$((health_score - 40))
    issues+=("Unresponsive for ${time_since_last_seen}s (timeout: ${AGENT_HEALTH_TIMEOUT}s)")
  fi

  # Check 3: Error rate in recent logs
  local log_file
  log_file="$(dirname "$0")/${agent}.log"
  if [[ -f ${log_file} ]]; then
    local recent_errors
    recent_errors=$(tail -50 "${log_file}" 2>/dev/null | grep -c -i 'error\|exception\|failed\|crash' 2>/dev/null || echo "0")

    if [[ ${recent_errors} -gt 5 ]]; then
      health_score=$((health_score - 20))
      issues+=("${recent_errors} recent errors in log")
    fi
  fi

  # Check 4: Restart frequency (circuit breaker check)
  local restart_count
  restart_count=$(get_agent_restart_count "${agent}")
  local last_restart
  last_restart=$(get_agent_last_restart "${agent}")
  local time_since_restart=$((current_time - last_restart))

  if [[ ${restart_count} -gt 3 && ${time_since_restart} -lt 3600 ]]; then
    health_status="unhealthy"
    health_score=$((health_score - 30))
    issues+=("${restart_count} restarts in last hour")
  fi

  # Update health status
  update_agent_health_status "${agent}" "${health_status}" "${health_score}" "${issues[*]}"

  # Log health issues
  if [[ ${#issues[@]} -gt 0 ]]; then
    log_message "WARNING" "Agent ${agent} health check found ${#issues[@]} issues: ${issues[*]}"
  fi

  # Return health score
  echo "${health_score}"
}

# Perform health check on the orchestrator itself
perform_orchestrator_health_check() {
  local current_time
  current_time=$(date +%s)

  if [[ "${HEALTH_CHECKS_ENABLED}" != "true" ]]; then
    return 0
  fi

  log_message "DEBUG" "Performing orchestrator health check"

  local health_status="healthy"
  local health_score=100
  local issues=()

  # Check 1: Queue file accessibility
  if [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    health_status="unhealthy"
    health_score=$((health_score - 50))
    issues+=("Task queue file not accessible")
  else
    # Check queue file size (potential memory issue)
    local queue_size
    queue_size=$(stat -f%z "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
    if [[ ${queue_size} -gt 104857600 ]]; then # 100MB
      health_score=$((health_score - 20))
      issues+=("Queue file very large (${queue_size} bytes)")
    fi
  fi

  # Check 2: Agent status file accessibility
  if [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    health_status="unhealthy"
    health_score=$((health_score - 30))
    issues+=("Agent status file not accessible")
  fi

  # Check 3: Available agents count
  local available_agents=0
  for agent in "${ALL_AGENTS[@]}"; do
    local status
    status=$(get_agent_status "${agent}")
    if [[ "${status}" == "available" ]]; then
      available_agents=$((available_agents + 1))
    fi
  done

  if [[ ${available_agents} -eq 0 ]]; then
    health_score=$((health_score - 40))
    issues+=("No available agents")
  fi

  # Check 4: Queue backlog
  if command -v jq &>/dev/null && [[ -f ${TASK_QUEUE_FILE} ]]; then
    local queued_count
    queued_count=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

    if [[ ${queued_count} -gt 100 ]]; then
      health_score=$((health_score - 20))
      issues+=("Large queue backlog (${queued_count} tasks)")
    fi
  fi

  # Check 5: Memory usage (if available)
  local memory_usage
  memory_usage=$(ps -o rss= -p $$ 2>/dev/null | awk '{print $1}' 2>/dev/null || echo "0")
  if [[ ${memory_usage} -gt 500000 ]]; then # 500MB
    health_score=$((health_score - 15))
    issues+=("High memory usage (${memory_usage} KB)")
  fi

  # Update orchestrator health status
  update_orchestrator_health_status "${health_status}" "${health_score}" "${issues[*]}"

  # Log health issues
  if [[ ${#issues[@]} -gt 0 ]]; then
    log_message "WARNING" "Orchestrator health check found ${#issues[@]} issues: ${issues[*]}"
  fi

  # Return health score
  echo "${health_score}"
}

# Initialize agent health status tracking
initialize_agent_health_status() {
  local agent="$1"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    return
  fi

  local current_time
  current_time=$(date +%s)

  # Initialize health tracking for agent if not exists
  local temp_file="${AGENT_STATUS_FILE}.tmp"
  jq --arg agent "${agent}" --arg current_time "${current_time}" \
    '.agents[$agent].health = (.agents[$agent].health // {
			"status": "unknown",
			"score": 100,
			"last_check": $current_time,
			"issues": [],
			"check_count": 0,
			"failure_count": 0
		})' \
    "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null

  if [[ -f ${temp_file} ]]; then
    mv "${temp_file}" "${AGENT_STATUS_FILE}"
  fi
}

# Update agent health status
update_agent_health_status() {
  local agent="$1"
  local status="$2"
  local score="$3"
  local issues_str="$4"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    return
  fi

  local current_time
  current_time=$(date +%s)

  # Update health status
  local temp_file="${AGENT_STATUS_FILE}.tmp"
  jq --arg agent "${agent}" --arg status "${status}" --arg score "${score}" --arg issues_arg "${issues_str}" --arg current_time "${current_time}" \
    '.agents[$agent].health.status = $status |
		 .agents[$agent].health.score = ($score | tonumber) |
		 .agents[$agent].health.last_check = ($current_time | tonumber) |
		 .agents[$agent].health.issues = ($issues_arg | split(" ") | map(select(. != ""))) |
		 .agents[$agent].health.check_count = (.agents[$agent].health.check_count // 0) + 1 |
		 (.agents[$agent].health.failure_count = (.agents[$agent].health.failure_count // 0) + 1 | select($status == "unhealthy"))' \
    "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null

  if [[ -f ${temp_file} ]]; then
    mv "${temp_file}" "${AGENT_STATUS_FILE}"
  fi
}

# Update orchestrator health status
update_orchestrator_health_status() {
  local status="$1"
  local score="$2"
  local issues_str="$3"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    return
  fi

  local current_time
  current_time=$(date +%s)

  # Update orchestrator health status
  local temp_file="${AGENT_STATUS_FILE}.tmp"
  jq --arg status "${status}" --arg score "${score}" --arg issues_arg "${issues_str}" --arg current_time "${current_time}" \
    '.orchestrator = (.orchestrator // {}) |
		 .orchestrator.health = (.orchestrator.health // {}) |
		 .orchestrator.health.status = $status |
		 .orchestrator.health.score = ($score | tonumber) |
		 .orchestrator.health.last_check = ($current_time | tonumber) |
		 .orchestrator.health.issues = ($issues_arg | split(" ") | map(select(. != ""))) |
		 .orchestrator.health.check_count = (.orchestrator.health.check_count // 0) + 1 |
		 (.orchestrator.health.failure_count = (.orchestrator.health.failure_count // 0) + 1 | select($status == "unhealthy"))' \
    "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null

  if [[ -f ${temp_file} ]]; then
    mv "${temp_file}" "${AGENT_STATUS_FILE}"
  fi
}

# Perform automatic recovery for unhealthy agents
perform_automatic_recovery() {
  local agent="$1"

  if [[ "${HEALTH_CHECKS_ENABLED}" != "true" ]]; then
    return 0
  fi

  log_message "INFO" "Attempting automatic recovery for agent: ${agent}"

  # Get current health status
  local health_status
  health_status=$(jq -r ".agents[\"${agent}\"].health.status // \"unknown\"" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "unknown")

  if [[ "${health_status}" != "unhealthy" ]]; then
    log_message "INFO" "Agent ${agent} is not unhealthy, skipping recovery"
    return 0
  fi

  # Get failure count
  local failure_count
  failure_count=$(jq -r ".agents[\"${agent}\"].health.failure_count // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")

  if [[ ${failure_count} -gt ${AGENT_MAX_FAILURES} ]]; then
    log_message "WARNING" "Agent ${agent} has exceeded max failures (${AGENT_MAX_FAILURES}), implementing circuit breaker"
    update_agent_status "${agent}" "circuit_breaker"
    return 1
  fi

  # Attempt recovery based on health issues
  local issues
  issues=$(jq -r ".agents[\"${agent}\"].health.issues // [] | join(\" \")" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "")

  if [[ ${issues} == *"Process not running"* || ${issues} == *"No PID file"* ]]; then
    # Process-related issue - try restart
    log_message "INFO" "Attempting process restart for ${agent}"
    if restart_agent "${agent}"; then
      log_message "INFO" "Successfully restarted ${agent}"
      return 0
    fi
  elif [[ ${issues} == *"Unresponsive"* ]]; then
    # Responsiveness issue - try gentle restart
    log_message "INFO" "Attempting gentle restart for unresponsive ${agent}"
    if restart_agent "${agent}"; then
      log_message "INFO" "Successfully restarted unresponsive ${agent}"
      return 0
    fi
  fi

  log_message "ERROR" "Automatic recovery failed for ${agent}"
  return 1
}

# Get agent health status
get_agent_health_status() {
  local agent="$1"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    echo "unknown"
    return
  fi

  local status
  status=$(jq -r ".agents[\"${agent}\"].health.status // \"unknown\"" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "unknown")
  echo "${status}"
}

# Get agent health score
get_agent_health_score() {
  local agent="$1"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    echo "0"
    return
  fi

  local score
  score=$(jq -r ".agents[\"${agent}\"].health.score // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
  echo "${score}"
}

# Get orchestrator health status
get_orchestrator_health_status() {
  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    echo "unknown"
    return
  fi

  local status
  status=$(jq -r ".orchestrator.health.status // \"unknown\"" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "unknown")
  echo "${status}"
}

# Get orchestrator health score
get_orchestrator_health_score() {
  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    echo "0"
    return
  fi

  local score
  score=$(jq -r ".orchestrator.health.score // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
  echo "${score}"
}

# Enhanced health monitoring with automatic recovery
enhanced_health_monitoring() {
  if [[ "${HEALTH_CHECKS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)

  # Perform orchestrator health check
  local orchestrator_score
  orchestrator_score=$(perform_orchestrator_health_check)

  # Perform agent health checks
  for agent in "${ALL_AGENTS[@]}"; do
    if [[ ! -f "$(dirname "$0")/${agent}" ]]; then
      continue
    fi

    # Check if it's time for this agent's health check
    local last_check
    last_check=$(jq -r ".agents[\"${agent}\"].health.last_check // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
    local time_since_check=$((current_time - last_check))

    if [[ ${time_since_check} -ge ${AGENT_HEALTH_CHECK_INTERVAL} ]]; then
      local agent_score
      agent_score=$(perform_agent_health_check "${agent}")

      # Perform automatic recovery if agent is unhealthy
      local health_status
      health_status=$(get_agent_health_status "${agent}")
      if [[ "${health_status}" == "unhealthy" ]]; then
        perform_automatic_recovery "${agent}"
      fi
    fi
  done

  # Log overall system health
  local total_agents=${#ALL_AGENTS[@]}
  local healthy_agents=0
  local unhealthy_agents=0

  for agent in "${ALL_AGENTS[@]}"; do
    local status
    status=$(get_agent_health_status "${agent}")
    if [[ "${status}" == "healthy" ]]; then
      healthy_agents=$((healthy_agents + 1))
    elif [[ "${status}" == "unhealthy" ]]; then
      unhealthy_agents=$((unhealthy_agents + 1))
    fi
  done

  local orchestrator_status
  orchestrator_status=$(get_orchestrator_health_status)

  log_message "INFO" "Health Check Summary - Orchestrator: ${orchestrator_status}, Agents: ${healthy_agents}/${total_agents} healthy, ${unhealthy_agents} unhealthy"
}

# Retry Logic Functions
# Intelligent retry mechanism with exponential backoff and failure classification

# Classify error type to determine retry strategy
classify_error_type() {
  local error_message="$1"

  # Convert to lowercase for case-insensitive matching
  local error_lower
  error_lower=$(echo "${error_message}" | tr '[:upper:]' '[:lower:]')

  # Check for transient errors (should retry)
  for transient_error in "${RETRY_TRANSIENT_ERRORS[@]}"; do
    if [[ ${error_lower} == *"${transient_error}"* ]]; then
      echo "transient"
      return 0
    fi
  done

  # Check for permanent errors (should not retry)
  for permanent_error in "${RETRY_PERMANENT_ERRORS[@]}"; do
    if [[ ${error_lower} == *"${permanent_error}"* ]]; then
      echo "permanent"
      return 0
    fi
  done

  # Default to transient for unknown errors
  echo "transient"
}

# Calculate retry delay with exponential backoff and jitter
calculate_retry_delay() {
  local retry_count="$1"
  local base_delay="${2:-${RETRY_BASE_DELAY}}"
  local max_delay="${3:-${RETRY_MAX_DELAY}}"

  # Exponential backoff: base_delay * (2 ^ retry_count)
  local exponential_delay=$((base_delay * (2 ** retry_count)))

  # Cap at maximum delay
  if [[ ${exponential_delay} -gt ${max_delay} ]]; then
    exponential_delay=${max_delay}
  fi

  # Add jitter if enabled
  if [[ "${RETRY_JITTER_ENABLED}" == "true" ]]; then
    local jitter_range=$((exponential_delay * RETRY_JITTER_PERCENT / 100))
    local jitter=$((RANDOM % (jitter_range * 2) - jitter_range)) # Random value between -jitter_range and +jitter_range
    exponential_delay=$((exponential_delay + jitter))

    # Ensure delay doesn't go below base delay
    if [[ ${exponential_delay} -lt ${base_delay} ]]; then
      exponential_delay=${base_delay}
    fi
  fi

  echo "${exponential_delay}"
}

# Check if task should be retried based on various conditions
should_retry_task() {
  local task_id="$1"
  local error_message="$2"
  local current_retry_count="${3:-0}"

  if [[ "${RETRY_LOGIC_ENABLED}" != "true" ]]; then
    echo "false"
    return 1
  fi

  # Check maximum retry attempts
  if [[ ${current_retry_count} -ge ${MAX_RETRY_ATTEMPTS} ]]; then
    log_message "INFO" "Task ${task_id} has reached maximum retry attempts (${MAX_RETRY_ATTEMPTS})"
    echo "false"
    return 1
  fi

  # Classify error type
  local error_type
  error_type=$(classify_error_type "${error_message}")

  if [[ "${error_type}" == "permanent" ]]; then
    log_message "INFO" "Task ${task_id} failed with permanent error, not retrying: ${error_message}"
    echo "false"
    return 1
  fi

  # Check agent load threshold
  local agent_load
  agent_load=$(get_agent_current_load "${task_id}")
  local load_percentage=0

  if [[ ${MAX_AGENT_LOAD} -gt 0 ]]; then
    load_percentage=$((agent_load * 100 / MAX_AGENT_LOAD))
  fi

  if (($(echo "${load_percentage} >= ${RETRY_AGENT_LOAD_THRESHOLD}" | bc -l 2>/dev/null || echo "0"))); then
    log_message "INFO" "Agent load too high (${load_percentage}%) for task ${task_id} retry"
    echo "false"
    return 1
  fi

  # Check queue backlog threshold
  local queued_count
  queued_count=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  if [[ ${queued_count} -gt ${RETRY_QUEUE_BACKLOG_THRESHOLD} ]]; then
    log_message "INFO" "Queue backlog too high (${queued_count}) for task ${task_id} retry"
    echo "false"
    return 1
  fi

  # Check agent success rate for this task type
  local task_type
  task_type=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

  local success_rate
  success_rate=$(get_agent_success_rate "${task_id}" "${task_type}")

  if (($(echo "${success_rate} < ${RETRY_SUCCESS_RATE_THRESHOLD}" | bc -l 2>/dev/null || echo "0"))); then
    log_message "INFO" "Agent success rate too low (${success_rate}%) for task ${task_id} retry"
    echo "false"
    return 1
  fi

  log_message "INFO" "Task ${task_id} eligible for retry (attempt ${current_retry_count})"
  echo "true"
}

# Schedule a task for retry with calculated delay
schedule_task_retry() {
  local task_id="$1"
  local error_message="$2"
  local agent="$3"

  if [[ "${RETRY_LOGIC_ENABLED}" != "true" ]]; then
    return 1
  fi

  # Get current retry count
  local current_retry_count
  current_retry_count=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .retry_count // 0' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  # Check if task should be retried
  local should_retry
  should_retry=$(should_retry_task "${task_id}" "${error_message}" "${current_retry_count}")

  if [[ "${should_retry}" != "true" ]]; then
    return 1
  fi

  # Calculate retry delay
  local retry_delay
  retry_delay=$(calculate_retry_delay "${current_retry_count}")

  local current_time
  current_time=$(date +%s)
  local retry_at=$((current_time + retry_delay))

  # Update task with retry information
  local temp_file="${TASK_QUEUE_FILE}.tmp"
  if jq --arg task_id "${task_id}" --arg retry_at "${retry_at}" --arg error_message "${error_message}" --arg agent "${agent}" \
    '(.tasks[] | select(.id == $task_id) | .retry_count) = (.tasks[] | select(.id == $task_id) | .retry_count // 0) + 1 |
		 (.tasks[] | select(.id == $task_id) | .retry_at) = $retry_at |
		 (.tasks[] | select(.id == $task_id) | .last_error) = $error_message |
		 (.tasks[] | select(.id == $task_id) | .last_failed_agent) = $agent |
		 (.tasks[] | select(.id == $task_id) | .status) = "retry_scheduled"' \
    "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then

    mv "${temp_file}" "${TASK_QUEUE_FILE}"
    log_message "INFO" "Scheduled retry for task ${task_id} in ${retry_delay}s (attempt ${current_retry_count})"
    return 0
  else
    log_message "ERROR" "Failed to schedule retry for task ${task_id}"
    rm -f "${temp_file}"
    return 1
  fi
}

# Process tasks that are ready for retry
process_retry_tasks() {
  if [[ "${RETRY_LOGIC_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)

  # Find tasks ready for retry
  local retry_tasks
  retry_tasks=$(jq -r '.tasks[] | select(.status == "retry_scheduled" and (.retry_at // 0) <= '"${current_time}"') | .id' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${retry_tasks} ]]; then
    return 0
  fi

  local retry_count=0

  while IFS= read -r task_id; do
    if [[ -z ${task_id} ]]; then
      continue
    fi

    log_message "INFO" "Processing retry for task ${task_id}"

    # Get task details
    local task_data
    task_data=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | "\(.type)|\(.description)|\(.assigned_agent)|\(.retry_count)"' "${TASK_QUEUE_FILE}" 2>/dev/null)

    if [[ -z ${task_data} ]]; then
      continue
    fi

    local task_type description assigned_agent task_retry_count
    IFS='|' read -r task_type description assigned_agent task_retry_count <<<"${task_data}"

    # Try to find a different agent for retry (avoid the one that failed)
    local retry_agent="${assigned_agent}"
    local last_failed_agent
    last_failed_agent=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .last_failed_agent // ""' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "")

    if [[ -n ${last_failed_agent} && ${last_failed_agent} != "${assigned_agent}" ]]; then
      # Try to use the originally assigned agent first
      local agent_status
      agent_status=$(get_agent_status "${assigned_agent}")
      if [[ "${agent_status}" == "available" ]]; then
        retry_agent="${assigned_agent}"
      else
        # Find alternative agent
        retry_agent=$(select_best_agent_smart "${task_type}" "${description}")
      fi
    else
      # Find alternative agent since the same agent failed
      retry_agent=$(select_best_agent_smart "${task_type}" "${description}")
    fi

    if [[ -z ${retry_agent} ]]; then
      log_message "WARNING" "No available agent found for retry of task ${task_id}"
      continue
    fi

    # Update task for retry
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --arg task_id "${task_id}" --arg retry_agent "${retry_agent}" \
      '(.tasks[] | select(.id == $task_id) | .assigned_agent) = $retry_agent |
			 (.tasks[] | select(.id == $task_id) | .status) = "queued" |
			 (.tasks[] | select(.id == $task_id) | .retry_at) = null |
			 (.tasks[] | select(.id == $task_id) | .started_at) = null' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then

      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Task ${task_id} ready for retry with agent ${retry_agent} (attempt ${task_retry_count})"

      # Notify the retry agent
      notify_agent "${retry_agent}" "retry_task" "${task_id}"
      retry_count=$((retry_count + 1))
    else
      log_message "ERROR" "Failed to prepare task ${task_id} for retry"
      rm -f "${temp_file}"
    fi
  done < <(echo "${retry_tasks}")

  log_message "INFO" "Processed ${retry_count} tasks for retry"
}

# Enhanced task failure with retry logic
fail_task_with_retry() {
  local task_id="$1"
  local agent="$2"
  local error_message="$3"

  log_message "ERROR" "Task ${task_id} failed by ${agent}: ${error_message}"

  # First, try to schedule a retry
  if schedule_task_retry "${task_id}" "${error_message}" "${agent}"; then
    # Retry scheduled, don't mark as permanently failed yet
    log_message "INFO" "Retry scheduled for failed task ${task_id}"
    return 0
  fi

  # No retry possible, mark as permanently failed
  update_task_status "${task_id}" "failed" "${error_message}"

  # Update agent performance metrics
  local task_type
  task_type=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")
  local completion_time=0

  if command -v jq &>/dev/null; then
    local started_at
    started_at=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .started_at // 0' "${TASK_QUEUE_FILE}")
    local failed_at
    failed_at=$(date +%s)
    if [[ ${started_at} -gt 0 ]]; then
      completion_time=$((failed_at - started_at))
    fi
  fi

  update_agent_performance "${agent}" "${task_type}" "false" "${completion_time}"

  # Free up the agent
  update_agent_status "${agent}" "available"

  # Process dependent tasks with failure status (this will cancel dependent tasks)
  process_dependent_tasks_enhanced "${task_id}" "failed"
}

# Get retry statistics for reporting
get_retry_statistics() {
  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    echo "0|0|0|0"
    return
  fi

  local retry_scheduled
  retry_scheduled=$(jq '.tasks[] | select(.status == "retry_scheduled") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local total_retries
  total_retries=$(jq '.tasks[] | select(.retry_count > 0) | .retry_count' "${TASK_QUEUE_FILE}" 2>/dev/null | awk '{sum += $1} END {print sum+0}' || echo "0")

  local max_retries
  max_retries=$(jq '.tasks[] | select(.retry_count) | .retry_count' "${TASK_QUEUE_FILE}" 2>/dev/null | sort -nr | head -1 || echo "0")

  local failed_after_retries
  failed_after_retries=$(jq '.failed[] | select(.retry_count > 0) | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  echo "${retry_scheduled}|${total_retries}|${max_retries}|${failed_after_retries}"
}

# Queue Analytics Functions
# Comprehensive metrics collection, performance reporting, and utilization analytics

# Initialize analytics data structure
initialize_analytics() {
  if [[ "${QUEUE_ANALYTICS_ENABLED}" != "true" ]]; then
    return 0
  fi

  if [[ ! -f "${ANALYTICS_METRICS_FILE}" ]]; then
    local current_time
    current_time=$(date +%s)

    local initial_data
    initial_data='{
			"metadata": {
				"created_at": '"${current_time}"',
				"version": "1.0",
				"retention_days": '"${ANALYTICS_RETENTION_DAYS}"'
			},
			"metrics": [],
			"performance": {
				"agents": {},
				"task_types": {},
				"system": {}
			},
			"utilization": {
				"hourly": [],
				"daily": [],
				"weekly": []
			}
		}'

    echo "${initial_data}" >"${ANALYTICS_METRICS_FILE}"
    log_message "INFO" "Initialized analytics data structure at ${ANALYTICS_METRICS_FILE}"
  fi
}

# Collect comprehensive queue metrics
collect_queue_metrics() {
  if [[ "${QUEUE_ANALYTICS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)

  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    return 1
  fi

  # Initialize analytics if needed
  initialize_analytics

  # Collect basic queue statistics
  local queued_count
  queued_count=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local assigned_count
  assigned_count=$(jq '.tasks[] | select(.status == "assigned" or .status == "in_progress") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local completed_count
  completed_count=$(jq '.completed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local failed_count
  failed_count=$(jq '.failed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local retry_scheduled_count
  retry_scheduled_count=$(jq '.tasks[] | select(.status == "retry_scheduled") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local blocked_count
  blocked_count=$(jq '.tasks[] | select(.status == "blocked") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  # Collect batch statistics
  local active_batches
  active_batches=$(jq '.batches[] | select(.status == "active") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local completed_batches
  completed_batches=$(jq '.batches[] | select(.status == "completed") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  # Collect agent utilization
  local agent_utilization
  agent_utilization=$(get_agent_utilization_stats)

  # Collect task type distribution
  local task_type_distribution
  task_type_distribution=$(get_task_type_distribution)

  # Collect performance metrics
  local avg_completion_time
  avg_completion_time=$(calculate_average_completion_time)

  local throughput_per_hour
  throughput_per_hour=$(calculate_throughput_per_hour)

  local failure_rate
  failure_rate=$(calculate_failure_rate)

  # Create metrics entry
  local metrics_entry
  metrics_entry='{
		"timestamp": '"${current_time}"',
		"queue_stats": {
			"queued": '"${queued_count}"',
			"assigned": '"${assigned_count}"',
			"completed": '"${completed_count}"',
			"failed": '"${failed_count}"',
			"retry_scheduled": '"${retry_scheduled_count}"',
			"blocked": '"${blocked_count}"',
			"total_active": '"$((queued_count + assigned_count + retry_scheduled_count + blocked_count))"'
		},
		"batch_stats": {
			"active": '"${active_batches}"',
			"completed": '"${completed_batches}"'
		},
		"agent_utilization": '"${agent_utilization}"',
		"task_distribution": '"${task_type_distribution}"',
		"performance": {
			"avg_completion_time": '"${avg_completion_time}"',
			"throughput_per_hour": '"${throughput_per_hour}"',
			"failure_rate": '"${failure_rate}"'
		}
	}'

  # Add metrics to analytics file
  local temp_file="${ANALYTICS_METRICS_FILE}.tmp"
  if jq --argjson metrics "${metrics_entry}" '.metrics += [$metrics]' "${ANALYTICS_METRICS_FILE}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${ANALYTICS_METRICS_FILE}"
    log_message "INFO" "Collected queue metrics at ${current_time}"
  else
    log_message "ERROR" "Failed to collect queue metrics"
    rm -f "${temp_file}"
  fi
}

# Get agent utilization statistics
get_agent_utilization_stats() {
  local utilization_stats='{}'

  if ! command -v jq &>/dev/null || [[ ! -f "${AGENT_STATUS_FILE}" ]]; then
    echo "${utilization_stats}"
    return
  fi

  # Calculate utilization for each agent
  local agent_stats='['
  local first=true

  for agent in "${ALL_AGENTS[@]}"; do
    if [[ ! -f "$(dirname "$0")/${agent}" ]]; then
      continue
    fi

    local status
    status=$(get_agent_status "${agent}")
    local current_load
    current_load=$(get_agent_current_load "${agent}")
    local tasks_completed_today
    tasks_completed_today=$(get_agent_tasks_completed_today "${agent}")
    local avg_response_time
    avg_response_time=$(get_agent_avg_response_time "${agent}")

    local agent_entry
    agent_entry='{
			"name": "'"${agent}"'",
			"status": "'"${status}"'",
			"current_load": '"${current_load}"',
			"tasks_completed_today": '"${tasks_completed_today}"',
			"avg_response_time": '"${avg_response_time}"'
		}'

    if [[ ${first} == true ]]; then
      agent_stats="${agent_stats}${agent_entry}"
      first=false
    else
      agent_stats="${agent_stats},${agent_entry}"
    fi
  done

  agent_stats="${agent_stats}]"

  # Wrap in object
  utilization_stats='{"agents": '"${agent_stats}"'}'
  echo "${utilization_stats}"
}

# Get task type distribution
get_task_type_distribution() {
  local distribution='{}'

  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "${distribution}"
    return
  fi

  # Count tasks by type
  local type_counts
  type_counts="{$(jq -r '.tasks[] | .type' "${TASK_QUEUE_FILE}" 2>/dev/null | sort | uniq -c | awk '{print "\"" $2 "\": " $1}' | paste -sd, -)}"

  if [[ -n ${type_counts} ]]; then
    distribution="${type_counts}"
  fi

  echo "${distribution}"
}

# Calculate average completion time
calculate_average_completion_time() {
  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "0"
    return
  fi

  # Calculate average completion time from recent completed tasks
  local avg_time
  avg_time=$(jq -r '.completed[] | select(.completed_at and .started_at) | (.completed_at - .started_at)' "${TASK_QUEUE_FILE}" 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

  echo "${avg_time}"
}

# Calculate throughput per hour
calculate_throughput_per_hour() {
  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "0"
    return
  fi

  local current_time
  current_time=$(date +%s)
  local one_hour_ago=$((current_time - 3600))

  # Count completed tasks in the last hour
  local recent_completed
  recent_completed=$(jq '.completed[] | select(.completed_at > '"${one_hour_ago}"') | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  echo "${recent_completed}"
}

# Calculate failure rate
calculate_failure_rate() {
  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "0"
    return
  fi

  local total_completed
  total_completed=$(jq '.completed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local total_failed
  total_failed=$(jq '.failed | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local total_processed=$((total_completed + total_failed))

  if [[ ${total_processed} -gt 0 ]]; then
    local failure_rate
    failure_rate=$((total_failed * 100 / total_processed))
    echo "${failure_rate}"
  else
    echo "0"
  fi
}

# Generate comprehensive analytics report
generate_analytics_report() {
  if [[ "${QUEUE_ANALYTICS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)

  if ! command -v jq &>/dev/null || [[ ! -f "${ANALYTICS_METRICS_FILE}" ]]; then
    log_message "WARNING" "Analytics data not available for report generation"
    return 1
  fi

  log_message "INFO" "Generating comprehensive analytics report"

  # Calculate time ranges
  local one_hour_ago=$((current_time - 3600))
  local seven_days_ago=$((current_time - 604800))

  # Extract recent metrics
  local recent_metrics
  recent_metrics=$(jq '.metrics[] | select(.timestamp > '"${one_hour_ago}"')' "${ANALYTICS_METRICS_FILE}" 2>/dev/null)

  # Generate report
  {
    echo "# Queue Analytics Report"
    echo "Generated at: $(date)"
    echo ""

    echo "## System Overview"
    echo "- Analytics Enabled: ${QUEUE_ANALYTICS_ENABLED}"
    echo "- Collection Interval: ${ANALYTICS_COLLECTION_INTERVAL} seconds"
    echo "- Data Retention: ${ANALYTICS_RETENTION_DAYS} days"
    echo "- Performance Window: ${ANALYTICS_PERFORMANCE_WINDOW} seconds"
    echo ""

    # Current queue status
    if command -v jq &>/dev/null && [[ -f "${TASK_QUEUE_FILE}" ]]; then
      local current_queued
      current_queued=$(jq '.tasks[] | select(.status == "queued") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
      local current_assigned
      current_assigned=$(jq '.tasks[] | select(.status == "assigned" or .status == "in_progress") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
      local current_retry
      current_retry=$(jq '.tasks[] | select(.status == "retry_scheduled") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

      echo "## Current Queue Status"
      echo "- Queued Tasks: ${current_queued}"
      echo "- Assigned/In Progress: ${current_assigned}"
      echo "- Scheduled for Retry: ${current_retry}"
      echo "- Total Active: $((current_queued + current_assigned + current_retry))"
      echo ""
    fi

    # Performance metrics (last hour)
    if [[ -n ${recent_metrics} ]]; then
      echo "## Performance Metrics (Last Hour)"
      local avg_completion_time
      avg_completion_time=$(echo "${recent_metrics}" | jq '.performance.avg_completion_time' 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

      local avg_throughput
      avg_throughput=$(echo "${recent_metrics}" | jq '.performance.throughput_per_hour' 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

      local avg_failure_rate
      avg_failure_rate=$(echo "${recent_metrics}" | jq '.performance.failure_rate' 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

      echo "- Average Completion Time: ${avg_completion_time} seconds"
      echo "- Average Throughput: ${avg_throughput} tasks/hour"
      echo "- Average Failure Rate: ${avg_failure_rate}%"
      echo ""
    fi

    # Agent utilization
    echo "## Agent Utilization"
    local total_agents=${#ALL_AGENTS[@]}
    local available_agents=0
    local busy_agents=0

    for agent in "${ALL_AGENTS[@]}"; do
      if [[ -f "$(dirname "$0")/${agent}" ]]; then
        local status
        status=$(get_agent_status "${agent}")
        if [[ "${status}" == "available" ]]; then
          available_agents=$((available_agents + 1))
        elif [[ "${status}" == "busy" ]]; then
          busy_agents=$((busy_agents + 1))
        fi
      fi
    done

    local utilization_percentage=0
    if [[ ${total_agents} -gt 0 ]]; then
      utilization_percentage=$((busy_agents * 100 / total_agents))
    fi

    echo "- Total Agents: ${total_agents}"
    echo "- Available: ${available_agents}"
    echo "- Busy: ${busy_agents}"
    echo "- Utilization: ${utilization_percentage}%"

    if [[ ${utilization_percentage} -ge ${ANALYTICS_UTILIZATION_THRESHOLD} ]]; then
      echo "- **WARNING**: High utilization detected (>= ${ANALYTICS_UTILIZATION_THRESHOLD}%)"
    fi
    echo ""

    # Task type distribution
    if command -v jq &>/dev/null && [[ -f "${TASK_QUEUE_FILE}" ]]; then
      echo "## Task Type Distribution"
      local task_types
      task_types=$(jq -r '.tasks[] | .type' "${TASK_QUEUE_FILE}" 2>/dev/null | sort | uniq -c | sort -nr | head -10)

      if [[ -n ${task_types} ]]; then
        echo "| Task Type | Count |"
        echo "|-----------|-------|"
        echo "${task_types}" | while read -r count type; do
          echo "| ${type} | ${count} |"
        done
        echo ""
      fi
    fi

    # Efficiency analysis
    echo "## Efficiency Analysis"
    local efficiency_score
    efficiency_score=$((100 - avg_failure_rate))

    echo "- Efficiency Score: ${efficiency_score}% (100% - failure rate)"

    if [[ ${efficiency_score} -lt ${ANALYTICS_EFFICIENCY_THRESHOLD} ]]; then
      echo "- **WARNING**: Low efficiency detected (< ${ANALYTICS_EFFICIENCY_THRESHOLD}%)"
      echo "- Recommendations:"
      echo "  - Review agent health and restart failed agents"
      echo "  - Check for recurring task failures"
      echo "  - Consider adjusting retry policies"
    fi
    echo ""

    # Trends (if we have enough historical data)
    local historical_metrics
    historical_metrics=$(jq '.metrics[] | select(.timestamp > '"${seven_days_ago}"')' "${ANALYTICS_METRICS_FILE}" 2>/dev/null)

    if [[ -n ${historical_metrics} ]]; then
      echo "## Trends (Last 7 Days)"
      local avg_queued_trend
      avg_queued_trend=$(echo "${historical_metrics}" | jq '.queue_stats.queued' 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

      local avg_completion_trend
      avg_completion_trend=$(echo "${historical_metrics}" | jq '.performance.avg_completion_time' 2>/dev/null | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

      echo "- Average Queue Size: ${avg_queued_trend} tasks"
      echo "- Average Completion Time: ${avg_completion_trend} seconds"
      echo ""
    fi

    # Recommendations
    echo "## Recommendations"

    if [[ ${current_queued} -gt 50 ]]; then
      echo "- **High Queue Backlog**: Consider increasing agent capacity or optimizing task processing"
    fi

    if [[ ${utilization_percentage} -lt 30 ]]; then
      echo "- **Low Utilization**: Agents may be over-provisioned or tasks may be bottlenecked elsewhere"
    fi

    if [[ ${avg_failure_rate} -gt 20 ]]; then
      echo "- **High Failure Rate**: Investigate root causes of task failures and improve error handling"
    fi

    if [[ ${avg_completion_time} -gt 600 ]]; then
      echo "- **Slow Processing**: Tasks are taking too long - consider optimization or parallel processing"
    fi

    echo ""
    echo "---"
    echo "*Report generated by Task Orchestrator Analytics*"

  } >"${ANALYTICS_REPORT_FILE}"

  log_message "INFO" "Analytics report generated: ${ANALYTICS_REPORT_FILE}"
}

# Clean up old analytics data
cleanup_analytics_data() {
  if [[ "${QUEUE_ANALYTICS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)
  local cutoff_time=$((current_time - (ANALYTICS_RETENTION_DAYS * 24 * 60 * 60)))

  if ! command -v jq &>/dev/null || [[ ! -f "${ANALYTICS_METRICS_FILE}" ]]; then
    return 0
  fi

  log_message "INFO" "Cleaning up analytics data older than ${ANALYTICS_RETENTION_DAYS} days"

  # Remove old metrics
  local temp_file="${ANALYTICS_METRICS_FILE}.tmp"
  if jq '.metrics = (.metrics | map(select(.timestamp > '"${cutoff_time}"')))' "${ANALYTICS_METRICS_FILE}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${ANALYTICS_METRICS_FILE}"
    log_message "INFO" "Cleaned up old analytics data"
  else
    rm -f "${temp_file}"
  fi
}

# Get agent tasks completed today
get_agent_tasks_completed_today() {
  local agent="$1"
  local today_start
  today_start=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 00:00:00" "+%s" 2>/dev/null || date -d "today 00:00:00" +%s 2>/dev/null || echo "0")

  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "0"
    return
  fi

  local tasks_completed
  tasks_completed=$(jq '.completed[] | select(.completed_at > '"${today_start}"' and (.assigned_agent == "'"${agent}"'" or .agent == "'"${agent}"'")) | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  echo "${tasks_completed}"
}

# Get agent average response time
get_agent_avg_response_time() {
  local agent="$1"

  if ! command -v jq &>/dev/null || [[ ! -f "${TASK_QUEUE_FILE}" ]]; then
    echo "0"
    return
  fi

  # Calculate average time from assignment to completion for recent tasks
  local avg_response
  avg_response=$(jq '.completed[] | select(.assigned_agent == "'"${agent}"'" or .agent == "'"${agent}"'") | select(.completed_at and .started_at) | (.completed_at - .started_at)' "${TASK_QUEUE_FILE}" 2>/dev/null | tail -20 | awk '{sum += $1; count++} END {if (count > 0) print int(sum / count); else print 0}' || echo "0")

  echo "${avg_response}"
}

# Async Processing Functions
# Non-blocking operations and concurrent task processing

# Initialize async processing system
initialize_async_processing() {
  if [[ "${ASYNC_PROCESSING_ENABLED}" != "true" ]]; then
    return 0
  fi

  # Create async operations tracking file
  local async_file="${SCRIPT_DIR}/async_operations.json"
  if [[ ! -f "${async_file}" ]]; then
    local initial_data
    initial_data='{
			"metadata": {
				"created_at": '"$(date +%s)"',
				"version": "1.0"
			},
			"operations": [],
			"concurrent_limits": {}
		}'

    echo "${initial_data}" >"${async_file}"
    log_message "INFO" "Initialized async processing system at ${async_file}"
  fi
}

# Start async task processing
start_async_task() {
  local task_id="$1"
  local agent="$2"

  if [[ "${ASYNC_PROCESSING_ENABLED}" != "true" ]]; then
    return 1
  fi

  # Check concurrent task limits
  local agent_concurrent
  agent_concurrent=$(get_agent_concurrent_tasks "${agent}")

  if [[ ${agent_concurrent} -ge ${MAX_CONCURRENT_TASKS} ]]; then
    log_message "WARNING" "Agent ${agent} at concurrent task limit (${MAX_CONCURRENT_TASKS})"
    return 1
  fi

  # Check async queue size
  local async_queue_size
  async_queue_size=$(get_async_queue_size)

  if [[ ${async_queue_size} -ge ${ASYNC_QUEUE_SIZE} ]]; then
    log_message "WARNING" "Async queue at capacity (${ASYNC_QUEUE_SIZE})"
    return 1
  fi

  # Start task asynchronously
  local operation_id
  operation_id=$(start_async_operation "${task_id}" "${agent}")

  if [[ -n ${operation_id} ]]; then
    log_message "INFO" "Started async processing for task ${task_id} with agent ${agent} (operation: ${operation_id})"
    return 0
  fi

  return 1
}

# Start an async operation
start_async_operation() {
  local task_id="$1"
  local agent="$2"
  local async_file="${SCRIPT_DIR}/async_operations.json"

  local operation_id
  operation_id="async_$(date +%s)_${task_id}"
  local current_time
  current_time=$(date +%s)

  # Create operation record
  local operation_data
  operation_data='{
		"id": "'"${operation_id}"'",
		"task_id": "'"${task_id}"'",
		"agent": "'"${agent}"'",
		"status": "running",
		"started_at": '"${current_time}"',
		"timeout_at": '"$((current_time + ASYNC_TIMEOUT))"',
		"retry_count": 0
	}'

  # Add to async operations file
  local temp_file="${async_file}.tmp"
  if jq --argjson operation "${operation_data}" '.operations += [$operation]' "${async_file}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${async_file}"

    # Start the operation in background
    start_background_task "${task_id}" "${agent}" "${operation_id}" &

    echo "${operation_id}"
    return 0
  else
    log_message "ERROR" "Failed to create async operation for task ${task_id}"
    rm -f "${temp_file}"
    return 1
  fi
}

# Start background task processing
start_background_task() {
  local task_id="$1"
  local agent="$2"
  local operation_id="$3"

  # Update task status to in_progress
  update_task_status "${task_id}" "in_progress"

  # Notify agent to start processing
  notify_agent "${agent}" "start_task" "${task_id}"

  # Monitor the task in background
  monitor_async_task "${task_id}" "${agent}" "${operation_id}" &
}

# Monitor async task completion
monitor_async_task() {
  local task_id="$1"
  local agent="$2"
  local operation_id="$3"
  local start_time
  start_time=$(date +%s)

  while true; do
    # Check if task is completed
    local task_status
    task_status=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

    if [[ "${task_status}" == "completed" || "${task_status}" == "failed" ]]; then
      # Task finished, update async operation
      complete_async_operation "${operation_id}" "${task_status}"
      break
    fi

    # Check for timeout
    local current_time
    current_time=$(date +%s)
    local elapsed=$((current_time - start_time))

    if [[ ${elapsed} -gt ${ASYNC_TIMEOUT} ]]; then
      log_message "WARNING" "Async task ${task_id} timed out after ${ASYNC_TIMEOUT} seconds"
      fail_async_operation "${operation_id}" "timeout"
      break
    fi

    sleep "${ASYNC_MONITORING_INTERVAL}"
  done
}

# Complete async operation
complete_async_operation() {
  local operation_id="$1"
  local final_status="$2"
  local async_file="${SCRIPT_DIR}/async_operations.json"

  local current_time
  current_time=$(date +%s)

  # Update operation status
  local temp_file="${async_file}.tmp"
  if jq --arg operation_id "${operation_id}" --arg final_status "${final_status}" --arg current_time "${current_time}" \
    '(.operations[] | select(.id == $operation_id) | .status) = "completed" |
		 (.operations[] | select(.id == $operation_id) | .completed_at) = $current_time |
		 (.operations[] | select(.id == $operation_id) | .final_status) = $final_status' \
    "${async_file}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${async_file}"
    log_message "INFO" "Completed async operation ${operation_id} with status ${final_status}"
  else
    log_message "ERROR" "Failed to complete async operation ${operation_id}"
    rm -f "${temp_file}"
  fi
}

# Fail async operation
fail_async_operation() {
  local operation_id="$1"
  local error_reason="$2"
  local async_file="${SCRIPT_DIR}/async_operations.json"

  local current_time
  current_time=$(date +%s)

  # Update operation status
  local temp_file="${async_file}.tmp"
  if jq --arg operation_id "${operation_id}" --arg error_reason "${error_reason}" --arg current_time "${current_time}" \
    '(.operations[] | select(.id == $operation_id) | .status) = "failed" |
		 (.operations[] | select(.id == $operation_id) | .failed_at) = $current_time |
		 (.operations[] | select(.id == $operation_id) | .error_reason) = $error_reason' \
    "${async_file}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${async_file}"
    log_message "ERROR" "Failed async operation ${operation_id}: ${error_reason}"
  else
    log_message "ERROR" "Failed to update async operation ${operation_id} failure status"
    rm -f "${temp_file}"
  fi
}

# Get agent concurrent task count
get_agent_concurrent_tasks() {
  local agent="$1"
  local async_file="${SCRIPT_DIR}/async_operations.json"

  if ! command -v jq &>/dev/null || [[ ! -f "${async_file}" ]]; then
    echo "0"
    return
  fi

  local concurrent_count
  concurrent_count=$(jq '.operations[] | select(.agent == "'"${agent}"'" and .status == "running") | length' "${async_file}" 2>/dev/null || echo "0")

  echo "${concurrent_count}"
}

# Get async queue size
get_async_queue_size() {
  local async_file="${SCRIPT_DIR}/async_operations.json"

  if ! command -v jq &>/dev/null || [[ ! -f "${async_file}" ]]; then
    echo "0"
    return
  fi

  local queue_size
  queue_size=$(jq '.operations | length' "${async_file}" 2>/dev/null || echo "0")

  echo "${queue_size}"
}

# Process async operations (cleanup and monitoring)
process_async_operations() {
  if [[ "${ASYNC_PROCESSING_ENABLED}" != "true" ]]; then
    return 0
  fi

  local async_file="${SCRIPT_DIR}/async_operations.json"

  if ! command -v jq &>/dev/null || [[ ! -f "${async_file}" ]]; then
    return 1
  fi

  local current_time
  current_time=$(date +%s)

  # Clean up completed operations older than 1 hour
  local one_hour_ago=$((current_time - 3600))

  local temp_file="${async_file}.tmp"
  if jq '.operations = (.operations | map(select(.status == "running" or (.completed_at // 0) > '"${one_hour_ago}"' or (.failed_at // 0) > '"${one_hour_ago}"' )))' \
    "${async_file}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${async_file}"
  fi

  # Check for timed out operations
  local timed_out_ops
  timed_out_ops=$(jq -r '.operations[] | select(.status == "running" and (.timeout_at // 0) < '"${current_time}"') | .id' "${async_file}" 2>/dev/null)

  if [[ -n ${timed_out_ops} ]]; then
    echo "${timed_out_ops}" | while read -r op_id; do
      log_message "WARNING" "Async operation ${op_id} timed out"
      fail_async_operation "${op_id}" "timeout"
    done
  fi

  # Check for stuck operations (running but no corresponding task)
  local running_ops
  running_ops=$(jq -r '.operations[] | select(.status == "running") | "\(.id)|\(.task_id)"' "${async_file}" 2>/dev/null)

  if [[ -n ${running_ops} ]]; then
    echo "${running_ops}" | while IFS='|' read -r op_id task_id; do
      local task_exists
      task_exists=$(jq '.tasks[] | select(.id == "'"${task_id}"'") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

      if [[ ${task_exists} -eq 0 ]]; then
        log_message "WARNING" "Async operation ${op_id} references non-existent task ${task_id}"
        fail_async_operation "${op_id}" "task_not_found"
      fi
    done
  fi
}

# Enhanced task distribution with async processing
distribute_tasks_async() {
  log_message "INFO" "Distributing tasks with async processing support"

  if [[ "${ASYNC_PROCESSING_ENABLED}" != "true" ]]; then
    distribute_tasks
    return $?
  fi

  local tasks_assigned=0
  local async_tasks_started=0

  # Get queued tasks sorted by priority
  local queued_tasks
  queued_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.assigned_agent)|\(.priority)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r task_id task_type agent priority; do
    local calc_priority
    calc_priority=$(calculate_task_priority "${task_id}")
    echo "${calc_priority}|${task_id}|${task_type}|${agent}|${priority}"
  done | sort -t'|' -k1 -nr | head -n "${MAX_CONCURRENT_TASKS}")

  if [[ -z ${queued_tasks} ]]; then
    log_message "INFO" "No queued tasks to distribute"
    return 0
  fi

  # Process tasks with async support
  while IFS='|' read -r calc_priority task_id task_type agent priority; do
    # Double-check task is still queued
    local current_status
    current_status=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

    if [[ "${current_status}" != "queued" ]]; then
      continue
    fi

    # Try async processing first
    if start_async_task "${task_id}" "${agent}"; then
      async_tasks_started=$((async_tasks_started + 1))
      log_message "INFO" "Started async processing for task ${task_id}"
    else
      # Fall back to synchronous processing
      local agent_status
      agent_status=$(get_agent_status "${agent}")

      if [[ "${agent_status}" == "available" ]]; then
        update_task_status "${task_id}" "assigned"
        notify_agent "${agent}" "assigned_task" "${task_id}"
        update_agent_status "${agent}" "busy"
        tasks_assigned=$((tasks_assigned + 1))
        log_message "INFO" "Assigned task ${task_id} synchronously to ${agent}"
      fi
    fi
  done < <(echo "${queued_tasks}")

  log_message "INFO" "Async distribution completed: ${async_tasks_started} async tasks started, ${tasks_assigned} sync tasks assigned"
}

# Get async processing statistics
get_async_processing_stats() {
  local async_file="${SCRIPT_DIR}/async_operations.json"

  if ! command -v jq &>/dev/null || [[ ! -f "${async_file}" ]]; then
    echo "0|0|0|0"
    return
  fi

  local running_count
  running_count=$(jq '.operations[] | select(.status == "running") | length' "${async_file}" 2>/dev/null || echo "0")

  local completed_count
  completed_count=$(jq '.operations[] | select(.status == "completed") | length' "${async_file}" 2>/dev/null || echo "0")

  local failed_count
  failed_count=$(jq '.operations[] | select(.status == "failed") | length' "${async_file}" 2>/dev/null || echo "0")

  local total_operations
  total_operations=$((running_count + completed_count + failed_count))

  echo "${running_count}|${completed_count}|${failed_count}|${total_operations}"
}

# Resource Limits Functions
# Resource throttling and capacity management

# Check system resource usage
check_system_resources() {
  local resource_type="$1"

  case "${resource_type}" in
  "cpu")
    get_cpu_usage
    ;;
  "memory")
    get_memory_usage
    ;;
  "disk")
    get_disk_usage
    ;;
  "load")
    get_system_load
    ;;
  "all")
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    local mem_usage
    mem_usage=$(get_memory_usage)
    local disk_usage
    disk_usage=$(get_disk_usage)
    local load_avg
    load_avg=$(get_system_load)

    echo "${cpu_usage}|${mem_usage}|${disk_usage}|${load_avg}"
    ;;
  *)
    echo "0"
    ;;
  esac
}

# Get CPU usage percentage
get_cpu_usage() {
  # Try different methods to get CPU usage
  if command -v top &>/dev/null; then
    # macOS specific
    local cpu_idle
    local cpu_output
    cpu_output=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $7}')
    cpu_idle=${cpu_output%\%}
    if [[ -n ${cpu_idle} ]]; then
      local cpu_usage=$((100 - cpu_idle))
      echo "${cpu_usage}"
      return
    fi
  fi

  # Fallback to ps-based calculation
  local cpu_usage
  cpu_usage=$(ps -A -o %cpu | awk '{sum += $1} END {print int(sum)}' 2>/dev/null || echo "0")
  echo "${cpu_usage}"
}

# Get memory usage percentage
get_memory_usage() {
  if command -v vm_stat &>/dev/null; then
    # macOS specific
    local pages_free pages_active pages_inactive pages_speculative pages_wired
    pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
    pages_active=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
    pages_inactive=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
    pages_speculative=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | tr -d '.')
    pages_wired=$(vm_stat | grep "Pages wired down" | awk '{print $3}' | tr -d '.')

    local total_pages=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired))
    local used_pages=$((pages_active + pages_inactive + pages_speculative + pages_wired))

    if [[ ${total_pages} -gt 0 ]]; then
      local mem_usage=$((used_pages * 100 / total_pages))
      echo "${mem_usage}"
      return
    fi
  fi

  # Fallback method
  local mem_usage
  mem_usage=$(ps -A -o %mem | awk '{sum += $1} END {print int(sum)}' 2>/dev/null || echo "0")
  echo "${mem_usage}"
}

# Get disk usage percentage
get_disk_usage() {
  local disk_usage
  local disk_output
  disk_output=$(df / | tail -1 | awk '{print $5}' 2>/dev/null || echo "0%")
  disk_usage=${disk_output%\%}
  echo "${disk_usage}"
}

# Get system load average
get_system_load() {
  local load_avg
  load_avg=$(uptime | awk -F'load averages?: ' '{print $2}' | awk -F', ' '{print $1}' 2>/dev/null)

  if [[ -z ${load_avg} ]]; then
    # Fallback to /proc/loadavg if available
    load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "0")
  fi

  # Convert to percentage (assuming 1.0 = 100% load)
  local load_percent
  load_percent=$(echo "scale=0; ${load_avg} * 100" | bc -l 2>/dev/null || echo "0")
  echo "${load_percent}"
}

# Check if system resources are within limits
check_resource_limits() {
  if [[ "${RESOURCE_LIMITS_ENABLED}" != "true" ]]; then
    echo "true"
    return 0
  fi

  local all_resources
  all_resources=$(check_system_resources "all")
  local cpu_usage mem_usage disk_usage load_avg
  IFS='|' read -r cpu_usage mem_usage disk_usage load_avg <<<"${all_resources}"

  local resources_ok=true
  local exceeded_resources=()

  # Check CPU usage
  if [[ ${cpu_usage} -gt ${MAX_CPU_USAGE} ]]; then
    resources_ok=false
    exceeded_resources+=("CPU:${cpu_usage}%")
  fi

  # Check memory usage
  if [[ ${mem_usage} -gt ${MAX_MEMORY_USAGE} ]]; then
    resources_ok=false
    exceeded_resources+=("Memory:${mem_usage}%")
  fi

  # Check disk usage
  if [[ ${disk_usage} -gt ${MAX_DISK_USAGE} ]]; then
    resources_ok=false
    exceeded_resources+=("Disk:${disk_usage}%")
  fi

  # Check system load
  if [[ ${load_avg} -gt ${MAX_SYSTEM_LOAD} ]]; then
    resources_ok=false
    exceeded_resources+=("Load:${load_avg}%")
  fi

  if [[ ${resources_ok} == false ]]; then
    log_message "WARNING" "Resource limits exceeded: ${exceeded_resources[*]}"
  fi

  echo "${resources_ok}"
}

# Apply resource-based throttling
apply_resource_throttling() {
  if [[ "${RESOURCE_LIMITS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local all_resources
  all_resources=$(check_system_resources "all")
  local cpu_usage mem_usage disk_usage load_avg
  IFS='|' read -r cpu_usage mem_usage disk_usage load_avg <<<"${all_resources}"

  local throttle_level=0

  # Determine throttling level based on resource usage
  if [[ ${cpu_usage} -gt ${THROTTLE_THRESHOLD} || ${mem_usage} -gt ${THROTTLE_THRESHOLD} || ${load_avg} -gt ${THROTTLE_THRESHOLD} ]]; then
    throttle_level=1
  fi

  if [[ ${cpu_usage} -gt ${MAX_CPU_USAGE} || ${mem_usage} -gt ${MAX_MEMORY_USAGE} || ${load_avg} -gt ${MAX_SYSTEM_LOAD} ]]; then
    throttle_level=2
  fi

  if [[ ${disk_usage} -gt ${MAX_DISK_USAGE} ]]; then
    throttle_level=3
  fi

  case ${throttle_level} in
  0)
    # No throttling - allow burst operations
    log_message "INFO" "Resource usage normal - allowing burst operations up to ${BURST_LIMIT} tasks"
    ;;
  1)
    # Light throttling - reduce concurrent operations
    log_message "WARNING" "Light resource throttling active - reducing concurrent operations"
    # Reduce async concurrent tasks
    export MAX_CONCURRENT_TASKS=$((MAX_CONCURRENT_TASKS / 2))
    if [[ ${MAX_CONCURRENT_TASKS} -lt 1 ]]; then
      MAX_CONCURRENT_TASKS=1
    fi
    ;;
  2)
    # Moderate throttling - pause non-critical operations
    log_message "ERROR" "Moderate resource throttling active - pausing non-critical operations"
    # Further reduce concurrent tasks
    export MAX_CONCURRENT_TASKS=$((MAX_CONCURRENT_TASKS / 4))
    if [[ ${MAX_CONCURRENT_TASKS} -lt 1 ]]; then
      MAX_CONCURRENT_TASKS=1
    fi
    # Disable async processing temporarily
    export ASYNC_PROCESSING_ENABLED=false
    ;;
  3)
    # Severe throttling - emergency measures
    log_message "CRITICAL" "Severe resource throttling active - emergency measures"
    # Stop all new task processing
    export MAX_CONCURRENT_TASKS=0
    export ASYNC_PROCESSING_ENABLED=false
    # This will effectively pause the orchestrator
    ;;
  esac

  echo "${throttle_level}"
}

# Monitor resource usage and apply throttling
monitor_resource_limits() {
  if [[ "${RESOURCE_LIMITS_ENABLED}" != "true" ]]; then
    return 0
  fi

  local current_time
  current_time=$(date +%s)

  # Check resources periodically
  local last_check_file="${SCRIPT_DIR}/resource_check.timestamp"
  local last_check=0

  if [[ -f ${last_check_file} ]]; then
    last_check=$(cat "${last_check_file}" 2>/dev/null || echo "0")
  fi

  local time_since_check=$((current_time - last_check))

  if [[ ${time_since_check} -ge ${RESOURCE_CHECK_INTERVAL} ]]; then
    # Update timestamp
    echo "${current_time}" >"${last_check_file}"

    # Check resource limits
    local resources_ok
    resources_ok=$(check_resource_limits)

    if [[ "${resources_ok}" == "false" ]]; then
      # Apply throttling
      local throttle_level
      throttle_level=$(apply_resource_throttling)

      # Log resource status
      local all_resources
      all_resources=$(check_system_resources "all")
      local cpu_usage mem_usage disk_usage load_avg
      IFS='|' read -r cpu_usage mem_usage disk_usage load_avg <<<"${all_resources}"

      log_message "INFO" "Resource monitoring - CPU: ${cpu_usage}%, Memory: ${mem_usage}%, Disk: ${disk_usage}%, Load: ${load_avg}%, Throttle Level: ${throttle_level}"
    fi
  fi
}

# Check if task can be started based on resource limits
can_start_task() {
  local task_type="$1"

  if [[ "${RESOURCE_LIMITS_ENABLED}" != "true" ]]; then
    echo "true"
    return 0
  fi

  # Check basic resource limits
  local resources_ok
  resources_ok=$(check_resource_limits)

  if [[ "${resources_ok}" == "false" ]]; then
    log_message "INFO" "Cannot start task ${task_type} - resource limits exceeded"
    echo "false"
    return 1
  fi

  # Check task-specific resource requirements
  case "${task_type}" in
  "build" | "compile")
    # High CPU tasks
    local cpu_usage
    cpu_usage=$(get_cpu_usage)
    if [[ ${cpu_usage} -gt ${THROTTLE_THRESHOLD} ]]; then
      log_message "INFO" "Cannot start ${task_type} task - CPU usage too high (${cpu_usage}%)"
      echo "false"
      return 1
    fi
    ;;
  "test" | "analyze")
    # Memory-intensive tasks
    local mem_usage
    mem_usage=$(get_memory_usage)
    if [[ ${mem_usage} -gt ${THROTTLE_THRESHOLD} ]]; then
      log_message "INFO" "Cannot start ${task_type} task - memory usage too high (${mem_usage}%)"
      echo "false"
      return 1
    fi
    ;;
  esac

  echo "true"
}

# Get resource limits status for reporting
get_resource_limits_status() {
  if [[ "${RESOURCE_LIMITS_ENABLED}" != "true" ]]; then
    echo "disabled"
    return
  fi

  local all_resources
  all_resources=$(check_system_resources "all")
  local cpu_usage mem_usage disk_usage load_avg
  IFS='|' read -r cpu_usage mem_usage disk_usage load_avg <<<"${all_resources}"

  local status="normal"
  local issues=()

  if [[ ${cpu_usage} -gt ${MAX_CPU_USAGE} ]]; then
    status="critical"
    issues+=("CPU:${cpu_usage}%")
  fi

  if [[ ${mem_usage} -gt ${MAX_MEMORY_USAGE} ]]; then
    status="critical"
    issues+=("Memory:${mem_usage}%")
  fi

  if [[ ${disk_usage} -gt ${MAX_DISK_USAGE} ]]; then
    status="critical"
    issues+=("Disk:${disk_usage}%")
  fi

  if [[ ${load_avg} -gt ${MAX_SYSTEM_LOAD} ]]; then
    status="critical"
    issues+=("Load:${load_avg}%")
  fi

  if [[ ${cpu_usage} -gt ${THROTTLE_THRESHOLD} || ${mem_usage} -gt ${THROTTLE_THRESHOLD} || ${load_avg} -gt ${THROTTLE_THRESHOLD} ]]; then
    if [[ "${status}" == "normal" ]]; then
      status="warning"
    fi
  fi

  echo "${status}|${cpu_usage}|${mem_usage}|${disk_usage}|${load_avg}|${issues[*]}"
}

# Task Compression Functions
# Efficient storage and retrieval of large task descriptions

# Compress task description if needed
compress_task_description() {
  local task_description="$1"

  if [[ "${TASK_COMPRESSION_ENABLED}" != "true" ]]; then
    echo "${task_description}"
    return 0
  fi

  local description_length=${#task_description}

  # Check if compression is needed
  if [[ ${description_length} -lt ${COMPRESSION_THRESHOLD} ]]; then
    echo "${task_description}"
    return 0
  fi

  # Compress the description
  local compressed_data
  case "${COMPRESSION_ALGORITHM}" in
  "gzip")
    if command -v gzip &>/dev/null; then
      compressed_data=$(echo "${task_description}" | gzip -c -"${COMPRESSION_LEVEL}" | base64)
      echo "COMPRESSED:${COMPRESSION_ALGORITHM}:${compressed_data}"
      return 0
    fi
    ;;
  "bzip2")
    if command -v bzip2 &>/dev/null; then
      compressed_data=$(echo "${task_description}" | bzip2 -c -"${COMPRESSION_LEVEL}" | base64)
      echo "COMPRESSED:${COMPRESSION_ALGORITHM}:${compressed_data}"
      return 0
    fi
    ;;
  "xz")
    if command -v xz &>/dev/null; then
      compressed_data=$(echo "${task_description}" | xz -c -"${COMPRESSION_LEVEL}" | base64)
      echo "COMPRESSED:${COMPRESSION_ALGORITHM}:${compressed_data}"
      return 0
    fi
    ;;
  esac

  # Fallback: truncate if compression not available
  if [[ ${description_length} -gt ${MAX_TASK_DESCRIPTION_LENGTH} ]]; then
    local truncated="${task_description:0:${MAX_TASK_DESCRIPTION_LENGTH}}..."
    echo "${truncated}"
  else
    echo "${task_description}"
  fi
}

# Decompress task description if compressed
decompress_task_description() {
  local task_description="$1"

  # Check if description is compressed
  if [[ ${task_description} != COMPRESSED:* ]]; then
    echo "${task_description}"
    return 0
  fi

  # Extract compression info
  local algorithm compressed_data
  IFS=':' read -r _ algorithm compressed_data <<<"${task_description}"

  # Decompress based on algorithm
  local decompressed_data
  case "${algorithm}" in
  "gzip")
    if command -v gzip &>/dev/null; then
      decompressed_data=$(echo "${compressed_data}" | base64 -d | gzip -d)
      echo "${decompressed_data}"
      return 0
    fi
    ;;
  "bzip2")
    if command -v bzip2 &>/dev/null; then
      decompressed_data=$(echo "${compressed_data}" | base64 -d | bzip2 -d)
      echo "${decompressed_data}"
      return 0
    fi
    ;;
  "xz")
    if command -v xz &>/dev/null; then
      decompressed_data=$(echo "${compressed_data}" | base64 -d | xz -d)
      echo "${decompressed_data}"
      return 0
    fi
    ;;
  esac

  # Fallback: return compressed data if decompression fails
  log_message "WARNING" "Failed to decompress task description with algorithm: ${algorithm}"
  echo "${task_description}"
}

# Check if task description should be compressed
should_compress_task() {
  local task_description="$1"
  local task_age_days="${2:-0}"

  if [[ "${TASK_COMPRESSION_ENABLED}" != "true" ]]; then
    echo "false"
    return 1
  fi

  local description_length=${#task_description}

  # Compress if description is too long
  if [[ ${description_length} -gt ${COMPRESSION_THRESHOLD} ]]; then
    echo "true"
    return 0
  fi

  # Compress old tasks if auto-compression is enabled
  if [[ "${AUTO_COMPRESS_OLD_TASKS}" == "true" && ${task_age_days} -gt ${COMPRESSION_RETENTION_DAYS} ]]; then
    echo "true"
    return 0
  fi

  echo "false"
}

# Compress old tasks in the queue
compress_old_tasks() {
  if [[ "${TASK_COMPRESSION_ENABLED}" != "true" || "${AUTO_COMPRESS_OLD_TASKS}" != "true" ]]; then
    return 0
  fi

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    return 1
  fi

  local current_time
  current_time=$(date +%s)
  local cutoff_time=$((current_time - (COMPRESSION_RETENTION_DAYS * 24 * 60 * 60)))

  log_message "INFO" "Compressing old tasks older than ${COMPRESSION_RETENTION_DAYS} days"

  local compressed_count=0

  # Find tasks that need compression
  local tasks_to_compress
  tasks_to_compress=$(jq -r '.tasks[] | select(.created < '"${cutoff_time}"' and (.description | length > '"${COMPRESSION_THRESHOLD}"')) | .id' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${tasks_to_compress} ]]; then
    return 0
  fi

  while IFS= read -r task_id; do
    if [[ -z ${task_id} ]]; then
      continue
    fi

    # Get current description
    local current_description
    current_description=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .description' "${TASK_QUEUE_FILE}" 2>/dev/null)

    if [[ -z ${current_description} || ${current_description} == COMPRESSED:* ]]; then
      continue
    fi

    # Compress the description
    local compressed_description
    compressed_description=$(compress_task_description "${current_description}")

    if [[ "${compressed_description}" != "${current_description}" ]]; then
      # Update the task with compressed description
      local temp_file="${TASK_QUEUE_FILE}.tmp"
      if jq --arg task_id "${task_id}" --arg description "${compressed_description}" \
        '(.tasks[] | select(.id == $task_id) | .description) = $description' \
        "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then

        mv "${temp_file}" "${TASK_QUEUE_FILE}"
        compressed_count=$((compressed_count + 1))
        log_message "INFO" "Compressed description for task ${task_id}"
      else
        rm -f "${temp_file}"
      fi
    fi
  done < <(echo "${tasks_to_compress}")

  if [[ ${compressed_count} -gt 0 ]]; then
    log_message "INFO" "Compressed ${compressed_count} old task descriptions"
  fi
}

# Archive completed tasks for long-term storage
archive_completed_tasks() {
  if [[ "${TASK_ARCHIVE_ENABLED}" != "true" ]]; then
    return 0
  fi

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    return 1
  fi

  local current_time
  current_time=$(date +%s)
  local archive_cutoff=$((current_time - (COMPRESSION_RETENTION_DAYS * 24 * 60 * 60)))

  log_message "INFO" "Archiving completed tasks older than ${COMPRESSION_RETENTION_DAYS} days"

  # Create archive directory if it doesn't exist
  local archive_dir="${SCRIPT_DIR}/task_archive"
  mkdir -p "${archive_dir}"

  # Get tasks to archive
  local tasks_to_archive
  tasks_to_archive=$(jq -r '.completed[] | select(.completed_at < '"${archive_cutoff}"')' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${tasks_to_archive} ]]; then
    return 0
  fi

  local archive_file
  archive_file="${archive_dir}/completed_tasks_$(date +%Y%m%d_%H%M%S).json"

  # Create archive with compressed descriptions
  local archived_tasks='[]'
  local archive_count=0

  while read -r task_data; do
    local task_json
    task_json=$(echo "${task_data}" | base64 -d)

    # Compress description if needed
    local description
    description=$(echo "${task_json}" | jq -r '.description // ""')

    if [[ -n ${description} ]]; then
      local compressed_desc
      compressed_desc=$(compress_task_description "${description}")
      task_json=$(echo "${task_json}" | jq --arg desc "${compressed_desc}" '.description = $desc')
    fi

    archived_tasks=$(echo "${archived_tasks}" | jq --argjson task "${task_json}" '. + [$task]')
    archive_count=$((archive_count + 1))
  done < <(echo "${tasks_to_archive}" | jq -s '.' | jq -r '.[] | @base64')

  # Write archive file
  local archive_data
  archive_data='{
		"metadata": {
			"created_at": '"${current_time}"',
			"compression_ratio": '"${ARCHIVE_COMPRESSION_RATIO}"',
			"task_count": '"${archive_count}"'
		},
		"tasks": '"${archived_tasks}"'
	}'

  echo "${archive_data}" >"${archive_file}"

  if [[ -f ${archive_file} ]]; then
    log_message "INFO" "Archived ${archive_count} completed tasks to ${archive_file}"

    # Remove archived tasks from main queue
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq '.completed = (.completed | map(select(.completed_at >= '"${archive_cutoff}"')))' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then

      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Removed archived tasks from main queue"
    else
      rm -f "${temp_file}"
    fi
  else
    log_message "ERROR" "Failed to create archive file: ${archive_file}"
  fi
}

# Get compression statistics
get_compression_statistics() {
  if [[ "${TASK_COMPRESSION_ENABLED}" != "true" ]]; then
    echo "disabled|0|0|0"
    return
  fi

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    echo "error|0|0|0"
    return
  fi

  # Count compressed vs uncompressed tasks
  local total_tasks
  total_tasks=$(jq '.tasks | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local compressed_tasks
  compressed_tasks=$(jq '.tasks[] | select(.description | startswith("COMPRESSED:")) | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  # Calculate compression ratio
  local compression_ratio=0
  if [[ ${total_tasks} -gt 0 ]]; then
    compression_ratio=$((compressed_tasks * 100 / total_tasks))
  fi

  echo "enabled|${total_tasks}|${compressed_tasks}|${compression_ratio}"
}

# Optimize task storage by compressing and archiving
optimize_task_storage() {
  if [[ "${TASK_COMPRESSION_ENABLED}" != "true" ]]; then
    return 0
  fi

  log_message "INFO" "Starting task storage optimization"

  # Compress old task descriptions
  compress_old_tasks

  # Archive old completed tasks
  archive_completed_tasks

  # Clean up old archive files (keep last 10)
  local archive_dir="${SCRIPT_DIR}/task_archive"
  if [[ -d ${archive_dir} ]]; then
    local old_archives
    old_archives="$(find "${archive_dir}" -name "*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -n -10 | cut -d' ' -f2-)"
    if [[ -n ${old_archives} ]]; then
      echo "${old_archives}" | xargs rm -f
      log_message "INFO" "Cleaned up old archive files"
    fi
  fi

  log_message "INFO" "Task storage optimization completed"
}

# Get decompressed task description for display
get_task_description_display() {
  local task_id="$1"

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    echo "Task queue not accessible"
    return 1
  fi

  local description
  description=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .description' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${description} ]]; then
    echo "Task not found"
    return 1
  fi

  # Decompress if needed
  local display_description
  display_description=$(decompress_task_description "${description}")

  # Truncate for display if still too long
  if [[ ${#display_description} -gt ${MAX_TASK_DESCRIPTION_LENGTH} ]]; then
    display_description="${display_description:0:${MAX_TASK_DESCRIPTION_LENGTH}}... [truncated]"
  fi

  echo "${display_description}"
}

# Get agent's last seen timestamp (placeholder - implement based on your agent communication)
get_agent_last_seen() {
  local agent="$1"
  local timestamp=0

  if command -v jq &>/dev/null && [[ -f ${AGENT_STATUS_FILE} ]]; then
    timestamp=$(jq -r ".agents[\"${agent}\"].last_seen // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
  fi

  echo "${timestamp}"
}

# Get agent's restart count
get_agent_restart_count() {
  local agent="$1"
  local count=0

  if command -v jq &>/dev/null && [[ -f ${AGENT_STATUS_FILE} ]]; then
    count=$(jq -r ".agents[\"${agent}\"].restart_count // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
  fi

  echo "${count}"
}

# Get agent's last restart timestamp
get_agent_last_restart() {
  local agent="$1"
  local timestamp=0

  if command -v jq &>/dev/null && [[ -f ${AGENT_STATUS_FILE} ]]; then
    timestamp=$(jq -r ".agents[\"${agent}\"].last_restart // 0" "${AGENT_STATUS_FILE}" 2>/dev/null || echo "0")
  fi

  echo "${timestamp}"
}

# Increment agent's restart count
increment_agent_restart_count() {
  local agent="$1"
  local current_time
  current_time=$(date +%s)

  if command -v jq &>/dev/null; then
    local temp_file="${AGENT_STATUS_FILE}.tmp"
    if jq --arg agent "${agent}" --arg current_time "${current_time}" \
      '.agents[$agent].restart_count = (.agents[$agent].restart_count // 0) + 1 |
			 .agents[$agent].last_restart = $current_time' \
      "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${AGENT_STATUS_FILE}"
    fi
  fi
}

# Reset agent's restart count (after successful recovery)
reset_agent_restart_count() {
  local agent="$1"

  if command -v jq &>/dev/null; then
    local temp_file="${AGENT_STATUS_FILE}.tmp"
    if jq --arg agent "${agent}" \
      '.agents[$agent].restart_count = 0 |
			 .agents[$agent].last_restart = 0' \
      "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${AGENT_STATUS_FILE}"
    fi
  fi
}

# Enhanced agent restart with better error handling and validation
restart_agent() {
  local agent="$1"
  local max_retries=3
  local retry_count=0

  log_message "INFO" "Attempting to restart ${agent}"

  # Kill existing process if running
  local pid_file
  pid_file="$(dirname "$0")/${agent}.pid"
  if [[ -f ${pid_file} ]]; then
    local old_pid
    old_pid=$(cat "${pid_file}" 2>/dev/null)
    if [[ -n ${old_pid} ]] && kill -0 "${old_pid}" 2>/dev/null; then
      log_message "INFO" "Terminating existing process ${old_pid} for ${agent}"
      kill "${old_pid}"
      # Wait up to 5 seconds for graceful shutdown
      local wait_count=0
      while kill -0 "${old_pid}" 2>/dev/null && [[ ${wait_count} -lt 5 ]]; do
        sleep 1
        wait_count=$((wait_count + 1))
      done
      # Force kill if still running
      if kill -0 "${old_pid}" 2>/dev/null; then
        log_message "WARNING" "Force killing ${old_pid} for ${agent}"
        kill -9 "${old_pid}" 2>/dev/null || true
      fi
    fi
    rm -f "${pid_file}"
  fi

  # Validate agent script exists and is executable
  local agent_path
  agent_path="$(dirname "$0")/${agent}"
  if [[ ! -f ${agent_path} ]]; then
    log_message "ERROR" "Agent script ${agent_path} does not exist"
    return 1
  fi

  if [[ ! -x ${agent_path} ]]; then
    log_message "ERROR" "Agent script ${agent_path} is not executable"
    return 1
  fi

  # Attempt to start new instance with retries
  local new_pid=""
  while [[ ${retry_count} -lt ${max_retries} ]]; do
    log_message "INFO" "Starting ${agent} (attempt ${retry_count})"

    # Start agent in background
    nohup bash "${agent_path}" >>"$(dirname "$0")/${agent}.log" 2>&1 &
    new_pid=$!

    # Wait a moment for process to start
    sleep 2

    # Verify process started successfully
    if kill -0 "${new_pid}" 2>/dev/null; then
      echo "${new_pid}" >"${pid_file}"
      log_message "INFO" "Successfully restarted ${agent} with PID ${new_pid}"
      return 0
    else
      log_message "WARNING" "Failed to start ${agent} (attempt ${retry_count})"
      retry_count=$((retry_count + 1))
      sleep 5 # Wait before retry
    fi
  done

  log_message "ERROR" "Failed to restart ${agent} after ${max_retries} attempts"
  return 1
}

# Get task information (assigned agent and type)
get_task_info() {
  local task_id="$1"
  # Simplified - return a default agent and type
  echo "agent_build.sh|build"
}

# Enhanced task distribution with intelligent priority processing and batch support
distribute_tasks() {
  log_message "INFO" "Distributing queued tasks with intelligent priority processing and batch support"

  # Use smart assignment if enabled
  if [[ "${SMART_ASSIGNMENT_ENABLED}" == "true" ]]; then
    distribute_tasks_smart
    return $?
  fi

  if [[ "${BATCH_PROCESSING_ENABLED}" != "true" ]]; then
    # Fall back to single-task processing if batch processing is disabled
    distribute_tasks_single
    return $?
  fi

  local tasks_assigned=0
  local batches_processed=0
  local high_priority_threshold=8                       # Tasks with priority >= 8 are considered high priority
  local critical_types=("debug" "security" "emergency") # Always process these types first

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, cannot distribute tasks"
    return 1
  fi

  # First pass: Process critical/high-priority tasks in batches
  log_message "INFO" "Processing critical and high-priority tasks in batches"
  local critical_tasks
  critical_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.priority)|\(.assigned_agent)"' "${TASK_QUEUE_FILE}")

  if [[ -n "${critical_tasks}" ]]; then
    # Group critical tasks by agent for batch processing
    local agent_batches
    declare -A agent_batches

    while IFS='|' read -r task_id task_type priority agent; do
      # Check if this is a critical type or high priority task
      local is_critical=false
      for critical_type in "${critical_types[@]}"; do
        if [[ "${task_type}" == "${critical_type}" ]]; then
          is_critical=true
          break
        fi
      done

      if [[ ${is_critical} == true || ${priority} -ge ${high_priority_threshold} ]]; then
        # Add to agent's batch
        if [[ -z "${agent_batches[${agent}]}" ]]; then
          agent_batches[${agent}]="${task_id}"
        else
          agent_batches[${agent}]="${agent_batches[${agent}]} ${task_id}"
        fi
      fi
    done < <(echo "${critical_tasks}")

    # Process agent batches
    for agent in "${!agent_batches[@]}"; do
      if [[ ${batches_processed} -ge ${MAX_BATCHES_PER_CYCLE} ]]; then
        log_message "INFO" "Reached maximum batches per cycle (${MAX_BATCHES_PER_CYCLE})"
        break
      fi

      local batch_tasks
      batch_tasks="${agent_batches[${agent}]}"
      local batch_size
      batch_size=$(echo "${batch_tasks}" | wc -w)

      if [[ ${batch_size} -gt ${BATCH_SIZE} ]]; then
        # Limit batch size
        batch_tasks=$(echo "${batch_tasks}" | head -n "${BATCH_SIZE}")
        batch_size=${BATCH_SIZE}
      fi

      log_message "INFO" "Processing critical batch of ${batch_size} tasks for ${agent}"

      # Process batch for this agent
      local batch_assigned
      batch_assigned=$(process_agent_batch "${agent}" "${batch_tasks}")

      tasks_assigned=$((tasks_assigned + batch_assigned))
      batches_processed=$((batches_processed + 1))

      # Add interval between batches if configured
      if [[ ${BATCH_INTERVAL} -gt 0 && ${batches_processed} -lt ${MAX_BATCHES_PER_CYCLE} ]]; then
        log_message "INFO" "Waiting ${BATCH_INTERVAL}s before next batch"
        sleep "${BATCH_INTERVAL}"
      fi
    done
  fi

  # Second pass: Process remaining tasks in priority-ordered batches
  if [[ ${batches_processed} -lt ${MAX_BATCHES_PER_CYCLE} ]]; then
    local remaining_batches=$((MAX_BATCHES_PER_CYCLE - batches_processed))
    log_message "INFO" "Processing up to ${remaining_batches} more batches for regular priority tasks"

    # Group remaining tasks by agent and priority
    local regular_tasks
    regular_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.assigned_agent)|\(.priority)|\(.created)"' "${TASK_QUEUE_FILE}" | sort -t'|' -k3 -nr -k4 -n)

    if [[ -n "${regular_tasks}" ]]; then
      local agent_regular_batches
      declare -A agent_regular_batches

      while IFS='|' read -r task_id agent priority created; do
        # Skip if already assigned in first pass
        local already_assigned
        already_assigned=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}")
        if [[ "${already_assigned}" == "assigned" ]]; then
          continue
        fi

        # Add to agent's batch
        if [[ -z "${agent_regular_batches[${agent}]}" ]]; then
          agent_regular_batches[${agent}]="${task_id}"
        else
          agent_regular_batches[${agent}]="${agent_regular_batches[${agent}]} ${task_id}"
        fi
      done < <(echo "${regular_tasks}")

      # Process regular agent batches in priority order
      for agent in "${!agent_regular_batches[@]}"; do
        if [[ ${batches_processed} -ge ${MAX_BATCHES_PER_CYCLE} ]]; then
          break
        fi

        local batch_tasks
        batch_tasks="${agent_regular_batches[${agent}]}"
        local batch_size
        batch_size=$(echo "${batch_tasks}" | wc -w)

        if [[ ${batch_size} -gt ${BATCH_SIZE} ]]; then
          # Limit batch size
          batch_tasks=$(echo "${batch_tasks}" | head -n "${BATCH_SIZE}")
          batch_size=${BATCH_SIZE}
        fi

        log_message "INFO" "Processing regular batch of ${batch_size} tasks for ${agent}"

        # Process batch for this agent
        local batch_assigned
        batch_assigned=$(process_agent_batch "${agent}" "${batch_tasks}")

        tasks_assigned=$((tasks_assigned + batch_assigned))
        batches_processed=$((batches_processed + 1))

        # Add interval between batches if configured
        if [[ ${BATCH_INTERVAL} -gt 0 && ${batches_processed} -lt ${MAX_BATCHES_PER_CYCLE} ]]; then
          log_message "INFO" "Waiting ${BATCH_INTERVAL}s before next batch"
          sleep "${BATCH_INTERVAL}"
        fi
      done
    fi
  fi

  if [[ ${tasks_assigned} -gt 0 ]]; then
    log_message "INFO" "Assigned ${tasks_assigned} tasks in ${batches_processed} batches this cycle"
  else
    log_message "INFO" "No tasks assigned this cycle"
  fi
}

# Process a batch of tasks for a specific agent
process_agent_batch() {
  local agent="$1"
  local task_ids="$2"
  local tasks_assigned=0

  # Check if agent exists and is executable
  if [[ ! -f "$(dirname "$0")/${agent}" || ! -x "$(dirname "$0")/${agent}" ]]; then
    log_message "WARNING" "Agent ${agent} not available for batch processing"
    return 0
  fi

  # Check if agent is available
  local agent_status
  agent_status=$(get_agent_status "${agent}")
  if [[ "${agent_status}" != "available" ]]; then
    log_message "WARNING" "Agent ${agent} not available (status: ${agent_status}) for batch processing"
    return 0
  fi

  # Process each task in the batch
  for task_id in ${task_ids}; do
    # Double-check task is still queued (might have been processed by another batch)
    local current_status
    current_status=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

    if [[ "${current_status}" == "queued" ]]; then
      log_message "INFO" "BATCH: Assigning task ${task_id} to ${agent}"

      # Update task status to assigned
      update_task_status "${task_id}" "assigned"

      # Notify agent
      notify_agent "${agent}" "assigned_task" "${task_id}"

      tasks_assigned=$((tasks_assigned + 1))
    fi
  done

  # Mark agent as busy if we assigned any tasks
  if [[ ${tasks_assigned} -gt 0 ]]; then
    update_agent_status "${agent}" "busy"
  fi

  echo "${tasks_assigned}"
}

# Smart task distribution using intelligent agent selection
distribute_tasks_smart() {
  log_message "INFO" "Using smart task distribution with intelligent agent selection"

  local tasks_assigned=0
  local max_tasks_per_cycle=5
  local high_priority_threshold=8
  local critical_types=("debug" "security" "emergency")

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, cannot distribute tasks"
    return 1
  fi

  # Get all queued tasks sorted by calculated priority
  local queued_tasks
  queued_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.description)|\(.priority)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r task_id task_type description priority; do
    local calc_priority
    calc_priority=$(calculate_task_priority "${task_id}")
    echo "${calc_priority}|${task_id}|${task_type}|${description}|${priority}"
  done | sort -t'|' -k1 -nr) # Sort by calculated priority descending

  if [[ -z ${queued_tasks} ]]; then
    log_message "INFO" "No queued tasks to distribute"
    return 0
  fi

  # Process tasks in priority order
  while IFS='|' read -r calc_priority task_id task_type description; do
    if [[ ${tasks_assigned} -ge ${max_tasks_per_cycle} ]]; then
      log_message "INFO" "Reached maximum tasks per cycle (${max_tasks_per_cycle})"
      break
    fi

    # Double-check task is still queued (might have been processed by another cycle)
    local current_status
    current_status=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

    if [[ "${current_status}" != "queued" ]]; then
      continue
    fi

    # Use smart agent selection
    local selected_agent
    selected_agent=$(select_best_agent_smart "${task_type}" "${description}")

    if [[ -n "${selected_agent}" ]]; then
      local agent_status
      agent_status=$(get_agent_status "${selected_agent}")

      if [[ "${agent_status}" == "available" ]]; then
        log_message "INFO" "SMART: Assigning task ${task_id} (${task_type}, calc_pri=${calc_priority}) to ${selected_agent}"

        # Update task with selected agent
        local temp_file="${TASK_QUEUE_FILE}.tmp"
        if jq --arg task_id "${task_id}" --arg selected_agent "${selected_agent}" \
          '(.tasks[] | select(.id == $task_id) | .assigned_agent) = $selected_agent' \
          "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
          mv "${temp_file}" "${TASK_QUEUE_FILE}"
        fi

        # Assign the task
        update_task_status "${task_id}" "assigned"
        notify_agent "${selected_agent}" "assigned_task" "${task_id}"
        update_agent_status "${selected_agent}" "busy"
        tasks_assigned=$((tasks_assigned + 1))

        # Add small delay between assignments to prevent overwhelming agents
        sleep 0.1
      else
        log_message "WARNING" "Selected agent ${selected_agent} is not available (status: ${agent_status})"
      fi
    else
      log_message "WARNING" "No suitable agent found for task ${task_id} (${task_type})"
    fi
  done < <(echo "${queued_tasks}")

  log_message "INFO" "Smart distribution completed: assigned ${tasks_assigned} tasks this cycle"
}

# Task Batching Functions
# Create intelligent task batches based on similarity and efficiency
create_task_batches() {
  log_message "INFO" "Creating intelligent task batches for efficient processing"

  if [[ "${TASK_BATCHING_ENABLED}" != "true" ]]; then
    log_message "INFO" "Task batching disabled, skipping batch creation"
    return 0
  fi

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, cannot create task batches"
    return 1
  fi

  # Get all queued tasks
  local queued_tasks
  queued_tasks=$(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.description)|\(.assigned_agent)|\(.priority)"' "${TASK_QUEUE_FILE}")

  if [[ -z ${queued_tasks} ]]; then
    log_message "INFO" "No queued tasks to batch"
    return 0
  fi

  # Group tasks by agent first
  local agent_groups
  declare -A agent_groups

  while IFS='|' read -r task_id task_type description agent priority; do
    if [[ -z "${agent_groups[${agent}]}" ]]; then
      agent_groups[${agent}]="${task_id}|${task_type}|${description}|${priority}"
    else
      agent_groups[${agent}]="${agent_groups[${agent}]}\n${task_id}|${task_type}|${description}|${priority}"
    fi
  done < <(echo "${queued_tasks}")

  # Process each agent's tasks to create batches
  local total_batches_created=0

  for agent in "${!agent_groups[@]}"; do
    local agent_tasks="${agent_groups[${agent}]}"
    local agent_batch_count
    agent_batch_count=$(create_agent_batches "${agent}" "${agent_tasks}")
    total_batches_created=$((total_batches_created + agent_batch_count))
  done

  log_message "INFO" "Created ${total_batches_created} task batches across all agents"
}

# Create batches for a specific agent's tasks
create_agent_batches() {
  local agent="$1"
  local agent_tasks="$2"
  local batches_created=0

  # Check current active batches for this agent
  local active_batches
  active_batches=$(jq -r '.batches[] | select(.agent == "'"${agent}"'" and .status == "active") | .id' "${TASK_QUEUE_FILE}" 2>/dev/null | wc -l)

  if [[ ${active_batches} -ge ${MAX_ACTIVE_BATCHES} ]]; then
    log_message "INFO" "Agent ${agent} already has ${active_batches} active batches (max: ${MAX_ACTIVE_BATCHES}), skipping batch creation"
    return 0
  fi

  # Parse tasks and group by similarity
  local task_list=()
  while IFS= read -r task_line; do
    task_list+=("${task_line}")
  done <<<"${agent_tasks}"

  if [[ ${#task_list[@]} -lt 2 ]]; then
    # Not enough tasks to batch
    return 0
  fi

  # Create similarity-based batches
  local batches=()
  local processed_tasks=()

  for ((i = 0; i < ${#task_list[@]}; i++)); do
    local current_task="${task_list[i]}"
    local current_id
    IFS='|' read -r current_id _ <<<"${current_task}"

    # Skip if already processed
    if [[ " ${processed_tasks[*]} " == *" ${current_id} "* ]]; then
      continue
    fi

    local current_batch=("${current_task}")
    processed_tasks+=("${current_id}")

    # Find similar tasks
    for ((j = i + 1; j < ${#task_list[@]}; j++)); do
      local other_task="${task_list[j]}"
      local other_id
      IFS='|' read -r other_id _ <<<"${other_task}"

      # Skip if already processed
      if [[ " ${processed_tasks[*]} " == *" ${other_id} "* ]]; then
        continue
      fi

      # Check similarity
      local similarity
      similarity=$(calculate_task_similarity "${current_task}" "${other_task}")

      if (($(echo "${similarity} >= ${BATCH_SIMILARITY_THRESHOLD}" | bc -l 2>/dev/null || echo "0"))); then
        current_batch+=("${other_task}")
        processed_tasks+=("${other_id}")

        # Limit batch size
        if [[ ${#current_batch[@]} -ge ${MAX_BATCH_SIZE} ]]; then
          break
        fi
      fi
    done

    # Create batch if we have multiple tasks or if single task is high priority
    if [[ ${#current_batch[@]} -gt 1 ]]; then
      batches+=("${current_batch[*]}")
    else
      # Check if single task should be batched alone (high priority or urgent)
      local task_priority
      IFS='|' read -r _ _ _ task_priority <<<"${current_task}"
      if [[ ${task_priority} -ge 8 ]]; then
        batches+=("${current_batch[*]}")
      fi
    fi
  done

  # Create batch objects in the queue
  for batch_tasks in "${batches[@]}"; do
    create_task_batch "${agent}" "${batch_tasks}"
    batches_created=$((batches_created + 1))
  done

  echo "${batches_created}"
}

# Smart Assignment Functions
# Enhanced agent selection with load balancing and performance tracking
select_best_agent_smart() {
  local task_type="$1"
  local task_description="$2"

  if [[ "${SMART_ASSIGNMENT_ENABLED}" != "true" ]]; then
    # Fall back to basic agent selection
    select_best_agent "${task_type}"
    return $?
  fi

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, falling back to basic agent selection"
    select_best_agent "${task_type}"
    return $?
  fi

  log_message "INFO" "Performing smart agent selection for task type: ${task_type}"

  local best_agent=""
  local best_score=0
  local agent_scores=()

  for agent in "${ALL_AGENTS[@]}"; do
    if [[ ! -f "$(dirname "$0")/${agent}" ]]; then
      continue
    fi

    local agent_score
    agent_score=$(calculate_agent_score "${agent}" "${task_type}" "${task_description}")

    if (($(echo "${agent_score} > ${best_score}" | bc -l 2>/dev/null || echo "0"))); then
      best_score=${agent_score}
      best_agent="${agent}"
    fi

    agent_scores+=("${agent}:${agent_score}")
  done

  if [[ -n "${best_agent}" ]]; then
    log_message "INFO" "Selected agent ${best_agent} with score ${best_score} for ${task_type} task"
    echo "${best_agent}"
  else
    log_message "WARNING" "No suitable agent found for task type: ${task_type}"
    echo ""
  fi
}

# Calculate comprehensive agent score based on multiple factors
calculate_agent_score() {
  local agent="$1"
  local task_type="$2"
  local task_description="$3"

  local total_score=0

  # Factor 1: Capability Match (40% weight)
  local capability_score
  capability_score=$(calculate_capability_score "${agent}" "${task_type}" "${task_description}")
  local weighted_capability
  weighted_capability=$(echo "scale=3; ${capability_score} * ${CAPABILITY_MATCH_WEIGHT}" | bc -l 2>/dev/null || echo "0")

  # Factor 2: Load Balance (30% weight)
  local load_score
  load_score=$(calculate_load_balance_score "${agent}")
  local weighted_load
  weighted_load=$(echo "scale=3; ${load_score} * ${LOAD_BALANCE_WEIGHT}" | bc -l 2>/dev/null || echo "0")

  # Factor 3: Historical Performance (30% weight)
  local performance_score
  performance_score=$(calculate_performance_score "${agent}" "${task_type}")
  local weighted_performance
  weighted_performance=$(echo "scale=3; ${performance_score} * ${PERFORMANCE_WEIGHT}" | bc -l 2>/dev/null || echo "0")

  # Calculate total score
  total_score=$(echo "scale=3; ${weighted_capability} + ${weighted_load} + ${weighted_performance}" | bc -l 2>/dev/null || echo "0")

  log_message "DEBUG" "Agent ${agent} scores - Capability: ${weighted_capability}, Load: ${weighted_load}, Performance: ${weighted_performance}, Total: ${total_score}"

  echo "${total_score}"
}

# Calculate capability match score (0-100)
calculate_capability_score() {
  local agent="$1"
  local task_type="$2"
  local task_description="$3"

  local capabilities
  capabilities=$(get_agent_capabilities "${agent}")
  local priority
  priority=$(get_agent_priority "${agent}")

  local score=0

  # Exact capability match
  if [[ ${capabilities} == *"${task_type}"* ]]; then
    score=100
  else
    # Check for related capabilities
    case "${task_type}" in
    "debug" | "fix")
      if [[ ${capabilities} == *"debug"* || ${capabilities} == *"fix"* ]]; then
        score=80
      fi
      ;;
    "build" | "test")
      if [[ ${capabilities} == *"build"* || ${capabilities} == *"test"* ]]; then
        score=80
      fi
      ;;
    "generate" | "create")
      if [[ ${capabilities} == *"generate"* || ${capabilities} == *"create"* ]]; then
        score=80
      fi
      ;;
    "ui" | "ux")
      if [[ ${capabilities} == *"ui"* || ${capabilities} == *"ux"* ]]; then
        score=80
      fi
      ;;
    esac
  fi

  # Priority bonus (higher priority agents get slight boost)
  local priority_bonus
  priority_bonus=$((priority * 2))
  score=$((score + priority_bonus))

  # Agent availability bonus
  local agent_status
  agent_status=$(get_agent_status "${agent}")
  if [[ "${agent_status}" == "available" ]]; then
    score=$((score + 10))
  fi

  # Ensure score stays within bounds
  if [[ ${score} -gt 100 ]]; then
    score=100
  fi

  echo "${score}"
}

# Calculate load balance score (0-100, higher is better)
calculate_load_balance_score() {
  local agent="$1"

  if [[ "${LOAD_BALANCING_ENABLED}" != "true" ]]; then
    echo "50" # Neutral score
    return
  fi

  # Get current agent load
  local current_tasks
  current_tasks=$(get_agent_current_load "${agent}")
  local agent_status
  agent_status=$(get_agent_status "${agent}")

  # Calculate load percentage
  local load_percentage=0
  if [[ ${MAX_AGENT_LOAD} -gt 0 ]]; then
    load_percentage=$((current_tasks * 100 / MAX_AGENT_LOAD))
  fi

  # Score based on load (lower load = higher score)
  local load_score=100
  if [[ ${load_percentage} -gt 80 ]]; then
    load_score=20 # Heavily loaded
  elif [[ ${load_percentage} -gt 60 ]]; then
    load_score=40 # Moderately loaded
  elif [[ ${load_percentage} -gt 40 ]]; then
    load_score=60 # Lightly loaded
  else
    load_score=100 # Not loaded
  fi

  # Bonus for available agents
  if [[ "${agent_status}" == "available" ]]; then
    load_score=$((load_score + 10))
  fi

  # Penalty for busy agents
  if [[ "${agent_status}" == "busy" ]]; then
    load_score=$((load_score - 20))
  fi

  # Ensure score stays within bounds
  if [[ ${load_score} -gt 100 ]]; then
    load_score=100
  elif [[ ${load_score} -lt 0 ]]; then
    load_score=0
  fi

  echo "${load_score}"
}

# Calculate historical performance score (0-100)
calculate_performance_score() {
  local agent="$1"
  local task_type="$2"

  if [[ "${PERFORMANCE_TRACKING_ENABLED}" != "true" ]]; then
    echo "50" # Neutral score
    return
  fi

  # Get performance metrics for this agent and task type
  local success_rate
  success_rate=$(get_agent_success_rate "${agent}" "${task_type}")
  local avg_completion_time
  avg_completion_time=$(get_agent_avg_completion_time "${agent}" "${task_type}")

  local performance_score=50 # Base score

  # Success rate contribution (0-40 points)
  local success_contribution
  success_contribution=$(echo "scale=0; ${success_rate} * 40 / 100" | bc -l 2>/dev/null || echo "20")
  performance_score=$((performance_score + success_contribution - 20)) # Center around neutral

  # Completion time contribution (0-10 points, faster is better)
  if [[ ${avg_completion_time} -gt 0 ]]; then
    local time_score=10
    if [[ ${avg_completion_time} -gt 3600 ]]; then # > 1 hour
      time_score=2
    elif [[ ${avg_completion_time} -gt 1800 ]]; then # > 30 minutes
      time_score=4
    elif [[ ${avg_completion_time} -gt 900 ]]; then # > 15 minutes
      time_score=6
    elif [[ ${avg_completion_time} -gt 300 ]]; then # > 5 minutes
      time_score=8
    fi
    performance_score=$((performance_score + time_score - 5)) # Center around neutral
  fi

  # Ensure score stays within bounds
  if [[ ${performance_score} -gt 100 ]]; then
    performance_score=100
  elif [[ ${performance_score} -lt 0 ]]; then
    performance_score=0
  fi

  echo "${performance_score}"
}

# Get agent's current load (number of active tasks)
get_agent_current_load() {
  local agent="$1"

  # Count tasks assigned to this agent that are in progress
  local active_tasks
  active_tasks=$(jq -r '.tasks[] | select(.assigned_agent == "'"${agent}"'" and (.status == "assigned" or .status == "in_progress")) | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  # Also count active batches for this agent
  local active_batches
  active_batches=$(jq -r '.batches[] | select(.agent == "'"${agent}"'" and .status == "assigned") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  local total_load=$((active_tasks + active_batches))

  echo "${total_load}"
}

# Get agent's success rate for a specific task type (0-100)
get_agent_success_rate() {
  local agent="$1"
  local task_type="$2"

  if ! command -v jq &>/dev/null || [[ ! -f ${AGENT_STATUS_FILE} ]]; then
    echo "50" # Neutral success rate
    return
  fi

  local current_time
  current_time=$(date +%s)
  local window_start=$((current_time - AGENT_PERFORMANCE_WINDOW))

  # Get completed tasks for this agent and task type within the performance window
  local completed_tasks
  completed_tasks=$(jq -r '.completed[] | select(.agent == "'"${agent}"'" and .type == "'"${task_type}"'" and .completed_at > '"${window_start}"')' "${TASK_QUEUE_FILE}" 2>/dev/null | wc -l)

  local failed_tasks
  failed_tasks=$(jq -r '.failed[] | select(.agent == "'"${agent}"'" and .type == "'"${task_type}"'" and .failed_at > '"${window_start}"')' "${TASK_QUEUE_FILE}" 2>/dev/null | wc -l)

  local total_tasks=$((completed_tasks + failed_tasks))

  if [[ ${total_tasks} -eq 0 ]]; then
    echo "50" # No historical data, neutral score
    return
  fi

  local success_rate=$((completed_tasks * 100 / total_tasks))
  echo "${success_rate}"
}

# Get agent's average completion time for a specific task type
get_agent_avg_completion_time() {
  local agent="$1"
  local task_type="$2"

  if ! command -v jq &>/dev/null; then
    echo "0"
    return
  fi

  local current_time
  current_time=$(date +%s)
  local window_start=$((current_time - AGENT_PERFORMANCE_WINDOW))

  # Calculate average completion time from recent tasks
  local completion_times
  completion_times=$(jq -r '.completed[] | select(.agent == "'"${agent}"'" and .type == "'"${task_type}"'" and .completed_at > '"${window_start}"') | (.completed_at - .started_at)' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${completion_times} ]]; then
    echo "0"
    return
  fi

  # Calculate average (simple implementation)
  local total_time=0
  local count=0

  while read -r time_diff; do
    if [[ ${time_diff} -gt 0 ]]; then
      total_time=$((total_time + time_diff))
      count=$((count + 1))
    fi
  done <<<"${completion_times}"

  if [[ ${count} -eq 0 ]]; then
    echo "0"
    return
  fi

  local avg_time=$((total_time / count))
  echo "${avg_time}"
}

# Update agent performance metrics when tasks complete
update_agent_performance() {
  local agent="$1"
  local task_type="$2"
  local success="$3"
  local completion_time="$4"

  if [[ "${PERFORMANCE_TRACKING_ENABLED}" != "true" ]]; then
    return
  fi

  if ! command -v jq &>/dev/null; then
    return
  fi

  local current_time
  current_time=$(date +%s)

  # Update agent status file with performance data
  local temp_file="${AGENT_STATUS_FILE}.tmp"

  # Initialize agent performance data if it doesn't exist
  jq --arg agent "${agent}" \
    '.agents[$agent].performance = (.agents[$agent].performance // {}) |
		 .agents[$agent].performance[$task_type] = (.agents[$agent].performance[$task_type] // {"completed": 0, "failed": 0, "total_completion_time": 0, "last_updated": 0})' \
    "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null

  if [[ -f ${temp_file} ]]; then
    mv "${temp_file}" "${AGENT_STATUS_FILE}"

    # Update performance metrics
    if [[ "${success}" == "true" ]]; then
      jq --arg agent "${agent}" --arg task_type "${task_type}" --arg completion_time "${completion_time}" --arg current_time "${current_time}" \
        '.agents[$agent].performance[$task_type].completed += 1 |
				 .agents[$agent].performance[$task_type].total_completion_time += ($completion_time | tonumber) |
				 .agents[$agent].performance[$task_type].last_updated = ($current_time | tonumber)' \
        "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null
    else
      jq --arg agent "${agent}" --arg task_type "${task_type}" --arg current_time "${current_time}" \
        '.agents[$agent].performance[$task_type].failed += 1 |
				 .agents[$agent].performance[$task_type].last_updated = ($current_time | tonumber)' \
        "${AGENT_STATUS_FILE}" >"${temp_file}" 2>/dev/null
    fi

    if [[ -f ${temp_file} ]]; then
      mv "${temp_file}" "${AGENT_STATUS_FILE}"
    fi
  fi
}

# Get agent load distribution for reporting
get_agent_load_distribution() {
  local output=""
  for agent in "${ALL_AGENTS[@]}"; do
    local load
    load=$(get_agent_current_load "${agent}")
    local status
    status=$(get_agent_status "${agent}")
    output="${output}${agent}:${load}:${status}\n"
  done
  echo -e "${output}"
}

# Calculate similarity between two tasks
calculate_task_similarity() {
  local task1="$1"
  local task2="$2"

  # Parse task components
  local type1 desc1 pri1
  local type2 desc2 pri2

  IFS='|' read -r _ type1 desc1 pri1 <<<"${task1}"
  IFS='|' read -r _ type2 desc2 pri2 <<<"${task2}"

  # Type similarity (exact match = 1.0, related = 0.5)
  local type_similarity=0
  if [[ "${type1}" == "${type2}" ]]; then
    type_similarity=1.0
  else
    # Check for related types
    case "${type1}" in
    "debug" | "fix")
      if [[ "${type2}" == "debug" || "${type2}" == "fix" ]]; then
        type_similarity=0.8
      fi
      ;;
    "build" | "test")
      if [[ "${type2}" == "build" || "${type2}" == "test" ]]; then
        type_similarity=0.8
      fi
      ;;
    "generate" | "create")
      if [[ "${type2}" == "generate" || "${type2}" == "create" ]]; then
        type_similarity=0.8
      fi
      ;;
    esac
  fi

  # Description similarity (word overlap)
  local desc_similarity=0
  if [[ -n "${desc1}" && -n "${desc2}" ]]; then
    local words1 words2 common_words
    words1=$(echo "${desc1}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq | wc -l)
    words2=$(echo "${desc2}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq | wc -l)
    common_words=$(comm -12 <(echo "${desc1}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq) <(echo "${desc2}" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | sort | uniq) | wc -l)

    if [[ ${words1} -gt 0 && ${words2} -gt 0 ]]; then
      local union=$((words1 + words2 - common_words))
      if [[ ${union} -gt 0 ]]; then
        desc_similarity=$((common_words * 100 / union))
        desc_similarity=$(echo "scale=2; ${desc_similarity}/100" | bc -l 2>/dev/null || echo "0")
      fi
    fi
  fi

  # Priority similarity (closer priorities = higher similarity)
  local pri_similarity=0
  local pri_diff=$((pri1 - pri2))
  if [[ ${pri_diff} -lt 0 ]]; then
    pri_diff=$((pri_diff * -1))
  fi

  if [[ ${pri_diff} -eq 0 ]]; then
    pri_similarity=1.0
  elif [[ ${pri_diff} -le 2 ]]; then
    pri_similarity=0.7
  elif [[ ${pri_diff} -le 4 ]]; then
    pri_similarity=0.4
  fi

  # Weighted average: 40% type, 40% description, 20% priority
  local weighted_similarity
  weighted_similarity=$(echo "scale=3; (${type_similarity} * 0.4) + (${desc_similarity} * 0.4) + (${pri_similarity} * 0.2)" | bc -l 2>/dev/null || echo "0")

  echo "${weighted_similarity}"
}

# Create a task batch in the queue
create_task_batch() {
  local agent="$1"
  local batch_tasks="$2"

  # Generate batch ID
  local timestamp
  timestamp=$(date +%s%N)
  local batch_id="batch_${timestamp:0:13}"

  # Parse task IDs from batch
  local task_ids=()
  local batch_priority=0
  local batch_types=()

  while IFS='|' read -r task_id task_type _ priority; do
    task_ids+=("${task_id}")
    batch_types+=("${task_type}")
    if [[ ${priority} -gt ${batch_priority} ]]; then
      batch_priority=${priority}
    fi
  done <<<"${batch_tasks}"

  # Create batch description
  local unique_types
  unique_types=$(printf '%s\n' "${batch_types[@]}" | sort | uniq | tr '\n' ', ' | sed 's/, $//')
  local batch_description="Batch: ${#task_ids[@]} ${unique_types} tasks"

  # Create batch object
  local created
  created=$(date +%s)
  local batch_json
  printf -v batch_json '{"id": "%s", "agent": "%s", "tasks": %s, "description": "%s", "priority": %s, "status": "active", "created": %s, "task_count": %s}' \
    "${batch_id}" "${agent}" "$(printf '%s\n' "${task_ids[@]}" | jq -R . | jq -s .)" "${batch_description}" "${batch_priority}" "${created}" "${#task_ids[@]}"

  # Add batch to queue
  if command -v jq &>/dev/null; then
    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq --argjson batch "${batch_json}" '.batches += [$batch]' "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Created batch ${batch_id} with ${#task_ids[@]} tasks for ${agent}"

      # Update individual tasks to reference the batch
      for task_id in "${task_ids[@]}"; do
        local task_temp_file="${TASK_QUEUE_FILE}.tmp2"
        if jq --arg task_id "${task_id}" --arg batch_id "${batch_id}" \
          '(.tasks[] | select(.id == $task_id) | .batch_id) = $batch_id' \
          "${TASK_QUEUE_FILE}" >"${task_temp_file}" 2>/dev/null; then
          mv "${task_temp_file}" "${TASK_QUEUE_FILE}"
        fi
      done
    else
      log_message "ERROR" "Failed to create batch ${batch_id}"
      rm -f "${temp_file}"
    fi
  fi
}

# Process active task batches
process_task_batches() {
  log_message "INFO" "Processing active task batches"

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, cannot process task batches"
    return 1
  fi

  # Get active batches
  local active_batches
  active_batches=$(jq -r '.batches[] | select(.status == "active") | "\(.id)|\(.agent)|\(.task_count)"' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${active_batches} ]]; then
    log_message "INFO" "No active batches to process"
    return 0
  fi

  local batches_processed=0

  while IFS='|' read -r batch_id agent task_count; do
    # Check if agent is available
    local agent_status
    agent_status=$(get_agent_status "${agent}")

    if [[ "${agent_status}" == "available" ]]; then
      log_message "INFO" "Processing batch ${batch_id} with ${task_count} tasks for ${agent}"

      # Assign batch to agent
      assign_batch_to_agent "${batch_id}" "${agent}"
      batches_processed=$((batches_processed + 1))

      # Update agent status
      update_agent_status "${agent}" "busy"
    fi
  done < <(echo "${active_batches}")

  log_message "INFO" "Processed ${batches_processed} task batches this cycle"
}

# Assign a batch to an agent
assign_batch_to_agent() {
  local batch_id="$1"
  local agent="$2"

  # Update batch status
  local temp_file="${TASK_QUEUE_FILE}.tmp"
  if jq --arg batch_id "${batch_id}" \
    '(.batches[] | select(.id == $batch_id) | .status) = "assigned" |
		 (.batches[] | select(.id == $batch_id) | .assigned_at) = (now | strftime("%s"))' \
    "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${TASK_QUEUE_FILE}"

    # Notify agent about the batch
    notify_agent "${agent}" "assigned_batch" "${batch_id}"
    log_message "INFO" "Assigned batch ${batch_id} to ${agent}"
  else
    log_message "ERROR" "Failed to assign batch ${batch_id} to ${agent}"
    rm -f "${temp_file}"
  fi
}

# Complete a task batch
complete_task_batch() {
  local batch_id="$1"
  local agent="$2"
  local success="${3:-true}"

  log_message "INFO" "Batch ${batch_id} completed by ${agent} (success: ${success})"

  # Update batch status
  local temp_file="${TASK_QUEUE_FILE}.tmp"
  if jq --arg batch_id "${batch_id}" --arg success "${success}" \
    '(.batches[] | select(.id == $batch_id) | .status) = "completed" |
		 (.batches[] | select(.id == $batch_id) | .completed_at) = (now | strftime("%s")) |
		 (.batches[] | select(.id == $batch_id) | .success) = ($success == "true")' \
    "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
    mv "${temp_file}" "${TASK_QUEUE_FILE}"

    # Free up the agent
    update_agent_status "${agent}" "available"
    log_message "INFO" "Batch ${batch_id} marked as completed"
  else
    log_message "ERROR" "Failed to complete batch ${batch_id}"
    rm -f "${temp_file}"
  fi
}

# Clean up old completed batches
cleanup_old_batches() {
  local current_time
  current_time=$(date +%s)
  local cutoff_time=$((current_time - TASK_RETENTION_DAYS * 24 * 60 * 60))

  if ! command -v jq &>/dev/null; then
    return 0
  fi

  local completed_batches
  completed_batches=$(jq '.batches[] | select(.status == "completed" and (.completed_at // 0) < '"${cutoff_time}"') | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

  if [[ ${completed_batches} -gt 0 ]]; then
    log_message "INFO" "Removing ${completed_batches} old completed batches"

    local temp_file="${TASK_QUEUE_FILE}.tmp"
    if jq '.batches = (.batches | map(select(.status != "completed" or (.completed_at // 0) >= '"${cutoff_time}"')))' \
      "${TASK_QUEUE_FILE}" >"${temp_file}" 2>/dev/null; then
      mv "${temp_file}" "${TASK_QUEUE_FILE}"
      log_message "INFO" "Cleaned up old completed batches"
    else
      rm -f "${temp_file}"
    fi
  fi
}

# Fallback single-task distribution (original logic)
distribute_tasks_single() {
  log_message "INFO" "Using single-task distribution (batch processing disabled)"

  local tasks_assigned=0
  local max_tasks_per_cycle=5
  local high_priority_threshold=8
  local critical_types=("debug" "security" "emergency")

  if ! command -v jq &>/dev/null; then
    log_message "WARNING" "jq not available, cannot distribute tasks"
    return 1
  fi

  # First pass: Process critical/high-priority tasks
  while IFS='|' read -r task_id task_type priority agent; do
    local is_critical=false
    for critical_type in "${critical_types[@]}"; do
      if [[ "${task_type}" == "${critical_type}" ]]; then
        is_critical=true
        break
      fi
    done

    if [[ ${is_critical} == true || ${priority} -ge ${high_priority_threshold} ]]; then
      if [[ -f "$(dirname "$0")/${agent}" && -x "$(dirname "$0")/${agent}" ]]; then
        local agent_status
        agent_status=$(get_agent_status "${agent}")
        if [[ ${agent_status} == "available" && ${tasks_assigned} -lt ${max_tasks_per_cycle} ]]; then
          # Check resource limits before assigning task
          local task_type_for_check
          task_type_for_check=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "general")
          if can_start_task "${task_type_for_check}"; then
            log_message "INFO" "PRIORITY: Assigning critical/high-priority task ${task_id} (${task_type}, pri=${priority}) to ${agent}"
            update_task_status "${task_id}" "assigned"
            notify_agent "${agent}" "assigned_task" "${task_id}"
            update_agent_status "${agent}" "busy"
            tasks_assigned=$((tasks_assigned + 1))
          else
            log_message "WARNING" "Cannot assign task ${task_id} - resource limits exceeded"
          fi
        fi
      fi
    fi
  done < <(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.priority)|\(.assigned_agent)"' "${TASK_QUEUE_FILE}")

  # Second pass: Process remaining tasks
  if [[ ${tasks_assigned} -lt ${max_tasks_per_cycle} ]]; then
    local remaining_slots=$((max_tasks_per_cycle - tasks_assigned))
    while IFS='|' read -r task_id agent priority created; do
      local already_assigned
      already_assigned=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .status' "${TASK_QUEUE_FILE}")
      if [[ "${already_assigned}" == "assigned" ]]; then
        continue
      fi

      if [[ -f "$(dirname "$0")/${agent}" && -x "$(dirname "$0")/${agent}" ]]; then
        local agent_status
        agent_status=$(get_agent_status "${agent}")
        if [[ ${agent_status} == "available" ]]; then
          # Check resource limits before assigning task
          local task_type_for_check
          task_type_for_check=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "general")
          if can_start_task "${task_type_for_check}"; then
            log_message "INFO" "Assigning regular task ${task_id} (pri=${priority}) to ${agent}"
            update_task_status "${task_id}" "assigned"
            notify_agent "${agent}" "assigned_task" "${task_id}"
            update_agent_status "${agent}" "busy"
            tasks_assigned=$((tasks_assigned + 1))
          else
            log_message "WARNING" "Cannot assign task ${task_id} - resource limits exceeded"
          fi
        fi
      fi
    done < <(jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.assigned_agent)|\(.priority)|\(.created)"' "${TASK_QUEUE_FILE}" | sort -t'|' -k3 -nr -k4 -n | head -n "${remaining_slots}")
  fi

  log_message "INFO" "Assigned ${tasks_assigned} tasks this cycle (single mode)"
}

# Mark task as in progress when agent starts working on it
start_task() {
  local task_id="$1"
  local agent="$2"

  log_message "INFO" "Agent ${agent} starting work on task ${task_id}"
  update_task_status "${task_id}" "in_progress"

  # Update agent status
  update_agent_status "${agent}" "busy"
}

# Complete a task successfully
complete_task() {
  local task_id="$1"
  local agent="$2"
  local success="${3:-true}"

  log_message "INFO" "Task ${task_id} completed by ${agent} (success: ${success})"
  update_task_status "${task_id}" "completed" "${success}"

  # Free up the agent
  update_agent_status "${agent}" "available"

  # Process any dependent tasks
  process_dependent_tasks "${task_id}"
}

# Fail a task
fail_task() {
  local task_id="$1"
  local agent="$2"
  local error_message="$3"

  log_message "ERROR" "Task ${task_id} failed by ${agent}: ${error_message}"
  update_task_status "${task_id}" "failed" "${error_message}"

  # Free up the agent
  update_agent_status "${agent}" "available"

  # Could implement retry logic here
}

# Process dependent tasks when a parent task completes
process_dependent_tasks() {
  local parent_task_id="$1"

  if command -v jq &>/dev/null; then
    # Find tasks that depend on this completed task
    jq -r '.tasks[] | select(.dependencies[]? == "'"${parent_task_id}"'") | .id' "${TASK_QUEUE_FILE}" | while read -r dependent_task_id; do
      log_message "INFO" "Unblocking dependent task ${dependent_task_id} after ${parent_task_id} completion"

      # Check if all dependencies are now satisfied
      local all_deps_satisfied=true
      while read -r dep_id; do
        local dep_status
        dep_status=$(jq -r '.tasks[] | select(.id == "'"${dep_id}"'") | .status' "${TASK_QUEUE_FILE}")
        if [[ "${dep_status}" != "completed" ]]; then
          all_deps_satisfied=false
          break
        fi
      done < <(jq -r '.tasks[] | select(.id == "'"${dependent_task_id}"'") | .dependencies[]?' "${TASK_QUEUE_FILE}")

      if [[ "${all_deps_satisfied}" == "true" ]]; then
        log_message "INFO" "All dependencies satisfied for task ${dependent_task_id}"
        # Task can now be processed (status remains queued, will be picked up by distribute_tasks)
      fi
    done
  fi
}

# Enhanced dependency processing with failure propagation
process_dependent_tasks_enhanced() {
  local parent_task_id="$1"
  local parent_status="$2" # "completed" or "failed"

  if ! command -v jq &>/dev/null; then
    return 0
  fi

  log_message "INFO" "Processing dependencies for ${parent_task_id} (status: ${parent_status})"

  # Find all tasks that depend on this completed/failed task
  local dependent_tasks
  dependent_tasks=$(jq -r '.tasks[] | select(.dependencies[]? == "'"${parent_task_id}"'") | .id' "${TASK_QUEUE_FILE}" 2>/dev/null)

  if [[ -z ${dependent_tasks} ]]; then
    return 0
  fi

  while read -r dependent_task_id; do
    if [[ -z ${dependent_task_id} ]]; then
      continue
    fi

    log_message "INFO" "Evaluating dependent task ${dependent_task_id} after ${parent_task_id} ${parent_status}"

    # Check if all dependencies are now satisfied (or failed)
    local all_deps_resolved=true
    local has_failed_dependency=false
    local pending_deps=()

    # Get all dependencies for this task
    local task_dependencies
    task_dependencies=$(jq -r '.tasks[] | select(.id == "'"${dependent_task_id}"'") | .dependencies[]?' "${TASK_QUEUE_FILE}" 2>/dev/null)

    if [[ -n ${task_dependencies} ]]; then
      while read -r dep_id; do
        if [[ -z ${dep_id} ]]; then
          continue
        fi

        local dep_status
        dep_status=$(jq -r '.tasks[] | select(.id == "'"${dep_id}"'") | .status' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")

        case ${dep_status} in
        "completed")
          # Dependency satisfied, continue
          ;;
        "failed")
          # Dependency failed - mark this task as cancelled due to dependency failure
          has_failed_dependency=true
          log_message "WARNING" "Dependency ${dep_id} failed, cancelling dependent task ${dependent_task_id}"
          ;;
        "queued" | "assigned" | "in_progress" | "blocked")
          # Dependency still pending
          all_deps_resolved=false
          pending_deps+=("${dep_id}")
          ;;
        *)
          # Unknown status, assume still pending
          all_deps_resolved=false
          pending_deps+=("${dep_id}")
          ;;
        esac
      done < <(echo "${task_dependencies}")
    fi

    # Handle dependency resolution outcomes
    if [[ ${has_failed_dependency} == true ]]; then
      # Cancel this task due to failed dependency
      fail_task "${dependent_task_id}" "orchestrator" "Cancelled due to failed dependency: ${parent_task_id}"

    elif [[ ${all_deps_resolved} == true ]]; then
      # All dependencies satisfied - unblock this task
      log_message "INFO" "All dependencies satisfied for task ${dependent_task_id} - unblocking"

      # Update task status from blocked to queued
      update_task_status "${dependent_task_id}" "queued"

      # Get task details for notification
      local task_agent
      task_agent=$(jq -r '.tasks[] | select(.id == "'"${dependent_task_id}"'") | .assigned_agent' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "")

      if [[ -n ${task_agent} ]]; then
        notify_agent "${task_agent}" "dependency_satisfied" "${dependent_task_id}"
      fi

    else
      # Still waiting for some dependencies
      if [[ ${#pending_deps[@]} -gt 0 ]]; then
        log_message "INFO" "Task ${dependent_task_id} still waiting for ${#pending_deps[@]} dependencies: ${pending_deps[*]}"
      fi
    fi
  done < <(echo "${dependent_tasks}")
}

# Enhanced task completion with dependency processing
complete_task_enhanced() {
  local task_id="$1"
  local agent="$2"
  local success="${3:-true}"

  log_message "INFO" "Task ${task_id} completed by ${agent} (success: ${success})"

  if [[ "${success}" == "true" ]]; then
    update_task_status "${task_id}" "completed" "${success}"
  else
    update_task_status "${task_id}" "failed" "${success}"
  fi

  # Update agent performance metrics
  local task_type
  task_type=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")
  local completion_time=0

  if command -v jq &>/dev/null; then
    local started_at
    started_at=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .started_at // 0' "${TASK_QUEUE_FILE}")
    local completed_at
    completed_at=$(date +%s)
    if [[ ${started_at} -gt 0 ]]; then
      completion_time=$((completed_at - started_at))
    fi
  fi

  update_agent_performance "${agent}" "${task_type}" "${success}" "${completion_time}"

  # Free up the agent
  update_agent_status "${agent}" "available"

  # Process dependent tasks with the completion status
  process_dependent_tasks_enhanced "${task_id}" "completed"
}

# Enhanced task failure with dependency processing
fail_task_enhanced() {
  local task_id="$1"
  local agent="$2"
  local error_message="$3"

  log_message "ERROR" "Task ${task_id} failed by ${agent}: ${error_message}"

  # Try retry logic first
  if [[ "${RETRY_LOGIC_ENABLED}" == "true" ]]; then
    if schedule_task_retry "${task_id}" "${error_message}" "${agent}"; then
      # Retry scheduled, don't mark as permanently failed yet
      log_message "INFO" "Retry scheduled for failed task ${task_id}"
      return 0
    fi
  fi

  # No retry possible, mark as permanently failed
  update_task_status "${task_id}" "failed" "${error_message}"

  # Update agent performance metrics
  local task_type
  task_type=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .type' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "unknown")
  local completion_time=0

  if command -v jq &>/dev/null; then
    local started_at
    started_at=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .started_at // 0' "${TASK_QUEUE_FILE}")
    local failed_at
    failed_at=$(date +%s)
    if [[ ${started_at} -gt 0 ]]; then
      completion_time=$((failed_at - started_at))
    fi
  fi

  update_agent_performance "${agent}" "${task_type}" "false" "${completion_time}"

  # Free up the agent
  update_agent_status "${agent}" "available"

  # Process dependent tasks with failure status (this will cancel dependent tasks)
  process_dependent_tasks_enhanced "${task_id}" "failed"
}

ensure_agent_running() {
  local agent="$1"
  local pid_file
  pid_file="$(dirname "$0")/${agent}.pid"

  # Check if agent is actually running
  if [[ -f ${pid_file} ]]; then
    local pid
    pid=$(cat "${pid_file}")
    if ! kill -0 "${pid}" 2>/dev/null; then
      # Agent is not running, start it
      log_message "WARNING" "Agent ${agent} not running, starting it"
      restart_agent "${agent}"
    fi
  else
    # No PID file, start the agent
    log_message "INFO" "Starting agent ${agent}"
    restart_agent "${agent}"
  fi
}

# Calculate intelligent priority score for a task based on type, content, and urgency
calculate_task_priority() {
  local task_id="$1"

  if ! command -v jq &>/dev/null || [[ ! -f ${TASK_QUEUE_FILE} ]]; then
    echo "5" # Default priority
    return
  fi

  # Get task details
  local task_data
  task_data=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | "\(.type)|\(.description)|\(.priority)"' "${TASK_QUEUE_FILE}")

  if [[ -z ${task_data} ]]; then
    echo "5"
    return
  fi

  local task_type description base_priority
  IFS='|' read -r task_type description base_priority <<<"${task_data}"

  local calculated_priority=${base_priority}

  # Priority adjustments based on task type
  case ${task_type} in
  "debug" | "security" | "emergency")
    calculated_priority=$((calculated_priority + 3)) # +3 for critical types
    ;;
  "build" | "test")
    calculated_priority=$((calculated_priority + 1)) # +1 for important types
    ;;
  "cleanup" | "organize")
    calculated_priority=$((calculated_priority - 1)) # -1 for low priority types
    ;;
  esac

  # Priority adjustments based on description content (urgency keywords)
  local urgency_keywords=("urgent" "critical" "emergency" "security" "vulnerability" "crash" "error" "fix" "bug")
  local desc_lower
  desc_lower=$(echo "${description}" | tr '[:upper:]' '[:lower:]')

  for keyword in "${urgency_keywords[@]}"; do
    if [[ ${desc_lower} == *"${keyword}"* ]]; then
      calculated_priority=$((calculated_priority + 2))
      break # Only apply once even if multiple keywords match
    fi
  done

  # Priority adjustments based on time factors
  local current_time
  current_time=$(date +%s)
  local task_age_hours=0

  if command -v jq &>/dev/null; then
    local created_time
    created_time=$(jq -r '.tasks[] | select(.id == "'"${task_id}"'") | .created // 0' "${TASK_QUEUE_FILE}")
    if [[ ${created_time} -gt 0 ]]; then
      local task_age_seconds=$((current_time - created_time))
      task_age_hours=$((task_age_seconds / 3600))
    fi
  fi

  # Slight priority boost for older tasks to prevent starvation
  if [[ ${task_age_hours} -gt 24 ]]; then
    calculated_priority=$((calculated_priority + 1))
  elif [[ ${task_age_hours} -gt 72 ]]; then
    calculated_priority=$((calculated_priority + 2))
  fi

  # Ensure priority stays within reasonable bounds (1-10)
  if [[ ${calculated_priority} -lt 1 ]]; then
    calculated_priority=1
  elif [[ ${calculated_priority} -gt 10 ]]; then
    calculated_priority=10
  fi

  echo "${calculated_priority}"
}

# Generate status report
generate_status_report() {
  local report_file
  report_file="$(dirname "$0")/orchestrator_status_$(date +%Y%m%d_%H%M%S).md"

  {
    echo "# Task Orchestrator Status Report"
    echo "Generated: $(date)"
    echo ""

    echo "## Agent Status"
    echo "| Agent | Status | Health | Health Score | Last Seen | Tasks Completed |"
    echo "|-------|--------|--------|--------------|-----------|-----------------|"

    for agent in "${ALL_AGENTS[@]}"; do
      local status
      status=$(get_agent_status "${agent}")
      local health
      health=$(get_agent_health_status "${agent}")
      local health_score
      health_score=$(get_agent_health_score "${agent}")
      local last_seen
      last_seen=$(get_agent_last_seen "${agent}")
      local tasks_completed="0"

      if command -v jq &>/dev/null; then
        tasks_completed=$(jq -r ".agents[\"${agent}\"].tasks_completed // \"0\"" "${AGENT_STATUS_FILE}")
      fi

      local last_seen_formatted="Never"
      if [[ ${last_seen} != "0" ]]; then
        last_seen_formatted=$(date -r "${last_seen}" 2>/dev/null || echo "Unknown")
      fi

      echo "| ${agent} | ${status} | ${health} | ${health_score} | ${last_seen_formatted} | ${tasks_completed} |"
    done

    echo ""
    echo "## System Health"

    if [[ "${HEALTH_CHECKS_ENABLED}" == "true" ]]; then
      local orchestrator_health
      orchestrator_health=$(get_orchestrator_health_status)
      local orchestrator_score
      orchestrator_score=$(get_orchestrator_health_score)

      echo "- Health Checks Enabled: ${HEALTH_CHECKS_ENABLED}"
      echo "- Orchestrator Health: ${orchestrator_health} (${orchestrator_score}/100)"
      echo "- Agent Health Check Interval: ${AGENT_HEALTH_CHECK_INTERVAL} seconds"
      echo "- Agent Health Timeout: ${AGENT_HEALTH_TIMEOUT} seconds"
      echo "- Max Agent Failures: ${AGENT_MAX_FAILURES}"

      # Add unhealthy agents summary
      local unhealthy_count=0
      local unhealthy_agents=""
      for agent in "${ALL_AGENTS[@]}"; do
        local health
        health=$(get_agent_health_status "${agent}")
        if [[ "${health}" == "unhealthy" ]]; then
          unhealthy_count=$((unhealthy_count + 1))
          unhealthy_agents="${unhealthy_agents} ${agent}"
        fi
      done

      if [[ ${unhealthy_count} -gt 0 ]]; then
        echo "- Unhealthy Agents: ${unhealthy_count} (${unhealthy_agents})"
      else
        echo "- Unhealthy Agents: 0"
      fi
    else
      echo "- Health Checks: Disabled"
    fi

    echo ""
    echo "## Task Queue"

    if command -v jq &>/dev/null; then
      local queued_count
      queued_count=$(jq '.tasks | length' "${TASK_QUEUE_FILE}")
      local completed_count
      completed_count=$(jq '.completed | length' "${TASK_QUEUE_FILE}")
      local failed_count
      failed_count=$(jq '.failed | length' "${TASK_QUEUE_FILE}")
      local retry_scheduled_count
      retry_scheduled_count=$(jq '.tasks[] | select(.status == "retry_scheduled") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

      echo "- Queued: ${queued_count}"
      echo "- Scheduled for Retry: ${retry_scheduled_count}"
      echo "- Completed: ${completed_count}"
      echo "- Failed: ${failed_count}"

      echo ""
      echo "## Smart Assignment Configuration"
      echo "- Smart Assignment Enabled: ${SMART_ASSIGNMENT_ENABLED}"
      echo "- Load Balancing Enabled: ${LOAD_BALANCING_ENABLED}"
      echo "- Performance Tracking Enabled: ${PERFORMANCE_TRACKING_ENABLED}"
      echo "- Max Agent Load: ${MAX_AGENT_LOAD} tasks per agent"
      echo "- Agent Performance Window: ${AGENT_PERFORMANCE_WINDOW} seconds"
      echo "- Capability Match Weight: ${CAPABILITY_MATCH_WEIGHT}"
      echo "- Load Balance Weight: ${LOAD_BALANCE_WEIGHT}"
      echo "- Performance Weight: ${PERFORMANCE_WEIGHT}"

      # Add agent load distribution
      local load_distribution
      load_distribution=$(get_agent_load_distribution)
      if [[ -n ${load_distribution} ]]; then
        echo ""
        echo "## Agent Load Distribution"
        echo "| Agent | Current Load | Status |"
        echo "|-------|--------------|--------|"
        while IFS=':' read -r agent load status; do
          echo "| ${agent} | ${load} | ${status} |"
        done < <(echo "${load_distribution}")
      fi

      echo ""
      echo "## Retry Logic Configuration"
      echo "- Retry Logic Enabled: ${RETRY_LOGIC_ENABLED}"
      echo "- Max Retry Attempts: ${MAX_RETRY_ATTEMPTS}"
      echo "- Base Retry Delay: ${RETRY_BASE_DELAY} seconds"
      echo "- Max Retry Delay: ${RETRY_MAX_DELAY} seconds"
      echo "- Retry Backoff Multiplier: ${RETRY_BACKOFF_MULTIPLIER}"
      echo "- Jitter Enabled: ${RETRY_JITTER_ENABLED} (${RETRY_JITTER_PERCENT}%)"
      echo "- Transient Errors: ${RETRY_TRANSIENT_ERRORS}"
      echo "- Permanent Errors: ${RETRY_PERMANENT_ERRORS}"
      echo "- Success Rate Threshold: ${RETRY_SUCCESS_RATE_THRESHOLD}%"
      echo "- Agent Load Threshold: ${RETRY_AGENT_LOAD_THRESHOLD}%"
      echo "- Queue Backlog Threshold: ${RETRY_QUEUE_BACKLOG_THRESHOLD}"

      # Add retry statistics
      if [[ "${RETRY_LOGIC_ENABLED}" == "true" ]]; then
        local retry_stats
        retry_stats=$(get_retry_statistics)
        local retry_scheduled total_retries max_retries failed_after_retries
        IFS='|' read -r retry_scheduled total_retries max_retries failed_after_retries <<<"${retry_stats}"

        echo ""
        echo "## Retry Statistics"
        echo "- Tasks Scheduled for Retry: ${retry_scheduled}"
        echo "- Total Retry Attempts: ${total_retries}"
        echo "- Maximum Retries for Single Task: ${max_retries}"
        echo "- Tasks Failed After Retries: ${failed_after_retries}"
      fi

      echo ""
      echo "## Queue Analytics Configuration"
      echo "- Analytics Enabled: ${QUEUE_ANALYTICS_ENABLED}"
      echo "- Collection Interval: ${ANALYTICS_COLLECTION_INTERVAL} seconds"
      echo "- Data Retention: ${ANALYTICS_RETENTION_DAYS} days"
      echo "- Performance Window: ${ANALYTICS_PERFORMANCE_WINDOW} seconds"
      echo "- Utilization Threshold: ${ANALYTICS_UTILIZATION_THRESHOLD}%"
      echo "- Efficiency Threshold: ${ANALYTICS_EFFICIENCY_THRESHOLD}%"
      echo ""

      # Add async processing configuration
      echo "## Async Processing Configuration"
      echo "- Async Processing Enabled: ${ASYNC_PROCESSING_ENABLED}"
      echo "- Max Concurrent Tasks per Agent: ${MAX_CONCURRENT_TASKS}"
      echo "- Async Queue Size: ${ASYNC_QUEUE_SIZE}"
      echo "- Async Timeout: ${ASYNC_TIMEOUT} seconds"
      echo "- Async Retry Attempts: ${ASYNC_RETRY_ATTEMPTS}"
      echo "- Non-blocking Operations: ${NON_BLOCKING_OPERATIONS}"
      echo "- Concurrent Batch Size: ${CONCURRENT_BATCH_SIZE}"
      echo "- Async Monitoring Interval: ${ASYNC_MONITORING_INTERVAL} seconds"
      echo ""

      # Add async processing statistics
      if [[ "${ASYNC_PROCESSING_ENABLED}" == "true" ]]; then
        local async_stats
        async_stats=$(get_async_processing_stats)
        local running_ops completed_ops failed_ops total_ops
        IFS='|' read -r running_ops completed_ops failed_ops total_ops <<<"${async_stats}"

        echo "## Async Processing Statistics"
        echo "- Running Operations: ${running_ops}"
        echo "- Completed Operations: ${completed_ops}"
        echo "- Failed Operations: ${failed_ops}"
        echo "- Total Operations: ${total_ops}"
        echo ""
      fi

      # Add resource limits status
      if [[ "${RESOURCE_LIMITS_ENABLED}" == "true" ]]; then
        local resource_status
        resource_status=$(get_resource_limits_status)
        local status cpu_usage mem_usage disk_usage load_avg issues
        IFS='|' read -r status cpu_usage mem_usage disk_usage load_avg issues <<<"${resource_status}"

        echo "## Resource Limits Status"
        echo "- Resource Limits Enabled: ${RESOURCE_LIMITS_ENABLED}"
        echo "- Current Status: ${status}"
        echo "- CPU Usage: ${cpu_usage}% (Limit: ${MAX_CPU_USAGE}%)"
        echo "- Memory Usage: ${mem_usage}% (Limit: ${MAX_MEMORY_USAGE}%)"
        echo "- Disk Usage: ${disk_usage}% (Limit: ${MAX_DISK_USAGE}%)"
        echo "- System Load: ${load_avg}% (Limit: ${MAX_SYSTEM_LOAD}%)"
        echo "- Resource Check Interval: ${RESOURCE_CHECK_INTERVAL} seconds"
        echo "- Throttle Threshold: ${THROTTLE_THRESHOLD}%"
        echo "- Burst Limit: ${BURST_LIMIT} tasks"

        if [[ -n ${issues} ]]; then
          echo "- Issues: ${issues}"
        fi
        echo ""
      else
        echo "## Resource Limits"
        echo "- Resource Limits: Disabled"
        echo ""
      fi
      if [[ "${QUEUE_ANALYTICS_ENABLED}" == "true" && -f "${ANALYTICS_METRICS_FILE}" ]]; then
        local metrics_count
        metrics_count=$(jq '.metrics | length' "${ANALYTICS_METRICS_FILE}" 2>/dev/null || echo "0")

        local latest_metrics
        latest_metrics=$(jq '.metrics[-1]' "${ANALYTICS_METRICS_FILE}" 2>/dev/null)

        if [[ -n ${latest_metrics} && ${latest_metrics} != "null" ]]; then
          echo "## Latest Analytics Summary"
          echo "- Metrics Collected: ${metrics_count}"
          local timestamp_value
          timestamp_value=$(echo "${latest_metrics}" | jq '.timestamp' 2>/dev/null || echo "0")
          echo "- Last Updated: $(date -r "${timestamp_value}" 2>/dev/null || echo "Unknown")"

          local avg_completion
          avg_completion=$(echo "${latest_metrics}" | jq '.performance.avg_completion_time' 2>/dev/null || echo "0")
          local throughput
          throughput=$(echo "${latest_metrics}" | jq '.performance.throughput_per_hour' 2>/dev/null || echo "0")
          local failure_rate
          failure_rate=$(echo "${latest_metrics}" | jq '.performance.failure_rate' 2>/dev/null || echo "0")

          echo "- Avg Completion Time: ${avg_completion} seconds"
          echo "- Throughput: ${throughput} tasks/hour"
          echo "- Failure Rate: ${failure_rate}%"
          echo ""
        fi
      fi
      local active_batches
      active_batches=$(jq '.batches[] | select(.status == "active") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
      local assigned_batches
      assigned_batches=$(jq '.batches[] | select(.status == "assigned") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")
      local completed_batches
      completed_batches=$(jq '.batches[] | select(.status == "completed") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

      if [[ ${active_batches} -gt 0 || ${assigned_batches} -gt 0 || ${completed_batches} -gt 0 ]]; then
        echo ""
        echo "## Task Batches"
        echo "- Active Batches: ${active_batches}"
        echo "- Assigned Batches: ${assigned_batches}"
        echo "- Completed Batches: ${completed_batches}"

        if [[ ${active_batches} -gt 0 ]]; then
          echo ""
          echo "### Active Batches"
          echo "| Batch ID | Agent | Task Count | Description | Priority | Created |"
          echo "|----------|-------|------------|-------------|----------|---------|"

          jq -r '.batches[] | select(.status == "active") | "\(.id)|\(.agent)|\(.task_count)|\(.description)|\(.priority)|\(.created)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r id agent count desc pri created; do
            local created_formatted
            created_formatted=$(date -r "${created}" 2>/dev/null || echo "Unknown")
            echo "| ${id} | ${agent} | ${count} | ${desc} | ${pri} | ${created_formatted} |"
          done
        fi

        if [[ ${assigned_batches} -gt 0 ]]; then
          echo ""
          echo "### Assigned Batches"
          echo "| Batch ID | Agent | Task Count | Description | Assigned At |"
          echo "|----------|-------|------------|-------------|-------------|"

          jq -r '.batches[] | select(.status == "assigned") | "\(.id)|\(.agent)|\(.task_count)|\(.description)|\(.assigned_at)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r id agent count desc assigned; do
            local assigned_formatted
            assigned_formatted=$(date -r "${assigned}" 2>/dev/null || echo "Unknown")
            echo "| ${id} | ${agent} | ${count} | ${desc} | ${assigned_formatted} |"
          done
        fi
      fi

      # Add dependency and workflow information
      local blocked_count
      blocked_count=$(jq '.tasks[] | select(.status == "blocked") | length' "${TASK_QUEUE_FILE}" 2>/dev/null || echo "0")

      if [[ ${blocked_count} -gt 0 ]]; then
        echo ""
        echo "## Workflow Dependencies"
        echo "- Blocked Tasks (waiting for dependencies): ${blocked_count}"

        echo ""
        echo "### Blocked Tasks"
        echo "| Task ID | Type | Description | Dependencies | Workflow Type | Step |"
        echo "|---------|------|-------------|--------------|---------------|------|"

        jq -r '.tasks[] | select(.status == "blocked") | "\(.id)|\(.type)|\(.description)|\(.dependencies | join(", "))|\(.workflow_type // "N/A")|\(.step_number // "N/A")"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r id type desc deps workflow step; do
          echo "| ${id} | ${type} | ${desc} | ${deps} | ${workflow} | ${step} |"
        done
      fi

      if [[ ${queued_count} -gt 0 ]]; then
        echo ""
        echo "### Queued Tasks (Sorted by Intelligent Priority)"
        echo "| Task ID | Type | Description | Assigned Agent | Static Priority | Calculated Priority |"
        echo "|---------|------|-------------|----------------|----------------|-------------------|"

        jq -r '.tasks[] | select(.status == "queued") | "\(.id)|\(.type)|\(.description)|\(.assigned_agent)|\(.priority)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r id type desc agent static_pri; do
          local calc_pri
          calc_pri=$(calculate_task_priority "${id}")
          echo "| ${id} | ${type} | ${desc} | ${agent} | ${static_pri} | ${calc_pri} |"
        done
      fi
    fi

    if [[ ${retry_scheduled_count} -gt 0 ]]; then
      echo ""
      echo "### Tasks Scheduled for Retry"
      echo "| Task ID | Type | Description | Retry Count | Retry At | Last Error |"
      echo "|---------|------|-------------|-------------|----------|------------|"

      jq -r '.tasks[] | select(.status == "retry_scheduled") | "\(.id)|\(.type)|\(.description)|\(.retry_count)|\(.retry_at)|\(.last_error)"' "${TASK_QUEUE_FILE}" | while IFS='|' read -r id type desc retry_count retry_at error; do
        local retry_formatted
        retry_formatted=$(date -r "${retry_at}" 2>/dev/null || echo "Unknown")
        local error_short
        error_short=$(echo "${error}" | cut -c1-50)
        if [[ ${#error} -gt 50 ]]; then
          error_short="${error_short}..."
        fi
        echo "| ${id} | ${type} | ${desc} | ${retry_count} | ${retry_formatted} | ${error_short} |"
      done
    fi

  } >"${report_file}"

  log_message "INFO" "Status report generated: ${report_file}"
}

# Auto-start essential agents
auto_start_agents() {
  local essential_agents=("agent_build.sh" "agent_debug.sh" "agent_codegen.sh")

  for agent in "${essential_agents[@]}"; do
    local agent_path
    agent_path="$(dirname "$0")/${agent}"
    if [[ -f ${agent_path} && -x ${agent_path} ]]; then
      ensure_agent_running "${agent}"
      log_message "INFO" "Ensured ${agent} is running"
    fi
  done
}

# Check for tasks from external sources (TODOs, issues, etc.)
check_external_tasks() {
  # Check for new TODO files
  local todo_file="/Users/danielstevens/Desktop/Quantum-workspace/Projects/todo-tree-output.json"
  if [[ -f ${todo_file} && -s ${todo_file} ]]; then
    # Read TODOs and create tasks
    python3 -c "
import json
import sys
try:
    with open('${todo_file}', 'r') as f:
        todos = json.load(f)
    for todo in todos:
        file_path = todo.get('file', '')
        text = todo.get('text', '')

        # Determine task type based on TODO content
        task_type = 'generate'
        if 'debug' in text.lower() or 'fix' in text.lower():
            task_type = 'debug'
        elif 'build' in text.lower() or 'compile' in text.lower():
            task_type = 'build'
        elif 'ui' in text.lower() or 'interface' in text.lower():
            task_type = 'ui'
        elif 'test' in text.lower():
            task_type = 'test'

        print(f'{task_type}|{file_path}|{text}')
except Exception as e:
    pass
" | while IFS='|' read -r task_type file_path description; do
      if [[ -n ${task_type} && -n ${description} ]]; then
        add_task "${task_type}" "TODO: ${description} in ${file_path}" 7
        log_message "INFO" "Created task from TODO: ${description}"
      fi
    done || true
  fi

  # Check for failed builds or tests that need attention
  for log_file in "$(dirname "$0")"/*.log; do
    if [[ -f ${log_file} ]]; then
      local recent_errors
      recent_errors=$(tail -50 "${log_file}" | grep -i 'error\|failed\|failure' | tail -5) || true
      if [[ -n ${recent_errors} ]]; then
        local agent_name
        agent_name=$(basename "${log_file}" .log)

        # Check if we already have a recent debug task for this issue
        local existing_task=""
        if command -v jq &>/dev/null; then
          local jq_result
          jq_result=$(jq --arg agent_name "${agent_name}" -r '.tasks[] | select(.type == "debug" and (.description // "") | type == "string" and contains($agent_name)) | .id' "${TASK_QUEUE_FILE}" 2>/dev/null | head -1)
          local jq_exit=$?
          if [[ ${jq_exit} -eq 0 ]] && [[ -n ${jq_result} ]]; then
            existing_task=${jq_result}
          fi
        fi

        if [[ -z ${existing_task} ]]; then
          add_task "debug" "Auto-generated: Investigate errors in ${agent_name}" 8
          log_message "INFO" "Created debug task for errors in ${agent_name}"
        fi
      fi
    fi
  done

  # Check git status for uncommitted changes that might need attention
  if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
    local git_output
    git_output=$(git status --porcelain 2>/dev/null)
    local git_exit_code=$?
    local uncommitted_files="0"

    if [[ ${git_exit_code} -eq 0 ]]; then
      uncommitted_files=$(echo "${git_output}" | wc -l)
    fi

    if [[ ${uncommitted_files} -gt 20 ]]; then
      # Many uncommitted files - create organization task
      local existing_organize_task=""
      if command -v jq &>/dev/null; then
        local jq_organize_result
        jq_organize_result=$(jq -r '.tasks[] | select(.type == "coordinate" and ((.description // "") | type == "string" and contains("uncommitted"))) | .id' "${TASK_QUEUE_FILE}" 2>/dev/null | head -1)
        local jq_org_exit=$?
        if [[ ${jq_org_exit} -eq 0 ]] && [[ -n ${jq_organize_result} ]]; then
          existing_organize_task=${jq_organize_result}
        fi
      fi

      if [[ -z ${existing_organize_task} ]]; then
        add_task "coordinate" "Organize and review ${uncommitted_files} uncommitted files" 6
        log_message "INFO" "Created coordination task for uncommitted files"
      fi
    fi
  fi
}

# Check for tasks from external sources (TODOs, issues, etc.)

# Main orchestration loop
log_message "INFO" "Task Orchestrator starting..."
auto_start_agents

# Initialize analytics system
initialize_analytics

# Initialize async processing system
initialize_async_processing

while true; do
  # Update orchestrator status
  update_agent_status "task_orchestrator.sh" "active"

  # Monitor resource limits and apply throttling
  monitor_resource_limits >/dev/null 2>&1

  # Optimize task storage (compression and archiving)
  optimize_task_storage >/dev/null 2>&1

  # Enforce queue limits and cleanup old tasks
  enforce_queue_limits >/dev/null 2>&1

  # Clean up old completed batches
  cleanup_old_batches >/dev/null 2>&1

  # Create intelligent task batches
  create_task_batches >/dev/null 2>&1

  # Process completed tasks
  process_completed_tasks >/dev/null 2>&1

  # Process active task batches
  process_task_batches >/dev/null 2>&1

  # Monitor agent health
  monitor_agent_health >/dev/null 2>&1

  # Enhanced health monitoring with automatic recovery
  enhanced_health_monitoring >/dev/null 2>&1

  # Process async operations
  process_async_operations >/dev/null 2>&1

  # Collect analytics data periodically
  current_minute=$(date +%M | sed 's/^0*//')
  if [[ $((current_minute % 5)) -eq 0 ]]; then
    collect_queue_metrics >/dev/null 2>&1
  fi

  # Generate analytics report hourly
  current_hour=$(date +%H | sed 's/^0*//')
  if [[ $((current_hour % 1)) -eq 0 && $((current_minute % 60)) -eq 0 ]]; then
    generate_analytics_report >/dev/null 2>&1
  fi

  # Clean up old analytics data daily
  if [[ $((current_hour)) -eq 2 && $((current_minute)) -eq 0 ]]; then
    cleanup_analytics_data >/dev/null 2>&1
  fi

  # Optimize task storage periodically (compress old tasks and archive completed ones)
  if [[ "${TASK_COMPRESSION_ENABLED}" == "true" ]] && [[ $((current_minute % 10)) -eq 0 ]]; then
    optimize_task_storage >/dev/null 2>&1
  fi

  # Distribute queued tasks
  if [[ "${ASYNC_PROCESSING_ENABLED}" == "true" ]]; then
    distribute_tasks_async >/dev/null 2>&1
  else
    distribute_tasks >/dev/null 2>&1
  fi

  # Generate periodic status report (every 5 minutes)
  if [[ $((current_minute % 5)) -eq 0 ]]; then
    generate_status_report >/dev/null 2>&1
  fi

  # Check for new tasks from external sources
  check_external_tasks >/dev/null 2>&1

  sleep 30 # Check every 30 seconds
done
