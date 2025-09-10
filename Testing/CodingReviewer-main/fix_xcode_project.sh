#!/bin/bash
# Fix Xcode project corruption issues

echo "🔧 Fixing Xcode project corruption..."

# Remove problematic metadata
echo "🧹 Cleaning project metadata..."
find CodingReviewer.xcodeproj -name "*.pbxuser" -delete
find CodingReviewer.xcodeproj -name "*.mode1v3" -delete  
find CodingReviewer.xcodeproj -name "*.mode2v3" -delete
find CodingReviewer.xcodeproj -name "*.perspectivev3" -delete
find CodingReviewer.xcodeproj -name "xcuserdata" -exec rm -rf {} +
find CodingReviewer.xcodeproj -name ".DS_Store" -delete

# Fix any extended attributes that might cause issues
echo "🔧 Removing extended attributes..."
xattr -cr CodingReviewer.xcodeproj/

# Validate the project file
echo "✅ Validating project file..."
plutil -lint CodingReviewer.xcodeproj/project.pbxproj

if [ $? -eq 0 ]; then
    echo "✅ Project file validation passed"
else
    echo "❌ Project file validation failed"
    exit 1
fi

# Test build system compatibility
echo "🔨 Testing build system compatibility..."
if xcodebuild -list -project CodingReviewer.xcodeproj; then
    echo "✅ Project schemes and configurations valid"
else
    echo "❌ Project structure invalid"
    exit 1
fi

# Ensure project is compatible with different Xcode versions
echo "🔧 Ensuring Xcode compatibility..."
# Force update scheme files for better CI compatibility
if [ -d "CodingReviewer.xcodeproj/xcshareddata/xcschemes" ]; then
    echo "✅ Shared schemes directory exists"
else
    mkdir -p "CodingReviewer.xcodeproj/xcshareddata/xcschemes"
    echo "📁 Created shared schemes directory"
fi

echo "✅ Xcode project fix completed successfully!"
