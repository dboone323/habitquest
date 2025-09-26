#!/bin/bash

# Quantum Workspace Test Runner
# Run tests for individual projects or all projects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Projects
PROJECTS=("AvoidObstaclesGame" "HabitQuest" "MomentumFinance" "PlannerApp" "CodingReviewer")

show_usage() {
    echo "Quantum Workspace Test Runner"
    echo ""
    echo "Usage: $0 [project_name] [options]"
    echo ""
    echo "Projects:"
    for project in "${PROJECTS[@]}"; do
        echo "  - ${project}"
    done
    echo "  - all (run all projects)"
    echo ""
    echo "Options:"
    echo "  --ios-only     Run iOS tests only"
    echo "  --macos-only   Run macOS tests only"
    echo "  --verbose      Show detailed output"
    echo "  --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 PlannerApp              # Test PlannerApp on all platforms"
    echo "  $0 all --ios-only          # Test all projects on iOS only"
    echo "  $0 MomentumFinance --verbose  # Test MomentumFinance with verbose output"
}

run_project_tests() {
    local project_name=$1
    local ios_only=${2:-false}
    local macos_only=${3:-false}
    local verbose=${4:-false}

    echo -e "${BLUE}Testing ${project_name}${NC}"

    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    if [[ ! -d "${project_path}" ]]; then
        echo -e "${RED}‚ùå Projec${ $project_na}me not found${NC}"
        return 1
    fi

    cd "${project_path}"

    # Find Xcode project
    local xcode_project
    xcode_project=$(find . -name "*.xcodeproj" -type d | head -1)

    if [[ -z "${xcode_project}" ]]; then
        echo -e "${YELLOW}‚ö†Ô∏è  No Xcode project found ${or $project_}name${NC}"
        return 1
    fi

    local scheme_name
    scheme_name=$(basename "${xcode_project}" .xcodeproj)

    local success=true

    # iOS Tests
    if [[ "${macos_only}" != "true" ]]; then
        echo -e "${BLUE}Building ${project_name} for iOS...${NC}"
        if [[ "${verbose}" = "true" ]]; then
            xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk iphoneos -configuration Debug -destination 'platform=iOS Simulator,id=43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF' -allowProvisioningUpdates
        else
            xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk iphoneos -configuration Debug -destination 'platform=iOS Simulator,id=43C262CD-FEC5-4CEB-8632-48B9AB5CF5EF' -allowProvisioningUpdates > /dev/null 2>&1
        fi

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}‚ú${ $project_na}me iOS build successful${NC}"
        else
            echo -e "${RED}‚ù${ $project_na}me iOS build failed${NC}"
            success=false
        fi
    fi

    # macOS Tests
    if [[ "${ios_only}" != "true" ]]; then
        echo -e "${BLUE}Building ${project_name} for macOS...${NC}"
        if [[ "${verbose}" = "true" ]]; then
            xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk macosx -configuration Debug -allowProvisioningUpdates
        else
            xcodebuild -project "${xcode_project}" -scheme "${scheme_name}" -sdk macosx -configuration Debug -allowProvisioningUpdates > /dev/null 2>&1
        fi

        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}‚ú${ $project_na}me macOS build successful${NC}"
        else
            echo -e "${RED}‚ù${ $project_na}me macOS build failed${NC}"
            success=false
        fi
    fi

    if [[ "${success}" = "true" ]]; then
        echo -e "${GREEN}ü${â $project_n}ame tests completed successfully${NC}"
        return 0
    else
        echo -e "${RED}ü${• $project_n}ame tests failed${NC}"
        return 1
    fi
}

# Parse arguments
project_name=""
ios_only=false
macos_only=false
verbose=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --ios-only)
            ios_only=true
            shift
            ;;
        --macos-only)
            macos_only=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            if [[ -z "${project_name}" ]]; then
                project_name=$1
            else
                echo -e "${RED}Error: Multiple project names specified${NC}"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "${project_name}" ]]; then
    echo -e "${RED}Error: No project specified${NC}"
    show_usage
    exit 1
fi

if [[ "${project_name}" = "all" ]]; then
    echo -e "${BLUE}Running tests for all projects...${NC}"
    overall_success=true

    for project in "${PROJECTS[@]}"; do
        if ! run_project_tests "${project}" "${ios_only}" "${macos_only}" "${verbose}"; then
            overall_success=false
        fi
        echo ""
    done

    if [[ "${overall_success}" = "true" ]]; then
        echo -e "${GREEN}üéâ All projects tested successfully!${NC}"
        exit 0
    else
        echo -e "${RED}üí• Some projects failed testing${NC}"
        exit 1
    fi
else
    # Check if project exists in our list
    project_found=false
    for project in "${PROJECTS[@]}"; do
        if [[ "${project}" = "${project_name}" ]]; then
            project_found=true
            break
        fi
    done

    if [[ "${project_found}" = "false" ]]; then
        echo -e "${RED}Error: Unknown project '${project_name}'${NC}"
        echo "Available projects:"
        for project in "${PROJECTS[@]}"; do
            echo "  - ${project}"
        done
        exit 1
    fi

    run_project_tests "${project_name}" "${ios_only}" "${macos_only}" "${verbose}"
fi