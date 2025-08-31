import LocalAuthentication // Added for biometric authentication
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

    // Published properties for tab selection and module navigation
    var selectedTab: Int = 0
    var dashboardNavPath = NavigationPath()
    var transactionsNavPath = NavigationPath()
    var budgetsNavPath = NavigationPath()
    var subscriptionsNavPath = NavigationPath()
    var goalsAndReportsNavPath = NavigationPath()

    // Enhanced UX properties
    var isSearchActive: Bool = false
    var searchQuery: String = ""
    var breadcrumbHistory: [NavigationTypes.BreadcrumbItem] = []
    var isShowingSearchResults: Bool = false

    // Authentication and security state
    var isAuthenticated: Bool = false
    var requiresAuthentication: Bool = true
    var lastAuthenticationTime: Date?
    var authenticationTimeoutInterval: TimeInterval = 300 // 5 minutes

    // Deep linking properties
    var pendingDeepLink: NavigationTypes.DeepLink?
    var lastHandledDeepLink: NavigationTypes.DeepLink?

    // State restoration
    private var lastKnownState: [String: Any] = [:]

    // Notification management
    var hasUnreadNotifications: Bool = false
    var notificationBadgeCounts: [NavigationTypes.TabSection: Int] = [:]

    // macOS specific navigation properties
    #if os(macOS)
        // Selected item in the sidebar navigation
        var selectedSidebarItem: NavigationTypes.SidebarItem? = .dashboard

        // Selected item in the middle column list
        var selectedListItem: NavigationTypes.ListableItem?

        // Column visibility control for NavigationSplitView
        var columnVisibility = NavigationSplitViewVisibility.all
    #endif

    // Logger for debugging navigation
    private let logger = Logger()

    init() {
        // Initialize notification badge counts
        for section in NavigationTypes.TabSection.allCases {
            notificationBadgeCounts[section] = 0
        }
    }
}

// MARK: - Extensions using extracted components

extension NavigationCoordinator {
    // Navigation Actions
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
        accountId: String, context: NavigationTypes.NavigationContext
    ) {
        Features.NavigationActions.navigateToAccountTransactions(
            coordinator: self, accountId: accountId, context: context
        )
    }

    func navigateToGoalTransactions(goalId: String) {
        Features.NavigationActions.navigateToGoalTransactions(coordinator: self, goalId: goalId)
    }

    // Authentication
    func authenticateWithBiometrics() async -> Bool {
        await Features.NavigationAuthentication.authenticateWithBiometrics(coordinator: self)
    }

    func checkAuthenticationStatus() -> Bool {
        Features.NavigationAuthentication.checkAuthenticationStatus(coordinator: self)
    }

    func resetAuthentication() {
        Features.NavigationAuthentication.resetAuthentication(coordinator: self)
    }

    // Deep Linking
    func handleDeepLink(_ url: URL) -> Bool {
        Features.NavigationDeepLinking.handleDeepLink(coordinator: self, url: url)
    }

    func processDeepLink(_ deepLink: NavigationTypes.DeepLink) -> Bool {
        Features.NavigationDeepLinking.processDeepLink(coordinator: self, deepLink: deepLink)
    }

    func processPendingDeepLink() -> Bool {
        Features.NavigationDeepLinking.processPendingDeepLink(coordinator: self)
    }

    // Search & Discovery
    func activateSearch() {
        Features.NavigationSearch.activateSearch(coordinator: self)
    }

    func deactivateSearch() {
        Features.NavigationSearch.deactivateSearch(coordinator: self)
    }

    func navigateToSearchResult(_ result: NavigationTypes.SearchResult) {
        Features.NavigationSearch.navigateToSearchResult(coordinator: self, result: result)
    }

    // Breadcrumbs
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

    // State Restoration
    func saveNavigationState() {
        Features.NavigationStateRestoration.saveNavigationState(coordinator: self)
    }

    func restoreNavigationState() -> Bool {
        Features.NavigationStateRestoration.restoreNavigationState(coordinator: self)
    }

    // Notification Integration
    func updateNotificationBadgeCount(for section: NavigationTypes.TabSection, count: Int) {
        Features.NavigationNotifications.updateNotificationBadgeCount(
            coordinator: self, section: section, count: count
        )
    }

    func navigateToNotification(_ notification: NavigationTypes.AppNotification) {
        Features.NavigationNotifications.navigateToNotification(
            coordinator: self, notification: notification
        )
    }

    func navigateToAllNotifications(for section: NavigationTypes.TabSection) {
        Features.NavigationNotifications.navigateToAllNotifications(
            coordinator: self, section: section
        )
    }

    func clearNotificationBadges(for section: NavigationTypes.TabSection) {
        Features.NavigationNotifications.clearNotificationBadges(
            coordinator: self, section: section
        )
    }

    // Utility methods
    func navigateToTransactionDetail(transactionId: String) {
        selectedTab = 1 // Transactions tab
        let context = NavigationTypes.NavigationContext(
            breadcrumbTitle: "Transaction Detail",
            sourceModule: "Notifications"
        )
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)
    }

    func resetAllPaths() {
        dashboardNavPath = NavigationPath()
        transactionsNavPath = NavigationPath()
        budgetsNavPath = NavigationPath()
        subscriptionsNavPath = NavigationPath()
        goalsAndReportsNavPath = NavigationPath()
    }

    #if os(macOS)
        // macOS Navigation Support
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
    #endif
}
