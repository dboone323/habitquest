import Foundation
import SwiftData

// MARK: - Data Fetching Methods

extension DataExporter {

    /// Fetch transactions within date range
    func fetchTransactions(from startDate: Date, to endDate: Date) throws
        -> [FinancialTransaction]
    {
        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)],
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all financial accounts
    func fetchAccounts() throws -> [FinancialAccount] {
        let descriptor = FetchDescriptor<FinancialAccount>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all budgets
    func fetchBudgets() throws -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all subscriptions
    func fetchSubscriptions() throws -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all savings goals
    func fetchGoals() throws -> [SavingsGoal] {
        let descriptor = FetchDescriptor<SavingsGoal>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try modelContext.fetch(descriptor)
    }
}
