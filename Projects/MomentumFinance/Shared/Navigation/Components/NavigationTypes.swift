import Foundation
import SwiftUI

// MARK: - Navigation Supporting Types

/// Navigation destination enums for each module

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

// The canonical BreadcrumbItem, DeepLink and TabSection types are defined in
// Shared/Models/FinancialAccount.swift to keep navigation metadata colocated with
// account and model-level helpers. This file keeps only navigation destination
// enums and the SearchResult shape used by GlobalSearch. Avoid redefining the
// other common types here to prevent duplicate-declaration compiler errors.

/// Search result type for navigation (kept here for consumers that import the
/// navigation components module).
public struct SearchResult: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let type: SearchResultType
    public let relatedId: String?

    public enum SearchResultType {
        case transaction, subscription, budget, goal, account
    }

    public init(id: String, title: String, subtitle: String? = nil, type: SearchResultType, relatedId: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.relatedId = relatedId
    }
}
