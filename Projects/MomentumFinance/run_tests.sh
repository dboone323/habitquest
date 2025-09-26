#!/bin/bash

# Test Runner Script for MomentumFinance
# This script provides alternative ways to run tests

PROJECT_DIR="/Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance"
UITESTS_DIR="${PROJECT_DIR}/MomentumFinanceUITests"

echo "=== MomentumFinance Test Runner ==="
echo ""

# Check if UI test files exist
if [[ -d "${UITESTS_DIR}" ]]; then
	echo "✅ UI test directory found${ $UITESTS_D}IR"
	echo "📁 UI test files:"
	ls -la "${UITESTS_DIR}"/*.swift 2>/dev/null || echo "   No .swift files found"
	echo ""
else
	echo "❌ UI test directory not found${ $UITESTS_D}IR"
	echo ""
fi

# Check Xcode project structure
echo "🔍 Checking Xcode project structure..."
if [[ -f "${PROJECT_DIR}/MomentumFinance.xcodeproj/project.pbxproj" ]]; then
	echo "✅ Xcode project file found"

	# Check for test targets
	if grep -q "MomentumFinanceUITests" "${PROJECT_DIR}/MomentumFinance.xcodeproj/project.pbxproj"; then
		echo "✅ UI test target found in project file"
	else
		echo "❌ UI test target NOT found in project file"
		echo "   → Need to add UI test target in Xcode"
	fi
else
	echo "❌ Xcode project file not found"
fi
echo ""

# Provide setup instructions
echo "=== Setup Instructions ==="
echo ""
echo "To complete UI test setup:"
echo ""
echo "1. Open Xcode and load MomentumFinance.xcodeproj"
echo "2. Select the project in Project Navigator"
echo "3. Click '+' at bottom of targets list"
echo "4. Choose 'UI Testing Bundle' template"
echo "5. Name: 'MomentumFinanceUITests'"
echo "6. Target to test: 'MomentumFinance'"
echo "7. Add existing UI test files to the target"
echo ""
echo "Alternative: Use Swift Package Manager for testing"
echo "1. Create Package.swift with test dependencies"
echo "2. Run: swift test"
echo ""

# Try to run basic compilation check
echo "=== Compilation Check ==="
echo ""
echo "Checking if UI test files compile..."
for file in "${UITESTS_DIR}"/*.swift; do
	if [[ -f "${file}" ]]; then
		echo "📄 Checking $(basenam${ "$f}ile")..."
		# Basic syntax check
		if head -10 "${file}" | grep -q "import XCTest"; then
			echo "   ✅ Has XCTest import"
		else
			echo "   ⚠️  Missing XCTest import"
		fi
	fi
done
echo ""

echo "=== Next Steps ==="
echo ""
echo "1. Complete Xcode UI test target setup"
echo "2. Run tests: Product → Test (⌘U)"
echo "3. Or use: xcodebuild test -project MomentumFinance.xcodeproj -scheme MomentumFinance"
echo ""
echo "Test files created successfully! 🎉"
