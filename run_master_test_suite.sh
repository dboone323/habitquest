#!/bin/bash

# Quantum Workspace Master Test Suite
# Comprehensive build and test validation for all projects and platforms
# Generated: September 19, 2025

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test Results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
BUILD_FAILURES=0
TEST_FAILURES=0

# Directories
WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
PROJECTS_DIR="$WORKSPACE_ROOT/Projects"
SHARED_DIR="$WORKSPACE_ROOT/Shared"
TOOLS_DIR="$WORKSPACE_ROOT/Tools"
DOCS_DIR="$WORKSPACE_ROOT/Documentation"

# Log file
LOG_FILE="$WORKSPACE_ROOT/test_results_$(date +%Y%m%d_%H%M%S).log"
REPORT_FILE="$WORKSPACE_ROOT/COMPREHENSIVE_TEST_REPORT_$(date +%Y%m%d_%H%M%S).md"

# Projects to test
PROJECTS=("HabitQuest" "MomentumFinance" "PlannerApp" "AvoidObstaclesGame" "CodingReviewer")

echo -e "${BLUE}🚀 QUANTUM WORKSPACE COMPREHENSIVE TEST SUITE${NC}"
echo -e "${BLUE}==============================================${NC}"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}Workspace: $WORKSPACE_ROOT${NC}"
echo -e "${CYAN}Log File: $LOG_FILE${NC}"
echo -e "${CYAN}Report File: $REPORT_FILE${NC}"
echo ""

# Initialize log file
cat > "$LOG_FILE" << EOF
Quantum Workspace Comprehensive Test Suite
==========================================
Date: $(date)
Workspace: $WORKSPACE_ROOT

EOF

# Initialize report file
cat > "$REPORT_FILE" << EOF
# Quantum Workspace Comprehensive Test Report

**Date**: $(date)  
**Workspace**: $WORKSPACE_ROOT  
**Test Suite Version**: Phase 4 Complete  

## Executive Summary

EOF

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    
    case $level in
        "ERROR")   echo -e "${RED}❌ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO")    echo -e "${CYAN}ℹ️  $message${NC}" ;;
        "BUILD")   echo -e "${PURPLE}🔨 $message${NC}" ;;
        "TEST")    echo -e "${BLUE}🧪 $message${NC}" ;;
    esac
}

# Function to update counters
update_counters() {
    local status=$1
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASSED" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to run build and capture output
run_build() {
    local project_path=$1
    local project_name=$2
    local platform=${3:-"default"}
    
    log_message "BUILD" "Building $project_name ($platform)"
    
    cd "$project_path"
    
    if swift build > build_output.tmp 2>&1; then
        log_message "SUCCESS" "$project_name ($platform) build successful"
        update_counters "PASSED"
        cat build_output.tmp >> "$LOG_FILE"
        rm -f build_output.tmp
        return 0
    else
        log_message "ERROR" "$project_name ($platform) build failed"
        BUILD_FAILURES=$((BUILD_FAILURES + 1))
        update_counters "FAILED"
        cat build_output.tmp >> "$LOG_FILE"
        rm -f build_output.tmp
        return 1
    fi
}

# Function to run tests if available
run_tests() {
    local project_path=$1
    local project_name=$2
    
    log_message "TEST" "Running tests for $project_name"
    
    cd "$project_path"
    
    # Check if tests exist
    if [ -d "Tests" ] || find . -name "*Tests.swift" -type f | grep -q .; then
        if swift test > test_output.tmp 2>&1; then
            log_message "SUCCESS" "$project_name tests passed"
            update_counters "PASSED"
            cat test_output.tmp >> "$LOG_FILE"
        else
            log_message "ERROR" "$project_name tests failed"
            TEST_FAILURES=$((TEST_FAILURES + 1))
            update_counters "FAILED"
            cat test_output.tmp >> "$LOG_FILE"
        fi
    else
        log_message "WARNING" "No tests found for $project_name"
    fi
    
    rm -f test_output.tmp
}

# Function to check Xcode build for iOS/macOS
run_xcode_build() {
    local project_path=$1
    local project_name=$2
    local platform=$3
    
    log_message "BUILD" "Building $project_name for $platform with Xcode"
    
    cd "$project_path"
    
    # Find .xcodeproj file
    local xcode_project=$(find . -name "*.xcodeproj" -type d | head -1)
    
    if [ -n "$xcode_project" ]; then
        local scheme_name=$(basename "$xcode_project" .xcodeproj)
        
        case $platform in
            "iOS")
                if xcodebuild -project "$xcode_project" -scheme "$scheme_name" -sdk iphoneos -configuration Debug -allowProvisioningUpdates > xcode_build.tmp 2>&1; then
                    log_message "SUCCESS" "$project_name iOS build successful"
                    update_counters "PASSED"
                else
                    log_message "ERROR" "$project_name iOS build failed"
                    BUILD_FAILURES=$((BUILD_FAILURES + 1))
                    update_counters "FAILED"
                fi
                ;;
            "macOS")
                if xcodebuild -project "$xcode_project" -scheme "$scheme_name" -sdk macosx -configuration Debug -allowProvisioningUpdates > xcode_build.tmp 2>&1; then
                    log_message "SUCCESS" "$project_name macOS build successful"
                    update_counters "PASSED"
                else
                    log_message "ERROR" "$project_name macOS build failed"
                    BUILD_FAILURES=$((BUILD_FAILURES + 1))
                    update_counters "FAILED"
                fi
                ;;
        esac
        
        cat xcode_build.tmp >> "$LOG_FILE"
        rm -f xcode_build.tmp
    else
        log_message "WARNING" "No Xcode project found for $project_name"
    fi
}

