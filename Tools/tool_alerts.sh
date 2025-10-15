#!/bin/bash
# Quantum Workspace Tool Alerting System
# Handles notifications and alerts for tool health issues

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
ALERT_LOG="${WORKSPACE_DIR}/Tools/logs/alerts_$(date +%Y%m%d).log"
DASHBOARD_DATA_FILE="${WORKSPACE_DIR}/Tools/dashboard_data.json"

# Alert levels
ALERT_CRITICAL=2
ALERT_WARNING=1
ALERT_INFO=0

log_alert() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "$timestamp [$level] $message" >>"$ALERT_LOG"
    echo "$timestamp [$level] $message"
}

send_notification() {
    local level="$1"
    local title="$2"
    local message="$3"

    # For now, just log the notification
    # This can be extended to send actual notifications (email, Slack, etc.)
    log_alert "$level" "NOTIFICATION: $title - $message"

    # Basic terminal notification for critical alerts
    if [[ "$level" == "CRITICAL" ]]; then
        echo "🚨 CRITICAL ALERT: $title"
        echo "   $message"
        echo ""
    fi
}

check_for_alerts() {
    log_alert "INFO" "Checking for tool health alerts..."

    if [[ ! -f "$DASHBOARD_DATA_FILE" ]]; then
        log_alert "WARNING" "Dashboard data file not found"
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        log_alert "WARNING" "jq not available for alert checking"
        return 1
    fi

    # Check for missing tools (critical)
    local missing_tools=$(jq -r '.tools.details | to_entries[] | select(.value.status == "missing") | .key' "$DASHBOARD_DATA_FILE" 2>/dev/null)
    if [[ -n "$missing_tools" ]]; then
        while IFS= read -r tool; do
            if [[ -n "$tool" && "$tool" != "null" ]]; then
                send_notification "CRITICAL" "Tool Missing" "Essential tool '$tool' is not installed or not found in PATH"
            fi
        done <<<"$missing_tools"
    fi

    # Check for unhealthy tools (warning)
    local unhealthy_tools=$(jq -r '.tools.details | to_entries[] | select(.value.status == "unhealthy") | .key' "$DASHBOARD_DATA_FILE" 2>/dev/null)
    if [[ -n "$unhealthy_tools" ]]; then
        while IFS= read -r tool; do
            if [[ -n "$tool" && "$tool" != "null" ]]; then
                send_notification "WARNING" "Tool Unhealthy" "Tool '$tool' is installed but not functioning properly"
            fi
        done <<<"$unhealthy_tools"
    fi

    # Check system resources
    local disk_percent=$(jq -r '.system.disk_usage.percent // 0' "$DASHBOARD_DATA_FILE" 2>/dev/null)
    if [[ "$disk_percent" -gt 90 ]]; then
        send_notification "CRITICAL" "Disk Space Critical" "Workspace disk usage is ${disk_percent}% - immediate action required"
    elif [[ "$disk_percent" -gt 80 ]]; then
        send_notification "WARNING" "Disk Space Warning" "Workspace disk usage is ${disk_percent}% - monitor closely"
    fi

    log_alert "INFO" "Alert check completed"
}

show_recent_alerts() {
    local hours=${1:-24}
    local since=$(date -v-${hours}H '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "${hours} hours ago" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "24 hours ago")

    echo "🚨 Recent Alerts (last $hours hours)"
    echo "====================================="

    if [[ -f "$ALERT_LOG" ]]; then
        local count=0
        if [[ -s "$ALERT_LOG" ]]; then
            count=$(wc -l < "$ALERT_LOG")
        fi
        if [[ $count -gt 0 ]]; then
            echo "Found $count alerts since $since:"
            echo ""
            awk -v since="$since" '$0 >= since' "$ALERT_LOG" | tail -20
        else
            echo "✅ No alerts in the last $hours hours"
        fi
    else
        echo "No alert log available"
    fi
}

case "${1:-check}" in
"check")
    check_for_alerts
    ;;
"show")
    show_recent_alerts "${2:-24}"
    ;;
"help" | *)
    echo "Quantum Workspace Tool Alerting System"
    echo "======================================"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  check          - Check for new alerts (default)"
    echo "  show [hours]   - Show recent alerts (default: 24 hours)"
    echo "  help           - Show this help"
    echo ""
    echo "Alert Levels:"
    echo "  CRITICAL (2)   - Essential tools missing, disk space critical"
    echo "  WARNING (1)    - Tools unhealthy, disk space warning"
    echo "  INFO (0)       - General information"
    ;;
esac
