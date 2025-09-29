#!/bin/bash
set -euo pipefail

# Smart Agent Management System
# Provides intelligent monitoring, backup control, and performance optimization

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
AGENTS_DIR="${SCRIPT_DIR}"
LOG_DIR="${AGENTS_DIR}/logs"
BACKUP_DIR="${AGENTS_DIR}/backups"
METRICS_DIR="${AGENTS_DIR}/metrics"

mkdir -p "${LOG_DIR}" "${BACKUP_DIR}" "${METRICS_DIR}"

AGENT_CONFIG="${AGENTS_DIR}/agent_config.json"
PERFORMANCE_METRICS="${METRICS_DIR}/performance_metrics.json"
BACKUP_POLICY="${AGENTS_DIR}/backup_policy.json"

if [[ -t 1 ]]; then
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'
else
  BLUE=''
  YELLOW=''
  RED=''
  NC=''
fi

log_info() {
  printf '%s[%s] %s%s\n' "${BLUE}" "$(date -Iseconds)" "$1" "${NC}"
}

log_warn() {
  printf '%s[%s] %s%s\n' "${YELLOW}" "$(date -Iseconds)" "$1" "${NC}"
}

log_error() {
  printf '%s[%s] %s%s\n' "${RED}" "$(date -Iseconds)" "$1" "${NC}"
}

if [[ ! -f ${AGENT_CONFIG} ]]; then
  cat <<'EOF' >"${AGENT_CONFIG}"
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

if [[ ! -f ${BACKUP_POLICY} ]]; then
  cat <<'EOF' >"${BACKUP_POLICY}"
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

if [[ ! -f ${PERFORMANCE_METRICS} ]]; then
  cat <<'EOF' >"${PERFORMANCE_METRICS}"
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

get_json_value() {
  local query=$1
  local fallback=$2
  local result

  if [[ -f ${AGENT_CONFIG} ]] && result=$(jq -r "${query}" "${AGENT_CONFIG}" 2>/dev/null); then
    if [[ ${result} != "null" && -n ${result} ]]; then
      printf '%s' "${result}"
      return 0
    fi
  fi

  printf '%s' "${fallback}"
}

list_agents() {
  if [[ -f ${AGENT_CONFIG} ]]; then
    jq -r '.agents | keys[]' "${AGENT_CONFIG}" 2>/dev/null || true
  fi
}

