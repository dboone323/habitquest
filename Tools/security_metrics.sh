#!/bin/bash
# Security Metrics Collection and Analysis
# Tracks security trends and generates reports

WORKSPACE="/Users/danielstevens/Desktop/Quantum-workspace"
METRICS_DIR="${WORKSPACE}/Tools/Automation/metrics"
HISTORY_DIR="${METRICS_DIR}/history"
REPORTS_DIR="${METRICS_DIR}/reports"
LOG_FILE="${WORKSPACE}/Tools/Automation/logs/security_metrics.log"

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
    mkdir -p "${HISTORY_DIR}" "${REPORTS_DIR}"
}

# Collect current security metrics
collect_metrics() {
    log "Collecting current security metrics..."

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local metrics_file="${HISTORY_DIR}/security_metrics_${timestamp}.json"

    # Run security scan to get current data
    cd "${WORKSPACE}/Tools" || { log "Failed to change to Tools directory"; return 1; }
    ./security_monitor.sh scan > /dev/null 2>&1

    # Read current metrics
    if [[ -f "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json" ]]; then
        cp "${WORKSPACE}/Tools/Automation/metrics/security_metrics.json" "${metrics_file}"

        # Add additional metrics
        jq ".timestamp = \"${timestamp}\" | .collection_date = \"$(date '+%Y-%m-%d %H:%M:%S')\"" "${metrics_file}" > "${metrics_file}.tmp" && mv "${metrics_file}.tmp" "${metrics_file}"

        log "Metrics collected and stored: ${metrics_file}"
    else
        log "Warning: Could not find current metrics file"
    fi
}

