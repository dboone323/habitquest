// swift-tools-version: 6.0
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import PackageDescription

let package = Package(
    name: "MomentumFinance",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "MomentumFinance",
            targets: ["MomentumFinanceCore", "MomentumFinanceUI"]
        ),
    ],
    dependencies: [
        .package(path: "../../Shared"),
    ],
    targets: [
        .target(
            name: "MomentumFinanceCore",
            dependencies: [
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Sources/Core",
            exclude: [
                "README.md",
                "Utils/HapticManager.swift.backup",
                "Animations/AnimationManager.swift.backup",
                "Theme/ThemeManager.swift.backup",
                "Utilities/NotificationManager.swift.backup",
                "Utils/ImportComponents/EntityManager.swift.backup",
                // Exclude subdirectories with duplicate files
                "Components/",
                "Animations/",
                "Features/",
                "Intelligence/",
                "Navigation/",
                "Utilities/",
                "Services/",
                "Export/",
                "Bridging/",
                "Theme/",
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "MomentumFinanceUI",
            dependencies: [
                "MomentumFinanceCore",
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Sources/UI",
            exclude: [
                "macOS/KeyboardShortcutManager.swift.backup",
                "macOS/MomentumFinance.entitlements",
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "MomentumFinanceTests",
            dependencies: ["MomentumFinanceCore"],
            path: "Tests/MomentumFinanceTests"
        ),
    ]
)
