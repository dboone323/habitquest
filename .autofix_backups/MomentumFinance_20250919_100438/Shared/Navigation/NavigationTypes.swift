//
//  NavigationTypes.swift
//  MomentumFinance - Consolidated navigation types
//
//  Moved from Navigation/Components for build compatibility
//

import Foundation
import SwiftUI

// MARK: - Navigation Types

/// Navigation destination enums for each module
public enum TransactionsDestination: Hashable {
    case accountDetail(String) // Uses account ID
    case categoryTransactions(String) // Uses category ID
}

public enum BudgetsDestination: Hashable {
    case categoryDetail(String) // Uses category ID
    case categoryTransactions(String) // Uses category ID
}

public enum SubscriptionsDestination: Hashable {
    case subscriptionDetail(String) // Uses subscription ID
    case accountDetail(String) // Uses account ID
}

public enum GoalsDestination: Hashable {
    case goalDetail(String) // Uses goal ID
    case relatedTransactions(String) // Uses goal ID
}

/// Context for navigation between modules
public struct NavigationContext {
    public let breadcrumbTitle: String
    public let sourceModule: String
    public let metadata: [String: String]?

    public init(breadcrumbTitle: String, sourceModule: String, metadata: [String: String]? = nil) {
        self.breadcrumbTitle = breadcrumbTitle
        self.sourceModule = sourceModule
        self.metadata = metadata
    }
}

/// Search result type for navigation
// SearchResult is defined in Navigation/Components/NavigationTypes.swift to keep a single canonical definition
// Please see Components/NavigationTypes.swift for the canonical SearchResult and SearchResultType definitions used by GlobalSearch.
