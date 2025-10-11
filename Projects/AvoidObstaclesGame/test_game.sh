#!/bin/bash

echo "Starting AvoidObstaclesGame test..."

# Build and run the project in the simulator
cd "$(dirname "$0")" || exit

echo "Building project..."
if xcodebuild -project AvoidObstaclesGame.xcodeproj -scheme AvoidObstaclesGame -destination 'platform=iOS Simulator,name=iPhone 17' build; then
  echo "Build successful! Starting simulator..."

  # Boot the simulator if not already running
  xcrun simctl boot "iPhone 17" 2>/dev/null || true

  # Open the simulator
  open -a Simulator

  # Install and launch the app
  APP_PATH="/Users/danielstevens/Library/Developer/Xcode/DerivedData/AvoidObstaclesGame-bhbjbhmmtvjkotgsgpqwvuwmtezr/Build/Products/Debug-iphonesimulator/AvoidObstaclesGame.app"

  if [[ -d ${APP_PATH} ]]; then
    echo "Installing app on simulator..."
    xcrun simctl install "iPhone 17" "${APP_PATH}"

    echo "Launching AvoidObstaclesGame..."
    xcrun simctl launch "iPhone 17" com.DanielStevens.AvoidObstaclesGame

    echo "Game launched successfully! Check the simulator to test all features:"
    echo "1. High score tracking (top 10 scores)"
    echo "2. Progressive difficulty system"
    echo "3. Enhanced UI with level indicators"
    echo "4. Visual feedback for level ups and high scores"
  else
    echo "Error: App bundle not found at ${APP_PATH}"
  fi
else
  echo "Build failed!"
fi
