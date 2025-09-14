#!/bin/bash

# Comprehensive Test Validation Script for Quantum Workspace Projects
# This script runs tests for all projects and validates test coverage

set -e

echo "🚀 Starting Quantum Workspace Test Validation"
echo "=============================================="

PROJECTS_DIR="/Users/danielstevens/Desktop/Quantum-workspace/Projects"
PROJECTS=("AvoidObstaclesGame" "HabitQuest" "MomentumFinance" "PlannerApp" "CodingReviewer")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to run tests for a project
run_project_tests() {
    local project=$1
    local project_path="$PROJECTS_DIR/$project"

    if [ ! -d "$project_path" ]; then
        print_status $RED "❌ Project directory not found: $project"
        return 1
    fi

    print_status $BLUE "🔍 Testing $project..."

    cd "$project_path"

    # Check if it's an Xcode project
    if [ -d "$project.xcodeproj" ]; then
        print_status $YELLOW "  Building and testing with Xcode..."

        # Build the project
        if xcodebuild -project "$project.xcodeproj" -scheme "$project" -configuration Debug -allowProvisioningUpdates build; then
            print_status $GREEN "  ✅ Build successful for $project"

            # Try to run tests
            if xcodebuild -project "$project.xcodeproj" -scheme "$project" -configuration Debug -allowProvisioningUpdates test; then
                print_status $GREEN "  ✅ Tests passed for $project"
                return 0
            else
                print_status $RED "  ❌ Tests failed for $project"
                return 1
            fi
        else
            print_status $RED "  ❌ Build failed for $project"
            return 1
        fi
    else
        print_status $YELLOW "  No Xcode project found, checking for Swift Package Manager..."

        # Check for Package.swift
        if [ -f "Package.swift" ]; then
            print_status $YELLOW "  Building and testing with SwiftPM..."

            if swift build; then
                print_status $GREEN "  ✅ Build successful for $project"

                if swift test; then
                    print_status $GREEN "  ✅ Tests passed for $project"
                    return 0
                else
                    print_status $RED "  ❌ Tests failed for $project"
                    return 1
                fi
            else
                print_status $RED "  ❌ Build failed for $project"
                return 1
            fi
        else
            print_status $YELLOW "  No build system detected for $project"
            return 1
        fi
    fi
}

# Function to validate test file existence
validate_test_files() {
    local project=$1
    local project_path="$PROJECTS_DIR/$project"

    print_status $BLUE "📋 Validating test files for $project..."

    # Look for test files
    local test_files
    test_files=$(find "$project_path" -name "*Tests*.swift" -o -name "*Test*.swift" 2>/dev/null | wc -l)

    if [ "$test_files" -gt 0 ]; then
        print_status $GREEN "  ✅ Found $test_files test file(s) in $project"

        # List the test files
        find "$project_path" -name "*Tests*.swift" -o -name "*Test*.swift" 2>/dev/null | while read -r file; do
            echo "    📄 $(basename "$file")"
        done

        return 0
    else
        print_status $RED "  ❌ No test files found in $project"
        return 1
    fi
}

# Main execution
echo ""
print_status $BLUE "📊 Test File Validation"
echo "========================"

total_projects=${#PROJECTS[@]}
passed_validation=0
failed_validation=0

for project in "${PROJECTS[@]}"; do
    if validate_test_files "$project"; then
        ((passed_validation++))
    else
        ((failed_validation++))
    fi
    echo ""
done

echo ""
print_status $BLUE "🧪 Test Execution"
echo "=================="

passed_tests=0
failed_tests=0

for project in "${PROJECTS[@]}"; do
    if run_project_tests "$project"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    echo ""
done

# Summary
echo ""
print_status $BLUE "📈 Test Validation Summary"
echo "==========================="

echo "Test File Validation:"
echo "  ✅ Passed: $passed_validation/$total_projects projects"
echo "  ❌ Failed: $failed_validation/$total_projects projects"

echo ""
echo "Test Execution:"
echo "  ✅ Passed: $passed_tests/$total_projects projects"
echo "  ❌ Failed: $failed_tests/$total_projects projects"

echo ""
if [ $failed_validation -eq 0 ] && [ $failed_tests -eq 0 ]; then
    print_status $GREEN "🎉 All tests validated successfully!"
    exit 0
else
    print_status $RED "⚠️  Some tests failed validation or execution"
    exit 1
fi