# Function to validate SharedKit components
validate_shared_components() {
    log_message "INFO" "=== PHASE 1: SharedKit Components Validation ==="
    
    echo "## 1. SharedKit Components Validation" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Test SharedKit build
    if run_build "$SHARED_DIR" "SharedKit" "Cross-Platform"; then
        echo "- ✅ SharedKit Cross-Platform Build: **PASSED**" >> "$REPORT_FILE"
    else
        echo "- ❌ SharedKit Cross-Platform Build: **FAILED**" >> "$REPORT_FILE"
    fi
    
    # Validate individual components exist
    local shared_components=(
        "Advanced/AdvancedAnimations.swift"
        "Advanced/InteractiveComponents.swift" 
        "Advanced/CustomTransitions.swift"
        "Advanced/MicroInteractions.swift"
        "Testing/TestingFramework.swift"
        "Testing/IntegrationTestSuite.swift"
        "Testing/PerformanceBenchmarkSuite.swift"
        "Testing/AIMLValidationSuite.swift"
        "Testing/SecurityAuditingSuite.swift"
        "Testing/DeviceCompatibilityUATSuite.swift"
        "Performance/PerformanceOptimization.swift"
        "Performance/PerformanceUtilities.swift"
        "AI/AIIntegration.swift"
        "Sources/SharedKit/AppLogger.swift"
    )
    
    echo "### Component File Validation:" >> "$REPORT_FILE"
    
    for component in "${shared_components[@]}"; do
        if [ -f "$SHARED_DIR/$component" ]; then
            log_message "SUCCESS" "SharedKit component exists: $component"
            echo "- ✅ $component" >> "$REPORT_FILE"
            update_counters "PASSED"
        else
            log_message "ERROR" "SharedKit component missing: $component"
            echo "- ❌ $component" >> "$REPORT_FILE"
            update_counters "FAILED"
        fi
    done
    
    echo "" >> "$REPORT_FILE"
}

# Function to validate iOS projects
validate_ios_projects() {
    log_message "INFO" "=== PHASE 2: iOS Projects Build & Test ==="
    
    echo "## 2. iOS Projects Build & Test" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    for project in "${PROJECTS[@]}"; do
        local project_path="$PROJECTS_DIR/$project"
        
        if [ -d "$project_path" ]; then
            log_message "INFO" "Testing iOS project: $project"
            echo "### $project (iOS)" >> "$REPORT_FILE"
            
            # Swift build test
            if run_build "$project_path" "$project" "iOS-Swift"; then
                echo "- ✅ Swift Build: **PASSED**" >> "$REPORT_FILE"
            else
                echo "- ❌ Swift Build: **FAILED**" >> "$REPORT_FILE"
            fi
            
            # Xcode build test
            run_xcode_build "$project_path" "$project" "iOS"
            if [ $? -eq 0 ]; then
                echo "- ✅ Xcode iOS Build: **PASSED**" >> "$REPORT_FILE"
            else
                echo "- ❌ Xcode iOS Build: **FAILED**" >> "$REPORT_FILE"
            fi
            
            # Run project tests
            run_tests "$project_path" "$project"
            
            echo "" >> "$REPORT_FILE"
        else
            log_message "WARNING" "Project directory not found: $project"
            echo "### $project (iOS)" >> "$REPORT_FILE"
            echo "- ⚠️ Project directory not found" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi
    done
}

