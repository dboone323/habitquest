#!/bin/bash
# Testing Agent: Manages and improves test coverage and quality

AGENT_NAME="testing_agent.sh"
WORKSPACE="/Users/danielstevens/Desktop/Quantum-workspace"
LOG_FILE="${WORKSPACE}/Tools/Automation/agents/testing_agent.log"
NOTIFICATION_FILE="${WORKSPACE}/Tools/Automation/agents/communication/${AGENT_NAME}_notification.txt"
AGENT_STATUS_FILE="${WORKSPACE}/Tools/Automation/agents/agent_status.json"
TASK_QUEUE_FILE="${WORKSPACE}/Tools/Automation/agents/task_queue.json"
OLLAMA_ENDPOINT="http://localhost:11434"

# Logging function
log() {
  echo "[$(date)] ${AGENT_NAME}: $*" >>"${LOG_FILE}"
}

# Ollama Integration Functions
ollama_query() {
  local prompt="$1"
  local model="${2:-codellama}"

  curl -s -X POST "${OLLAMA_ENDPOINT}/api/generate" \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"${model}\", \"prompt\": \"${prompt}\", \"stream\": false}" |
    jq -r '.response // empty'
}

generate_test_with_ollama() {
  local source_file="$1"
  local test_type="$2"

  if [[ ! -f ${source_file} ]]; then
    log "ERROR: Source file not found: ${source_file}"
    return 1
  fi

  local source_content
  source_content=$(cat "${source_file}")

  local prompt="Generate comprehensive unit tests for this Swift code. Include edge cases, error handling, and async tests where appropriate:

${source_content}

Generate tests in the following format:
- Test class structure
- Individual test methods
- Setup and teardown methods
- Mock objects if needed
- Assertions for all scenarios

Focus on ${test_type} testing."

  local generated_tests
  generated_tests=$(ollama_query "${prompt}")

  if [[ -n ${generated_tests} ]]; then
    echo "${generated_tests}"
    return 0
  else
    log "ERROR: Failed to generate tests with Ollama"
    return 1
  fi
}

analyze_test_quality_with_ollama() {
  local test_file="$1"

  if [[ ! -f ${test_file} ]]; then
    log "ERROR: Test file not found: ${test_file}"
    return 1
  fi

  local test_content
  test_content=$(cat "${test_file}")

  local prompt="Analyze the quality of these Swift unit tests. Provide feedback on:
1. Test coverage completeness
2. Edge case coverage
3. Assertion quality
4. Test isolation
5. Naming conventions
6. Setup/teardown usage
7. Mock/stub usage
8. Async testing patterns

Tests to analyze:
${test_content}

Provide specific recommendations for improvement."

  local analysis
  analysis=$(ollama_query "${prompt}")

  if [[ -n ${analysis} ]]; then
    echo "${analysis}"
    return 0
  else
    log "ERROR: Failed to analyze test quality with Ollama"
    return 1
  fi
}

# Update agent status to available when starting
update_status() {
  local status="$1"
  if command -v jq &>/dev/null; then
    jq ".agents[\"${AGENT_NAME}\"].status = \"${status}\" | .agents[\"${AGENT_NAME}\"].last_seen = $(date +%s)" "${AGENT_STATUS_FILE}" >"${AGENT_STATUS_FILE}.tmp" && mv "${AGENT_STATUS_FILE}.tmp" "${AGENT_STATUS_FILE}"
  fi
  echo "[$(date)] ${AGENT_NAME}: Status updated to ${status}" >>"${LOG_FILE}"
}

# Process a specific task
process_task() {
  local task_id="$1"
  log "Processing task ${task_id}"

  # Get task details
  if command -v jq &>/dev/null; then
    local task_desc
    task_desc=$(jq -r ".tasks[] | select(.id == \"${task_id}\") | .description" "${TASK_QUEUE_FILE}")
    local task_type
    task_type=$(jq -r ".tasks[] | select(.id == \"${task_id}\") | .type" "${TASK_QUEUE_FILE}")
    log "Task description: ${task_desc}"
    log "Task type: ${task_type}"

    # Process based on task type
    case "${task_type}" in
    "test" | "testing" | "coverage")
      run_testing_analysis "${task_desc}"
      ;;
    *)
      log "Unknown task type: ${task_type}"
      ;;
    esac

    # Mark task as completed
    update_task_status "${task_id}" "completed"
    log "Task ${task_id} completed"
  fi
}

# Update task status
update_task_status() {
  local task_id="$1"
  local status="$2"
  if command -v jq &>/dev/null; then
    jq "(.tasks[] | select(.id == \"${task_id}\") | .status) = \"${status}\"" "${TASK_QUEUE_FILE}" >"${TASK_QUEUE_FILE}.tmp" && mv "${TASK_QUEUE_FILE}.tmp" "${TASK_QUEUE_FILE}"
  fi
}

