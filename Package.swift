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
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .executable(
            name: "HabitAudit",
            targets: ["HabitAudit"]
        )
    ],
    dependencies: [
        sharedKitDependency,
    ],
    targets: [
        // Core agent library – contains HabitInsightAgent conforming to BaseAgent
        .target(
            name: "HabitAgentCore",
            dependencies: [
                .product(name: "SharedKit", package: "shared-kit"),
            ],
            path: "Sources/HabitAgentCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        // Audit executable
        .executableTarget(
            name: "HabitAudit",
            dependencies: ["HabitAgentCore"],
            path: "Tools",
            exclude: ["ProjectScripts", "Automation"],
            sources: ["HabitAudit.swift"]
        ),
    ]
)
