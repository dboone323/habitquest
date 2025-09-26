#!/bin/bash
# Security Monitoring Dashboard
# Real-time security status and alerting system

WORKSPACE="/Users/danielstevens/Desktop/Quantum-workspace"
DASHBOARD_FILE="${WORKSPACE}/Tools/security_monitor_dashboard.html"
LOG_FILE="${WORKSPACE}/Tools/Automation/logs/security_monitor.log"
ALERT_FILE="${WORKSPACE}/Tools/Automation/logs/security_alerts.log"
METRICS_FILE="${WORKSPACE}/Tools/Automation/metrics/security_metrics.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "${LOG_FILE}"
}

# Alert function
alert() {
    local severity="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${severity}] ${message}" >> "${ALERT_FILE}"
    log "ALERT [${severity}]: ${message}"
}

# Initialize metrics file
init_metrics() {
    if [[ ! -f "${METRICS_FILE}" ]]; then
        cat > "${METRICS_FILE}" << EOF
{
  "last_scan": "$(date '+%Y-%m-%d %H:%M:%S')",
  "vulnerabilities": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0
  },
  "security_score": 100,
  "projects": {
    "CodingReviewer": {"score": 100, "issues": 0},
    "MomentumFinance": {"score": 100, "issues": 0},
    "HabitQuest": {"score": 100, "issues": 0},
    "PlannerApp": {"score": 100, "issues": 0},
    "AvoidObstaclesGame": {"score": 100, "issues": 0}
  },
  "alerts": []
}
EOF
    fi
}

# Security scan function
perform_security_scan() {
    log "Starting comprehensive security scan..."

    # Initialize metrics first
    init_metrics

    local total_vulnerabilities=0
    local critical_issues=0
    local high_issues=0
    local medium_issues=0
    local low_issues=0

    # Scan each project
    for project in "CodingReviewer" "MomentumFinance" "HabitQuest" "PlannerApp" "AvoidObstaclesGame"; do
        if [[ -d "${WORKSPACE}/Projects/${project}" ]]; then
            log "Scanning ${project}..."

            cd "${WORKSPACE}/Projects/${project}" || continue

            # Check for hardcoded secrets
            local secrets_found
            secrets_found=$(find . -name "*.swift" -exec grep -l "password\|secret\|key.*=.*\"" {} \; 2>/dev/null | wc -l)
            if [[ ${secrets_found} -gt 0 ]]; then
                alert "CRITICAL" "Hardcoded secrets found in ${project} (${secrets_found} files)"
                ((critical_issues += secrets_found))
            fi

            # Check for SQL injection risks
            local sql_injection
            sql_injection=$(find . -name "*.swift" -exec grep -l "SELECT.*+.*\|INSERT.*+.*\|UPDATE.*+.*" {} \; 2>/dev/null | wc -l)
            if [[ ${sql_injection} -gt 0 ]]; then
                alert "HIGH" "SQL injection risks found in ${project} (${sql_injection} files)"
                ((high_issues += sql_injection))
            fi

            # Check for weak cryptography
            local weak_crypto
            weak_crypto=$(find . -name "*.swift" -exec grep -l "MD5\|SHA1\|DES\|RC4" {} \; 2>/dev/null | wc -l)
            if [[ ${weak_crypto} -gt 0 ]]; then
                alert "HIGH" "Weak cryptography found in ${project} (${weak_crypto} files)"
                ((high_issues += weak_crypto))
            fi

            # Check for unsafe HTTP URLs
            local unsafe_urls
            unsafe_urls=$(find . -name "*.swift" -exec grep -l "http://" {} \; 2>/dev/null | wc -l)
            if [[ ${unsafe_urls} -gt 0 ]]; then
                alert "MEDIUM" "Unsafe HTTP URLs found in ${project} (${unsafe_urls} files)"
                ((medium_issues += unsafe_urls))
            fi

            # Check for missing input validation
            local input_validation
            input_validation=$(find . -name "*.swift" -exec grep -l "guard.*let\|if.*nil" {} \; 2>/dev/null | wc -l)
            local swift_files
            swift_files=$(find . -name "*.swift" | wc -l)

            if [[ ${input_validation} -lt $((swift_files / 2)) ]]; then
                alert "MEDIUM" "Insufficient input validation in ${project}"
                ((medium_issues++))
            fi

            # Calculate project security score
            local project_score=$((100 - (critical_issues * 20) - (high_issues * 10) - (medium_issues * 5)))
            if [[ ${project_score} -lt 0 ]]; then
                project_score=0
            fi

            # Update metrics for this project
            jq ".projects.\"${project}\".score = ${project_score} | .projects.\"${project}\".issues = $((critical_issues + high_issues + medium_issues))" "${METRICS_FILE}" > "${METRICS_FILE}.tmp" && mv "${METRICS_FILE}.tmp" "${METRICS_FILE}"

            log "${project} security score: ${project_score}% ($((critical_issues + high_issues + medium_issues)) issues)"
        fi
    done

    # Update overall metrics
    local overall_score=$((100 - (critical_issues * 20) - (high_issues * 10) - (medium_issues * 5)))
    if [[ ${overall_score} -lt 0 ]]; then
        overall_score=0
    fi

    jq ".last_scan = \"$(date '+%Y-%m-%d %H:%M:%S')\" | .vulnerabilities.critical = ${critical_issues} | .vulnerabilities.high = ${high_issues} | .vulnerabilities.medium = ${medium_issues} | .vulnerabilities.low = ${low_issues} | .security_score = ${overall_score}" "${METRICS_FILE}" > "${METRICS_FILE}.tmp" && mv "${METRICS_FILE}.tmp" "${METRICS_FILE}"

    local total_vulnerabilities=$((critical_issues + high_issues + medium_issues + low_issues))
    log "Security scan completed. Total vulnerabilities: ${total_vulnerabilities}"
}

