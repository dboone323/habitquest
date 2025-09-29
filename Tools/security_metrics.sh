#!/bin/bash
set -euo pipefail

# Security Metrics Collection and Analysis
# Tracks security trends and generates reports

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
METRICS_DIR="${WORKSPACE_ROOT}/Tools/Automation/metrics"
HISTORY_DIR="${METRICS_DIR}/history"
REPORTS_DIR="${METRICS_DIR}/reports"
LOG_FILE="${WORKSPACE_ROOT}/Tools/Automation/logs/security_metrics.log"
CURRENT_METRICS="${METRICS_DIR}/security_metrics.json"

mkdir -p "${HISTORY_DIR}" "${REPORTS_DIR}" "$(dirname "${LOG_FILE}")"

if [[ -t 1 ]]; then
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  BLUE=''
  NC=''
fi

log_info() {
  printf '%s[%s] %s%s\n' "${BLUE}" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "${NC}" | tee -a "${LOG_FILE}"
}

latest_metric_file() {
  python3 - "${HISTORY_DIR}" <<'PY' || true
import os
import sys
from pathlib import Path

history_dir = Path(sys.argv[1])
files = sorted(history_dir.glob('security_metrics_*.json'), key=os.path.getmtime, reverse=True)
if files:
    print(files[0])
PY
}

collect_metrics() {
  log_info "Collecting current security metrics"

  if [[ ! -f "${SCRIPT_DIR}/security_monitor.sh" ]]; then
    log_info "security_monitor.sh not found; skipping scan"
  else
    if ! (cd "${SCRIPT_DIR}" && ./security_monitor.sh scan >/dev/null 2>&1); then
      log_info "security_monitor.sh scan failed; continuing"
    fi
  fi

  if [[ ! -f ${CURRENT_METRICS} ]]; then
    log_info "Current metrics file not found at ${CURRENT_METRICS}"
    return 1
  fi

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local dest="${HISTORY_DIR}/security_metrics_${timestamp}.json"

  jq --arg ts "${timestamp}" \
    --arg collected "$(date '+%Y-%m-%d %H:%M:%S')" \
    '.timestamp = $ts | .collection_date = $collected' \
    "${CURRENT_METRICS}" >"${dest}"

  log_info "Stored metrics snapshot at ${dest}"
}

analyze_trends() {
  log_info "Analyzing security trends"

  local trend_report
  trend_report="${REPORTS_DIR}/security_trends_$(date '+%Y%m%d').json"

  python3 - "${HISTORY_DIR}" "${trend_report}" <<'PY' || exit 1
import json
import os
import statistics
import sys
from pathlib import Path

history_dir = Path(sys.argv[1])
output_path = Path(sys.argv[2])

files = sorted(history_dir.glob('security_metrics_*.json'), key=os.path.getmtime, reverse=True)
files = files[:30]

if len(files) < 2:
    print('Insufficient data for trend analysis')
    sys.exit(0)

data_points = []
for file in files:
    try:
        with file.open('r', encoding='utf-8') as handle:
            data = json.load(handle)
    except (json.JSONDecodeError, OSError):
        continue
    data_points.append(
        {
            "timestamp": data.get("timestamp", ""),
            "date": data.get("collection_date", ""),
            "security_score": data.get("security_score", 0),
            "vulnerabilities": data.get("vulnerabilities", {}),
            "projects": data.get("projects", {}),
        }
    )

if len(data_points) < 2:
    print('Insufficient clean data for trend analysis')
    sys.exit(0)

scores = [point["security_score"] for point in data_points]
critical_counts = [point["vulnerabilities"].get("critical", 0) for point in data_points]

trend = {
    "period": {
        "start": data_points[-1]["date"],
        "end": data_points[0]["date"],
        "data_points": len(data_points),
    },
    "overall_trend": {
        "security_score": {
            "current": scores[0],
            "previous": scores[1],
            "change": scores[0] - scores[1],
            "direction": "improving" if scores[0] > scores[1] else "declining" if scores[0] < scores[1] else "stable",
        },
        "critical_vulnerabilities": {
            "current": critical_counts[0],
            "previous": critical_counts[1],
            "change": critical_counts[0] - critical_counts[1],
        },
    },
    "project_trends": {},
}

latest_projects = data_points[0]["projects"] or {}
for project, values in latest_projects.items():
    project_scores = [point["projects"].get(project, {}).get("score") for point in data_points]
    project_scores = [score for score in project_scores if score is not None]
    if len(project_scores) < 2:
        continue
    trend["project_trends"][project] = {
        "current_score": project_scores[0],
        "previous_score": project_scores[1],
        "change": project_scores[0] - project_scores[1],
        "direction": "improving" if project_scores[0] > project_scores[1] else "declining",
    }

if len(scores) > 1:
    trend["statistics"] = {
        "average_score": statistics.mean(scores),
        "score_volatility": statistics.stdev(scores) if len(scores) > 1 else 0,
        "best_score": max(scores),
        "worst_score": min(scores),
    }

output_path.parent.mkdir(parents=True, exist_ok=True)
with output_path.open('w', encoding='utf-8') as handle:
    json.dump(trend, handle, indent=2)

print(f'Trend analysis written to {output_path}')
PY

  log_info "Trend analysis complete"
}

