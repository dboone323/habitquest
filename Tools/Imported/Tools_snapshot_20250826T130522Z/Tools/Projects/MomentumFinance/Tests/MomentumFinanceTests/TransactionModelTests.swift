@testable import MomentumFinance
import SwiftData
import XCTest

/// Unit tests for Transaction model functionality
final class TransactionModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([Transaction.self, Account.self, Category.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Transaction Creation Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testTransactionCreation() throws {
        let transaction = Transaction(
            amount: 25.99,
            description: "Coffee",
            date: Date(),
            type: .expense,
            categoryName: "Food",
        )

        XCTAssertEqual(transaction.amount, 25.99)
        XCTAssertEqual(transaction.description, "Coffee")
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertEqual(transaction.categoryName, "Food")
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func testTransactionPersistence() throws {
        let transaction = Transaction(
            amount: 100.0,
            description: "Salary",
            date: Date(),
            type: .income,
            categoryName: "Work",
        )

        modelContext.insert(transaction)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let savedTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.amount, 100.0)
        XCTAssertEqual(savedTransactions.first?.description, "Salary")
    }

    // MARK: - Transaction Calculations Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testIncomeCalculation() throws {
        let income1 = Transaction(amount: 1000.0, description: "Salary", date: Date(), type: .income, categoryName: "Work")
        let income2 = Transaction(amount: 500.0, description: "Freelance", date: Date(), type: .income, categoryName: "Side Work")
        let expense = Transaction(amount: 200.0, description: "Groceries", date: Date(), type: .expense, categoryName: "Food")

        modelContext.insert(income1)
        modelContext.insert(income2)
        modelContext.insert(expense)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.type == .income },
        )
        let incomeTransactions = try modelContext.fetch(fetchRequest)
        let totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }

        XCTAssertEqual(totalIncome, 1500.0)
        XCTAssertEqual(incomeTransactions.count, 2)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func testExpenseCalculation() throws {
        let expense1 = Transaction(amount: 100.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport")
        let expense2 = Transaction(amount: 50.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food")

        modelContext.insert(expense1)
        modelContext.insert(expense2)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.type == .expense },
        )
        let expenseTransactions = try modelContext.fetch(fetchRequest)
        let totalExpenses = expenseTransactions.reduce(0) { $0 + $1.amount }

        XCTAssertEqual(totalExpenses, 150.0)
        XCTAssertEqual(expenseTransactions.count, 2)
    }

    // MARK: - Date Range Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testTransactionsByDateRange() throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        let todayTransaction = Transaction(amount: 25.0, description: "Lunch", date: today, type: .expense, categoryName: "Food")
        let yesterdayTransaction = Transaction(amount: 15.0, description: "Snack", date: yesterday, type: .expense, categoryName: "Food")
        let oldTransaction = Transaction(amount: 100.0, description: "Old Purchase", date: lastWeek, type: .expense, categoryName: "Other")

        modelContext.insert(todayTransaction)
        modelContext.insert(yesterdayTransaction)
        modelContext.insert(oldTransaction)
        try modelContext.save()

        // Test recent transactions (last 3 days)
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.date >= threeDaysAgo },
        )
        let recentTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(recentTransactions.count, 2)
    }

    // MARK: - Category Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testTransactionsByCategory() throws {
        let foodTransaction1 = Transaction(amount: 25.0, description: "Lunch", date: Date(), type: .expense, categoryName: "Food")
        let foodTransaction2 = Transaction(amount: 15.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food")
        let transportTransaction = Transaction(amount: 30.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport")

        modelContext.insert(foodTransaction1)
        modelContext.insert(foodTransaction2)
        modelContext.insert(transportTransaction)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.categoryName == "Food" },
        )
        let foodTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(foodTransactions.count, 2)
        XCTAssertEqual(foodTransactions.map(\.amount).reduce(0, +), 40.0)
    }

    // MARK: - Edge Cases Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testZeroAmountTransaction() throws {
        let zeroTransaction = Transaction(
            amount: 0.0,
            description: "Zero amount test",
            date: Date(),
            type: .expense,
            categoryName: "Test",
        )

        modelContext.insert(zeroTransaction)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(allTransactions.count, 1)
        XCTAssertEqual(allTransactions.first?.amount, 0.0)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func testNegativeAmountTransaction() throws {
        // In some contexts, negative amounts might represent refunds
        let refundTransaction = Transaction(
            amount: -25.99,
            description: "Refund",
            date: Date(),
            type: .income,
            categoryName: "Refunds",
        )

        modelContext.insert(refundTransaction)
        try modelContext.save()

        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)

        XCTAssertEqual(allTransactions.count, 1)
        XCTAssertEqual(allTransactions.first?.amount, -25.99)
    }

    // MARK: - Performance Tests

    /// <#Description#>
    /// - Returns: <#description#>
    func testLargeDatasetPerformance() throws {
        let startTime = Date()

        // Insert 1000 transactions
        for i in 1 ... 1000 {
            let transaction = Transaction(
                amount: Double(i),
                description: "Transaction \(i)",
                date: Date(),
                type: i % 2 == 0 ? .income : .expense,
                categoryName: "Category \(i % 10)",
            )
            modelContext.insert(transaction)
        }

        try modelContext.save()

        let insertTime = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(insertTime, 5.0, "Inserting 1000 transactions should take less than 5 seconds")

        // Test fetch performance
        let fetchStartTime = Date()
        let fetchRequest = FetchDescriptor<Transaction>()
        let allTransactions = try modelContext.fetch(fetchRequest)
        let fetchTime = Date().timeIntervalSince(fetchStartTime)

        XCTAssertEqual(allTransactions.count, 1000)
        XCTAssertLessThan(fetchTime, 1.0, "Fetching 1000 transactions should take less than 1 second")
    }
}
