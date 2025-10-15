#!/bin/bash
# Quantum Workspace Tool Performance Benchmarking
# Tracks response times and performance metrics over time

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
METRICS_DIR="${WORKSPACE_DIR}/Tools/metrics"
BENCHMARK_LOG="${WORKSPACE_DIR}/Tools/logs/benchmark_$(date +%Y%m%d).log"
DASHBOARD_DATA_FILE="${WORKSPACE_DIR}/Tools/dashboard_data.json"

# Create metrics directory if it doesn't exist
mkdir -p "$METRICS_DIR"

# Essential tools to benchmark
BENCHMARK_TOOLS=(
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

log_benchmark() {
    local message="$*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [BENCHMARK] $message" | tee -a "$BENCHMARK_LOG"
}

measure_response_time() {
    local tool="$1"
    local start_time end_time response_time

    start_time=$(date +%s.%3N)

    case "$tool" in
        "git")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "python3")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "node")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "npm")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "brew")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "ollama")
            timeout 10 "$tool" list >/dev/null 2>&1
            ;;
        "jq")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "swiftlint")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "swiftformat")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "xcodebuild")
            timeout 10 "$tool" -version >/dev/null 2>&1
            ;;
        "swift")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "fastlane")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "pod")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        "gh")
            timeout 10 "$tool" --version >/dev/null 2>&1
            ;;
        *)
            # Unknown tool, skip
            echo "0.000"
            return 1
            ;;
    esac

    local exit_code=$?
    end_time=$(date +%s.%3N)

    if [[ $exit_code -eq 0 ]]; then
        response_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.000")
        echo "$response_time"
        return 0
    else
        echo "0.000"
        return 1
    fi
}

run_benchmark() {
    log_benchmark "Starting performance benchmark for ${#BENCHMARK_TOOLS[@]} tools..."

    local results=()
    local total_time=0
    local successful_tests=0

    for tool in "${BENCHMARK_TOOLS[@]}"; do
        log_benchmark "Benchmarking $tool..."

        local response_time=$(measure_response_time "$tool")
        local status="success"

        if [[ $? -ne 0 ]]; then
            status="failed"
            response_time="0.000"
        else
            ((successful_tests++))
            total_time=$(echo "$total_time + $response_time" | bc 2>/dev/null || echo "$total_time")
        fi

        results+=("{\"tool\":\"$tool\",\"response_time\":$response_time,\"status\":\"$status\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")

        log_benchmark "$tool: ${response_time}s ($status)"
    done

    # Calculate average response time
    local avg_time="0.000"
    if [[ $successful_tests -gt 0 ]]; then
        avg_time=$(echo "scale=3; $total_time / $successful_tests" | bc 2>/dev/null || echo "0.000")
    fi

    # Create benchmark results JSON
    local benchmark_json="{"
    benchmark_json+="\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    benchmark_json+="\"total_tools\":${#BENCHMARK_TOOLS[@]},"
    benchmark_json+="\"successful_tests\":$successful_tests,"
    benchmark_json+="\"average_response_time\":$avg_time,"
    benchmark_json+="\"results\":["
    local first=true
    for result in "${results[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            benchmark_json+=","
        fi
        benchmark_json+="$result"
    done
    benchmark_json+="]}"

    # Save to metrics file
    local metrics_file="${METRICS_DIR}/benchmark_$(date +%Y%m%d_%H%M%S).json"
    echo "$benchmark_json" > "$metrics_file"

    log_benchmark "Benchmark completed - Average response time: ${avg_time}s"
    log_benchmark "Results saved to: $metrics_file"

    # Update dashboard with latest benchmark
    update_dashboard_benchmark "$benchmark_json"
}

