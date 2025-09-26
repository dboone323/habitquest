#!/bin/bash

# Quantum Workspace Code Quality Assessment Script
# Comprehensive linting and formatting analysis across all projects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
WORKSPACE_ROOT="${SCRIPT_DIR}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Projects to analyze
PROJECTS=("AvoidObstaclesGame" "HabitQuest" "MomentumFinance" "PlannerApp" "CodingReviewer")

# Results storage
QUALITY_REPORT="${WORKSPACE_ROOT}/CODE_QUALITY_REPORT_$(date +%Y%m%d_%H%M%S).md"

echo -e "${BLUE}🔍 QUANTUM WORKSPACE CODE QUALITY ASSESSMENT${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}Report: ${QUALITY_REPORT}${NC}"
echo ""

# Initialize report
cat > "${QUALITY_REPORT}" << EOF
# Quantum Workspace Code Quality Report

**Date**: $(date)
**Assessment**: Comprehensive Code Quality Analysis
**Projects Analyzed**: ${#PROJECTS[@]}

## Executive Summary

EOF

# Function to analyze project code quality
analyze_project_quality() {
    local project_name=$1
    local project_path="${WORKSPACE_ROOT}/Projects/${project_name}"

    echo -e "${PURPLE}🔬 Analyzi$$$${g $}pro}jec}t_n}ame...${NC}"
    echo "### ${project_name} Code Quality Analysis" >> "${QUALITY_REPORT}"
    echo "" >> "${QUALITY_REPORT}"

    cd "${project_path}"

    # Count Swift files
    local swift_files
    swift_files=$(find . -name "*.swift" -type f | wc -l | tr -d ' ')

    # Run SwiftLint and capture output
    local lint_output
    lint_output=$(swiftlint --strict 2>&1)
    local lint_exit_code=$?

    # Extract violation count
    local violation_count
    violation_count=$(echo "${lint_output}" | grep -c "error:" || echo "0")

    # Run SwiftFormat (dry run to see what would be changed)
    local format_output
    format_output=$(swiftformat . --dry-run 2>&1 || echo "SwiftFormat failed")
    local format_exit_code=$?

    # Count files that would be formatted
    local files_to_format
    files_to_format=$(echo "${format_output}" | grep -c "would be formatted" || echo "0")

    # Calculate code metrics
    local total_lines=0
    local large_files=0
    local long_lines=0

    while IFS= read -r file; do
        if [[ -f "${file}" ]]; then
            local file_lines
            file_lines=$(wc -l < "${file}")
            total_lines=$((total_lines + file_lines))

            if [[ "${file_lines}" -gt 400 ]]; then
                large_files=$((large_files + 1))
            fi

            # Count lines longer than 120 characters
            local long_lines_in_file
            long_lines_in_file=$(awk 'length($0) > 120 {count++} END {print count+0}' "${file}")
            long_lines=$((long_lines + long_lines_in_file))
        fi
    done < <(find . -name "*.swift" -type f)

    local avg_lines_per_file=0
    if [[ "${swift_files}" -gt 0 ]]; then
        avg_lines_per_file=$((total_lines / swift_files))
    fi

    # Output results
    echo -e "${CYAN}�${� ${project_n}}ame Metrics:${NC}"
    echo -e "  📁 Swift File$$$${: }$sw}ift}_fi}les"
    echo -e "  📏 Total Line$$$${: }$to}tal}_li}nes"
    echo -e "  📏 Avg Lines/Fil$$$${: $avg_li}nes}_pe}r_f}ile"
    echo -e "  🚨 Lint Violation$$$${: $vio}lat}ion}_co}unt"
    echo -e "  🎨 Files to Forma$$$${: $fil}es_}to_}for}mat"
    echo -e "  📏 Large Files (>400 lines$$$${: }$la}rge}_fi}les"
    echo -e "  📏 Long Lines (>120 chars$$$${:} $l}ong}_li}nes"
    echo ""

    # Add to report
    cat >> "${QUALITY_REPORT}" << EOF
| Metric | Value |
|--------|-------|
| Swift Files | ${swift_files} |
| Total Lines of Code | ${total_lines} |
| Average Lines per File | ${avg_lines_per_file} |
| SwiftLint Violations | ${violation_count} |
| Files Needing Formatting | ${files_to_format} |
| Files > 400 Lines | ${large_files} |
| Lines > 120 Characters | ${long_lines} |

EOF

    # Add violation summary if violations exist
    if [[ "${violation_count}" -gt 0 ]]; then
        echo "#### Top Violation Types" >> "${QUALITY_REPORT}"
        echo "" >> "${QUALITY_REPORT}"
        echo "${lint_output}" | grep "error:" | sed 's/.*error: //' | sort | uniq -c | sort -nr | head -10 | while read -r count violation; do
            echo "- **${violation}**: ${count} occurrences" >> "${QUALITY_REPORT}"
        done
        echo "" >> "${QUALITY_REPORT}"
    fi
}

# Analyze all projects
total_violations=0
total_files=0
total_lines=0

for project in "${PROJECTS[@]}"; do
    if [[ -d "${WORKSPACE_ROOT}/Projects/${project}" ]]; then
        analyze_project_quality "${project}"
    else
        echo -e "${YELLOW}⚠️  Proj$${${${ }}}$pro}ject not found, skipping${NC}"
    fi
done

# Generate summary
cat >> "${QUALITY_REPORT}" << EOF

## Code Quality Recommendations

### Immediate Actions (High Priority)
1. **Fix SwiftLint Violations**: Address critical code quality issues
2. **Format Code**: Apply SwiftFormat to standardize code style
3. **Reduce File Sizes**: Break down files exceeding 400 lines
4. **Fix Line Lengths**: Ensure lines stay under 120 characters

### Medium Priority
1. **Resolve TODO Comments**: Complete pending development tasks
2. **Improve Identifier Names**: Use descriptive variable names
3. **Remove Force Casts**: Replace with safer casting alternatives
4. **Clean Up Overrides**: Remove unnecessary overridden methods

### Long-term Improvements
1. **Implement Code Coverage**: Add comprehensive test coverage
2. **Set up CI/CD Quality Gates**: Automate quality checks
3. **Regular Code Reviews**: Maintain code quality standards
4. **Documentation**: Add comprehensive code documentation

### Quality Metrics Targets
- **SwiftLint Violations**: Target < 50 per project
- **File Length**: Maximum 400 lines per file
- **Line Length**: Maximum 120 characters
- **Test Coverage**: Minimum 70%
- **Code Complexity**: Maintain readable, maintainable code

---

**Assessment Completed**: $(date)
**Generated by**: Quantum Workspace Code Quality Suite v1.0
EOF

echo -e "${GREEN}✅ Code quality assessment completed!${NC}"
echo -e "${CYAN}📊 Results saved t$$$${: $QU}ALI}TY_}REP}ORT${NC}"

# Display summary
echo ""
echo -e "${BLUE}📈 ASSESSMENT SUMMARY${NC}"
echo -e "${BLUE}===================${NC}"
echo -e "${CYAN}Report Location: ${QUALITY_REPORT}${NC}"
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Review the detailed report"
echo -e "  2. Prioritize fixing critical violations"
echo -e "  3. Run SwiftFormat on all projects"
echo -e "  4. Address file size and complexity issues"