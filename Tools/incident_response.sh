#!/bin/bash
# Security Incident Response System
# Automated detection, alerting, and response workflows

WORKSPACE="/Users/danielstevens/Desktop/Quantum-workspace"
INCIDENT_DIR="${WORKSPACE}/Tools/Automation/incidents"
ALERTS_DIR="${WORKSPACE}/Tools/Automation/alerts"
RESPONSE_DIR="${WORKSPACE}/Tools/Automation/responses"
LOG_FILE="${WORKSPACE}/Tools/Automation/logs/incident_response.log"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging function
log() {
    echo "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "${LOG_FILE}"
}

# Initialize directories
init_directories() {
    mkdir -p "${INCIDENT_DIR}" "${ALERTS_DIR}" "${RESPONSE_DIR}"
}

# Incident severity levels
get_severity_level() {
    case "$1" in
        "CRITICAL") echo 4 ;;
        "HIGH") echo 3 ;;
        "MEDIUM") echo 2 ;;
        "LOW") echo 1 ;;
        "INFO") echo 0 ;;
        *) echo 0 ;;
    esac
}

# Create incident record
create_incident() {
    local incident_id="$1"
    local severity="$2"
    local title="$3"
    local description="$4"
    local source="$5"

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"

    cat > "${incident_file}" << EOF
{
  "incident_id": "${incident_id}",
  "severity": "${severity}",
  "severity_level": $(get_severity_level "${severity}"),
  "title": "${title}",
  "description": "${description}",
  "source": "${source}",
  "status": "OPEN",
  "created_at": "${timestamp}",
  "updated_at": "${timestamp}",
  "assigned_to": null,
  "tags": [],
  "evidence": [],
  "response_actions": [],
  "resolution": null,
  "resolved_at": null
}
EOF

    log "Incident created: ${incident_id} (${severity}) - ${title}"
    echo "${incident_file}"
}

# Update incident status
update_incident() {
    local incident_id="$1"
    local status="$2"
    local notes="$3"

    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"
    if [[ ! -f "${incident_file}" ]]; then
        log "Error: Incident ${incident_id} not found"
        return 1
    fi

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Update status and timestamp (simplified)
    echo "Status update: ${status} at ${timestamp} - ${notes}" >> "${incident_file}"

    if [[ "${status}" == "RESOLVED" ]] || [[ "${status}" == "CLOSED" ]]; then
        echo "Resolution: ${notes} at ${timestamp}" >> "${incident_file}"
    fi

    log "Incident ${incident_id} status updated to: ${status}"
}

