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
            targets: ["MomentumFinance"]
        ),
    ],
    dependencies: [
        .package(path: "../../Shared"),
    ],
    targets: [
        .target(
            name: "MomentumFinance",
            dependencies: ["SharedKit"],
            path: ".",
            exclude: ["UI/macOS", "UI/iOS", "Sources/UI/macOS", "Sources/UI/iOS"], // Exclude platform-specific UI for now
            sources: [
                "Core",
                "Features",
                "App",
                "Shared",
                "Sources"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "MomentumFinanceTests",
            dependencies: ["MomentumFinance"],
            path: "Tests/MomentumFinanceTests"
        ),
    ]
)
