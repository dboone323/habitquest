#!/bin/bash
# Smart Agent Management System
# Provides intelligent monitoring, backup control, and performance optimization

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
AGENTS_DIR="$SCRIPT_DIR"
LOG_DIR="$AGENTS_DIR/logs"
BACKUP_DIR="$AGENTS_DIR/backups"
METRICS_DIR="$AGENTS_DIR/metrics"

# Create directories
mkdir -p "$LOG_DIR" "$BACKUP_DIR" "$METRICS_DIR"

# Configuration files
AGENT_CONFIG="$AGENTS_DIR/agent_config.json"
PERFORMANCE_METRICS="$METRICS_DIR/performance_metrics.json"
BACKUP_POLICY="$AGENTS_DIR/backup_policy.json"

# Initialize configuration if not exists
if [[ ! -f "$AGENT_CONFIG" ]]; then
    cat > "$AGENT_CONFIG" << 'EOF'
{
    "agents": {
        "build_agent": {
            "script": "agent_build.sh",
            "max_backups": 5,
            "backup_interval": 3600,
            "health_check_interval": 300,
            "auto_restart": true,
            "max_restarts": 3,
            "restart_window": 1800
        },
        "debug_agent": {
            "script": "agent_debug.sh",
            "max_backups": 3,
            "backup_interval": 1800,
            "health_check_interval": 300,
            "auto_restart": true,
            "max_restarts": 5,
            "restart_window": 3600
        },
        "codegen_agent": {
            "script": "agent_codegen.sh",
            "max_backups": 5,
            "backup_interval": 3600,
            "health_check_interval": 300,
            "auto_restart": true,
            "max_restarts": 3,
            "restart_window": 1800
        }
    },
    "global_settings": {
        "max_total_backups": 50,
        "backup_retention_days": 7,
        "log_rotation_size_mb": 10,
        "performance_monitoring": true,
        "alert_thresholds": {
            "cpu_percent": 80,
            "memory_mb": 500,
            "disk_percent": 90
        }
    }
}
EOF
fi

if [[ ! -f "$BACKUP_POLICY" ]]; then
    cat > "$BACKUP_POLICY" << 'EOF'
{
    "policies": {
        "smart_backup": {
            "description": "Only backup when significant changes detected",
            "trigger_conditions": [
                "file_changes > 10",
                "build_success = false",
                "manual_trigger = true"
            ],
            "retention": {
                "max_per_agent": 5,
                "max_age_days": 7,
                "compression": true
            }
        },
        "emergency_backup": {
            "description": "Backup before risky operations",
            "trigger_conditions": [
                "operation = 'auto_enhancement'",
                "operation = 'major_refactor'",
                "risk_level = 'high'"
            ],
            "retention": {
                "max_per_agent": 10,
                "max_age_days": 30,
                "compression": true
            }
        }
    }
}
EOF
fi

# Initialize performance metrics
if [[ ! -f "$PERFORMANCE_METRICS" ]]; then
    cat > "$PERFORMANCE_METRICS" << 'EOF'
{
    "timestamp": "",
    "agents": {},
    "system": {
        "cpu_usage": 0,
        "memory_usage": 0,
        "disk_usage": 0
    },
    "backups": {
        "total_size_mb": 0,
        "total_count": 0,
        "oldest_backup": "",
        "newest_backup": ""
    }
}
EOF
fi

# Smart backup function with retention
smart_backup() {
    local agent_name="$1"
    local project="${2:-}"
    local backup_type="${3:-smart}"

    echo "[$(date)] Smart Agent Manager: Starting $backup_type backup for $agent_name"

    # Check if backup is needed
    if should_backup "$agent_name" "$backup_type"; then
        # Clean old backups first
        cleanup_old_backups "$agent_name"

        # Create backup
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_name="${agent_name}_${backup_type}_${timestamp}"

        if [[ -n "$project" ]]; then
            backup_project "$project" "$backup_name"
        else
            backup_agent_state "$agent_name" "$backup_name"
        fi

        # Update metrics
        update_backup_metrics

        echo "[$(date)] Smart Agent Manager: $backup_type backup completed for $agent_name"
    else
        echo "[$(date)] Smart Agent Manager: Skipping backup for $agent_name (not needed)"
    fi
}

# Check if backup should be performed
should_backup() {
    local agent_name="$1"
    local backup_type="$2"

    # Get agent config
    local max_backups
    max_backups=$(jq -r ".agents.${agent_name}.max_backups" "$AGENT_CONFIG" 2>/dev/null || echo "5")
    local backup_interval
    backup_interval=$(jq -r ".agents.${agent_name}.backup_interval" "$AGENT_CONFIG" 2>/dev/null || echo "3600")

    # Count existing backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -name "${agent_name}_*" -type d 2>/dev/null | wc -l)

    # Check if we're at the limit
    if [[ $backup_count -ge $max_backups ]]; then
        echo "[$(date)] Smart Agent Manager: Backup limit reached for $agent_name ($backup_count >= $max_backups)"
        return 1
    fi

    # Check time since last backup
    local last_backup
    last_backup=$(find "$BACKUP_DIR" -name "${agent_name}_*" -type d 2>/dev/null | sort | tail -1)
    if [[ -n "$last_backup" ]]; then
        local last_backup_time
        last_backup_time=$(stat -f%B "$last_backup" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)
        local time_diff=$((current_time - last_backup_time))

        if [[ $time_diff -lt $backup_interval ]]; then
            echo "[$(date)] Smart Agent Manager: Too soon for backup of $agent_name (${time_diff}s < ${backup_interval}s)"
            return 1
        fi
    fi

    return 0
}

