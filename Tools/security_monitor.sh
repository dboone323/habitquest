#!/bin/bash
set -euo pipefail

# Security Monitoring Dashboard
# Performs static checks across Swift projects, updates metrics, and renders dashboard output.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
OUTPUT_DIR="${WORKSPACE_ROOT}/Tools"
AUTOMATION_DIR="${WORKSPACE_ROOT}/Tools/Automation"
METRICS_DIR="${AUTOMATION_DIR}/metrics"
LOG_DIR="${AUTOMATION_DIR}/logs"

DASHBOARD_FILE="${OUTPUT_DIR}/security_monitor_dashboard.html"
LOG_FILE="${LOG_DIR}/security_monitor.log"
ALERT_FILE="${LOG_DIR}/security_alerts.log"
METRICS_FILE="${METRICS_DIR}/security_metrics.json"

mkdir -p "${METRICS_DIR}" "${LOG_DIR}"

if [[ -t 1 ]]; then
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  BLUE=''
  NC=''
fi

log_info() {
  local message=$1
  printf '%s[%s] %s%s\n' "${BLUE}" "$(date '+%Y-%m-%d %H:%M:%S')" "${message}" "${NC}" | tee -a "${LOG_FILE}"
}

update_metrics_file() {
  local jq_script=$1
  shift || true
  local temp
  temp=$(mktemp)
  jq -M "$@" "${jq_script}" "${METRICS_FILE}" >"${temp}" && mv "${temp}" "${METRICS_FILE}"
}

append_alert() {
  local severity=$1
  local message=$2
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  # shellcheck disable=SC2016
  update_metrics_file '.alerts = ([{"timestamp":$ts,"severity":$sev,"message":$msg}] + (.alerts // []))[:50]' --arg ts "${timestamp}" --arg sev "${severity}" --arg msg "${message}"
  printf '[%s] [%s] %s\n' "${timestamp}" "${severity}" "${message}" >>"${ALERT_FILE}"
}

issue_alert() {
  local severity=$1
  local message=$2
  append_alert "${severity}" "${message}"
  log_info "ALERT [${severity}]: ${message}"
}

