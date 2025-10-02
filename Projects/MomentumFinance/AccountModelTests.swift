import Foundation

// MARK: - Financial Account Model Tests

func runAccountModelTests() {
    runTest("testAccountCreation") {
        let account = FinancialAccount(
            name: "Checking",
            balance: 1000.0,
            iconName: "bank",
            accountType: .checking
        )

        assert(account.name == "Checking")
        assert(account.balance == 1000.0)
        assert(account.accountType == .checking)
    }

    runTest("testAccountPersistence") {
        let account = FinancialAccount(
            name: "Savings",
            balance: 5000.0,
            iconName: "piggy",
            accountType: .savings
        )

        assert(account.name == "Savings")
        assert(account.balance == 5000.0)
    }

    runTest("testUpdateBalanceForIncomeTransaction") {
        var account = FinancialAccount(
            name: "Main",
            balance: 100.0,
            iconName: "wallet",
            accountType: .checking
        )

        let transaction = FinancialTransaction(
            title: "Paycheck",
            amount: 500.0,
            date: Date(),
            transactionType: .income
        )

        account.updateBalance(for: transaction)
        assert(account.balance == 600.0)
    }

    runTest("testUpdateBalanceForExpenseTransaction") {
        var account = FinancialAccount(
            name: "Main",
            balance: 100.0,
            iconName: "wallet",
            accountType: .checking
        )

        let transaction = FinancialTransaction(
            title: "Groceries",
            amount: 40.0,
            date: Date(),
            transactionType: .expense
        )

        account.updateBalance(for: transaction)
        assert(account.balance == 60.0)
    }

    runTest("testAccountWithCreditLimit") {
        let account = FinancialAccount(
            name: "Credit Card",
            balance: -200.0,
            iconName: "creditcard",
            accountType: .credit,
            creditLimit: 1000.0
        )

        assert(account.creditLimit == 1000.0)
        assert(account.accountType == .credit)
    }

    runTest("testAccountBalanceCalculations") {
        var account = FinancialAccount(
            name: "Test Account",
            balance: 1000.0,
            iconName: "test",
            accountType: .checking
        )

        let transactions = [
            FinancialTransaction(
                title: "Income", amount: 500.0, date: Date(), transactionType: .income
            ),
            FinancialTransaction(
                title: "Expense 1", amount: 100.0, date: Date(), transactionType: .expense
            ),
            FinancialTransaction(
                title: "Expense 2", amount: 50.0, date: Date(), transactionType: .expense
            ),
        ]

        for transaction in transactions {
            account.updateBalance(for: transaction)
        }

        assert(account.balance == 1350.0)
    }
}
