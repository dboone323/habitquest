import Foundation
import OSLog

// MARK: - Deep Link Handling

extension NavigationCoordinator {

    /// Process deep link from URL
    func handleDeepLink(_ url: URL) -> Bool {
        guard let deepLink = DeepLink(url: url) else {
            Logger.logWarning("Failed to parse deep link from URL: \(url)")
            return false
        }

        return processDeepLink(deepLink)
    }

    /// Process a deep link object
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
    func processPendingDeepLink() -> Bool {
        guard let pendingLink = pendingDeepLink else { return false }
        return processDeepLink(pendingLink)
    }
}
