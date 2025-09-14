import SwiftData
import XCTest

// Unit tests for ExpenseCategory model in MomentumFinance
@testable import MomentumFinance

final class ExpenseCategoryModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            ExpenseCategory.self, FinancialTransaction.self, FinancialAccount.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    func testCategoryCreation() throws {
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        XCTAssertEqual(category.name, "Food")
        XCTAssertEqual(category.iconName, "fork.knife")
    }

    func testCategoryPersistence() throws {
        let category = ExpenseCategory(name: "Transport", iconName: "car")
        modelContext.insert(category)
        try modelContext.save()
        let fetchRequest = FetchDescriptor<ExpenseCategory>()
        let savedCategories = try modelContext.fetch(fetchRequest)
        XCTAssertEqual(savedCategories.count, 1)
        XCTAssertEqual(savedCategories.first?.name, "Transport")
    }

    func testTotalSpentForMonth() throws {
        let category = ExpenseCategory(name: "Dining", iconName: "fork.knife")
        let now = Date()
        let transaction1 = FinancialTransaction(
            title: "Lunch", amount: 20.0, date: now, transactionType: .expense)
        let transaction2 = FinancialTransaction(
            title: "Dinner", amount: 30.0, date: now, transactionType: .expense)
        category.transactions = [transaction1, transaction2]
        let total = category.totalSpent(for: now)
        XCTAssertEqual(total, 50.0)
    }

    func testTotalSpentForMonthWithNoTransactions() throws {
        let category = ExpenseCategory(name: "Empty", iconName: "tray")
        let now = Date()
        let total = category.totalSpent(for: now)
        XCTAssertEqual(total, 0.0)
    }
}
