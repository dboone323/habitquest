// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodingReviewer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(name: "CodingReviewer", targets: ["CodingReviewer"]),
    ],
    dependencies: [
        .package(path: "../../Shared"),
    ],
    targets: [
        .target(
            name: "CodingReviewerLib",
            dependencies: [
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Sources",
            exclude: ["CodingReviewer"],
            sources: [
                "Core",
                "Models",
                "Services",
                "UI",
            ]
        ),
        .executableTarget(
            name: "CodingReviewer",
            dependencies: ["CodingReviewerLib"]
        ),
    ]
)
