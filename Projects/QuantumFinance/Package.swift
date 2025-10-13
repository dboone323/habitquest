// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QuantumFinance",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "QuantumFinanceDemo", targets: ["QuantumFinanceDemo"]),
        .library(name: "QuantumFinanceKit", targets: ["QuantumFinanceKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "QuantumFinanceKit",
            dependencies: [],
            path: "Sources/QuantumFinanceKit"
        ),
        .target(
            name: "QuantumFinanceDemo",
            dependencies: ["QuantumFinanceKit"],
            path: "Sources/QuantumFinanceDemo"
        ),
        .testTarget(
            name: "QuantumFinanceTests",
            dependencies: ["QuantumFinanceKit"],
            path: "Tests/QuantumFinanceTests"
        )
    ]
)