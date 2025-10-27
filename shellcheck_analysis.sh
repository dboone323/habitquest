#!/bin/bash

# Comprehensive shellcheck analysis script
# Runs shellcheck on all .sh files in workspace with proper error handling

WORKSPACE_DIR="/Users/danielstevens/Desktop/Quantum-workspace"
LOG_FILE="$WORKSPACE_DIR/shellcheck_analysis.log"
SUMMARY_FILE="$WORKSPACE_DIR/shellcheck_summary.txt"

echo "Starting comprehensive shellcheck analysis..." | tee "$LOG_FILE"
echo "Workspace: $WORKSPACE_DIR" | tee -a "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Find all .sh files
echo "Finding all shell scripts..." | tee -a "$LOG_FILE"
find "$WORKSPACE_DIR" -name "*.sh" -type f > /tmp/shell_files.txt
TOTAL_FILES=$(wc -l < /tmp/shell_files.txt)
echo "Found $TOTAL_FILES shell scripts" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Initialize counters
total_issues=0
error_files=0
ok_files=0
timeout_files=0
processed=0

# Process files in batches of 10
BATCH_SIZE=10
while read -r sh_file; do
    ((processed++))
    echo -n "[$processed/$TOTAL_FILES] Checking $(basename "$sh_file")... " | tee -a "$LOG_FILE"

    # Run shellcheck with timeout and capture output
    if timeout 30s shellcheck -x "$sh_file" 2>&1; then
        echo "OK" | tee -a "$LOG_FILE"
        ((ok_files++))
    else
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo "TIMEOUT" | tee -a "$LOG_FILE"
            ((timeout_files++))
        else
            # Count issues from shellcheck output
            issues=$(timeout 30s shellcheck -x "$sh_file" 2>&1 | grep -c "^.*:")
            echo "$issues issues" | tee -a "$LOG_FILE"
            ((total_issues += issues))
            ((error_files++))
        fi
    fi

    # Progress indicator every 50 files
    if (( processed % 50 == 0 )); then
        echo "Progress: $processed/$TOTAL_FILES files processed" | tee -a "$LOG_FILE"
    fi

done < /tmp/shell_files.txt

# Generate summary
echo "" | tee -a "$LOG_FILE"
echo "=== SHELLCHECK ANALYSIS SUMMARY ===" | tee -a "$LOG_FILE" | tee "$SUMMARY_FILE"
echo "Total files analyzed: $TOTAL_FILES" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "Files with no issues: $ok_files" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "Files with issues: $error_files" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "Files that timed out: $timeout_files" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "Total issues found: $total_issues" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "Analysis completed at: $(date)" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"

# Clean up
rm -f /tmp/shell_files.txt

echo "Analysis complete. See $LOG_FILE for details and $SUMMARY_FILE for summary."