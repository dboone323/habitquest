// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData
<<<<<<< HEAD
=======
import SwiftUI
import OSLog
import UserNotifications

// NOTE: Notification-related types and schedulers were previously defined
// here but are now canonicalized under:
// - Shared/Utilities/NotificationComponents/*
// - Shared/Utilities/NotificationTypes.swift
// Please use those implementations. This file keeps account model logic only.

// MARK: - Navigation Types

/// Navigation tab sections
public enum TabSection: CaseIterable {
    case dashboard, transactions, budgets, subscriptions, reports
    
    public var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .transactions: return "Transactions"
        case .budgets: return "Budgets"
        case .subscriptions: return "Subscriptions"
        case .reports: return "Reports"
        }
    }
}

/// Deep link structure for navigation
public struct DeepLink: Identifiable, Hashable {
    public let id = UUID()
    public let url: URL
    public let targetTab: TabSection
    public let parameters: [String: String]
    
    public init(url: URL, targetTab: TabSection, parameters: [String: String] = [:]) {
        self.url = url
        self.targetTab = targetTab
        self.parameters = parameters
    }
}

/// Breadcrumb item for navigation history
public struct BreadcrumbItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let tabIndex: Int
    public let timestamp: Date
    
    public init(title: String, tabIndex: Int, timestamp: Date = Date()) {
        self.title = title
        self.tabIndex = tabIndex
        self.timestamp = timestamp
    }
}

// NOTE: Search-related types are provided by the GlobalSearch feature at:
// - Shared/Features/GlobalSearch/Components/
// Use those types (SearchResult, SearchEngineService, SearchFilter) instead of duplicating them here.

// MARK: - Data Import Types

public struct ColumnMapping {
    public let sourceColumn: String
    public let targetField: String
    public let dataType: String
    
    public init(sourceColumn: String, targetField: String, dataType: String) {
        self.sourceColumn = sourceColumn
        self.targetField = targetField
        self.dataType = dataType
    }
}

public class EntityManager {
    public init() {}
    public func createEntity<T>(from data: [String: Any], type: T.Type) -> T? { return nil }
}

// MARK: - Intelligence Types

// Intelligence implementations are provided by the canonical components under:
// Shared/Intelligence/Components/FinancialMLModels.swift and
// Shared/Intelligence/Components/TransactionPatternAnalyzer.swift.
// Legacy stubs removed to prevent duplicate symbols during compilation.

// MARK: - Animation Types

public struct AnimatedCardComponent {
    public struct AnimatedCard: View {
        let content: AnyView
        public init(content: AnyView) { self.content = content }
        public var body: some View {
            content.transition(.scale.combined(with: .opacity)).animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public struct AnimatedButtonComponent {
    public struct AnimatedButton: View {
        let title: String
        let action: () -> Void
        public init(title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
        public var body: some View {
            Button(title, action: action).scaleEffect(1.0).animation(.easeInOut(duration: 0.2), value: UUID())
        }
    }
}

public struct AnimatedTransactionComponent {
    public struct AnimatedTransactionItem: View {
        let title: String
        public init(title: String) { self.title = title }
        public var body: some View {
            Text(title).transition(.slide).animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public struct AnimatedProgressComponents {
    public struct AnimatedBudgetProgress: View {
        let progress: Double
        public init(progress: Double) { self.progress = progress }
        public var body: some View {
            ProgressView(value: progress).animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
    
    public struct AnimatedCounter: View {
        let count: Int
        public init(count: Int) { self.count = count }
        public var body: some View {
            Text("\(count)").contentTransition(.numericText()).animation(.easeInOut(duration: 0.3), value: count)
        }
    }
}

public struct FloatingActionButtonComponent {
    public struct FloatingActionButton: View {
        let action: () -> Void
        public init(action: @escaping () -> Void) { self.action = action }
        public var body: some View {
            Button(action: action) {
                Image(systemName: "plus").font(.title2).foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.accentColor)
            .clipShape(Circle())
            .shadow(radius: 4)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
        }
    }
}

// MARK: - Insights View Components

struct InsightsFilterBar: View {
    @Binding var filterPriority: InsightPriority?
    @Binding var filterType: InsightType?
    
    init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        self._filterPriority = filterPriority
        self._filterType = filterType
    }
    
    var body: some View {
        HStack {
            Text("Filters")
            Spacer()
            // Filter controls would go here
        }
        .padding()
    }
}

struct InsightDetailView: View {
    let insight: FinancialInsight
    init(insight: FinancialInsight) { self.insight = insight }
    var body: some View {
        VStack(alignment: .leading) {
            Text(insight.title).font(.headline)
            Text(insight.description).font(.body)
        }
    }
}

struct InsightsLoadingView: View {
    var body: some View {
        ProgressView("Loading insights...")
    }
}

struct InsightsEmptyStateView: View {
    var body: some View {
        VStack {
            Text("No insights available")
            Text("Check back later for financial insights")
        }
    }
}

struct InsightRowView: View {
    let insight: FinancialInsight
    let action: () -> Void
    
    init(insight: FinancialInsight, action: @escaping () -> Void) {
        self.insight = insight
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(insight.title).font(.headline)
                    Text(insight.description).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Account Types
>>>>>>> 1cf3938 (Create working state for recovery)

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case credit = "Credit Card"
    case investment = "Investment"
    case cash = "Cash"
}

@Model
final class FinancialAccount {
    var name: String
    var balance: Double
    var iconName: String
    var createdDate: Date
    var accountType: AccountType
    var currencyCode: String
    var creditLimit: Double?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var transactions: [FinancialTransaction] = []
    @Relationship(deleteRule: .cascade)
    var subscriptions: [Subscription] = []

    init(name: String, balance: Double, iconName: String, accountType: AccountType = .checking, currencyCode: String = "USD", creditLimit: Double? = nil) {
        self.name = name
        self.balance = balance
        self.iconName = iconName
        self.accountType = accountType
        self.currencyCode = currencyCode
        self.creditLimit = creditLimit
        self.createdDate = Date()
    }

    /// Updates the account balance based on a transaction
    @MainActor
    /// <#Description#>
    /// - Returns: <#description#>
    func updateBalance(for transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        }
    }
}
