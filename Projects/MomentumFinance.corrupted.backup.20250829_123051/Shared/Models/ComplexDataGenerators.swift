// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

/// Transactions data generator
@MainActor
class TransactionsDataGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        guard let categories = try? modelContext.fetch(FetchDescriptor<ExpenseCategory>()) else { return }
        guard let accounts = try? modelContext.fetch(FetchDescriptor<FinancialAccount>()) else { return }

        var categoryDict: [String: ExpenseCategory] = [:]
        for category in categories {
            categoryDict[category.name] = category
        }

        let checkingAccount = accounts.first { $0.name == "Checking Account" }
        let savingsAccount = accounts.first { $0.name == "Savings Account" }
        let creditCard = accounts.first { $0.name == "Credit Card" }

        // Sample transactions
        let transactions = [
            // Income transactions
<<<<<<< HEAD
            (title: "Salary", amount: 3_500.0, date: Date().addingTimeInterval(-86_400 * 15),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Freelance Work", amount: 500.0, date: Date().addingTimeInterval(-86_400 * 8),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Interest", amount: 25.0, date: Date().addingTimeInterval(-86_400 * 3),
             type: TransactionType.income, category: "Income", account: savingsAccount),

            // Expense transactions
            (title: "Rent", amount: 1_200.0, date: Date().addingTimeInterval(-86_400 * 28),
             type: TransactionType.expense, category: "Housing", account: checkingAccount),
            (title: "Groceries", amount: 120.50, date: Date().addingTimeInterval(-86_400 * 25),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Electricity Bill", amount: 85.0, date: Date().addingTimeInterval(-86_400 * 20),
             type: TransactionType.expense, category: "Utilities", account: checkingAccount),
            (title: "Internet", amount: 60.0, date: Date().addingTimeInterval(-86_400 * 18),
             type: TransactionType.expense, category: "Utilities", account: creditCard),
            (title: "Gas", amount: 45.0, date: Date().addingTimeInterval(-86_400 * 15),
             type: TransactionType.expense, category: "Transportation", account: creditCard),
            (title: "Dinner", amount: 65.75, date: Date().addingTimeInterval(-86_400 * 12),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Movie Tickets", amount: 30.0, date: Date().addingTimeInterval(-86_400 * 10),
             type: TransactionType.expense, category: "Entertainment", account: creditCard),
            (title: "Coffee", amount: 4.50, date: Date().addingTimeInterval(-86_400 * 7),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Gym Membership", amount: 50.0, date: Date().addingTimeInterval(-86_400 * 5),
             type: TransactionType.expense, category: "Personal Care", account: checkingAccount),
            (title: "Online Course", amount: 200.0, date: Date().addingTimeInterval(-86_400 * 2),
             type: TransactionType.expense, category: "Education", account: creditCard),

            // Previous month transactions
            (title: "Salary", amount: 3_500.0, date: Date().addingTimeInterval(-86_400 * 45),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Rent", amount: 1_200.0, date: Date().addingTimeInterval(-86_400 * 58),
             type: TransactionType.expense, category: "Housing", account: checkingAccount),
            (title: "Groceries", amount: 160.30, date: Date().addingTimeInterval(-86_400 * 50),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Travel", amount: 500.0, date: Date().addingTimeInterval(-86_400 * 40),
             type: TransactionType.expense, category: "Travel", account: creditCard)
=======
            (title: "Salary", amount: 3500.0, date: Date().addingTimeInterval(-86400 * 15),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Freelance Work", amount: 500.0, date: Date().addingTimeInterval(-86400 * 8),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Interest", amount: 25.0, date: Date().addingTimeInterval(-86400 * 3),
             type: TransactionType.income, category: "Income", account: savingsAccount),

            // Expense transactions
            (title: "Rent", amount: 1200.0, date: Date().addingTimeInterval(-86400 * 28),
             type: TransactionType.expense, category: "Housing", account: checkingAccount),
            (title: "Groceries", amount: 120.50, date: Date().addingTimeInterval(-86400 * 25),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Electricity Bill", amount: 85.0, date: Date().addingTimeInterval(-86400 * 20),
             type: TransactionType.expense, category: "Utilities", account: checkingAccount),
            (title: "Internet", amount: 60.0, date: Date().addingTimeInterval(-86400 * 18),
             type: TransactionType.expense, category: "Utilities", account: creditCard),
            (title: "Gas", amount: 45.0, date: Date().addingTimeInterval(-86400 * 15),
             type: TransactionType.expense, category: "Transportation", account: creditCard),
            (title: "Dinner", amount: 65.75, date: Date().addingTimeInterval(-86400 * 12),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Movie Tickets", amount: 30.0, date: Date().addingTimeInterval(-86400 * 10),
             type: TransactionType.expense, category: "Entertainment", account: creditCard),
            (title: "Coffee", amount: 4.50, date: Date().addingTimeInterval(-86400 * 7),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Gym Membership", amount: 50.0, date: Date().addingTimeInterval(-86400 * 5),
             type: TransactionType.expense, category: "Personal Care", account: checkingAccount),
            (title: "Online Course", amount: 200.0, date: Date().addingTimeInterval(-86400 * 2),
             type: TransactionType.expense, category: "Education", account: creditCard),

            // Previous month transactions
            (title: "Salary", amount: 3500.0, date: Date().addingTimeInterval(-86400 * 45),
             type: TransactionType.income, category: "Income", account: checkingAccount),
            (title: "Rent", amount: 1200.0, date: Date().addingTimeInterval(-86400 * 58),
             type: TransactionType.expense, category: "Housing", account: checkingAccount),
            (title: "Groceries", amount: 160.30, date: Date().addingTimeInterval(-86400 * 50),
             type: TransactionType.expense, category: "Food", account: creditCard),
            (title: "Travel", amount: 500.0, date: Date().addingTimeInterval(-86400 * 40),
             type: TransactionType.expense, category: "Travel", account: creditCard),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]

        for transaction in transactions {
            let newTransaction = FinancialTransaction(
                title: transaction.title,
                amount: transaction.amount,
                date: transaction.date,
                transactionType: transaction.type,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
            newTransaction.category = categoryDict[transaction.category]
            newTransaction.account = transaction.account

            // Update account balance based on transaction
            transaction.account?.updateBalance(for: newTransaction)

            modelContext.insert(newTransaction)
        }

        try? modelContext.save()
    }
}

