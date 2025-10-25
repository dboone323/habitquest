#!/usr/bin/env bash
# TODO Processing Agent: Autonomously scans for TODOs and delegates to appropriate agents

AGENT_NAME="TodoAgent"
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
AGENTS_DIR="$(dirname "$0")"
TODO_FILE="${WORKSPACE_ROOT}/Projects/todo-tree-output.json"
LOG_FILE="${AGENTS_DIR}/todo_agent.log"
MCP_URL="http://127.0.0.1:5005"
STATUS_FILE="${AGENTS_DIR}/agent_status.json"
TASK_QUEUE="${AGENTS_DIR}/task_queue.json"
PID_FILE="${AGENTS_DIR}/agent_todo.sh.pid"
PID=$$

# Logging function
log_message() {
    echo "[$(date)] ${AGENT_NAME}: $1" | tee -a "${LOG_FILE}"
}

# Default configuration
MAX_TODOS_PER_CYCLE=10
SCAN_INTERVAL=1800 # 30 minutes default
RUN_ONCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --once)
        RUN_ONCE=true
        shift
        ;;
    --limit=*)
        MAX_TODOS_PER_CYCLE="${1#*=}"
        shift
        ;;
    --interval=*)
        SCAN_INTERVAL="${1#*=}"
        shift
        ;;
    --help)
        echo "Usage: $0 [options]"
        echo "Options:"
        echo "  --once                 Run one scan and exit"
        echo "  --limit=N             Process maximum N TODOs per cycle (default: 10)"
        echo "  --interval=N          Sleep N seconds between scans (default: 1800)"
        echo "  --help                Show this help"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
done

# Ensure running in bash
if [[ -z ${BASH_VERSION} ]]; then
    echo "This script must be run with bash."
    exec bash "$0" "$@"
    exit 1
fi

# Check for existing instance BEFORE writing PID file
if [[ -f ${PID_FILE} ]]; then
    existing_pid=$(cat "${PID_FILE}")
    if kill -0 "${existing_pid}" 2>/dev/null; then
        log_message "Another instance is already running (PID: ${existing_pid}), exiting"
        exit 1
    else
        log_message "Removing stale PID file from dead process"
        rm -f "${PID_FILE}"
    fi
fi

# Write PID file
echo "${PID}" >"${PID_FILE}"

# Trap signals for clean shutdown
trap 'cleanup; exit 0' SIGTERM SIGINT EXIT

cleanup() {
    update_status "stopped"
    rm -f "${PID_FILE}"
    log_message "Agent stopped and cleaned up"
}

# Update agent status
update_status() {
    local status="$1"
    local timestamp
    timestamp=$(date +%s)

    # Ensure status file exists
    if [[ ! -f ${STATUS_FILE} ]]; then
        echo '{"agents": {}}' >"${STATUS_FILE}"
    fi

    # Update status using jq if available
    if command -v jq &>/dev/null; then
        jq --arg agent "agent_todo.sh" --arg status "${status}" --arg pid "${PID}" --arg timestamp "${timestamp}" \
            '.agents[$agent] = {"status": $status, "pid": ($pid | tonumber), "last_seen": ($timestamp | tonumber), "tasks_completed": (.agents[$agent].tasks_completed // 0)}' \
            "${STATUS_FILE}" >"${STATUS_FILE}.tmp" && mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
    else
        # Fallback method without jq
        log_message "jq not available, using fallback status update"
    fi
}

