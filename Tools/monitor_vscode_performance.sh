#!/bin/bash

# VS Code Performance Monitor
# Monitors VS Code performance and workspace enumeration times

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
PERFORMANCE_LOG="${LOG_DIR}/vscode_performance_$(date +%Y%m%d_%H%M%S).log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${PERFORMANCE_LOG}"
}

# Function to get system metrics
get_system_metrics() {
  local cpu_usage
  cpu_usage=$(ps aux | awk 'BEGIN {sum=0} {sum += $3} END {print sum}')

  local mem_usage
  mem_usage=$(ps aux | awk 'BEGIN {sum=0} {sum += $4} END {print sum}')

  local disk_usage
  disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

  echo "CPU: ${cpu_usage}%, Memory: ${mem_usage}%, Disk: ${disk_usage}%"
}

# Function to monitor VS Code processes
monitor_vscode() {
  local vscode_pids
  vscode_pids=$(pgrep -f "Visual Studio Code" | tr '\n' ' ')

  local vscode_count
  vscode_count=$(echo "${vscode_pids}" | wc -w)

  if [[ "${vscode_count}" -gt 0 ]]; then
    log "VS Code processes found: ${vscode_count} (PIDs: ${vscode_pids})"

    # Get memory usage for VS Code processes
    local total_mem=0
    for pid in ${vscode_pids}; do
      if [[ -n "${pid}" ]] && [[ "${pid}" != " " ]]; then
        local mem
        mem=$(ps -p "${pid}" -o pmem= 2>/dev/null | tr -d ' ')
        if [[ -n "${mem}" ]]; then
          total_mem=$(echo "${total_mem} + ${mem}" | bc 2>/dev/null || echo "${total_mem}")
        fi
      fi
    done

    log "VS Code total memory usage: ${total_mem}%"
  else
    log "No VS Code processes found"
  fi
}

# Function to check workspace file count
check_workspace_files() {
  local workspace_root="/Users/danielstevens/Desktop/Quantum-workspace"

  log "Analyzing workspace structure..."

  # Count total files
  local total_files
  total_files=$(find "${workspace_root}" -type f 2>/dev/null | wc -l)
  log "Total files in workspace: ${total_files}"

  # Count files by type
  local swift_files
  swift_files=$(find "${workspace_root}" -name "*.swift" -type f 2>/dev/null | wc -l)

  local py_files
  py_files=$(find "${workspace_root}" -name "*.py" -type f 2>/dev/null | wc -l)

  local js_files
  js_files=$(find "${workspace_root}" -name "*.js" -type f 2>/dev/null | wc -l)

  local md_files
  md_files=$(find "${workspace_root}" -name "*.md" -type f 2>/dev/null | wc -l)

  local log_files
  log_files=$(find "${workspace_root}" -name "*.log" -type f 2>/dev/null | wc -l)

  log "File breakdown:"
  log "  Swift files: ${swift_files}"
  log "  Python files: ${py_files}"
  log "  JavaScript files: ${js_files}"
  log "  Markdown files: ${md_files}"
  log "  Log files: ${log_files}"

  # Check for large directories that might slow down indexing
  log "Checking for potentially problematic directories:"
  find "${workspace_root}" -type d \( -name "node_modules" -o -name ".git" -o -name "build" -o -name "DerivedData" -o -name "xcuserdata" \) 2>/dev/null | while read -r dir; do
    local file_count
    file_count=$(find "${dir}" -type f 2>/dev/null | wc -l)
    if [[ "${file_count}" -gt 100 ]]; then
      log "  Large directory: ${dir} (${file_count} files)"
    fi
  done
}

# Function to test file enumeration performance
test_enumeration_performance() {
  local workspace_root="/Users/danielstevens/Desktop/Quantum-workspace"

  local test_start
  test_start=$(date +%s.%3N)

  log "Testing file enumeration performance..."

  # Time a typical file enumeration operation
  local file_list
  file_list=$(find "${workspace_root}" -type f -name "*.swift" -o -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null)

  local file_count
  file_count=$(echo "${file_list}" | wc -l)

  local test_end
  test_end=$(date +%s.%3N)

  local duration
  duration=$(echo "${test_end} - ${test_start}" | bc 2>/dev/null)
  log "File enumeration test completed in ${duration}s for ${file_count} source files"
}

# Main monitoring function
main() {
  log "=== VS Code Performance Monitor Started ==="
  log "System metrics: $(get_system_metrics)"

  monitor_vscode
  check_workspace_files
  test_enumeration_performance

  log "=== Performance Monitor Complete ==="
  log "Log saved to: ${PERFORMANCE_LOG}"
}

# Run the monitor
main "$@"
