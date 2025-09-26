#!/bin/bash

# Quantum Workspace Performance Benchmark Suite
# Comprehensive performance analysis for all projects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="${SCRIPT_DIR}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Projects to benchmark
PROJECTS=("AvoidObstaclesGame" "HabitQuest" "MomentumFinance" "PlannerApp" "CodingReviewer")

# Results storage (using files instead of associative arrays for compatibility)
BUILD_TIMES_FILE="/tmp/build_times.txt"
TEST_TIMES_FILE="/tmp/test_times.txt"
APP_SIZES_FILE="/tmp/app_sizes.txt"

# Initialize temp files
true > "${BUILD_TIMES_FILE}"
true > "${TEST_TIMES_FILE}"
true > "${APP_SIZES_FILE}"

# Benchmark results file
BENCHMARK_FILE="${WORKSPACE_ROOT}/PERFORMANCE_BENCHMARKS_$(date +%Y%m%d_%H%M%S).md"

echo -e "${BLUE}ðŸš€ QUANTUM WORKSPACE PERFORMANCE BENCHMARK SUITE${NC}"
echo -e "${BLUE}=================================================${NC}"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}Workspace: ${WORKSPACE_ROOT}${NC}"
echo -e "${CYAN}Report: ${BENCHMARK_FILE}${NC}"
echo ""

# Initialize benchmark report
cat > "${BENCHMARK_FILE}" << EOF
# Quantum Workspace Performance Benchmarks

**Date**: $(date)
**Workspace**: ${WORKSPACE_ROOT}
**Benchmark Suite Version**: v1.0

## Executive Summary

EOF

# Function to measure build time
measure_build_time() {
    local project_name=$1
    local platform=$2
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    echo -e "${BLUE}Building ${project_name} for ${platform}...${NC}"

    cd "${project_path}"

    # Find Xcode project
    local xcode_project
    xcode_project=$(find . -name "*.xcodeproj" -type d | head -1)

    if [[ -z "${xcode_project}" ]]; then
        echo -e "${YELLOW}âš ï¸  No Xcode project found ${or $project_}name${NC}"
        return 1
    fi

    local scheme_name
    scheme_name=$(basename "${xcode_project}" .xcodeproj)
    local start_time
    start_time=$(date +%s)

    case ${platform} in
        "iOS")
            if xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk iphoneos -configuration Release -destination 'platform=iOS Simulator,id=43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF' -allowProvisioningUpdates > /dev/null 2>&1; then
                local end_time
                end_time=$(date +%s)
                local build_time=$((end_time - start_time))
                echo "${project_name}_iOS:${build_time}" >> "${BUILD_TIMES_FILE}"
                echo -e "${GREEN}âœ${ $project_na}me iOS build: ${build_time}s${NC}"
                return 0
            fi
            ;;
        "macOS")
            if xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk macosx -configuration Release -allowProvisioningUpdates > /dev/null 2>&1; then
                local end_time
                end_time=$(date +%s)
                local build_time=$((end_time - start_time))
                echo "${project_name}_macOS:${build_time}" >> "${BUILD_TIMES_FILE}"
                echo -e "${GREEN}âœ${ $project_na}me macOS build: ${build_time}s${NC}"
                return 0
            fi
            ;;
    esac

    echo -e "${RED}â${ $project_na}m${ $platfo}rm build failed${NC}"
    return 1
}

# Function to measure app size
measure_app_size() {
    local project_name=$1
    local platform=$2
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    cd "${project_path}"

    case ${platform} in
        "iOS")
            # Find the built app in DerivedData
            local app_path
            app_path=$(find ~/Library/Developer/Xcode/DerivedData -name "${project_name}.app" -type d 2>/dev/null | head -1)

            if [[ -n "${app_path}" ]] && [[ -d "${app_path}" ]]; then
                local app_size
                app_size=$(du -sh "${app_path}" | cut -f1)
                echo "${project_name}_iOS:${app_size}" >> "${APP_SIZES_FILE}"
                echo -e "${GREEN}ðŸ${± $project_n}ame iOS app siz${: $app_s}ize${NC}"
            else
                echo -e "${YELLOW}âš ï¸  Could not find iOS app bundle ${or $project_}name${NC}"
            fi
            ;;
        "macOS")
            # Find the built app
            local app_path
            app_path=$(find ~/Library/Developer/Xcode/DerivedData -name "${project_name}.app" -type d 2>/dev/null | head -1)

            if [[ -n "${app_path}" ]] && [[ -d "${app_path}" ]]; then
                local app_size
                app_size=$(du -sh "${app_path}" | cut -f1)
                echo "${project_name}_macOS:${app_size}" >> "${APP_SIZES_FILE}"
                echo -e "${GREEN}ï¿½ï${  $project_}name macOS app si${e: $app_}size${NC}"
            else
                echo -e "${YELLOW}âš ï¸  Could not find macOS app bundle ${or $project_}name${NC}"
            fi
            ;;
    esac
}

