// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CodingReviewer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CodingReviewer",
            targets: ["CodingReviewer"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "CodingReviewer",
            dependencies: [],
            path: "Sources",
            exclude: ["Tests", "Core/Services/OllamaCodeAnalysisService.swift"]
        ),
        .testTarget(
            name: "CodingReviewerTests",
            dependencies: ["CodingReviewer"],
            path: "Sources/Tests"
        )
    ]
)
