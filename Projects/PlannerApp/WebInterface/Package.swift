// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PlannerAppWeb",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "PlannerAppWeb", targets: ["PlannerAppWeb"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "PlannerAppWeb",
            dependencies: [
                "JavaScriptKit",
                "SwiftWebAPI",
            ],
            path: "Sources/PlannerAppWeb"
        ),
    ]
)
