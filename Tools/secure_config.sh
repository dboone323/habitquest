#!/bin/bash
set -euo pipefail

# Secure Configuration Management System
# Manages environment variables and secrets securely

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
CONFIG_DIR="${WORKSPACE_ROOT}/.secure"
ENV_FILE="${CONFIG_DIR}/.env.secure"

if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

print_info() {
  printf '%s%s%s\n' "${BLUE}" "$1" "${NC}"
}

print_success() {
  printf '%s%s%s\n' "${GREEN}" "$1" "${NC}"
}

print_warning() {
  printf '%s%s%s\n' "${YELLOW}" "$1" "${NC}"
}

print_error() {
  printf '%s%s%s\n' "${RED}" "$1" "${NC}"
}

init_secure_config() {
  print_info "Initializing secure configuration..."

  mkdir -p "${CONFIG_DIR}"
  chmod 700 "${CONFIG_DIR}"

  if [[ ! -f ${ENV_FILE} ]]; then
    cat >"${ENV_FILE}" <<'EOF'
# Secure Environment Configuration
# This file contains sensitive configuration
# DO NOT commit to version control

# JWT Configuration
JWT_SECRET=""

# API Keys (add your keys here)
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
GROQ_API_KEY=""

# Database Configuration
DATABASE_URL=""
DB_PASSWORD=""

# Cloud Services
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AZURE_STORAGE_KEY=""
GOOGLE_CLOUD_KEY=""

# Application Secrets
APP_SECRET_KEY=""
ENCRYPTION_KEY=""
SESSION_SECRET=""

# Development/Production flags
ENVIRONMENT="development"
DEBUG="false"
EOF
    chmod 600 "${ENV_FILE}"
    print_success "Created secure environment file: ${ENV_FILE}"
    print_warning "Important: Populate the secrets in ${ENV_FILE} before running in production."
  fi
}

set_secret() {
  local key=${1-}
  local value=${2-}

  if [[ -z ${key} || -z ${value} ]]; then
    print_error "Error: Both key and value are required."
    return 1
  fi

  if [[ ! -f ${ENV_FILE} ]]; then
    print_error "Error: Secure config not initialized. Run 'init' first."
    return 1
  fi

  if grep -q "^${key}=" "${ENV_FILE}"; then
    local tmp_file
    tmp_file=$(mktemp)
    awk -v key="${key}" -v value="${value}" '
            BEGIN { replaced = 0 }
            /^[[:space:]]*$/ { print; next }
            $0 ~ "^[[:space:]]*#" { print; next }
            substr($0, 1, length(key) + 1) == key "=" {
                printf "%s=\"%s\"\n", key, value
                replaced = 1
                next
            }
            { print }
            END {
                if (replaced == 0) {
                    printf "%s=\"%s\"\n", key, value
                }
            }
        ' "${ENV_FILE}" >"${tmp_file}"
    mv "${tmp_file}" "${ENV_FILE}"
  else
    printf '%s="%s"\n' "${key}" "${value}" >>"${ENV_FILE}"
  fi

  chmod 600 "${ENV_FILE}"
  print_success "Set secret: ${key}"
}

get_secret() {
  local key=${1-}

  if [[ -z ${key} ]]; then
    print_error "Error: Key is required."
    return 1
  fi

  if [[ ! -f ${ENV_FILE} ]]; then
    print_error "Error: Secure config not initialized."
    return 1
  fi

  local raw
  raw=$(grep "^${key}=" "${ENV_FILE}" | head -n1 || true)
  if [[ -z ${raw} ]]; then
    print_warning "Warning: Secret '${key}' not found."
    return 1
  fi

  local value=${raw#*=}
  value=${value#\"}
  value=${value%\"}
  printf '%s\n' "${value}"
}

generate_key() {
  local length=${1:-32}
  local key_type=${2:-hex}

  case "${key_type}" in
  hex)
    openssl rand -hex "${length}"
    ;;
  base64)
    openssl rand -base64 "${length}"
    ;;
  alnum)
    openssl rand -base64 "$((length * 2))" | tr -dc 'A-Za-z0-9' | head -c "${length}"
    ;;
  *)
    print_error "Error: Invalid key type. Use hex, base64, or alnum."
    return 1
    ;;
  esac
}

get_permissions() {
  local target=$1
  local perms

  if perms=$(stat -f '%04OLp' "${target}" 2>/dev/null); then
    printf '%s\n' "${perms#0}"
    return 0
  fi

  if perms=$(stat -c '%a' "${target}" 2>/dev/null); then
    printf '%s\n' "${perms}"
    return 0
  fi

  return 1
}

