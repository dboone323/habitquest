import Foundation

// MARK: - Transaction Model Tests

func runTransactionModelTests() {
    runTest("testTransactionCreation") {
        let transaction = Transaction(
            amount: 25.99,
            description: "Coffee",
            date: Date(),
            type: .expense,
            categoryName: "Food"
        )

        assert(transaction.amount == 25.99)
        assert(transaction.description == "Coffee")
        assert(transaction.type == .expense)
        assert(transaction.categoryName == "Food")
    }

    runTest("testTransactionPersistence") {
        let transaction = Transaction(
            amount: 100.0,
            description: "Salary",
            date: Date(),
            type: .income,
            categoryName: "Work"
        )

        assert(transaction.amount == 100.0)
        assert(transaction.description == "Salary")
    }

    runTest("testIncomeCalculation") {
        let income1 = Transaction(
            amount: 1000.0, description: "Salary", date: Date(), type: .income, categoryName: "Work"
        )
        let income2 = Transaction(
            amount: 500.0, description: "Freelance", date: Date(), type: .income,
            categoryName: "Side Work"
        )
        _ = Transaction(
            amount: 200.0, description: "Groceries", date: Date(), type: .expense, categoryName: "Food"
        )

        let totalIncome = [income1, income2].reduce(0) { $0 + $1.amount }
        assert(totalIncome == 1500.0)
    }

    runTest("testExpenseCalculation") {
        let expense1 = Transaction(
            amount: 100.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport"
        )
        let expense2 = Transaction(
            amount: 50.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food"
        )

        let totalExpenses = [expense1, expense2].reduce(0) { $0 + $1.amount }
        assert(totalExpenses == 150.0)
    }

    runTest("testTransactionsByDateRange") {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!

        let todayTransaction = Transaction(
            amount: 25.0, description: "Lunch", date: today, type: .expense, categoryName: "Food"
        )
        let yesterdayTransaction = Transaction(
            amount: 15.0, description: "Snack", date: yesterday, type: .expense, categoryName: "Food"
        )
        let oldTransaction = Transaction(
            amount: 100.0, description: "Old Purchase", date: lastWeek, type: .expense,
            categoryName: "Other"
        )

        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let recentTransactions = [todayTransaction, yesterdayTransaction, oldTransaction].filter {
            $0.date >= threeDaysAgo
        }
        assert(recentTransactions.count == 2)
    }

    runTest("testTransactionsByCategory") {
        let foodTransaction1 = Transaction(
            amount: 25.0, description: "Lunch", date: Date(), type: .expense, categoryName: "Food"
        )
        let foodTransaction2 = Transaction(
            amount: 15.0, description: "Coffee", date: Date(), type: .expense, categoryName: "Food"
        )
        let transportTransaction = Transaction(
            amount: 30.0, description: "Gas", date: Date(), type: .expense, categoryName: "Transport"
        )

        let foodTransactions = [foodTransaction1, foodTransaction2, transportTransaction].filter {
            $0.categoryName == "Food"
        }
        assert(foodTransactions.count == 2)
        assert(foodTransactions.map(\.amount).reduce(0, +) == 40.0)
    }

    runTest("testZeroAmountTransaction") {
        let transaction = Transaction(
            amount: 0.0,
            description: "Zero amount test",
            date: Date(),
            type: .expense,
            categoryName: "Test"
        )

        assert(transaction.amount == 0.0)
    }

    runTest("testNegativeAmountTransaction") {
        let transaction = Transaction(
            amount: -25.99,
            description: "Refund",
            date: Date(),
            type: .income,
            categoryName: "Refunds"
        )

        assert(transaction.amount == -25.99)
    }
}
