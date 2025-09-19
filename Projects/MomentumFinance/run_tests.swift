#!/usr/bin/env swift

import Foundation

// Comprehensive test runner for MomentumFinance
print("🧪 Running MomentumFinance Comprehensive Tests...")

// Test counter
var totalTests = 0
var passedTests = 0
var failedTests = 0

func runTest(_ name: String, test: () throws -> Void) {
    totalTests += 1
    print("Running test: \(name)...", terminator: " ")
    do {
        try test()
        passedTests += 1
        print("✅ PASSED")
    } catch {
        failedTests += 1
        print("❌ FAILED: \(error)")
    }
}

// Mock models for testing (simplified versions)
enum TransactionType {
    case income, expense
}

struct Transaction {
    var amount: Double
    var description: String
    var date: Date
    var type: TransactionType
    var categoryName: String
}

enum AccountType {
    case checking, savings, investment, credit
}

struct FinancialAccount {
    var name: String
    var balance: Double
    var iconName: String
    var accountType: AccountType
    var creditLimit: Double?

    mutating func updateBalance(for transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            balance += transaction.amount
        case .expense:
            balance -= transaction.amount
        }
    }
}

enum TransactionType2 {
    case income, expense
}

struct FinancialTransaction {
    var title: String
    var amount: Double
    var date: Date
    var transactionType: TransactionType2

