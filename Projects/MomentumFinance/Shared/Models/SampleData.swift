import Foundation
import OSLog
import SwiftData
import os.log

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Main utility class to generate sample data for the app
@MainActor
class SampleDataGenerator {
    let modelContext: ModelContext

    private lazy var categoriesGenerator = CategoriesGenerator(modelContext: modelContext)
    private lazy var accountsGenerator = AccountsGenerator(modelContext: modelContext)
    private lazy var budgetsGenerator = BudgetsGenerator(modelContext: modelContext)
    private lazy var savingsGoalsGenerator = SavingsGoalsGenerator(modelContext: modelContext)
    private lazy var transactionsGenerator = TransactionsGenerator(modelContext: modelContext)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generate all sample data in the correct order
    /// <#Description#>
    /// - Returns: <#description#>
    func generateAllSampleData() {
        self.resetAllData()

        // Generate data in dependency order
        self.generateCategories()
        self.generateAccounts()
        self.generateBudgets()
        self.generateSavingsGoals()
        self.generateTransactions()
    }

    /// Generate expense categories
    /// <#Description#>
    /// - Returns: <#description#>
    func generateCategories() {
        self.categoriesGenerator.generate()
    }

    /// Generate financial accounts
    /// <#Description#>
    /// - Returns: <#description#>
    func generateAccounts() {
        self.accountsGenerator.generate()
    }

    /// Generate budgets
    /// <#Description#>
    /// - Returns: <#description#>
    func generateBudgets() {
        self.budgetsGenerator.generate()
    }

    /// Generate savings goals
    /// <#Description#>
    /// - Returns: <#description#>
    func generateSavingsGoals() {
        self.savingsGoalsGenerator.generate()
    }

    /// Generate transactions
    /// <#Description#>
    /// - Returns: <#description#>
    func generateTransactions() {
        self.transactionsGenerator.generate()
    }

    /// Reset all data in the model context
    private func resetAllData() {
        self.deleteAllEntities(of: FinancialTransaction.self)
        self.deleteAllEntities(of: Subscription.self)
        self.deleteAllEntities(of: Budget.self)
        self.deleteAllEntities(of: SavingsGoal.self)
        self.deleteAllEntities(of: FinancialAccount.self)
        self.deleteAllEntities(of: ExpenseCategory.self)
    }

    /// Generic method to delete all entities of a specific type
    private func deleteAllEntities<T: PersistentModel>(of type: T.Type) {
        do {
            let entities = try modelContext.fetch(FetchDescriptor<T>())
            for entity in entities {
                self.modelContext.delete(entity)
            }
            try self.modelContext.save()
        } catch {
            Logger.logError(error, context: "Deleting entities of type \(String(describing: type))")
        }
    }
}
