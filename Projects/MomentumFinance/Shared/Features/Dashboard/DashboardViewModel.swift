import Foundation
import Observation
import os
import OSLog
import SwiftData
import SwiftUI

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

@MainActor
@Observable
final class DashboardViewModel {
    private var modelContext: ModelContext?
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance", category: "Dashboard")

    /// <#Description#>
    /// - Returns: <#description#>
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// Get upcoming subscriptions sorted by due date
    /// <#Description#>
    /// - Returns: <#description#>
    func upcomingSubscriptions(_ subscriptions: [Subscription]) -> [Subscription] {
        subscriptions
            .filter(\.isActive)
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }

    /// Get budgets for the current month
    /// <#Description#>
    /// - Returns: <#description#>
    func currentMonthBudgets(_ budgets: [Budget]) -> [Budget] {
        let calendar = Calendar.current
        let now = Date()

        return budgets.filter { budget in
            calendar.isDate(budget.month, equalTo: now, toGranularity: .month)
        }
    }

    /// Calculate total balance across all accounts
    /// <#Description#>
    /// - Returns: <#description#>
    func totalBalance(_ accounts: [FinancialAccount]) -> Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    /// Get recent transactions
    /// <#Description#>
    /// - Returns: <#description#>
    func recentTransactions(_ transactions: [FinancialTransaction], limit: Int = 5) -> [FinancialTransaction] {
        Array(transactions
<<<<<<< HEAD
                .sorted { $0.date > $1.date }
                .prefix(limit))
=======
            .sorted { $0.date > $1.date }
            .prefix(limit))
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    /// Check for overdue subscriptions and process them
    /// <#Description#>
    /// - Returns: <#description#>
    func processOverdueSubscriptions(_ subscriptions: [Subscription]) async {
        guard let modelContext else { return }

        let overdueSubscriptions = subscriptions.filter { subscription in
            subscription.isActive && subscription.nextDueDate <= Date()
        }

        for subscription in overdueSubscriptions {
            await processSubscription(subscription, modelContext: modelContext)
        }
    }

    /// Process a single subscription payment
    private func processSubscription(_ subscription: Subscription, modelContext: ModelContext) async {
        subscription.processPayment(modelContext: modelContext)

        do {
            try modelContext.save()
        } catch {
            os_log("Failed to save subscription payment: %@",
                   log: self.logger,
                   type: .error,
                   error.localizedDescription)
        }
    }

    /// Get spending by category for current month
    /// <#Description#>
    /// - Returns: <#description#>
    func spendingByCategory(_ transactions: [FinancialTransaction]) -> [String: Double] {
        let calendar = Calendar.current
        let now = Date()

        let currentMonthTransactions = transactions.filter { transaction in
            transaction.transactionType == .expense &&
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }

        var spendingByCategory: [String: Double] = [:]
        for transaction in currentMonthTransactions {
            let categoryName = transaction.category?.name ?? "Uncategorized"
            spendingByCategory[categoryName, default: 0] += transaction.amount
        }

        return spendingByCategory
    }

    /// Get net income for current month
    /// <#Description#>
    /// - Returns: <#description#>
    func netIncomeThisMonth(_ transactions: [FinancialTransaction]) -> Double {
        let calendar = Calendar.current
        let now = Date()

        let currentMonthTransactions = transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
        }

        let income = currentMonthTransactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }

        let expenses = currentMonthTransactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }

        return income - expenses
    }
}
