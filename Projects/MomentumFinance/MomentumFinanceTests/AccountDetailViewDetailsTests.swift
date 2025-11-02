import XCTest
@testable import MomentumFinance

class AccountDetailViewTests: XCTestCase {

    // MARK: - Test Cases for AccountDetailField

    func testAccountDetailFieldLabel() {
        let label = "Credit Limit"
        let value = "$10,000.00"
        let expectedText = "\(label): \(value)"
        
        let view = AccountDetailField(label: label, value: value)
        XCTAssertEqual(view.text, expectedText)
    }

    func testAccountDetailFieldValue() {
        let label = "Available Credit"
        let value = "$5,000.00"
        let expectedText = "\(label): \(value)"
        
        let view = AccountDetailField(label: label, value: value)
        XCTAssertEqual(view.text, expectedText)
    }

    // MARK: - Test Cases for AccountTypeBadge

    func testAccountTypeBadgeText() {
        let type = FinancialAccount.AccountType.credit
        let expectedText = "Credit"
        
        let view = AccountTypeBadge(type: type)
        XCTAssertEqual(view.text, expectedText)
    }

    func testAccountTypeBadgeColor() {
        let type = FinancialAccount.AccountType.credit
        let expectedColor = .purple
        
        let view = AccountTypeBadge(type: type)
        XCTAssertEqual(view.color, expectedColor)
    }

    // MARK: - Test Cases for CreditAccountDetailsView

    func testCreditAccountDetailsViewTitle() {
        let account = FinancialAccount()
        let expectedText = "Credit Account Details"
        
        let view = CreditAccountDetailsView(account: account)
        XCTAssertEqual(view.text, expectedText)
    }

    func testCreditAccountDetailsViewGridRows() {
        let account = FinancialAccount()
        let expectedRows = 4
        
        let view = CreditAccountDetailsView(account: account)
        XCTAssertEqual(view.gridRows, expectedRows)
    }

    func testCreditAccountDetailsViewGridCellColumns() {
        let account = FinancialAccount()
        let expectedColumns = 2
        
        let view = CreditAccountDetailsView(account: account)
        XCTAssertEqual(view.gridCellColumns, expectedColumns)
    }
}
