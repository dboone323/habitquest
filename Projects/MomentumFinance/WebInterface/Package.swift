// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MomentumFinanceWeb",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "MomentumFinanceWeb",
            dependencies: [
                "JavaScriptKit",
                "SwiftWebAPI"
            ]
        )
    ]
)
