import Foundation

// MARK: - State Restoration

extension NavigationCoordinator {

    /// Save current navigation state for restoration
    func saveNavigationState() {
        lastKnownState = [
            "selectedTab": selectedTab,
            "isSearchActive": isSearchActive,
            "searchQuery": searchQuery,
            "timestamp": Date().timeIntervalSince1970,
        ]

        // Store the navigation paths as serializable data if needed
        // This would require custom encoding/decoding for NavigationPath
    }

    /// Restore previously saved navigation state
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
}