# Analyze security trends
analyze_trends() {
    log "Analyzing security trends..."

    local date_str
    date_str=$(date '+%Y%m%d')
    local trend_report="${REPORTS_DIR}/security_trends_${date_str}.json"

    # Get all historical metrics files
    local metrics_files=()
    while IFS= read -r file; do
        metrics_files+=("${file}")
    done < <(ls -t "${HISTORY_DIR}"/security_metrics_*.json 2>/dev/null | head -30)

    if [[ ${#metrics_files[@]} -lt 2 ]]; then
        log "Not enough historical data for trend analysis (need at least 2 data points)"
        return
    fi

    # Analyze trends
    python3 -c "
import json
import os
from datetime import datetime
import statistics

metrics_files = [
$(printf "'%s',\n" "${metrics_files[@]}")
]

data_points = []
for file_path in metrics_files:
    try:
        with open(file_path.strip(',').strip(), 'r') as f:
            data = json.load(f)
            data_points.append({
                'timestamp': data.get('timestamp', ''),
                'date': data.get('collection_date', ''),
                'security_score': data.get('security_score', 0),
                'critical': data.get('vulnerabilities', {}).get('critical', 0),
                'high': data.get('vulnerabilities', {}).get('high', 0),
                'medium': data.get('vulnerabilities', {}).get('medium', 0),
                'projects': data.get('projects', {})
            })
    except Exception as e:
        pass

# Calculate trends
if len(data_points) >= 2:
    scores = [p['security_score'] for p in data_points]
    critical_counts = [p['critical'] for p in data_points]

    trend_analysis = {
        'period': {
            'start': data_points[-1]['date'],
            'end': data_points[0]['date'],
            'data_points': len(data_points)
        },
        'overall_trend': {
            'security_score': {
                'current': scores[0],
                'previous': scores[1] if len(scores) > 1 else scores[0],
                'change': scores[0] - (scores[1] if len(scores) > 1 else scores[0]),
                'direction': 'improving' if scores[0] > scores[1] else 'declining' if len(scores) > 1 else 'stable'
            },
            'critical_vulnerabilities': {
                'current': critical_counts[0],
                'previous': critical_counts[1] if len(critical_counts) > 1 else critical_counts[0],
                'change': critical_counts[0] - (critical_counts[1] if len(critical_counts) > 1 else critical_counts[0])
            }
        },
        'project_trends': {}
    }

    # Analyze project-specific trends
    if data_points[0]['projects']:
        for project_name in data_points[0]['projects'].keys():
            project_scores = []
            for point in data_points:
                if project_name in point['projects']:
                    project_scores.append(point['projects'][project_name]['score'])

            if len(project_scores) >= 2:
                trend_analysis['project_trends'][project_name] = {
                    'current_score': project_scores[0],
                    'previous_score': project_scores[1],
                    'change': project_scores[0] - project_scores[1],
                    'direction': 'improving' if project_scores[0] > project_scores[1] else 'declining'
                }

    # Calculate averages and volatility
    if len(scores) > 1:
        trend_analysis['statistics'] = {
            'average_score': statistics.mean(scores),
            'score_volatility': statistics.stdev(scores) if len(scores) > 1 else 0,
            'best_score': max(scores),
            'worst_score': min(scores)
        }

    with open('${trend_report}', 'w') as f:
        json.dump(trend_analysis, f, indent=2)

    print(f'Trend analysis completed: {len(data_points)} data points analyzed')
else:
    print('Insufficient data for trend analysis')
"

    if [[ -f "${trend_report}" ]]; then
        log "Trend analysis completed: ${trend_report}"
    fi
}

# Generate security metrics report
generate_report() {
    log "Generating security metrics report..."

    local timestamp_str
    timestamp_str=$(date '+%Y%m%d_%H%M%S')
    local report_file="${REPORTS_DIR}/security_metrics_report_${timestamp_str}.md"

    # Get latest metrics
    local latest_metrics
    latest_metrics=$(ls -t "${HISTORY_DIR}"/security_metrics_*.json 2>/dev/null | head -1)

    if [[ -z "${latest_metrics}" ]]; then
        log "No metrics data available for report generation"
        return
    fi

    # Get trend data
    local date_today
    date_today=$(date '+%Y%m%d')
    local trend_data="${REPORTS_DIR}/security_trends_${date_today}.json"

    cat > "${report_file}" << EOF
# Security Metrics Report
Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Current Security Status

EOF

    # Add current metrics
    if [[ -f "${latest_metrics}" ]]; then
        jq -r '
            "## Overall Security Score: \(.security_score)%",
            "",
            "### Vulnerability Summary",
            "| Severity | Count |",
            "|----------|-------|",
            "| Critical | \(.vulnerabilities.critical) |",
            "| High     | \(.vulnerabilities.high) |",
            "| Medium   | \(.vulnerabilities.medium) |",
            "| Low      | \(.vulnerabilities.low) |",
            "",
            "### Project Scores",
            "| Project | Score | Issues |",
            "|---------|-------|--------|"
        ' "${latest_metrics}" >> "${report_file}"

        # Add project details
        jq -r '.projects | to_entries[] | "| \(.key) | \(.value.score)% | \(.value.issues) |"' "${latest_metrics}" >> "${report_file}"

        echo "" >> "${report_file}"
    fi

    # Add trend analysis
    if [[ -f "${trend_data}" ]]; then
        cat >> "${report_file}" << EOF

## Security Trends

EOF

        jq -r '
            "Period: \(.period.start) to \(.period.end) (\(.period.data_points) data points)",
            "",
            "### Overall Trend",
            "- Security Score: \(.overall_trend.security_score.current)% (change: \(.overall_trend.security_score.change)) - \(.overall_trend.security_score.direction)",
            "- Critical Vulnerabilities: \(.overall_trend.critical_vulnerabilities.current) (change: \(.overall_trend.critical_vulnerabilities.change))",
            ""
        ' "${trend_data}" >> "${report_file}"

        # Add project trends
        if jq -e '.project_trends | length > 0' "${trend_data}" > /dev/null 2>&1; then
            echo "### Project Trends" >> "${report_file}"
            jq -r '.project_trends | to_entries[] | "- \(.key): \(.value.current_score)% (change: \(.value.change)) - \(.value.direction)"' "${trend_data}" >> "${report_file}"
            echo "" >> "${report_file}"
        fi

        # Add statistics
        if jq -e '.statistics' "${trend_data}" > /dev/null 2>&1; then
            cat >> "${report_file}" << EOF

### Statistics
EOF
            jq -r '
                .statistics |
                "- Average Score: \(.average_score | floor)%",
                "- Score Volatility: \(.score_volatility | . * 100 | floor | . / 100)",
                "- Best Score: \(.best_score)%",
                "- Worst Score: \(.worst_score)%"
            ' "${trend_data}" >> "${report_file}"
        fi
    fi

    cat >> "${report_file}" << EOF

## Recommendations

EOF

    # Generate recommendations based on current status
    if [[ -f "${latest_metrics}" ]]; then
        local critical_count
        critical_count=$(jq -r '.vulnerabilities.critical' "${latest_metrics}")
        local security_score
        security_score=$(jq -r '.security_score' "${latest_metrics}")

        if [[ ${critical_count} -gt 0 ]]; then
            echo "- **CRITICAL**: Address ${critical_count} critical vulnerabilities immediately" >> "${report_file}"
        fi

        if [[ ${security_score} -lt 50 ]]; then
            echo "- **HIGH PRIORITY**: Security score is critically low (${security_score}%). Immediate remediation required." >> "${report_file}"
        elif [[ ${security_score} -lt 70 ]]; then
            echo "- **MEDIUM PRIORITY**: Security score needs improvement (${security_score}%)." >> "${report_file}"
        else
            echo "- Security score is acceptable (${security_score}%). Continue monitoring." >> "${report_file}"
        fi

        # Project-specific recommendations
        jq -r '.projects | to_entries[] | select(.value.score < 70) | "- Review \(.key) project (score: \(.value.score)%)"' "${latest_metrics}" >> "${report_file}"
    fi

    log "Security metrics report generated: ${report_file}"
}

# Clean up old metrics files (keep last 90 days)
cleanup_old_metrics() {
    log "Cleaning up old metrics files..."

    # Remove files older than 90 days
    find "${HISTORY_DIR}" -name "security_metrics_*.json" -mtime +90 -delete 2>/dev/null || true
    find "${REPORTS_DIR}" -name "*.md" -mtime +90 -delete 2>/dev/null || true
    find "${REPORTS_DIR}" -name "*.json" -mtime +90 -delete 2>/dev/null || true

    log "Cleanup completed"
}

# Main execution
case "${1:-}" in
    "collect")
        init_directories
        collect_metrics
        ;;
    "analyze")
        init_directories
        analyze_trends
        ;;
    "report")
        init_directories
        generate_report
        ;;
    "full")
        init_directories
        collect_metrics
        analyze_trends
        generate_report
        cleanup_old_metrics
        ;;
    "cleanup")
        cleanup_old_metrics
        ;;
    *)
        echo "Usage: $0 {collect|analyze|report|full|cleanup}"
        echo "  collect  - Collect current security metrics"
        echo "  analyze  - Analyze security trends"
        echo "  report   - Generate security metrics report"
        echo "  full     - Run complete metrics collection and analysis"
        echo "  cleanup  - Clean up old metrics files"
        exit 1
        ;;
esac