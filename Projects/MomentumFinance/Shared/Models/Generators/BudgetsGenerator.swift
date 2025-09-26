import Foundation
import SwiftData

/// Budgets data generator
@MainActor
final class BudgetsGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generates sample budgets for the current and previous months
    func generate() {
        guard let categories = try? modelContext.fetch(FetchDescriptor<ExpenseCategory>()) else { return }

        var categoryDict: [String: ExpenseCategory] = [:]
        for category in categories {
            categoryDict[category.name] = category
        }

        // Current month budgets
        let currentMonthBudgets = [
            (category: "Housing", limit: 1300.0),
            (category: "Food & Dining", limit: 500.0),
            (category: "Transportation", limit: 200.0),
            (category: "Utilities", limit: 250.0),
            (category: "Entertainment", limit: 150.0),
            (category: "Shopping", limit: 300.0),
            (category: "Health & Fitness", limit: 100.0),
        ]

        // Get first day of current month
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let firstDayOfMonth = calendar.date(from: components) else {
            print("Failed to create first day of month")
            return
        }

        // Create budgets for current month
        for budgetInfo in currentMonthBudgets {
            if let category = categoryDict[budgetInfo.category] {
                let budget = Budget(
                    name: "\(category.name) Budget",
                    limitAmount: budgetInfo.limit,
                    month: firstDayOfMonth
                )
                budget.category = category
                self.modelContext.insert(budget)
            }
        }

        // Previous month budgets (for comparison)
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth) {
            for budgetInfo in currentMonthBudgets {
                if let category = categoryDict[budgetInfo.category] {
                    let budget = Budget(
                        name: "\(category.name) Budget",
                        limitAmount: budgetInfo.limit,
                        month: previousMonth
                    )
                    budget.category = category
                    self.modelContext.insert(budget)
                }
            }
        }

        try? self.modelContext.save()
    }
}
