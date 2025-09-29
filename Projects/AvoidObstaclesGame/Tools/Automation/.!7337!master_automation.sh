#!/bin/bash

# Master Automation Controller for Unified Code Architecture
CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECTS_DIR="${CODE_DIR}/Projects"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
	echo -e "${BLUE}[AUTOMATION]${NC} $1"
}

print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

# List available projects
list_projects() {
	print_status "Available projects in unified Code architecture:"
	for project in "${PROJECTS_DIR}"/*; do
		if [[ -d ${project} ]]; then
			local project_name
			project_name=$(basename "${project}")
			local swift_files
			swift_files=$(find "${project}" -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
			local has_automation=""
			if [[ -d "${project}/automation" ]]; then
				has_automation=" (✅ automation)"
			else
				has_automation=" (❌ no automation)"
			fi
			echo "  - ${project_name}: ${swift_files} Swift files${has_automation}"
		fi
	done
}

# Run automation for specific project
run_project_automation() {
	local project_name="$1"
	local project_path="${PROJECTS_DIR}/${project_name}"

	if [[ ! -d ${project_path} ]]; then
		echo "❌ Project ${project_name} not found"
		return 1
	fi

	print_status "Running automation for ${project_name}..."

	if [[ -f "${project_path}/automation/run_automation.sh" ]]; then
		cd "${project_path}" && bash automation/run_automation.sh
		print_success "${project_name} automation completed"
	else
		print_warning "No automation script found for ${project_name}"
		return 1
	fi
}

# Run automation for all projects
run_all_automation() {
	print_status "Running automation for all projects..."
	local overall_success=true

	for project in "${PROJECTS_DIR}"/*; do
		if [[ -d ${project} ]]; then
			local current_project
			current_project=$(basename "${project}")

			case "${current_project}" in
			Tools | scripts | Config)
				continue
				;;
			esac

			print_status "Processing ${current_project}..."
			if run_project_automation "${current_project}"; then
				print_success "${current_project} automation completed"
			else
				print_warning "${current_project} automation encountered issues"
				overall_success=false
			fi
			echo ""
		fi
	done

	if [[ ${overall_success} == "true" ]]; then
		print_success "All project automations completed"
		return 0
	fi

	print_warning "Some project automations did not complete successfully"
	return 1
}

# Format code using SwiftFormat
format_code() {
	local project_name="${1-}"

	if [[ -n ${project_name} ]]; then
		local project_path="${PROJECTS_DIR}/${project_name}"
		if [[ ! -d ${project_path} ]]; then
			echo "❌ Project ${project_name} not found"
			return 1
		fi
		print_status "Formatting Swift code in ${project_name}..."
		swiftformat "${project_path}" --exclude "*.backup" 2>/dev/null
		print_success "Code formatting completed for ${project_name}"
	else
		print_status "Formatting Swift code in all projects..."
		for project in "${PROJECTS_DIR}"/*; do
			if [[ -d ${project} ]]; then
				local current_project
				current_project=$(basename "${project}")
				print_status "Formatting ${current_project}..."
				swiftformat "${project}" --exclude "*.backup" 2>/dev/null
			fi
		done
		print_success "Code formatting completed for all projects"
	fi
}

# Lint code using SwiftLint
lint_code() {
	local project_name="${1-}"

	if [[ -n ${project_name} ]]; then
		local project_path="${PROJECTS_DIR}/${project_name}"
		if [[ ! -d ${project_path} ]]; then
			echo "❌ Project ${project_name} not found"
			return 1
		fi
		print_status "Linting Swift code in ${project_name}..."
		if ! cd "${project_path}"; then
			print_warning "Unable to enter ${project_path}"
			return 1
		fi
		swiftlint
		print_success "Code linting completed for ${project_name}"
	else
		print_status "Linting Swift code in all projects..."
		for project in "${PROJECTS_DIR}"/*; do
			if [[ -d ${project} ]]; then
				local current_project
				current_project=$(basename "${project}")
				print_status "Linting ${current_project}..."
				(cd "${project}" && swiftlint)
			fi
		done
		print_success "Code linting completed for all projects"
	fi
}

# Initialize CocoaPods for a project
init_pods() {
	local project_name="$1"
	local project_path="${PROJECTS_DIR}/${project_name}"

	if [[ ! -d ${project_path} ]]; then
		echo "❌ Project ${project_name} not found"
		return 1
	fi

	print_status "Initializing CocoaPods for ${project_name}..."
	cd "${project_path}" || return 1

	if [[ ! -f "Podfile" ]]; then
		print_status "Creating Podfile..."
		pod init
		print_success "Podfile created"
	else
		print_status "Installing/updating pods..."
		pod install
		print_success "CocoaPods setup completed"
	fi
}

# Setup Fastlane for iOS deployment
init_fastlane() {
	local project_name="$1"
	local project_path="${PROJECTS_DIR}/${project_name}"

	if [[ ! -d ${project_path} ]]; then
		echo "❌ Project ${project_name} not found"
		return 1
	fi

	print_status "Setting up Fastlane for ${project_name}..."
	cd "${project_path}" || return 1

	if [[ ! -d "fastlane" ]]; then
		print_status "Initializing Fastlane..."
		fastlane init
		print_success "Fastlane initialized"
	else
		print_status "Fastlane already configured"
	fi
}

# Show unified architecture status
show_status() {
	print_status "Unified Code Architecture Status"
	echo ""

	echo "📍 Locatio${: $CODE_}DIR"
	echo "📊 Projects: $(fin${ "$PROJECTS_}DIR" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ')"

	# Check tool availability
	echo ""
	print_status "Development Tools:"
	check_tool "xcodebuild" "Xcode Build System"
	check_tool "swift" "Swift Compiler"
	check_tool "swiftlint" "SwiftLint"
	check_tool "swiftformat" "SwiftFormat"
	check_tool "fastlane" "Fastlane"
	check_tool "pod" "CocoaPods"
	check_tool "git" "Git"
	check_tool "python3" "Python"

	echo ""
	list_projects
}

# Check if a tool is available
check_tool() {
	local tool="$1"
	local description="$2"
	if command -v "${tool}" &>/dev/null; then