# Function to measure test execution time
measure_test_time() {
    local project_name=$1
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    echo -e "${BLUE}Running tests for ${project_name}...${NC}"

    cd "${project_path}"

    # Find Xcode project
    local xcode_project
    xcode_project=$(find . -name "*.xcodeproj" -type d | head -1)

    if [[ -z "${xcode_project}" ]]; then
        echo -e "${YELLOW}âš ï¸  No Xcode project found ${or $project_}name${NC}"
        return 1
    fi

    local scheme_name
    scheme_name=$(basename "${xcode_project}" .xcodeproj)
    local start_time
    start_time=$(date +%s)

    # Try to run tests (may not work in all environments)
    if xcodebuild -project "${xcode_project}" -scheme "${scheme_name}Tests" -sdk iphoneos -configuration Debug -destination 'platform=iOS Simulator,id=43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF' -allowProvisioningUpdates test > /dev/null 2>&1; then
        local end_time
        end_time=$(date +%s)
        local test_time=$((end_time - start_time))
        echo "${project_name}:${test_time}" >> "${TEST_TIMES_FILE}"
        echo -e "${GREEN}ðŸ${ª $project_n}ame tests: ${test_time}s${NC}"
        return 0
    else
        echo -e "${YELLOW}âš ï${  $project_}name tests not available or failed${NC}"
        echo "${project_name}:N/A" >> "${TEST_TIMES_FILE}"
        return 1
    fi
}

# Function to analyze code complexity
analyze_code_complexity() {
    local project_name=$1
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    echo -e "${BLUE}Analyzing code complexity for ${project_name}...${NC}"

    cd "${project_path}"

    # Count Swift files
    local swift_files
    swift_files=$(find . -name "*.swift" -type f | wc -l | tr -d ' ')

    # Count lines of code
    local total_lines
    total_lines=$(find . -name "*.swift" -type f -exec wc -l {} \; | awk '{sum += $1} END {print sum}')

    # Average file size
    local avg_file_size=0
    if [[ "${swift_files}" -gt 0 ]]; then
        avg_file_size=$((total_lines / swift_files))
    fi

    echo -e "${GREEN}ðŸ${Š $project_n}am${: $swift_fi}les file${, $total_li}nes lines, avg ${avg_file_size} lines/file${NC}"

    # Return metrics for reporting
    echo "${swift_files}:${total_lines}:${avg_file_size}"
}

# Helper function to get value from file
get_value_from_file() {
    local file=$1
    local key=$2
    local value
    value=$(grep "^${key}:" "${file}" | cut -d':' -f2)
    echo "${value:-N/A}"
}

