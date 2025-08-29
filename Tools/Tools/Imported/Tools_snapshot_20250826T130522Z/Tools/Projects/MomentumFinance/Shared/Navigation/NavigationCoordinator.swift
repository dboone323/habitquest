<<<<<<< HEAD
import LocalAuthentication // Added for biometric authentication
import Observation
import OSLog
=======
import LocalAuthentication
import OSLog
import Observation
>>>>>>> 1cf3938 (Create working state for recovery)
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

<<<<<<< HEAD
    // Published properties for tab selection and module navigation
=======
    // MARK: - Core Navigation State
>>>>>>> 1cf3938 (Create working state for recovery)
    var selectedTab: Int = 0
    var dashboardNavPath = NavigationPath()
    var transactionsNavPath = NavigationPath()
    var budgetsNavPath = NavigationPath()
    var subscriptionsNavPath = NavigationPath()
    var goalsAndReportsNavPath = NavigationPath()

<<<<<<< HEAD
    // Enhanced UX properties
=======
    // MARK: - Enhanced UX Properties
>>>>>>> 1cf3938 (Create working state for recovery)
    var isSearchActive: Bool = false
    var searchQuery: String = ""
    var breadcrumbHistory: [BreadcrumbItem] = []
    var isShowingSearchResults: Bool = false

<<<<<<< HEAD
    // Authentication and security state
    var isAuthenticated: Bool = false
    var requiresAuthentication: Bool = true
    var lastAuthenticationTime: Date?
    var authenticationTimeoutInterval: TimeInterval = 300 // 5 minutes

    // Deep linking properties
    var pendingDeepLink: DeepLink?
    var lastHandledDeepLink: DeepLink?

    // State restoration
    private var lastKnownState: [String: Any] = [:]

    // Notification management
    var hasUnreadNotifications: Bool = false
    var notificationBadgeCounts: [TabSection: Int] = [:]

    // macOS specific navigation properties
    #if os(macOS)
    // Selected item in the sidebar navigation
    var selectedSidebarItem: SidebarItem? = .dashboard

    // Selected item in the middle column list
    var selectedListItem: ListableItem?

    // Column visibility control for NavigationSplitView
    var columnVisibility = NavigationSplitViewVisibility.all
    #endif

    // Logger for debugging navigation
    // Uses static Logger methods directly
=======
    // MARK: - Authentication State
    var isAuthenticated: Bool = false
    var requiresAuthentication: Bool = true
    var lastAuthenticationTime: Date?
    var authenticationTimeoutInterval: TimeInterval = 300  // 5 minutes

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
>>>>>>> 1cf3938 (Create working state for recovery)

    init() {
        // Initialize notification badge counts
        for section in TabSection.allCases {
            notificationBadgeCounts[section] = 0
        }
    }