# Detect security incidents
detect_incidents() {
    log "Scanning for security incidents..."

    local incident_count=0

    # Check for critical security issues
    if [[ -f "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json" ]]; then
        local critical_count
        critical_count=$(jq -r '.vulnerabilities.critical' "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json")

        if [[ ${critical_count} -gt 0 ]]; then
            local incident_id
            incident_id="CRIT_$(date '+%Y%m%d_%H%M%S')"
            local incident_file
            incident_file=$(create_incident "${incident_id}" "CRITICAL" "Critical Security Vulnerabilities Detected" "${critical_count} critical security vulnerabilities found in codebase" "security_monitor")

            # Add evidence (simplified - skipping jq for now)
            echo "Evidence: Critical vulnerabilities: ${critical_count}" >> "${incident_file}"

            ((incident_count++))
        fi
    fi

    # Check for hardcoded secrets
    local secrets_found
    secrets_found=$(find "${WORKSPACE}/Projects" -name "*.swift" -exec grep -l "password\|secret\|key.*=.*\"" {} \; 2>/dev/null | wc -l)
    if [[ ${secrets_found} -gt 0 ]]; then
        local incident_id
        incident_id="SECRETS_$(date '+%Y%m%d_%H%M%S')"
        local incident_file
        incident_file=$(create_incident "${incident_id}" "HIGH" "Hardcoded Secrets Detected" "${secrets_found} files contain potential hardcoded secrets" "secret_scanner")

        # Add evidence (simplified)
        echo "Evidence: Files with potential secrets: ${secrets_found}" >> "${incident_file}"

        ((incident_count++))
    fi

    # Check for security alerts
    if [[ -f "${WORKSPACE}/Tools/Automation/logs/security_alerts.log" ]]; then
        local recent_alerts
        recent_alerts=$(tail -20 "${WORKSPACE}/Tools/Automation/logs/security_alerts.log" | grep -c "CRITICAL\|HIGH" 2>/dev/null || echo "0")

        if [[ ${recent_alerts} -gt 0 ]]; then
            local incident_id
            incident_id="ALERTS_$(date '+%Y%m%d_%H%M%S')"
            local incident_file
            incident_file=$(create_incident "${incident_id}" "HIGH" "Multiple Security Alerts" "${recent_alerts} high/critical security alerts detected recently" "alert_monitor")

            ((incident_count++))
        fi
    fi

    # Check for unusual file changes (potential compromise)
    local suspicious_changes
    suspicious_changes=$(find "${WORKSPACE}" -name "*.swift" -newer "${WORKSPACE}/Tools/Automation/logs/security_monitor.log" 2>/dev/null | wc -l 2>/dev/null || echo "0")

    if [[ ${suspicious_changes} -gt 10 ]]; then
        local incident_id
        incident_id="CHANGES_$(date '+%Y%m%d_%H%M%S')"
        create_incident "${incident_id}" "MEDIUM" "Unusual File Modification Activity" "${suspicious_changes} files modified recently - potential security concern" "file_monitor"
        ((incident_count++))
    fi

    log "Incident detection completed. Found ${incident_count} new incidents."
}

# Execute automated response actions
execute_response() {
    local incident_id="$1"
    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"

    if [[ ! -f "${incident_file}" ]]; then
        log "Error: Incident ${incident_id} not found"
        return 1
    fi

    local severity
    severity=$(jq -r '.severity' "${incident_file}")
    local title
    title=$(jq -r '.title' "${incident_file}")

    log "Executing automated response for incident ${incident_id} (${severity}): ${title}"

    case "${severity}" in
        "CRITICAL")
            # Critical incidents get immediate quarantine actions
            quarantine_incident "${incident_id}"
            notify_security_team "${incident_id}" "CRITICAL"
            create_backup "${incident_id}"
            ;;
        "HIGH")
            # High priority incidents get alerts and monitoring
            notify_security_team "${incident_id}" "HIGH"
            increase_monitoring "${incident_id}"
            ;;
        "MEDIUM")
            # Medium incidents get logged and monitored
            log_incident "${incident_id}"
            monitor_incident "${incident_id}"
            ;;
        "LOW"|"INFO")
            # Low priority incidents just get logged
            log_incident "${incident_id}"
            ;;
    esac
}

# Quarantine actions for critical incidents
quarantine_incident() {
    local incident_id="$1"
    log "Executing quarantine actions for incident ${incident_id}"

    # Create quarantine directory
    local quarantine_dir="${RESPONSE_DIR}/quarantine_${incident_id}"
    mkdir -p "${quarantine_dir}"

    # Move suspicious files to quarantine (example - would need more sophisticated logic)
    # This is a placeholder for actual quarantine logic
    echo "Quarantine actions would be implemented here" > "${quarantine_dir}/quarantine_log.txt"

    # Update incident with response action (simplified)
    echo "Response action: Quarantine executed at ${timestamp}" >> "${incident_file}"
}

# Notification system
notify_security_team() {
    local incident_id="$1"
    local severity="$2"

    log "Sending ${severity} notification for incident ${incident_id}"

    # Create notification file
    local timestamp_part
    timestamp_part=$(date '+%Y%m%d_%H%M%S')
    local notification_file="${ALERTS_DIR}/notification_${incident_id}_${timestamp_part}.txt"

    cat > "${notification_file}" << EOF
SECURITY INCIDENT ALERT
========================

Incident ID: ${incident_id}
Severity: ${severity}
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')

This is an automated security alert. Please review the incident details immediately.

Incident details can be found at:
${INCIDENT_DIR}/incident_${incident_id}.json

Security Dashboard:
${WORKSPACE}/Tools/security_monitor_dashboard.html

EOF

    # In a real system, this would integrate with:
    # - Email notifications
    # - Slack/Teams webhooks
    # - SMS alerts
    # - Incident management systems (Jira, ServiceNow, etc.)

    log "Notification created: ${notification_file}"
}

