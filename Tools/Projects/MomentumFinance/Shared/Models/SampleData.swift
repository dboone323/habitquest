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
        resetAllData()

        // Generate data in dependency order
        generateCategories()
        generateAccounts()
        generateBudgets()
        generateSavingsGoals()
        generateTransactions()
        generateSubscriptions()
    }

    /// Generate expense categories
    /// <#Description#>
    /// - Returns: <#description#>
    func generateCategories() {
        categoriesGenerator.generate()
    }

    /// Generate financial accounts
    /// <#Description#>
    /// - Returns: <#description#>
    func generateAccounts() {
        accountsGenerator.generate()
    }

    /// Generate budgets
    /// <#Description#>
    /// - Returns: <#description#>
    func generateBudgets() {
        budgetsGenerator.generate()
    }

    /// Generate savings goals
    /// <#Description#>
    /// - Returns: <#description#>
    func generateSavingsGoals() {
        savingsGoalsGenerator.generate()
    }

    /// Generate transactions
    /// <#Description#>
    /// - Returns: <#description#>
    func generateTransactions() {
        transactionsGenerator.generate()
    }

    /// Generate subscriptions
    /// <#Description#>
    /// - Returns: <#description#>
    func generateSubscriptions() {
        subscriptionsGenerator.generate()
    }

    /// Reset all data in the model context
    private func resetAllData() {
        deleteAllEntities(of: FinancialTransaction.self)
        deleteAllEntities(of: Subscription.self)
        deleteAllEntities(of: Budget.self)
        deleteAllEntities(of: SavingsGoal.self)
        deleteAllEntities(of: FinancialAccount.self)
        deleteAllEntities(of: ExpenseCategory.self)
    }

    /// Generic method to delete all entities of a specific type
    private func deleteAllEntities<T: PersistentModel>(of type: T.Type) {
        do {
            let entities = try modelContext.fetch(FetchDescriptor<T>())
            for entity in entities {
                modelContext.delete(entity)
            }
            try modelContext.save()
        } catch {
            Logger.logError(error, context: "Deleting entities of type \(String(describing: type))")
        }
    }
}
