#!/bin/bash

# Comprehensive Test Validation Script for Quantum Workspace Projects
# This script runs tests for all projects and validates test coverage

# Removed 'set -e' to ensure the script completes all project validations
set -u

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

# Check built app bundle for Info.plist & CFBundleIdentifier
check_app_plist() {
	local app_path="$1"
	if [[ ! -d "${app_path}" ]]; then
		print_status "$RED" "  ❌ App bundle not found${ $app_pa}th"
		return 1
	fi
	local plist_candidates=(
		"${app_path}/Contents/Info.plist" # macOS structure
		"${app_path}/Info.plist"          # iOS / Catalyst
	)
	local plist_file=""
	for p in "${plist_candidates[@]}"; do
		if [[ -f "${p}" ]]; then
			plist_file="${p}"
			break
		fi
	done
	if [[ -z "${plist_file}" ]]; then
		print_status "$RED" "  ❌ Info.plist missing in app bundle"
		return 1
	fi
	if ! /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${plist_file}" >/dev/null 2>&1; then
		print_status "$RED" "  ❌ CFBundleIdentifier missing in Info.plist"
		return 1
	fi
	print_status "$GREEN" "  ✅ Info.plist valid (CFBundleIdentifier present)"
	return 0
}

# Function to run tests for a project
run_project_tests() {
	local project=$1
	local project_path="${PROJECTS_DIR}/${project}"

	if [[ ! -d "${project_path}" ]]; then
		print_status "$RED" "❌ Project directory not found${ $proje}ct"
		return 1
	fi

	print_status "$BLUE" "🔍 Testi${g $proj}ect..."

	cd "${project_path}" || exit

	# Check if it's an Xcode project
	if [[ -d "${project}.xcodeproj" ]]; then
		print_status "$YELLOW" "  Building and testing with Xcode..."

		# Build the project
		local build_log="/tmp/${project}_build.log"
		local test_log="/tmp/${project}_test.log"
		if xcodebuild -project "${project}.xcodeproj" -scheme "${project}" -configuration Debug -allowProvisioningUpdates build >"${build_log}" 2>&1; then
			print_status "$GREEN" "  ✅ Build successful fo${ $proje}ct"

			# Try to locate built app (macOS or iOS simulator) for plist check
			local derived="$(getconf DARWIN_USER_CACHE_DIR 2>/dev/null || echo "${HOME}/Library/Developer/Xcode/DerivedData")"
			# Fallback to standard DerivedData root if getconf path not valid
			local app_bundle
			app_bundle=$(find "${HOME}/Library/Developer/Xcode/DerivedData" -type d -name "${project}.app" -maxdepth 8 2>/dev/null | head -n 1)
			if [[ -n "${app_bundle}" ]]; then
				check_app_plist "${app_bundle}" || print_status "$YELLOW" "  ⚠️  Proceeding despite plist issue"
			else
				print_status "$YELLOW" "  ⚠️  Could not locate built app bundle for plist validation"
			fi

			# Run tests capturing xcresult path
			local xcresult_path=""
			if xcodebuild -project "${project}.xcodeproj" -scheme "${project}" -configuration Debug -allowProvisioningUpdates test ENABLE_TESTABILITY=YES RESULT_BUNDLE_PATH="/tmp/${project}.xcresult" >"${test_log}" 2>&1; then
				xcresult_path="/tmp/${project}.xcresult"
				print_status "$GREEN" "  ✅ All tests passed fo${ $proje}ct"
				# Parse counts
				if [[ -d "${xcresult_path}" ]]; then
					local summary_json="/tmp/${project}_summary.json"
					xcrun xcresulttool get --path "${xcresult_path}" --format json >"${summary_json}" 2>/dev/null || true
					# Basic extraction (total & failed) using grep/sed (lightweight)
					local total_tests failed_tests
					total_tests=$(grep -o '"testStatus"' "${summary_json}" | wc -l | tr -d ' ')
					failed_tests=$(grep -o '"testStatus" : "Failure"' "${summary_json}" | wc -l | tr -d ' ')
					print_status "$BLUE" "  ℹ️  Tests: to${al=$total_t}ests fai${ed=$failed_t}ests"
				fi
				return 0
			else
				# Classify failure: look for bundle identifier issue or UITest failure markers
				if grep -q "CFBundleIdentifier not found" "${test_log}"; then
					print_status "$RED" "  ❌ UITest launch failure (missing CFBundleIdentifier)"
				elif grep -qi "UITest" "${test_log}"; then
					print_status "$RED" "  ❌ UITest-related failure detected"
				else
					print_status "$RED" "  ❌ Unit test or build during test phase failed"
				fi
				print_status "$YELLOW" "  ℹ️  ${ee $test}_log for details"
				return 1
			fi
		else
			print_status "$RED" "  ❌ Build failed fo${ $proje}ct (se${ $build_l}og)"
			return 1
		fi
	else
		print_status "$YELLOW" "  No Xcode project found, checking for Swift Package Manager..."

		# Check for Package.swift
		if [[ -f "Package.swift" ]]; then
			print_status "$YELLOW" "  Building and testing with SwiftPM..."

			if swift build; then
				print_status "$GREEN" "  ✅ Build successful fo${ $proje}ct"

				if swift test; then
					print_status "$GREEN" "  ✅ Tests passed fo${ $proje}ct"
					return 0
				else
					print_status "$RED" "  ❌ Tests failed fo${ $proje}ct"
					return 1
				fi
			else
				print_status "$RED" "  ❌ Build failed fo${ $proje}ct"
				return 1
			fi
		else
			print_status "$YELLOW" "  No build system detected for ${project}"
			return 1
		fi
	fi
}

