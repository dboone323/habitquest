// swift-tools-version: 6.2
// HabitQuest – Agent Tools
// Copyright © 2026 HabitQuest. All rights reserved.

import Foundation
import PackageDescription

let package = Package(
    name: "HabitQuest",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
    ],
    products: [
        .library(
            name: "HabitQuestCore",
            targets: ["HabitQuestCore"]
        )
    ],
    dependencies: [],
    targets: [
        // Core library
        .target(
            name: "HabitQuestCore",
            dependencies: [],
            path: "Sources/HabitQuestCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "HabitQuestCoreTests",
            dependencies: ["HabitQuestCore"],
            path: "Tests/HabitQuestCoreTests"
        ),
    ]
)
