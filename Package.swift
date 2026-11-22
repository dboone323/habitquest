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
        ),
        .executable(
            name: "HabitAudit",
            targets: ["HabitAudit"]
        )
    ],
    dependencies: [],
    targets: [
        // Core library – contains HabitInsightAgent and consolidated models
        .target(
            name: "HabitQuestCore",
            dependencies: [],
            path: "Sources/HabitQuestCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        // Audit executable
        .executableTarget(
            name: "HabitAudit",
            dependencies: ["HabitQuestCore"],
            path: "Tools",
            exclude: ["ProjectScripts", "Automation"],
            sources: ["HabitAudit.swift"]
        ),
        .testTarget(
            name: "HabitQuestCoreTests",
            dependencies: ["HabitQuestCore"],
            path: "Tests/HabitQuestCoreTests"
        ),
    ]
)