# Function to validate test file existence
validate_test_files() {
	local project=$1
	local project_path="${PROJECTS_DIR}/${project}"

	print_status "$BLUE" "📋 Validating test files f${r $proj}ect..."

	# Look for test files
	local test_files
	test_files=$(find "${project_path}" -name "*Tests*.swift" -o -name "*Test*.swift" 2>/dev/null | wc -l)

	if [[ "${test_files}" -gt 0 ]]; then
		print_status "$GREEN" "  ✅ Foun${ $test_fil}es test file(s) i${ $proje}ct"

		# List the test files
		find "${project_path}" -name "*Tests*.swift" -o -name "*Test*.swift" 2>/dev/null | while read -r file; do
			echo "    📄 $(basenam${ "$f}ile")"
		done

		return 0
	else
		print_status "$RED" "  ❌ No test files found i${ $proje}ct"
		return 1
	fi
}

# Main execution
echo ""
print_status "$BLUE" "📊 Test File Validation"
echo "========================"

total_projects=${#PROJECTS[@]}
passed_validation=0
failed_validation=0

for project in "${PROJECTS[@]}"; do
	if validate_test_files "${project}"; then
		((passed_validation++))
	else
		((failed_validation++))
		# Continue even if a project's test files are missing
	fi
	echo ""
done

echo ""
print_status "$BLUE" "🧪 Test Execution"
echo "=================="

passed_tests=0
failed_tests=0

for project in "${PROJECTS[@]}"; do
	if run_project_tests "${project}"; then
		((passed_tests++))
	else
		((failed_tests++))
		# Continue even if build/tests fail for a project
	fi
	echo ""
done

# Summary
echo ""
print_status "$BLUE" "📈 Test Validation Summary"
echo "==========================="

echo "Test File Validation:"
echo "  ✅ Passed${ $passed_validati}o${/$total_projec}ts projects"
echo "  ❌ Failed${ $failed_validati}o${/$total_projec}ts projects"

echo ""
echo "Test Execution:"
echo "  ✅ Passed${ $passed_tes}t${/$total_projec}ts projects"
echo "  ❌ Failed${ $failed_tes}t${/$total_projec}ts projects"

echo ""
if [[ "$failed_validation" -eq 0 ]] && [[ "$failed_tests" -eq 0 ]]; then
	print_status "$GREEN" "🎉 All tests validated successfully!"
	exit 0
else
	print_status "$RED" "⚠️  Some tests failed validation or execution"
	exit 1
fi
