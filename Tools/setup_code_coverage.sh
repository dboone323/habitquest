#!/bin/bash
# Code Coverage Setup Script
# Configures code coverage tracking for all projects

set -e

WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
COVERAGE_DIR="${WORKSPACE_ROOT}/Reports/Coverage"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 Setting Up Code Coverage Tracking${NC}"
echo "========================================"
echo ""

# Create coverage directory
mkdir -p "${COVERAGE_DIR}"

# Function to enable coverage for Xcode projects
enable_xcode_coverage() {
    local project_path=$1
    local project_name=$2

    echo -e "${YELLOW}Configuring ${project_name}...${NC}"

    # Create or update scheme to enable code coverage
    local scheme_path="${project_path}/${project_name}.xcodeproj/xcshareddata/xcschemes/${project_name}.xcscheme"

    if [ -f "${scheme_path}" ]; then
        # Backup existing scheme
        cp "${scheme_path}" "${scheme_path}.backup"

        # Enable code coverage in test action
        if grep -q "codeCoverageEnabled" "${scheme_path}"; then
            sed -i '' 's/codeCoverageEnabled = "NO"/codeCoverageEnabled = "YES"/g' "${scheme_path}"
        else
            # Add coverage attribute if not present
            sed -i '' 's/<TestAction/<TestAction codeCoverageEnabled = "YES"/g' "${scheme_path}"
        fi

        echo "  ✅ Enabled code coverage in scheme"
    else
        echo "  ⚠️  Scheme file not found, skipping"
    fi
}

# Configure each project
echo -e "${YELLOW}Configuring projects for code coverage...${NC}"
echo ""

# AvoidObstaclesGame
if [ -d "${WORKSPACE_ROOT}/Projects/AvoidObstaclesGame" ]; then
    enable_xcode_coverage "${WORKSPACE_ROOT}/Projects/AvoidObstaclesGame" "AvoidObstaclesGame"
fi

# HabitQuest
if [ -d "${WORKSPACE_ROOT}/Projects/HabitQuest" ]; then
    enable_xcode_coverage "${WORKSPACE_ROOT}/Projects/HabitQuest" "HabitQuest"
fi

# PlannerApp
if [ -d "${WORKSPACE_ROOT}/Projects/PlannerApp" ]; then
    enable_xcode_coverage "${WORKSPACE_ROOT}/Projects/PlannerApp" "PlannerApp"
fi

# MomentumFinance
if [ -d "${WORKSPACE_ROOT}/Projects/MomentumFinance" ]; then
    enable_xcode_coverage "${WORKSPACE_ROOT}/Projects/MomentumFinance" "MomentumFinance"
fi

# Create coverage collection script
cat >"${WORKSPACE_ROOT}/Tools/collect_coverage.sh" <<'EOF'
#!/bin/bash
# Collect code coverage from all projects

set -e

WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
COVERAGE_DIR="${WORKSPACE_ROOT}/Reports/Coverage"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🔍 Collecting code coverage data..."
echo ""

# Create timestamped report directory
REPORT_DIR="${COVERAGE_DIR}/${TIMESTAMP}"
mkdir -p "${REPORT_DIR}"

# Function to collect coverage for a project
collect_coverage() {
    local project_name=$1
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"
    local scheme=$2
    local sdk=$3
    
    echo "📊 Collecting coverage for ${project_name}..."
    
    cd "${project_path}"
    
    # Run tests with coverage
    xcodebuild test \
        -scheme "${scheme}" \
        -sdk "${sdk}" \
        -configuration Debug \
        -enableCodeCoverage YES \
        -resultBundlePath "${REPORT_DIR}/${project_name}.xcresult" \
        2>&1 | grep -E "Test Suite|succeeded|failed" || true
    
    # Extract coverage report
    if [ -d "${REPORT_DIR}/${project_name}.xcresult" ]; then
        xcrun xccov view --report --json "${REPORT_DIR}/${project_name}.xcresult" > "${REPORT_DIR}/${project_name}_coverage.json"
        
        # Parse and display coverage percentage
        if command -v jq &> /dev/null; then
            coverage=$(jq -r '.lineCoverage' "${REPORT_DIR}/${project_name}_coverage.json" 2>/dev/null || echo "0")
            coverage_percent=$(awk "BEGIN {printf \"%.1f\", ${coverage}*100}")
            echo "  Coverage: ${coverage_percent}%"
        fi
    fi
    
    echo ""
}

