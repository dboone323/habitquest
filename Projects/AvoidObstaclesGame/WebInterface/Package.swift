// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AvoidObstaclesGameWeb",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
    ],
    targets: [
        .executableTarget(
            name: "AvoidObstaclesGameWeb",
            dependencies: [
                "JavaScriptKit",
            ]
        ),
    ]
)
