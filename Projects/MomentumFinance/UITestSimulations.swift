import Foundation

// MARK: - UI Test Simulations

func runUITestSimulations() {
    runTest("testTransactionListDisplaySimulation") {
        let transactions = [
            FinancialTransaction(title: "Salary", amount: 3000.0, date: Date(), transactionType: .income),
            FinancialTransaction(title: "Rent", amount: 1200.0, date: Date(), transactionType: .expense),
            FinancialTransaction(title: "Groceries", amount: 150.0, date: Date(), transactionType: .expense),
            FinancialTransaction(title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense),
            FinancialTransaction(title: "Freelance", amount: 500.0, date: Date(), transactionType: .income)
        ]

        // Simulate UI display logic
        let displayItems = transactions.map { transaction in
            [
                "title": transaction.title,
                "amount": transaction.formattedAmount,
                "date": transaction.formattedDate,
                "type": transaction.transactionType.rawValue
            ]
        }

        assert(displayItems.count == 5)
        assert(displayItems[0]["title"] == "Salary")
        assert(displayItems[0]["amount"]!.hasPrefix("+"))
        assert(displayItems[1]["amount"]!.hasPrefix("-"))
    }

    runTest("testAccountSummaryDisplaySimulation") {
        let account = FinancialAccount(
            name: "Main Checking",
            type: .checking,
            balance: 2500.0,
            transactions: [
                FinancialTransaction(title: "Deposit", amount: 1000.0, date: Date(), transactionType: .income),
                FinancialTransaction(title: "ATM", amount: 200.0, date: Date(), transactionType: .expense),
                FinancialTransaction(title: "Paycheck", amount: 2000.0, date: Date(), transactionType: .income),
                FinancialTransaction(title: "Utilities", amount: 300.0, date: Date(), transactionType: .expense)
            ]
        )

        // Simulate account summary UI
        let summary = [
            "accountName": account.name,
            "accountType": account.type.rawValue,
            "currentBalance": String(format: "$%.2f", account.calculatedBalance),
            "transactionCount": String(account.transactions.count),
            "lastTransaction": account.transactions.last?.title ?? "None"
        ]

        assert(summary["accountName"] == "Main Checking")
        assert(summary["currentBalance"] == "$3300.00")
        assert(summary["transactionCount"] == "4")
    }

    runTest("testCategoryBudgetDisplaySimulation") {
        let categories = [
            ExpenseCategory(name: "Food", color: "#FF6B6B", transactions: [
                FinancialTransaction(title: "Groceries", amount: 200.0, date: Date(), transactionType: .expense),
                FinancialTransaction(title: "Restaurant", amount: 100.0, date: Date(), transactionType: .expense)
            ]),
            ExpenseCategory(name: "Transportation", color: "#4ECDC4", transactions: [
                FinancialTransaction(title: "Gas", amount: 150.0, date: Date(), transactionType: .expense),
                FinancialTransaction(title: "Bus Pass", amount: 50.0, date: Date(), transactionType: .expense)
            ])
        ]

        // Simulate category budget display
        let categorySummaries = categories.map { category in
            [
                "name": category.name,
                "totalSpent": String(format: "$%.2f", category.totalAmount),
                "transactionCount": String(category.transactions.count),
                "color": category.color
            ]
        }

        assert(categorySummaries.count == 2)
        assert(categorySummaries[0]["name"] == "Food")
        assert(categorySummaries[0]["totalSpent"] == "$300.00")
        assert(categorySummaries[1]["name"] == "Transportation")
        assert(categorySummaries[1]["totalSpent"] == "$200.00")
    }

    runTest("testTransactionFilterSimulation") {
        let allTransactions = [
            FinancialTransaction(title: "Salary", amount: 3000.0, date: Date(), transactionType: .income),
            FinancialTransaction(title: "Rent", amount: 1200.0, date: Date(), transactionType: .expense),
            FinancialTransaction(title: "Bonus", amount: 500.0, date: Date(), transactionType: .income),
            FinancialTransaction(title: "Groceries", amount: 150.0, date: Date(), transactionType: .expense),
            FinancialTransaction(title: "Coffee", amount: 5.0, date: Date(), transactionType: .expense)
        ]

        // Simulate filtering by type
        let incomeTransactions = allTransactions.filter { $0.transactionType == .income }
        let expenseTransactions = allTransactions.filter { $0.transactionType == .expense }

        // Simulate filtering by amount range
        let smallTransactions = allTransactions.filter { $0.amount < 100 }
        let largeTransactions = allTransactions.filter { $0.amount >= 1000 }

        assert(incomeTransactions.count == 2)
        assert(expenseTransactions.count == 3)
        assert(smallTransactions.count == 1) // Coffee
        assert(largeTransactions.count == 2) // Salary and Rent
    }

    runTest("testDashboardSummarySimulation") {
        let accounts = [
            FinancialAccount(name: "Checking", type: .checking, balance: 1500.0, transactions: []),
            FinancialAccount(name: "Savings", type: .savings, balance: 5000.0, transactions: []),
            FinancialAccount(name: "Credit Card", type: .credit, balance: -500.0, transactions: [])
        ]

        let categories = [
            ExpenseCategory(name: "Food", color: "#FF6B6B", transactions: [
                FinancialTransaction(title: "Test", amount: 100.0, date: Date(), transactionType: .expense)
            ]),
            ExpenseCategory(name: "Transport", color: "#4ECDC4", transactions: [
                FinancialTransaction(title: "Test", amount: 50.0, date: Date(), transactionType: .expense)
            ])
        ]

        // Simulate dashboard calculations
        let totalBalance = accounts.map(\.calculatedBalance).reduce(0, +)
        let totalExpenses = categories.map(\.totalAmount).reduce(0, +)
        let accountCount = accounts.count
        let categoryCount = categories.count

        assert(totalBalance == 6000.0)
        assert(totalExpenses == 150.0)
        assert(accountCount == 3)
        assert(categoryCount == 2)
    }
}
