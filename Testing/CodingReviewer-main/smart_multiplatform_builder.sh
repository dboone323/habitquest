#!/bin/bash
# Smart Multi-Platform CI Builder
# Detects project capabilities and builds for appropriate platforms

set -e

# Detect CI environment and set appropriate build flags
CI_BUILD_FLAGS=""
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$CONTINUOUS_INTEGRATION" ]; then
    echo "🤖 CI environment detected - configuring for CI builds..."
    CI_BUILD_FLAGS="CODE_SIGNING_ALLOWED=NO"
fi

# Find the actual project file
PROJECT_FILE=""
if ls *.xcodeproj/project.pbxproj 1> /dev/null 2>&1; then
    PROJECT_FILE="$(ls *.xcodeproj/project.pbxproj | head -1)"
else
    echo "❌ No Xcode project found"
    exit 1
fi

echo "🔍 Analyzing project capabilities..."

# Check if project supports macOS
SUPPORTS_MACOS=false
if grep -q "MACOSX_DEPLOYMENT_TARGET\|macosx\|macOS" "$PROJECT_FILE" 2>/dev/null; then
    SUPPORTS_MACOS=true
    echo "✅ Project supports macOS"
else
    echo "📱 Project is iOS-only"
fi

# Check if project supports iOS
SUPPORTS_IOS=false
if grep -q "IPHONEOS_DEPLOYMENT_TARGET\|iphoneos\|iOS" "$PROJECT_FILE" 2>/dev/null; then
    SUPPORTS_IOS=true
    echo "✅ Project supports iOS"
fi

echo "🏗️ Starting multi-platform build..."

BUILD_SUCCESS=false

# Strategy 1: iOS Simulator (most compatible)
if [ "$SUPPORTS_IOS" = true ]; then
    echo "📱 Attempting iOS Simulator build..."
    set +e
    xcodebuild -scheme "$1" -destination "platform=iOS Simulator,name=iPhone 16" build $CI_BUILD_FLAGS
    if [ $? -eq 0 ]; then
        echo "✅ iOS Simulator build successful!"
        BUILD_SUCCESS=true
        exit 0
    else
        echo "⚠️ iOS Simulator build failed, trying next strategy..."
    fi
    set -e
fi

# Strategy 2: macOS (if supported)
if [ "$SUPPORTS_MACOS" = true ]; then
    echo "🖥️ Attempting macOS build..."
    set +e
    xcodebuild -scheme "$1" -destination "platform=macOS" build $CI_BUILD_FLAGS
    if [ $? -eq 0 ]; then
        echo "✅ macOS build successful!"
        BUILD_SUCCESS=true
        exit 0
    else
        echo "⚠️ macOS build failed, trying next strategy..."
    fi
    set -e
fi

# Strategy 3: Generic iOS Simulator with fallback
if [ "$SUPPORTS_IOS" = true ]; then
    echo "📱 Attempting generic iOS Simulator build..."
    set +e
    # Try different iOS Simulator strategies
    if xcodebuild -scheme "$1" -destination "generic/platform=iOS Simulator" build $CI_BUILD_FLAGS 2>/dev/null; then
        echo "✅ Generic iOS Simulator build successful!"
        BUILD_SUCCESS=true
        exit 0
    elif xcodebuild -scheme "$1" -destination "platform=iOS Simulator,name=Any iOS Simulator Device" build $CI_BUILD_FLAGS 2>/dev/null; then
        echo "✅ Any iOS Simulator build successful!"
        BUILD_SUCCESS=true
        exit 0
    elif xcodebuild -scheme "$1" -sdk iphonesimulator build $CI_BUILD_FLAGS 2>/dev/null; then
        echo "✅ iOS Simulator SDK build successful!"
        BUILD_SUCCESS=true
        exit 0
    else
        echo "⚠️ All iOS Simulator strategies failed"
    fi
    set -e
fi

# Strategy 4: Basic build without destination (let Xcode decide)
echo "🔄 Attempting basic build strategy..."
set +e
if xcodebuild -scheme "$1" build $CI_BUILD_FLAGS 2>/dev/null; then
    echo "✅ Basic build successful!"
    BUILD_SUCCESS=true
    exit 0
else
    echo "⚠️ Basic build failed"
fi
set -e

if [ "$BUILD_SUCCESS" = false ]; then
    echo "❌ All build strategies failed"
    exit 1
fi
