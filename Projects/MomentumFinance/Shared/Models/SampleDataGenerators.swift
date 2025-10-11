import Foundation
import SwiftData
import os.log

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

// NOTE: This file has been refactored into modular generators.
// See Shared/Models/Generators/ for individual generator classes.
// Use SampleDataGenerator for coordinated data generation.

/// Legacy data generator protocol for backward compatibility
@MainActor
protocol LegacyDataGenerator {
    var modelContext: ModelContext { get }
    func generate()
}

/// Convenience extension for easy sample data generation
public extension ModelContext {
    /// Generates comprehensive sample data for development and testing
    @MainActor
    func generateSampleData() {
        // Create generators and generate data
        let categoriesGen = CategoriesGenerator(modelContext: self)
        categoriesGen.generate()

        let accountsGen = AccountsGenerator(modelContext: self)
        accountsGen.generate()

        let transactionsGen = TransactionsGenerator(modelContext: self)
        transactionsGen.generate()

        let budgetsGen = BudgetsGenerator(modelContext: self)
        budgetsGen.generate()

        let goalsGen = SavingsGoalsGenerator(modelContext: self)
        goalsGen.generate()
    }

    /// Checks if the context already has sample data
    @MainActor
    func hasSampleData() -> Bool {
        // Check if any data exists
        let categoryCount = (try? fetchCount(FetchDescriptor<ExpenseCategory>())) ?? 0
        let accountCount = (try? fetchCount(FetchDescriptor<FinancialAccount>())) ?? 0
        let transactionCount = (try? fetchCount(FetchDescriptor<FinancialTransaction>())) ?? 0

        return categoryCount > 0 || accountCount > 0 || transactionCount > 0
    }

    /// Clears all data from the context
    @MainActor
    func clearAllData() throws {
        // Delete all entities
        try delete(model: FinancialTransaction.self)
        try delete(model: FinancialAccount.self)
        try delete(model: ExpenseCategory.self)
        try delete(model: Budget.self)
        try delete(model: SavingsGoal.self)
        try delete(model: Subscription.self)

        try save()
    }
}
