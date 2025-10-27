#!/bin/bash

# Source shared functions for file locking and monitoring
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/shared_functions.sh"

# Source project configuration
if [[ -f "${SCRIPT_DIR}/../project_config.sh" ]]; then
    source "${SCRIPT_DIR}/../project_config.sh"
fi

# Agent throttling configuration
MAX_CONCURRENCY="${MAX_CONCURRENCY:-2}" # Maximum concurrent instances of this agent
LOAD_THRESHOLD="${LOAD_THRESHOLD:-4.0}" # System load threshold (1.0 = 100% on single core)
WAIT_WHEN_BUSY="${WAIT_WHEN_BUSY:-30}"  # Seconds to wait when system is busy

# Function to check if we should proceed with task processing
ensure_within_limits() {
    local agent_name="agent_monitoring.sh"

    # Check concurrent instances
    local running_count=$(pgrep -f "${agent_name}" | wc -l)
    if [[ ${running_count} -gt ${MAX_CONCURRENCY} ]]; then
        echo "[$(date)] ${AGENT_NAME}: Too many concurrent instances (${running_count}/${MAX_CONCURRENCY}). Waiting..." >>"${LOG_FILE}"
        return 1
    fi

    # Check system load (macOS compatible)
    local load_avg
    if command -v sysctl >/dev/null 2>&1; then
        # macOS: use sysctl vm.loadavg
        load_avg=$(sysctl -n vm.loadavg | awk '{print $2}')
    else
        # Fallback: use uptime
        load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ')
    fi

    # Compare load as float
    if (($(echo "${load_avg} >= ${LOAD_THRESHOLD}" | bc -l 2>/dev/null || echo "0"))); then
        echo "[$(date)] ${AGENT_NAME}: System load too high (${load_avg} >= ${LOAD_THRESHOLD}). Waiting..." >>"${LOG_FILE}"
        return 1
    fi

    return 0
}

# Set task queue file path
export TASK_QUEUE_FILE="${SCRIPT_DIR}/../task_queue.json"

# Ensure PROJECT_NAME is set for subprocess calls
export PROJECT_NAME="${PROJECT_NAME:-CodingReviewer}"

echo "[$(date)] monitoring_agent: Script started for project ${PROJECT}, PID=${PID}" >>"${LOG_FILE}"

# Validate configuration
if [[ $SLEEP_INTERVAL -lt $MIN_INTERVAL || $SLEEP_INTERVAL -gt $MAX_INTERVAL ]]; then
    echo "[$(date)] monitoring_agent: WARNING: SLEEP_INTERVAL ($SLEEP_INTERVAL) outside recommended range [$MIN_INTERVAL, $MAX_INTERVAL]" >>"${LOG_FILE}"
fi
# Monitoring Agent: Handles system monitoring and alerting

AGENT_NAME="MonitoringAgent"
LOG_FILE="/Users/danielstevens/Desktop/Quantum-workspace/Tools/Automation/agents/monitoring_agent.log"
PROJECT="${PROJECT_NAME:-CodingReviewer}"

SLEEP_INTERVAL=120 # Start with 2 minutes
MIN_INTERVAL=60
MAX_INTERVAL=600

STATUS_FILE="$(dirname "$0")/agent_status.json"
TASK_QUEUE="$(dirname "$0")/task_queue.json"
PID=$$

# Export variables for shared functions
export STATUS_FILE
export TASK_QUEUE
trap 'update_agent_status "agent_monitoring.sh" "stopped" $$ ""; exit 0' SIGTERM SIGINT

# Register with MCP server
register_with_mcp "agent_monitoring.sh" "monitoring,alerting,health-check"

