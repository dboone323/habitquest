import Foundation
import SwiftUI

// MARK: - Search Types

public enum SearchFilter: String, CaseIterable, Hashable {
    case all = "All"
    case accounts = "Accounts"
    case transactions = "Transactions"
    case subscriptions = "Subscriptions"
    case budgets = "Budgets"
}

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

public enum SearchConfiguration {
    public static let searchDebounceDelay: TimeInterval = 0.3
    public static let maxResults: Int = 50
    public static let minQueryLength: Int = 2
}