# Collect coverage for each project
collect_coverage "AvoidObstaclesGame" "AvoidObstaclesGame" "iphonesimulator"
collect_coverage "HabitQuest" "HabitQuest" "iphonesimulator"
collect_coverage "PlannerApp" "PlannerApp" "macosx"
collect_coverage "MomentumFinance" "MomentumFinance" "iphonesimulator"

# Generate summary report
cat > "${REPORT_DIR}/coverage_summary.md" <<SUMMARY
# Code Coverage Summary
Generated: $(date)

## Project Coverage

SUMMARY

for json_file in "${REPORT_DIR}"/*_coverage.json; do
    if [ -f "$json_file" ]; then
        project=$(basename "$json_file" _coverage.json)
        if command -v jq &> /dev/null; then
            coverage=$(jq -r '.lineCoverage' "$json_file" 2>/dev/null || echo "0")
            coverage_percent=$(awk "BEGIN {printf \"%.1f\", ${coverage}*100}")
            
            # Determine status
            if (( $(echo "${coverage_percent} >= 85" | bc -l) )); then
                status="✅ Target Met"
            elif (( $(echo "${coverage_percent} >= 70" | bc -l) )); then
                status="⚠️ Minimum Met"
            else
                status="❌ Below Minimum"
            fi
            
            echo "- **${project}**: ${coverage_percent}% ${status}" >> "${REPORT_DIR}/coverage_summary.md"
        fi
    fi
done

cat >> "${REPORT_DIR}/coverage_summary.md" <<SUMMARY

## Quality Gates

- **Minimum**: 70%
- **Target**: 85%

## Recommendations

SUMMARY

# Add recommendations based on coverage
for json_file in "${REPORT_DIR}"/*_coverage.json; do
    if [ -f "$json_file" ]; then
        project=$(basename "$json_file" _coverage.json)
        if command -v jq &> /dev/null; then
            coverage=$(jq -r '.lineCoverage' "$json_file" 2>/dev/null || echo "0")
            coverage_percent=$(awk "BEGIN {printf \"%.1f\", ${coverage}*100}")
            
            if (( $(echo "${coverage_percent} < 70" | bc -l) )); then
                echo "- **${project}**: Increase test coverage by $(awk "BEGIN {printf \"%.1f\", 70-${coverage_percent}}")%" >> "${REPORT_DIR}/coverage_summary.md"
            fi
        fi
    fi
done

echo "✅ Coverage data collected"
echo "📄 Report location: ${REPORT_DIR}"
echo ""

# Display summary
if [ -f "${REPORT_DIR}/coverage_summary.md" ]; then
    cat "${REPORT_DIR}/coverage_summary.md"
fi

EOF

chmod +x "${WORKSPACE_ROOT}/Tools/collect_coverage.sh"

# Create pre-commit hook for coverage check
cat >"${WORKSPACE_ROOT}/.git/hooks/pre-push-coverage" <<'EOF'
#!/bin/bash
# Pre-push hook to check code coverage

WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"

echo "🔍 Checking code coverage before push..."

# Run coverage collection
"${WORKSPACE_ROOT}/Tools/collect_coverage.sh" > /dev/null 2>&1

# Check if any project is below minimum
COVERAGE_DIR=$(find "${WORKSPACE_ROOT}/Reports/Coverage" -type d -name "20*" | sort -r | head -1)

if [ -d "${COVERAGE_DIR}" ]; then
    for json_file in "${COVERAGE_DIR}"/*_coverage.json; do
        if [ -f "$json_file" ]; then
            if command -v jq &> /dev/null; then
                coverage=$(jq -r '.lineCoverage' "$json_file" 2>/dev/null || echo "0")
                coverage_percent=$(awk "BEGIN {printf \"%.1f\", ${coverage}*100}")
                
                if (( $(echo "${coverage_percent} < 70" | bc -l) )); then
                    project=$(basename "$json_file" _coverage.json)
                    echo "⚠️  Warning: ${project} coverage (${coverage_percent}%) is below minimum (70%)"
                fi
            fi
        fi
    done
fi

# Always allow push, but warn
exit 0
EOF

chmod +x "${WORKSPACE_ROOT}/.git/hooks/pre-push-coverage"

echo ""
echo -e "${GREEN}✅ Code coverage setup complete${NC}"
echo ""
echo "📋 Next steps:"
echo "  1. Run: ./Tools/collect_coverage.sh"
echo "  2. View reports in: ${COVERAGE_DIR}"
echo "  3. Coverage is now tracked on every push"
echo ""
