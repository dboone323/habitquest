#!/bin/bash

# Quantum Workspace - Automated Retention Policy Manager
# Implements 5-backup rule to prevent disk space issues
# Cleans up logs, backups, and temporary files across all systems

set -e

# Configuration
MAX_BACKUPS=5
MAX_LOGS=5
MAX_REPORTS=5
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
LOG_FILE="$WORKSPACE_ROOT/retention_policy.log"

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Cleanup function for directories with timestamped files
cleanup_timestamped_files() {
  local dir="$1"
  local pattern="$2"
  local max_files="$3"
  local description="$4"

  if [[ ! -d "$dir" ]] || [[ "$dir" == *"/Archive"* ]]; then
    return
  fi

  # Find files matching pattern, sort by modification time (newest first)
  local find_output
  find_output=$(find "$dir" -name "$pattern" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null || true)
  local files=()
  while IFS= read -r -d '' file; do
    files+=("$file")
  done <<<"$find_output"

  if [[ ${#files[@]} -gt $max_files ]]; then
    local files_to_remove=$((${#files[@]} - $max_files))
    log "Cleaning up $files_to_remove old $description files in $dir"

    # Remove oldest files
    for ((i = max_files; i < ${#files[@]}; i++)); do
      rm -f "${files[$i]}"
      log "Removed: ${files[$i]}"
    done
  fi
}

# Cleanup function for directories with timestamped subdirectories
cleanup_timestamped_dirs() {
  local dir="$1"
  local pattern="$2"
  local max_dirs="$3"
  local description="$4"

  if [[ ! -d "$dir" ]] || [[ "$dir" == *"/Archive"* ]]; then
    return
  fi

  # Find directories matching pattern, sort by modification time (newest first)
  local find_output
  find_output=$(find "$dir" -name "$pattern" -type d -print0 2>/dev/null | xargs -0 ls -td 2>/dev/null || true)
  local dirs=()
  while IFS= read -r -d '' dir_path; do
    dirs+=("$dir_path")
  done <<<"$find_output"

  if [[ ${#dirs[@]} -gt $max_dirs ]]; then
    local dirs_to_remove=$((${#dirs[@]} - $max_dirs))
    log "Cleaning up $dirs_to_remove old $description directories in $dir"

    # Remove oldest directories
    for ((i = max_dirs; i < ${#dirs[@]}; i++)); do
      rm -rf "${dirs[$i]}"
      log "Removed directory: ${dirs[$i]}"
    done
  fi
}

# Main cleanup function
main() {
  log "Starting Quantum Workspace Retention Policy Cleanup"
  log "Maximum backups/logs/reports retained: $MAX_BACKUPS"

  # 1. Agent System Cleanup
  log "=== AGENT SYSTEM CLEANUP ==="

  # Agent backups
  cleanup_timestamped_dirs "$WORKSPACE_ROOT/Tools/Automation/agents/backups" "*" $MAX_BACKUPS "agent backup"

  # Agent logs
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation/agents" "agent_*.log" $MAX_LOGS "agent log"
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation/agents" "*_agent.log" $MAX_LOGS "agent log"
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation/agents" "*.log" $MAX_LOGS "general log"

  # Performance reports (keep only recent ones)
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation/agents" "PERFORMANCE_REPORT_*.md" $MAX_REPORTS "performance report"

  # Orchestrator status files
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation/agents" "orchestrator_status_*.md" $MAX_REPORTS "orchestrator status"

  # Clean up temporary processing files
  if [[ -d "$WORKSPACE_ROOT/Tools/Automation/agents" ]]; then
    log "Cleaning up temporary processing files"
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "todo_*.processing" -type f -delete 2>/dev/null || true
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "*.log.old" -type f -delete 2>/dev/null || true
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "agent_status.json.corrupt_*" -type f -delete 2>/dev/null || true
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "agent_status.json.shutdown_*" -type f -delete 2>/dev/null || true
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "*.tmp*" -type f -delete 2>/dev/null || true
    find "$WORKSPACE_ROOT/Tools/Automation/agents" -name "*.bak*" -type f -delete 2>/dev/null || true
  fi

  # 2. MCP System Cleanup
  log "=== MCP SYSTEM CLEANUP ==="

  # MCP logs
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation" "mcp_*.log" $MAX_LOGS "MCP log"
  cleanup_timestamped_files "$WORKSPACE_ROOT/Tools/Automation" "*mcp*.log" $MAX_LOGS "MCP log"

  # 3. Workflow System Cleanup
  log "=== WORKFLOW SYSTEM CLEANUP ==="

  # GitHub workflow logs (if any)
  cleanup_timestamped_files "$WORKSPACE_ROOT/.github" "*.log" $MAX_LOGS "workflow log"

  # 4. General System Cleanup
  log "=== GENERAL SYSTEM CLEANUP ==="

  # Root level logs
  cleanup_timestamped_files "$WORKSPACE_ROOT" "*.log" $MAX_LOGS "root log"

  # Backup directories
  cleanup_timestamped_dirs "$WORKSPACE_ROOT/.backups" "*" $MAX_BACKUPS "system backup"
  cleanup_timestamped_dirs "$WORKSPACE_ROOT/.autofix_backups" "*" $MAX_BACKUPS "autofix backup"

  # Metrics cleanup (keep recent analytics)
  if [[ -d "$WORKSPACE_ROOT/.metrics" ]]; then
    cleanup_timestamped_files "$WORKSPACE_ROOT/.metrics" "*.json" $MAX_REPORTS "metrics file"
    cleanup_timestamped_files "$WORKSPACE_ROOT/.metrics" "*.md" $MAX_REPORTS "metrics report"
    # Clean up analytics reports specifically
    cleanup_timestamped_files "$WORKSPACE_ROOT/.metrics/reports" "analytics_*.json" $MAX_REPORTS "analytics report"
  fi

  # AI reviews cleanup
  cleanup_timestamped_files "$WORKSPACE_ROOT/ai_reviews" "*.md" $MAX_REPORTS "AI review"

  # Communication files
  cleanup_timestamped_files "$WORKSPACE_ROOT/communication" "*" $MAX_LOGS "communication file"

  # Clean up cache directories and temp files
  log "Cleaning up cache directories and temp files"
  find "$WORKSPACE_ROOT" -type d \( -name "__pycache__" -o -name ".pytest_cache" -o -name ".cache" \) -exec rm -rf {} + 2>/dev/null || true
  find "$WORKSPACE_ROOT/Tools/Automation" -name "*.bak*" -o -name "*.backup*" -o -name "*.tmp*" -type f -delete 2>/dev/null || true

  # 5. Archive old files (move to Archive if they exceed retention)
  log "=== ARCHIVE MANAGEMENT ==="

  # Move very old files to Archive directory
  local archive_threshold_days=30
  local old_files
  old_files=$(find "$WORKSPACE_ROOT" -type d -name "Archive" -prune -o \( -name "*.log" -o -name "*.out" -o -name "*_report_*.md" \) -type f -mtime +$archive_threshold_days -print 2>/dev/null || true)

  if [[ -n "$old_files" ]]; then
    log "Archiving $(echo "$old_files" | wc -l) very old files"
    echo "$old_files" | while read -r file; do
      if [[ -f "$file" ]]; then
        relative_path="${file#$WORKSPACE_ROOT/}"
        archive_path="$WORKSPACE_ROOT/Archive/$(dirname "$relative_path")"
        mkdir -p "$archive_path"
        mv "$file" "$archive_path/"
        log "Archived: $relative_path"
      fi
    done
  fi

  # 6. Disk space check
  log "=== DISK SPACE CHECK ==="
  local disk_usage
  disk_usage=$(du -sh "$WORKSPACE_ROOT" 2>/dev/null | cut -f1)
  log "Current workspace size: $disk_usage"

  # Check if we need to compress old archives
  if [[ -d "$WORKSPACE_ROOT/Archive" ]]; then
    local archive_size
    archive_size=$(du -sh "$WORKSPACE_ROOT/Archive" 2>/dev/null | cut -f1)
    log "Archive size: $archive_size"

    # If archive is over 500MB, compress it
    local archive_bytes
    archive_bytes=$(du -b "$WORKSPACE_ROOT/Archive" 2>/dev/null | cut -f1)
    if [[ $archive_bytes -gt 524288000 ]]; then # 500MB
      log "Compressing large archive to save space"
      cd "$WORKSPACE_ROOT"
      tar -czf "Archive_$(date +%Y%m%d_%H%M%S).tar.gz" Archive/
      rm -rf Archive/
      mkdir -p Archive/
      log "Archive compressed and cleaned"
    fi
  fi

  log "Retention policy cleanup completed successfully"
}

# Run main function
main "$@"
