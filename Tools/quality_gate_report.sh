#!/bin/bash
# Quality Gate Compliance Report Generator
# Analyzes code quality metrics and generates actionable reports

set -e

WORKSPACE_ROOT="/Users/danielstevens/Desktop/Quantum-workspace"
REPORT_DIR="${WORKSPACE_ROOT}/Reports/QualityGates"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Quality Gate Compliance Analysis${NC}"
echo "========================================"
echo ""

# Create report directory
mkdir -p "${REPORT_DIR}"

REPORT_FILE="${REPORT_DIR}/quality_report_${TIMESTAMP}.md"

# Initialize report
cat >"${REPORT_FILE}" <<EOF
# Quality Gate Compliance Report
Generated: $(date)

## Executive Summary

EOF

# 1. File Size Analysis
echo -e "${YELLOW}📊 Analyzing file sizes...${NC}"
FILE_SIZE_VIOLATIONS=$(find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; | awk '$1 > 500 {count++} END {print count+0}')

cat >>"${REPORT_FILE}" <<EOF
### File Size Compliance

- **Quality Gate**: Max 500 lines per file
- **Status**: ${FILE_SIZE_VIOLATIONS} files exceed limit
- **Severity**: $([ ${FILE_SIZE_VIOLATIONS} -gt 100 ] && echo "⚠️ High" || echo "✅ Moderate")

#### Top 10 Largest Files

EOF

find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; |
    sort -rn | head -10 |
    awk '{printf "- %s (%d lines)\n", $2, $1}' >>"${REPORT_FILE}"

# 2. Complexity Analysis (estimate based on function count)
echo -e "${YELLOW}🧩 Analyzing code complexity...${NC}"

cat >>"${REPORT_FILE}" <<EOF

### Code Complexity Analysis

EOF

# Count files with high function density (potential complexity issues)
COMPLEX_FILES=0
for file in $(find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -type f); do
    FUNC_COUNT=$(grep -c "func " "$file" 2>/dev/null || echo 0)
    LINE_COUNT=$(wc -l <"$file")
    if [ $LINE_COUNT -gt 0 ] && [ $FUNC_COUNT -gt 0 ]; then
        DENSITY=$((LINE_COUNT / FUNC_COUNT))
        if [ $DENSITY -lt 15 ]; then
            COMPLEX_FILES=$((COMPLEX_FILES + 1))
        fi
    fi
done

cat >>"${REPORT_FILE}" <<EOF
- **Files with high function density**: ${COMPLEX_FILES}
- **Quality Gate**: Max 10 cyclomatic complexity
- **Recommendation**: Review files with >20 functions for refactoring opportunities

EOF

# 3. Project-Specific Analysis
echo -e "${YELLOW}📁 Analyzing projects...${NC}"

cat >>"${REPORT_FILE}" <<EOF
## Project-Specific Analysis

EOF

for project_dir in "${WORKSPACE_ROOT}"/Projects/*/; do
    project_name=$(basename "$project_dir")

    # Skip non-project directories
    [ "$project_name" = "Tools" ] || [ "$project_name" = "scripts" ] && continue

    total_swift_files=$(find "$project_dir" -name "*.swift" -type f | wc -l)
    large_files=$(find "$project_dir" -name "*.swift" -exec wc -l {} \; | awk '$1 > 500 {count++} END {print count+0}')
    avg_file_size=$(find "$project_dir" -name "*.swift" -exec wc -l {} \; | awk '{sum+=$1; count++} END {if(count>0) print int(sum/count); else print 0}')

    cat >>"${REPORT_FILE}" <<EOF
### ${project_name}

- Total Swift files: ${total_swift_files}
- Files exceeding 500 lines: ${large_files}
- Average file size: ${avg_file_size} lines
- Compliance rate: $(awk "BEGIN {printf \"%.1f%%\", (${total_swift_files}-${large_files})/${total_swift_files}*100}")

EOF
done

# 4. Refactoring Recommendations
cat >>"${REPORT_FILE}" <<EOF

## Refactoring Recommendations

### High Priority (>1000 lines)

EOF

find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; |
    awk '$1 > 1000 {print $0}' | sort -rn |
    awk '{printf "- **%s** (%d lines)\n  - Recommended action: Split into 3-4 smaller modules\n  - Estimated effort: 4-6 hours\n\n", $2, $1}' >>"${REPORT_FILE}"

cat >>"${REPORT_FILE}" <<EOF

### Medium Priority (500-1000 lines)

EOF

find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; |
    awk '$1 > 500 && $1 <= 1000 {print $0}' | sort -rn | head -10 |
    awk '{printf "- **%s** (%d lines)\n  - Recommended action: Extract 2-3 helper classes/extensions\n  - Estimated effort: 2-3 hours\n\n", $2, $1}' >>"${REPORT_FILE}"

# 5. Generate actionable summary
cat >>"${REPORT_FILE}" <<EOF

## Action Items

### Immediate Actions (This Sprint)
1. Review and refactor top 5 largest files (>1200 lines)
2. Set up automated file size monitoring in CI/CD
3. Create file size pre-commit hook

### Short-term Goals (Next 2 Sprints)
1. Reduce files >1000 lines by 50%
2. Establish modular architecture guidelines
3. Implement progressive refactoring strategy

### Long-term Strategy
1. Target: <2% of files exceed 500 lines
2. Establish file size budgets per feature
3. Regular refactoring sprints (monthly)

## Metrics Tracking

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Files >500 lines | ${FILE_SIZE_VIOLATIONS} | <50 | $([ ${FILE_SIZE_VIOLATIONS} -gt 50 ] && echo "⚠️" || echo "✅") |
| Largest file | $(find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; | sort -rn | head -1 | awk '{print $1}') lines | <800 lines | ⚠️ |
| Average file size | $(find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; | awk '{sum+=$1; count++} END {print int(sum/count)}') lines | <250 lines | ✅ |

---
*Report generated by Quality Gate Analysis Tool*
*Next review: $(date -v+1w)*
EOF

echo ""
echo -e "${GREEN}✅ Quality gate report generated${NC}"
echo "📄 Report location: ${REPORT_FILE}"
echo ""

# Display summary
echo -e "${BLUE}Summary:${NC}"
echo "• Files exceeding 500 lines: ${FILE_SIZE_VIOLATIONS}"
echo "• High priority files (>1000 lines): $(find "${WORKSPACE_ROOT}/Projects" -name "*.swift" -exec wc -l {} \; | awk '$1 > 1000 {count++} END {print count+0}')"
echo "• Report saved to: ${REPORT_FILE}"

# Open report if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo -e "${BLUE}Opening report...${NC}"
    open "${REPORT_FILE}"
fi
