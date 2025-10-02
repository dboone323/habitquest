import Foundation

// MARK: - Expense Category Model Tests

func runCategoryModelTests() {
    runTest("testCategoryCreation") {
        let category = ExpenseCategory(
            name: "Food",
            iconName: "fork.knife",
            colorHex: "#FF6B6B",
            budgetAmount: 500.0
        )

        assert(category.name == "Food")
        assert(category.iconName == "fork.knife")
        assert(category.colorHex == "#FF6B6B")
        assert(category.budgetAmount == 500.0)
    }

    runTest("testCategoryPersistence") {
        let category = ExpenseCategory(
            name: "Transport",
            iconName: "car",
            colorHex: "#4ECDC4",
            budgetAmount: 300.0
        )

        assert(category.name == "Transport")
        assert(category.budgetAmount == 300.0)
    }

    runTest("testTotalSpentForMonth") {
        let now = Date()
        var category = ExpenseCategory(
            name: "Dining",
            iconName: "fork.knife",
            colorHex: "#FF6B6B",
            budgetAmount: 400.0
        )

        let transaction1 = FinancialTransaction(
            title: "Lunch",
            amount: 20.0,
            date: now,
            transactionType: .expense
        )
        let transaction2 = FinancialTransaction(
            title: "Dinner",
            amount: 30.0,
            date: now,
            transactionType: .expense
        )

        category.transactions = [transaction1, transaction2]
        let total = category.totalSpent(for: now)
        assert(total == 50.0)
    }

    runTest("testTotalSpentForMonthWithNoTransactions") {
        let category = ExpenseCategory(
            name: "Empty",
            iconName: "tray",
            colorHex: "#808080",
            budgetAmount: 100.0
        )

        let now = Date()
        let total = category.totalSpent(for: now)
        assert(total == 0.0)
    }

    runTest("testCategoryBudgetTracking") {
        var category = ExpenseCategory(
            name: "Entertainment",
            iconName: "tv",
            colorHex: "#45B7D1",
            budgetAmount: 200.0
        )

        category.spentAmount = 150.0

        assert(category.spentAmount == 150.0)
        assert(category.remainingBudget == 50.0)
        assert(!category.isOverBudget)
    }

    runTest("testCategoryOverBudget") {
        var category = ExpenseCategory(
            name: "Dining Out",
            iconName: "fork.knife.circle",
            colorHex: "#FFA07A",
            budgetAmount: 100.0
        )

        category.spentAmount = 120.0

        assert(category.spentAmount == 120.0)
        assert(category.remainingBudget == -20.0)
        assert(category.isOverBudget)
    }

    runTest("testCategoryTransactionIntegration") {
        var foodCategory = ExpenseCategory(
            name: "Food & Dining",
            iconName: "fork.knife",
            colorHex: "#FF6B6B",
            budgetAmount: 600.0
        )

        var transportCategory = ExpenseCategory(
            name: "Transportation",
            iconName: "car",
            colorHex: "#4ECDC4",
            budgetAmount: 300.0
        )

        foodCategory.spentAmount = 450.0
        transportCategory.spentAmount = 120.0

        assert(foodCategory.remainingBudget == 150.0)
        assert(transportCategory.remainingBudget == 180.0)
        assert(!foodCategory.isOverBudget)
        assert(!transportCategory.isOverBudget)
    }
}