init_metrics() {
  if [[ -f ${METRICS_FILE} ]]; then
    return
  fi

  cat >"${METRICS_FILE}" <<'EOF'
{
  "last_scan": "",
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
}

run_static_scan() {
  python3 - "${WORKSPACE_ROOT}" <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
projects = [
    "CodingReviewer",
    "MomentumFinance",
    "HabitQuest",
    "PlannerApp",
    "AvoidObstaclesGame",
]

patterns = {
    "hardcoded_secrets": re.compile(r"(password|secret|api[_-]?key)\s*=", re.IGNORECASE),
    "sql_injection": re.compile(r"\b(SELECT|INSERT|UPDATE)\b.*\+", re.IGNORECASE),
    "weak_crypto": re.compile(r"\b(MD5|SHA1|DES|RC4)\b", re.IGNORECASE),
    "unsafe_http": re.compile(r"http://", re.IGNORECASE),
    "guard_pattern": re.compile(r"guard\s+.+let|if\s+.+==\s+nil", re.IGNORECASE),
}

result = {
    "projects": {},
    "totals": {"critical": 0, "high": 0, "medium": 0, "low": 0},
}

for project in projects:
    project_dir = root / "Projects" / project
    if not project_dir.is_dir():
        continue

    stats = {
        "swift_files": 0,
        "hardcoded_secrets": 0,
        "sql_injection": 0,
        "weak_crypto": 0,
        "unsafe_http": 0,
        "guard_matches": 0,
    }

    for swift_file in project_dir.rglob("*.swift"):
        try:
            content = swift_file.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        stats["swift_files"] += 1
        if patterns["hardcoded_secrets"].search(content):
            stats["hardcoded_secrets"] += 1
        if patterns["sql_injection"].search(content):
            stats["sql_injection"] += 1
        if patterns["weak_crypto"].search(content):
            stats["weak_crypto"] += 1
        if patterns["unsafe_http"].search(content):
            stats["unsafe_http"] += 1
        if patterns["guard_pattern"].search(content):
            stats["guard_matches"] += 1

    insufficient_validation = 0
    if stats["swift_files"] and stats["guard_matches"] * 2 < stats["swift_files"]:
        insufficient_validation = 1

    critical = stats["hardcoded_secrets"]
    high = stats["sql_injection"] + stats["weak_crypto"]
    medium = stats["unsafe_http"] + insufficient_validation
    low = 0

    score = 100 - (critical * 20) - (high * 10) - (medium * 5)
    score = max(score, 0)

    alerts = []
    if stats["hardcoded_secrets"]:
        alerts.append({
            "severity": "CRITICAL",
            "message": f"{project}: {stats['hardcoded_secrets']} file(s) contain potential hardcoded secrets",
        })
    if stats["sql_injection"]:
        alerts.append({
            "severity": "HIGH",
            "message": f"{project}: {stats['sql_injection']} file(s) may allow SQL injection",
        })
    if stats["weak_crypto"]:
        alerts.append({
            "severity": "HIGH",
            "message": f"{project}: {stats['weak_crypto']} file(s) reference weak cryptography",
        })
    if stats["unsafe_http"]:
        alerts.append({
            "severity": "MEDIUM",
            "message": f"{project}: {stats['unsafe_http']} file(s) use insecure HTTP URLs",
        })
    if insufficient_validation:
        alerts.append({
            "severity": "MEDIUM",
            "message": f"{project}: Many files lack guard or nil validation patterns",
        })

    result["projects"][project] = {
        "critical": critical,
        "high": high,
        "medium": medium,
        "low": low,
        "score": score,
        "issues": critical + high + medium + low,
        "alerts": alerts,
    }

    result["totals"]["critical"] += critical
    result["totals"]["high"] += high
    result["totals"]["medium"] += medium
    result["totals"]["low"] += low

print(json.dumps(result))
PY
}

update_project_metrics() {
  local project=$1
  local score=$2
  local issues=$3
  # shellcheck disable=SC2016
  update_metrics_file '.projects[$name].score = $score | .projects[$name].issues = $issues' --arg name "${project}" --argjson score "${score}" --argjson issues "${issues}"
}

update_overall_metrics() {
  local critical=$1
  local high=$2
  local medium=$3
  local low=$4
  local overall_score=$5
  # shellcheck disable=SC2016
  update_metrics_file '.last_scan = $ts | .vulnerabilities.critical = $crit | .vulnerabilities.high = $high | .vulnerabilities.medium = $med | .vulnerabilities.low = $low | .security_score = $score' \
    --arg ts "$(date '+%Y-%m-%d %H:%M:%S')" \
    --argjson crit "${critical}" --argjson high "${high}" --argjson med "${medium}" --argjson low "${low}" --argjson score "${overall_score}"
}

calculate_overall_score() {
  local critical=$1
  local high=$2
  local medium=$3
  local base=100
  local deduction=$((critical * 20 + high * 10 + medium * 5))
  local score=$((base - deduction))
  if ((score < 0)); then
    score=0
  fi
  printf '%s\n' "${score}"
}

perform_security_scan() {
  log_info "Starting security scan"
  init_metrics

  local scan_output
  if ! scan_output=$(run_static_scan); then
    log_info "Static scan failed"
    return 1
  fi

  local projects
  mapfile -t projects < <(jq -r '.projects | keys[]' <<<"${scan_output}")

  for project in "${projects[@]}"; do
    local score issues
    score=$(jq -r ".projects.\"${project}\".score" <<<"${scan_output}")
    issues=$(jq -r ".projects.\"${project}\".issues" <<<"${scan_output}")
    # shellcheck disable=SC2016
    update_project_metrics "${project}" "${score}" "${issues}"

    jq -c ".projects.\"${project}\".alerts[]?" <<<"${scan_output}" | while IFS= read -r alert_entry; do
      local severity message
      severity=$(jq -r '.severity' <<<"${alert_entry}")
      message=$(jq -r '.message' <<<"${alert_entry}")
      issue_alert "${severity}" "${message}"
    done

    log_info "${project} security score: ${score}% (${issues} issues)"
  done

  local critical high medium low overall_score
  critical=$(jq -r '.totals.critical' <<<"${scan_output}")
  high=$(jq -r '.totals.high' <<<"${scan_output}")
  medium=$(jq -r '.totals.medium' <<<"${scan_output}")
  low=$(jq -r '.totals.low' <<<"${scan_output}")
  overall_score=$(calculate_overall_score "${critical}" "${high}" "${medium}")

  update_overall_metrics "${critical}" "${high}" "${medium}" "${low}" "${overall_score}"

  local total=$((critical + high + medium + low))
  log_info "Security scan complete. Vulnerabilities tracked: ${total}"
}

generate_dashboard() {
  init_metrics
  log_info "Rendering security dashboard"

  local security_score last_scan critical_count high_count medium_count status_color status_text
  security_score=$(jq -r '.security_score' "${METRICS_FILE}")
  last_scan=$(jq -r '.last_scan' "${METRICS_FILE}")
  critical_count=$(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")
  high_count=$(jq -r '.vulnerabilities.high' "${METRICS_FILE}")
  medium_count=$(jq -r '.vulnerabilities.medium' "${METRICS_FILE}")

  status_color="#28a745"
  status_text="SECURE"
  if ((critical_count > 0)); then
    status_color="#dc3545"
    status_text="CRITICAL"
  elif ((high_count > 0)); then
    status_color="#fd7e14"
    status_text="WARNING"
  elif ((medium_count > 0)); then
    status_color="#ffc107"
    status_text="CAUTION"
  fi

  cat >"${DASHBOARD_FILE}" <<EOF
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
      <h1>Quantum Workspace Security Monitor</h1>
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

  jq -c '.projects | to_entries[]' "${METRICS_FILE}" | while IFS= read -r project_entry; do
    local project_name project_score project_issues project_color
    project_name=$(jq -r '.key' <<<"${project_entry}")
    project_score=$(jq -r '.value.score' <<<"${project_entry}")
    project_issues=$(jq -r '.value.issues' <<<"${project_entry}")

    project_color="#28a745"
    if ((project_issues > 5)); then
      project_color="#dc3545"
    elif ((project_issues > 2)); then
      project_color="#fd7e14"
    elif ((project_issues > 0)); then
      project_color="#ffc107"
    fi

    cat >>"${DASHBOARD_FILE}" <<EOF
      <div class="project-card">
        <h3>${project_name}</h3>
        <div class="project-score" style="color: ${project_color};">${project_score}%</div>
        <p>${project_issues} issues found</p>
      </div>
EOF
  done

  cat >>"${DASHBOARD_FILE}" <<'EOF'
    </div>

    <div class="alerts">
      <h2>Recent Security Alerts</h2>
EOF

  jq -c '(.alerts // [])[:10][]?' "${METRICS_FILE}" | while IFS= read -r alert_entry; do
    local severity message alert_class
    severity=$(jq -r '.severity' <<<"${alert_entry}")
    message=$(jq -r '.message' <<<"${alert_entry}")
    case "${severity}" in
    CRITICAL) alert_class="alert alert-critical" ;;
    HIGH) alert_class="alert alert-high" ;;
    MEDIUM) alert_class="alert alert-medium" ;;
    *) alert_class="alert" ;;
    esac
    printf '      <div class="%s">[%s] %s</div>\n' "${alert_class}" "${severity}" "${message}" >>"${DASHBOARD_FILE}"
  done

  cat >>"${DASHBOARD_FILE}" <<EOF
    </div>

    <div style="text-align: center;">
      <button class="refresh-btn" onclick="location.reload()">Refresh Dashboard</button>
    </div>

    <div style="text-align: center; margin-top: 20px; color: #666;">
      <p>Dashboard auto-refreshes every 5 minutes | Last updated: $(date '+%Y-%m-%d %H:%M:%S')</p>
    </div>
  </div>

  <script>
    setTimeout(function () {
      location.reload();
    }, 300000);
  </script>