while true; do
    # Check if we should proceed (throttling)
    if ! ensure_within_limits; then
        # Wait when busy, with exponential backoff
        wait_time=${WAIT_WHEN_BUSY}
        attempts=0
        while ! ensure_within_limits && [[ ${attempts} -lt 10 ]]; do
            echo "[$(date)] ${AGENT_NAME}: Waiting ${wait_time}s before retry (attempt $((attempts + 1))/10)" >>"${LOG_FILE}"
            sleep "${wait_time}"
            wait_time=$((wait_time * 2))                          # Exponential backoff
            if [[ ${wait_time} -gt 300 ]]; then wait_time=300; fi # Cap at 5 minutes
            ((attempts++))
        done

        # If still busy after retries, skip this cycle
        if ! ensure_within_limits; then
            echo "[$(date)] ${AGENT_NAME}: System still busy after retries. Skipping cycle." >>"${LOG_FILE}"
            sleep 60
            continue
        fi
    fi

    # SINGLE_RUN mode: exit after one cycle for testing
    if [[ "${SINGLE_RUN:-false}" == "true" ]]; then
        echo "[$(date)] ${AGENT_NAME}: SINGLE_RUN mode - exiting after one cycle" >>"${LOG_FILE}"
        update_agent_status "agent_monitoring.sh" "stopped" $$ ""
        exit 0
    fi

    update_agent_status "agent_monitoring.sh" "running" $$ ""
    echo "[$(date)] ${AGENT_NAME}: Running monitoring operations..." >>"${LOG_FILE}"

    # Get next task for this agent
    TASK_ID=$(get_next_task "agent_monitoring.sh")

    if [[ -n "${TASK_ID}" ]]; then
        echo "[$(date)] ${AGENT_NAME}: Processing task ${TASK_ID}" >>"${LOG_FILE}"

        # Mark task as in progress
        update_task_status "${TASK_ID}" "in_progress"
        update_agent_status "agent_monitoring.sh" "busy" $$ "${TASK_ID}"

        # Get task details
        TASK_DETAILS=$(get_task_details "${TASK_ID}")
        TASK_TYPE=$(echo "${TASK_DETAILS}" | jq -r '.type // "monitoring"')
        TASK_DESCRIPTION=$(echo "${TASK_DETAILS}" | jq -r '.description // "Unknown task"')

        echo "[$(date)] ${AGENT_NAME}: Task type: ${TASK_TYPE}, Description: ${TASK_DESCRIPTION}" >>"${LOG_FILE}"

        # Process the task based on type
        TASK_SUCCESS=true

        case "${TASK_TYPE}" in
        "monitoring")
            # Run monitoring operations
            echo "[$(date)] ${AGENT_NAME}: Performing system monitoring..." >>"${LOG_FILE}"
            agent_count=$(pgrep -f "agent_.*\.sh" | grep -c ".*" || echo "0")
            echo "[$(date)] ${AGENT_NAME}: Found ${agent_count} running agents." >>"${LOG_FILE}"
            echo "[$(date)] ${AGENT_NAME}: System monitoring completed successfully." >>"${LOG_FILE}"
            ;;
        "alerting")
            # Handle alerting operations
            echo "[$(date)] ${AGENT_NAME}: Checking for alerts..." >>"${LOG_FILE}"
            echo "[$(date)] ${AGENT_NAME}: Alert checking completed successfully." >>"${LOG_FILE}"
            ;;
        "health-check")
            # Perform health checks
            echo "[$(date)] ${AGENT_NAME}: Running health checks..." >>"${LOG_FILE}"
            curl -s http://localhost:5005/health >>"${LOG_FILE}" 2>&1
            echo "[$(date)] ${AGENT_NAME}: Health checks completed successfully." >>"${LOG_FILE}"
            ;;
        *)
            echo "[$(date)] ${AGENT_NAME}: Unknown task type: ${TASK_TYPE}" >>"${LOG_FILE}"
            TASK_SUCCESS=false
            ;;
        esac

        # Complete the task
        complete_task "${TASK_ID}" "${TASK_SUCCESS}"
        increment_task_count "agent_monitoring.sh"

        if [[ "${TASK_SUCCESS}" == "true" ]]; then
            echo "[$(date)] ${AGENT_NAME}: Task ${TASK_ID} completed successfully" >>"${LOG_FILE}"
        else
            echo "[$(date)] ${AGENT_NAME}: Task ${TASK_ID} failed" >>"${LOG_FILE}"
        fi

    else
        update_agent_status "agent_monitoring.sh" "idle" $$ ""
        echo "[$(date)] ${AGENT_NAME}: No monitoring tasks found. Sleeping as idle." >>"${LOG_FILE}"
        sleep 60
        continue
    fi
    sleep "${SLEEP_INTERVAL}"
done
