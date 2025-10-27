#!/bin/bash

# Comprehensive shellcheck analysis script
# Runs shellcheck on all .sh files in workspace

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
LOG_FILE="$WORKSPACE_DIR/shellcheck_analysis.log"
SUMMARY_FILE="$WORKSPACE_DIR/shellcheck_summary.txt"

echo "Starting comprehensive shellcheck analysis..." > "$LOG_FILE"
echo "Workspace: $WORKSPACE_DIR" >> "$LOG_FILE"
echo "Started at: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Find all .sh files
echo "Finding all shell scripts..." >> "$LOG_FILE"
find "$WORKSPACE_DIR" -name "*.sh" -type f > /tmp/shell_files.txt 2>/dev/null
TOTAL_FILES=$(wc -l < /tmp/shell_files.txt)
echo "Found $TOTAL_FILES shell scripts" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Initialize counters
total_issues=0
error_files=0
ok_files=0
processed=0

# Process each file
while read -r sh_file; do
    ((processed++))
    basename_file=$(basename "$sh_file")

    # Run shellcheck and capture output
    output=$(shellcheck -x "$sh_file" 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "[$processed/$TOTAL_FILES] $basename_file: OK" >> "$LOG_FILE"
        ((ok_files++))
    else
        # Count issues (lines that look like "filename line X: message")
        issues=$(echo "$output" | grep -c "^In $basename_file line [0-9]\+:")
        echo "[$processed/$TOTAL_FILES] $basename_file: $issues issues" >> "$LOG_FILE"
        ((total_issues += issues))
        ((error_files++))

        # Append the actual issues to log
        echo "$output" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
    fi

    # Progress indicator every 50 files
    if (( processed % 50 == 0 )); then
        echo "Progress: $processed/$TOTAL_FILES files processed" >> "$LOG_FILE"
    fi

done < /tmp/shell_files.txt

# Generate summary
echo "" >> "$LOG_FILE"
echo "=== SHELLCHECK ANALYSIS SUMMARY ===" >> "$LOG_FILE"
echo "Total files analyzed: $TOTAL_FILES" >> "$LOG_FILE"
echo "Files with no issues: $ok_files" >> "$LOG_FILE"
echo "Files with issues: $error_files" >> "$LOG_FILE"
echo "Total issues found: $total_issues" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "Analysis completed at: $(date)" >> "$LOG_FILE"

# Create summary file
cat > "$SUMMARY_FILE" << EOF
=== SHELLCHECK ANALYSIS SUMMARY ===
Total files analyzed: $TOTAL_FILES
Files with no issues: $ok_files
Files with issues: $error_files
Total issues found: $total_issues

Analysis completed at: $(date)

See $LOG_FILE for detailed results.
EOF

# Clean up
rm -f /tmp/shell_files.txt

echo "Analysis complete. See $LOG_FILE for details and $SUMMARY_FILE for summary."