should_backup() {
  local agent_name=$1
  local backup_type=$2
  local max_backups backup_interval

  max_backups=$(get_json_value ".agents.${agent_name}.max_backups" "5")
  backup_interval=$(get_json_value ".agents.${agent_name}.backup_interval" "3600")

  local backup_count
  backup_count=$(find "${BACKUP_DIR}" -type d -name "${agent_name}_*" 2>/dev/null | wc -l | tr -d ' ')

  if [[ ${backup_count} -ge ${max_backups} ]]; then
    log_warn "Backup limit reached for ${agent_name} (${backup_count} >= ${max_backups})"
    return 1
  fi

  local last_backup_dir='' newest_mtime=0
  while IFS= read -r -d '' candidate; do
    local mtime
    mtime=$(stat -f %m "${candidate}" 2>/dev/null || echo 0)
    if [[ ${mtime} -gt ${newest_mtime} ]]; then
      newest_mtime=${mtime}
      last_backup_dir="${candidate}"
    fi
  done < <(find "${BACKUP_DIR}" -type d -name "${agent_name}_*" -print0 2>/dev/null)

  if [[ -n ${last_backup_dir} ]]; then
    local last_backup_time current_time time_diff
    last_backup_time=$(stat -f %m "${last_backup_dir}" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    time_diff=$((current_time - last_backup_time))
    if [[ ${time_diff} -lt ${backup_interval} ]]; then
      log_warn "Too soon for ${backup_type} backup of ${agent_name} (${time_diff}s < ${backup_interval}s)"
      return 1
    fi
  fi

  return 0
}

cleanup_old_backups() {
  local agent_name=$1
  local max_backups retention_days

  max_backups=$(get_json_value ".agents.${agent_name}.max_backups" "5")
  retention_days=$(get_json_value ".global_settings.backup_retention_days" "7")

  log_info "Cleaning backups for ${agent_name}"

  find "${BACKUP_DIR}" -type d -name "${agent_name}_*" -mtime "+${retention_days}" -exec rm -rf {} + 2>/dev/null || true

  local backup_dirs=()
  if compgen -G "${BACKUP_DIR}/${agent_name}_*" >/dev/null 2>&1; then
    mapfile -t backup_dirs < <(ls -td "${BACKUP_DIR}/${agent_name}_*" 2>/dev/null)
  fi

  if ((${#backup_dirs[@]} > max_backups)); then
    for ((i = max_backups; i < ${#backup_dirs[@]}; i++)); do
      log_info "Removing old backup ${backup_dirs[i]}"
      rm -rf "${backup_dirs[i]}" 2>/dev/null || true
    done
  fi
}

backup_project() {
  local project=$1
  local backup_name=$2
  local project_path="${WORKSPACE_ROOT}/Projects/${project}"

  if [[ ! -d ${project_path} ]]; then
    log_warn "Project ${project} not found at ${project_path}"
    return 1
  fi

  local backup_path="${BACKUP_DIR}/${backup_name}"
  mkdir -p "${backup_path}"

  log_info "Creating compressed backup of ${project}"

  (
    cd "${WORKSPACE_ROOT}/Projects" &&
      tar -czf "${backup_path}/${project}.tar.gz" "${project}"
  ) || return 1

  local original_size compressed_size
  original_size=$(du -sh "${project_path}" 2>/dev/null | cut -f1 || echo "0")
  compressed_size=$(du -sh "${backup_path}/${project}.tar.gz" 2>/dev/null | cut -f1 || echo "0")

  cat >"${backup_path}/metadata.json" <<EOF
{
    "project": "${project}",
    "timestamp": "$(date -Iseconds)",
    "type": "compressed",
    "original_size": "${original_size}",
    "compressed_size": "${compressed_size}",
    "created_by": "smart_agent_manager"
}
EOF

  log_info "Backup created at ${backup_path}"
}

backup_agent_state() {
  local agent_name=$1
  local backup_name=$2
  local backup_path="${BACKUP_DIR}/${backup_name}"

  mkdir -p "${backup_path}"
  log_info "Backing up state for ${agent_name}"

  if compgen -G "${AGENTS_DIR}"/*.log >/dev/null 2>&1; then
    cp "${AGENTS_DIR}"/*.log "${backup_path}/" 2>/dev/null || true
  fi
  if compgen -G "${AGENTS_DIR}"/*.json >/dev/null 2>&1; then
    cp "${AGENTS_DIR}"/*.json "${backup_path}/" 2>/dev/null || true
  fi
  if compgen -G "${AGENTS_DIR}"/*.sh >/dev/null 2>&1; then
    cp "${AGENTS_DIR}"/*.sh "${backup_path}/" 2>/dev/null || true
  fi

  local backed_up_count
  backed_up_count=$(find "${backup_path}" -type f 2>/dev/null | wc -l | tr -d ' ')

  cat >"${backup_path}/metadata.json" <<EOF
{
    "agent": "${agent_name}",
    "timestamp": "$(date -Iseconds)",
    "type": "agent_state",
    "files_backed_up": ${backed_up_count},
    "created_by": "smart_agent_manager"
}
EOF

  log_info "Agent state backup stored at ${backup_path}"
}

smart_backup() {
  local agent_name=${1-}
  local project=${2-}
  local backup_type=${3:-smart}

  if [[ -z ${agent_name} ]]; then
    log_error "Usage: smart_agent_manager.sh backup <agent> [project] [type]"
    return 1
  fi

  log_info "Starting ${backup_type} backup for ${agent_name}"

  if should_backup "${agent_name}" "${backup_type}"; then
    cleanup_old_backups "${agent_name}"

    local timestamp backup_name
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_name="${agent_name}_${backup_type}_${timestamp}"

    if [[ -n ${project} ]]; then
      backup_project "${project}" "${backup_name}"
    else
      backup_agent_state "${agent_name}" "${backup_name}"
    fi

    update_backup_metrics
    log_info "${backup_type} backup completed for ${agent_name}"
  else
    log_info "Skipping backup for ${agent_name}; conditions not met"
  fi
}

update_backup_metrics() {
  local total_size total_count oldest_backup newest_backup
  total_size=$(du -sm "${BACKUP_DIR}" 2>/dev/null | cut -f1 || echo 0)
  total_count=$(find "${BACKUP_DIR}" -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

  local entries=()
  while IFS= read -r -d '' dir; do
    local mtime
    mtime=$(stat -f %m "${dir}" 2>/dev/null || echo 0)
    entries+=("${mtime}:${dir}")
  done < <(find "${BACKUP_DIR}" -mindepth 1 -type d -print0 2>/dev/null)

  oldest_backup=""
  newest_backup=""
  if ((${#entries[@]} > 0)); then
    local sorted=()
    mapfile -t sorted < <(printf '%s\n' "${entries[@]}" | sort -n)
    oldest_backup="${sorted[0]#*:}"
    local last_index=$((${#sorted[@]} - 1))
    if ((last_index >= 0)); then
      newest_backup="${sorted[last_index]#*:}"
    fi
  fi

  jq --arg total_size "${total_size}" \
    --arg total_count "${total_count}" \
    --arg oldest_backup "${oldest_backup}" \
    --arg newest_backup "${newest_backup}" \
    --arg timestamp "$(date -Iseconds)" \
    '.timestamp = $timestamp |
         .backups.total_size_mb = ($total_size | tonumber) |
         .backups.total_count = ($total_count | tonumber) |
         .backups.oldest_backup = $oldest_backup |
         .backups.newest_backup = $newest_backup' \
    "${PERFORMANCE_METRICS}" >"${PERFORMANCE_METRICS}.tmp" && mv "${PERFORMANCE_METRICS}.tmp" "${PERFORMANCE_METRICS}"
}

monitor_agent_health() {
  local agent_name=${1-}
  if [[ -z ${agent_name} ]]; then
    log_error "Usage: smart_agent_manager.sh monitor <agent>"
    return 1
  fi

  local agent_script
  agent_script=$(get_json_value ".agents.${agent_name}.script" "")

  if [[ -z ${agent_script} ]]; then
    log_warn "Agent ${agent_name} not configured"
    return 1
  fi

  local pid_file="${AGENTS_DIR}/${agent_script}.pid"
  if [[ -f ${pid_file} ]]; then
    local pid
    pid=$(cat "${pid_file}" 2>/dev/null || echo "")
    if [[ -n ${pid} ]] && kill -0 "${pid}" 2>/dev/null; then
      log_info "Agent ${agent_name} running (PID ${pid})"
      return 0
    fi
    rm -f "${pid_file}" 2>/dev/null || true
    log_warn "Agent ${agent_name} PID file stale"
  fi

  local log_file="${AGENTS_DIR}/${agent_script%.sh}.log"
  if [[ -f ${log_file} ]]; then
    local last_activity current_time time_diff
    last_activity=$(stat -f %m "${log_file}" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    time_diff=$((current_time - last_activity))
    if [[ ${time_diff} -le 3600 ]]; then
      log_info "Agent ${agent_name} recently active (${time_diff}s ago)"
      return 0
    fi
    log_warn "Agent ${agent_name} inactive for ${time_diff}s"
  else
    log_warn "Agent ${agent_name} log file not found"
  fi

  return 1
}

get_system_metrics() {
  local cpu_usage memory_usage disk_usage
  cpu_usage=$(ps aux | awk '{sum += $3} END {print sum}' 2>/dev/null || echo 0)
  memory_usage=$(ps aux | awk '{sum += $4} END {print sum * 1024 / 100}' 2>/dev/null || echo 0)
  disk_usage=$(df "${WORKSPACE_ROOT}" | awk 'NR==2 {gsub("%", "", $5); print $5}' 2>/dev/null || echo 0)

  jq --arg cpu_usage "${cpu_usage}" \
    --arg memory_usage "${memory_usage}" \
    --arg disk_usage "${disk_usage}" \
    '.system.cpu_usage = ($cpu_usage | tonumber) |
         .system.memory_usage = ($memory_usage | tonumber) |
         .system.disk_usage = ($disk_usage | tonumber)' \
    "${PERFORMANCE_METRICS}" >"${PERFORMANCE_METRICS}.tmp" && mv "${PERFORMANCE_METRICS}.tmp" "${PERFORMANCE_METRICS}"
}

show_status() {
  printf '=== Smart Agent Management System Status ===\n'
  printf 'Configuration: %s\n' "${AGENT_CONFIG}"
  printf 'Backup Directory: %s\n' "${BACKUP_DIR}"
  printf 'Log Directory: %s\n' "${LOG_DIR}"
  printf 'Metrics File: %s\n\n' "${PERFORMANCE_METRICS}"

  printf '=== Agent Status ===\n'
  local any_agents=false
  while IFS= read -r agent; do
    any_agents=true
    if monitor_agent_health "${agent}" >/dev/null; then
      printf '  - %s: running\n' "${agent}"
    else
      printf '  - %s: not running or unhealthy\n' "${agent}"
    fi
  done < <(list_agents)

  if [[ ${any_agents} == false ]]; then
    printf '  (no agents configured)\n'
  fi

  printf '\n=== Backup Status ===\n'
  update_backup_metrics
  jq -r '.backups | "Total backups: \(.total_count)"\n"Total size: \(.total_size_mb) MB"\n"Oldest: \(.oldest_backup)"\n"Newest: \(.newest_backup)"' "${PERFORMANCE_METRICS}" 2>/dev/null || printf 'Unable to read backup metrics\n'
}

print_help() {
  cat <<'EOF'
Smart Agent Management System

Usage: smart_agent_manager.sh <command> [options]

Commands:
  backup <agent> [project] [type]   Create a backup (default type: smart)
  monitor <agent>                   Check agent health
  cleanup                           Remove old backups per policy
  metrics                           Update and print system metrics
  status                            Show overall status summary
  help                              Display this help text

Examples:
  smart_agent_manager.sh backup build_agent CodingReviewer smart
  smart_agent_manager.sh monitor debug_agent
  smart_agent_manager.sh cleanup
EOF
}

main() {
  local command=${1:-help}
  shift || true

  case "${command}" in
  backup)
    smart_backup "$@"
    ;;
  monitor)
    monitor_agent_health "$@"
    ;;
  cleanup)
    log_info "Running backup cleanup"
    while IFS= read -r agent; do
      cleanup_old_backups "${agent}"
    done < <(list_agents)
    update_backup_metrics
    ;;
  metrics)
    get_system_metrics
    cat "${PERFORMANCE_METRICS}"
    ;;
  status)
    show_status
    ;;
  help | "" | -h | --help)
    print_help
    ;;
  *)
    log_error "Unknown command: ${command}"
    print_help
    return 1
    ;;
  esac
}

main "$@"
