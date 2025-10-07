#!/bin/bash
# Dashboard Server Management Script
# Handles starting, stopping, and monitoring the dashboard server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_FILE="$SCRIPT_DIR/simple_dashboard_server.py"
PID_FILE="$SCRIPT_DIR/dashboard_server.pid"
LOG_FILE="$SCRIPT_DIR/dashboard_server.log"
PORT=8004

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
  echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
  echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Check if server is running
is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid=$(cat "$PID_FILE")
    if ps -p "$pid" >/dev/null 2>&1; then
      return 0
    else
      rm -f "$PID_FILE"
      return 1
    fi
  fi
  return 1
}

# Start the server
start_server() {
  if is_running; then
    log "Dashboard server is already running (PID: $(cat "$PID_FILE"))"
    return 0
  fi

  log "Starting dashboard server..."

  # Kill any process using port 8004
  local existing_pid=$(lsof -ti:$PORT 2>/dev/null)
  if [[ -n "$existing_pid" ]]; then
    warn "Killing existing process on port $PORT (PID: $existing_pid)"
    kill -9 "$existing_pid" 2>/dev/null
    sleep 2
  fi

  # Start server in background
  cd "$SCRIPT_DIR"
  nohup python3 "$SERVER_FILE" >"$LOG_FILE" 2>&1 &
  local pid=$!

  # Save PID
  echo "$pid" >"$PID_FILE"

  # Wait a moment and check if it started successfully
  sleep 3
  if is_running; then
    log "Dashboard server started successfully (PID: $pid)"
    log "Dashboard URL: http://localhost:$PORT/dashboard"
    log "API URL: http://localhost:$PORT/api/dashboard-data"
    log "Log file: $LOG_FILE"
    return 0
  else
    error "Failed to start dashboard server"
    if [[ -f "$LOG_FILE" ]]; then
      echo "Last few lines from log:"
      tail -5 "$LOG_FILE"
    fi
    return 1
  fi
}

# Stop the server
stop_server() {
  if ! is_running; then
    log "Dashboard server is not running"
    return 0
  fi

  local pid=$(cat "$PID_FILE")
  log "Stopping dashboard server (PID: $pid)..."

  kill "$pid" 2>/dev/null
  sleep 2

  # Force kill if still running
  if ps -p "$pid" >/dev/null 2>&1; then
    warn "Force killing server..."
    kill -9 "$pid" 2>/dev/null
    sleep 1
  fi

  rm -f "$PID_FILE"
  log "Dashboard server stopped"
}

# Restart the server
restart_server() {
  log "Restarting dashboard server..."
  stop_server
  sleep 2
  start_server
}

# Show server status
status() {
  if is_running; then
    local pid=$(cat "$PID_FILE")
    log "Dashboard server is running (PID: $pid)"
    log "Dashboard URL: http://localhost:$PORT/dashboard"
    log "API URL: http://localhost:$PORT/api/dashboard-data"

    # Test API endpoint
    if command -v curl >/dev/null 2>&1; then
      log "Testing API endpoint..."
      if curl -s --max-time 5 "http://localhost:$PORT/api/dashboard-data" >/dev/null; then
        log "✅ API endpoint is responding"
      else
        error "❌ API endpoint is not responding"
      fi
    fi
  else
    warn "Dashboard server is not running"
  fi
}

# Show help
show_help() {
  echo "Dashboard Server Management Script"
  echo ""
  echo "Usage: $0 [COMMAND]"
  echo ""
  echo "Commands:"
  echo "  start     Start the dashboard server"
  echo "  stop      Stop the dashboard server"
  echo "  restart   Restart the dashboard server"
  echo "  status    Show server status"
  echo "  logs      Show recent logs"
  echo "  help      Show this help message"
  echo ""
}

# Show logs
show_logs() {
  if [[ -f "$LOG_FILE" ]]; then
    echo "Recent dashboard server logs:"
    echo "================================"
    tail -20 "$LOG_FILE"
  else
    warn "No log file found at $LOG_FILE"
  fi
}

# Main script logic
case "${1:-help}" in
start)
  start_server
  ;;
stop)
  stop_server
  ;;
restart)
  restart_server
  ;;
status)
  status
  ;;
logs)
  show_logs
  ;;
help | --help | -h)
  show_help
  ;;
*)
  error "Unknown command: $1"
  show_help
  exit 1
  ;;
esac