generate_report() {
  log_info "Generating security metrics report"

  local latest
  latest=$(latest_metric_file)
  if [[ -z ${latest} ]]; then
    log_info "No metrics snapshots available"
    return 1
  fi

  local report
  report="${REPORTS_DIR}/security_metrics_report_$(date '+%Y%m%d_%H%M%S').md"
  local trend_file
  trend_file="${REPORTS_DIR}/security_trends_$(date '+%Y%m%d').json"

  {
    printf '# Security Metrics Report\nGenerated: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    printf '## Current Security Status\n\n'
  } >"${report}"

  {
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
    ' "${latest}"
    jq -r '.projects | to_entries[] | "| \(.key) | \(.value.score)% | \(.value.issues) |"' "${latest}"
    printf '\n'
  } >>"${report}"

  if [[ -f ${trend_file} ]]; then
    {
      printf '## Security Trends\n\n'
      jq -r '
        "Period: \(.period.start) to \(.period.end) (\(.period.data_points) data points)",
        "",
        "### Overall Trend",
        "- Security Score: \(.overall_trend.security_score.current)% (change: \(.overall_trend.security_score.change)) - \(.overall_trend.security_score.direction)",
        "- Critical Vulnerabilities: \(.overall_trend.critical_vulnerabilities.current) (change: \(.overall_trend.critical_vulnerabilities.change))",
        ""
      ' "${trend_file}"

      if jq -e '.project_trends | length > 0' "${trend_file}" >/dev/null 2>&1; then
        jq -r '
          "### Project Trends",
          (.project_trends | to_entries[] | "- \(.key): \(.value.current_score)% (change: \(.value.change)) - \(.value.direction)")
        ' "${trend_file}"
        printf '\n'
      fi

      if jq -e '.statistics' "${trend_file}" >/dev/null 2>&1; then
        jq -r '
          "### Statistics",
          (.statistics |
            "- Average Score: \(.average_score | floor)%",
            "- Score Volatility: \(.score_volatility)",
            "- Best Score: \(.best_score)%",
            "- Worst Score: \(.worst_score)%"
          )
        ' "${trend_file}"
        printf '\n'
      fi
    } >>"${report}"
  fi

  {
    printf '## Recommendations\n\n'
    local critical_count security_score
    critical_count=$(jq -r '.vulnerabilities.critical' "${latest}")
    security_score=$(jq -r '.security_score' "${latest}")

    if ((critical_count > 0)); then
      printf '- **CRITICAL**: Address %s critical vulnerabilities immediately\n' "${critical_count}"
    fi

    if ((security_score < 50)); then
      printf '- **HIGH PRIORITY**: Security score is critically low (%s%%). Immediate remediation required.\n' "${security_score}"
    elif ((security_score < 70)); then
      printf '- **MEDIUM PRIORITY**: Security score needs improvement (%s%%).\n' "${security_score}"
    else
      printf '- Security score is acceptable (%s%%). Continue monitoring.\n' "${security_score}"
    fi

    jq -r '.projects | to_entries[] | select(.value.score < 70) | "- Review \(.key) project (score: \(.value.score)%)"' "${latest}"
  } >>"${report}"

  log_info "Report generated at ${report}"
}

cleanup_old_metrics() {
  log_info "Cleaning up metrics older than 90 days"
  find "${HISTORY_DIR}" -type f -name 'security_metrics_*.json' -mtime +90 -delete 2>/dev/null || true
  find "${REPORTS_DIR}" -type f \( -name '*.md' -o -name '*.json' \) -mtime +90 -delete 2>/dev/null || true
}

main() {
  local command=${1:-help}
  case "${command}" in
  collect)
    collect_metrics
    ;;
  analyze)
    analyze_trends
    ;;
  report)
    generate_report
    ;;
  full)
    collect_metrics
    analyze_trends
    generate_report
    cleanup_old_metrics
    ;;
  cleanup)
    cleanup_old_metrics
    ;;
  help | "" | -h | --help)
    cat <<'EOF'
Usage: security_metrics.sh <command>

Commands:
  collect   Capture a new metrics snapshot
  analyze   Build security trend data
  report    Generate the latest Markdown report
  full      Run collect, analyze, report, then cleanup
  cleanup   Remove reports and metrics older than 90 days
EOF
    ;;
  *)
    printf 'Unknown command: %s\n' "${command}" >&2
    return 1
    ;;
  esac
}

main "$@"
