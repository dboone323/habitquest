import Foundation

// MARK: - Search & Discovery

extension NavigationCoordinator {

    /// Activate global search mode
    func activateSearch() {
        isSearchActive = true
        addBreadcrumb(title: "Search", tabIndex: selectedTab)
    }

    /// Deactivate search and return to previous context
    func deactivateSearch() {
        isSearchActive = false
        searchQuery = ""
        isShowingSearchResults = false
    }

    /// Navigate to search result
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
}
