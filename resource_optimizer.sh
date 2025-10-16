#!/bin/bash

# Resource Management Script for Quantum Workspace
# Optimizes storage and runtime resource usage

set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${WORKSPACE_DIR}/Tools/Automation/agents/backups"
VENV_DIR="${WORKSPACE_DIR}/.venv"

echo "🧹 Quantum Workspace Resource Optimization"
echo "=========================================="

# Function to clean up old backups
cleanup_backups() {
    echo "📦 Cleaning up backup directories..."

    cd "${BACKUP_DIR}"

    # Count total backups (both compressed and uncompressed)
    total_backups=$(find . -maxdepth 1 \( -type d -o -name "*.tar.gz" \) | wc -l)
    echo "Found ${total_backups} backup items"

    # Keep only the 10 most recent uncompressed directories
    echo "Keeping only the 10 most recent backups..."
    # Get list of uncompressed directories sorted by modification time (oldest first), skip first 10
    find . -maxdepth 1 -type d -name "CodingReviewer_*" -print0 | xargs -0 ls -t | tail -n +11 | while read -r dir; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo "Removed old backup: $dir"
        fi
    done

    # Compress remaining uncompressed backups older than 1 day
    echo "Compressing backups older than 1 day..."
    find . -maxdepth 1 -type d -name "CodingReviewer_*" -mtime +1 | while read -r dir; do
        if [[ -d "$dir" ]]; then
            tar -czf "${dir}.tar.gz" -C . "$(basename "$dir")" && rm -rf "$dir"
            echo "Compressed: $(basename "$dir")"
        fi
    done

    # Remove compressed backups older than 30 days
    echo "Removing compressed backups older than 30 days..."
    find . -maxdepth 1 -name "CodingReviewer_*.tar.gz" -mtime +30 -delete

    # Show final counts
    remaining_dirs=$(find . -maxdepth 1 -type d -name "CodingReviewer_*" | wc -l)
    remaining_compressed=$(find . -maxdepth 1 -name "CodingReviewer_*.tar.gz" | wc -l)
    echo "Remaining uncompressed backups: ${remaining_dirs}"
    echo "Remaining compressed backups: ${remaining_compressed}"
}

# Function to optimize Python environment usage
optimize_python_env() {
    echo "🐍 Optimizing Python environment usage..."

    # Check if venv exists and is properly configured
    if [[ -d "${VENV_DIR}" ]]; then
        echo "✅ Virtual environment found at ${VENV_DIR}"

        # Ensure venv is activated for Python processes
        export VIRTUAL_ENV="${VENV_DIR}"
        export PATH="${VENV_DIR}/bin:$PATH"

        # Check for any system Python processes that should use venv
        python_processes=$(ps aux | grep python | grep -v grep | grep -v venv | wc -l)
        if [[ $python_processes -gt 0 ]]; then
            echo "⚠️  Found ${python_processes} Python processes not using venv"
            echo "Consider updating agent scripts to use: source ${VENV_DIR}/bin/activate"
        fi
    else
        echo "❌ Virtual environment not found"
    fi
}

# Function to optimize Ollama usage
optimize_ollama() {
    echo "🧠 Optimizing Ollama usage..."

    # Check if Ollama is running
    if pgrep -f "ollama serve" > /dev/null; then
        echo "⚠️  Ollama is running continuously"

        # Create on-demand Ollama wrapper
        cat > "${WORKSPACE_DIR}/ollama_wrapper.sh" << 'EOF'
#!/bin/bash
# On-demand Ollama wrapper

OLLAMA_PID_FILE="/tmp/quantum_ollama.pid"

start_ollama() {
    if [[ ! -f "$OLLAMA_PID_FILE" ]] || ! kill -0 "$(cat "$OLLAMA_PID_FILE" 2>/dev/null)" 2>/dev/null; then
        echo "Starting Ollama..."
        nohup ollama serve > /dev/null 2>&1 &
        echo $! > "$OLLAMA_PID_FILE"
        sleep 2  # Wait for startup
    fi
}

stop_ollama() {
    if [[ -f "$OLLAMA_PID_FILE" ]]; then
        kill "$(cat "$OLLAMA_PID_FILE" 2>/dev/null)" 2>/dev/null || true
        rm -f "$OLLAMA_PID_FILE"
    fi
}

# Start Ollama, run command, then stop
start_ollama
"$@"
stop_ollama
EOF

        chmod +x "${WORKSPACE_DIR}/ollama_wrapper.sh"
        echo "✅ Created on-demand Ollama wrapper at ${WORKSPACE_DIR}/ollama_wrapper.sh"
        echo "Use: ./ollama_wrapper.sh ollama run <model> <prompt>"
    else
        echo "✅ Ollama not running continuously (good)"
    fi
}

