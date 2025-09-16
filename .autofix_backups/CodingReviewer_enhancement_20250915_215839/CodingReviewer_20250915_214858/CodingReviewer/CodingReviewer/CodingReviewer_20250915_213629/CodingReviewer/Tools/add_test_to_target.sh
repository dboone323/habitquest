#!/bin/bash
# Script to add CodingReviewerTests.swift to CodingReviewerTests target in Xcode project

PROJECT_DIR="/Users/danielstevens/Desktop/Quantum-workspace/Projects/CodingReviewer"
PROJECT_FILE="$PROJECT_DIR/CodingReviewer.xcodeproj/project.pbxproj"
TEST_FILE="CodingReviewerTests/CodingReviewerTests.swift"

# Find the PBXGroup section for CodingReviewerTests
GROUP_ID=$(grep -B2 "path = CodingReviewerTests;" "$PROJECT_FILE" | head -1 | awk '{print $1}')
GROUP_ID=$(echo "$GROUP_ID" | tr -d '"')

# Find the PBXSourcesBuildPhase for CodingReviewerTests target
PHASE_ID=$(grep -B1 "CodingReviewerTests" "$PROJECT_FILE" | grep buildPhases | awk '{print $1}')
PHASE_ID=$(echo "$PHASE_ID" | tr -d '"')

# Add CodingReviewerTests.swift as a PBXFileReference if not present
if ! grep -q "$TEST_FILE" "$PROJECT_FILE"; then
  FILE_REF_ID=$(uuidgen | tr -d '-')
  echo "\t\t$FILE_REF_ID /* $TEST_FILE */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $TEST_FILE; sourceTree = \"<group>\"; };" >> "$PROJECT_FILE"
  # Add to group
  sed -i '' "/$GROUP_ID \/\* CodingReviewerTests \*\//a\\
\t\t\t$FILE_REF_ID /* $TEST_FILE */,
" "$PROJECT_FILE"
else
  FILE_REF_ID=$(grep "$TEST_FILE" "$PROJECT_FILE" | awk '{print $1}')
  FILE_REF_ID=$(echo "$FILE_REF_ID" | tr -d '"')
fi

# Add to sources build phase if not present
if ! grep -q "$FILE_REF_ID" "$PROJECT_FILE"; then
  # Append the file reference just before runOnlyForDeploymentPostprocessing = 0;
  sed -i '' "/$PHASE_ID \/\* Sources \*\//,/runOnlyForDeploymentPostprocessing = 0;/ {
    /runOnlyForDeploymentPostprocessing = 0;/ i\
    			$FILE_REF_ID /* $TEST_FILE */,
  }" "$PROJECT_FILE"
fi
