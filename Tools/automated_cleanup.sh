#!/bin/bash

# Automated Duplicate File Cleanup Script
# Quantum Workspace - Intelligent Duplicate Removal

# set -e  # Exit on any error - commented out for robustness

# Configuration
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
LOG_FILE="$WORKSPACE_ROOT/cleanup_log_$(date +%Y%m%d_%H%M%S).txt"
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Progress tracking
TOTAL_FILES=0
REMOVED_FILES=0
SPACE_SAVED=0

# Function to get file size in bytes
get_file_size() {
  if [[ -f "$1" ]]; then
    stat -f%z "$1" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Function to format size
format_size() {
  local size=$1
  if ((size > 1073741824)); then
    echo "$((size / 1073741824))GB"
  elif ((size > 1048576)); then
    echo "$((size / 1048576))MB"
  elif ((size > 1024)); then
    echo "$((size / 1024))KB"
  else
    echo "${size}B"
  fi
}

# Function to safely remove file
safe_remove() {
  local file="$1"
  local size
  size=$(get_file_size "$file")

  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}DRY RUN: Would remove $file ($(format_size "${size}"))${NC}"
    ((SPACE_SAVED += size))
    ((REMOVED_FILES++))
  else
    if rm -f "${file}" 2>/dev/null; then
      echo -e "${GREEN}✓ Removed${ $fi}le ($(format_size "$size"))${NC}"
      ((SPACE_SAVED += size))
      ((REMOVED_FILES++))
    else
      echo -e "${RED}✗ Failed to remove: $file${NC}"
      log "Failed to remove: $file"
    fi
  fi
}