# Generate HTML dashboard
generate_dashboard() {
    log "Generating security dashboard..."

    # Read current metrics
    local security_score
    security_score=$(jq -r '.security_score' "${METRICS_FILE}")
    local last_scan
    last_scan=$(jq -r '.last_scan' "${METRICS_FILE}")
    local critical_count
    critical_count=$(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")
    local high_count
    high_count=$(jq -r '.vulnerabilities.high' "${METRICS_FILE}")
    local medium_count
    medium_count=$(jq -r '.vulnerabilities.medium' "${METRICS_FILE}")

    # Determine status color
    local status_color="#28a745" # green
    local status_text="SECURE"
    if [[ ${critical_count} -gt 0 ]]; then
        status_color="#dc3545" # red
        status_text="CRITICAL"
    elif [[ ${high_count} -gt 0 ]]; then
        status_color="#fd7e14" # orange
        status_text="WARNING"
    elif [[ ${medium_count} -gt 0 ]]; then
        status_color="#ffc107" # yellow
        status_text="CAUTION"
    fi

    cat > "${DASHBOARD_FILE}" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quantum Workspace Security Monitor</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 20px; text-align: center; }
        .status-card { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status-indicator { display: inline-block; width: 20px; height: 20px; border-radius: 50%; margin-right: 10px; }
        .score-display { font-size: 48px; font-weight: bold; text-align: center; margin: 20px 0; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .metric-card { background: white; padding: 20px; border-radius: 10px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .metric-value { font-size: 32px; font-weight: bold; margin: 10px 0; }
        .critical { color: #dc3545; }
        .high { color: #fd7e14; }
        .medium { color: #ffc107; }
        .low { color: #17a2b8; }
        .projects-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .project-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .project-score { font-size: 24px; font-weight: bold; text-align: center; margin: 10px 0; }
        .alerts { background: white; padding: 20px; border-radius: 10px; margin-top: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .alert { padding: 10px; margin: 5px 0; border-left: 4px solid; }
        .alert-critical { border-color: #dc3545; background: #f8d7da; }
        .alert-high { border-color: #fd7e14; background: #fff3cd; }
        .alert-medium { border-color: #ffc107; background: #fff3cd; }
        .refresh-btn { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin-top: 20px; }
        .refresh-btn:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Quantum Workspace Security Monitor</h1>
            <p>Real-time security status and vulnerability tracking</p>
            <div class="status-card" style="background: ${status_color}; color: white; margin-top: 20px;">
                <div class="status-indicator" style="background: white;"></div>
                <strong>Status: ${status_text}</strong>
            </div>
        </div>

        <div class="status-card">
            <h2>Security Score</h2>
            <div class="score-display" style="color: ${status_color};">${security_score}%</div>
            <p>Last scan: ${last_scan}</p>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <h3>Critical Vulnerabilities</h3>
                <div class="metric-value critical">${critical_count}</div>
            </div>
            <div class="metric-card">
                <h3>High Risk Issues</h3>
                <div class="metric-value high">${high_count}</div>
            </div>
            <div class="metric-card">
                <h3>Medium Risk Issues</h3>
                <div class="metric-value medium">${medium_count}</div>
            </div>
            <div class="metric-card">
                <h3>Overall Health</h3>
                <div class="metric-value" style="color: ${status_color};">${security_score}%</div>
            </div>
        </div>

        <h2>Project Security Scores</h2>
        <div class="projects-grid">
EOF

    # Add project cards
    for project in "CodingReviewer" "MomentumFinance" "HabitQuest" "PlannerApp" "AvoidObstaclesGame"; do
        local project_score
        project_score=$(jq -r ".projects.\"${project}\".score" "${METRICS_FILE}")
        local project_issues
        project_issues=$(jq -r ".projects.\"${project}\".issues" "${METRICS_FILE}")

        # Determine project status color
        local project_color="#28a745"
        if [[ ${project_issues} -gt 5 ]]; then
            project_color="#dc3545"
        elif [[ ${project_issues} -gt 2 ]]; then
            project_color="#fd7e14"
        elif [[ ${project_issues} -gt 0 ]]; then
            project_color="#ffc107"
        fi

        cat >> "${DASHBOARD_FILE}" << EOF
            <div class="project-card">
                <h3>${project}</h3>
                <div class="project-score" style="color: ${project_color};">${project_score}%</div>
                <p>${project_issues} issues found</p>
            </div>
EOF
    done

    cat >> "${DASHBOARD_FILE}" << EOF
        </div>

        <div class="alerts">
            <h2>Recent Security Alerts</h2>
EOF

    # Add recent alerts (last 10)
    if [[ -f "${ALERT_FILE}" ]]; then
        tail -10 "${ALERT_FILE}" | while IFS= read -r line; do
            if [[ ${line} =~ \[CRITICAL\] ]]; then
                echo "<div class=\"alert alert-critical\">${line}</div>" >> "${DASHBOARD_FILE}"
            elif [[ ${line} =~ \[HIGH\] ]]; then
                echo "<div class=\"alert alert-high\">${line}</div>" >> "${DASHBOARD_FILE}"
            elif [[ ${line} =~ \[MEDIUM\] ]]; then
                echo "<div class=\"alert alert-medium\">${line}</div>" >> "${DASHBOARD_FILE}"
            else
                echo "<div class=\"alert\">${line}</div>" >> "${DASHBOARD_FILE}"
            fi
        done
    fi

    cat >> "${DASHBOARD_FILE}" << EOF
        </div>

        <div style="text-align: center;">
            <button class="refresh-btn" onclick="location.reload()">Refresh Dashboard</button>
        </div>

        <div style="text-align: center; margin-top: 20px; color: #666;">
            <p>Dashboard auto-refreshes every 5 minutes | Last updated: $(date)</p>
        </div>
    </div>

    <script>
        // Auto-refresh every 5 minutes
        setTimeout(function() {
            location.reload();
        }, 300000);
    </script>
</body>
</html>
EOF

    log "Security dashboard generated at ${DASHBOARD_FILE}"
}

# Continuous monitoring function
start_monitoring() {
    log "Starting continuous security monitoring..."

    while true; do
        perform_security_scan
        generate_dashboard

        # Check for critical alerts and send notifications if needed
        local critical_count
        critical_count=$(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")

        if [[ ${critical_count} -gt 0 ]]; then
            log "CRITICAL security issues detected! Sending alert..."
            # Here you could integrate with notification systems
            # For now, just log it
        fi

        log "Security monitoring cycle completed. Next scan in 10 minutes..."
        sleep 600  # Wait 10 minutes before next scan
    done
}

# Main execution
case "${1:-}" in
    "scan")
        perform_security_scan
        generate_dashboard
        ;;
    "monitor")
        start_monitoring
        ;;
    "dashboard")
        generate_dashboard
        ;;
    "status")
        echo "Security Monitor Status:"
        echo "Last scan: $(jq -r '.last_scan' "${METRICS_FILE}")"
        echo "Security score: $(jq -r '.security_score' "${METRICS_FILE}")%"
        echo "Critical issues: $(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")"
        echo "High risk issues: $(jq -r '.vulnerabilities.high' "${METRICS_FILE}")"
        echo "Medium risk issues: $(jq -r '.vulnerabilities.medium' "${METRICS_FILE}")"
        ;;
    *)
        echo "Usage: $0 {scan|monitor|dashboard|status}"
        echo "  scan      - Perform security scan and update dashboard"
        echo "  monitor   - Start continuous monitoring (runs every 10 minutes)"
        echo "  dashboard - Generate HTML dashboard only"
        echo "  status    - Show current security status"
        exit 1
        ;;
esac