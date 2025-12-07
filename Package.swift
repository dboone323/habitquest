// swift-tools-version: 6.0
// HabitQuest - Gamified Habit Tracking App
// Copyright © 2025 HabitQuest. All rights reserved.

import PackageDescription

let package = Package(
    name: "HabitQuest",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "HabitQuest",
            targets: ["HabitQuestCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HabitQuestCore",
            dependencies: [],
            path: "HabitQuest",
            exclude: ["Info.plist", "Preview Content"],
            sources: [
                "Core",
                "Features",
                "Application",
                "Views",
                "ML",
                "Social"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "HabitQuestTests",
            dependencies: ["HabitQuestCore"],
            path: "HabitQuestTests"
        )
    ]
)
