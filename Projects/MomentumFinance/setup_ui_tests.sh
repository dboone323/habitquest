#!/bin/bash

# Script to add UI Test target to MomentumFinance Xcode project
# This script adds the necessary configuration for UI testing

PROJECT_PATH="/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinance.xcodeproj"
UITESTS_DIR="/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance/MomentumFinanceUITests"

echo "Adding UI Test target to MomentumFinance project..."

# Create Info.plist for UI tests if it doesn't exist
if [[ ! -f "${UITESTS_DIR}/Info.plist" ]]; then
	cat >"${UITESTS_DIR}/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
</dict>
</plist>
EOF
	echo "Created Info.plist for UI tests"
fi

echo "UI Test target setup complete!"
echo ""
echo "To complete the setup:"
echo "1. Open MomentumFinance.xcodeproj in Xcode"
echo "2. Select the project in the Project Navigator"
echo "3. Click the '+' button at the bottom of the targets list"
echo "4. Choose 'UI Testing Bundle' template"
echo "5. Name it 'MomentumFinanceUITests'"
echo "6. Select the MomentumFinance app as the target to test"
echo "7. Add the existing UI test files to the target"
echo ""
echo "Alternatively, you can run the tests using xcodebuild with the -destination flag:"
echo "xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance -destination 'platform=iOS Simulator,name=iPhone 15'"