# Function to clean timestamped files (keep only most recent N)
clean_timestamped_files() {
  local pattern="$1"
  local keep_count="${2:-5}"
  local description="$3"

  log "Cleaning $description files (keeping $keep_count most recent)..."

  # Find files matching pattern, sort by modification time (newest first)
  local files=()
  while IFS= read -r file; do
    [[ -n "$file" ]] && files+=("$file")
  done < <(find "$WORKSPACE_ROOT" -name "$pattern" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null)

  if [[ ${#files[@]} -gt $keep_count ]]; then
    local to_remove=$((${#files[@]} - keep_count))
    log "Found ${#files[@]} files, will remove $to_remove oldest"

    for ((i = keep_count; i < ${#files[@]}; i++)); do
      safe_remove "${files[$i]}"
    done
  else
    log "Found ${#files[@]} files (≤ $keep_count), keeping all"
  fi
}

# Function to clean duplicate files by pattern
clean_duplicate_pattern() {
  local pattern="$1"
  local description="$2"

  log "Cleaning $description files..."

  local files=()
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(find "$WORKSPACE_ROOT" -name "$pattern" -type f -print0 2>/dev/null)

  for file in "${files[@]}"; do
    # Skip if file doesn't exist
    [[ ! -f "$file" ]] && continue

    # Check if this is a duplicate by looking for similar files
    local base_name="${file%.*}"
    local extension="${file##*.}"

    # Look for similar files without the pattern suffix
    local similar_files=()
    if [[ "$pattern" == *"_old"* ]]; then
      while IFS= read -r -d '' similar_file; do
        similar_files+=("$similar_file")
      done < <(find "$(dirname "$file")" -name "${base_name%_old}.$extension" -print0 2>/dev/null)
    elif [[ "$pattern" == *"_backup"* ]]; then
      while IFS= read -r -d '' similar_file; do
        similar_files+=("$similar_file")
      done < <(find "$(dirname "$file")" -name "${base_name%_backup}.$extension" -print0 2>/dev/null)
    elif [[ "$pattern" == *"_duplicate"* ]]; then
      while IFS= read -r -d '' similar_file; do
        similar_files+=("$similar_file")
      done < <(find "$(dirname "$file")" -name "${base_name%_duplicate}.$extension" -print0 2>/dev/null)
    fi

    # If we found a similar file, check which one is newer
    if [[ ${#similar_files[@]} -gt 0 ]]; then
      local similar_file="${similar_files[0]}"
      if [[ "$file" -ot "$similar_file" ]]; then
        # Original file is newer, remove the duplicate
        safe_remove "$file"
      else
        log "Keeping newer duplicate: $file"
      fi
    else
      # No similar file found, might be safe to remove if it's clearly a duplicate
      if [[ "$file" == *"_old"* ]] || [[ "$file" == *"_backup"* ]] || [[ "$file" == *"_duplicate"* ]]; then
        safe_remove "$file"
      fi
    fi
  done
}

# Main cleanup function
main_cleanup() {
  echo -e "${BLUE}🚀 Starting Automated Duplicate File Cleanup${NC}"
  echo -e "${BLUE}Workspace: $WORKSPACE_ROOT${NC}"
  echo -e "${BLUE}Log file: $LOG_FILE${NC}"
  echo

  log "=== Automated Duplicate File Cleanup Started ==="
  log "Workspace: $WORKSPACE_ROOT"
  log "Dry run: $DRY_RUN"

  # Count total files before cleanup
  TOTAL_FILES=$(find "$WORKSPACE_ROOT" -type f 2>/dev/null | wc -l)
  log "Total files before cleanup: $TOTAL_FILES"

  # 1. Clean timestamped status files (keep only 10 most recent)
  clean_timestamped_files "*orchestrator_status_*.md" 10 "orchestrator status"
  clean_timestamped_files "*performance_report_*.md" 5 "performance reports"
  clean_timestamped_files "*dashboard_report_*.md" 5 "dashboard reports"
  clean_timestamped_files "*knowledge_report_*.md" 3 "knowledge reports"

  # 2. Clean duplicate files by pattern
  clean_duplicate_pattern "*_old*" "old files"
  clean_duplicate_pattern "*_backup*" "backup files"
  clean_duplicate_pattern "*_duplicate*" "duplicate files"
  clean_duplicate_pattern "*_bak*" "bak files"
  clean_duplicate_pattern "*_copy*" "copy files"
  clean_duplicate_pattern "*_temp*" "temp files"
  clean_duplicate_pattern "*_archive*" "archive files"

  # 3. Clean log files (keep only recent ones)
  clean_timestamped_files "*setup_log_*.txt" 3 "setup logs"
  clean_timestamped_files "*_log_*.txt" 5 "general logs"

  # 4. Clean enhanced/updated files (keep the latest version)
  log "Cleaning enhanced/updated files..."
  local enhanced_files=()
  while IFS= read -r -d '' file; do
    enhanced_files+=("$file")
  done < <(find "$WORKSPACE_ROOT" -name "*_enhanced*" -type f -print0 2>/dev/null)
  for file in "${enhanced_files[@]}"; do
    local base_name="${file%_enhanced*}"
    local extension="${file##*.}"
    local original_file="${base_name}.${extension}"

    if [[ -f "$original_file" ]]; then
      # Compare modification times
      if [[ "$file" -nt "$original_file" ]]; then
        # Enhanced file is newer, remove original
        safe_remove "$original_file"
      else
        # Original is newer, remove enhanced
        safe_remove "$file"
      fi
    fi
  done

  # Summary
  echo
  echo -e "${GREEN}=== Cleanup Summary ===${NC}"
  log "=== Cleanup Summary ==="
  log "Total files processed: ${TOTAL_FILES}"
  log "Files removed: ${REMOVED_FILES}"
  log "Space saved: $(format_size "$SPACE_SAVED")"

  echo -e "${GREEN}Files removed: ${REMOVED_FILES}${NC}"
  echo -e "${GREEN}Space saved: $(format_size "$SPACE_SAVED")${NC}"
  echo -e "${GREEN}Log saved to: ${LOG_FILE}${NC}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    echo -e "${YELLOW}This was a DRY RUN - no files were actually removed${NC}"
    echo -e "${YELLOW}Run with --execute to perform actual cleanup${NC}"
  fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --execute)
    DRY_RUN=false
    shift
    ;;
  --help)
    echo "Usage: $0 [--dry-run] [--execute] [--help]"
    echo "  --dry-run    Show what would be removed without actually removing"
    echo "  --execute    Actually perform the cleanup (default)"
    echo "  --help       Show this help"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage information"
    exit 1
    ;;
  esac
done

# Run the cleanup
main_cleanup
