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
    dependencies: [],
    targets: [
        .target(
            name: "MomentumFinance",
            dependencies: [],
            path: "Shared",
            resources: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "MomentumFinanceTests",
            dependencies: ["MomentumFinance"]
        ),
    ]
)
