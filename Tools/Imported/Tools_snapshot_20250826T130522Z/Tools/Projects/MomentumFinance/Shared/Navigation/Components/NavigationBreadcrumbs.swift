import Foundation

// MARK: - Breadcrumb Navigation

extension NavigationCoordinator {

    /// Add breadcrumb for navigation history
    func addBreadcrumb(title: String, tabIndex: Int) {
        let breadcrumb = BreadcrumbItem(
            title: title,
            tabIndex: tabIndex,
            timestamp: Date()
        )
        breadcrumbHistory.append(breadcrumb)

        // Keep only last 10 breadcrumbs
        if breadcrumbHistory.count > 10 {
            breadcrumbHistory.removeFirst()
        }
    }

    /// Navigate back using breadcrumb history
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
    func clearBreadcrumbs() {
        breadcrumbHistory.removeAll()
    }
}
