// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuantumChemistry",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "QuantumChemistryDemo",
            targets: ["QuantumChemistry"]
        ),
        .library(
            name: "QuantumChemistryKit",
            targets: ["QuantumChemistryKit"]
        ),
    ],
    dependencies: [
        // No external dependencies for standalone quantum supremacy demo
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "QuantumChemistry",
            dependencies: ["QuantumChemistryKit"],
            path: "Sources/QuantumChemistry",
            sources: ["QuantumChemistryDemo.swift"] // Use demo instead of main.swift
        ),
        .target(
            name: "QuantumChemistryKit",
            dependencies: [],
            path: "Sources/QuantumChemistryKit"
        ),
        .testTarget(
            name: "QuantumChemistryTests",
            dependencies: ["QuantumChemistryKit"],
            path: "Tests/QuantumChemistryTests"
        ),
    ]
)