//
//  MissingTypes.swift
//  MomentumFinance
//
//  Temporary file to resolve missing type definitions
//  These should eventually be moved to proper module files
//

import Foundation
import OSLog
import SwiftUI
import UserNotifications

// MARK: - Navigation Types

/// Navigation tab sections
enum TabSection: CaseIterable {
    case dashboard
    case transactions
    case budgets
    case subscriptions
    case reports

    var title: String {
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
struct DeepLink: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let targetTab: TabSection
    let parameters: [String: String]

    init(url: URL, targetTab: TabSection, parameters: [String: String] = [:]) {
        self.url = url
        self.targetTab = targetTab
        self.parameters = parameters
    }
}

/// Breadcrumb item for navigation history
struct BreadcrumbItem: Identifiable {
    let id = UUID()
    let title: String
    let tabIndex: Int
    let timestamp: Date
}

// This file previously contained duplicate type declarations that conflicted
// with the canonical implementations added under
// `Shared/Utilities/NotificationComponents` and `Shared/Features/GlobalSearch`.
// Those canonical types should be used instead. Keep only lightweight
// compatibility helpers here.

// MARK: - Lightweight Navigation Helpers

/// Simple wrapper to represent a deep link (kept intentionally minimal).
struct DeepLinkSimple: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let target: String
}

// MARK: - Data Import Types

struct ColumnMapping {
    let sourceColumn: String
    let targetField: String
    let dataType: String

    init(sourceColumn: String, targetField: String, dataType: String) {
        self.sourceColumn = sourceColumn
        self.targetField = targetField
        self.dataType = dataType
    }
}

class EntityManager {
    init() {}

    func createEntity<T>(from data: [String: Any], type: T.Type) -> T? {
        // Implementation would go here
        nil
    }
}

// MARK: - Animation Types

enum AnimatedCardComponent {
    struct AnimatedCard: View {
        let content: AnyView

        var body: some View {
            content
                .animation(.easeInOut, value: UUID())
        }
    }
}

enum AnimatedButtonComponent {
    struct AnimatedButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(title, action: action)
                .animation(.easeInOut, value: UUID())
        }
    }
}

enum AnimatedTransactionComponent {
    struct AnimatedTransactionItem: View {
        let title: String

        var body: some View {
            Text(title)
                .animation(.easeInOut, value: UUID())
        }
    }
}

enum AnimatedProgressComponents {
    struct AnimatedBudgetProgress: View {
        let progress: Double

        var body: some View {
            ProgressView(value: progress)
                .animation(.easeInOut, value: progress)
        }
    }

    struct AnimatedCounter: View {
        let count: Int

        var body: some View {
            Text("\(count)")
                .animation(.easeInOut, value: count)
        }
    }
}

enum FloatingActionButtonComponent {
    struct FloatingActionButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 56, height: 56)
            .background(Color.accentColor)
            .clipShape(Circle())
            .shadow(radius: 4)
        }
    }
}

// MARK: - Intelligence Types

class FinancialMLModels {
    init() {}

    func analyzeBudgetTrends() -> [String: Any] {
        [:]
    }
}

class TransactionPatternAnalyzer {
    init() {}

    func analyzePatterns() -> [String: Any] {
        [:]
    }
}
