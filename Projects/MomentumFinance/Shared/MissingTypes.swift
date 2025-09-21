// MissingTypes.swift (Minimal Stub)
// Purpose: Temporary navigation types only. All previous large content moved.
// Safe to remove once BreadcrumbItem & DeepLink are relocated.

import Foundation

public struct BreadcrumbItem: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let destination: AnyHashable?
    public let timestamp: Date
    public init(title: String, destination: AnyHashable? = nil) {
        self.title = title
        self.destination = destination
        self.timestamp = Date()
    }
}

public enum DeepLink {
    case dashboard, transactions, budgets, subscriptions, goals, settings
    case search(query: String)
    case transaction(id: UUID)
    case account(id: UUID)
    case subscription(id: UUID)
    case budget(id: UUID)
    case goal(id: UUID)
    public var path: String {
        switch self {
        case .dashboard: "/dashboard"
        case .transactions: "/transactions"
        case .budgets: "/budgets"
        case .subscriptions: "/subscriptions"
        case .goals: "/goals"
        case .settings: "/settings"
        case .search: "/search"
        case let .transaction(id): "/transaction/\(id)"
        case let .account(id): "/account/\(id)"
        case let .subscription(id): "/subscription/\(id)"
        case let .budget(id): "/budget/\(id)"
        case let .goal(id): "/goal/\(id)"
        }
    }
}
