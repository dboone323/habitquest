#!/bin/bash
# Fix the ThemeManager appearanceObserver issues

# Fix the init method
sed -i '' '312s/self\.appearanceObserver = nil/#if os(iOS) || os(tvOS)\
        self.appearanceObserver = nil\
        #endif/' AvoidObstaclesGame/Managers/ThemeManager.swift

# Fix the setupSystemAppearanceObserver method
sed -i '' '528s/appearanceObserver = DistributedNotificationCenter/# On macOS, we don'\''t need to store the observer\
                DistributedNotificationCenter/' AvoidObstaclesGame/Managers/ThemeManager.swift

echo "ThemeManager fixes applied"
