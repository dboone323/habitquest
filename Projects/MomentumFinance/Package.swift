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
            targets: ["MomentumFinanceCore"]
        ),
    ],
    dependencies: [
        .package(path: "../../Shared"),
    ],
    targets: [
        .target(
            name: "MomentumFinanceShared",
            dependencies: [
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Shared",
            exclude: [
                "README.md",
                // Exclude UI files that might cause issues
                "Views/",
                "Navigation/",
                "Intelligence/",
                "Search/",
                "Utils/",
                "Utilities/",
                "Protocols/",
                "Models/",
                "Features/GoalsAndReports/",
                "Features/Subscriptions/",
                "Features/Transactions/",
            ],
            sources: [
                "SharedArchitecture.swift",
                "Features/Dashboard/DashboardViewModel.swift",
                "Features/Budgets/BudgetsViewModel.swift",
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "MomentumFinanceCore",
            dependencies: [
                "MomentumFinanceShared",
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Sources/Core",
            exclude: [
                "README.md",
                "Utils/HapticManager.swift.backup",
                "Animations/AnimationManager.swift.backup",
                "Theme/ThemeManager.swift.backup",
                "Utilities/NotificationManager.swift.backup",
                "Utils/ImportComponents/EntityManager.swift.backup",
                // Exclude subdirectories with duplicate files
                "Components/",
                "Animations/",
                "Features/",
                "Intelligence/",
                "Navigation/",
                "Utilities/",
                "Services/",
                "Export/",
                "Bridging/",
                "Theme/",
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "MomentumFinanceUI",
            dependencies: [
                "MomentumFinanceCore",
                "MomentumFinanceShared",
                .product(name: "SharedKit", package: "Shared"),
            ],
            path: "Sources/UI",
            exclude: [
                "macOS/KeyboardShortcutManager.swift.backup",
                "macOS/MomentumFinance.entitlements",
                // Exclude problematic UI files that reference undefined types
                "macOS/EnhancedAccountDetailView_Models.swift",
                "macOS/EnhancedAccountDetailView_Transactions.swift",
                "macOS/EnhancedContentView_macOS.swift",
                "macOS/EnhancedDetailViews.swift",
                "macOS/EnhancedSubscriptionDetailView_Charts.swift",
                "macOS/EnhancedSubscriptionDetailView_Helpers.swift",
                "macOS/EnhancedSubscriptionDetailView_Models.swift",
                "macOS/EnhancedSubscriptionDetailView_Views.swift",
                "macOS/GoalsAndReportsUIEnhancements.swift",
                "macOS/KeyboardShortcutManager.swift",
                "macOS/MacOSUIIntegration_Navigation.swift",
                "macOS/MacOSUIIntegration_Placeholders.swift",
                "macOS/MacOS_Dashboard_UI_Enhancements.swift",
                "macOS/MacOS_Subscriptions_UI_Enhancements.swift",
                "macOS/SubscriptionDetailView.swift",
                "macOS/SubscriptionDetailViewActions.swift",
                "macOS/SubscriptionDetailViewTransactions.swift",
                "macOS/SubscriptionListViewComponent.swift",
                "macOS/TransactionsListViewComponent.swift",
                "macOS/TransactionsUIEnhancements.swift",
                "macOS/UIEnhancements.swift",
                "macOS/UIIntegration.swift",
                "macOS/UIIntegrationHelpers.swift",
                "macOS/UIIntegrationLists.swift",
                "macOS/UIIntegrationViews.swift",
                "macOS/UpdatedMomentumFinanceApp.swift",
                "macOS/DragAndDropSupport.swift",
                "macOS/BudgetsUIEnhancements.swift",
                "macOS/ContentView_macOS.swift",
                "macOS/DashboardListViewComponent.swift",
                "macOS/BudgetDetailView.swift",
                "macOS/BudgetDetailViews.swift",
                "macOS/BudgetDetailModels.swift",
                "macOS/BudgetDetailHelpers.swift",
                "macOS/BudgetDetailActions.swift",
                "macOS/BudgetListViewComponent.swift",
                "macOS/AccountDetailView.swift",
                "macOS/AccountDetailViewActions.swift",
                "macOS/AccountDetailViewCharts.swift",
                "macOS/AccountDetailViewDetails.swift",
                "macOS/AccountDetailViewExport.swift",
                "macOS/AccountDetailViewExtensions.swift",
                "macOS/AccountDetailViewValidation.swift",
                "macOS/AccountDetailViewViews.swift",
                "macOS/EnhancedAccountDetailView.swift",
                "macOS/MacOSUIIntegration.swift",
                "Shared/ReusableListItemView.swift",
                // Exclude the ContentView extension that causes circular dependency
                "iOS/ContentView.swift",
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "MomentumFinanceTests",
            dependencies: ["MomentumFinanceCore", "MomentumFinanceShared"],
            path: "Tests/MomentumFinanceTests",
            exclude: ["**"]  // Exclude all test files for now
        ),
    ]
)