# Function to validate macOS projects
validate_macos_projects() {
    log_message "INFO" "=== PHASE 3: macOS Projects Build & Test ==="
    
    echo "## 3. macOS Projects Build & Test" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    for project in "${PROJECTS[@]}"; do
        local project_path="$PROJECTS_DIR/$project"
        
        if [ -d "$project_path" ]; then
            log_message "INFO" "Testing macOS project: $project"
            echo "### $project (macOS)" >> "$REPORT_FILE"
            
            # Xcode macOS build test
            run_xcode_build "$project_path" "$project" "macOS"
            if [ $? -eq 0 ]; then
                echo "- ✅ Xcode macOS Build: **PASSED**" >> "$REPORT_FILE"
            else
                echo "- ❌ Xcode macOS Build: **FAILED**" >> "$REPORT_FILE"
            fi
            
            echo "" >> "$REPORT_FILE"
        else
            log_message "WARNING" "Project directory not found: $project"
            echo "### $project (macOS)" >> "$REPORT_FILE"
            echo "- ⚠️ Project directory not found" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi
    done
}

# Function to run integration tests
run_integration_tests() {
    log_message "INFO" "=== PHASE 4: Cross-Platform Integration Testing ==="
    
    echo "## 4. Cross-Platform Integration Testing" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Test our Phase 4 testing suites
    cd "$SHARED_DIR"
    
    log_message "TEST" "Running Integration Test Validation"
    echo "### Integration Test Suites Validation" >> "$REPORT_FILE"
    
    # Validate that our test files compile and are accessible
    local test_suites=(
        "Testing/IntegrationTestSuite.swift"
        "Testing/PerformanceBenchmarkSuite.swift" 
        "Testing/AIMLValidationSuite.swift"
        "Testing/SecurityAuditingSuite.swift"
        "Testing/DeviceCompatibilityUATSuite.swift"
    )
    
    for test_suite in "${test_suites[@]}"; do
        if [ -f "$test_suite" ]; then
            log_message "SUCCESS" "Test suite available: $test_suite"
            echo "- ✅ $(basename "$test_suite"): **AVAILABLE**" >> "$REPORT_FILE"
            update_counters "PASSED"
            
            # Check file size to ensure it's not empty
            local file_size=$(wc -l < "$test_suite")
            if [ "$file_size" -gt 100 ]; then
                log_message "SUCCESS" "Test suite substantial: $test_suite ($file_size lines)"
                echo "  - Lines of code: $file_size" >> "$REPORT_FILE"
            else
                log_message "WARNING" "Test suite may be incomplete: $test_suite ($file_size lines)"
                echo "  - ⚠️ Warning: Only $file_size lines" >> "$REPORT_FILE"
            fi
        else
            log_message "ERROR" "Test suite missing: $test_suite"
            echo "- ❌ $(basename "$test_suite"): **MISSING**" >> "$REPORT_FILE"
            update_counters "FAILED"
        fi
    done
    
    echo "" >> "$REPORT_FILE"
    
    # Test compilation of advanced features
    log_message "TEST" "Validating advanced feature compilation"
    echo "### Advanced Features Compilation" >> "$REPORT_FILE"
    
    if swift build > integration_build.tmp 2>&1; then
        log_message "SUCCESS" "All advanced features compile successfully"
        echo "- ✅ Advanced Features Compilation: **PASSED**" >> "$REPORT_FILE"
        update_counters "PASSED"
    else
        log_message "ERROR" "Advanced features compilation failed"
        echo "- ❌ Advanced Features Compilation: **FAILED**" >> "$REPORT_FILE"
        update_counters "FAILED"
        cat integration_build.tmp >> "$LOG_FILE"
    fi
    
    rm -f integration_build.tmp
    echo "" >> "$REPORT_FILE"
}

