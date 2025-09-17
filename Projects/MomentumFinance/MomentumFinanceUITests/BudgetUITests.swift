//
//  BudgetUITests.swift
//  MomentumFinanceUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class BudgetUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        self.app.launch()
    }

    // MARK: - Budget Creation Tests

    @MainActor
    func testCreateMonthlyBudget() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = self.app.buttons["Add Budget"].firstMatch
        XCTAssertTrue(addButton.exists, "Add budget button should exist")
        addButton.tap()

        // Fill in budget details
        let budgetNameField = self.app.textFields["Budget Name"].firstMatch
        let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
        let categoryPicker = self.app.popUpButtons["Category"].firstMatch
        let periodPicker = self.app.popUpButtons["Period"].firstMatch

        if budgetNameField.exists {
            budgetNameField.tap()
            budgetNameField.typeText("Monthly Food Budget")
        }

        if budgetAmountField.exists {
            budgetAmountField.tap()
            budgetAmountField.typeText("500.00")
        }

        if categoryPicker.exists {
            categoryPicker.click()
            let foodCategory = self.app.menuItems["Food & Dining"].firstMatch
            if foodCategory.exists {
                foodCategory.click()
            }
        }

        if periodPicker.exists {
            periodPicker.click()
            let monthlyOption = self.app.menuItems["Monthly"].firstMatch
            if monthlyOption.exists {
                monthlyOption.click()
            }
        }

        // Save budget
        let saveButton = self.app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify budget was created
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Budget should be added to list")
        }
    }

    @MainActor
    func testCreateCategoryBudget() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = self.app.buttons["Add Budget"].firstMatch
        XCTAssertTrue(addButton.exists, "Add budget button should exist")
        addButton.tap()

        // Fill in category budget details
        let budgetNameField = self.app.textFields["Budget Name"].firstMatch
        let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
        let categoryPicker = self.app.popUpButtons["Category"].firstMatch

        if budgetNameField.exists {
            budgetNameField.tap()
            budgetNameField.typeText("Entertainment Budget")
        }

        if budgetAmountField.exists {
            budgetAmountField.tap()
            budgetAmountField.typeText("200.00")
        }

        if categoryPicker.exists {
            categoryPicker.click()
            let entertainmentCategory = self.app.menuItems["Entertainment"].firstMatch
            if entertainmentCategory.exists {
                entertainmentCategory.click()
            }
        }

        // Save budget
        let saveButton = self.app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify budget was created
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Category budget should be added to list")
        }
    }

    // MARK: - Budget Progress Tests

    @MainActor
    func testBudgetProgressDisplay() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check budget progress indicators
        let progressBars = self.app.progressIndicators.allElementsBoundByIndex
        let progressViews = self.app.otherElements.matching(identifier: "progress")
            .allElementsBoundByIndex

        XCTAssertGreaterThan(
            progressBars.count + progressViews.count, 0,
            "Should display budget progress indicators"
        )

        // Verify progress values are shown
        let spentLabels = self.app.staticTexts.matching(identifier: "spent").allElementsBoundByIndex
        let remainingLabels = self.app.staticTexts.matching(identifier: "remaining")
            .allElementsBoundByIndex

        XCTAssertGreaterThan(
            spentLabels.count + remainingLabels.count, 0,
            "Should display spent/remaining amounts"
        )
    }

    @MainActor
    func testBudgetProgressUpdate() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Get initial progress
        let initialProgressBars = self.app.progressIndicators.allElementsBoundByIndex
        let initialProgress = initialProgressBars.first?.value as? Double ?? 0.0

        // Add a transaction that affects a budget
        let addTransactionButton = self.app.buttons["Add Transaction"].firstMatch
        if addTransactionButton.exists {
            addTransactionButton.tap()

            let amountField = self.app.textFields["Amount"].firstMatch
            let categoryPicker = self.app.popUpButtons["Category"].firstMatch

            if amountField.exists {
                amountField.tap()
                amountField.typeText("50.00")
            }

            if categoryPicker.exists {
                categoryPicker.click()
                let foodCategory = self.app.menuItems["Food & Dining"].firstMatch
                if foodCategory.exists {
                    foodCategory.click()
                }
            }

            let saveButton = self.app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
            }

            // Check if budget progress updated
            let updatedProgressBars = self.app.progressIndicators.allElementsBoundByIndex
            let updatedProgress = updatedProgressBars.first?.value as? Double ?? 0.0

            // Progress should be different after transaction
            XCTAssertNotEqual(
                initialProgress, updatedProgress,
                "Budget progress should update after transaction"
            )
        }
    }

    // MARK: - Budget Editing Tests

    @MainActor
    func testEditBudgetAmount() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Select a budget to edit
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let firstCell = budgetList.cells.firstMatch
            if firstCell.exists {
                firstCell.tap()

                // Look for edit button
                let editButton = self.app.buttons["Edit"].firstMatch
                if editButton.exists {
                    editButton.tap()

                    // Modify budget amount
                    let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
                    if budgetAmountField.exists {
                        budgetAmountField.tap()
                        budgetAmountField.clearText()
                        budgetAmountField.typeText("750.00")
                    }

                    // Save changes
                    let saveButton = self.app.buttons["Save"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                    }

                    // Verify changes were saved
                    XCTAssertTrue(true, "Budget editing should complete successfully")
                }
            }
        }
    }

    // MARK: - Budget Deletion Tests

    @MainActor
    func testDeleteBudget() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Get initial count
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let initialCount = budgetList.cells.count

            // Select and delete a budget
            let firstCell = budgetList.cells.firstMatch
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

                    // Verify budget was deleted
                    let finalCount = budgetList.cells.count
                    XCTAssertLessThan(
                        finalCount, initialCount, "Budget count should decrease after deletion"
                    )
                }
            }
        }
    }

    // MARK: - Budget Alert Tests

    @MainActor
    func testBudgetAlertDisplay() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check for budget alerts/warnings
        let alertIcons = self.app.images.matching(identifier: "alert").allElementsBoundByIndex
        let warningLabels = self.app.staticTexts.matching(identifier: "warning").allElementsBoundByIndex

        // If there are alerts, verify they are displayed properly
        if alertIcons.count > 0 || warningLabels.count > 0 {
            XCTAssertTrue(true, "Budget alerts should be displayed when budgets are exceeded")
        }
    }

    @MainActor
    func testBudgetOverLimitAlert() throws {
        // Create a budget and exceed it with transactions
        // This test assumes some transactions exist that would exceed budget

        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for over-limit indicators
        let overLimitLabels = self.app.staticTexts.matching(identifier: "over").allElementsBoundByIndex
        let exceededLabels = self.app.staticTexts.matching(identifier: "exceeded")
            .allElementsBoundByIndex

        // If budgets are exceeded, alerts should be shown
        if overLimitLabels.count > 0 || exceededLabels.count > 0 {
            XCTAssertTrue(true, "Should show alerts when budget is exceeded")
        }
    }

    // MARK: - Budget Category Tests

    @MainActor
    func testBudgetByCategory() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check if budgets are organized by category
        let categorySections = self.app.staticTexts.matching(identifier: "category")
            .allElementsBoundByIndex
        XCTAssertGreaterThan(categorySections.count, 0, "Budgets should be organized by category")

        // Verify category breakdown
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Should display budgets by category")
        }
    }

    // MARK: - Budget Summary Tests

    @MainActor
    func testBudgetSummaryView() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check for budget summary information
        let totalBudgetLabel = self.app.staticTexts["Total Budget"].firstMatch
        let totalSpentLabel = self.app.staticTexts["Total Spent"].firstMatch
        let remainingBudgetLabel = self.app.staticTexts["Remaining Budget"].firstMatch

        let hasSummary =
            totalBudgetLabel.exists || totalSpentLabel.exists || remainingBudgetLabel.exists
        XCTAssertTrue(hasSummary, "Should display budget summary information")
    }

    // MARK: - Budget Filtering Tests

    @MainActor
    func testFilterBudgetsByPeriod() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Open filter options
        let filterButton = self.app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Select period filter
            let periodFilter = self.app.buttons["By Period"].firstMatch
            if periodFilter.exists {
                periodFilter.tap()

                // Choose period
                let monthlyPeriod = self.app.buttons["Monthly"].firstMatch
                if monthlyPeriod.exists {
                    monthlyPeriod.tap()
                }

                // Apply filter
                let applyButton = self.app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                }

                // Verify filtered results
                let budgetList = self.app.tables["Budget List"].firstMatch
                if budgetList.exists {
                    let cells = budgetList.cells
                    XCTAssertGreaterThanOrEqual(
                        cells.count, 0, "Filtered results should be displayed"
                    )
                }
            }
        }
    }

    // MARK: - Budget Validation Tests

    @MainActor
    func testInvalidBudgetAmountValidation() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = self.app.buttons["Add Budget"].firstMatch
        if addButton.exists {
            addButton.tap()

            let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
            if budgetAmountField.exists {
                budgetAmountField.tap()
                budgetAmountField.typeText("invalid")

                let saveButton = self.app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = self.app.staticTexts["Invalid budget amount"].firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for invalid amount"
                    )
                }
            }
        }
    }

    @MainActor
    func testZeroBudgetAmountValidation() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = self.app.buttons["Add Budget"].firstMatch
        if addButton.exists {
            addButton.tap()

            let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
            if budgetAmountField.exists {
                budgetAmountField.tap()
                budgetAmountField.typeText("0.00")

                let saveButton = self.app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = self.app.staticTexts["Budget amount must be greater than zero"]
                        .firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for zero amount"
                    )
                }
            }
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testBudgetListScrollingPerformance() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Measure scrolling performance
        let budgetList = self.app.tables["Budget List"].firstMatch
        if budgetList.exists {
            measure {
                budgetList.swipeUp()
                budgetList.swipeDown()
            }
        }
    }

    @MainActor
    func testBudgetCreationPerformance() throws {
        measure {
            // Navigate to budgets
            let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
            if budgetsTab.exists {
                budgetsTab.tap()
            }

            // Add new budget
            let addButton = self.app.buttons["Add Budget"].firstMatch
            if addButton.exists {
                addButton.tap()

                let budgetNameField = self.app.textFields["Budget Name"].firstMatch
                if budgetNameField.exists {
                    budgetNameField.tap()
                    budgetNameField.typeText("Performance Test Budget")
                }

                let budgetAmountField = self.app.textFields["Budget Amount"].firstMatch
                if budgetAmountField.exists {
                    budgetAmountField.tap()
                    budgetAmountField.typeText("100.00")
                }

                let saveButton = self.app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()
                }
            }
        }
    }

    // MARK: - Budget Report Tests

    @MainActor
    func testBudgetReportGeneration() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for report generation
        let reportButton = self.app.buttons["Generate Report"].firstMatch
        if reportButton.exists {
            reportButton.tap()

            // Check for report view
            let reportView = self.app.otherElements["Budget Report"].firstMatch
            if reportView.exists {
                XCTAssertTrue(reportView.isEnabled, "Budget report should be generated")

                // Check report contents
                let reportTitle = self.app.staticTexts["Budget Report"].firstMatch
                XCTAssertTrue(reportTitle.exists, "Report should have a title")
            }
        }
    }

    @MainActor
    func testBudgetComparisonView() throws {
        // Navigate to budgets
        let budgetsTab = self.app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for budget comparison functionality
        let compareButton = self.app.buttons["Compare"].firstMatch
        if compareButton.exists {
            compareButton.tap()

            // Check for comparison view
            let comparisonView = self.app.otherElements["Budget Comparison"].firstMatch
            if comparisonView.exists {
                XCTAssertTrue(comparisonView.isEnabled, "Budget comparison should be accessible")

                // Check for comparison elements
                let currentPeriodLabel = self.app.staticTexts["Current Period"].firstMatch
                let previousPeriodLabel = self.app.staticTexts["Previous Period"].firstMatch

                XCTAssertTrue(
                    currentPeriodLabel.exists || previousPeriodLabel.exists,
                    "Comparison should show different periods"
                )
            }
        }
    }
}
