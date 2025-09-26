#!/bin/bash
# Secure Configuration Management System
# Manages environment variables and secrets securely

WORKSPACE="/Users/danielstevens/Desktop/Quantum-workspace"
CONFIG_DIR="${WORKSPACE}/.secure"
ENV_FILE="${CONFIG_DIR}/.env.secure"
KEYCHAIN_SERVICE="com.quantum.workspace"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize secure configuration
init_secure_config() {
    echo -e "${BLUE}Initializing secure configuration...${NC}"

    # Create secure config directory
    mkdir -p "${CONFIG_DIR}"
    chmod 700 "${CONFIG_DIR}"

    # Create secure environment file if it doesn't exist
    if [[ ! -f "${ENV_FILE}" ]]; then
        cat > "${ENV_FILE}" << 'EOF'
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
        echo -e "${GREEN}Created secure environment file: ${ENV_FILE}${NC}"
        echo -e "${YELLOW}⚠️  IMPORTANT: Add your actual secrets$${to $}ENV_}FILE${NC}"
    fi
}

# Set a secure environment variable
set_secret() {
    local key="$1"
    local value="$2"

    if [[ -z "${key}" || -z "${value}" ]]; then
        echo -e "${RED}Error: Both key and value are required${NC}"
        return 1
    fi

    # Store in secure env file
    if [[ -f "${ENV_FILE}" ]]; then
        if grep -q "^${key}=" "${ENV_FILE}"; then
            # Update existing key
            sed -i.bak "s|^${key}=.*|${key}=\"${value}\"|" "${ENV_FILE}" && rm "${ENV_FILE}.bak"
        else
            # Add new key
            echo "${key}=\"${value}\"" >> "${ENV_FILE}"
        fi
        echo -e "${GREEN}Set secret: ${key}${NC}"
    else
        echo -e "${RED}Error: Secure config not initialized. Run 'init' first.${NC}"
        return 1
    fi
}

# Get a secure environment variable
get_secret() {
    local key="$1"

    if [[ -f "${ENV_FILE}" ]]; then
        local value
        value=$(grep "^${key}=" "${ENV_FILE}" | cut -d'=' -f2- | sed 's/^"//' | sed 's/"$//')
        if [[ -n "${value}" ]]; then
            echo "${value}"
        else
            echo -e "${YELLOW}Warning: Secret '${key}' not found${NC}" >&2
            return 1
        fi
    else
        echo -e "${RED}Error: Secure config not initialized${NC}" >&2
        return 1
    fi
}

# Generate a secure random key
generate_key() {
    local length="${1:-32}"
    local key_type="${2:-hex}"

    case "${key_type}" in
        "hex")
            openssl rand -hex "${length}"
            ;;
        "base64")
            openssl rand -base64 "${length}"
            ;;
        "alnum")
            openssl rand -hex "${length}" | tr -d '\n' | fold -w"$((length * 2))" | head -n1
            ;;
        *)
            echo -e "${RED}Error: Invalid key type. Use: hex, base64, or alnum${NC}"
            return 1
            ;;
    esac
}

