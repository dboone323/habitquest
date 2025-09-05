import LocalAuthentication
import Observation
import OSLog
import SwiftUI

//
//  NavigationCoordinator.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

// Import the proper SearchResult types
// Note: These should be available from the proper architectural location
// If this causes issues, the SearchTypes.swift file needs to be added to Xcode project

/// Handles cross-module navigation in the app with advanced deep linking and search
@MainActor
@Observable
final class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()

    // MARK: - Core Navigation State

    var selectedTab: Int = 0
    var dashboardNavPath = NavigationPath()
    var transactionsNavPath = NavigationPath()
    var budgetsNavPath = NavigationPath()
    var subscriptionsNavPath = NavigationPath()
    var goalsAndReportsNavPath = NavigationPath()

    // MARK: - Enhanced UX Properties

    var isSearchActive: Bool = false
    var searchQuery: String = ""
    var breadcrumbHistory: [BreadcrumbItem] = []
    var isShowingSearchResults: Bool = false

    // MARK: - Authentication State

    var isAuthenticated: Bool = false
    var requiresAuthentication: Bool = true
    var lastAuthenticationTime: Date?
    var authenticationTimeoutInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Deep Linking State

    var pendingDeepLink: DeepLink?
    var lastHandledDeepLink: DeepLink?
    private var lastKnownState: [String: Any] = [:]

    // MARK: - Notification Management

    var hasUnreadNotifications: Bool = false
    var notificationBadgeCounts: [TabSection: Int] = [:]

    // MARK: - macOS Support

    #if os(macOS)
        var selectedSidebarItem: SidebarItem? = .dashboard
        var selectedListItem: ListableItem?
        var columnVisibility = NavigationSplitViewVisibility.all
    #endif

    private let logger = Logger()

    init() {
        // Initialize notification badge counts
        for section in TabSection.allCases {
            notificationBadgeCounts[section] = 0
        }
    }

    // MARK: - Navigation Methods

    func navigateToBudgets() {
        selectedTab = 2 // Assuming budgets is tab index 2
        budgetsNavPath = NavigationPath()
    }

    func navigateToSubscriptions() {
        selectedTab = 3 // Assuming subscriptions is tab index 3
        subscriptionsNavPath = NavigationPath()
    }

    func navigateToGoals() {
        selectedTab = 4 // Assuming goals is tab index 4
        goalsAndReportsNavPath = NavigationPath()
    }

    // MARK: - Search helpers

    func activateSearch() {
        // Keep this minimal and self-contained so callers can toggle search
        isSearchActive = true
        // breadcrumb helper may be provided by other extensions; append a simple marker
        // Avoid referencing external types here to keep this method safe during incremental builds
    }

    func deactivateSearch() {
        isSearchActive = false
        searchQuery = ""
        isShowingSearchResults = false
    }

    func navigateToSearchResult(_ result: SearchResult) {
        // Navigate based on the search result type
        switch result.type {
        case .accounts:
            selectedTab = 0 // Dashboard tab
            dashboardNavPath = NavigationPath()
        case .transactions:
            selectedTab = 1 // Transactions tab
            transactionsNavPath = NavigationPath()
        case .budgets:
            selectedTab = 2 // Budgets tab
            budgetsNavPath = NavigationPath()
        case .subscriptions:
            selectedTab = 3 // Subscriptions tab
            subscriptionsNavPath = NavigationPath()
        case .all:
            // For 'all' type, default to dashboard
            selectedTab = 0
            dashboardNavPath = NavigationPath()
        }

        // Deactivate search after navigation
        deactivateSearch()
    }
}

// All navigation methods are provided by the extracted component extensions:
// - NavigationActions.swift: Tab and deep navigation
// - NavigationAuthentication.swift: Biometric authentication
// - NavigationDeepLinking.swift: Deep link processing
// - NavigationSearch.swift: Search functionality
// - NavigationBreadcrumbs.swift: Navigation history
// - NavigationStateRestoration.swift: State persistence
// - NavigationNotifications.swift: Badge management
// - NavigationMacOS.swift: macOS-specific features
// - NavigationTypes.swift: Supporting types and enums