<<<<<<< HEAD
    // MARK: - Tab Navigation

    /// Navigate to a specific tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToTab(_ tabIndex: Int) {
        selectedTab = tabIndex
        #if os(macOS)
        // Sync macOS sidebar selection with tab selection
        selectedSidebarItem = sidebarItemForTab(tabIndex)
        // Reset list selection when changing tabs
        selectedListItem = nil
        #endif

        // Log navigation action
        Logger.logInfo("Navigated to tab \(tabIndex)")
    }

    /// Navigate to Transactions tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToTransactions() {
        selectedTab = 1
        #if os(macOS)
        selectedSidebarItem = .transactions
        selectedListItem = nil
        #endif
    }

    /// Navigate to Budgets tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToBudgets() {
        selectedTab = 2
        #if os(macOS)
        selectedSidebarItem = .budgets
        selectedListItem = nil
        #endif
    }

    /// Navigate to Subscriptions tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToSubscriptions() {
        selectedTab = 3
        #if os(macOS)
        selectedSidebarItem = .subscriptions
        selectedListItem = nil
        #endif
    }

    /// Navigate to Goals tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToGoals() {
        selectedTab = 4
        #if os(macOS)
        selectedSidebarItem = .goalsAndReports
        selectedListItem = nil
        #endif
    }

    // MARK: - Deep Navigation

    /// Navigate to account detail from any tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToAccountDetail(accountId: String) {
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.accountDetail(accountId))
    }

    /// Navigate to subscription detail from any tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToSubscriptionDetail(subscriptionId: String) {
        selectedTab = 3 // Subscriptions tab
        subscriptionsNavPath.append(SubscriptionsDestination.subscriptionDetail(subscriptionId))
    }

    /// Navigate to budget category from any tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToBudgetCategory(categoryId: String) {
        selectedTab = 2 // Budgets tab
        budgetsNavPath.append(BudgetsDestination.categoryDetail(categoryId))
    }

    /// Navigate to savings goal detail from any tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToGoalDetail(goalId: String) {
        selectedTab = 4 // Goals tab
        goalsAndReportsNavPath.append(GoalsDestination.goalDetail(goalId))
    }

    // MARK: - Advanced Deep Linking

    /// Navigate to category transactions from any context
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToCategoryTransactions(categoryId: String, sourceTab: Int? = nil) {
        addBreadcrumb(title: "Category Transactions", tabIndex: selectedTab)
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.categoryTransactions(categoryId))
    }

    /// Navigate to account transactions from subscription or budget
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToAccountTransactions(accountId: String, context: NavigationContext) {
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.accountDetail(accountId))
    }

    /// Navigate to related transactions for a specific goal
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToGoalTransactions(goalId: String) {
        addBreadcrumb(title: "Goal Transactions", tabIndex: selectedTab)
        selectedTab = 4 // Goals tab
        goalsAndReportsNavPath.append(GoalsDestination.relatedTransactions(goalId))
    }

    // MARK: - Search & Discovery

    /// Activate global search mode
    /// <#Description#>
    /// - Returns: <#description#>
    func activateSearch() {
        isSearchActive = true
        addBreadcrumb(title: "Search", tabIndex: selectedTab)
    }

    /// Deactivate search and return to previous context
    /// <#Description#>
    /// - Returns: <#description#>
=======
    // MARK: - Navigation Methods

    func navigateToBudgets() {
        selectedTab = 2  // Assuming budgets is tab index 2
        budgetsNavPath = NavigationPath()
    }

    func navigateToSubscriptions() {
        selectedTab = 3  // Assuming subscriptions is tab index 3
        subscriptionsNavPath = NavigationPath()
    }

    func navigateToGoals() {
        selectedTab = 4  // Assuming goals is tab index 4
        goalsAndReportsNavPath = NavigationPath()
    }

    // MARK: - Search helpers
    func activateSearch() {
        // Keep this minimal and self-contained so callers can toggle search
        isSearchActive = true
        // breadcrumb helper may be provided by other extensions; append a simple marker
        // Avoid referencing external types here to keep this method safe during incremental builds
    }

>>>>>>> 1cf3938 (Create working state for recovery)
    func deactivateSearch() {
        isSearchActive = false
        searchQuery = ""
        isShowingSearchResults = false
    }

