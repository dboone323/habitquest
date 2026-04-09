// swift-tools-version: 6.2
// HabitQuest – Agent Tools
// Copyright © 2026 HabitQuest. All rights reserved.

import Foundation
import PackageDescription

private let localSharedKitPath = "../shared-kit"
private let sharedKitDependency: Package.Dependency = FileManager.default.fileExists(atPath: localSharedKitPath)
    ? .package(path: localSharedKitPath)
    : .package(url: "https://github.com/dboone323/shared-kit.git", branch: "main")

let package = Package(
    name: "HabitQuest",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
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
    dependencies: [
        sharedKitDependency,
    ],
    targets: [
        // Core library – contains HabitInsightAgent and consolidated models
        .target(
            name: "HabitQuestCore",
            dependencies: [
                .product(name: "SharedKit", package: "shared-kit"),
            ],
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
