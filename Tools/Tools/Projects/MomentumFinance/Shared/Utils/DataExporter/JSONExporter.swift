import Foundation
import SwiftData

// MARK: - JSON Export Functionality

extension DataExporter {

    /// Export data to JSON format
    func exportToJSON(with settings: ExportSettings) async throws -> URL {
        var exportData: [String: Any] = [:]

        exportData["exportInfo"] = [
            "date": ISO8601DateFormatter().string(from: Date()),
            "startDate": ISO8601DateFormatter().string(from: settings.startDate),
            "endDate": ISO8601DateFormatter().string(from: settings.endDate),
            "app": "Momentum Finance",
            "version": "1.0.0",
        ]

        if settings.includeTransactions {
            exportData["transactions"] = try await fetchTransactionsJSON(settings: settings)
        }

        if settings.includeAccounts {
            exportData["accounts"] = try await fetchAccountsJSON()
        }

        if settings.includeBudgets {
            exportData["budgets"] = try await fetchBudgetsJSON()
        }

        if settings.includeSubscriptions {
            exportData["subscriptions"] = try await fetchSubscriptionsJSON()
        }

        if settings.includeGoals {
            exportData["goals"] = try await fetchGoalsJSON()
        }

        let jsonData = try JSONSerialization.data(
            withJSONObject: exportData, options: .prettyPrinted
        )
        return try saveToFile(data: jsonData, filename: "momentum_finance_export.json")
    }

    // MARK: - JSON Conversion Methods

    private func fetchTransactionsJSON(settings: ExportSettings) async throws -> [[String: Any]] {
        let transactions = try fetchTransactions(from: settings.startDate, to: settings.endDate)
        let formatter = ISO8601DateFormatter()

        return transactions.map { transaction in
            [
                "id": transaction.id.hashValue.description,
                "date": formatter.string(from: transaction.date),
                "title": transaction.title,
                "amount": transaction.amount,
                "type": transaction.transactionType.rawValue,
                "category": transaction.category?.name ?? "",
                "account": transaction.account?.name ?? "",
                "notes": transaction.notes ?? "",
            ]
        }
    }

    private func fetchAccountsJSON() async throws -> [[String: Any]] {
        let accounts = try fetchAccounts()
        let formatter = ISO8601DateFormatter()

        return accounts.map { account in
            [
                "id": account.id.hashValue.description,
                "name": account.name,
                "balance": account.balance,
                "type": account.accountType.rawValue,
                "currencyCode": account.currencyCode,
                "createdDate": formatter.string(from: account.createdDate),
            ]
        }
    }

    private func fetchBudgetsJSON() async throws -> [[String: Any]] {
        let budgets = try fetchBudgets()
        let formatter = ISO8601DateFormatter()

        return budgets.map { budget in
            [
                "id": budget.id.hashValue.description,
                "name": budget.name,
                "limitAmount": budget.limitAmount,
                "spentAmount": budget.spentAmount,
                "category": budget.category?.name ?? "",
                "month": formatter.string(from: budget.month),
                "createdDate": formatter.string(from: budget.createdDate),
            ]
        }
    }

    private func fetchSubscriptionsJSON() async throws -> [[String: Any]] {
        let subscriptions = try fetchSubscriptions()
        let formatter = ISO8601DateFormatter()

        return subscriptions.map { subscription in
            [
                "id": subscription.id.hashValue.description,
                "name": subscription.name,
                "amount": subscription.amount,
                "billingCycle": subscription.billingCycle.rawValue,
                "nextDueDate": formatter.string(from: subscription.nextDueDate),
                "category": subscription.category?.name ?? "",
                "account": subscription.account?.name ?? "",
                "isActive": subscription.isActive,
            ]
        }
    }

    private func fetchGoalsJSON() async throws -> [[String: Any]] {
        let goals = try fetchGoals()
        let formatter = ISO8601DateFormatter()

        return goals.map { goal in
            var goalData: [String: Any] = [
                "id": goal.id.hashValue.description,
                "name": goal.name,
                "targetAmount": goal.targetAmount,
                "currentAmount": goal.currentAmount,
                "progressPercentage": goal.progressPercentage,
            ]

            if let targetDate = goal.targetDate {
                goalData["targetDate"] = formatter.string(from: targetDate)
            }

            return goalData
        }
    }
}
