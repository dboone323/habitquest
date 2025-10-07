import Foundation

// MARK: - Performance Tests

func runPerformanceTests() {
    runTest("testTransactionCreationPerformance") {
        let startTime = Date()

        for i in 0 ..< 1000 {
            _ = FinancialTransaction(
                title: "Performance Test Transaction \(i)",
                amount: Double(i),
                date: Date(),
                transactionType: i % 2 == 0 ? .income : .expense
            )
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        assert(duration < 1.0, "Transaction creation should be fast")
        print("Transaction creation performance: \(duration) seconds for 1000 transactions")
    }

    runTest("testAccountBalanceCalculationPerformance") {
        var transactions: [FinancialTransaction] = []

        for i in 0 ..< 10000 {
            transactions.append(FinancialTransaction(
                title: "Transaction \(i)",
                amount: Double(i % 100),
                date: Date(),
                transactionType: i % 3 == 0 ? .income : .expense
            ))
        }

        let account = FinancialAccount(
            name: "Performance Test Account",
            type: .checking,
            balance: 0.0,
            transactions: transactions
        )

        let startTime = Date()
        let calculatedBalance = account.calculatedBalance
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        assert(duration < 0.1, "Balance calculation should be very fast")
        assert(calculatedBalance >= 0.0)
        print("Balance calculation performance: \(duration) seconds for \(transactions.count) transactions")
    }

    runTest("testCategoryTotalCalculationPerformance") {
        var transactions: [FinancialTransaction] = []

        for i in 0 ..< 5000 {
            transactions.append(FinancialTransaction(
                title: "Category Transaction \(i)",
                amount: Double(i % 50),
                date: Date(),
                transactionType: .expense
            ))
        }

        let category = ExpenseCategory(
            name: "Performance Test Category",
            color: "#FF0000",
            transactions: transactions
        )

        let startTime = Date()
        let totalAmount = category.totalAmount
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        assert(duration < 0.05, "Category total calculation should be very fast")
        assert(totalAmount >= 0.0)
        print("Category total calculation performance: \(duration) seconds for \(transactions.count) transactions")
    }

    runTest("testTransactionFilteringPerformance") {
        var transactions: [FinancialTransaction] = []

        for i in 0 ..< 10000 {
            transactions.append(FinancialTransaction(
                title: "Filter Test \(i)",
                amount: Double(i),
                date: Date(),
                transactionType: i % 2 == 0 ? .income : .expense
            ))
        }

        let startTime = Date()
        let expenseTransactions = transactions.filter { $0.transactionType == .expense }
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        assert(duration < 0.1, "Transaction filtering should be fast")
        assert(expenseTransactions.count > 0)
        print("Transaction filtering performance: \(duration) seconds for \(transactions.count) transactions")
    }

    runTest("testMemoryUsageWithLargeDataset") {
        var transactions: [FinancialTransaction] = []

        for i in 0 ..< 50000 {
            transactions.append(FinancialTransaction(
                title: "Memory Test Transaction \(i)",
                amount: Double(i % 1000),
                date: Date(),
                transactionType: .expense
            ))
        }

        let account = FinancialAccount(
            name: "Memory Test Account",
            type: .savings,
            balance: 10000.0,
            transactions: transactions
        )

        assert(account.transactions.count == 50000)
        assert(account.calculatedBalance >= 0.0)
        print("Successfully handled \(transactions.count) transactions in memory")
    }
}