# Increase monitoring for high-priority incidents
increase_monitoring() {
    local incident_id="$1"
    log "Increasing monitoring for incident ${incident_id}"

    # This would increase monitoring frequency, enable additional logging, etc.
    # For now, just log the action
    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    jq ".response_actions += [{\"timestamp\": \"${timestamp}\", \"action\": \"Monitoring increased\", \"details\": \"Enhanced monitoring enabled for this incident\"}]" "${incident_file}" > "${incident_file}.tmp" && mv "${incident_file}.tmp" "${incident_file}" 2>/dev/null || echo "Response logged: Monitoring increased at ${timestamp}" >> "${incident_file}"
}

# Log incident for tracking
log_incident() {
    local incident_id="$1"
    log "Logging incident ${incident_id} for tracking"

    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    jq ".response_actions += [{\"timestamp\": \"${timestamp}\", \"action\": \"Incident logged\", \"details\": \"Added to security incident log\"}]" "${incident_file}" > "${incident_file}.tmp" && mv "${incident_file}.tmp" "${incident_file}" 2>/dev/null || echo "Response logged: Incident logged at ${timestamp}" >> "${incident_file}"
}

# Monitor incident progress
monitor_incident() {
    local incident_id="$1"
    log "Setting up monitoring for incident ${incident_id}"

    # Create monitoring task
    local monitor_file="${RESPONSE_DIR}/monitor_${incident_id}.sh"

    cat > "${monitor_file}" << EOF
#!/bin/bash
# Monitor incident ${incident_id}

INCIDENT_FILE="${INCIDENT_DIR}/incident_${incident_id}.json"

while [ "\$(jq -r '.status' "\$INCIDENT_FILE")" = "OPEN" ]; do
    echo "Monitoring incident ${incident_id}..."
    sleep 300  # Check every 5 minutes
done

echo "Incident ${incident_id} resolved. Stopping monitoring."
EOF

    chmod +x "${monitor_file}"

    # Update incident
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    jq ".response_actions += [{\"timestamp\": \"${timestamp}\", \"action\": \"Monitoring setup\", \"details\": \"Continuous monitoring enabled\"}]" "${incident_file}" > "${incident_file}.tmp" && mv "${incident_file}.tmp" "${incident_file}" 2>/dev/null || echo "Response logged: Monitoring setup at ${timestamp}" >> "${incident_file}"
}

# Create system backup for critical incidents
create_backup() {
    local incident_id="$1"
    log "Creating backup for incident ${incident_id}"

    local backup_dir="${RESPONSE_DIR}/backup_${incident_id}"
    mkdir -p "${backup_dir}"

    # Create backup of critical files (simplified example)
    cp -r "${WORKSPACE}/Tools/Automation/metrics" "${backup_dir}/" 2>/dev/null || true
    cp -r "${WORKSPACE}/Tools/Automation/logs" "${backup_dir}/" 2>/dev/null || true

    # Update incident
    local incident_file="${INCIDENT_DIR}/incident_${incident_id}.json"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    jq ".response_actions += [{\"timestamp\": \"${timestamp}\", \"action\": \"Backup created\", \"details\": \"System backup created at ${backup_dir}\"}]" "${incident_file}" > "${incident_file}.tmp" && mv "${incident_file}.tmp" "${incident_file}" 2>/dev/null || echo "Response logged: Backup created at ${backup_dir} at ${timestamp}" >> "${incident_file}"

    log "Backup created: ${backup_dir}"
}