# Function to optimize MCP suite
optimize_mcp_suite() {
    echo "🔧 Optimizing MCP suite performance..."

    MCP_DIR="${WORKSPACE_DIR}/Tools/Automation"

    # Check MCP server configuration
    if [[ -f "${MCP_DIR}/mcp_server.py" ]]; then
        # Add memory optimization to MCP server
        if ! grep -q "gc.collect" "${MCP_DIR}/mcp_server.py"; then
            # Add import gc after import time
            sed -i.bak 's/import time/import time\
import gc/' "${MCP_DIR}/mcp_server.py"
            # Add memory cleanup in task execution
            sed -i.bak 's/def _execute_task/def _execute_task\
        gc.collect()  # Memory cleanup/' "${MCP_DIR}/mcp_server.py"
            echo "✅ Added memory cleanup to MCP server"
        fi
    fi

    # Optimize task cleanup
    if [[ -d "${MCP_DIR}/tasks" ]]; then
        # Remove old task files (older than 7 days instead of 30)
        find "${MCP_DIR}/tasks" -name "*.json" -mtime +7 -delete 2>/dev/null || true
        echo "✅ Cleaned up old MCP task files"
    fi
}

# Function to create resource monitoring
create_resource_monitor() {
    echo "📊 Creating resource monitoring system..."

    MONITOR_SCRIPT="${WORKSPACE_DIR}/resource_monitor.sh"

    cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# Resource monitoring script for Quantum Workspace

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${WORKSPACE_DIR}/resource_usage.log"

# Log current resource usage
log_resources() {
    echo "$(date): $(du -sh "$WORKSPACE_DIR" | cut -f1) workspace, $(ps aux | grep -E "(python|mcp|ollama|agent)" | grep -v grep | wc -l) processes" >> "$LOG_FILE"
}

# Cleanup old backups automatically
cleanup_old_backups() {
    BACKUP_DIR="${WORKSPACE_DIR}/Tools/Automation/agents/backups"
    if [[ -d "$BACKUP_DIR" ]]; then
        # Remove backups older than 30 days
        find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
        find "$BACKUP_DIR" -name "CodingReviewer_*" -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
    fi
}

# Run maintenance
log_resources
cleanup_old_backups

# Check if resources are getting too high
workspace_size=$(du -s "$WORKSPACE_DIR" | awk '{print $1}')
if [[ $workspace_size -gt 100000000 ]]; then  # 100GB in KB
    echo "$(date): WARNING - Workspace size exceeded 100GB" >> "$LOG_FILE"
fi
EOF

    chmod +x "$MONITOR_SCRIPT"
    echo "✅ Created resource monitor at ${MONITOR_SCRIPT}"

    # Add to crontab for daily monitoring
    if ! crontab -l 2>/dev/null | grep -q "resource_monitor.sh"; then
        (crontab -l 2>/dev/null; echo "0 2 * * * ${MONITOR_SCRIPT}") | crontab -
        echo "✅ Added daily resource monitoring to crontab"
    fi
}

# Main execution
case "${1:-all}" in
"backups")
    cleanup_backups
    ;;
"python")
    optimize_python_env
    ;;
"ollama")
    optimize_ollama
    ;;
"mcp")
    optimize_mcp_suite
    ;;
"monitor")
    create_resource_monitor
    ;;
"all")
    echo "Running full resource optimization..."
    cleanup_backups
    optimize_python_env
    optimize_ollama
    optimize_mcp_suite
    create_resource_monitor
    ;;
*)
    echo "Usage: $0 [backups|python|ollama|mcp|monitor|all]"
    exit 1
    ;;
esac

echo ""
echo "🎉 Resource optimization completed!"
echo "Run '$0 monitor' to check ongoing resource usage"