#!/bin/bash
# Auto-applicable enhancements for safe improvements

set -euo pipefail

PROJECT_PATH="$1"
cd "$PROJECT_PATH"

echo "🤖 Applying safe enhancements..."

# Optimize array operations
echo "🔧 Optimizing array operations..."
find . -name "*.swift" -type f -exec sed -i.bak '
    /for.*in.*{/{
        N
        s/for \([^{]*\) {\n[[:space:]]*\([^.]*\)\.append(\([^)]*\))/\2 += \1.map { \3 }/
    }
' {} \;
find . -name "*.swift.bak" -delete
echo "✅ Array operations optimized"

# Add basic accessibility labels
echo "🔧 Adding basic accessibility labels..."
find . -name "*.swift" -type f -exec sed -i.bak '
    s/Button(\([^)]*\))/Button(\1).accessibilityLabel("Button")/g
    s/TextField(\([^)]*\))/TextField(\1).accessibilityLabel("Text Field")/g
' {} \;
find . -name "*.swift.bak" -delete
echo "✅ Basic accessibility labels added"