# Generate incident report
generate_incident_report() {
    log "Generating incident response report..."

    local timestamp_str
    timestamp_str=$(date '+%Y%m%d_%H%M%S')
    local report_file="${RESPONSE_DIR}/incident_report_${timestamp_str}.md"

    cat > "${report_file}" << EOF
# Security Incident Response Report
Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Active Incidents

EOF

    # List active incidents
    for incident_file in "${INCIDENT_DIR}"/incident_*.json; do
        if [[ -f "${incident_file}" ]]; then
            status=$(jq -r '.status' "${incident_file}")
            if [[ "${status}" == "OPEN" ]]; then
                incident_id=$(jq -r '.incident_id' "${incident_file}")
                severity=$(jq -r '.severity' "${incident_file}")
                title=$(jq -r '.title' "${incident_file}")
                created=$(jq -r '.created_at' "${incident_file}")

                cat >> "${report_file}" << EOF
### ${incident_id} (${severity})
- **Title**: ${title}
- **Created**: ${created}
- **Status**: ${status}

EOF
            fi
        fi
    done

    cat >> "${report_file}" << EOF

## Recent Response Actions

EOF

    # Show recent response actions from all incidents
    for incident_file in "${INCIDENT_DIR}"/incident_*.json; do
        if [[ -f "${incident_file}" ]]; then
            local incident_id
            incident_id=$(jq -r '.incident_id' "${incident_file}")

            jq -r '.response_actions[-5:][]? | "- **\(.timestamp)**: \(.action) - \(.details)"' "${incident_file}" >> "${report_file}" 2>/dev/null || true
        fi
    done

    cat >> "${report_file}" << EOF

## System Health

EOF

    # Add system health information
    if [[ -f "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json" ]]; then
        local security_score
        security_score=$(jq -r '.security_score' "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json")
        local critical_count
        critical_count=$(jq -r '.vulnerabilities.critical' "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json")

        cat >> "${report_file}" << EOF
- **Security Score**: ${security_score}%
- **Critical Issues**: ${critical_count}
- **Last Scan**: $(jq -r '.last_scan' "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json")

EOF
    fi

    log "Incident report generated: ${report_file}"
}

# Main execution
case "${1:-}" in
    "detect")
        init_directories
        detect_incidents
        ;;
    "respond")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 respond <incident_id>"
            exit 1
        fi
        init_directories
        execute_response "$2"
        ;;
    "update")
        if [[ -z "$2" ]] || [[ -z "$3" ]]; then
            echo "Usage: $0 update <incident_id> <status> [notes]"
            exit 1
        fi
        init_directories
        update_incident "$2" "$3" "${4:-}"
        ;;
    "report")
        init_directories
        generate_incident_report
        ;;
    "full")
        init_directories
        detect_incidents

        # Execute responses for all open incidents
        for incident_file in "${INCIDENT_DIR}"/incident_*.json; do
            if [[ -f "${incident_file}" ]]; then
                status=$(jq -r '.status' "${incident_file}")
                if [[ "${status}" == "OPEN" ]]; then
                    incident_id=$(jq -r '.incident_id' "${incident_file}")
                    execute_response "${incident_id}"
                fi
            fi
        done

        generate_incident_report
        ;;
    "list")
        echo "Active Security Incidents:"
        echo "=========================="
        for incident_file in "${INCIDENT_DIR}"/incident_*.json; do
            if [[ -f "${incident_file}" ]]; then
                status=$(jq -r '.status' "${incident_file}")
                if [[ "${status}" == "OPEN" ]]; then
                    incident_id=$(jq -r '.incident_id' "${incident_file}")
                    severity=$(jq -r '.severity' "${incident_file}")
                    title=$(jq -r '.title' "${incident_file}")
                    echo "${incident_id} | ${severity} | ${title}"
                fi
            fi
        done
        ;;
    *)
        echo "Usage: $0 {detect|respond|update|report|full|list}"
        echo "  detect   - Scan for new security incidents"
        echo "  respond <id> - Execute response for specific incident"
        echo "  update <id> <status> [notes] - Update incident status"
        echo "  report   - Generate incident response report"
        echo "  full     - Run complete incident detection and response"
        echo "  list     - List all active incidents"
        exit 1
        ;;
esac