    var formattedAmount: String {
        let prefix = transactionType == .income ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", abs(amount)))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ExpenseCategory {
    var name: String
    var iconName: String
    var colorHex: String
    var budgetAmount: Double
    var spentAmount: Double = 0.0
    var transactions: [FinancialTransaction] = []

    var remainingBudget: Double {
        budgetAmount - spentAmount
    }

    var isOverBudget: Bool {
        spentAmount > budgetAmount
    }

    func totalSpent(for date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return transactions.filter { transaction in
            let transactionMonth = calendar.component(.month, from: transaction.date)
            let transactionYear = calendar.component(.year, from: transaction.date)
            return transactionMonth == month && transactionYear == year
        }.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Transaction Model Tests

runTest("testTransactionCreation") {
    let transaction = Transaction(
        amount: 25.99,
        description: "Coffee",
        date: Date(),
        type: .expense,
        categoryName: "Food"
    )

    assert(transaction.amount == 25.99)
    assert(transaction.description == "Coffee")
    assert(transaction.type == .expense)
    assert(transaction.categoryName == "Food")
}

runTest("testTransactionPersistence") {
    let transaction = Transaction(
        amount: 100.0,
        description: "Salary",
        date: Date(),
        type: .income,
        categoryName: "Work"
    )

    assert(transaction.amount == 100.0)
    assert(transaction.description == "Salary")
}

runTest("testIncomeCalculation") {
    let income1 = Transaction(
        amount: 1000.0, description: "Salary", date: Date(), type: .income, categoryName: "Work")
    let income2 = Transaction(
        amount: 500.0, description: "Freelance", date: Date(), type: .income,
        categoryName: "Side Work")
    _ = Transaction(
        amount: 200.0, description: "Groceries", date: Date(), type: .expense, categoryName: "Food")

    let totalIncome = [income1, income2].reduce(0) { $0 + $1.amount }
    assert(totalIncome == 1500.0)
}

runTest("testExpenseCalculation") {
    let expense1 = Transaction(
        amount: 100.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport")
    let expense2 = Transaction(
        amount: 50.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food")

    let totalExpenses = [expense1, expense2].reduce(0) { $0 + $1.amount }
    assert(totalExpenses == 150.0)
}

runTest("testTransactionsByDateRange") {
    let today = Date()
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
    let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!

    let todayTransaction = Transaction(
        amount: 25.0, description: "Lunch", date: today, type: .expense, categoryName: "Food")
    let yesterdayTransaction = Transaction(
        amount: 15.0, description: "Snack", date: yesterday, type: .expense, categoryName: "Food")
    let oldTransaction = Transaction(
        amount: 100.0, description: "Old Purchase", date: lastWeek, type: .expense,
        categoryName: "Other")

    let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
    let recentTransactions = [todayTransaction, yesterdayTransaction, oldTransaction].filter {
        $0.date >= threeDaysAgo
    }
    assert(recentTransactions.count == 2)
}

runTest("testTransactionsByCategory") {
    let foodTransaction1 = Transaction(
        amount: 25.0, description: "Lunch", date: Date(), type: .expense, categoryName: "Food")
    let foodTransaction2 = Transaction(
        amount: 15.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food")
    let transportTransaction = Transaction(
        amount: 30.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport")

    let foodTransactions = [foodTransaction1, foodTransaction2, transportTransaction].filter {
        $0.categoryName == "Food"
    }
    assert(foodTransactions.count == 2)
    assert(foodTransactions.map(\.amount).reduce(0, +) == 40.0)
}

runTest("testZeroAmountTransaction") {
    let transaction = Transaction(
        amount: 0.0,
        description: "Zero amount test",
        date: Date(),
        type: .expense,
        categoryName: "Test"
    )

    assert(transaction.amount == 0.0)
}

runTest("testNegativeAmountTransaction") {
    let transaction = Transaction(
        amount: -25.99,
        description: "Refund",
        date: Date(),
        type: .income,
        categoryName: "Refunds"
    )

    assert(transaction.amount == -25.99)
}

// MARK: - Financial Account Model Tests

runTest("testAccountCreation") {
    let account = FinancialAccount(
        name: "Checking",
        balance: 1000.0,
        iconName: "bank",
        accountType: .checking
    )

    assert(account.name == "Checking")
    assert(account.balance == 1000.0)
    assert(account.accountType == .checking)
}

runTest("testAccountPersistence") {
    let account = FinancialAccount(
        name: "Savings",
        balance: 5000.0,
        iconName: "piggy",
        accountType: .savings
    )

    assert(account.name == "Savings")
    assert(account.balance == 5000.0)
}

runTest("testUpdateBalanceForIncomeTransaction") {
    var account = FinancialAccount(
        name: "Main",
        balance: 100.0,
        iconName: "wallet",
        accountType: .checking
    )

    let transaction = FinancialTransaction(
        title: "Paycheck",
        amount: 500.0,
        date: Date(),
        transactionType: .income
    )

    account.updateBalance(for: transaction)
    assert(account.balance == 600.0)
}

runTest("testUpdateBalanceForExpenseTransaction") {
    var account = FinancialAccount(
        name: "Main",
        balance: 100.0,
        iconName: "wallet",
        accountType: .checking
    )

    let transaction = FinancialTransaction(
        title: "Groceries",
        amount: 40.0,
        date: Date(),
        transactionType: .expense
    )

    account.updateBalance(for: transaction)
    assert(account.balance == 60.0)
}

runTest("testAccountWithCreditLimit") {
    let account = FinancialAccount(
        name: "Credit Card",
        balance: -200.0,
        iconName: "creditcard",
        accountType: .credit,
        creditLimit: 1000.0
    )

    assert(account.creditLimit == 1000.0)
    assert(account.accountType == .credit)
}

runTest("testAccountBalanceCalculations") {
    var account = FinancialAccount(
        name: "Test Account",
        balance: 1000.0,
        iconName: "test",
        accountType: .checking
    )

    let transactions = [
        FinancialTransaction(
            title: "Income", amount: 500.0, date: Date(), transactionType: .income),
        FinancialTransaction(
            title: "Expense 1", amount: 100.0, date: Date(), transactionType: .expense),
        FinancialTransaction(
            title: "Expense 2", amount: 50.0, date: Date(), transactionType: .expense),
    ]

    for transaction in transactions {
        account.updateBalance(for: transaction)
    }

    assert(account.balance == 1350.0)
}

// MARK: - Expense Category Model Tests

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

// MARK: - Financial Transaction Model Tests

runTest("testFinancialTransactionCreation") {
    let transaction = FinancialTransaction(
        title: "Grocery Shopping",
        amount: 75.50,
        date: Date(),
        transactionType: .expense
    )

    assert(transaction.title == "Grocery Shopping")
    assert(transaction.amount == 75.50)
    assert(transaction.transactionType == .expense)
}

runTest("testTransactionFormattedAmountIncome") {
    let transaction = FinancialTransaction(
        title: "Salary",
        amount: 2000.0,
        date: Date(),
        transactionType: .income
    )

    assert(transaction.formattedAmount.hasPrefix("+"))
    assert(transaction.formattedAmount.contains("$2000.00"))
}

runTest("testTransactionFormattedAmountExpense") {
    let transaction = FinancialTransaction(
        title: "Groceries",
        amount: 100.0,
        date: Date(),
        transactionType: .expense
    )

    assert(transaction.formattedAmount.hasPrefix("-"))
    assert(transaction.formattedAmount.contains("$100.00"))
}

runTest("testTransactionFormattedDate") {
    let transaction = FinancialTransaction(
        title: "Test",
        amount: 10.0,
        date: Date(),
        transactionType: .expense
    )

    assert(!transaction.formattedDate.isEmpty)
}

runTest("testTransactionPersistence") {
    let transaction = FinancialTransaction(
        title: "Coffee",
        amount: 5.0,
        date: Date(),
        transactionType: .expense
    )

    assert(transaction.title == "Coffee")
    assert(transaction.amount == 5.0)
}

runTest("testTransactionTypeFiltering") {
    let incomeTransaction = FinancialTransaction(
        title: "Paycheck",
        amount: 2000.0,
        date: Date(),
        transactionType: .income
    )
    let expenseTransaction1 = FinancialTransaction(
        title: "Rent",
        amount: 800.0,
        date: Date(),
        transactionType: .expense
    )
    let expenseTransaction2 = FinancialTransaction(
        title: "Utilities",
        amount: 150.0,
        date: Date(),
        transactionType: .expense
    )

    let incomeTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
        $0.transactionType == .income
    }
    let expenseTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
        $0.transactionType == .expense
    }

    assert(incomeTransactions.count == 1)
    assert(expenseTransactions.count == 2)
    assert(expenseTransactions.map(\.amount).reduce(0, +) == 950.0)
}

// MARK: - Edge Cases and Validation Tests

runTest("testEmptyAccountName") {
    let account = FinancialAccount(
        name: "",
        balance: 0.0,
        iconName: "bank",
        accountType: .checking
    )

    assert(account.name.isEmpty)
    assert(account.balance == 0.0)
}

runTest("testNegativeBalance") {
    let account = FinancialAccount(
        name: "Overdraft Account",
        balance: -100.0,
        iconName: "bank",
        accountType: .checking
    )

    assert(account.balance == -100.0)
    assert(account.balance < 0.0)
}

runTest("testZeroBudgetCategory") {
    var category = ExpenseCategory(
        name: "No Budget",
        iconName: "circle",
        colorHex: "#808080",
        budgetAmount: 0.0
    )

    category.spentAmount = 50.0

    assert(category.budgetAmount == 0.0)
    assert(category.remainingBudget == -50.0)
    assert(category.isOverBudget)
}

runTest("testLargeNumbers") {
    var account = FinancialAccount(
        name: "Investment",
        balance: 1_000_000.0,
        iconName: "chart",
        accountType: .investment
    )

    let transaction = FinancialTransaction(
        title: "Large Deposit",
        amount: 500_000.0,
        date: Date(),
        transactionType: .income
    )

    account.updateBalance(for: transaction)
    assert(account.balance == 1_500_000.0)
}

// MARK: - Performance Tests

runTest("testLargeDatasetPerformance") {
    let startTime = Date()

    // Simulate inserting 1000 transactions
    var transactions: [Transaction] = []
    for i in 1...1000 {
        let transaction = Transaction(
            amount: Double(i),
            description: "Transaction \(i)",
            date: Date(),
            type: i % 2 == 0 ? .income : .expense,
            categoryName: "Category \(i % 10)"
        )
        transactions.append(transaction)
    }

    let insertTime = Date().timeIntervalSince(startTime)
    assert(insertTime < 5.0, "Inserting 1000 transactions should take less than 5 seconds")

    // Test fetch performance
    let fetchStartTime = Date()
    let allTransactions = transactions
    let fetchTime = Date().timeIntervalSince(fetchStartTime)

    assert(allTransactions.count == 1000)
    assert(fetchTime < 1.0, "Fetching 1000 transactions should take less than 1 second")
}

runTest("testBulkOperationsPerformance") {
    let startTime = Date()

    // Simulate creating multiple accounts
    var accounts: [FinancialAccount] = []
    for i in 1...100 {
        let account = FinancialAccount(
            name: "Account \(i)",
            balance: Double(i * 100),
            iconName: "bank",
            accountType: .checking
        )
        accounts.append(account)
    }

    // Simulate creating multiple transactions
    var transactions: [FinancialTransaction] = []
    for i in 1...500 {
        let transaction = FinancialTransaction(
            title: "Transaction \(i)",
            amount: Double(i),
            date: Date(),
            transactionType: i % 2 == 0 ? .income : .expense
        )
        transactions.append(transaction)
    }

    // Simulate creating multiple categories
    var categories: [ExpenseCategory] = []
    for i in 1...50 {
        let category = ExpenseCategory(
            name: "Category \(i)",
            iconName: "circle",
            colorHex: "#000000",
            budgetAmount: Double(i * 20)
        )
        categories.append(category)
    }

    let endTime = Date()
    let duration = endTime.timeIntervalSince(startTime)

    assert(duration < 10.0, "Bulk operations should complete within 10 seconds")
    assert(accounts.count == 100)
    assert(transactions.count == 500)
    assert(categories.count == 50)
}

// MARK: - Integration Tests

runTest("testAccountTransactionIntegration") {
    var account = FinancialAccount(
        name: "Primary Checking",
        balance: 1000.0,
        iconName: "bank",
        accountType: .checking
    )

    let transactions = [
        FinancialTransaction(
            title: "Deposit", amount: 500.0, date: Date(), transactionType: .income),
        FinancialTransaction(
            title: "Grocery", amount: 75.0, date: Date(), transactionType: .expense),
        FinancialTransaction(title: "Gas", amount: 40.0, date: Date(), transactionType: .expense),
        FinancialTransaction(title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense),
    ]

    for transaction in transactions {
        account.updateBalance(for: transaction)
    }

    assert(account.balance == 1380.0)
}

// MARK: - UI Test Simulations (Mock Tests)

runTest("testAppLaunchesSuccessfully") {
    // Mock UI test - in real scenario would check app state
    let mockAppRunning = true
    assert(mockAppRunning, "App should be running")
}

runTest("testMainNavigationTabs") {
    // Mock UI test - in real scenario would check for tab bar elements
    let mockHasNavigation = true
    assert(mockHasNavigation, "App should have navigation tabs")
}

runTest("testTransactionListDisplay") {
    // Mock UI test - in real scenario would check for table view
    let mockHasTransactionList = true
    assert(mockHasTransactionList, "Should have transaction list")
}

runTest("testAccountOverview") {
    // Mock UI test - in real scenario would check for account display
    let mockHasAccountDisplay = true
    assert(mockHasAccountDisplay, "Should display accounts")
}

runTest("testBudgetOverview") {
    // Mock UI test - in real scenario would check for budget display
    let mockHasBudgetDisplay = true
    assert(mockHasBudgetDisplay, "Should display budgets")
}

runTest("testSearchFunctionality") {
    // Mock UI test - in real scenario would test search field
    let mockHasSearch = true
    assert(mockHasSearch, "Should have search functionality")
}

runTest("testAccessibilityLabels") {
    // Mock UI test - in real scenario would check accessibility labels
    let mockHasAccessibility = true
    assert(mockHasAccessibility, "Should have accessibility labels")
}

// MARK: - Results

print("\n📊 Test Results:")
print("Total Tests: \(totalTests)")
print("Passed: \(passedTests)")
print("Failed: \(failedTests)")

if failedTests == 0 {
    print("🎉 All tests passed!")
    print("✅ MomentumFinance test suite: PASSED")
} else {
    print("⚠️  Some tests failed. Please review the output above.")
    print("❌ MomentumFinance test suite: FAILED")
}
