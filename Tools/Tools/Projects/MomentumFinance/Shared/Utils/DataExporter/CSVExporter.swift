import Foundation
import SwiftData

// MARK: - CSV Export Functionality

extension DataExporter {

    /// Export data to CSV format
    func exportToCSV(with settings: ExportSettings) async throws -> URL {
        var csvContent = ""

        if settings.includeTransactions {
            csvContent += try await generateTransactionsCSV(settings: settings)
            csvContent += "\n\n"
        }

        if settings.includeAccounts {
            csvContent += try await generateAccountsCSV(settings: settings)
            csvContent += "\n\n"
        }

        if settings.includeBudgets {
            csvContent += try await generateBudgetsCSV(settings: settings)
            csvContent += "\n\n"
        }

        if settings.includeSubscriptions {
            csvContent += try await generateSubscriptionsCSV(settings: settings)
            csvContent += "\n\n"
        }

        if settings.includeGoals {
            csvContent += try await generateGoalsCSV(settings: settings)
        }

        return try saveToFile(content: csvContent, filename: "momentum_finance_export.csv")
    }

    private func generateTransactionsCSV(settings: ExportSettings) async throws -> String {
        let transactions = try fetchTransactions(from: settings.startDate, to: settings.endDate)

        var csv = "TRANSACTIONS\n"
        csv += "Date,Title,Amount,Type,Category,Account,Notes\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for transaction in transactions {
            let date = formatter.string(from: transaction.date)
            let title = escapeCSVField(transaction.title)
            let amount = String(transaction.amount)
            let type = transaction.transactionType.rawValue
            let category = escapeCSVField(transaction.category?.name ?? "")
            let account = escapeCSVField(transaction.account?.name ?? "")
            let notes = escapeCSVField(transaction.notes ?? "")

            csv += "\(date),\(title),\(amount),\(type),\(category),\(account),\(notes)\n"
        }

        return csv
    }

    private func generateAccountsCSV(settings: ExportSettings) async throws -> String {
        let accounts = try fetchAccounts()

        var csv = "ACCOUNTS\n"
        csv += "Name,Balance,Type,Currency,Created Date\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for account in accounts {
            let name = escapeCSVField(account.name)
            let balance = String(account.balance)
            let type = account.accountType.rawValue
            let currency = account.currencyCode
            let created = formatter.string(from: account.createdDate)

            csv += "\(name),\(balance),\(type),\(currency),\(created)\n"
        }

        return csv
    }

    private func generateBudgetsCSV(settings: ExportSettings) async throws -> String {
        let budgets = try fetchBudgets()

        var csv = "BUDGETS\n"
        csv += "Name,Limit Amount,Spent Amount,Category,Month,Created Date\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for budget in budgets {
            let name = escapeCSVField(budget.name)
            let limit = String(budget.limitAmount)
            let spent = String(budget.spentAmount)
            let category = escapeCSVField(budget.category?.name ?? "")
            let month = formatter.string(from: budget.month)
            let created = formatter.string(from: budget.createdDate)

            csv += "\(name),\(limit),\(spent),\(category),\(month),\(created)\n"
        }

        return csv
    }

    private func generateSubscriptionsCSV(settings: ExportSettings) async throws -> String {
        let subscriptions = try fetchSubscriptions()

        var csv = "SUBSCRIPTIONS\n"
        csv += "Name,Amount,Billing Cycle,Next Due Date,Category,Account,Is Active\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for subscription in subscriptions {
            let name = escapeCSVField(subscription.name)
            let amount = String(subscription.amount)
            let cycle = subscription.billingCycle.rawValue
            let nextDue = formatter.string(from: subscription.nextDueDate)
            let category = escapeCSVField(subscription.category?.name ?? "")
            let account = escapeCSVField(subscription.account?.name ?? "")
            let isActive = subscription.isActive ? "Yes" : "No"

            csv += "\(name),\(amount),\(cycle),\(nextDue),\(category),\(account),\(isActive)\n"
        }

        return csv
    }

    private func generateGoalsCSV(settings: ExportSettings) async throws -> String {
        let goals = try fetchGoals()

        var csv = "SAVINGS GOALS\n"
        csv += "Name,Target Amount,Current Amount,Target Date,Progress\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for goal in goals {
            let name = escapeCSVField(goal.name)
            let target = String(goal.targetAmount)
            let current = String(goal.currentAmount)
            let targetDate = goal.targetDate.map { formatter.string(from: $0) } ?? ""
            let progress = String(format: "%.1f%%", goal.progressPercentage * 100)

            csv += "\(name),\(target),\(current),\(targetDate),\(progress)\n"
        }

        return csv
    }
}
