import Foundation

// MARK: - Notification Integration

extension NavigationCoordinator {

    /// Update notification badge counts for a specific tab
    func updateNotificationBadgeCount(for section: TabSection, count: Int) {
        notificationBadgeCounts[section] = count
        hasUnreadNotifications = notificationBadgeCounts.values.contains { $0 > 0 }
    }

    /// Navigate to a specific notification
    func navigateToNotification(_ notification: AppNotification) {
        // Process the notification based on its type
        switch notification.type {
        case .transaction(let transactionId):
            navigateToTransactionDetail(transactionId: transactionId)
        case .budget(let budgetId):
            navigateToBudgetCategory(categoryId: budgetId)
        case .subscription(let subscriptionId):
            navigateToSubscriptionDetail(subscriptionId: subscriptionId)
        case .goal(let goalId):
            navigateToGoalDetail(goalId: goalId)
        case .account(let accountId):
            navigateToAccountDetail(accountId: accountId)
        }

        // Mark notification as read
        // This would typically call into a NotificationManager
    }

    /// Navigate to all notifications for a specific tab
    func navigateToAllNotifications(for section: TabSection) {
        selectedTab = section.tabIndex
        // Additional logic to show notifications list view
    }

    /// Clear all notification badges for a specific tab
    func clearNotificationBadges(for section: TabSection) {
        updateNotificationBadgeCount(for: section, count: 0)
    }
}
