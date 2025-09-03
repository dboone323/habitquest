import Foundation
import SwiftUI

// MARK: - Navigation Actions

extension NavigationCoordinator {

    // MARK: - Tab Navigation

    /// Navigate to a specific tab
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
    func navigateToTransactions() {
        selectedTab = 1
        #if os(macOS)
            selectedSidebarItem = .transactions
            selectedListItem = nil
        #endif
    }

    /// Navigate to Budgets tab
    func navigateToBudgets() {
        selectedTab = 2
        #if os(macOS)
            selectedSidebarItem = .budgets
            selectedListItem = nil
        #endif
    }

    /// Navigate to Subscriptions tab
    func navigateToSubscriptions() {
        selectedTab = 3
        #if os(macOS)
            selectedSidebarItem = .subscriptions
            selectedListItem = nil
        #endif
    }

    /// Navigate to Goals tab
    func navigateToGoals() {
        selectedTab = 4
        #if os(macOS)
            selectedSidebarItem = .goalsAndReports
            selectedListItem = nil
        #endif
    }

    // MARK: - Deep Navigation

    /// Navigate to account detail from any tab
    func navigateToAccountDetail(accountId: String) {
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.accountDetail(accountId))
    }

    /// Navigate to subscription detail from any tab
    func navigateToSubscriptionDetail(subscriptionId: String) {
        selectedTab = 3 // Subscriptions tab
        subscriptionsNavPath.append(SubscriptionsDestination.subscriptionDetail(subscriptionId))
    }

    /// Navigate to budget category from any tab
    func navigateToBudgetCategory(categoryId: String) {
        selectedTab = 2 // Budgets tab
        budgetsNavPath.append(BudgetsDestination.categoryDetail(categoryId))
    }

    /// Navigate to savings goal detail from any tab
    func navigateToGoalDetail(goalId: String) {
        selectedTab = 4 // Goals tab
        goalsAndReportsNavPath.append(GoalsDestination.goalDetail(goalId))
    }

    // MARK: - Advanced Deep Linking

    /// Navigate to category transactions from any context
    func navigateToCategoryTransactions(categoryId: String, sourceTab: Int? = nil) {
        addBreadcrumb(title: "Category Transactions", tabIndex: selectedTab)
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.categoryTransactions(categoryId))
    }

    /// Navigate to account transactions from subscription or budget
    func navigateToAccountTransactions(accountId: String, context: NavigationContext) {
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)
        selectedTab = 1 // Transactions tab
        transactionsNavPath.append(TransactionsDestination.accountDetail(accountId))
    }

    /// Navigate to related transactions for a specific goal
    func navigateToGoalTransactions(goalId: String) {
        addBreadcrumb(title: "Goal Transactions", tabIndex: selectedTab)
        selectedTab = 4 // Goals tab
        goalsAndReportsNavPath.append(GoalsDestination.relatedTransactions(goalId))
    }

    /// Navigate to transaction detail
    func navigateToTransactionDetail(transactionId: String) {
        selectedTab = 1 // Transactions tab
        // Create a context for the transaction detail
        let context = NavigationContext(
            breadcrumbTitle: "Transaction Detail",
            sourceModule: "Notifications"
        )
        addBreadcrumb(title: context.breadcrumbTitle, tabIndex: selectedTab)

        // Navigate to transaction detail (this would need to be implemented in the app)
        // For now, we'll navigate to the associated account
        // Future: transactionsNavPath.append(TransactionsDestination.transactionDetail(transactionId))
    }

    /// Reset all navigation paths
    func resetAllPaths() {
        dashboardNavPath = NavigationPath()
        transactionsNavPath = NavigationPath()
        budgetsNavPath = NavigationPath()
        subscriptionsNavPath = NavigationPath()
        goalsAndReportsNavPath = NavigationPath()
    }
}
