// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CodingReviewerWeb",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "CodingReviewerWeb",
            dependencies: [
                "JavaScriptKit",
                "SwiftWebAPI",
            ]
        ),
    ]
)
