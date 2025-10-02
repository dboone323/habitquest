import Foundation

// MARK: - Integration Tests

func runIntegrationTests() {
    runTest("testAccountTransactionIntegration") {
        let transaction1 = FinancialTransaction(
            title: "Salary",
            amount: 3000.0,
            date: Date(),
            transactionType: .income
        )
        let transaction2 = FinancialTransaction(
            title: "Rent",
            amount: 1200.0,
            date: Date(),
            transactionType: .expense
        )
        let transaction3 = FinancialTransaction(
            title: "Groceries",
            amount: 300.0,
            date: Date(),
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
            date: Date(),
            transactionType: .expense
        )
        let transaction2 = FinancialTransaction(
            title: "Coffee Shop",
            amount: 25.0,
            date: Date(),
            transactionType: .expense
        )

        let category = ExpenseCategory(
            name: "Food & Dining",
            color: "#FF6B6B",
            transactions: [transaction1, transaction2]
        )

        assert(category.transactions.count == 2)
        assert(category.totalAmount == 75.0)
    }

    runTest("testMultiAccountBalanceCalculation") {
        let checkingAccount = FinancialAccount(
            name: "Checking",
            type: .checking,
            balance: 500.0,
            transactions: [
                FinancialTransaction(title: "Deposit", amount: 1000.0, date: Date(), transactionType: .income),
                FinancialTransaction(title: "ATM", amount: 200.0, date: Date(), transactionType: .expense)
            ]
        )

        let savingsAccount = FinancialAccount(
            name: "Savings",
            type: .savings,
            balance: 2000.0,
            transactions: [
                FinancialTransaction(title: "Interest", amount: 50.0, date: Date(), transactionType: .income)
            ]
        )

        let totalBalance = checkingAccount.calculatedBalance + savingsAccount.calculatedBalance
        assert(totalBalance == 1300.0 + 2050.0)
        assert(totalBalance == 3350.0)
    }

    runTest("testTransactionCategoryGrouping") {
        let foodCategory = ExpenseCategory(
            name: "Food",
            color: "#FF6B6B",
            transactions: [
                FinancialTransaction(title: "Groceries", amount: 100.0, date: Date(), transactionType: .expense),
                FinancialTransaction(title: "Restaurant", amount: 50.0, date: Date(), transactionType: .expense)
            ]
        )

        let transportCategory = ExpenseCategory(
            name: "Transportation",
            color: "#4ECDC4",
            transactions: [
                FinancialTransaction(title: "Gas", amount: 60.0, date: Date(), transactionType: .expense),
                FinancialTransaction(title: "Bus Pass", amount: 40.0, date: Date(), transactionType: .expense)
            ]
        )

        let categories = [foodCategory, transportCategory]
        let totalExpenses = categories.map(\.totalAmount).reduce(0, +)

        assert(totalExpenses == 250.0)
        assert(foodCategory.totalAmount == 150.0)
        assert(transportCategory.totalAmount == 100.0)
    }
}