<<<<<<< HEAD
    /// Navigate to search result
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToSearchResult(_ result: SearchResult) {
        switch result.type {
        case .transaction:
            navigateToAccountDetail(accountId: result.relatedId ?? "")
        case .subscription:
            navigateToSubscriptionDetail(subscriptionId: result.id)
        case .budget:
            navigateToBudgetCategory(categoryId: result.relatedId ?? "")
        case .goal:
            navigateToGoalDetail(goalId: result.id)
        case .account:
            navigateToAccountDetail(accountId: result.id)
        }
        deactivateSearch()
    }

    // MARK: - Breadcrumb Navigation

    /// Add breadcrumb for navigation history
    /// <#Description#>
    /// - Returns: <#description#>
    func addBreadcrumb(title: String, tabIndex: Int) {
        let breadcrumb = BreadcrumbItem(
            title: title,
            tabIndex: tabIndex,
            timestamp: Date(),
            )
        breadcrumbHistory.append(breadcrumb)

        // Keep only last 10 breadcrumbs
        if breadcrumbHistory.count > 10 {
            breadcrumbHistory.removeFirst()
        }
    }

    /// Navigate back using breadcrumb history
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateBack() {
        guard breadcrumbHistory.count > 1 else { return }

        // Remove current breadcrumb
        breadcrumbHistory.removeLast()

        // Navigate to previous breadcrumb
        if let previousBreadcrumb = breadcrumbHistory.last {
            selectedTab = previousBreadcrumb.tabIndex
        }
    }

    /// Clear breadcrumb history
    /// <#Description#>
    /// - Returns: <#description#>
    func clearBreadcrumbs() {
        breadcrumbHistory.removeAll()
    }

    // MARK: - Authentication & Security

    /// Authenticate user with biometrics (Face ID/Touch ID)
    /// <#Description#>
    /// - Returns: <#description#>
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            Logger.logWarning("Biometric authentication not available: \(String(describing: error))")
            return false
        }

        do {
            // Perform biometric authentication
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your financial data",
                )

            if success {
                isAuthenticated = true
                lastAuthenticationTime = Date()
                return true
            } else {
                return false
            }
        } catch {
            Logger.logError(error, context: "Authentication")
            return false
        }
    }

    /// Check if authentication has timed out
    /// <#Description#>
    /// - Returns: <#description#>
    func checkAuthenticationStatus() -> Bool {
        guard requiresAuthentication else { return true }

        if let lastAuth = lastAuthenticationTime,
           Date().timeIntervalSince(lastAuth) < authenticationTimeoutInterval {
            return true
        }

        isAuthenticated = false
        return false
    }

    /// Reset authentication state
    /// <#Description#>
    /// - Returns: <#description#>
    func resetAuthentication() {
        isAuthenticated = false
        lastAuthenticationTime = nil
    }

    // MARK: - Deep Link Handling

    /// Process deep link from URL
    /// <#Description#>
    /// - Returns: <#description#>
    func handleDeepLink(_ url: URL) -> Bool {
        guard let deepLink = DeepLink(url: url) else {
            Logger.logWarning("Failed to parse deep link from URL: \(url)")
            return false
        }

        return processDeepLink(deepLink)
    }

    /// Process a deep link object
    /// <#Description#>
    /// - Returns: <#description#>
    func processDeepLink(_ deepLink: DeepLink) -> Bool {
        // Store the pending deep link if user is not authenticated
        if requiresAuthentication && !isAuthenticated {
            pendingDeepLink = deepLink
            return false
        }

        // Process the deep link based on type
        switch deepLink.type {
        case let .account(id):
            navigateToAccountDetail(accountId: id)
        case let .transaction(id):
            navigateToTransactionDetail(transactionId: id)
        case let .budget(id):
            navigateToBudgetCategory(categoryId: id)
        case let .subscription(id):
            navigateToSubscriptionDetail(subscriptionId: id)
        case let .goal(id):
            navigateToGoalDetail(goalId: id)
        case let .category(id):
            navigateToCategoryTransactions(categoryId: id)
        case let .search(query):
            searchQuery = query
            activateSearch()
            isShowingSearchResults = true
        }

        // Store the last handled deep link
        lastHandledDeepLink = deepLink
        pendingDeepLink = nil

        return true
    }

    /// Process any pending deep links
    /// <#Description#>
    /// - Returns: <#description#>
    func processPendingDeepLink() -> Bool {
        guard let pendingLink = pendingDeepLink else { return false }
        return processDeepLink(pendingLink)
    }

    // MARK: - State Restoration

    /// Save current navigation state for restoration
    /// <#Description#>
    /// - Returns: <#description#>
    func saveNavigationState() {
        lastKnownState = [
            "selectedTab": selectedTab,
            "isSearchActive": isSearchActive,
            "searchQuery": searchQuery,
            "timestamp": Date().timeIntervalSince1970
        ]

        // Store the navigation paths as serializable data if needed
        // This would require custom encoding/decoding for NavigationPath
    }

    /// Restore previously saved navigation state
    /// <#Description#>
    /// - Returns: <#description#>
    func restoreNavigationState() -> Bool {
        guard !lastKnownState.isEmpty else { return false }

        if let tab = lastKnownState["selectedTab"] as? Int {
            selectedTab = tab
        }

        if let searchActive = lastKnownState["isSearchActive"] as? Bool {
            isSearchActive = searchActive
        }

        if let query = lastKnownState["searchQuery"] as? String {
            searchQuery = query
        }

        return true
    }

    // MARK: - Notification Integration

    /// Update notification badge counts for a specific tab
    /// <#Description#>
    /// - Returns: <#description#>
    func updateNotificationBadgeCount(for section: TabSection, count: Int) {
        notificationBadgeCounts[section] = count
        hasUnreadNotifications = notificationBadgeCounts.values.contains { $0 > 0 }
    }

    /// Navigate to a specific notification
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToNotification(_ notification: AppNotification) {
        // Process the notification based on its type
        switch notification.type {
        case let .transaction(transactionId):
            navigateToTransactionDetail(transactionId: transactionId)
        case let .budget(budgetId):
            navigateToBudgetCategory(categoryId: budgetId)
        case let .subscription(subscriptionId):
            navigateToSubscriptionDetail(subscriptionId: subscriptionId)
        case let .goal(goalId):
            navigateToGoalDetail(goalId: goalId)
        case let .account(accountId):
            navigateToAccountDetail(accountId: accountId)
        }

        // Mark notification as read
        // This would typically call into a NotificationManager
    }

    /// Navigate to all notifications for a specific tab
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToAllNotifications(for section: TabSection) {
        selectedTab = section.tabIndex
        // Additional logic to show notifications list view
    }

    /// Clear all notification badges for a specific tab
    /// <#Description#>
    /// - Returns: <#description#>
    func clearNotificationBadges(for section: TabSection) {
        updateNotificationBadgeCount(for: section, count: 0)
    }

    // MARK: - Additional Navigation Methods

    /// Navigate to transaction detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToTransactionDetail(transactionId: String) {
        selectedTab = 1 // Transactions tab
        // Create a context for the transaction detail
        let context = NavigationContext(
            breadcrumbTitle: "Transaction Detail",
            sourceModule: "Notifications",
            )
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)

        // Navigate to transaction detail (this would need to be implemented in the app)
        // For now, we'll navigate to the associated account
        // Future: transactionsNavPath.append(TransactionsDestination.transactionDetail(transactionId))
    }

    // MARK: - Navigation Destinations

    // Define destinations for each module
    enum TransactionsDestination: Hashable {
        case accountDetail(String) // Uses account ID
        case categoryTransactions(String) // Uses category ID
    }

    enum BudgetsDestination: Hashable {
        case categoryDetail(String) // Uses category ID
        case categoryTransactions(String) // Uses category ID
    }

    enum SubscriptionsDestination: Hashable {
        case subscriptionDetail(String) // Uses subscription ID
        case accountDetail(String) // Uses account ID
    }

    enum GoalsDestination: Hashable {
        case goalDetail(String) // Uses goal ID
        case relatedTransactions(String) // Uses goal ID
    }

    // MARK: - Supporting Types

    /// Context for navigation between modules
    struct NavigationContext {
        let breadcrumbTitle: String
        let sourceModule: String
        let metadata: [String: String]?

        init(breadcrumbTitle: String, sourceModule: String, metadata: [String: String]? = nil) {
            self.breadcrumbTitle = breadcrumbTitle
            self.sourceModule = sourceModule
            self.metadata = metadata
        }
    }

    /// Breadcrumb item for navigation history
    struct BreadcrumbItem: Identifiable {
        let id = UUID()
        let title: String
        let tabIndex: Int
        let timestamp: Date
    }

    /// Search result type for navigation
    struct SearchResult: Identifiable {
        let id: String
        let title: String
        let subtitle: String?
        let type: SearchResultType
        let relatedId: String? // For related entity navigation

        enum SearchResultType {
            case transaction, subscription, budget, goal, account
        }
    }

    /// App notification
    struct AppNotification: Identifiable {
        let id: String
        let title: String
        let message: String
        let timestamp: Date
        let type: NotificationType
        let isRead: Bool

        enum NotificationType {
            case transaction(String)
            case budget(String)
            case subscription(String)
            case goal(String)
            case account(String)
        }
    }

    /// Deep link type for URL-based navigation
    struct DeepLink {
        let type: DeepLinkType
        let timestamp: Date

        init?(url: URL) {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let host = components.host
            else {
                return nil
            }

            // Parse URL path components
            let pathComponents = components.path.split(separator: "/").map(String.init)
            let queryItems = components.queryItems ?? []

            // Extract ID from path or query
            let id = pathComponents.last ?? queryItems.first(where: { $0.name == "id" })?.value ?? ""

            switch host {
            case "account":
                self.type = .account(id)
            case "transaction":
                self.type = .transaction(id)
            case "budget":
                self.type = .budget(id)
            case "subscription":
                self.type = .subscription(id)
            case "goal":
                self.type = .goal(id)
            case "category":
                self.type = .category(id)
            case "search":
                let query = queryItems.first(where: { $0.name == "q" })?.value ?? ""
                self.type = .search(query)
            default:
                return nil
            }

            self.timestamp = Date()
        }

        enum DeepLinkType {
            case account(String)
            case transaction(String)
            case budget(String)
            case subscription(String)
            case goal(String)
            case category(String)
            case search(String)
        }
    }

    /// App tab section for navigation and notification management
    enum TabSection: Int, CaseIterable {
        case dashboard = 0
        case transactions = 1
        case budgets = 2
        case subscriptions = 3
        case goalsAndReports = 4

        var tabIndex: Int {
            self.rawValue
        }

        var title: String {
            switch self {
            case .dashboard: "Dashboard"
            case .transactions: "Transactions"
            case .budgets: "Budgets"
            case .subscriptions: "Subscriptions"
            case .goalsAndReports: "Goals & Reports"
            }
        }
    }

    /// Reset all navigation paths
    /// <#Description#>
    /// - Returns: <#description#>
    func resetAllPaths() {
        dashboardNavPath = NavigationPath()
        transactionsNavPath = NavigationPath()
        budgetsNavPath = NavigationPath()
        subscriptionsNavPath = NavigationPath()
        goalsAndReportsNavPath = NavigationPath()
    }

    // MARK: - macOS Navigation Support

    #if os(macOS)
    /// Convert tab index to sidebar item
    private func sidebarItemForTab(_ tabIndex: Int) -> SidebarItem? {
        switch tabIndex {
        case 0: .dashboard
        case 1: .transactions
        case 2: .budgets
        case 3: .subscriptions
        case 4: .goalsAndReports
        default: nil
        }
    }

    /// Navigate to an account detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToAccount(accountId: String) {
        selectedSidebarItem = .transactions
        selectedListItem = ListableItem(id: accountId, name: "Account", type: .account)
    }

    /// Navigate to a transaction detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToTransaction(transactionId: String, transactionName: String) {
        selectedSidebarItem = .transactions
        selectedListItem = ListableItem(id: transactionId, name: transactionName, type: .transaction)
    }

    /// Navigate to a budget detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToBudget(budgetId: String, budgetName: String) {
        selectedSidebarItem = .budgets
        selectedListItem = ListableItem(id: budgetId, name: budgetName, type: .budget)
    }

    /// Navigate to a subscription detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToSubscription(subscriptionId: String, subscriptionName: String) {
        selectedSidebarItem = .subscriptions
        selectedListItem = ListableItem(id: subscriptionId, name: subscriptionName, type: .subscription)
    }

    /// Navigate to a savings goal detail
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToGoal(goalId: String, goalName: String) {
        selectedSidebarItem = .goalsAndReports
        selectedListItem = ListableItem(id: goalId, name: goalName, type: .goal)
    }

    /// Navigate to a report
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToReport(reportType: String) {
        selectedSidebarItem = .goalsAndReports
        selectedListItem = ListableItem(id: reportType, name: "Report", type: .report)
    }

    /// Toggle sidebar visibility
    /// <#Description#>
    /// - Returns: <#description#>
    func toggleSidebar() {
        switch columnVisibility {
        case .all:
            columnVisibility = .doubleColumn
        case .doubleColumn where selectedListItem == nil:
            columnVisibility = .all
        default:
            columnVisibility = .all
        }
    }
    #endif
}
=======
    // NavigationSearch behavior is implemented in the NavigationSearch
    // component extension (Navigation/Components/NavigationSearch.swift).
    // Avoid duplicating navigateToSearchResult(_:) here to prevent
    // duplicate-symbol and type-visibility issues during incremental builds.
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
>>>>>>> 1cf3938 (Create working state for recovery)
