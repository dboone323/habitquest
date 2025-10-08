//
//  BudgetsViewTests.swift
//  MomentumFinanceTests
//
//  Created by Daniel Stevens on 2025
//

import SwiftData
import SwiftUI
import XCTest

@testable import MomentumFinanceCore

@MainActor
final class BudgetsViewTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var viewModel: BudgetsViewModel!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([
            Budget.self,
            ExpenseCategory.self,
            FinancialTransaction.self
        ])
        self.modelContainer = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        self.modelContext = ModelContext(self.modelContainer)

        // Initialize view model
        self.viewModel = BudgetsViewModel()
        self.viewModel.setModelContext(self.modelContext)
    }

    override func tearDownWithError() throws {
        self.modelContainer = nil
        self.modelContext = nil
        self.viewModel = nil
    }

    // MARK: - View Model Business Logic Tests

    func testBudgetsViewModelCalculatesTotalBudgetedAmount() throws {
        // Given: Multiple budgets for the same month
        let category1 = ExpenseCategory(name: "Food", iconName: "fork.knife")
        let category2 = ExpenseCategory(name: "Transport", iconName: "car")
        self.modelContext.insert(category1)
        self.modelContext.insert(category2)

        let currentMonth = Date()
        let budget1 = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        budget1.category = category1

        let budget2 = Budget(name: "Transport Budget", limitAmount: 300.0, month: currentMonth)
        budget2.category = category2

        let budgets = [budget1, budget2]

        // When: Calculating total budgeted amount
        let total = self.viewModel.totalBudgetedAmount(budgets, for: currentMonth)

        // Then: Should sum all budget limits
        XCTAssertEqual(total, 800.0)
    }

    func testBudgetsViewModelCalculatesRemainingBudget() throws {
        // Given: Budgets with spending
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let currentMonth = Date()
        let budget = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        budget.category = category
        self.modelContext.insert(budget)

        // Create a transaction to simulate spending
        let transaction = FinancialTransaction(
            title: "Grocery Shopping",
            amount: 250.0,
            date: currentMonth,
            transactionType: .expense
        )
        transaction.category = category
        self.modelContext.insert(transaction)

        let budgets = [budget]

        // When: Calculating remaining budget
        let remaining = self.viewModel.remainingBudget(budgets, for: currentMonth)

        // Then: Should be limit minus spent
        XCTAssertEqual(remaining, 250.0)
    }

    func testBudgetsViewModelDetectsOverBudget() throws {
        // Given: Over-budget scenario
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let currentMonth = Date()
        let budget = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        budget.category = category
        self.modelContext.insert(budget)

        // Create a transaction to simulate over-budget spending
        let transaction = FinancialTransaction(
            title: "Expensive Dinner",
            amount: 600.0,
            date: currentMonth,
            transactionType: .expense
        )
        transaction.category = category
        self.modelContext.insert(transaction)

        let budgets = [budget]

        // When: Checking for over-budget categories
        let hasOverBudget = self.viewModel.hasOverBudgetCategories(budgets, for: currentMonth)

        // Then: Should detect over-budget
        XCTAssertTrue(hasOverBudget)
    }

    func testBudgetsViewModelCreatesBudgetSuccessfully() throws {
        // Given: Valid budget parameters
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let currentMonth = Date()

        // When: Creating a budget
        self.viewModel.createBudget(category: category, limitAmount: 500.0, month: currentMonth)

        // Then: Budget should be created and saved
        let descriptor = FetchDescriptor<Budget>()
        let budgets = try modelContext.fetch(descriptor)
        XCTAssertEqual(budgets.count, 1)
        XCTAssertEqual(budgets[0].limitAmount, 500.0)
        XCTAssertEqual(budgets[0].category?.name, "Food")
    }

    func testBudgetsViewModelPreventsDuplicateBudgets() throws {
        // Given: Existing budget for category and month
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let currentMonth = Date()
        let existingBudget = Budget(name: "Food Budget", limitAmount: 400.0, month: currentMonth)
        existingBudget.category = category
        self.modelContext.insert(existingBudget)

        // When: Attempting to create duplicate budget
        self.viewModel.createBudget(category: category, limitAmount: 500.0, month: currentMonth)

        // Then: Should not create duplicate
        let descriptor = FetchDescriptor<Budget>()
        let budgets = try modelContext.fetch(descriptor)
        XCTAssertEqual(budgets.count, 1) // Still only one budget
        XCTAssertEqual(budgets[0].limitAmount, 400.0) // Original amount preserved
    }

    func testBudgetsViewModelUpdatesBudgetLimit() throws {
        // Given: Existing budget
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let budget = Budget(name: "Food Budget", limitAmount: 400.0, month: Date())
        budget.category = category
        self.modelContext.insert(budget)

        // When: Updating budget limit
        self.viewModel.updateBudgetLimit(budget, newLimit: 600.0)

        // Then: Budget limit should be updated
        XCTAssertEqual(budget.limitAmount, 600.0)
    }

    func testBudgetsViewModelDeletesBudget() throws {
        // Given: Existing budget
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let budget = Budget(name: "Food Budget", limitAmount: 400.0, month: Date())
        budget.category = category
        self.modelContext.insert(budget)

        // When: Deleting budget
        self.viewModel.deleteBudget(budget)

        // Then: Budget should be removed
        let descriptor = FetchDescriptor<Budget>()
        let budgets = try modelContext.fetch(descriptor)
        XCTAssertEqual(budgets.count, 0)
    }

    func testBudgetsViewModelCalculatesBudgetProgressSummary() throws {
        // Given: Multiple budgets with different statuses
        let foodCategory = ExpenseCategory(name: "Food", iconName: "fork.knife")
        let transportCategory = ExpenseCategory(name: "Transport", iconName: "car")
        self.modelContext.insert(foodCategory)
        self.modelContext.insert(transportCategory)

        let currentMonth = Date()

        // On-track budget
        let foodBudget = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        foodBudget.category = foodCategory
        self.modelContext.insert(foodBudget)

        // Create transaction for food budget
        let foodTransaction = FinancialTransaction(
            title: "Weekly Groceries",
            amount: 250.0,
            date: currentMonth,
            transactionType: .expense
        )
        foodTransaction.category = foodCategory
        self.modelContext.insert(foodTransaction)

        // Over-budget
        let transportBudget = Budget(name: "Transport Budget", limitAmount: 300.0, month: currentMonth)
        transportBudget.category = transportCategory
        self.modelContext.insert(transportBudget)

        // Create transaction for transport budget (over budget)
        let transportTransaction = FinancialTransaction(
            title: "Car Repair",
            amount: 350.0,
            date: currentMonth,
            transactionType: .expense
        )
        transportTransaction.category = transportCategory
        self.modelContext.insert(transportTransaction)

        let budgets = [foodBudget, transportBudget]

        // When: Calculating progress summary
        let summary = self.viewModel.budgetProgressSummary(budgets, for: currentMonth)

        // Then: Summary should be correct
        XCTAssertEqual(summary.totalBudgeted, 800.0)
        XCTAssertEqual(summary.totalSpent, 600.0)
        XCTAssertEqual(summary.onTrackCount, 1)
        XCTAssertEqual(summary.overBudgetCount, 1)
        XCTAssertEqual(summary.totalBudgets, 2)
        XCTAssertEqual(summary.remainingAmount, 200.0)
    }

    // MARK: - Error Handling Tests

    func testBudgetsViewModelHandlesSaveErrorsGracefully() throws {
        // Given: View model without model context
        let viewModelWithoutContext = BudgetsViewModel()
        // Don't set model context

        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")

        // When: Attempting operations without context
        viewModelWithoutContext.createBudget(category: category, limitAmount: 500.0, month: Date())

        // Then: Should handle error gracefully (no crash)
        XCTAssertTrue(true) // Test passes if no exception thrown
    }

    // MARK: - Performance Tests

    func testBudgetsViewModelPerformanceWithLargeBudgetSet() throws {
        // Given: Large set of budgets with individual categories
        var budgets: [Budget] = []
        let currentMonth = Date()

        for i in 0 ..< 100 {
            let category = ExpenseCategory(name: "Category \(i)", iconName: "circle")
            self.modelContext.insert(category)

            let budget = Budget(name: "Budget \(i)", limitAmount: Double(i * 10 + 100), month: currentMonth)
            budget.category = category
            budgets.append(budget)
            self.modelContext.insert(budget)

            // Create transaction for each budget
            let transaction = FinancialTransaction(
                title: "Transaction \(i)",
                amount: Double(i * 5),
                date: currentMonth,
                transactionType: .expense
            )
            transaction.category = category
            self.modelContext.insert(transaction)
        }

        // When: Performing calculations on large dataset
        measure {
            let total = self.viewModel.totalBudgetedAmount(budgets, for: currentMonth)
            let remaining = self.viewModel.remainingBudget(budgets, for: currentMonth)
            let summary = self.viewModel.budgetProgressSummary(budgets, for: currentMonth)

            // Then: Operations should complete within reasonable time
            XCTAssertGreaterThan(total, 0)
            XCTAssertGreaterThanOrEqual(remaining, 0)
            XCTAssertEqual(summary.totalBudgets, 100)
        }
    }

    // MARK: - Edge Cases

    func testBudgetsViewModelHandlesZeroBudgets() throws {
        // Given: Empty budgets array
        let budgets: [Budget] = []
        let currentMonth = Date()

        // When: Calculating with empty array
        let total = self.viewModel.totalBudgetedAmount(budgets, for: currentMonth)
        let remaining = self.viewModel.remainingBudget(budgets, for: currentMonth)
        let hasOverBudget = self.viewModel.hasOverBudgetCategories(budgets, for: currentMonth)

        // Then: Should return zero/false values
        XCTAssertEqual(total, 0.0)
        XCTAssertEqual(remaining, 0.0)
        XCTAssertFalse(hasOverBudget)
    }

    func testBudgetsViewModelHandlesZeroLimitBudget() throws {
        // Given: Budget with zero limit
        let category = ExpenseCategory(name: "Test", iconName: "circle")
        self.modelContext.insert(category)

        let budget = Budget(name: "Zero Budget", limitAmount: 0.0, month: Date())
        budget.category = category
        let budgets = [budget]

        // No transactions needed for zero spending

        // When: Calculating progress
        let summary = self.viewModel.budgetProgressSummary(budgets, for: Date())

        // Then: Should handle zero division gracefully
        XCTAssertEqual(summary.progressPercentage, 0.0)
    }

    func testBudgetsViewModelHandlesNegativeSpending() throws {
        // Given: Budget with negative spending (refunds, etc.)
        let category = ExpenseCategory(name: "Test", iconName: "circle")
        self.modelContext.insert(category)

        let budget = Budget(name: "Test Budget", limitAmount: 500.0, month: Date())
        budget.category = category
        self.modelContext.insert(budget)

        // No transactions needed for zero spending

        // Create a refund transaction (negative expense = income)
        let refundTransaction = FinancialTransaction(
            title: "Grocery Refund",
            amount: 50.0,
            date: Date(),
            transactionType: .income // Refunds are income
        )
        refundTransaction.category = category
        self.modelContext.insert(refundTransaction)
        let budgets = [budget]

        // When: Calculating remaining budget
        let remaining = self.viewModel.remainingBudget(budgets, for: Date())

        // Then: Should handle negative spending correctly
        XCTAssertEqual(remaining, 550.0) // 500 + 50 refund
    }

    // MARK: - Budget Rollover Tests

    func testBudgetsViewModelApplyRolloverToNextPeriod() throws {
        // Given: Budget with rollover enabled
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let currentMonth = Date()
        let budget = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        budget.category = category
        budget.rolloverEnabled = true
        budget.maxRolloverPercentage = 50.0 // Max 50% of remaining
        self.modelContext.insert(budget)

        // Create transaction to simulate spending (300 spent, 200 remaining)
        let transaction = FinancialTransaction(
            title: "Monthly Food Expenses",
            amount: 300.0,
            date: currentMonth,
            transactionType: .expense
        )
        transaction.category = category
        self.modelContext.insert(transaction)

        // When: Applying rollover to next period
        self.viewModel.applyRolloverToNextPeriod(for: budget)

        // Then: Next period budget should be created with rollover amount
        let descriptor = FetchDescriptor<Budget>()
        let allBudgets = try modelContext.fetch(descriptor)
        XCTAssertEqual(allBudgets.count, 2) // Original + next period

        let nextPeriodBudgets = allBudgets.filter { $0.id != budget.id }
        XCTAssertEqual(nextPeriodBudgets.count, 1)

        let nextBudget = nextPeriodBudgets[0]
        XCTAssertEqual(nextBudget.limitAmount, 500.0) // Same as original budget
        XCTAssertEqual(nextBudget.rolledOverAmount, 200.0) // min(200 remaining, 250 max rollover)
        XCTAssertEqual(nextBudget.effectiveLimit, 700.0) // 500 + 200 rollover
    }

    func testBudgetsViewModelGetRolloverSummary() throws {
        // Given: Budget with rollover settings
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let budget = Budget(name: "Food Budget", limitAmount: 500.0, month: Date())
        budget.category = category
        budget.rolloverEnabled = true
        budget.maxRolloverPercentage = 50.0
        budget.rolledOverAmount = 50.0
        self.modelContext.insert(budget)

        // Create transaction to simulate spending
        let transaction = FinancialTransaction(
            title: "Food Spending",
            amount: 300.0,
            date: Date(),
            transactionType: .expense
        )
        transaction.category = category
        self.modelContext.insert(transaction)

        // When: Getting rollover summary
        let summary = self.viewModel.getRolloverSummary(for: budget)

        // Then: Summary should contain correct information
        XCTAssertEqual(summary.unusedAmount, 200.0)
        XCTAssertEqual(summary.potentialRollover, 200.0) // min(200 remaining, 250 max rollover)
        XCTAssertTrue(summary.rolloverEnabled)
        XCTAssertEqual(summary.maxRolloverPercentage, 50.0)
        XCTAssertEqual(summary.currentRolloverAmount, 50.0)
    }

    // MARK: - Spending Trend Tests

    func testBudgetsViewModelSpendingTrend() throws {
        // Given: Category with spending history
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        // When: Getting spending trend for 3 months
        let trend = self.viewModel.spendingTrend(for: category, months: 3)

        // Then: Should return trend data (may be empty if no transactions)
        XCTAssertEqual(trend.count, 3)
        XCTAssertEqual(trend[0].categoryName, "Food")
    }

    // MARK: - Budget Filtering Tests

    func testBudgetsViewModelBudgetsForMonth() throws {
        // Given: Budgets for different months
        let category = ExpenseCategory(name: "Food", iconName: "fork.knife")
        self.modelContext.insert(category)

        let calendar = Calendar.current
        let currentMonth = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!

        let currentBudget = Budget(name: "Current Food", limitAmount: 500.0, month: currentMonth)
        currentBudget.category = category

        let lastMonthBudget = Budget(name: "Last Month Food", limitAmount: 400.0, month: lastMonth)
        lastMonthBudget.category = category

        let budgets = [currentBudget, lastMonthBudget]

        // When: Filtering budgets for current month
        let currentMonthBudgets = self.viewModel.budgetsForMonth(budgets, month: currentMonth)

        // Then: Should return only current month budgets
        XCTAssertEqual(currentMonthBudgets.count, 1)
        XCTAssertEqual(currentMonthBudgets[0].name, "Current Food")
    }

    func testBudgetsViewModelOverBudgetCategories() throws {
        // Given: Mix of over-budget and on-budget categories
        let foodCategory = ExpenseCategory(name: "Food", iconName: "fork.knife")
        let transportCategory = ExpenseCategory(name: "Transport", iconName: "car")
        self.modelContext.insert(foodCategory)
        self.modelContext.insert(transportCategory)

        let currentMonth = Date()

        let overBudget = Budget(name: "Food Budget", limitAmount: 500.0, month: currentMonth)
        overBudget.category = foodCategory
        self.modelContext.insert(overBudget)

        // Create over-budget transaction
        let overBudgetTransaction = FinancialTransaction(
            title: "Expensive Purchase",
            amount: 600.0,
            date: currentMonth,
            transactionType: .expense
        )
        overBudgetTransaction.category = foodCategory
        self.modelContext.insert(overBudgetTransaction)

        let onBudget = Budget(name: "Transport Budget", limitAmount: 300.0, month: currentMonth)
        onBudget.category = transportCategory
        self.modelContext.insert(onBudget)

        // Create on-budget transaction
        let onBudgetTransaction = FinancialTransaction(
            title: "Gas",
            amount: 200.0,
            date: currentMonth,
            transactionType: .expense
        )
        onBudgetTransaction.category = transportCategory
        self.modelContext.insert(onBudgetTransaction)

        let budgets = [overBudget, onBudget]

        // When: Getting over-budget categories
        let overBudgetCategories = self.viewModel.overBudgetCategories(budgets, for: currentMonth)

        // Then: Should return only over-budget categories
        XCTAssertEqual(overBudgetCategories.count, 1)
        XCTAssertEqual(overBudgetCategories[0].name, "Food Budget")
    }
}
