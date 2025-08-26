import Foundation
import os.log
import SwiftData

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Protocol for data generators
@MainActor
protocol DataGenerator {
    var modelContext: ModelContext { get }
    func generate()
}

/// Categories data generator
@MainActor
class CategoriesDataGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        let categories = [
            (name: "Housing", icon: "house.fill"),
            (name: "Transportation", icon: "car.fill"),
            (name: "Food & Dining", icon: "fork.knife"),
            (name: "Utilities", icon: "bolt.fill"),
            (name: "Entertainment", icon: "tv.fill"),
            (name: "Shopping", icon: "bag.fill"),
            (name: "Health & Fitness", icon: "heart.fill"),
            (name: "Travel", icon: "airplane"),
            (name: "Education", icon: "book.fill"),
<<<<<<< HEAD
            (name: "Income", icon: "dollarsign.circle.fill")
=======
            (name: "Income", icon: "dollarsign.circle.fill"),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]

        for category in categories {
            let newCategory = ExpenseCategory(name: category.name, iconName: category.icon)
            modelContext.insert(newCategory)
        }

        try? modelContext.save()
    }
}

/// Accounts data generator
@MainActor
class AccountsDataGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        let accounts = [
<<<<<<< HEAD
            (name: "Checking Account", icon: "creditcard.fill", balance: 2_500.0),
            (name: "Savings Account", icon: "building.columns.fill", balance: 15_000.0),
            (name: "Credit Card", icon: "creditcard", balance: -850.0),
            (name: "Investment Account", icon: "chart.line.uptrend.xyaxis", balance: 25_000.0),
            (name: "Emergency Fund", icon: "shield.fill", balance: 5_000.0)
=======
            (name: "Checking Account", icon: "creditcard.fill", balance: 2500.0),
            (name: "Savings Account", icon: "building.columns.fill", balance: 15000.0),
            (name: "Credit Card", icon: "creditcard", balance: -850.0),
            (name: "Investment Account", icon: "chart.line.uptrend.xyaxis", balance: 25000.0),
            (name: "Emergency Fund", icon: "shield.fill", balance: 5000.0),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]

        for account in accounts {
            let newAccount = FinancialAccount(name: account.name, balance: account.balance, iconName: account.icon)
            modelContext.insert(newAccount)
        }

        try? modelContext.save()
    }
}

/// Budgets data generator
@MainActor
class BudgetsDataGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        guard let categories = try? modelContext.fetch(FetchDescriptor<ExpenseCategory>()) else { return }

        var categoryDict: [String: ExpenseCategory] = [:]
        for category in categories {
            categoryDict[category.name] = category
        }

        // Current month budgets
        let currentMonthBudgets = [
<<<<<<< HEAD
            (category: "Housing", limit: 1_300.0),
            (category: "Food", limit: 500.0),
            (category: "Transportation", limit: 200.0),
            (category: "Utilities", limit: 250.0),
            (category: "Entertainment", limit: 150.0)
=======
            (category: "Housing", limit: 1300.0),
            (category: "Food", limit: 500.0),
            (category: "Transportation", limit: 200.0),
            (category: "Utilities", limit: 250.0),
            (category: "Entertainment", limit: 150.0),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]

        // Get first day of current month
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let firstDayOfMonth = calendar.date(from: components) else {
            os_log("Failed to create first day of month", log: .default, type: .error)
            return
        }

        // Create budgets for current month
        for budgetInfo in currentMonthBudgets {
            if let category = categoryDict[budgetInfo.category] {
                let budget = Budget(
                    name: "\(category.name) Budget",
                    limitAmount: budgetInfo.limit,
                    month: firstDayOfMonth,
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                budget.category = category
                modelContext.insert(budget)
            }
        }

        // Previous month budgets (for comparison)
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth) {
            for budgetInfo in currentMonthBudgets {
                if let category = categoryDict[budgetInfo.category] {
                    let budget = Budget(
                        name: "\(category.name) Budget",
                        limitAmount: budgetInfo.limit,
                        month: previousMonth,
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                    budget.category = category
                    modelContext.insert(budget)
                }
            }
        }

        try? modelContext.save()
    }
}

/// Savings goals data generator
@MainActor
class SavingsGoalsDataGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        let calendar = Calendar.current
        let savingsGoals = [
<<<<<<< HEAD
            (name: "Emergency Fund", target: 10_000.0, current: 3_500.0,
             targetDate: calendar.date(byAdding: .month, value: 12, to: Date())),
            (name: "Vacation Fund", target: 5_000.0, current: 1_200.0,
             targetDate: calendar.date(byAdding: .month, value: 8, to: Date())),
            (name: "New Car", target: 25_000.0, current: 8_500.0,
             targetDate: calendar.date(byAdding: .month, value: 24, to: Date())),
            (name: "Home Down Payment", target: 50_000.0, current: 15_000.0,
             targetDate: calendar.date(byAdding: .month, value: 36, to: Date()))
=======
            (name: "Emergency Fund", target: 10000.0, current: 3500.0,
             targetDate: calendar.date(byAdding: .month, value: 12, to: Date())),
            (name: "Vacation Fund", target: 5000.0, current: 1200.0,
             targetDate: calendar.date(byAdding: .month, value: 8, to: Date())),
            (name: "New Car", target: 25000.0, current: 8500.0,
             targetDate: calendar.date(byAdding: .month, value: 24, to: Date())),
            (name: "Home Down Payment", target: 50000.0, current: 15000.0,
             targetDate: calendar.date(byAdding: .month, value: 36, to: Date())),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]

        for goal in savingsGoals {
            let newGoal = SavingsGoal(name: goal.name, targetAmount: goal.target, currentAmount: goal.current)
            if let targetDate = goal.targetDate {
                newGoal.targetDate = targetDate
            }

            modelContext.insert(newGoal)
        }

        try? modelContext.save()
    }
}
