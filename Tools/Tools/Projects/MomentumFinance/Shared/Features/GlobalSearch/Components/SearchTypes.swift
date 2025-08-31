import SwiftUI

// MARK: - Search Types and Enums

extension Features.GlobalSearchView {

    // MARK: - Search Filter Enum

    enum SearchFilter: String, CaseIterable {
        case all = "All"
        case accounts = "Accounts"
        case transactions = "Transactions"
        case subscriptions = "Subscriptions"
        case budgets = "Budgets"
        case goals = "Goals"

        var icon: String {
            switch self {
            case .all: "magnifyingglass"
            case .accounts: "building.columns"
            case .transactions: "creditcard"
            case .subscriptions: "arrow.clockwise.circle"
            case .budgets: "chart.pie"
            case .goals: "target"
            }
        }
    }
}

// MARK: - Search Result Type Extensions

extension SearchResult.SearchResultType {
    var icon: String {
        switch self {
        case .account: "building.columns"
        case .transaction: "creditcard"
        case .subscription: "arrow.clockwise.circle"
        case .budget: "chart.pie"
        case .goal: "target"
        }
    }
}

// MARK: - Search Configuration

enum SearchConfiguration {
    static let transactionResultLimit = 20
    static let searchDebounceDelay: TimeInterval = 0.1
}
