// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"]),
    ],
    targets: [
        // The SharedCore target includes only model and utility sources to avoid
        // compiling app-specific UI code under the package. App UI remains in
        // the Xcode project and imports SharedCore for logic/shared types.
        .target(
            name: "SharedCore",
            path: ".",
            exclude: [
                "Package.swift", "README.md", "Tests", "Features", "Theme", "Views", "Animations",
                "Features/Transactions/TransactionsView.swift",
                "Features/GoalsAndReports/SavingsGoalViews.swift",
                "Features/GoalsAndReports/SavingsGoalManagementViews.swift",
                "Features/Budgets/BudgetsView.swift", "Utils/HapticManager.swift",
                "Theme/ColorTheme.swift",
            ],
            sources: ["Utilities", "Models", "Navigation", "Utils", "Intelligence"]
        ),
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"],
            path: "Tests"
        ),
    ]
)
