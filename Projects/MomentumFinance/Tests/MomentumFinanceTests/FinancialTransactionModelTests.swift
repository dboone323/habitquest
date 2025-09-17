import SwiftData
import XCTest

// Unit tests for FinancialTransaction model in MomentumFinance
@testable import MomentumFinance

final class FinancialTransactionModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            FinancialTransaction.self, FinancialAccount.self, ExpenseCategory.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        self.modelContext = ModelContext(self.modelContainer)
    }

    override func tearDownWithError() throws {
        self.modelContainer = nil
        self.modelContext = nil
    }

    func testTransactionFormattedAmountIncome() throws {
        let transaction = FinancialTransaction(
            title: "Salary", amount: 2000.0, date: Date(), transactionType: .income
        )
        XCTAssertTrue(transaction.formattedAmount.hasPrefix("+"))
    }

    func testTransactionFormattedAmountExpense() throws {
        let transaction = FinancialTransaction(
            title: "Groceries", amount: 100.0, date: Date(), transactionType: .expense
        )
        XCTAssertTrue(transaction.formattedAmount.hasPrefix("-"))
    }

    func testTransactionFormattedDate() throws {
        let transaction = FinancialTransaction(
            title: "Test", amount: 10.0, date: Date(), transactionType: .expense
        )
        XCTAssertFalse(transaction.formattedDate.isEmpty)
    }

    func testTransactionPersistence() throws {
        let transaction = FinancialTransaction(
            title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense
        )
        self.modelContext.insert(transaction)
        try self.modelContext.save()
        let fetchRequest = FetchDescriptor<FinancialTransaction>()
        let savedTransactions = try modelContext.fetch(fetchRequest)
        XCTAssertEqual(savedTransactions.count, 1)
        XCTAssertEqual(savedTransactions.first?.title, "Coffee")
    }
}
