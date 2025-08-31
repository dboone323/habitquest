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
    var breadcrumbHistory: [Features.NavigationTypes.BreadcrumbItem] = []
    var isShowingSearchResults: Bool = false

    // MARK: - Authentication State

    var isAuthenticated: Bool = false
    var requiresAuthentication: Bool = true
    var lastAuthenticationTime: Date?
    var authenticationTimeoutInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Deep Linking State

    var pendingDeepLink: Features.NavigationTypes.DeepLink?
    var lastHandledDeepLink: Features.NavigationTypes.DeepLink?
    private var lastKnownState: [String: Any] = [:]

    // MARK: - Notification Management

    var hasUnreadNotifications: Bool = false
    var notificationBadgeCounts: [Features.NavigationTypes.TabSection: Int] = [:]

    // MARK: - macOS Support

    #if os(macOS)
        var selectedSidebarItem: Features.NavigationTypes.SidebarItem? = .dashboard
        var selectedListItem: Features.NavigationTypes.ListableItem?
        var columnVisibility = NavigationSplitViewVisibility.all
    #endif

    private let logger = Logger()

    init() {
        // Initialize notification badge counts
        for section in Features.NavigationTypes.TabSection.allCases {
            notificationBadgeCounts[section] = 0
        }
    }
}

// MARK: - Navigation Actions

extension NavigationCoordinator {
    func navigateToTab(_ tabIndex: Int) {
        Features.NavigationActions.navigateToTab(coordinator: self, tabIndex: tabIndex)
    }

    func navigateToTransactions() {
        Features.NavigationActions.navigateToTransactions(coordinator: self)
    }

    func navigateToBudgets() {
        Features.NavigationActions.navigateToBudgets(coordinator: self)
    }

    func navigateToSubscriptions() {
        Features.NavigationActions.navigateToSubscriptions(coordinator: self)
    }

    func navigateToGoals() {
        Features.NavigationActions.navigateToGoals(coordinator: self)
    }

    func navigateToAccountDetail(accountId: String) {
        Features.NavigationActions.navigateToAccountDetail(coordinator: self, accountId: accountId)
    }

    func navigateToSubscriptionDetail(subscriptionId: String) {
        Features.NavigationActions.navigateToSubscriptionDetail(
            coordinator: self, subscriptionId: subscriptionId
        )
    }

    func navigateToBudgetCategory(categoryId: String) {
        Features.NavigationActions.navigateToBudgetCategory(
            coordinator: self, categoryId: categoryId
        )
    }

    func navigateToGoalDetail(goalId: String) {
        Features.NavigationActions.navigateToGoalDetail(coordinator: self, goalId: goalId)
    }

    func navigateToCategoryTransactions(categoryId: String, sourceTab: Int? = nil) {
        Features.NavigationActions.navigateToCategoryTransactions(
            coordinator: self, categoryId: categoryId, sourceTab: sourceTab
        )
    }

    func navigateToAccountTransactions(
        accountId: String, context: Features.NavigationTypes.NavigationContext
    ) {
        Features.NavigationActions.navigateToAccountTransactions(
            coordinator: self, accountId: accountId, context: context
        )
    }

    func navigateToGoalTransactions(goalId: String) {
        Features.NavigationActions.navigateToGoalTransactions(coordinator: self, goalId: goalId)
    }

    func resetAllPaths() {
        dashboardNavPath = NavigationPath()
        transactionsNavPath = NavigationPath()
        budgetsNavPath = NavigationPath()
        subscriptionsNavPath = NavigationPath()
        goalsAndReportsNavPath = NavigationPath()
    }
}

// MARK: - Authentication

extension NavigationCoordinator {
    func authenticateWithBiometrics() async -> Bool {
        await Features.NavigationAuthentication.authenticateWithBiometrics(coordinator: self)
    }

    func checkAuthenticationStatus() -> Bool {
        Features.NavigationAuthentication.checkAuthenticationStatus(coordinator: self)
    }

    func resetAuthentication() {
        Features.NavigationAuthentication.resetAuthentication(coordinator: self)
    }
}

// MARK: - Deep Linking

extension NavigationCoordinator {
    func handleDeepLink(_ url: URL) -> Bool {
        Features.NavigationDeepLinking.handleDeepLink(coordinator: self, url: url)
    }

