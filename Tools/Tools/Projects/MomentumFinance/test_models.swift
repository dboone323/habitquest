// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

// Test compilation of models
/// <#Description#>
/// - Returns: <#description#>
func testModels() {
    let account = FinancialAccount(name: "Test", accountType: .checking, balance: 100.0)
    let transaction = FinancialTransaction(
        title: "Test Transaction",
        amount: 50.0,
        date: Date(),
        transactionType: .expense,
    )
    let category = Category(name: "Test Category", color: "blue", icon: "star")
    let subscription = Subscription(
        name: "Test Sub",
        amount: 10.0,
        frequency: .monthly,
        nextDueDate: Date(),
    )
    let budget = Budget(
        category: category,
        monthlyLimit: 200.0,
        month: Date(),
    )
    let goal = SavingsGoal(
        name: "Test Goal",
        targetAmount: 1000.0,
        currentAmount: 0.0,
        targetDate: Date(),
    )
}
