import Foundation

// MARK: - Edge Cases and Validation Tests

func runValidationTests() {
    runTest("testEmptyTransactionTitle") {
        let transaction = FinancialTransaction(
            title: "",
            amount: 50.0,
            date: Date(),
            transactionType: .expense
        )

        assert(transaction.title.isEmpty)
        assert(transaction.amount == 50.0)
    }

    runTest("testZeroAmountTransaction") {
        let transaction = FinancialTransaction(
            title: "Free Item",
            amount: 0.0,
            date: Date(),
            transactionType: .expense
        )

        assert(transaction.amount == 0.0)
        assert(transaction.formattedAmount.contains("$0.00"))
    }

    runTest("testNegativeAmountTransaction") {
        let transaction = FinancialTransaction(
            title: "Refund",
            amount: -25.0,
            date: Date(),
            transactionType: .income
        )

        assert(transaction.amount == -25.0)
        assert(transaction.formattedAmount.contains("-$25.00"))
    }

    runTest("testVeryLargeAmount") {
        let transaction = FinancialTransaction(
            title: "Lottery Win",
            amount: 1_000_000.0,
            date: Date(),
            transactionType: .income
        )

        assert(transaction.amount == 1_000_000.0)
        assert(transaction.formattedAmount.contains("$1,000,000.00"))
    }

    runTest("testFutureDateTransaction") {
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let transaction = FinancialTransaction(
            title: "Future Expense",
            amount: 100.0,
            date: futureDate,
            transactionType: .expense
        )

        assert(transaction.date > Date())
    }

    runTest("testPastDateTransaction") {
        let pastDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let transaction = FinancialTransaction(
            title: "Old Transaction",
            amount: 50.0,
            date: pastDate,
            transactionType: .expense
        )

        assert(transaction.date < Date())
    }

    runTest("testAccountWithNoTransactions") {
        let account = FinancialAccount(
            name: "Empty Account",
            type: .checking,
            balance: 0.0,
            transactions: []
        )

        assert(account.transactions.isEmpty)
        assert(account.balance == 0.0)
    }

    runTest("testCategoryWithNoTransactions") {
        let category = ExpenseCategory(
            name: "Empty Category",
            color: "#FF0000",
            transactions: []
        )

        assert(category.transactions.isEmpty)
        assert(category.totalAmount == 0.0)
    }
}
