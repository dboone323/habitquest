import SwiftData
import XCTest

// Unit tests for FinancialAccount model in MomentumFinance
@testable import MomentumFinance

final class FinancialAccountModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            FinancialAccount.self, FinancialTransaction.self, ExpenseCategory.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        self.modelContext = ModelContext(self.modelContainer)
    }

    override func tearDownWithError() throws {
        self.modelContainer = nil
        self.modelContext = nil
    }

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
            title: "Groceries", amount: 40.0, date: Date(), transactionType: .expense
        )
        account.updateBalance(for: transaction)
        XCTAssertEqual(account.balance, 60.0)
    }

    func testAccountWithCreditLimit() throws {
        let account = FinancialAccount(
            name: "Credit Card", balance: -200.0, iconName: "creditcard", accountType: .credit,
            creditLimit: 1000.0
        )
        XCTAssertEqual(account.creditLimit, 1000.0)
        XCTAssertEqual(account.accountType, .credit)
    }
}