# Clean up old backups
cleanup_old_backups() {
    local agent_name="$1"
    local max_backups
    max_backups=$(jq -r ".agents.${agent_name}.max_backups" "$AGENT_CONFIG" 2>/dev/null || echo "5")
    local retention_days
    retention_days=$(jq -r ".global_settings.backup_retention_days" "$AGENT_CONFIG" 2>/dev/null || echo "7")

    echo "[$(date)] Smart Agent Manager: Cleaning up old backups for $agent_name"

    # Remove backups older than retention period
    find "$BACKUP_DIR" -name "${agent_name}_*" -type d -mtime +$retention_days -exec rm -rf {} \; 2>/dev/null || true

    # Keep only the most recent backups
    local backup_dirs
    mapfile -t backup_dirs < <(find "$BACKUP_DIR" -name "${agent_name}_*" -type d -print0 2>/dev/null | xargs -0 ls -td 2>/dev/null || true)

    if [[ ${#backup_dirs[@]} -gt $max_backups ]]; then
        local to_remove=$(( ${#backup_dirs[@]} - max_backups ))
        for ((i=to_remove; i<${#backup_dirs[@]}; i++)); do
            echo "[$(date)] Smart Agent Manager: Removing old backup: ${backup_dirs[$i]}"
            rm -rf "${backup_dirs[$i]}" 2>/dev/null || true
        done
    fi
}

# Backup project with compression
backup_project() {
    local project="$1"
    local backup_name="$2"
    local project_path="$WORKSPACE_ROOT/Projects/$project"

    if [[ ! -d "$project_path" ]]; then
        echo "[$(date)] Smart Agent Manager: Project $project not found at $project_path"
        return 1
    fi

    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path"

    echo "[$(date)] Smart Agent Manager: Creating compressed backup of $project"

    # Create compressed archive
    cd "$WORKSPACE_ROOT/Projects"
    tar -czf "$backup_path/${project}.tar.gz" "$project" 2>/dev/null

    # Create metadata
    cat > "$backup_path/metadata.json" << EOF
{
    "project": "$project",
    "timestamp": "$(date -Iseconds)",
    "type": "compressed",
    "original_size": "$(du -sh "$project_path" | cut -f1)",
    "compressed_size": "$(du -sh "$backup_path/${project}.tar.gz" | cut -f1)",
    "created_by": "smart_agent_manager"
}
EOF

    echo "[$(date)] Smart Agent Manager: Backup created: $backup_path"
}

# Backup agent state (logs, configs, etc.)
backup_agent_state() {
    local agent_name="$1"
    local backup_name="$2"

    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path"

    echo "[$(date)] Smart Agent Manager: Creating agent state backup for $agent_name"

    # Backup agent logs and configs
    if [[ -d "$AGENTS_DIR" ]]; then
        cp -r "$AGENTS_DIR"/*.log "$backup_path/" 2>/dev/null || true
        cp -r "$AGENTS_DIR"/*.json "$backup_path/" 2>/dev/null || true
        cp -r "$AGENTS_DIR"/*.sh "$backup_path/" 2>/dev/null || true
    fi

    # Create metadata
    cat > "$backup_path/metadata.json" << EOF
{
    "agent": "$agent_name",
    "timestamp": "$(date -Iseconds)",
    "type": "agent_state",
    "files_backed_up": $(find "$backup_path" -type f | wc -l),
    "created_by": "smart_agent_manager"
}
EOF

    echo "[$(date)] Smart Agent Manager: Agent state backup created: $backup_path"
}

# Update backup metrics
update_backup_metrics() {
    local total_size
    total_size=$(du -sm "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "0")
    local total_count
    total_count=$(find "$BACKUP_DIR" -mindepth 1 -type d 2>/dev/null | wc -l || echo "0")
    local oldest_backup
    oldest_backup=$(find "$BACKUP_DIR" -mindepth 1 -type d -print0 2>/dev/null | xargs -0 ls -td 2>/dev/null | tail -1 || echo "")
    local newest_backup
    newest_backup=$(find "$BACKUP_DIR" -mindepth 1 -type d -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1 || echo "")

    jq --arg total_size "$total_size" \
       --arg total_count "$total_count" \
       --arg oldest_backup "$oldest_backup" \
       --arg newest_backup "$newest_backup" \
       --arg timestamp "$(date -Iseconds)" \
       '.timestamp = $timestamp | .backups.total_size_mb = ($total_size | tonumber) | .backups.total_count = ($total_count | tonumber) | .backups.oldest_backup = $oldest_backup | .backups.newest_backup = $newest_backup' \
       "$PERFORMANCE_METRICS" > "$PERFORMANCE_METRICS.tmp" && mv "$PERFORMANCE_METRICS.tmp" "$PERFORMANCE_METRICS"
}

# Monitor agent health
monitor_agent_health() {
    local agent_name="$1"
    local agent_script
    agent_script=$(jq -r ".agents.${agent_name}.script" "$AGENT_CONFIG" 2>/dev/null || echo "")

    if [[ -z "$agent_script" ]]; then
        echo "[$(date)] Smart Agent Manager: Agent $agent_name not configured"
        return 1
    fi

    # Check if agent is running
    local pid_file="$AGENTS_DIR/${agent_script}.pid"
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            echo "[$(date)] Smart Agent Manager: Agent $agent_name is running (PID: $pid)"
            return 0
        else
            echo "[$(date)] Smart Agent Manager: Agent $agent_name PID file exists but process not running"
            rm -f "$pid_file" 2>/dev/null || true
        fi
    fi

    # Check log file for recent activity
    local log_file="$AGENTS_DIR/${agent_script%.sh}.log"
    if [[ -f "$log_file" ]]; then
        local last_activity
        last_activity=$(stat -f%B "$log_file" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)
        local time_diff=$((current_time - last_activity))

        if [[ $time_diff -gt 3600 ]]; then
            echo "[$(date)] Smart Agent Manager: Agent $agent_name has been inactive for ${time_diff}s"
            return 1
        fi
    fi

    echo "[$(date)] Smart Agent Manager: Agent $agent_name status unknown"
    return 1
}

# Get system metrics
get_system_metrics() {
    # CPU usage
    local cpu_usage
    cpu_usage=$(ps aux | awk '{sum += $3} END {print sum}' 2>/dev/null || echo "0")

    # Memory usage (MB)
    local memory_usage
    memory_usage=$(ps aux | awk '{sum += $4} END {print sum * 1024 / 100}' 2>/dev/null || echo "0")

    # Disk usage (%)
    local disk_usage
    disk_usage=$(df "$WORKSPACE_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")

    jq --arg cpu_usage "$cpu_usage" \
       --arg memory_usage "$memory_usage" \
       --arg disk_usage "$disk_usage" \
       '.system.cpu_usage = ($cpu_usage | tonumber) | .system.memory_usage = ($memory_usage | tonumber) | .system.disk_usage = ($disk_usage | tonumber)' \
       "$PERFORMANCE_METRICS" > "$PERFORMANCE_METRICS.tmp" && mv "$PERFORMANCE_METRICS.tmp" "$PERFORMANCE_METRICS"
}

# Main command handler
case "${1:-help}" in
    "backup")
        shift
        smart_backup "$@"
        ;;
    "monitor")
        shift
        monitor_agent_health "$@"
        ;;
    "cleanup")
        echo "[$(date)] Smart Agent Manager: Running backup cleanup"
        for agent in $(jq -r '.agents | keys[]' "$AGENT_CONFIG" 2>/dev/null); do
            cleanup_old_backups "$agent"
        done
        update_backup_metrics
        ;;
    "metrics")
        get_system_metrics
        cat "$PERFORMANCE_METRICS"
        ;;
    "status")
        echo "=== Smart Agent Management System Status ==="
        echo "Configuration: $AGENT_CONFIG"
        echo "Backup Directory: $BACKUP_DIR"
        echo "Log Directory: $LOG_DIR"
        echo "Metrics File: $PERFORMANCE_METRICS"
        echo ""
        echo "=== Agent Status ==="
        for agent in $(jq -r '.agents | keys[]' "$AGENT_CONFIG" 2>/dev/null); do
            if monitor_agent_health "$agent" >/dev/null 2>&1; then
                echo "✅ $agent: Running"
            else
                echo "❌ $agent: Not running or unhealthy"
            fi
        done
        echo ""
        echo "=== Backup Status ==="
        update_backup_metrics
        jq -r '.backups | "Total backups: \(.total_count)", "Total size: \(.total_size_mb) MB", "Oldest: \(.oldest_backup)", "Newest: \(.newest_backup)"' "$PERFORMANCE_METRICS" 2>/dev/null || echo "Unable to read backup metrics"
        ;;
    "help"|*)
        echo "Smart Agent Management System"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  backup <agent> [project] [type]  - Create smart backup"
        echo "  monitor <agent>                  - Monitor agent health"
        echo "  cleanup                          - Clean up old backups"
        echo "  metrics                          - Show system metrics"
        echo "  status                           - Show system status"
        echo "  help                             - Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 backup build_agent CodingReviewer smart"
        echo "  $0 monitor debug_agent"
        echo "  $0 cleanup"
        ;;
esac