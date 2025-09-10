#!/bin/bash
# Convert Xcode project to be compatible with older Xcode versions

echo "🔧 Converting project to older Xcode format for CI compatibility..."

PROJECT_FILE="CodingReviewer.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Project file not found: $PROJECT_FILE"
    exit 1
fi

echo "📋 Current project format:"
grep "objectVersion" "$PROJECT_FILE" || echo "No objectVersion found"

# Backup original
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Convert objectVersion 77 (Xcode 16+) to objectVersion 56 (Xcode 14+)
# This makes it compatible with GitHub Actions Xcode versions
sed -i '' 's/objectVersion = 77;/objectVersion = 56;/' "$PROJECT_FILE"

# Verify the change
echo "📋 Updated project format:"
grep "objectVersion" "$PROJECT_FILE" || echo "No objectVersion found"

# Validate the updated file
if plutil -lint "$PROJECT_FILE" >/dev/null 2>&1; then
    echo "✅ Project file validation successful"
    
    # Test with local Xcode to ensure we didn't break anything
    if xcodebuild -list -project CodingReviewer.xcodeproj >/dev/null 2>&1; then
        echo "✅ Project file is readable by Xcode"
        echo "🎯 Project format conversion completed successfully!"
    else
        echo "⚠️  Warning: Project may have issues, but continuing..."
        echo "🔧 Conversion completed - testing in CI will verify compatibility"
    fi
else
    echo "❌ Project file validation failed after conversion"
    echo "🔄 Restoring backup..."
    mv "$PROJECT_FILE.backup" "$PROJECT_FILE"
    exit 1
fi