# Function to generate performance report
generate_performance_report() {
    echo -e "${BLUE}Generating performance report...${NC}"

    # Calculate averages and summaries
    local total_build_time_ios=0
    local total_build_time_macos=0
    local ios_build_count=0
    local macos_build_count=0

    # Read build times from file
    while IFS=':' read -r key value; do
        if [[ ${key} == *_iOS ]]; then
            total_build_time_ios=$((total_build_time_ios + value))
            ios_build_count=$((ios_build_count + 1))
        elif [[ ${key} == *_macOS ]]; then
            total_build_time_macos=$((total_build_time_macos + value))
            macos_build_count=$((macos_build_count + 1))
        fi
    done < "${BUILD_TIMES_FILE}"

    local avg_build_time_ios="N/A"
    local avg_build_time_macos="N/A"

    if [[ "$ios_build_count" -gt 0 ]]; then
        avg_build_time_ios=$((total_build_time_ios / ios_build_count))
    fi
    if [[ "$macos_build_count" -gt 0 ]]; then
        avg_build_time_macos=$((total_build_time_macos / macos_build_count))
    fi

    # Update executive summary
    cat >> "${BENCHMARK_FILE}" << EOF

**Total Projects Benchmarked**: ${#PROJECTS[@]}
**iOS Builds Measured**: ${ios_build_count}
**macOS Builds Measured**: ${macos_build_count}
**Average iOS Build Time**: ${avg_build_time_ios}s
**Average macOS Build Time**: ${avg_build_time_macos}s

## Detailed Results

### Build Performance

| Project | iOS Build Time | macOS Build Time | Status |
|---------|----------------|------------------|--------|
EOF

    for project in "${PROJECTS[@]}"; do
        local ios_time
        ios_time=$(get_value_from_file "${BUILD_TIMES_FILE}" "${project}_iOS")
        local macos_time
        macos_time=$(get_value_from_file "${BUILD_TIMES_FILE}" "${project}_macOS")
        local status="âœ… Complete"

        if [[ "${ios_time}" = "N/A" ]] && [[ "${macos_time}" = "N/A" ]]; then
            status="âŒ Failed"
        elif [[ "${ios_time}" = "N/A" ]] || [[ "${macos_time}" = "N/A" ]]; then
            status="âš ï¸ Partial"
        fi

        echo "| ${project} | ${ios_time}s | ${macos_time}s | ${status} |" >> "${BENCHMARK_FILE}"
    done

    # App Sizes
    cat >> "${BENCHMARK_FILE}" << EOF

### App Sizes

| Project | iOS App Size | macOS App Size |
|---------|--------------|----------------|
EOF

    for project in "${PROJECTS[@]}"; do
        local ios_size
        ios_size=$(get_value_from_file "${APP_SIZES_FILE}" "${project}_iOS")
        local macos_size
        macos_size=$(get_value_from_file "${APP_SIZES_FILE}" "${project}_macOS")
        echo "| ${project} | ${ios_size} | ${macos_size} |" >> "${BENCHMARK_FILE}"
    done

    # Test Performance
    cat >> "${BENCHMARK_FILE}" << EOF

### Test Performance

| Project | Test Execution Time | Status |
|---------|---------------------|--------|
EOF

    for project in "${PROJECTS[@]}"; do
        local test_time
        test_time=$(get_value_from_file "${TEST_TIMES_FILE}" "${project}")
        local status="âœ… Available"
        if [[ "${test_time}" = "N/A" ]]; then
            status="âŒ Not Available"
        fi
        echo "| ${project} | ${test_time}s | ${status} |" >> "${BENCHMARK_FILE}"
    done

    # Code Complexity Analysis
    cat >> "${BENCHMARK_FILE}" << EOF

### Code Complexity Analysis

| Project | Swift Files | Total Lines | Avg Lines/File |
|---------|-------------|-------------|----------------|
EOF

    for project in "${PROJECTS[@]}"; do
        local complexity
        complexity=$(analyze_code_complexity "${project}")
        IFS=':' read -r file_count total_lines avg_lines <<< "${complexity}"
        echo "| ${project} | ${file_count} | ${total_lines} | ${avg_lines} |" >> "${BENCHMARK_FILE}"
    done

    # Performance Recommendations
    cat >> "${BENCHMARK_FILE}" << EOF

## Performance Recommendations

### Build Optimization
EOF

    # Analyze build times and provide recommendations
    for project in "${PROJECTS[@]}"; do
        local ios_time
        ios_time=$(get_value_from_file "${BUILD_TIMES_FILE}" "${project}_iOS")
        local macos_time
        macos_time=$(get_value_from_file "${BUILD_TIMES_FILE}" "${project}_macOS")

        if [[ "${ios_time}" != "N/A" ]] && [[ "${ios_time}" -gt 120 ]]; then
            echo "- **${project} iOS**: Build time (${ios_time}s) exceeds 2 minutes. Consider:" >> "${BENCHMARK_FILE}"
            echo "  - Enabling build caching" >> "${BENCHMARK_FILE}"
            echo "  - Reducing dependencies" >> "${BENCHMARK_FILE}"
            echo "  - Using incremental builds" >> "${BENCHMARK_FILE}"
        fi

        if [[ "${macos_time}" != "N/A" ]] && [[ "${macos_time}" -gt 120 ]]; then
            echo "- **${project} macOS**: Build time (${macos_time}s) exceeds 2 minutes. Consider:" >> "${BENCHMARK_FILE}"
            echo "  - Enabling build caching" >> "${BENCHMARK_FILE}"
            echo "  - Reducing dependencies" >> "${BENCHMARK_FILE}"
            echo "  - Using incremental builds" >> "${BENCHMARK_FILE}"
        fi
    done

    cat >> "${BENCHMARK_FILE}" << EOF

### Code Quality Improvements
- Review files with high line counts (>500 lines)
- Implement proper separation of concerns
- Add comprehensive unit tests
- Enable compiler optimizations for release builds

### Testing Recommendations
- Implement automated UI tests for critical user flows
- Add performance regression tests
- Set up continuous integration with performance gates
- Monitor app size growth over time

---

**Benchmark Completed**: $(date)
**Generated by**: Quantum Workspace Performance Benchmark Suite v1.0
EOF

    echo -e "${GREEN}âœ… Performance benchmark report generated${ $BENCHMARK_FI}LE${NC}"
}

# Main execution
main() {
    echo "## Build Performance Analysis" >> "${BENCHMARK_FILE}"
    echo "" >> "${BENCHMARK_FILE}"

    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}ðŸ”¬ Benchmarki${g $proj}ect...${NC}"
        echo "### ${project} Performance Metrics" >> "${BENCHMARK_FILE}"
        echo "" >> "${BENCHMARK_FILE}"

        # Measure iOS build time
        if measure_build_time "${project}" "iOS"; then
            measure_app_size "${project}" "iOS"
        fi

        # Measure macOS build time
        if measure_build_time "${project}" "macOS"; then
            measure_app_size "${project}" "macOS"
        fi

        # Measure test time
        measure_test_time "${project}"

        echo "" >> "${BENCHMARK_FILE}"
    done

    # Generate final report
    generate_performance_report

    echo ""
    echo -e "${GREEN}ðŸŽ‰ Performance benchmarking completed!${NC}"
    echo -e "${CYAN}ðŸ“Š Results saved t${: $BENCHMARK_F}ILE${NC}"
}

# Execute main function
main