# Function to autonomously scan workspace for TODOs
scan_workspace_todos() {
    log_message "Scanning workspace for TODOs..."

    local temp_todo_file="${TODO_FILE}.temp"
    local todos_found=0

    # Create temporary file for new TODOs
    echo "[]" >"${temp_todo_file}"

    # Find all relevant source files
    local file_types=("*.swift" "*.py" "*.sh" "*.js" "*.ts" "*.md" "*.txt")
    local exclude_dirs=(".git" "node_modules" ".build" "DerivedData" "*.xcworkspace" "*.xcodeproj")

    # Build find command with exclusions
    local find_cmd="find \"${WORKSPACE_ROOT}\" -type f"
    for exclude in "${exclude_dirs[@]}"; do
        find_cmd+=" -not -path \"*/${exclude}/*\""
    done

    # Add file type conditions
    find_cmd+=' \( '
    for i in "${!file_types[@]}"; do
        if [[ ${i} -gt 0 ]]; then
            find_cmd+=" -o "
        fi
        find_cmd+="-name \"${file_types[${i}]}\""
    done
    find_cmd+=' \)'

    # Execute find and process files
    eval "${find_cmd}" | while read -r file_path; do
        if [[ ! -f ${file_path} ]]; then
            continue
        fi

        # Skip binary files and very large files
        if [[ $(wc -c <"${file_path}") -gt 1048576 ]]; then # Skip files > 1MB
            continue
        fi

        local line_num=0
        while IFS= read -r line; do
            ((line_num++))

            # Look for TODO, FIXME, HACK, BUG comments
            if [[ ${line} =~ (TODO|FIXME|HACK|BUG|XXX) ]]; then
                local rel_path
                # Get relative path (macOS compatible)
                if [[ ${file_path} == "${WORKSPACE_ROOT}"* ]]; then
                    rel_path="${file_path#"${WORKSPACE_ROOT}"/}"
                else
                    rel_path="${file_path}"
                fi

                # Extract the comment text
                local comment_text="${line}"
                # Remove leading whitespace and comment markers
                comment_text=$(echo "${comment_text}" | sed -E 's/^[[:space:]]*[\/\*#]*[[:space:]]*//' | sed -E 's/\*\/[[:space:]]*$//')

                # Create TODO entry with proper JSON escaping
                # Clean comment_text to prevent JSON parsing errors
                comment_text=$(echo "${comment_text}" | tr -d '\n\r\t' | sed 's/"/\\"/g')

                # Add to temporary file using jq if available
                if command -v jq &>/dev/null; then
                    jq --arg file "${rel_path}" --arg line "${line_num}" --arg text "${comment_text}" \
                        --arg type "$(determine_todo_type "${comment_text}")" --arg priority "$(determine_todo_priority "${comment_text}")" \
                        '. += [{"file": $file, "line": ($line | tonumber), "text": $text, "type": $type, "priority": ($priority | tonumber)}]' \
                        "${temp_todo_file}" >"${temp_todo_file}.tmp" && mv "${temp_todo_file}.tmp" "${temp_todo_file}"
                fi

                ((todos_found++))
            fi
        done <"${file_path}"
    done

    # Move temporary file to final location
    if [[ -f ${temp_todo_file} ]]; then
        mv "${temp_todo_file}" "${TODO_FILE}"
        log_message "Found and catalogued ${todos_found} TODOs"
    fi

    return 0
}

# Determine TODO type based on content
determine_todo_type() {
    local text="$1"
    local lower_text="${text,,}" # Convert to lowercase

    if [[ ${lower_text} =~ (fix|bug|error|broken|issue) ]]; then
        echo "debug"
    elif [[ ${lower_text} =~ (build|compile|test|ci) ]]; then
        echo "build"
    elif [[ ${lower_text} =~ (ui|ux|interface|design|layout) ]]; then
        echo "ui"
    elif [[ ${lower_text} =~ (implement|add|create|develop) ]]; then
        echo "generate"
    elif [[ ${lower_text} =~ (refactor|optimize|improve|enhance) ]]; then
        echo "update"
    elif [[ ${lower_text} =~ (review|check|validate|verify) ]]; then
        echo "coordinate"
    else
        echo "generate"
    fi
}

