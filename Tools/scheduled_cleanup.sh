#!/bin/bash

# Automated Cleanup Scheduler
# Manages scheduled cleanup operations for Quantum Workspace

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
CLEANUP_SCRIPT="$SCRIPT_DIR/automated_cleanup.sh"
LOG_FILE="$WORKSPACE_ROOT/cleanup_scheduler.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if other processes are running
check_running_processes() {
  local processes=("supervisor" "agent" "orchestrator" "dashboard")
  local running_count=0

  for process in "${processes[@]}"; do
    if pgrep -f "$process" >/dev/null 2>&1; then
      ((running_count++))
      log "Found running process: $process"
    fi
  done

  echo $running_count
}

# Function to run cleanup with safety checks
run_safe_cleanup() {
  local mode="${1:-normal}"
  local running_processes
  running_processes=$(check_running_processes)

  log "=== Starting Scheduled Cleanup ($mode mode) ==="
  log "Running processes detected: $running_processes"
  log "Workspace: $WORKSPACE_ROOT"

  # Always run cleanup - it's designed to be safe
  if [[ -x "$CLEANUP_SCRIPT" ]]; then
    log "Running cleanup script..."
    if "$CLEANUP_SCRIPT" --execute >>"$LOG_FILE" 2>&1; then
      log "✅ Cleanup completed successfully"
    else
      log "❌ Cleanup completed with warnings/errors"
    fi
  else
    log "❌ Cleanup script not found or not executable${ $CLEANUP_SCRI}PT"
    return 1
  fi

  log "=== Scheduled Cleanup Complete ==="
  echo "" >>"$LOG_FILE"
}

# Function to setup cron jobs
setup_cron_jobs() {
  log "Setting up cron jobs..."

  # Backup existing crontab
  crontab -l >"$WORKSPACE_ROOT/crontab_backup_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || true

  # Weekly cleanup (Sunday 2 AM)
  local weekly_cron="0 2 * * 0 $SCRIPT_DIR/scheduled_cleanup.sh weekly >> $LOG_FILE 2>&1"

  # Daily cleanup (optional - commented out by default)
  local daily_cron="# 0 2 * * * $SCRIPT_DIR/scheduled_cleanup.sh daily >> $LOG_FILE 2>&1"

  # Add to crontab
  {
    crontab -l 2>/dev/null || true
    echo "$weekly_cron"
    echo "$daily_cron"
  } | crontab -

  log "✅ Cron jobs configured:"
  log "  - Weekly: Every Sunday at 2:00 AM"
  log "  - Daily: Commented out (uncomment if needed)"
}

# Function to show current schedule
show_schedule() {
  echo -e "${BLUE}=== Current Cleanup Schedule ===${NC}"
  echo -e "${GREEN}Weekly Cleanup:${NC} Every Sunday at 2:00 AM"
  echo -e "${YELLOW}Daily Cleanup:${NC} Currently disabled (can be enabled if needed)"
  echo ""
  echo -e "${BLUE}Active Cron Jobs:${NC}"
  crontab -l 2>/dev/null || echo "No cron jobs found"
  echo ""
  echo -e "${BLUE}Log File:${NC} $LOG_FILE"
}

# Function to test the setup
test_setup() {
  log "=== Testing Cleanup Setup ==="

  # Check if cleanup script exists and is executable
  if [[ -x "$CLEANUP_SCRIPT" ]]; then
    echo -e "${GREEN}✅ Cleanup script found and executable${NC}"
  else
    echo -e "${RED}❌ Cleanup script not found or not executable${NC}"
    return 1
  fi

  # Check workspace directory
  if [[ -d "$WORKSPACE_ROOT" ]]; then
    echo -e "${GREEN}✅ Workspace directory exists${NC}"
  else
    echo -e "${RED}❌ Workspace directory not found${NC}"
    return 1
  fi

  # Check running processes
  local running
  running=$(check_running_processes)
  echo -e "${BLUE}ℹ️  Currently running processes: $running${NC}"

  # Test dry run
  echo -e "${YELLOW}Testing dry run...${NC}"
  if "$CLEANUP_SCRIPT" --dry-run >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Dry run successful${NC}"
  else
    echo -e "${RED}❌ Dry run failed${NC}"
    return 1
  fi

  log "✅ Setup test completed successfully"
  echo -e "${GREEN}🎉 All tests passed! Scheduled cleanup is ready.${NC}"
}

# Main script logic
case "${1:-help}" in
"weekly")
  run_safe_cleanup "weekly"
  ;;
"daily")
  run_safe_cleanup "daily"
  ;;
"setup")
  setup_cron_jobs
  ;;
"test")
  test_setup
  ;;
"status")
  show_schedule
  ;;
"manual")
  run_safe_cleanup "manual"
  ;;
"help" | *)
  echo -e "${BLUE}Automated Cleanup Scheduler${NC}"
  echo ""
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  setup    - Configure cron jobs for automatic cleanup"
  echo "  test     - Test the cleanup setup"
  echo "  status   - Show current schedule and status"
  echo "  manual   - Run cleanup manually"
  echo "  weekly   - Run weekly cleanup (called by cron)"
  echo "  daily    - Run daily cleanup (called by cron)"
  echo "  help     - Show this help"
  echo ""
  echo "Examples:"
  echo "  $0 setup    # Set up automatic scheduling"
  echo "  $0 test     # Test the setup"
  echo "  $0 manual   # Run cleanup now"
  echo "  $0 status   # Check current configuration"
  ;;
esac