/// Subscriptions data generator
@MainActor
class SubscriptionsDataGenerator: DataGenerator {
    let modelContext: ModelContext

    /// Temporary struct for subscription data creation
    private struct SubscriptionData {
        let name: String
        let amount: Double
        let cycle: BillingCycle
        let nextDue: Date
        let category: String
        let account: FinancialAccount
        let isActive: Bool
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func generate() {
        guard let categories = try? modelContext.fetch(FetchDescriptor<ExpenseCategory>()) else { return }
        guard let accounts = try? modelContext.fetch(FetchDescriptor<FinancialAccount>()) else { return }

        var categoryDict: [String: ExpenseCategory] = [:]
        for category in categories {
            categoryDict[category.name] = category
        }

        let checkingAccount = accounts.first { $0.name == "Checking Account" }
        let creditCard = accounts.first { $0.name == "Credit Card" }

        guard let checkingAccount, let creditCard else { return }

        let subscriptions = createSubscriptionDataArray(checkingAccount: checkingAccount, creditCard: creditCard)

        for subscription in subscriptions {
            let newSubscription = Subscription(
                name: subscription.name,
                amount: subscription.amount,
                billingCycle: subscription.cycle,
                nextDueDate: subscription.nextDue,
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)

            newSubscription.category = categoryDict[subscription.category]
            newSubscription.account = subscription.account
            newSubscription.isActive = subscription.isActive

            modelContext.insert(newSubscription)
        }

        try? modelContext.save()
    }