# Determine TODO priority based on urgency indicators
determine_todo_priority() {
    local text="$1"
    local lower_text="${text,,}"

    if [[ ${lower_text} =~ (urgent|critical|important|asap|immediately) ]]; then
        echo 9
    elif [[ ${lower_text} =~ (bug|error|broken|fix) ]]; then
        echo 8
    elif [[ ${lower_text} =~ (security|safety|vulnerability) ]]; then
        echo 9
    elif [[ ${lower_text} =~ (performance|slow|optimize) ]]; then
        echo 7
    elif [[ ${lower_text} =~ (test|testing) ]]; then
        echo 6
    else
        echo 5
    fi
}

# Enhanced function to create tasks via MCP server
create_todo_task() {
    local task_type="$1"
    local description="$2"
    local priority="$3"
    local project="$4"
    local file_path="$5"

    # Check for duplicate tasks first
    if [[ -f ${TASK_QUEUE} ]]; then
        local existing_task
        existing_task=$(jq --arg desc "${description}" --arg type "${task_type}" \
            '.tasks[] | select(.type == $type and .description == $desc and (.status == "queued" or .status == "assigned" or .status == "in_progress"))' \
            "${TASK_QUEUE}" 2>/dev/null)

        if [[ -n ${existing_task} ]]; then
            log_message "Skipping duplicate task: ${task_type} - ${description}"
            return 0
        fi
    fi

    log_message "Creating task: ${description}"

    # Create task via MCP server
    local response
    response=$(curl -s -X POST "${MCP_URL}/create_task" \
        -H "Content-Type: application/json" \
        -d "{
      \"type\": \"${task_type}\",
      \"description\": \"${description}\",
      \"priority\": ${priority},
      \"project\": \"${project}\",
      \"file_path\": \"${file_path}\"
    }")

    if [[ $? -eq 0 ]] && echo "${response}" | grep -q '"ok": true'; then
        local task_id
        task_id=$(echo "${response}" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('task', {}).get('id', 'unknown'))" 2>/dev/null)
        log_message "Successfully created task ${task_id}: ${description}"
        return 0
    else
        log_message "Failed to create task: ${response}"
        return 1
    fi
}

# Process TODOs and create tasks
process_todos() {
    if [[ ! -f ${TODO_FILE} ]]; then
        log_message "No TODO file found, skipping processing"
        return 1
    fi

    local processed_count=0
    local skipped_count=0
    local max_todos=${MAX_TODOS_PER_CYCLE}

    # Process each TODO using Python for JSON parsing
    python3 -c "
import json
import sys

try:
    with open('${TODO_FILE}', 'r') as f:
        todos = json.load(f)

    for i, todo in enumerate(todos):
        file_path = todo.get('file', '')
        line_num = todo.get('line', 0)
        text = todo.get('text', '')
        todo_type = todo.get('type', 'generate')
        priority = todo.get('priority', 5)

        # Determine project from file path
        project = ''
        if file_path.startswith('Projects/'):
            parts = file_path.split('/')
            if len(parts) > 1:
                project = parts[1]

        print(f'{i}|{file_path}|{line_num}|{text}|{todo_type}|{priority}|{project}')

except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" | while IFS='|' read -r index file_path line_num text todo_type priority project; do

        if [[ ${index} == "ERROR:"* ]]; then
            log_message "JSON parsing error: ${index}"
            continue
        fi

        # Check if we've reached the processing limit
        if [[ ${processed_count} -ge ${max_todos} ]]; then
            log_message "Reached maximum TODO processing limit (${max_todos}), stopping for this cycle"
            break
        fi

        # Check if we've already processed this TODO recently
        local todo_marker="${AGENTS_DIR}/todo_${index}_$(echo "${text}" | md5sum | cut -d' ' -f1).processed"

        if [[ -f ${todo_marker} ]]; then
            ((skipped_count++))
            continue
        fi

        # Check if the TODO still exists in the file (hasn't been resolved)
        if [[ -f "${WORKSPACE_ROOT}/${file_path}" ]]; then
            if ! grep -n "${text}" "${WORKSPACE_ROOT}/${file_path}" >/dev/null 2>&1; then
                log_message "TODO appears to be resolved: ${text}"
                rm -f "${todo_marker}" # Remove old marker
                continue
            fi
        fi

        # Create task for this TODO
        local description="TODO from ${file_path}:${line_num} - ${text}"

        if create_todo_task "${todo_type}" "${description}" "${priority}" "${project}" "${file_path}"; then
            # Mark as processed
            touch "${todo_marker}"
            ((processed_count++))
        else
            log_message "Failed to create task for TODO: ${text}"
        fi

        # Rate limiting - don't overwhelm the system
        sleep 1
    done

    log_message "Processed ${processed_count} new TODOs, skipped ${skipped_count} already processed"
    return 0
}

