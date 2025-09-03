import SwiftUI

#if os(macOS)

    // MARK: - macOS Navigation Support

    extension NavigationCoordinator {

        /// Convert tab index to sidebar item
        func sidebarItemForTab(_ tabIndex: Int) -> SidebarItem? {
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
        func navigateToAccount(accountId: String) {
            selectedSidebarItem = .transactions
            selectedListItem = ListableItem(id: accountId, name: "Account", type: .account)
        }

        /// Navigate to a transaction detail
        func navigateToTransaction(transactionId: String, transactionName: String) {
            selectedSidebarItem = .transactions
            selectedListItem = ListableItem(
                id: transactionId, name: transactionName, type: .transaction
            )
        }

        /// Navigate to a budget detail
        func navigateToBudget(budgetId: String, budgetName: String) {
            selectedSidebarItem = .budgets
            selectedListItem = ListableItem(id: budgetId, name: budgetName, type: .budget)
        }

        /// Navigate to a subscription detail
        func navigateToSubscription(subscriptionId: String, subscriptionName: String) {
            selectedSidebarItem = .subscriptions
            selectedListItem = ListableItem(
                id: subscriptionId, name: subscriptionName, type: .subscription
            )
        }

        /// Navigate to a savings goal detail
        func navigateToGoal(goalId: String, goalName: String) {
            selectedSidebarItem = .goalsAndReports
            selectedListItem = ListableItem(id: goalId, name: goalName, type: .goal)
        }

        /// Navigate to a report
        func navigateToReport(reportType: String) {
            selectedSidebarItem = .goalsAndReports
            selectedListItem = ListableItem(id: reportType, name: "Report", type: .report)
        }

        /// Toggle sidebar visibility
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
    }

    // MARK: - macOS Supporting Types

    enum SidebarItem: String, CaseIterable {
        case dashboard
        case transactions
        case budgets
        case subscriptions
        case goalsAndReports
    }

    struct ListableItem: Identifiable {
        let id: String
        let name: String
        let type: ListableItemType

        enum ListableItemType {
            case account
            case transaction
            case budget
            case subscription
            case goal
            case report
        }
    }

#endif