    func processDeepLink(_ deepLink: Features.NavigationTypes.DeepLink) -> Bool {
        Features.NavigationDeepLinking.processDeepLink(coordinator: self, deepLink: deepLink)
    }

    func processPendingDeepLink() -> Bool {
        Features.NavigationDeepLinking.processPendingDeepLink(coordinator: self)
    }
}

// MARK: - Search & Discovery

extension NavigationCoordinator {
    func activateSearch() {
        Features.NavigationSearch.activateSearch(coordinator: self)
    }

    func deactivateSearch() {
        Features.NavigationSearch.deactivateSearch(coordinator: self)
    }

    func navigateToSearchResult(_ result: Features.NavigationTypes.SearchResult) {
        Features.NavigationSearch.navigateToSearchResult(coordinator: self, result: result)
    }
}

// MARK: - Breadcrumbs

extension NavigationCoordinator {
    func addBreadcrumb(title: String, tabIndex: Int) {
        Features.NavigationBreadcrumbs.addBreadcrumb(
            coordinator: self, title: title, tabIndex: tabIndex
        )
    }

    func navigateBack() {
        Features.NavigationBreadcrumbs.navigateBack(coordinator: self)
    }

    func clearBreadcrumbs() {
        Features.NavigationBreadcrumbs.clearBreadcrumbs(coordinator: self)
    }
}

// MARK: - State Restoration

extension NavigationCoordinator {
    func saveNavigationState() {
        Features.NavigationStateRestoration.saveNavigationState(coordinator: self)
    }

    func restoreNavigationState() -> Bool {
        Features.NavigationStateRestoration.restoreNavigationState(coordinator: self)
    }
}

// MARK: - Notification Integration

extension NavigationCoordinator {
    func updateNotificationBadgeCount(for section: Features.NavigationTypes.TabSection, count: Int) {
        Features.NavigationNotifications.updateNotificationBadgeCount(
            coordinator: self, section: section, count: count
        )
    }

    func navigateToNotification(_ notification: Features.NavigationTypes.AppNotification) {
        Features.NavigationNotifications.navigateToNotification(
            coordinator: self, notification: notification
        )
    }

    func navigateToAllNotifications(for section: Features.NavigationTypes.TabSection) {
        Features.NavigationNotifications.navigateToAllNotifications(
            coordinator: self, section: section
        )
    }

    func clearNotificationBadges(for section: Features.NavigationTypes.TabSection) {
        Features.NavigationNotifications.clearNotificationBadges(
            coordinator: self, section: section
        )
    }
}

// MARK: - Helper Methods

extension NavigationCoordinator {
    func navigateToTransactionDetail(transactionId: String) {
        selectedTab = 1 // Transactions tab
        let context = Features.NavigationTypes.NavigationContext(
            breadcrumbTitle: "Transaction Detail",
            sourceModule: "Notifications"
        )
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)
    }
}

// MARK: - macOS Navigation Support

#if os(macOS)
    extension NavigationCoordinator {
        func navigateToAccount(accountId: String) {
            Features.NavigationMacOS.navigateToAccount(coordinator: self, accountId: accountId)
        }

        func navigateToTransaction(transactionId: String, transactionName: String) {
            Features.NavigationMacOS.navigateToTransaction(
                coordinator: self, transactionId: transactionId, transactionName: transactionName
            )
        }

        func navigateToBudget(budgetId: String, budgetName: String) {
            Features.NavigationMacOS.navigateToBudget(
                coordinator: self, budgetId: budgetId, budgetName: budgetName
            )
        }

        func navigateToSubscription(subscriptionId: String, subscriptionName: String) {
            Features.NavigationMacOS.navigateToSubscription(
                coordinator: self, subscriptionId: subscriptionId,
                subscriptionName: subscriptionName
            )
        }

        func navigateToGoal(goalId: String, goalName: String) {
            Features.NavigationMacOS.navigateToGoal(
                coordinator: self, goalId: goalId, goalName: goalName
            )
        }

        func navigateToReport(reportType: String) {
            Features.NavigationMacOS.navigateToReport(coordinator: self, reportType: reportType)
        }

        func toggleSidebar() {
            Features.NavigationMacOS.toggleSidebar(coordinator: self)
        }
    }
#endif