# Clean up old processed markers (older than 24 hours)
cleanup_old_markers() {
    find "${AGENTS_DIR}" -name "todo_*.processed" -mtime +1 -delete 2>/dev/null || true
}

# Check MCP server availability
check_mcp_server() {
    local response
    response=$(curl -s --max-time 5 "${MCP_URL}/health" 2>/dev/null)

    if [[ $? -eq 0 ]] && echo "${response}" | grep -q '"ok":.*true'; then
        return 0
    else
        log_message "MCP server not available at ${MCP_URL}"
        return 1
    fi
}

# Start MCP server if not running
ensure_mcp_server() {
    if ! check_mcp_server; then
        log_message "Starting MCP server..."

        local mcp_server_script="${AGENTS_DIR}/mcp_server.py"
        if [[ -f ${mcp_server_script} ]]; then
            # Check if python3 and required packages are available
            if command -v python3 &>/dev/null; then
                nohup python3 "${mcp_server_script}" >"${AGENTS_DIR}/mcp_server.log" 2>&1 &
                local mcp_pid=$!
                echo "${mcp_pid}" >"${AGENTS_DIR}/mcp_server.pid"

                # Wait a moment for server to start
                sleep 5

                if check_mcp_server; then
                    log_message "MCP server started successfully (PID: ${mcp_pid})"
                    return 0
                else
                    log_message "Failed to start MCP server"
                    return 1
                fi
            else
                log_message "Python3 not available, cannot start MCP server"
                return 1
            fi
        else
            log_message "MCP server script not found: ${mcp_server_script}"
            return 1
        fi
    fi

    return 0
}

# Main processing loop with autonomous operation
log_message "Starting TODO Processing Agent"
update_status "starting"

# Ensure MCP server is running
if ! ensure_mcp_server; then
    log_message "Cannot start without MCP server, exiting"
    update_status "failed"
    exit 1
fi

# Register with MCP server
register_response=$(curl -s -X POST "${MCP_URL}/register" \
    -H "Content-Type: application/json" \
    -d '{"agent": "agent_todo.sh", "capabilities": ["todo", "task_creation", "scan", "analysis"]}')

if echo "${register_response}" | grep -q '"ok": true'; then
    log_message "Successfully registered with MCP server"
else
    log_message "Failed to register with MCP server: ${register_response}"
fi

update_status "running"

# Main autonomous loop
while true; do
    log_message "Starting autonomous TODO processing cycle"

    # Send heartbeat to MCP server
    curl -s -X POST "${MCP_URL}/heartbeat" \
        -H "Content-Type: application/json" \
        -d '{"agent": "agent_todo.sh"}' >/dev/null 2>&1

    # Scan workspace for new TODOs
    if scan_workspace_todos; then
        log_message "TODO scan completed successfully"

        # Process discovered TODOs
        if process_todos; then
            log_message "TODO processing completed successfully"
        else
            log_message "TODO processing encountered errors"
        fi
    else
        log_message "TODO scanning failed"
    fi

    # Clean up old markers
    cleanup_old_markers

    # Update status
    update_status "running"

    # Exit if running once
    if [[ ${RUN_ONCE} == true ]]; then
        log_message "Run-once mode completed, exiting"
        update_status "completed"
        cleanup
        exit 0
    fi

    log_message "TODO processing cycle completed, sleeping for ${SCAN_INTERVAL} seconds"
    sleep ${SCAN_INTERVAL}
done
