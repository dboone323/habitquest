#!/bin/bash
# Advanced Predictive Analytics Runner
# Integrates advanced ML-based tool health forecasting with the monitoring system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PYTHON_CMD="python3"
ANALYTICS_SCRIPT="advanced_predictive_analytics.py"
REQUIREMENTS_FILE="requirements_advanced_analytics.txt"
LOG_FILE="logs/advanced_analytics_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

# Check dependencies
check_dependencies() {
    log "🔍 Checking dependencies..."

    # Check Python
    if ! command -v "$PYTHON_CMD" &>/dev/null; then
        error_exit "Python 3 not found. Please install Python 3."
    fi

    # Check pip
    if ! command -v pip3 &>/dev/null; then
        error_exit "pip3 not found. Please install pip3."
    fi

    # Check if required packages are installed
    local missing_packages=()

    "$PYTHON_CMD" -c "import numpy" 2>/dev/null || missing_packages+=("numpy")
    "$PYTHON_CMD" -c "import pandas" 2>/dev/null || missing_packages+=("pandas")
    "$PYTHON_CMD" -c "import sklearn" 2>/dev/null || missing_packages+=("scikit-learn")
    "$PYTHON_CMD" -c "import statsmodels" 2>/dev/null || missing_packages+=("statsmodels")
    "$PYTHON_CMD" -c "import joblib" 2>/dev/null || missing_packages+=("joblib")

    if [ ${#missing_packages[@]} -ne 0 ]; then
        log "📦 Installing missing packages: ${missing_packages[*]}"
        pip3 install "${missing_packages[@]}" || error_exit "Failed to install required packages"
    fi

    log "✅ Dependencies check complete"
}

# Install full requirements if requested
install_requirements() {
    if [ -f "$REQUIREMENTS_FILE" ]; then
        log "📦 Installing full requirements from $REQUIREMENTS_FILE"
        pip3 install -r "$REQUIREMENTS_FILE" || log "⚠️ Some optional packages failed to install"
    fi
}

# Run advanced analytics
run_analytics() {
    log "🚀 Starting Advanced Predictive Analytics Engine"

    if [ ! -f "$ANALYTICS_SCRIPT" ]; then
        error_exit "Analytics script $ANALYTICS_SCRIPT not found"
    fi

    # Run the analytics engine
    "$PYTHON_CMD" "$ANALYTICS_SCRIPT"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "✅ Advanced predictive analytics completed successfully"
    else
        error_exit "Advanced predictive analytics failed with exit code $exit_code"
    fi
}

# Generate analytics summary
generate_summary() {
    log "📊 Generating analytics summary"

    # Find latest analytics report
    local latest_report=$(find analytics/ -name "advanced_analytics_*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

    if [ -n "$latest_report" ] && [ -f "$latest_report" ]; then
        log "📄 Latest analytics report: $latest_report"

        # Extract key metrics
        local total_tools=$(jq '.summary.total_tools' "$latest_report" 2>/dev/null || echo "N/A")
        local critical_health=$(jq '.summary.critical_health' "$latest_report" 2>/dev/null || echo "N/A")
        local high_risk=$(jq '.summary.high_risk' "$latest_report" 2>/dev/null || echo "N/A")

        log "📈 Summary: $total_tools tools analyzed, $critical_health critical health, $high_risk high risk"

        # Show top insights
        if jq -e '.insights' "$latest_report" >/dev/null 2>&1; then
            log "💡 Key Insights:"
            jq -r '.insights[]' "$latest_report" 2>/dev/null | while read -r insight; do
                log "   • $insight"
            done
        fi
    else
        log "⚠️ No analytics reports found"
    fi
}

# Main execution
main() {
    local install_req=false
    local skip_deps=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --install-requirements)
            install_req=true
            shift
            ;;
        --skip-deps-check)
            skip_deps=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --install-requirements  Install full requirements from requirements file"
            echo "  --skip-deps-check      Skip dependency checking"
            echo "  --help                 Show this help message"
            exit 0
            ;;
        *)
            error_exit "Unknown option: $1"
            ;;
        esac
    done

    log "🔬 Advanced Predictive Analytics Runner Started"
    log "📁 Working directory: $(pwd)"
    log "📝 Log file: $LOG_FILE"

    # Install requirements if requested
    if [ "$install_req" = true ]; then
        install_requirements
    fi

    # Check dependencies unless skipped
    if [ "$skip_deps" = false ]; then
        check_dependencies
    fi

    # Run analytics
    run_analytics

    # Generate summary
    generate_summary

    log "🎉 Advanced predictive analytics runner completed successfully"
}

# Run main function with all arguments
main "$@"