# Testing analysis function
run_testing_analysis() {
  local task_desc="$1"
  log "Running testing analysis for: ${task_desc}"

  # Extract project name from task description
  local projects=("CodingReviewer" "MomentumFinance" "HabitQuest" "PlannerApp" "AvoidObstaclesGame")

  for project in "${projects[@]}"; do
    if [[ -d "${WORKSPACE}/Projects/${project}" ]]; then
      log "Analyzing testing coverage in ${project}..."
      cd "${WORKSPACE}/Projects/${project}" || return

      # Test coverage metrics
      log "Calculating testing metrics for ${project}..."

      # Count test files
      local test_files
      test_files=$(find . -name "*Test*.swift" -o -name "*Tests*.swift" | wc -l)
      log "Test files found: ${test_files}"

      # Count source files
      local source_files
      source_files=$(find . -name "*.swift" -not -path "*/Tests/*" -not -path "*/UITests/*" | wc -l)
      log "Source files found: ${source_files}"

      # Calculate test coverage ratio
      local coverage_ratio=0
      if [[ ${source_files} -gt 0 ]]; then
        coverage_ratio=$((test_files * 100 / source_files))
      fi
      log "Test coverage ratio: ${coverage_ratio}%"

      # Analyze test quality
      log "Analyzing test quality..."

      if [[ ${test_files} -gt 0 ]]; then
        # Check for test patterns
        local unit_tests
        unit_tests=$(find . -name "*Test*.swift" -exec grep -l "func test" {} \; | wc -l)
        local ui_tests
        ui_tests=$(find . -name "*UITest*.swift" -exec grep -l "func test" {} \; | wc -l)
        local async_tests
        async_tests=$(find . -name "*Test*.swift" -exec grep -l "async" {} \; | wc -l)

        log "Unit tests: ${unit_tests}"
        log "UI tests: ${ui_tests}"
        log "Async tests: ${async_tests}"

        # Check for test best practices
        local missing_asserts
        missing_asserts=$(find . -name "*Test*.swift" -exec grep -l "func test" {} \; -print0 | xargs -0 grep -L "XCTAssert\|XCTFail" | wc -l)
        log "Tests missing assertions: ${missing_asserts}"

        # Calculate test quality score
        local quality_score=$((100 - (missing_asserts * 10)))
        if [[ ${quality_score} -lt 0 ]]; then
          quality_score=0
        fi
        log "Test quality score: ${quality_score}%"
      else
        log "No test files found - test coverage is 0%"
      fi

      # Use Ollama for intelligent test analysis and generation
      log "Using Ollama for intelligent test analysis..."

      # Find source files that need tests
      local source_files_list
      source_files_list=$(find . -name "*.swift" -not -path "*/Tests/*" -not -path "*/UITests/*" | head -5)

      for source_file in ${source_files_list}; do
        if [[ -f ${source_file} ]]; then
          local test_file="${source_file%.swift}Tests.swift"
          if [[ ! -f ${test_file} ]]; then
            log "Generating tests for ${source_file} using Ollama..."
            local generated_tests
            generated_tests=$(generate_test_with_ollama "${source_file}" "unit")
            if [[ -n ${generated_tests} ]]; then
              log "Generated tests for ${source_file}"
              # Could save generated tests to file here
            fi
          else
            # Analyze existing test quality
            local analysis
            analysis=$(analyze_test_quality_with_ollama "${test_file}")
            if [[ -n ${analysis} ]]; then
              log "Test quality analysis for ${test_file} completed"
            fi
          fi
        fi
      done

      if [[ ${test_files} -eq 0 ]]; then
        log "Recommendation: Create unit tests for core functionality"
        log "Recommendation: Add UI tests for user interactions"
      fi

      if [[ ${coverage_ratio} -lt 50 ]]; then
        log "Recommendation: Increase test coverage to at least 50%"
      fi

      if [[ ${missing_asserts} -gt 0 ]]; then
        log "Recommendation: Add proper assertions to all test methods"
      fi

      if [[ ${async_tests} -eq 0 ]]; then
        log "Recommendation: Add async tests for network and database operations"
      fi
    fi
  done

  log "Testing analysis completed"
}

# Main agent loop
log "Starting testing agent..."
update_status "available"

# Track processed tasks to avoid duplicates
declare -A processed_tasks

while true; do
  # Check for new task notifications
  if [[ -f ${NOTIFICATION_FILE} ]]; then
    while IFS='|' read -r _ action task_id; do
      if [[ ${action} == "execute_task" && -z ${processed_tasks[${task_id}]} ]]; then
        update_status "busy"
        process_task "${task_id}"
        update_status "available"
        processed_tasks[${task_id}]="completed"
        log "Marked task ${task_id} as processed"
      fi
    done <"${NOTIFICATION_FILE}"

    # Clear processed notifications to prevent re-processing
    true >"${NOTIFICATION_FILE}"
  fi

  # Update last seen timestamp
  update_status "available"

  sleep 30 # Check every 30 seconds
done
