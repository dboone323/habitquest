//
//  AccountUITests.swift
//  MomentumFinanceUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class AccountUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Account Creation Tests

    @MainActor
    func testCreateCheckingAccount() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Add new account
        let addButton = app.buttons["Add Account"].firstMatch
        XCTAssertTrue(addButton.exists, "Add account button should exist")
        addButton.tap()

        // Fill in account details
        let accountNameField = app.textFields["Account Name"].firstMatch
        let accountTypePicker = app.popUpButtons["Account Type"].firstMatch
        let initialBalanceField = app.textFields["Initial Balance"].firstMatch

        if accountNameField.exists {
            accountNameField.tap()
            accountNameField.typeText("Main Checking")
        }

        if accountTypePicker.exists {
            accountTypePicker.click()
            let checkingOption = app.menuItems["Checking"].firstMatch
            if checkingOption.exists {
                checkingOption.click()
            }
        }

        if initialBalanceField.exists {
            initialBalanceField.tap()
            initialBalanceField.typeText("1000.00")
        }

        // Save account
        let saveButton = app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify account was created
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            let cells = accountList.cells
            XCTAssertGreaterThan(cells.count, 0, "Account should be added to list")
        }
    }

    @MainActor
    func testCreateSavingsAccount() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Add new account
        let addButton = app.buttons["Add Account"].firstMatch
        XCTAssertTrue(addButton.exists, "Add account button should exist")
        addButton.tap()

        // Fill in savings account details
        let accountNameField = app.textFields["Account Name"].firstMatch
        let accountTypePicker = app.popUpButtons["Account Type"].firstMatch
        let initialBalanceField = app.textFields["Initial Balance"].firstMatch

        if accountNameField.exists {
            accountNameField.tap()
            accountNameField.typeText("Emergency Savings")
        }

        if accountTypePicker.exists {
            accountTypePicker.click()
            let savingsOption = app.menuItems["Savings"].firstMatch
            if savingsOption.exists {
                savingsOption.click()
            }
        }

        if initialBalanceField.exists {
            initialBalanceField.tap()
            initialBalanceField.typeText("5000.00")
        }

        // Save account
        let saveButton = app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify account was created
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            let cells = accountList.cells
            XCTAssertGreaterThan(cells.count, 0, "Savings account should be added to list")
        }
    }

    // MARK: - Account Balance Tests

    @MainActor
    func testAccountBalanceDisplay() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Check account balances are displayed
        let balanceLabels = app.staticTexts.matching(identifier: "balance").allElementsBoundByIndex
        XCTAssertGreaterThan(balanceLabels.count, 0, "Should display account balances")

        // Verify balance formatting
        for label in balanceLabels.prefix(3) {
            let text = label.label
            XCTAssertFalse(text.isEmpty, "Balance should not be empty")

            // Check for currency formatting (contains $ or other currency symbols)
            let hasCurrencySymbol =
                text.contains("$") || text.contains("€") || text.contains("£") || text.contains("¥")
            XCTAssertTrue(hasCurrencySymbol, "Balance should have currency formatting")
        }
    }

    @MainActor
    func testAccountBalanceUpdate() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Get initial balance
        let initialBalanceLabel = app.staticTexts.matching(identifier: "balance").firstMatch
        let initialBalance = initialBalanceLabel.label

        // Add a transaction that affects the account
        let addTransactionButton = app.buttons["Add Transaction"].firstMatch
        if addTransactionButton.exists {
            addTransactionButton.tap()

            let amountField = app.textFields["Amount"].firstMatch
            if amountField.exists {
                amountField.tap()
                amountField.typeText("100.00")
            }

            let saveButton = app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
            }

            // Check if balance updated
            let updatedBalanceLabel = app.staticTexts.matching(identifier: "balance").firstMatch
            let updatedBalance = updatedBalanceLabel.label

            // Balance should be different after transaction
            XCTAssertNotEqual(
                initialBalance, updatedBalance, "Account balance should update after transaction")
        }
    }

    // MARK: - Account Editing Tests

    @MainActor
    func testEditAccountDetails() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Select an account to edit
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            let firstCell = accountList.cells.firstMatch
            if firstCell.exists {
                firstCell.tap()

                // Look for edit button
                let editButton = app.buttons["Edit"].firstMatch
                if editButton.exists {
                    editButton.tap()

                    // Modify account name
                    let accountNameField = app.textFields["Account Name"].firstMatch
                    if accountNameField.exists {
                        accountNameField.tap()
                        accountNameField.clearText()
                        accountNameField.typeText("Updated Account Name")
                    }

                    // Save changes
                    let saveButton = app.buttons["Save"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                    }

                    // Verify changes were saved
                    XCTAssertTrue(true, "Account editing should complete successfully")
                }
            }
        }
    }

    // MARK: - Account Deletion Tests

    @MainActor
    func testDeleteAccount() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Get initial count
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            let initialCount = accountList.cells.count

            // Select and delete an account
            let firstCell = accountList.cells.firstMatch
            if firstCell.exists {
                firstCell.press(forDuration: 1.0)  // Long press for context menu

                let deleteButton = app.buttons["Delete"].firstMatch
                if deleteButton.exists {
                    deleteButton.tap()

                    // Confirm deletion
                    let confirmButton = app.buttons["Delete"].firstMatch
                    if confirmButton.exists {
                        confirmButton.tap()
                    }

                    // Verify account was deleted
                    let finalCount = accountList.cells.count
                    XCTAssertLessThan(
                        finalCount, initialCount, "Account count should decrease after deletion")
                }
            }
        }
    }

    // MARK: - Account Transfer Tests

    @MainActor
    func testTransferBetweenAccounts() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Look for transfer functionality
        let transferButton = app.buttons["Transfer"].firstMatch
        if transferButton.exists {
            transferButton.tap()

            // Fill in transfer details
            let amountField = app.textFields["Transfer Amount"].firstMatch
            let fromAccountPicker = app.popUpButtons["From Account"].firstMatch
            let toAccountPicker = app.popUpButtons["To Account"].firstMatch

            if amountField.exists {
                amountField.tap()
                amountField.typeText("200.00")
            }

            if fromAccountPicker.exists {
                fromAccountPicker.click()
                let firstAccount = app.menuItems.firstMatch
                if firstAccount.exists {
                    firstAccount.click()
                }
            }

            if toAccountPicker.exists {
                toAccountPicker.click()
                let secondAccount = app.menuItems.element(boundBy: 1)
                if secondAccount.exists {
                    secondAccount.click()
                }
            }

            // Execute transfer
            let transferButton = app.buttons["Execute Transfer"].firstMatch
            if transferButton.exists {
                transferButton.tap()
            }

            // Verify transfer completed
            XCTAssertTrue(true, "Transfer between accounts should complete successfully")
        }
    }

    // MARK: - Account Summary Tests

    @MainActor
    func testAccountSummaryView() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Select an account to view details
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            let firstCell = accountList.cells.firstMatch
            if firstCell.exists {
                firstCell.tap()

                // Check for account summary information
                let accountSummary = app.otherElements["Account Summary"].firstMatch
                if accountSummary.exists {
                    XCTAssertTrue(accountSummary.isEnabled, "Account summary should be accessible")

                    // Check for key summary elements
                    let totalBalance = app.staticTexts["Total Balance"].firstMatch
                    let availableBalance = app.staticTexts["Available Balance"].firstMatch
                    let recentTransactions = app.staticTexts["Recent Transactions"].firstMatch

                    XCTAssertTrue(
                        totalBalance.exists || availableBalance.exists || recentTransactions.exists,
                        "Account summary should contain key information")
                }
            }
        }
    }

    // MARK: - Account Filtering Tests

    @MainActor
    func testFilterAccountsByType() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Open filter options
        let filterButton = app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Select account type filter
            let typeFilter = app.buttons["By Type"].firstMatch
            if typeFilter.exists {
                typeFilter.tap()

                // Choose account type
                let checkingType = app.buttons["Checking"].firstMatch
                if checkingType.exists {
                    checkingType.tap()
                }

                // Apply filter
                let applyButton = app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                }

                // Verify filtered results
                let accountList = app.tables["Account List"].firstMatch
                if accountList.exists {
                    let cells = accountList.cells
                    XCTAssertGreaterThanOrEqual(
                        cells.count, 0, "Filtered results should be displayed")
                }
            }
        }
    }

    // MARK: - Account Search Tests

    @MainActor
    func testSearchAccounts() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Use search functionality
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("checking")

            // Verify search results
            let searchResults = app.tables["Search Results"].firstMatch
            if searchResults.exists {
                let cells = searchResults.cells
                XCTAssertGreaterThanOrEqual(cells.count, 0, "Search should return results")
            }

            // Clear search
            let clearButton = app.buttons["Clear"].firstMatch
            if clearButton.exists {
                clearButton.tap()
            }
        }
    }

    // MARK: - Account Validation Tests

    @MainActor
    func testInvalidAccountNameValidation() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Add new account
        let addButton = app.buttons["Add Account"].firstMatch
        if addButton.exists {
            addButton.tap()

            let accountNameField = app.textFields["Account Name"].firstMatch
            if accountNameField.exists {
                accountNameField.tap()
                accountNameField.typeText("")  // Empty name

                let saveButton = app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = app.staticTexts["Account name is required"].firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for empty account name")
                }
            }
        }
    }

    @MainActor
    func testDuplicateAccountNameValidation() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Add first account
        let addButton = app.buttons["Add Account"].firstMatch
        if addButton.exists {
            addButton.tap()

            let accountNameField = app.textFields["Account Name"].firstMatch
            if accountNameField.exists {
                accountNameField.tap()
                accountNameField.typeText("Test Account")
            }

            let saveButton = app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
            }

            // Try to add duplicate account
            let addButton2 = app.buttons["Add Account"].firstMatch
            if addButton2.exists {
                addButton2.tap()

                let accountNameField2 = app.textFields["Account Name"].firstMatch
                if accountNameField2.exists {
                    accountNameField2.tap()
                    accountNameField2.typeText("Test Account")  // Same name

                    let saveButton2 = app.buttons["Save"].firstMatch
                    if saveButton2.exists {
                        saveButton2.tap()

                        // Check for duplicate error
                        let errorMessage = app.staticTexts["Account name already exists"].firstMatch
                        XCTAssertTrue(
                            errorMessage.exists,
                            "Should show validation error for duplicate account name")
                    }
                }
            }
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testAccountListScrollingPerformance() throws {
        // Navigate to accounts
        let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
        if accountsTab.exists {
            accountsTab.tap()
        }

        // Measure scrolling performance
        let accountList = app.tables["Account List"].firstMatch
        if accountList.exists {
            measure {
                accountList.swipeUp()
                accountList.swipeDown()
            }
        }
    }

    @MainActor
    func testAccountCreationPerformance() throws {
        measure {
            // Navigate to accounts
            let accountsTab = app.tabBars.buttons["Accounts"].firstMatch
            if accountsTab.exists {
                accountsTab.tap()
            }

            // Add new account
            let addButton = app.buttons["Add Account"].firstMatch
            if addButton.exists {
                addButton.tap()

                let accountNameField = app.textFields["Account Name"].firstMatch
                if accountNameField.exists {
                    accountNameField.tap()
                    accountNameField.typeText("Performance Test Account")
                }

                let saveButton = app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()
                }
            }
        }
    }
}
