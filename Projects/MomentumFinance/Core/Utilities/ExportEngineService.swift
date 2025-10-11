import Foundation
import PDFKit
import SwiftData
import SwiftUI

final class ExportEngineService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Public API
    func export(settings: ExportSettings) async throws -> URL {
        switch settings.format {
        case .csv:
            try await self.exportToCSV(settings: settings)
        case .pdf:
            try await self.exportToPDF(settings: settings)
        case .json:
            try await self.exportToJSON(settings: settings)
        }
    }

    // MARK: - CSV

    private func exportToCSV(settings: ExportSettings) async throws -> URL {
        var csvParts: [String] = []

        if settings.includeTransactions {
            try await csvParts.append(self.generateTransactionsCSV(settings: settings))
            csvParts.append("\n\n")
        }
        if settings.includeAccounts {
            try await csvParts.append(self.generateAccountsCSV(settings: settings))
            csvParts.append("\n\n")
        }
        if settings.includeBudgets {
            try await csvParts.append(self.generateBudgetsCSV(settings: settings))
            csvParts.append("\n\n")
        }
        if settings.includeSubscriptions {
            try await csvParts.append(self.generateSubscriptionsCSV(settings: settings))
            csvParts.append("\n\n")
        }
        if settings.includeGoals {
            try await csvParts.append(self.generateGoalsCSV(settings: settings))
        }

        let csvContent = csvParts.joined()
        return try self.saveToFile(content: csvContent, filename: ExportConstants.csvFilename)
    }

    private func generateTransactionsCSV(settings: ExportSettings) async throws -> String {
        let transactions = try fetchTransactions(from: settings.startDate, to: settings.endDate)

        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"

        var csvLines = ["TRANSACTIONS", "Date,Title,Amount,Type,Category,Account,Notes"]

        for transaction in transactions {
            let date = formatter.string(from: transaction.date)
            let title = self.escapeCSVField(transaction.title)
            let amount = String(transaction.amount)
            let type = transaction.transactionType.rawValue
            let category = self.escapeCSVField(transaction.category?.name ?? "")
            let account = self.escapeCSVField(transaction.account?.name ?? "")
            let notes = self.escapeCSVField(transaction.notes ?? "")

            csvLines.append("\(date),\(title),\(amount),\(type),\(category),\(account),\(notes)")
        }

        return csvLines.joined(separator: "\n") + "\n"
    }

    private func generateAccountsCSV(settings _: ExportSettings) async throws -> String {
        let accounts = try fetchAccounts()

        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"

        var csvLines = ["ACCOUNTS", "Name,Balance,Type,Currency,Created Date"]

        for account in accounts {
            let name = self.escapeCSVField(account.name)
            let balance = String(account.balance)
            let type = account.accountType.rawValue
            let currency = account.currencyCode
            let created = formatter.string(from: account.createdDate)

            csvLines.append("\(name),\(balance),\(type),\(currency),\(created)")
        }

        return csvLines.joined(separator: "\n") + "\n"
    }

    private func generateBudgetsCSV(settings _: ExportSettings) async throws -> String {
        let budgets = try fetchBudgets()

        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"

        var csvLines = ["BUDGETS", "Name,Limit Amount,Spent Amount,Category,Month,Created Date"]

        for budget in budgets {
            let name = self.escapeCSVField(budget.name)
            let limit = String(budget.limitAmount)
            let spent = String(budget.spentAmount)
            let category = self.escapeCSVField(budget.category?.name ?? "")
            let month = formatter.string(from: budget.month)
            let created = formatter.string(from: budget.createdDate)

            csvLines.append("\(name),\(limit),\(spent),\(category),\(month),\(created)")
        }

        return csvLines.joined(separator: "\n") + "\n"
    }

    private func generateSubscriptionsCSV(settings _: ExportSettings) async throws -> String {
        let subscriptions = try fetchSubscriptions()

        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"

        var csvLines = ["SUBSCRIPTIONS", "Name,Amount,Billing Cycle,Next Due Date,Category,Account,Is Active"]

        for subscription in subscriptions {
            let name = self.escapeCSVField(subscription.name)
            let amount = String(subscription.amount)
            let cycle = subscription.billingCycle.rawValue
            let nextDue = formatter.string(from: subscription.nextDueDate)
            let category = self.escapeCSVField(subscription.category?.name ?? "")
            let account = self.escapeCSVField(subscription.account?.name ?? "")
            let isActive = subscription.isActive ? "Yes" : "No"

            csvLines.append("\(name),\(amount),\(cycle),\(nextDue),\(category),\(account),\(isActive)")
        }

        return csvLines.joined(separator: "\n") + "\n"
    }

    private func generateGoalsCSV(settings _: ExportSettings) async throws -> String {
        let goals = try fetchGoals()

        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"

        var csvLines = ["SAVINGS GOALS", "Name,Target Amount,Current Amount,Target Date,Progress"]

        for goal in goals {
            let name = self.escapeCSVField(goal.name)
            let target = String(goal.targetAmount)
            let current = String(goal.currentAmount)
            let targetDate = goal.targetDate.map { formatter.string(from: $0) } ?? ""
            let progress = String(format: "%.1f%%", goal.progressPercentage * 100)

            csvLines.append("\(name),\(target),\(current),\(targetDate),\(progress)")
        }

        return csvLines.joined(separator: "\n") + "\n"
    }

    // MARK: - PDF

    private func exportToPDF(settings: ExportSettings) async throws -> URL {
        let pdfData = try await generatePDFData(settings: settings)
        return try self.saveToFile(data: pdfData, filename: ExportConstants.pdfFilename)
    }

    private func generatePDFData(settings: ExportSettings) async throws -> Data {
        // Keep platform-safe PDF generation. For brevity we call through to a basic renderer
        #if os(iOS)
        // iOS PDF rendering omitted in this simplified engine to avoid UIKit dependency in tests
        throw ExportError.pdfGenerationFailed
        #else
        let pdfData = NSMutableData()
        let pdfInfo = [kCGPDFContextCreator: "Momentum Finance"] as CFDictionary
        guard let dataConsumer = CGDataConsumer(data: pdfData as CFMutableData),
              let pdfContext = CGContext(consumer: dataConsumer, mediaBox: nil, pdfInfo)
        else { throw ExportError.pdfGenerationFailed }

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        pdfContext.beginPDFPage(nil)

        NSGraphicsContext.saveGraphicsState()
        let nsContext = NSGraphicsContext(cgContext: pdfContext, flipped: false)
        NSGraphicsContext.current = nsContext

        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: NSColor.black,
        ]
        let title = "Momentum Finance Report"
        title.draw(at: CGPoint(x: 50, y: pageRect.height - 50), withAttributes: titleAttributes)

        let dateFormatter = DateFormatter(); dateFormatter.dateStyle = .long
        let dateRange = "Period: \(dateFormatter.string(from: settings.startDate)) - \(dateFormatter.string(from: settings.endDate))"
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.gray,
        ]
        dateRange.draw(at: CGPoint(x: 50, y: pageRect.height - 80), withAttributes: dateAttributes)

        var yPosition = pageRect.height - 120
        if settings.includeTransactions {
            yPosition = try self.drawTransactionsSummary(context: pdfContext, yPosition: yPosition, settings: settings)
        }
        if settings.includeAccounts {
            yPosition = try self.drawAccountsSummary(context: pdfContext, yPosition: yPosition, settings: settings)
        }

        pdfContext.endPDFPage()
        NSGraphicsContext.restoreGraphicsState()

        return pdfData as Data
        #endif
    }

    private func drawTransactionsSummary(context _: CGContext, yPosition: Double, settings: ExportSettings) throws -> Double {
        let transactions = try fetchTransactions(from: settings.startDate, to: settings.endDate)

        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 18),
            .foregroundColor: NSColor.black,
        ]
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black,
        ]

        "Transactions Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)

        let totalIncome = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + abs($1.amount) }
        let netAmount = totalIncome - totalExpenses

        var currentY = yPosition + 30

        "Total Transactions: \(transactions.count)".draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Total Income: $\(String(format: "%.2f", totalIncome))".draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Total Expenses: $\(String(format: "%.2f", totalExpenses))".draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 20

        "Net Amount: $\(String(format: "%.2f", netAmount))".draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
        currentY += 40

        return currentY
    }

    private func drawAccountsSummary(context _: CGContext, yPosition: Double, settings _: ExportSettings) throws -> Double {
        let accounts = try fetchAccounts()

        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 18),
            .foregroundColor: NSColor.black,
        ]
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black,
        ]

        "Accounts Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)

        var currentY = yPosition + 30

        for account in accounts {
            let accountInfo = "\(account.name): $\(String(format: "%.2f", account.balance))"
            accountInfo.draw(at: CGPoint(x: 70, y: currentY), withAttributes: textAttributes)
            currentY += 20
        }

        return currentY + 20
    }

    // MARK: - JSON

    private func exportToJSON(settings: ExportSettings) async throws -> URL {
        var exportData: [String: Any] = [:]

        exportData["exportInfo"] = [
            "date": ISO8601DateFormatter().string(from: Date()),
            "startDate": ISO8601DateFormatter().string(from: settings.startDate),
            "endDate": ISO8601DateFormatter().string(from: settings.endDate),
            "app": "Momentum Finance",
            "version": "1.0.0",
        ]

        if settings.includeTransactions {
            exportData["transactions"] = try await self.fetchTransactionsJSON(settings: settings)
        }
        if settings.includeAccounts {
            exportData["accounts"] = try await self.fetchAccountsJSON()
        }
        if settings.includeBudgets {
            exportData["budgets"] = try await self.fetchBudgetsJSON()
        }
        if settings.includeSubscriptions {
            exportData["subscriptions"] = try await self.fetchSubscriptionsJSON()
        }
        if settings.includeGoals {
            exportData["goals"] = try await self.fetchGoalsJSON()
        }

        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        return try self.saveToFile(data: jsonData, filename: ExportConstants.jsonFilename)
    }

    // MARK: - Fetching

    private func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [FinancialTransaction] {
        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)],
        )
        return try self.modelContext.fetch(descriptor)
    }

    private func fetchAccounts() throws -> [FinancialAccount] {
        let descriptor = FetchDescriptor<FinancialAccount>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try self.modelContext.fetch(descriptor)
    }

    private func fetchBudgets() throws -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try self.modelContext.fetch(descriptor)
    }

    private func fetchSubscriptions() throws -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try self.modelContext.fetch(descriptor)
    }

    private func fetchGoals() throws -> [SavingsGoal] {
        let descriptor = FetchDescriptor<SavingsGoal>(
            sortBy: [SortDescriptor(\.name)],
        )
        return try self.modelContext.fetch(descriptor)
    }

    // MARK: - JSON Converters

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

    // MARK: - Helpers

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    private func saveToFile(content: String, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    private func saveToFile(data: Data, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }
}
