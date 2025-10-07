// Momentum Finance - Navigation System Integration for macOS UI
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

#if os(macOS)

// MARK: - Navigation System Integration

extension NavigationCoordinator {
    /// Connect a ListableItem selection to the detail view navigation
    /// <#Description#>
    /// - Returns: <#description#>
    func navigateToDetail(item: ListableItem?) {
        selectedListItem = item

        // Also update the appropriate navigation path for cross-platform compatibility
        // This ensures that when switching back to iOS, we maintain proper navigation state
        guard let item else { return }

        switch item.type {
        case .account:
            if let id = item.id {
                selectedTab = 1 // Transactions tab
                transactionsNavPath.append(TransactionsDestination.accountDetail(id))
            }
        case .transaction:
            if let id = item.id {
                selectedTab = 1 // Transactions tab
                // We don't have a direct transaction detail in the iOS navigation paths
                // But we could add it or navigate to its containing account
            }
        case .budget:
            if let id = item.id {
                selectedTab = 2 // Budgets tab
                budgetsNavPath.append(BudgetsDestination.categoryDetail(id))
            }
        case .subscription:
            if let id = item.id {
                selectedTab = 3 // Subscriptions tab
                subscriptionsNavPath.append(SubscriptionsDestination.subscriptionDetail(id))
            }
        case .goal:
            if let id = item.id {
                selectedTab = 4 // Goals tab
                goalsAndReportsNavPath.append(GoalsDestination.goalDetail(id))
            }
        case .report:
            if let id = item.id {
                selectedTab = 4 // Goals tab
                // Add specific report destination if needed
            }
        }
    }

    /// Clear detail selection when changing sidebar item
    /// <#Description#>
    /// - Returns: <#description#>
    func clearDetailSelection() {
        selectedListItem = nil
    }
}
#endif
