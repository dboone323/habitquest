//
//  TabSection.swift
//  MomentumFinance
//
//  Tab section enum moved to separate file to avoid SwiftUI TabSection conflict
//

import Foundation

/// Navigation tab sections - separated from SwiftUI imports to avoid generic type conflicts
public enum AppTabSection: String, CaseIterable, Hashable {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case goals

    public var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .transactions: "Transactions"
        case .budgets: "Budgets"
        case .subscriptions: "Subscriptions"
        case .goals: "Goals"
        }
    }
}
