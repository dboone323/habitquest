#!/bin/bash
# Quantum Workspace Tool Health Monitor - Simplified Version
# Monitors health of essential tools in the optimized ecosystem

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
DASHBOARD_DATA_FILE="${WORKSPACE_DIR}/Tools/dashboard_data.json"
LOG_FILE="${WORKSPACE_DIR}/Tools/logs/tool_health_$(date +%Y%m%d).log"

# Essential tools to monitor
ESSENTIAL_TOOLS=(
    "git"
    "python3"
    "node"
    "npm"
    "brew"
    "ollama"
    "jq"
    "swiftlint"
    "swiftformat"
    "xcodebuild"
    "swift"
    "fastlane"
    "pod"
    "gh"
)

log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $*" | tee -a "$LOG_FILE"
}

check_tool() {
    local tool="$1"
    local status="unknown"
    local version="unknown"

    if command -v "$tool" &>/dev/null; then
        # Get version for some tools
        case "$tool" in
            "git")
                version=$(git --version | sed 's/git version //' 2>/dev/null || echo "unknown")
                status="healthy"
                ;;
            "python3")
                version=$(python3 --version 2>&1 | sed 's/Python //' || echo "unknown")
                status="healthy"
                ;;
            "node")
                version=$(node --version 2>/dev/null || echo "unknown")
                status="healthy"
                ;;
            "npm")
                version=$(npm --version 2>/dev/null || echo "unknown")
                status="healthy"
                ;;
            "brew")
                version=$(brew --version 2>/dev/null | head -1 || echo "unknown")
                status="healthy"
                ;;
            "ollama")
                if ollama list &>/dev/null 2>&1; then
                    version="available"
                    status="healthy"
                else
                    version="unavailable"
                    status="unhealthy"
                fi
                ;;
            "jq")
                version=$(jq --version 2>/dev/null || echo "unknown")
                status="healthy"
                ;;
            "swiftlint")
                version=$(swiftlint --version 2>/dev/null | head -1 || echo "unknown")
                status="healthy"
                ;;
            "swiftformat")
                version=$(swiftformat --version 2>/dev/null | head -1 || echo "unknown")
                status="healthy"
                ;;
            "xcodebuild")
                version=$(xcodebuild -version 2>&1 | head -1 | sed 's/.* version //' || echo "unknown")
                status="healthy"
                ;;
            "swift")
                version=$(swift --version 2>&1 | head -1 | sed 's/.* version //' || echo "unknown")
                status="healthy"
                ;;
            "fastlane")
                version=$(fastlane --version 2>/dev/null | head -1 || echo "unknown")
                status="healthy"
                ;;
            "pod")
                version=$(pod --version 2>/dev/null | head -1 || echo "unknown")
                status="healthy"
                ;;
            "gh")
                version=$(gh --version 2>&1 | head -1 | sed 's/.* version //' || echo "unknown")
                status="healthy"
                ;;
            *)
                status="healthy"
                ;;
        esac
    else
        status="missing"
    fi

    echo "$status:$version"
}

run_health_check() {
    log_info "Starting Quantum Workspace tool health check..."
    log_info "Monitoring ${#ESSENTIAL_TOOLS[@]} essential tools"

    local healthy_count=0
    local unhealthy_count=0
    local missing_count=0

    # Create tools section for dashboard
    local tools_json="{\"tools\":{"
    tools_json+="\"total\":${#ESSENTIAL_TOOLS[@]},"
    tools_json+="\"last_check\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    tools_json+="\"details\":{"

    local first=true
    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        local result=$(check_tool "$tool")
        local status="${result%%:*}"
        local version="${result#*:}"

        if [[ "$first" == true ]]; then
            first=false
        else
            tools_json+=","
        fi

        tools_json+="\"$tool\":{\"status\":\"$status\",\"version\":\"$version\"}"

        case "$status" in
            "healthy")
                log_info "✅ $tool: $status (v$version)"
                ((healthy_count++))
                ;;
            "missing")
                log_error "❌ $tool: $status"
                ((missing_count++))
                ;;
            "unhealthy")
                log_warning "⚠️  $tool: $status (v$version)"
                ((unhealthy_count++))
                ;;
        esac
    done

    tools_json+="}}}"

    # Update dashboard data
    if [[ -f "$DASHBOARD_DATA_FILE" ]] && command -v jq &>/dev/null; then
        jq ". + $tools_json" "$DASHBOARD_DATA_FILE" > "${DASHBOARD_DATA_FILE}.tmp" 2>/dev/null && mv "${DASHBOARD_DATA_FILE}.tmp" "$DASHBOARD_DATA_FILE"
        log_info "Dashboard updated successfully"
    else
        # Fallback: create basic dashboard structure
        cat > "$DASHBOARD_DATA_FILE" << EOF2
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "3.0.0",
  "tools": {
    "total": ${#ESSENTIAL_TOOLS[@]},
    "healthy": $healthy_count,
    "unhealthy": $unhealthy_count,
    "missing": $missing_count,
    "last_check": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF2
        log_info "Dashboard created with basic structure"
    fi

    # Summary
    log_info "Health check completed:"
    log_info "  ✅ Healthy: $healthy_count tools"
    log_info "  ⚠️  Unhealthy: $unhealthy_count tools"
    log_info "  ❌ Missing: $missing_count tools"
    log_info "  �� Total: ${#ESSENTIAL_TOOLS[@]} tools monitored"

    # Return appropriate exit code
    if [[ $missing_count -gt 0 ]]; then
        log_error "CRITICAL: $missing_count essential tools are missing"
        return 2
    elif [[ $unhealthy_count -gt 0 ]]; then
        log_warning "WARNING: $unhealthy_count tools are unhealthy"
        return 1
    else
        log_info "SUCCESS: All essential tools are healthy"
        return 0
    fi
}

show_status() {
    echo "🔍 Quantum Workspace Tool Health Status"
    echo "========================================"

    if [[ -f "$DASHBOARD_DATA_FILE" ]]; then
        if command -v jq &>/dev/null; then
            total=$(jq -r '.tools.total // 0' "$DASHBOARD_DATA_FILE" 2>/dev/null)
            last_check=$(jq -r '.tools.last_check // "Never"' "$DASHBOARD_DATA_FILE" 2>/dev/null)

            # Count healthy/unhealthy/missing from details
            healthy=$(jq -r '[.tools.details | to_entries[] | select(.value.status == "healthy")] | length' "$DASHBOARD_DATA_FILE" 2>/dev/null)
            unhealthy=$(jq -r '[.tools.details | to_entries[] | select(.value.status == "unhealthy")] | length' "$DASHBOARD_DATA_FILE" 2>/dev/null)
            missing=$(jq -r '[.tools.details | to_entries[] | select(.value.status == "missing")] | length' "$DASHBOARD_DATA_FILE" 2>/dev/null)

            echo "Last Check: $last_check"
            echo "Healthy: $healthy tools"
            echo "Unhealthy: $unhealthy tools"
            echo "Missing: $missing tools"
            echo "Total: $total tools"
        else
            echo "Dashboard data available (install jq for detailed status)"
        fi
    else
        echo "No dashboard data available - run health check first"
    fi
}

case "${1:-check}" in
    "check")
        run_health_check
        ;;
    "status")
        show_status
        ;;
    "help"|*)
        echo "Quantum Workspace Tool Health Monitor"
        echo "====================================="
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check  - Run full health check (default)"
        echo "  status - Show current status summary"
        echo "  help   - Show this help"
        echo ""
        echo "Monitors ${#ESSENTIAL_TOOLS[@]} essential tools in the optimized ecosystem."
        ;;
esac