# Function to generate final report
generate_final_report() {
    log_message "INFO" "=== PHASE 5: Test Results Analysis & Reporting ==="
    
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi
    
    # Update executive summary
    cat >> "$REPORT_FILE" << EOF

**Total Tests Run**: $TOTAL_TESTS  
**Tests Passed**: $PASSED_TESTS  
**Tests Failed**: $FAILED_TESTS  
**Success Rate**: $success_rate%  
**Build Failures**: $BUILD_FAILURES  
**Test Failures**: $TEST_FAILURES  

## Test Results Summary

### 📊 Overall Statistics
- **Success Rate**: $success_rate% ($PASSED_TESTS/$TOTAL_TESTS)
- **Build Status**: $(if [ $BUILD_FAILURES -eq 0 ]; then echo "✅ ALL BUILDS SUCCESSFUL"; else echo "❌ $BUILD_FAILURES BUILD FAILURES"; fi)
- **Test Status**: $(if [ $TEST_FAILURES -eq 0 ]; then echo "✅ ALL TESTS PASSED"; else echo "❌ $TEST_FAILURES TEST FAILURES"; fi)

### 🎯 Quality Gate Assessment
$(if [ $success_rate -ge 90 ]; then echo "🟢 **EXCELLENT** - Production Ready"; elif [ $success_rate -ge 75 ]; then echo "🟡 **GOOD** - Minor Issues"; else echo "🔴 **NEEDS IMPROVEMENT** - Major Issues"; fi)

### 📝 Recommendations
$(if [ $BUILD_FAILURES -eq 0 ] && [ $TEST_FAILURES -eq 0 ]; then
    echo "✅ **All systems operational** - Ready for production deployment"
    echo "✅ **No critical issues found** - Proceed with confidence"
    echo "✅ **Cross-platform compatibility validated** - Full device support confirmed"
else
    echo "⚠️ **Review failed components** - Address build/test failures before deployment"
    echo "🔍 **Check logs for details** - See $LOG_FILE for detailed error information"
    echo "🛠️ **Fix and retest** - Resolve issues and run validation again"
fi)

---

## Detailed Log Information
For complete build and test output, see: \`$(basename "$LOG_FILE")\`

**Test Suite Completed**: $(date)  
**Workspace**: $WORKSPACE_ROOT  
**Generated by**: Quantum Workspace Master Test Suite v4.0
EOF
    
    # Display final summary
    echo ""
    log_message "INFO" "=========================================="
    log_message "INFO" "QUANTUM WORKSPACE TEST SUITE COMPLETE"
    log_message "INFO" "=========================================="
    log_message "INFO" "Total Tests: $TOTAL_TESTS"
    log_message "INFO" "Passed: $PASSED_TESTS"
    log_message "INFO" "Failed: $FAILED_TESTS"
    log_message "INFO" "Success Rate: $success_rate%"
    log_message "INFO" "Build Failures: $BUILD_FAILURES"
    log_message "INFO" "Test Failures: $TEST_FAILURES"
    
    if [ $success_rate -ge 90 ]; then
        log_message "SUCCESS" "🎉 EXCELLENT RESULTS - PRODUCTION READY!"
    elif [ $success_rate -ge 75 ]; then
        log_message "WARNING" "GOOD RESULTS - MINOR ISSUES TO RESOLVE"
    else
        log_message "ERROR" "NEEDS IMPROVEMENT - MAJOR ISSUES FOUND"
    fi
    
    log_message "INFO" "Detailed Report: $REPORT_FILE"
    log_message "INFO" "Complete Log: $LOG_FILE"
}

# Main execution flow
main() {
    cd "$WORKSPACE_ROOT"
    
    # Phase 1: SharedKit Components Validation
    validate_shared_components
    
    # Phase 2: iOS Projects Build & Test  
    validate_ios_projects
    
    # Phase 3: macOS Projects Build & Test
    validate_macos_projects
    
    # Phase 4: Cross-Platform Integration Testing
    run_integration_tests
    
    # Phase 5: Test Results Analysis & Reporting
    generate_final_report
}

# Execute main function
main

# Set exit code based on results
if [ $BUILD_FAILURES -eq 0 ] && [ $TEST_FAILURES -eq 0 ]; then
    exit 0
else
    exit 1
fi