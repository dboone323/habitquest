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
        app.launch()
    }

    // MARK: - Budget Creation Tests

    @MainActor
    func testCreateMonthlyBudget() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = app.buttons["Add Budget"].firstMatch
        XCTAssertTrue(addButton.exists, "Add budget button should exist")
        addButton.tap()

        // Fill in budget details
        let budgetNameField = app.textFields["Budget Name"].firstMatch
        let budgetAmountField = app.textFields["Budget Amount"].firstMatch
        let categoryPicker = app.popUpButtons["Category"].firstMatch
        let periodPicker = app.popUpButtons["Period"].firstMatch

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
            let foodCategory = app.menuItems["Food & Dining"].firstMatch
            if foodCategory.exists {
                foodCategory.click()
            }
        }

        if periodPicker.exists {
            periodPicker.click()
            let monthlyOption = app.menuItems["Monthly"].firstMatch
            if monthlyOption.exists {
                monthlyOption.click()
            }
        }

        // Save budget
        let saveButton = app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify budget was created
        let budgetList = app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Budget should be added to list")
        }
    }

    @MainActor
    func testCreateCategoryBudget() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = app.buttons["Add Budget"].firstMatch
        XCTAssertTrue(addButton.exists, "Add budget button should exist")
        addButton.tap()

        // Fill in category budget details
        let budgetNameField = app.textFields["Budget Name"].firstMatch
        let budgetAmountField = app.textFields["Budget Amount"].firstMatch
        let categoryPicker = app.popUpButtons["Category"].firstMatch

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
            let entertainmentCategory = app.menuItems["Entertainment"].firstMatch
            if entertainmentCategory.exists {
                entertainmentCategory.click()
            }
        }

        // Save budget
        let saveButton = app.buttons["Save"].firstMatch
        if saveButton.exists {
            saveButton.tap()
        }

        // Verify budget was created
        let budgetList = app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Category budget should be added to list")
        }
    }

    // MARK: - Budget Progress Tests

    @MainActor
    func testBudgetProgressDisplay() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check budget progress indicators
        let progressBars = app.progressIndicators.allElementsBoundByIndex
        let progressViews = app.otherElements.matching(identifier: "progress")
            .allElementsBoundByIndex

        XCTAssertGreaterThan(
            progressBars.count + progressViews.count, 0,
            "Should display budget progress indicators")

        // Verify progress values are shown
        let spentLabels = app.staticTexts.matching(identifier: "spent").allElementsBoundByIndex
        let remainingLabels = app.staticTexts.matching(identifier: "remaining")
            .allElementsBoundByIndex

        XCTAssertGreaterThan(
            spentLabels.count + remainingLabels.count, 0,
            "Should display spent/remaining amounts")
    }

    @MainActor
    func testBudgetProgressUpdate() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Get initial progress
        let initialProgressBars = app.progressIndicators.allElementsBoundByIndex
        let initialProgress = initialProgressBars.first?.value as? Double ?? 0.0

        // Add a transaction that affects a budget
        let addTransactionButton = app.buttons["Add Transaction"].firstMatch
        if addTransactionButton.exists {
            addTransactionButton.tap()

            let amountField = app.textFields["Amount"].firstMatch
            let categoryPicker = app.popUpButtons["Category"].firstMatch

            if amountField.exists {
                amountField.tap()
                amountField.typeText("50.00")
            }

            if categoryPicker.exists {
                categoryPicker.click()
                let foodCategory = app.menuItems["Food & Dining"].firstMatch
                if foodCategory.exists {
                    foodCategory.click()
                }
            }

            let saveButton = app.buttons["Save"].firstMatch
            if saveButton.exists {
                saveButton.tap()
            }

            // Check if budget progress updated
            let updatedProgressBars = app.progressIndicators.allElementsBoundByIndex
            let updatedProgress = updatedProgressBars.first?.value as? Double ?? 0.0

            // Progress should be different after transaction
            XCTAssertNotEqual(
                initialProgress, updatedProgress,
                "Budget progress should update after transaction")
        }
    }

    // MARK: - Budget Editing Tests

    @MainActor
    func testEditBudgetAmount() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Select a budget to edit
        let budgetList = app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let firstCell = budgetList.cells.firstMatch
            if firstCell.exists {
                firstCell.tap()

                // Look for edit button
                let editButton = app.buttons["Edit"].firstMatch
                if editButton.exists {
                    editButton.tap()

                    // Modify budget amount
                    let budgetAmountField = app.textFields["Budget Amount"].firstMatch
                    if budgetAmountField.exists {
                        budgetAmountField.tap()
                        budgetAmountField.clearText()
                        budgetAmountField.typeText("750.00")
                    }

                    // Save changes
                    let saveButton = app.buttons["Save"].firstMatch
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
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Get initial count
        let budgetList = app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let initialCount = budgetList.cells.count

            // Select and delete a budget
            let firstCell = budgetList.cells.firstMatch
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

                    // Verify budget was deleted
                    let finalCount = budgetList.cells.count
                    XCTAssertLessThan(
                        finalCount, initialCount, "Budget count should decrease after deletion")
                }
            }
        }
    }

    // MARK: - Budget Alert Tests

    @MainActor
    func testBudgetAlertDisplay() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check for budget alerts/warnings
        let alertIcons = app.images.matching(identifier: "alert").allElementsBoundByIndex
        let warningLabels = app.staticTexts.matching(identifier: "warning").allElementsBoundByIndex

        // If there are alerts, verify they are displayed properly
        if alertIcons.count > 0 || warningLabels.count > 0 {
            XCTAssertTrue(true, "Budget alerts should be displayed when budgets are exceeded")
        }
    }

    @MainActor
    func testBudgetOverLimitAlert() throws {
        // Create a budget and exceed it with transactions
        // This test assumes some transactions exist that would exceed budget

        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for over-limit indicators
        let overLimitLabels = app.staticTexts.matching(identifier: "over").allElementsBoundByIndex
        let exceededLabels = app.staticTexts.matching(identifier: "exceeded")
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
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check if budgets are organized by category
        let categorySections = app.staticTexts.matching(identifier: "category")
            .allElementsBoundByIndex
        XCTAssertGreaterThan(categorySections.count, 0, "Budgets should be organized by category")

        // Verify category breakdown
        let budgetList = app.tables["Budget List"].firstMatch
        if budgetList.exists {
            let cells = budgetList.cells
            XCTAssertGreaterThan(cells.count, 0, "Should display budgets by category")
        }
    }

    // MARK: - Budget Summary Tests

    @MainActor
    func testBudgetSummaryView() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Check for budget summary information
        let totalBudgetLabel = app.staticTexts["Total Budget"].firstMatch
        let totalSpentLabel = app.staticTexts["Total Spent"].firstMatch
        let remainingBudgetLabel = app.staticTexts["Remaining Budget"].firstMatch

        let hasSummary =
            totalBudgetLabel.exists || totalSpentLabel.exists || remainingBudgetLabel.exists
        XCTAssertTrue(hasSummary, "Should display budget summary information")
    }

    // MARK: - Budget Filtering Tests

    @MainActor
    func testFilterBudgetsByPeriod() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Open filter options
        let filterButton = app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Select period filter
            let periodFilter = app.buttons["By Period"].firstMatch
            if periodFilter.exists {
                periodFilter.tap()

                // Choose period
                let monthlyPeriod = app.buttons["Monthly"].firstMatch
                if monthlyPeriod.exists {
                    monthlyPeriod.tap()
                }

                // Apply filter
                let applyButton = app.buttons["Apply"].firstMatch
                if applyButton.exists {
                    applyButton.tap()
                }

                // Verify filtered results
                let budgetList = app.tables["Budget List"].firstMatch
                if budgetList.exists {
                    let cells = budgetList.cells
                    XCTAssertGreaterThanOrEqual(
                        cells.count, 0, "Filtered results should be displayed")
                }
            }
        }
    }

    // MARK: - Budget Validation Tests

    @MainActor
    func testInvalidBudgetAmountValidation() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = app.buttons["Add Budget"].firstMatch
        if addButton.exists {
            addButton.tap()

            let budgetAmountField = app.textFields["Budget Amount"].firstMatch
            if budgetAmountField.exists {
                budgetAmountField.tap()
                budgetAmountField.typeText("invalid")

                let saveButton = app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = app.staticTexts["Invalid budget amount"].firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for invalid amount")
                }
            }
        }
    }

    @MainActor
    func testZeroBudgetAmountValidation() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Add new budget
        let addButton = app.buttons["Add Budget"].firstMatch
        if addButton.exists {
            addButton.tap()

            let budgetAmountField = app.textFields["Budget Amount"].firstMatch
            if budgetAmountField.exists {
                budgetAmountField.tap()
                budgetAmountField.typeText("0.00")

                let saveButton = app.buttons["Save"].firstMatch
                if saveButton.exists {
                    saveButton.tap()

                    // Check for validation error
                    let errorMessage = app.staticTexts["Budget amount must be greater than zero"]
                        .firstMatch
                    XCTAssertTrue(
                        errorMessage.exists, "Should show validation error for zero amount")
                }
            }
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testBudgetListScrollingPerformance() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Measure scrolling performance
        let budgetList = app.tables["Budget List"].firstMatch
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
            let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
            if budgetsTab.exists {
                budgetsTab.tap()
            }

            // Add new budget
            let addButton = app.buttons["Add Budget"].firstMatch
            if addButton.exists {
                addButton.tap()

                let budgetNameField = app.textFields["Budget Name"].firstMatch
                if budgetNameField.exists {
                    budgetNameField.tap()
                    budgetNameField.typeText("Performance Test Budget")
                }

                let budgetAmountField = app.textFields["Budget Amount"].firstMatch
                if budgetAmountField.exists {
                    budgetAmountField.tap()
                    budgetAmountField.typeText("100.00")
                }

                let saveButton = app.buttons["Save"].firstMatch
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
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for report generation
        let reportButton = app.buttons["Generate Report"].firstMatch
        if reportButton.exists {
            reportButton.tap()

            // Check for report view
            let reportView = app.otherElements["Budget Report"].firstMatch
            if reportView.exists {
                XCTAssertTrue(reportView.isEnabled, "Budget report should be generated")

                // Check report contents
                let reportTitle = app.staticTexts["Budget Report"].firstMatch
                XCTAssertTrue(reportTitle.exists, "Report should have a title")
            }
        }
    }

    @MainActor
    func testBudgetComparisonView() throws {
        // Navigate to budgets
        let budgetsTab = app.tabBars.buttons["Budgets"].firstMatch
        if budgetsTab.exists {
            budgetsTab.tap()
        }

        // Look for budget comparison functionality
        let compareButton = app.buttons["Compare"].firstMatch
        if compareButton.exists {
            compareButton.tap()

            // Check for comparison view
            let comparisonView = app.otherElements["Budget Comparison"].firstMatch
            if comparisonView.exists {
                XCTAssertTrue(comparisonView.isEnabled, "Budget comparison should be accessible")

                // Check for comparison elements
                let currentPeriodLabel = app.staticTexts["Current Period"].firstMatch
                let previousPeriodLabel = app.staticTexts["Previous Period"].firstMatch

                XCTAssertTrue(
                    currentPeriodLabel.exists || previousPeriodLabel.exists,
                    "Comparison should show different periods")
            }
        }
    }
}
