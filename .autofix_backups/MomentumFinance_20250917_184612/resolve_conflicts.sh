#!/bin/bash

# Resolve merge conflicts by keeping HEAD version
PROJECT_FILE="MomentumFinance.xcodeproj/project.pbxproj"

# Create a temporary file for processing
cp "$PROJECT_FILE" "${PROJECT_FILE}.tmp"

# Process the file to remove conflict markers and branch content
awk '
BEGIN { in_conflict = 0; keep_section = 0 }
/^<<<<<<< HEAD$/ { 
    in_conflict = 1; 
    keep_section = 1; 
    next 
}
/^=======/ { 
    if (in_conflict) {
        keep_section = 0;
        next
    }
}
/^>>>>>>> [a-f0-9]{7}$/ { 
    if (in_conflict) {
        in_conflict = 0;
        keep_section = 1;
        next
    }
}
{
    if (!in_conflict || keep_section) {
        print $0
    }
}
' "${PROJECT_FILE}.tmp" >"$PROJECT_FILE"

# Clean up
rm "${PROJECT_FILE}.tmp"

echo "Conflicts resolved - kept HEAD version"