validate_config() {
  print_info "Validating secure configuration..."

  local issues=0

  if [[ ! -f ${ENV_FILE} ]]; then
    print_error "Secure config file missing."
    ((issues++))
  else
    local perms
    if perms=$(get_permissions "${ENV_FILE}"); then
      if [[ ${perms} != "600" ]]; then
        print_warning "Config file permissions should be 600 (current: ${perms})."
        ((issues++))
      fi
    else
      print_warning "Unable to determine file permissions for ${ENV_FILE}."
    fi
  fi

  if [[ -f ${ENV_FILE} ]]; then
    local empty_secrets=()
    while IFS='=' read -r key value; do
      [[ -z ${key} ]] && continue
      [[ ${key} =~ ^[[:space:]]*# ]] && continue

      value=${value#\"}
      value=${value%\"}
      if [[ -z ${value} ]]; then
        empty_secrets+=("${key}")
      fi
    done <"${ENV_FILE}"

    if ((${#empty_secrets[@]} > 0)); then
      print_warning "Empty secrets found:"
      printf '  - %s\n' "${empty_secrets[@]}"
      ((issues++))
    fi
  fi

  if ((issues == 0)); then
    print_success "Configuration validation passed."
  else
    print_warning "Found ${issues} configuration issue(s)."
  fi

  return "${issues}"
}

load_env() {
  if [[ ! -f ${ENV_FILE} ]]; then
    print_error "Error: Secure config file not found."
    return 1
  fi

  while IFS='=' read -r key value; do
    [[ -z ${key} ]] && continue
    [[ ${key} =~ ^[[:space:]]*# ]] && continue

    value=${value#\"}
    value=${value%\"}

    if [[ -n ${value} ]]; then
      export "${key}=${value}"
    fi
  done <"${ENV_FILE}"

  print_success "Loaded secure environment variables."
}

backup_config() {
  if [[ ! -f ${ENV_FILE} ]]; then
    print_error "Error: No configuration file to back up."
    return 1
  fi

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local backup_file="${CONFIG_DIR}/backup_${timestamp}.env"

  cp "${ENV_FILE}" "${backup_file}"
  chmod 600 "${backup_file}"
  print_success "Configuration backed up to: ${backup_file}"
}

show_status() {
  print_info "Secure Configuration Status"
  printf '==========================\n'

  if [[ -f ${ENV_FILE} ]]; then
    print_success "Secure config file exists."

    local total_secrets=0
    local set_secrets=0

    while IFS='=' read -r key value; do
      [[ -z ${key} ]] && continue
      [[ ${key} =~ ^[[:space:]]*# ]] && continue

      ((total_secrets++))

      value=${value#\"}
      value=${value%\"}
      if [[ -n ${value} ]]; then
        ((set_secrets++))
      fi
    done <"${ENV_FILE}"

    printf 'Total secrets configured: %d / %d\n' "${set_secrets}" "${total_secrets}"

    local perms
    if perms=$(get_permissions "${ENV_FILE}"); then
      printf 'File permissions: %s\n' "${perms}"
    fi
  else
    print_error "Secure config file missing."
  fi

  printf '\nConfig directory: %s\n' "${CONFIG_DIR}"
  printf 'Environment file: %s\n' "${ENV_FILE}"
}

print_usage() {
  cat <<'EOF'
Secure Configuration Management
===============================
Usage: secure_config.sh <command> [options]

Commands:
  init                        Initialize secure configuration storage
  set <key> <value>           Set a secret value
  get <key>                  Get a secret value
  generate [len] [type]       Generate a secure random key (hex/base64/alnum)
  validate                   Validate configuration and permissions
  load                       Export secrets into the current shell
  backup                     Back up the secure environment file
  status                     Display configuration summary
EOF
}

main() {
  local command=${1-}

  case "${command}" in
  init)
    init_secure_config
    ;;
  set)
    if [[ $# -lt 3 ]]; then
      print_error "Usage: secure_config.sh set <key> <value>"
      return 1
    fi
    set_secret "$2" "$3"
    ;;
  get)
    if [[ $# -lt 2 ]]; then
      print_error "Usage: secure_config.sh get <key>"
      return 1
    fi
    get_secret "$2"
    ;;
  generate)
    generate_key "${2:-32}" "${3:-hex}"
    ;;
  validate)
    validate_config
    ;;
  load)
    load_env
    ;;
  backup)
    backup_config
    ;;
  status)
    show_status
    ;;
  "" | -h | --help)
    print_usage
    ;;
  *)
    print_error "Unknown command: ${command}"
    print_usage
    return 1
    ;;
  esac
}

main "$@"
