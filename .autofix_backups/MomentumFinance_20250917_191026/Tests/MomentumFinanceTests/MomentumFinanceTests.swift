import SwiftData
import XCTest

@testable import MomentumFinance

final class MomentumFinanceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([
            Transaction.self,
            Account.self,
            Category.self,
            FinancialAccount.self,
            FinancialTransaction.self,
            ExpenseCategory.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        self.modelContext = ModelContext(self.modelContainer)
    }

    override func tearDownWithError() throws {
        self.modelContainer = nil
        self.modelContext = nil
    }

    // MARK: - Transaction Model Tests

    func testTransactionCreation() throws {
        let transaction = Transaction(
            amount: 25.99,
            description: "Coffee",
            date: Date(),
            type: .expense,
            categoryName: "Food"
        )

        XCTAssertEqual(transaction.amount, 25.99)
        XCTAssertEqual(transaction.description, "Coffee")
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertEqual(transaction.categoryName, "Food")
    }

    func testTransactionPersistence() throws {
        let transaction = Transaction(
            amount: 100.0,
            description: "Salary",
            date: Date(),
            type: .income,
            categoryName: "Work"
        )

        self.modelContext.insert(transaction)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let savedTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.amount, 100.0)
        XCTAssertEqual(savedTransactions.first?.description, "Salary")
    }

    func testIncomeCalculation() throws {
        let income1 = Transaction(
            amount: 1000.0, description: "Salary", date: Date(), type: .income, categoryName: "Work"
        )
        let income2 = Transaction(
            amount: 500.0, description: "Freelance", date: Date(), type: .income,
            categoryName: "Side Work"
        )
        let expense = Transaction(
            amount: 200.0, description: "Groceries", date: Date(), type: .expense,
            categoryName: "Food"
        )

        self.modelContext.insert(income1)
        self.modelContext.insert(income2)
        self.modelContext.insert(expense)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.type == .income }
        )
        let incomeTransactions = try modelContext.fetch(fetchRequest)
        let totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }

        XCTAssertEqual(totalIncome, 1500.0)
        XCTAssertEqual(incomeTransactions.count, 2)
    }

    func testExpenseCalculation() throws {
        let expense1 = Transaction(
            amount: 100.0, description: "Gas", date: Date(), type: .expense,
            categoryName: "Transport"
        )
        let expense2 = Transaction(
            amount: 50.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food"
        )

        self.modelContext.insert(expense1)
        self.modelContext.insert(expense2)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.type == .expense }
        )
        let expenseTransactions = try modelContext.fetch(fetchRequest)
        let totalExpenses = expenseTransactions.reduce(0) { $0 + $1.amount }

        XCTAssertEqual(totalExpenses, 150.0)
        XCTAssertEqual(expenseTransactions.count, 2)
    }

    func testTransactionsByDateRange() throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        let todayTransaction = Transaction(
            amount: 25.0, description: "Lunch", date: today, type: .expense, categoryName: "Food"
        )
        let yesterdayTransaction = Transaction(
            amount: 15.0, description: "Snack", date: yesterday, type: .expense,
            categoryName: "Food"
        )
        let oldTransaction = Transaction(
            amount: 100.0, description: "Old Purchase", date: lastWeek, type: .expense,
            categoryName: "Other"
        )

        self.modelContext.insert(todayTransaction)
        self.modelContext.insert(yesterdayTransaction)
        self.modelContext.insert(oldTransaction)
        try self.modelContext.save()

        // Test recent transactions (last 3 days)
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.date >= threeDaysAgo }
        )
        let recentTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(recentTransactions.count, 2)
    }

    func testTransactionsByCategory() throws {
        let foodTransaction1 = Transaction(
            amount: 25.0, description: "Lunch", date: Date(), type: .expense, categoryName: "Food"
        )
        let foodTransaction2 = Transaction(
            amount: 15.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food"
        )
        let transportTransaction = Transaction(
            amount: 30.0, description: "Gas", date: Date(), type: .expense,
            categoryName: "Transport"
        )

        self.modelContext.insert(foodTransaction1)
        self.modelContext.insert(foodTransaction2)
        self.modelContext.insert(transportTransaction)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.categoryName == "Food" }
        )
        let foodTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(foodTransactions.count, 2)
        XCTAssertEqual(foodTransactions.map(\.amount).reduce(0, +), 40.0)
    }

    func testZeroAmountTransaction() throws {
        let zeroTransaction = Transaction(
            amount: 0.0,
            description: "Zero amount test",
            date: Date(),
            type: .expense,
            categoryName: "Test"
        )

        self.modelContext.insert(zeroTransaction)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(allTransactions.count, 1)
        XCTAssertEqual(allTransactions.first?.amount, 0.0)
    }

    func testNegativeAmountTransaction() throws {
        // In some contexts, negative amounts might represent refunds
        let refundTransaction = Transaction(
            amount: -25.99,
            description: "Refund",
            date: Date(),
            type: .income,
            categoryName: "Refunds"
        )

        self.modelContext.insert(refundTransaction)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(allTransactions.count, 1)
        XCTAssertEqual(allTransactions.first?.amount, -25.99)
    }

    func testTransactionPerformance() throws {
        let startTime = Date()

        // Insert 1000 transactions
        for i in 1 ... 1000 {
            let transaction = Transaction(
                amount: Double(i),
                description: "Transaction \(i)",
                date: Date(),
                type: i % 2 == 0 ? .income : .expense,
                categoryName: "Category \(i % 10)"
            )
            self.modelContext.insert(transaction)
        }

        try self.modelContext.save()

        let insertTime = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(
            insertTime, 5.0, "Inserting 1000 transactions should take less than 5 seconds"
        )

        // Test fetch performance
        let fetchStartTime = Date()
        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)
        let fetchTime = Date().timeIntervalSince(fetchStartTime)

        XCTAssertEqual(allTransactions.count, 1000)
        XCTAssertLessThan(
            fetchTime, 1.0, "Fetching 1000 transactions should take less than 1 second"
        )
    }

    // MARK: - Financial Account Model Tests

    func testAccountCreation() throws {
        let account = FinancialAccount(
            name: "Checking", balance: 1000.0, iconName: "bank", accountType: .checking
        )
        XCTAssertEqual(account.name, "Checking")
        XCTAssertEqual(account.balance, 1000.0)
        XCTAssertEqual(account.accountType, .checking)
    }

    func testAccountPersistence() throws {
        let account = FinancialAccount(
            name: "Savings", balance: 5000.0, iconName: "piggy", accountType: .savings
        )
        self.modelContext.insert(account)
        try self.modelContext.save()
        let fetchRequest = FetchDescriptor<FinancialAccount>()
        let savedAccounts = try modelContext.fetch(fetchRequest)
        XCTAssertEqual(savedAccounts.count, 1)
        XCTAssertEqual(savedAccounts.first?.name, "Savings")
    }

    func testUpdateBalanceForIncomeTransaction() throws {
        let account = FinancialAccount(
            name: "Main", balance: 100.0, iconName: "wallet", accountType: .checking
        )
        let transaction = FinancialTransaction(
            title: "Paycheck", amount: 500.0, date: Date(), transactionType: .income
        )
        account.updateBalance(for: transaction)
        XCTAssertEqual(account.balance, 600.0)
    }

    func testUpdateBalanceForExpenseTransaction() throws {
        let account = FinancialAccount(
            name: "Main", balance: 100.0, iconName: "wallet", accountType: .checking
        )
        let transaction = FinancialTransaction(
            title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense
        )
        account.updateBalance(for: transaction)
        XCTAssertEqual(account.balance, 95.0)
    }

    func testAccountBalanceCalculations() throws {
        let account = FinancialAccount(
            name: "Test Account", balance: 1000.0, iconName: "test", accountType: .checking
        )

        // Test multiple transactions
        let income = FinancialTransaction(
            title: "Income", amount: 500.0, date: Date(), transactionType: .income
        )
        let expense1 = FinancialTransaction(
            title: "Expense 1", amount: 100.0, date: Date(), transactionType: .expense
        )
        let expense2 = FinancialTransaction(
            title: "Expense 2", amount: 50.0, date: Date(), transactionType: .expense
        )

        account.updateBalance(for: income)
        account.updateBalance(for: expense1)
        account.updateBalance(for: expense2)

        XCTAssertEqual(account.balance, 1350.0)
    }

    // MARK: - Expense Category Model Tests

    func testExpenseCategoryCreation() throws {
        let category = ExpenseCategory(
            name: "Food", iconName: "fork.knife", colorHex: "#FF6B6B", budgetAmount: 500.0
        )

        XCTAssertEqual(category.name, "Food")
        XCTAssertEqual(category.iconName, "fork.knife")
        XCTAssertEqual(category.colorHex, "#FF6B6B")
        XCTAssertEqual(category.budgetAmount, 500.0)
    }

    func testExpenseCategoryPersistence() throws {
        let category = ExpenseCategory(
            name: "Transportation", iconName: "car", colorHex: "#4ECDC4", budgetAmount: 300.0
        )

        self.modelContext.insert(category)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<ExpenseCategory>()
        let savedCategories = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(savedCategories.count, 1)
        XCTAssertEqual(savedCategories.first?.name, "Transportation")
        XCTAssertEqual(savedCategories.first?.budgetAmount, 300.0)
    }

    func testCategoryBudgetTracking() throws {
        let category = ExpenseCategory(
            name: "Entertainment", iconName: "tv", colorHex: "#45B7D1", budgetAmount: 200.0
        )

        // Simulate spending
        category.spentAmount = 150.0

        XCTAssertEqual(category.spentAmount, 150.0)
        XCTAssertEqual(category.remainingBudget, 50.0)
        XCTAssertFalse(category.isOverBudget)
    }

    func testCategoryOverBudget() throws {
        let category = ExpenseCategory(
            name: "Dining Out", iconName: "fork.knife.circle", colorHex: "#FFA07A",
            budgetAmount: 100.0
        )

        // Simulate overspending
        category.spentAmount = 120.0

        XCTAssertEqual(category.spentAmount, 120.0)
        XCTAssertEqual(category.remainingBudget, -20.0)
        XCTAssertTrue(category.isOverBudget)
    }

    // MARK: - Financial Transaction Model Tests

    func testFinancialTransactionCreation() throws {
        let transaction = FinancialTransaction(
            title: "Grocery Shopping", amount: 75.50, date: Date(), transactionType: .expense
        )

        XCTAssertEqual(transaction.title, "Grocery Shopping")
        XCTAssertEqual(transaction.amount, 75.50)
        XCTAssertEqual(transaction.transactionType, .expense)
    }

    func testFinancialTransactionPersistence() throws {
        let transaction = FinancialTransaction(
            title: "Salary Deposit", amount: 2500.0, date: Date(), transactionType: .income
        )

        self.modelContext.insert(transaction)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<FinancialTransaction>()
        let savedTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.title, "Salary Deposit")
        XCTAssertEqual(savedTransactions.first?.amount, 2500.0)
    }

    func testTransactionTypeFiltering() throws {
        let incomeTransaction = FinancialTransaction(
            title: "Paycheck", amount: 2000.0, date: Date(), transactionType: .income
        )
        let expenseTransaction1 = FinancialTransaction(
            title: "Rent", amount: 800.0, date: Date(), transactionType: .expense
        )
        let expenseTransaction2 = FinancialTransaction(
            title: "Utilities", amount: 150.0, date: Date(), transactionType: .expense
        )

        self.modelContext.insert(incomeTransaction)
        self.modelContext.insert(expenseTransaction1)
        self.modelContext.insert(expenseTransaction2)
        try self.modelContext.save()

        let incomeFetchRequest = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { $0.transactionType == .income }
        )
        let expenseFetchRequest = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { $0.transactionType == .expense }
        )

        let incomeTransactions = try modelContext.fetch(incomeFetchRequest)
        let expenseTransactions = try modelContext.fetch(expenseFetchRequest)

        XCTAssertEqual(incomeTransactions.count, 1)
        XCTAssertEqual(expenseTransactions.count, 2)
        XCTAssertEqual(expenseTransactions.map(\.amount).reduce(0, +), 950.0)
    }

    // MARK: - Integration Tests

    func testAccountTransactionIntegration() throws {
        let account = FinancialAccount(
            name: "Primary Checking", balance: 1000.0, iconName: "bank", accountType: .checking
        )

        let transactions = [
            FinancialTransaction(
                title: "Deposit", amount: 500.0, date: Date(), transactionType: .income
            ),
            FinancialTransaction(
                title: "Grocery", amount: 75.0, date: Date(), transactionType: .expense
            ),
            FinancialTransaction(
                title: "Gas", amount: 40.0, date: Date(), transactionType: .expense
            ),
            FinancialTransaction(
                title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense
            ),
        ]

        // Apply all transactions to account
        for transaction in transactions {
            account.updateBalance(for: transaction)
        }

        XCTAssertEqual(account.balance, 1380.0)

        // Verify account and transactions are properly linked
        self.modelContext.insert(account)
        for transaction in transactions {
            self.modelContext.insert(transaction)
        }
        try self.modelContext.save()

        let accountFetchRequest = FetchDescriptor<FinancialAccount>()
        let transactionFetchRequest = FetchDescriptor<FinancialTransaction>()

        let savedAccounts = try modelContext.fetch(accountFetchRequest)
        let savedTransactions = try modelContext.fetch(transactionFetchRequest)

        XCTAssertEqual(savedAccounts.count, 1)
        XCTAssertEqual(savedTransactions.count, 4)
        XCTAssertEqual(savedAccounts.first?.balance, 1380.0)
    }

    func testCategoryTransactionIntegration() throws {
        let foodCategory = ExpenseCategory(
            name: "Food & Dining", iconName: "fork.knife", colorHex: "#FF6B6B", budgetAmount: 600.0
        )

        let transportCategory = ExpenseCategory(
            name: "Transportation", iconName: "car", colorHex: "#4ECDC4", budgetAmount: 300.0
        )

        // Simulate spending in categories
        foodCategory.spentAmount = 450.0
        transportCategory.spentAmount = 120.0

        XCTAssertEqual(foodCategory.remainingBudget, 150.0)
        XCTAssertEqual(transportCategory.remainingBudget, 180.0)
        XCTAssertFalse(foodCategory.isOverBudget)
        XCTAssertFalse(transportCategory.isOverBudget)

        // Persist categories
        self.modelContext.insert(foodCategory)
        self.modelContext.insert(transportCategory)
        try self.modelContext.save()

        let fetchRequest = FetchDescriptor<ExpenseCategory>()
        let savedCategories = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(savedCategories.count, 2)
        let totalBudget = savedCategories.map(\.budgetAmount).reduce(0, +)
        let totalSpent = savedCategories.map(\.spentAmount).reduce(0, +)

        XCTAssertEqual(totalBudget, 900.0)
        XCTAssertEqual(totalSpent, 570.0)
    }

    // MARK: - Edge Cases and Validation Tests

    func testEmptyAccountName() throws {
        let account = FinancialAccount(
            name: "", balance: 0.0, iconName: "bank", accountType: .checking
        )

        XCTAssertTrue(account.name.isEmpty)
        XCTAssertEqual(account.balance, 0.0)
    }

    func testNegativeBalance() throws {
        let account = FinancialAccount(
            name: "Overdraft Account", balance: -100.0, iconName: "bank", accountType: .checking
        )

        XCTAssertEqual(account.balance, -100.0)
        XCTAssertLessThan(account.balance, 0.0)
    }

    func testZeroBudgetCategory() throws {
        let category = ExpenseCategory(
            name: "No Budget", iconName: "circle", colorHex: "#808080", budgetAmount: 0.0
        )

        category.spentAmount = 50.0

        XCTAssertEqual(category.budgetAmount, 0.0)
        XCTAssertEqual(category.remainingBudget, -50.0)
        XCTAssertTrue(category.isOverBudget)
    }

    func testLargeNumbers() throws {
        let account = FinancialAccount(
            name: "Investment", balance: 1_000_000.0, iconName: "chart", accountType: .investment
        )

        let largeTransaction = FinancialTransaction(
            title: "Large Deposit", amount: 500_000.0, date: Date(), transactionType: .income
        )

        account.updateBalance(for: largeTransaction)

        XCTAssertEqual(account.balance, 1_500_000.0)
    }

    // MARK: - Performance Tests

    func testBulkOperationsPerformance() throws {
        let startTime = Date()

        // Create multiple accounts
        for i in 1 ... 100 {
            let account = FinancialAccount(
                name: "Account \(i)", balance: Double(i * 100), iconName: "bank",
                accountType: .checking
            )
            self.modelContext.insert(account)
        }

        // Create multiple transactions
        for i in 1 ... 500 {
            let transaction = FinancialTransaction(
                title: "Transaction \(i)", amount: Double(i), date: Date(),
                transactionType: i % 2 == 0 ? .income : .expense
            )
            self.modelContext.insert(transaction)
        }

        // Create multiple categories
        for i in 1 ... 50 {
            let category = ExpenseCategory(
                name: "Category \(i)", iconName: "circle", colorHex: "#000000",
                budgetAmount: Double(i * 20)
            )
            self.modelContext.insert(category)
        }

        try self.modelContext.save()

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 10.0, "Bulk operations should complete within 10 seconds")

        // Verify counts
        let accountCount = try modelContext.fetchCount(FetchDescriptor<FinancialAccount>())
        let transactionCount = try modelContext.fetchCount(FetchDescriptor<FinancialTransaction>())
        let categoryCount = try modelContext.fetchCount(FetchDescriptor<ExpenseCategory>())

        XCTAssertEqual(accountCount, 100)
        XCTAssertEqual(transactionCount, 500)
        XCTAssertEqual(categoryCount, 50)
    }
}