</body>
</html>
EOF

  log_info "Security dashboard generated at ${DASHBOARD_FILE}"
}

start_monitoring() {
  log_info "Starting continuous monitoring"
  init_metrics

  while true; do
    perform_security_scan
    generate_dashboard

    local critical_count
    critical_count=$(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")
    if ((critical_count > 0)); then
      log_info "Critical vulnerabilities detected; escalation recommended"
    fi

    log_info "Monitoring cycle complete. Sleeping for 10 minutes"
    sleep 600
  done
}

print_status() {
  init_metrics
  printf 'Security Monitor Status:\n'
  printf 'Last scan: %s\n' "$(jq -r '.last_scan' "${METRICS_FILE}")"
  printf 'Security score: %s%%\n' "$(jq -r '.security_score' "${METRICS_FILE}")"
  printf 'Critical issues: %s\n' "$(jq -r '.vulnerabilities.critical' "${METRICS_FILE}")"
  printf 'High risk issues: %s\n' "$(jq -r '.vulnerabilities.high' "${METRICS_FILE}")"
  printf 'Medium risk issues: %s\n' "$(jq -r '.vulnerabilities.medium' "${METRICS_FILE}")"
}

show_usage() {
  cat <<'EOF'
Usage: security_monitor.sh <command>

Commands:
  scan       Run static analysis, update metrics, regenerate dashboard
  monitor    Continuously run scans every 10 minutes
  dashboard  Refresh dashboard using current metrics
  status     Print current metrics summary
EOF
}

main() {
  local command=${1:-help}
  case "${command}" in
  scan)
    perform_security_scan
    generate_dashboard
    ;;
  monitor)
    start_monitoring
    ;;
  dashboard)
    generate_dashboard
    ;;
  status)
    print_status
    ;;
  help | -h | --help)
    show_usage
    ;;
  *)
    printf 'Unknown command: %s\n' "${command}" >&2
    show_usage >&2
    return 1
    ;;
  esac
}

main "$@"
