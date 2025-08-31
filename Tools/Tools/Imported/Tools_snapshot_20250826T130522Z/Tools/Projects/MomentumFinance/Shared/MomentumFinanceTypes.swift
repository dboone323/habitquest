//
//  MomentumFinanceTypes.swift
//  MomentumFinance
//
//  Comprehensive type definitions for MomentumFinance app
//  This file consolidates types that were scattered across subdirectories
//  to resolve build target inclusion issues.
//

import Foundation
import OSLog
import SwiftUI
import UserNotifications

// NOTE: Notification types and schedulers were intentionally removed from this aggregated
// types file. The canonical implementations live under
// `Shared/Utilities/NotificationComponents/` and `Shared/Utilities/NotificationTypes.swift`.
// Keeping duplicate implementations here caused invalid redeclarations. Use the
// canonical types (e.g. `NotificationPermissionManager`, `BudgetNotificationScheduler`,
// `SubscriptionNotificationScheduler`, `GoalNotificationScheduler`, `NotificationUrgency`,
// and `ScheduledNotification`) from the NotificationComponents module.

// MARK: - Navigation Types

/// Navigation tab sections
public enum TabSection: CaseIterable {
    case dashboard, transactions, budgets, subscriptions, reports

    public var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .transactions: "Transactions"
        case .budgets: "Budgets"
        case .subscriptions: "Subscriptions"
        case .reports: "Reports"
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

// Search types are provided by the GlobalSearch feature under
// `Shared/Features/GlobalSearch/Components`. Do not duplicate them here.

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
    public func createEntity<T>(from data: [String: Any], type: T.Type) -> T? { nil }
}

// MARK: - Intelligence Types

// Canonical intelligence implementations live under:
// - Shared/Intelligence/Components/FinancialMLModels.swift
// - Shared/Intelligence/Components/TransactionPatternAnalyzer.swift
// Remove duplicate stubs to avoid invalid redeclaration errors; use the
// concrete implementations above when performing analysis or ML operations.

// MARK: - Animation Types

public enum AnimatedCardComponent {
    public struct AnimatedCard: View {
        let content: AnyView
        public init(content: AnyView) { self.content = content }
        public var body: some View {
            content.transition(.scale.combined(with: .opacity)).animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public enum AnimatedButtonComponent {
    public struct AnimatedButton: View {
        let title: String
        let action: () -> Void
        public init(title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
        public var body: some View {
            Button(title, action: action).scaleEffect(1.0).animation(.easeInOut(duration: 0.2), value: UUID())
        }
    }
}

public enum AnimatedTransactionComponent {
    public struct AnimatedTransactionItem: View {
        let title: String
        public init(title: String) { self.title = title }
        public var body: some View {
            Text(title).transition(.slide).animation(.easeInOut(duration: 0.3), value: UUID())
        }
    }
}

public enum AnimatedProgressComponents {
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

public enum FloatingActionButtonComponent {
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
