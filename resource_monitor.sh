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
if [[ $workspace_size -gt 80000000 ]]; then  # 80GB in KB
    echo "$(date): WARNING - Workspace size exceeded 80GB" >> "$LOG_FILE"
fi
