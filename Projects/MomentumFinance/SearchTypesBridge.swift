import Foundation
import SwiftUI

//
//  SearchTypesBridge.swift
//  MomentumFinance
//
//  Temporary bridge file to resolve SearchResult import issues
//  This provides access to the proper search types during architectural transition
//

// MARK: - Search Filter Types

/// Search filter options for global search
public enum SearchFilter: String, CaseIterable, Hashable {
    case all = "All"
    case accounts = "Accounts"
    case transactions = "Transactions"
    case subscriptions = "Subscriptions"
    case budgets = "Budgets"
}

// MARK: - Search Result Types

/// Represents a search result item
public struct SearchResult: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let type: SearchFilter
    public let iconName: String
    public let data: Any?

    public init(id: String, title: String, subtitle: String? = nil, type: SearchFilter, iconName: String, data: Any? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.iconName = iconName
        self.data = data
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }

    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }
}

// MARK: - Search Configuration

/// Configuration settings for search functionality
public enum SearchConfiguration {
    public static let searchDebounceDelay: TimeInterval = 0.3
    public static let maxResults: Int = 50
    public static let minQueryLength: Int = 2
}

// MARK: - TODO: Architectural Notes

// This bridge file should be replaced with proper imports once the following files are added to Xcode:
// - Shared/Features/GlobalSearch/SearchTypes.swift
// - Shared/Features/GlobalSearch/SearchEngineService.swift
// - Shared/Features/GlobalSearch/SearchResultsComponent.swift
