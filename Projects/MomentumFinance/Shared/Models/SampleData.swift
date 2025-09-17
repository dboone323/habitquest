import Foundation
import os.log
import OSLog
import SwiftData

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Main utility class to generate sample data for the app
@MainActor
class SampleDataGenerator {
    let modelContext: ModelContext

    private lazy var categoriesGenerator = CategoriesDataGenerator(modelContext: modelContext)
    private lazy var accountsGenerator = AccountsDataGenerator(modelContext: modelContext)
    private lazy var budgetsGenerator = BudgetsDataGenerator(modelContext: modelContext)
    private lazy var savingsGoalsGenerator = SavingsGoalsDataGenerator(modelContext: modelContext)
    private lazy var transactionsGenerator = TransactionsDataGenerator(modelContext: modelContext)
    private lazy var subscriptionsGenerator = SubscriptionsDataGenerator(modelContext: modelContext)

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
        self.generateSubscriptions()
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

    /// Generate subscriptions
    /// <#Description#>
    /// - Returns: <#description#>
    func generateSubscriptions() {
        self.subscriptionsGenerator.generate()
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