update_dashboard_benchmark() {
    local benchmark_data="$1"

    if [[ -f "$DASHBOARD_DATA_FILE" ]] && command -v jq &>/dev/null; then
        # Add benchmark section to dashboard
        local benchmark_section="{\"benchmark\":$benchmark_data}"
        jq ". + $benchmark_section" "$DASHBOARD_DATA_FILE" > "${DASHBOARD_DATA_FILE}.tmp" 2>/dev/null && mv "${DASHBOARD_DATA_FILE}.tmp" "$DASHBOARD_DATA_FILE"
        log_benchmark "Dashboard updated with benchmark results"
    fi
}

show_benchmark_history() {
    local days=${1:-7}

    echo "📊 Tool Performance Benchmark History (last $days days)"
    echo "======================================================="

    if [[ -d "$METRICS_DIR" ]]; then
        local benchmark_files=($(find "$METRICS_DIR" -name "benchmark_*.json" -type f -mtime -$days | sort))

        if [[ ${#benchmark_files[@]} -gt 0 ]]; then
            echo "Found ${#benchmark_files[@]} benchmark runs:"
            echo ""

            for file in "${benchmark_files[@]}"; do
                if command -v jq &>/dev/null; then
                    local timestamp=$(jq -r '.timestamp' "$file" 2>/dev/null)
                    local avg_time=$(jq -r '.average_response_time' "$file" 2>/dev/null)
                    local successful=$(jq -r '.successful_tests' "$file" 2>/dev/null)
                    local total=$(jq -r '.total_tools' "$file" 2>/dev/null)

                    echo "📅 $timestamp"
                    echo "   Average Response Time: ${avg_time}s"
                    echo "   Success Rate: $successful/$total tools"
                    echo ""
                else
                    echo "📄 $(basename "$file")"
                fi
            done
        else
            echo "No benchmark data found in the last $days days"
        fi
    else
        echo "No metrics directory available"
    fi
}

show_performance_trends() {
    echo "📈 Performance Trends Analysis"
    echo "================================"

    if [[ -d "$METRICS_DIR" ]] && command -v jq &>/dev/null; then
        local benchmark_files=($(find "$METRICS_DIR" -name "benchmark_*.json" -type f | sort))

        if [[ ${#benchmark_files[@]} -ge 2 ]]; then
            echo "Analyzing ${#benchmark_files[@]} benchmark runs..."
            echo ""

            # Get latest and previous benchmarks
            local latest_file="${benchmark_files[-1]}"
            local previous_file="${benchmark_files[-2]}"

            local latest_avg=$(jq -r '.average_response_time' "$latest_file" 2>/dev/null)
            local previous_avg=$(jq -r '.average_response_time' "$previous_file" 2>/dev/null)

            echo "Latest benchmark:   ${latest_avg}s average response time"
            echo "Previous benchmark: ${previous_avg}s average response time"

            # Calculate trend
            if [[ $(echo "$latest_avg > $previous_avg" | bc 2>/dev/null) -eq 1 ]]; then
                local diff=$(echo "$latest_avg - $previous_avg" | bc 2>/dev/null)
                echo "📉 Trend: Performance degraded by ${diff}s"
            elif [[ $(echo "$latest_avg < $previous_avg" | bc 2>/dev/null) -eq 1 ]]; then
                local diff=$(echo "$previous_avg - $latest_avg" | bc 2>/dev/null)
                echo "📈 Trend: Performance improved by ${diff}s"
            else
                echo "➡️  Trend: Performance stable"
            fi
        else
            echo "Need at least 2 benchmark runs for trend analysis"
        fi
    else
        echo "Insufficient data for trend analysis"
    fi
}

case "${1:-run}" in
    "run")
        run_benchmark
        ;;
    "history")
        show_benchmark_history "${2:-7}"
        ;;
    "trends")
        show_performance_trends
        ;;
    "help"|*)
        echo "Quantum Workspace Tool Performance Benchmarking"
        echo "==============================================="
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  run              - Run performance benchmark (default)"
        echo "  history [days]   - Show benchmark history (default: 7 days)"
        echo "  trends           - Show performance trends analysis"
        echo "  help             - Show this help"
        echo ""
        echo "This tool measures response times for essential tools and tracks"
        echo "performance trends over time."
        ;;
esac