import Foundation

// MARK: - Integration Tests

func runIntegrationTests() {
    // Use fixed date for deterministic tests
    let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
    runTest("testAccountTransactionIntegration") {
        let transaction1 = FinancialTransaction(
            title: "Salary",
            amount: 3000.0,
            date: testDate,
            transactionType: .income
        )
        let transaction2 = FinancialTransaction(
            title: "Rent",
            amount: 1200.0,
            date: testDate,
            transactionType: .expense
        )
        let transaction3 = FinancialTransaction(
            title: "Groceries",
            amount: 300.0,
            date: testDate,
            transactionType: .expense
        )

        let account = FinancialAccount(
            name: "Integration Test Account",
            type: .checking,
            balance: 1000.0,
            transactions: [transaction1, transaction2, transaction3]
        )

        assert(account.transactions.count == 3)
        assert(account.calculatedBalance == 1000.0 + 3000.0 - 1200.0 - 300.0)
        assert(account.calculatedBalance == 2500.0)
    }

    runTest("testCategoryTransactionIntegration") {
        let transaction1 = FinancialTransaction(
            title: "Restaurant",
            amount: 50.0,
            date: testDate,
            transactionType: .expense
        )
        let transaction2 = FinancialTransaction(
            title: "Coffee Shop",
            amount: 25.0,
            date: testDate,
            transactionType: .expense
        )

        // Use TransactionCategory instead of ExpenseCategory for consistency
        let category = TransactionCategory(
            name: "Food & Dining",
            transactions: [transaction1, transaction2]
        )

        assert(category.transactions.count == 2)
        assert(category.totalExpenses == 75.0)
    }

    runTest("testMultiAccountBalanceCalculation") {
        let checkingAccount = FinancialAccount(
            name: "Checking",
            type: .checking,
            balance: 500.0,
            transactions: [
                FinancialTransaction(title: "Deposit", amount: 1000.0, date: testDate, transactionType: .income),
                FinancialTransaction(title: "ATM", amount: 200.0, date: testDate, transactionType: .expense)
            ]
        )

        let savingsAccount = FinancialAccount(
            name: "Savings",
            type: .savings,
            balance: 2000.0,
            transactions: [
                FinancialTransaction(title: "Interest", amount: 50.0, date: testDate, transactionType: .income)
            ]
        )

        let totalBalance = checkingAccount.calculatedBalance + savingsAccount.calculatedBalance
        assert(totalBalance == 1300.0 + 2050.0)
        assert(totalBalance == 3350.0)
    }

    runTest("testTransactionCategoryGrouping") {
        let foodCategory = TransactionCategory(
            name: "Food",
            transactions: [
                FinancialTransaction(title: "Groceries", amount: 100.0, date: testDate, transactionType: .expense),
                FinancialTransaction(title: "Restaurant", amount: 50.0, date: testDate, transactionType: .expense)
            ]
        )

        let transportCategory = TransactionCategory(
            name: "Transportation",
            transactions: [
                FinancialTransaction(title: "Gas", amount: 60.0, date: testDate, transactionType: .expense),
                FinancialTransaction(title: "Bus Pass", amount: 40.0, date: testDate, transactionType: .expense)
            ]
        )

        let categories = [foodCategory, transportCategory]
        let totalExpenses = categories.map(\.totalExpenses).reduce(0, +)

        assert(totalExpenses == 250.0)
        assert(foodCategory.totalExpenses == 150.0)
        assert(transportCategory.totalExpenses == 100.0)
    }
}
