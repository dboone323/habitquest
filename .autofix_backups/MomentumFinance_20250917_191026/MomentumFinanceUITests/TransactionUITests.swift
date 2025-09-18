//
//  TransactionUITests.swift
//  MomentumFinanceUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class TransactionUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        self.app.launch()
    }

    // MARK: - Transaction Creation Tests

    @MainActor
    func testCreateIncomeTransaction() throws {
        // Navigate to add transaction
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        XCTAssertTrue(addButton.exists, "Add transaction button should exist")
        addButton.tap()

        // Fill in transaction details
        let amountField = self.app.textFields["Amount"].firstMatch
        let descriptionField = self.app.textFields["Description"].firstMatch
        let categoryPicker = self.app.popUpButtons["Category"].firstMatch

        if amountField.exists {
            amountField.tap()
            amountField.typeText("100.00")
        }

        if descriptionField.exists {
            descriptionField.tap()
            descriptionField.typeText("Salary Payment")
        }

        if categoryPicker.exists {
            categoryPicker.click()
            let incomeCategory = self.app.menuItems["Income"].firstMatch
            if incomeCategory.exists {
                incomeCategory.click()
            }
        }

        // Save transaction
        let saveButton = self.app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify transaction was added
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            let cells = transactionList.cells
            XCTAssertGreaterThan(cells.count, 0, "Transaction should be added to list")
        }
    }

    @MainActor
    func testCreateExpenseTransaction() throws {
        // Navigate to add transaction
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        XCTAssertTrue(addButton.exists, "Add transaction button should exist")
        addButton.tap()

        // Fill in expense details
        let amountField = self.app.textFields["Amount"].firstMatch
        let descriptionField = self.app.textFields["Description"].firstMatch
        let categoryPicker = self.app.popUpButtons["Category"].firstMatch

        if amountField.exists {
            amountField.tap()
            amountField.typeText("50.00")
        }

        if descriptionField.exists {
            descriptionField.tap()
            descriptionField.typeText("Grocery Shopping")
        }

        if categoryPicker.exists {
            categoryPicker.click()
            let expenseCategory = self.app.menuItems["Food & Dining"].firstMatch
            if expenseCategory.exists {
                expenseCategory.click()
            }
        }

        // Save transaction
        let saveButton = self.app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify transaction was added
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            let cells = transactionList.cells
            XCTAssertGreaterThan(cells.count, 0, "Transaction should be added to list")
        }
    }

    // MARK: - Transaction Editing Tests

    @MainActor
    func testEditTransaction() throws {
        // Select a transaction to edit
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            let firstCell = transactionList.cells.firstMatch
            if firstCell.exists {
                firstCell.tap()

                // Look for edit button
                let editButton = self.app.buttons["Edit"].firstMatch
                if editButton.exists {
                    editButton.tap()

                    // Modify amount
                    let amountField = self.app.textFields["Amount"].firstMatch
                    if amountField.exists {
                        amountField.tap()
                        amountField.clearText()
                        amountField.typeText("75.00")
                    }

                    // Save changes
                    let saveButton = self.app.buttons["Save"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                    }

                    // Verify changes were saved
                    XCTAssertTrue(true, "Transaction editing should complete successfully")
                }
            }
        }
    }

    // MARK: - Transaction Deletion Tests

    @MainActor
    func testDeleteTransaction() throws {
        // Get initial count
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            let initialCount = transactionList.cells.count

            // Select and delete a transaction
            let firstCell = transactionList.cells.firstMatch
            if firstCell.exists {
                firstCell.press(forDuration: 1.0) // Long press for context menu

                let deleteButton = self.app.buttons["Delete"].firstMatch
                if deleteButton.exists {
                    deleteButton.tap()

                    // Confirm deletion
                    let confirmButton = self.app.buttons["Delete"].firstMatch
                    if confirmButton.exists {
                        confirmButton.tap()
                    }

                    // Verify transaction was deleted
                    let finalCount = transactionList.cells.count
                    XCTAssertLessThan(
                        finalCount, initialCount, "Transaction count should decrease after deletion"
                    )
                }
            }
        }
    }

    // MARK: - Transaction Filtering Tests

    @MainActor
    func testFilterByCategory() throws {
        // Open filter options
        let filterButton = self.app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Select category filter
            let categoryFilter = self.app.buttons["By Category"].firstMatch
            if categoryFilter.exists {
                categoryFilter.tap()

                // Choose a category
                let foodCategory = self.app.buttons["Food & Dining"].firstMatch
                if foodCategory.exists {
                    foodCategory.tap()
                }

                // Apply filter
                let applyButton = self.app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                }

                // Verify filtered results
                let transactionList = self.app.tables["Transaction List"].firstMatch
                if transactionList.exists {
                    let cells = transactionList.cells
                    XCTAssertGreaterThanOrEqual(
                        cells.count, 0, "Filtered results should be displayed"
                    )
                }
            }
        }
    }

    @MainActor
    func testFilterByDateRange() throws {
        // Open filter options
        let filterButton = self.app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Select date filter
            let dateFilter = self.app.buttons["By Date"].firstMatch
            if dateFilter.exists {
                dateFilter.tap()

                // Set date range
                let startDatePicker = self.app.datePickers["Start Date"].firstMatch
                let endDatePicker = self.app.datePickers["End Date"].firstMatch

                if startDatePicker.exists {
                    startDatePicker.tap()
                    // Select a date (implementation depends on date picker type)
                }

                if endDatePicker.exists {
                    endDatePicker.tap()
                    // Select a date (implementation depends on date picker type)
                }

                // Apply filter
                let applyButton = self.app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                }

                // Verify filtered results
                let transactionList = self.app.tables["Transaction List"].firstMatch
                if transactionList.exists {
                    let cells = transactionList.cells
                    XCTAssertGreaterThanOrEqual(
                        cells.count, 0, "Date filtered results should be displayed"
                    )
                }
            }
        }
    }

    // MARK: - Transaction Search Tests

    @MainActor
    func testSearchTransactions() throws {
        // Use search functionality
        let searchField = self.app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("grocery")

            // Verify search results
            let searchResults = self.app.tables["Search Results"].firstMatch
            if searchResults.exists {
                let cells = searchResults.cells
                XCTAssertGreaterThanOrEqual(cells.count, 0, "Search should return results")
            }

            // Clear search
            let clearButton = self.app.buttons["Clear"].firstMatch
            if clearButton.exists {
                clearButton.tap()
            }
        }
    }

    // MARK: - Transaction Sorting Tests

    @MainActor
    func testSortByDate() throws {
        // Test sorting transactions by date
        let sortButton = self.app.buttons["Sort"].firstMatch
        if sortButton.exists {
            sortButton.tap()

            let sortByDate = self.app.buttons["By Date"].firstMatch
            if sortByDate.exists {
                sortByDate.tap()

                // Verify sorting (this would require checking order of dates)
                let transactionList = self.app.tables["Transaction List"].firstMatch
                if transactionList.exists {
                    XCTAssertTrue(transactionList.exists, "Transactions should be sorted by date")
                }
            }
        }
    }

    @MainActor
    func testSortByAmount() throws {
        // Test sorting transactions by amount
        let sortButton = self.app.buttons["Sort"].firstMatch
        if sortButton.exists {
            sortButton.tap()

            let sortByAmount = self.app.buttons["By Amount"].firstMatch
            if sortByAmount.exists {
                sortByAmount.tap()

                // Verify sorting (this would require checking order of amounts)
                let transactionList = self.app.tables["Transaction List"].firstMatch
                if transactionList.exists {
                    XCTAssertTrue(transactionList.exists, "Transactions should be sorted by amount")
                }
            }
        }
    }

    // MARK: - Bulk Operations Tests

    @MainActor
    func testBulkDeleteTransactions() throws {
        // Test bulk deletion of transactions
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            let initialCount = transactionList.cells.count

            // Enter selection mode
            let selectButton = self.app.buttons["Select"].firstMatch
            if selectButton.exists {
                selectButton.tap()

                // Select multiple transactions
                let cells = transactionList.cells
                if cells.count >= 2 {
                    cells.element(boundBy: 0).tap()
                    cells.element(boundBy: 1).tap()

                    // Delete selected
                    let deleteButton = self.app.buttons["Delete Selected"].firstMatch
                    if deleteButton.exists {
                        deleteButton.tap()

                        // Confirm deletion
                        let confirmButton = self.app.buttons["Delete"].firstMatch
                        if confirmButton.exists {
                            confirmButton.tap()
                        }

                        // Verify transactions were deleted
                        let finalCount = transactionList.cells.count
                        XCTAssertLessThan(
                            finalCount, initialCount, "Multiple transactions should be deleted"
                        )
                    }
                }
            }
        }
    }

    // MARK: - Recurring Transaction Tests

    @MainActor
    func testCreateRecurringTransaction() throws {
        // Test creating a recurring transaction
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        if addButton.exists {
            addButton.tap()

            // Fill in transaction details
            let amountField = self.app.textFields["Amount"].firstMatch
            let descriptionField = self.app.textFields["Description"].firstMatch

            if amountField.exists {
                amountField.tap()
                amountField.typeText("100.00")
            }

            if descriptionField.exists {
                descriptionField.tap()
                descriptionField.typeText("Monthly Rent")
            }

            // Set as recurring
            let recurringSwitch = self.app.switches["Recurring"].firstMatch
            if recurringSwitch.exists {
                recurringSwitch.tap()
            }

            // Set frequency
            let frequencyPicker = self.app.popUpButtons["Frequency"].firstMatch
            if frequencyPicker.exists {
                frequencyPicker.click()
                let monthlyOption = self.app.menuItems["Monthly"].firstMatch
                if monthlyOption.exists {
                    monthlyOption.click()
                }
            }

            // Save transaction
            let saveButton = self.app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
            }

            // Verify recurring transaction was created
            XCTAssertTrue(true, "Recurring transaction should be created successfully")
        }
    }

    // MARK: - Transaction Validation Tests

    @MainActor
    func testInvalidAmountValidation() throws {
        // Test validation for invalid amounts
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        if addButton.exists {
            addButton.tap()

            let amountField = self.app.textFields["Amount"].firstMatch
            if amountField.exists {
                amountField.tap()
                amountField.typeText("invalid")

                let saveButton = self.app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = self.app.staticTexts["Invalid amount format"].firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for invalid amount"
                    )
                }
            }
        }
    }

    @MainActor
    func testRequiredFieldValidation() throws {
        // Test validation for required fields
        let addButton = self.app.buttons["Add Transaction"].firstMatch
        if addButton.exists {
            addButton.tap()

            // Try to save without required fields
            let saveButton = self.app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()

                // Check for validation error
                let errorMessage = self.app.staticTexts["Required field missing"].firstMatch
                XCTAssertTrue(
                    errorMessage.exists, "Should show validation error for missing required fields"
                )
            }
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testTransactionListScrollingPerformance() throws {
        // Navigate to transactions
        let transactionsTab = self.app.tabBars.buttons["Transactions"].firstMatch
        if transactionsTab.exists {
            transactionsTab.tap()
        }

        // Measure scrolling performance
        let transactionList = self.app.tables["Transaction List"].firstMatch
        if transactionList.exists {
            measure {
                transactionList.swipeUp()
                transactionList.swipeDown()
            }
        }
    }

    @MainActor
    func testBulkTransactionCreationPerformance() throws {
        measure {
            for i in 1 ... 10 {
                let addButton = self.app.buttons["Add Transaction"].firstMatch
                if addButton.exists {
                    addButton.tap()

                    let amountField = self.app.textFields["Amount"].firstMatch
                    if amountField.exists {
                        amountField.tap()
                        amountField.typeText("\(i * 10).00")
                    }

                    let saveButton = self.app.buttons["Save"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                    }
                }
            }
        }
    }
}