# Validate configuration
validate_config() {
    echo -e "${BLUE}Validating secure configuration...${NC}"

    local issues=0

    # Check if config file exists and has correct permissions
    if [[ ! -f "${ENV_FILE}" ]]; then
        echo -e "${RED}❌ Secure config file missing${NC}"
        ((issues++))
    else
        local perms
        perms=$(stat -c "%a" "${ENV_FILE}" 2>/dev/null || stat -f "%A" "${ENV_FILE}" 2>/dev/null)
        if [[ "${perms}" != "600" ]]; then
            echo -e "${YELLOW}⚠️  Config file permissions should be 600 (curren$${${${${${}}y $p}erms)${NC}"
            ((issues++))
        fi
    fi

    # Check for empty required secrets
    if [[ -f "${ENV_FILE}" ]]; then
        local empty_secrets=()
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "${key}" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${key}" ]] && continue

            # Remove quotes from value
            value=$(echo "${value}" | sed 's/^"//' | sed 's/"$//')

            # Check if value is empty
            if [[ -z "${value}" ]]; then
                empty_secrets+=("${key}")
            fi
        done < "${ENV_FILE}"

        if [[ ${#empty_secrets[@]} -gt 0 ]]; then
            echo -e "${YELLOW}⚠️  Empty secrets found:${NC}"
            printf '   - %s\n' "${empty_secrets[@]}"
            ((issues++))
        fi
    fi

    if [[ ${issues} -eq 0 ]]; then
        echo -e "${GREEN}✅ Configuration validation passed${NC}"
    else
        echo -e "${YELLOW}Found ${issues} configuration issues${NC}"
    fi

    return "${issues}"
}

# Load environment variables from secure config
load_env() {
    if [[ -f "${ENV_FILE}" ]]; then
        # Source the file but only export non-empty values
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "${key}" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${key}" ]] && continue

            # Remove quotes from value
            value=$(echo "${value}" | sed 's/^"//' | sed 's/"$//')

            # Only export non-empty values
            if [[ -n "${value}" ]]; then
                export "${key}=${value}"
            fi
        done < "${ENV_FILE}"

        echo -e "${GREEN}Loaded secure environment variables${NC}"
    else
        echo -e "${RED}Error: Secure config file not found${NC}"
        return 1
    fi
}

# Backup configuration
backup_config() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${CONFIG_DIR}/backup_${timestamp}.env"

    if [[ -f "${ENV_FILE}" ]]; then
        cp "${ENV_FILE}" "${backup_file}"
        chmod 600 "${backup_file}"
        echo -e "${GREEN}Configuration backed up to: ${backup_file}${NC}"
    else
        echo -e "${RED}Error: No configuration file to backup${NC}"
        return 1
    fi
}

# Show configuration status
show_status() {
    echo -e "${BLUE}Secure Configuration Status${NC}"
    echo "=========================="

    if [[ -f "${ENV_FILE}" ]]; then
        echo -e "${GREEN}✅ Secure config file exists${NC}"

        local total_secrets=0
        local set_secrets=0

        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "${key}" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${key}" ]] && continue

            ((total_secrets++))

            # Remove quotes from value
            value=$(echo "${value}" | sed 's/^"//' | sed 's/"$//')

            if [[ -n "${value}" ]]; then
                ((set_secrets++))
            fi
        done < "${ENV_FILE}"

        echo "Total secrets configured: ${set_secrets} / ${total_secrets}"

        local perms
        perms=$(stat -c "%a" "${ENV_FILE}" 2>/dev/null || stat -f "%A" "${ENV_FILE}" 2>/dev/null)
        echo "File permissions: ${perms}"

    else
        echo -e "${RED}❌ Secure config file missing${NC}"
    fi

    echo ""
    echo "Config location: ${CONFIG_DIR}"
    echo "Environment file: ${ENV_FILE}"
}

# Main command handling
case "${1:-}" in
    "init")
        init_secure_config
        ;;
    "set")
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: $0 set <key> <value>"
            exit 1
        fi
        set_secret "$2" "$3"
        ;;
    "get")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 get <key>"
            exit 1
        fi
        get_secret "$2"
        ;;
    "generate")
        length="${2:-32}"
        type="${3:-hex}"
        generate_key "${length}" "${type}"
        ;;
    "validate")
        validate_config
        ;;
    "load")
        load_env
        ;;
    "backup")
        backup_config
        ;;
    "status")
        show_status
        ;;
    *)
        echo "Secure Configuration Management"
        echo "==============================="
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init                    Initialize secure configuration"
        echo "  set <key> <value>       Set a secret value"
        echo "  get <key>              Get a secret value"
        echo "  generate [length] [type] Generate a secure random key (hex/base64/alnum)"
        echo "  validate               Validate configuration"
        echo "  load                   Load environment variables"
        echo "  backup                 Backup configuration"
        echo "  status                 Show configuration status"
        echo ""
        echo "Examples:"
        echo "  $0 init"
        echo "  $0 set JWT_SECRET \"\$(openssl rand -hex 32)\""
        echo "  $0 generate 32 hex"
        echo "  $0 validate"
        exit 1
        ;;
esac