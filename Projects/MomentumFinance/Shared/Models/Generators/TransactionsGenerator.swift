import Foundation
import SwiftData

/// Transactions data generator
@MainActor
final class TransactionsGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generates sample transactions for the past few months
    func generate() {
        guard let categories = try? modelContext.fetch(FetchDescriptor<ExpenseCategory>()),
              let accounts = try? modelContext.fetch(FetchDescriptor<FinancialAccount>())
        else {
            return
        }

        let categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0) })
        let accountDict = Dictionary(uniqueKeysWithValues: accounts.map { ($0.name, $0) })

        let calendar = Calendar.current
        let now = Date()

        // Generate transactions for the past 3 months
        for monthOffset in 0 ..< 3 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }

            let transactions = self.generateTransactionsForMonth(monthDate, categories: categoryDict, accounts: accountDict)
            for transaction in transactions {
                self.modelContext.insert(transaction)
            }
        }

        try? self.modelContext.save()
    }

    private func generateTransactionsForMonth(
        _ month: Date,
        categories: [String: ExpenseCategory],
        accounts: [String: FinancialAccount]
    ) -> [FinancialTransaction] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components),
              let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count
        else {
            return []
        }

        var transactions: [FinancialTransaction] = []

        // Income transactions (salary, etc.)
        if let incomeCategory = categories["Income"],
           let checkingAccount = accounts["Checking Account"] {
            for week in 0 ..< 4 {
                let payDate = calendar.date(byAdding: .day, value: week * 7 + 1, to: startOfMonth) ?? startOfMonth
                let income = FinancialTransaction(
                    title: "Salary Deposit",
                    amount: 3200.0,
                    date: payDate,
                    transactionType: .income,
                    notes: "Bi-weekly salary"
                )
                income.category = incomeCategory
                income.account = checkingAccount
                transactions.append(income)
            }
        }

        // Expense transactions
        let expenseData = [
            ("Grocery Store", 85.50, "Food & Dining"),
            ("Gas Station", 45.20, "Transportation"),
            ("Electric Bill", 120.00, "Utilities"),
            ("Netflix", 15.99, "Entertainment"),
            ("Coffee Shop", 12.50, "Food & Dining"),
            ("Pharmacy", 67.80, "Health & Fitness"),
            ("Amazon", 89.99, "Shopping"),
            ("Uber", 18.50, "Transportation"),
            ("Gym Membership", 49.99, "Health & Fitness"),
            ("Restaurant", 65.30, "Food & Dining"),
            ("Internet Bill", 79.99, "Utilities"),
            ("Movie Theater", 28.00, "Entertainment"),
            ("Hardware Store", 156.75, "Shopping"),
            ("Car Insurance", 145.00, "Transportation"),
            ("Doctor Visit", 120.00, "Health & Fitness"),
        ]

        for (title, amount, categoryName) in expenseData {
            if let category = categories[categoryName],
               let account = accounts["Checking Account"] ?? accounts.values.first {
                let randomDay = Int.random(in: 1 ... daysInMonth)
                let transactionDate = calendar.date(byAdding: .day, value: randomDay - 1, to: startOfMonth) ?? startOfMonth

                let transaction = FinancialTransaction(
                    title: title,
                    amount: amount,
                    date: transactionDate,
                    transactionType: .expense,
                    notes: nil
                )
                transaction.category = category
                transaction.account = account
                transactions.append(transaction)
            }
        }

        return transactions
    }
}