    /// Create subscription data array
    private func createSubscriptionDataArray(checkingAccount: FinancialAccount, creditCard: FinancialAccount) -> [SubscriptionData] {
        let entertainment = createEntertainmentSubscriptions(creditCard: creditCard)
        let utilities = createUtilitySubscriptions(checkingAccount: checkingAccount, creditCard: creditCard)
        let personal = createPersonalSubscriptions(checkingAccount: checkingAccount)
        let transportation = createTransportationSubscriptions(checkingAccount: checkingAccount)

        return entertainment + utilities + personal + transportation
    }

    private func createEntertainmentSubscriptions(creditCard: FinancialAccount) -> [SubscriptionData] {
        let calendar = Calendar.current
        let today = Date()

<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func safeDateByAdding(days: Int, to date: Date) -> Date {
            calendar.date(byAdding: .day, value: days, to: date) ?? date
        }

        return [
            SubscriptionData(
                name: "Netflix",
                amount: 14.99,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 5, to: today),
                category: "Entertainment",
                account: creditCard,
                isActive: true,
<<<<<<< HEAD
                ),
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
            SubscriptionData(
                name: "Spotify",
                amount: 9.99,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 12, to: today),
                category: "Entertainment",
                account: creditCard,
                isActive: true,
<<<<<<< HEAD
                ),
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
            SubscriptionData(
                name: "Video Streaming",
                amount: 7.99,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 2, to: today),
                category: "Entertainment",
                account: creditCard,
                isActive: false,
<<<<<<< HEAD
                )
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]
    }

    private func createUtilitySubscriptions(checkingAccount: FinancialAccount, creditCard: FinancialAccount) -> [SubscriptionData] {
        let calendar = Calendar.current
        let today = Date()

<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func safeDateByAdding(days: Int, to date: Date) -> Date {
            calendar.date(byAdding: .day, value: days, to: date) ?? date
        }

        return [
            SubscriptionData(
                name: "Cloud Storage",
                amount: 2.99,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 15, to: today),
                category: "Utilities",
                account: creditCard,
                isActive: true,
<<<<<<< HEAD
                ),
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
            SubscriptionData(
                name: "Phone Bill",
                amount: 65.0,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 22, to: today),
                category: "Utilities",
                account: checkingAccount,
                isActive: true,
<<<<<<< HEAD
                ),
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
            SubscriptionData(
                name: "Internet",
                amount: 60.0,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 18, to: today),
                category: "Utilities",
                account: checkingAccount,
                isActive: true,
<<<<<<< HEAD
                )
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]
    }

    private func createPersonalSubscriptions(checkingAccount: FinancialAccount) -> [SubscriptionData] {
        let calendar = Calendar.current
        let today = Date()

<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func safeDateByAdding(days: Int, to date: Date) -> Date {
            calendar.date(byAdding: .day, value: days, to: date) ?? date
        }

        return [
            SubscriptionData(
                name: "Gym Membership",
                amount: 50.0,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 8, to: today),
                category: "Personal Care",
                account: checkingAccount,
                isActive: true,
<<<<<<< HEAD
                )
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]
    }

    private func createTransportationSubscriptions(checkingAccount: FinancialAccount) -> [SubscriptionData] {
        let calendar = Calendar.current
        let today = Date()

<<<<<<< HEAD
        /// <#Description#>
        /// - Returns: <#description#>
=======
    /// <#Description#>
    /// - Returns: <#description#>
>>>>>>> 1cf3938 (Create working state for recovery)
        func safeDateByAdding(days: Int, to date: Date) -> Date {
            calendar.date(byAdding: .day, value: days, to: date) ?? date
        }

        return [
            SubscriptionData(
                name: "Car Insurance",
                amount: 120.0,
                cycle: BillingCycle.monthly,
                nextDue: safeDateByAdding(days: 25, to: today),
                category: "Transportation",
                account: checkingAccount,
                isActive: true,
<<<<<<< HEAD
                )
=======
            ),
>>>>>>> 1cf3938 (Create working state for recovery)
        ]
    }
}
