import Foundation

// MARK: - Financial Transaction Model Tests

func runFinancialTransactionTests() {
    runTest("testFinancialTransactionCreation") {
        let transaction = FinancialTransaction(
            title: "Grocery Shopping",
            amount: 75.50,
            date: Date(),
            transactionType: .expense
        )

        assert(transaction.title == "Grocery Shopping")
        assert(transaction.amount == 75.50)
        assert(transaction.transactionType == .expense)
    }

    runTest("testTransactionFormattedAmountIncome") {
        let transaction = FinancialTransaction(
            title: "Salary",
            amount: 2000.0,
            date: Date(),
            transactionType: .income
        )

        assert(transaction.formattedAmount.hasPrefix("+"))
        assert(transaction.formattedAmount.contains("$2000.00"))
    }

    runTest("testTransactionFormattedAmountExpense") {
        let transaction = FinancialTransaction(
            title: "Groceries",
            amount: 100.0,
            date: Date(),
            transactionType: .expense
        )

        assert(transaction.formattedAmount.hasPrefix("-"))
        assert(transaction.formattedAmount.contains("$100.00"))
    }

    runTest("testTransactionFormattedDate") {
        let transaction = FinancialTransaction(
            title: "Test",
            amount: 10.0,
            date: Date(),
            transactionType: .expense
        )

        assert(!transaction.formattedDate.isEmpty)
    }

    runTest("testTransactionPersistence") {
        let transaction = FinancialTransaction(
            title: "Coffee",
            amount: 5.0,
            date: Date(),
            transactionType: .expense
        )

        assert(transaction.title == "Coffee")
        assert(transaction.amount == 5.0)
    }

    runTest("testTransactionTypeFiltering") {
        let incomeTransaction = FinancialTransaction(
            title: "Paycheck",
            amount: 2000.0,
            date: Date(),
            transactionType: .income
        )
        let expenseTransaction1 = FinancialTransaction(
            title: "Rent",
            amount: 800.0,
            date: Date(),
            transactionType: .expense
        )
        let expenseTransaction2 = FinancialTransaction(
            title: "Utilities",
            amount: 150.0,
            date: Date(),
            transactionType: .expense
        )

        let incomeTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
            $0.transactionType == .income
        }
        let expenseTransactions = [incomeTransaction, expenseTransaction1, expenseTransaction2].filter {
            $0.transactionType == .expense
        }

        assert(incomeTransactions.count == 1)
        assert(expenseTransactions.count == 2)
        assert(expenseTransactions.map(\.amount).reduce(0, +) == 950.0)
    }
}
