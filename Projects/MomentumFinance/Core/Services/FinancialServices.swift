import Foundation
import SwiftData

// MARK: - Service Protocols

public protocol EntityManager: Sendable {
    func save() async throws
    func delete(_ entity: some Any) async throws
    func fetch<T>(_ type: T.Type) async throws -> [T]
    func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping) async throws
        -> FinancialAccount?
    func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory?
}

// MARK: - Service Implementations

public final class SwiftDataEntityManager: EntityManager {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func save() async throws {
        try self.modelContext.save()
    }

    public func delete(_ entity: some Any) async throws {
        self.modelContext.delete(entity)
        try self.modelContext.save()
    }

    public func fetch<T>(_: T.Type) async throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try self.modelContext.fetch(descriptor)
    }

    public func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping)
        async throws -> FinancialAccount? {
        // Extract account name from CSV fields
        guard let accountColumnIndex = getColumnIndex(for: columnMapping.accountColumn, in: fields) else {
            return nil
        }

        let accountName = fields[accountColumnIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        if accountName.isEmpty {
            return nil
        }

        // Try to find existing account
        let descriptor = FetchDescriptor<FinancialAccount>(
            predicate: #Predicate<FinancialAccount> { $0.name == accountName }
        )

        if let existingAccount = try? modelContext.fetch(descriptor).first {
            return existingAccount
        }

        // Create new account
        let newAccount = FinancialAccount(
            name: accountName,
            balance: 0.0,
            iconName: "creditcard.fill",
            accountType: .checking
        )
        self.modelContext.insert(newAccount)
        try? self.modelContext.save()

        return newAccount
    }

    public func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory? {
        // Extract category name from CSV fields
        guard let categoryColumnIndex = getColumnIndex(for: columnMapping.categoryColumn, in: fields) else {
            // Use default category based on transaction type
            return self.getDefaultCategory(for: transactionType)
        }

        let categoryName = fields[categoryColumnIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        if categoryName.isEmpty {
            return self.getDefaultCategory(for: transactionType)
        }

        // Try to find existing category
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate<ExpenseCategory> { $0.name == categoryName }
        )

        if let existingCategory = try? modelContext.fetch(descriptor).first {
            return existingCategory
        }

        // Create new category
        let newCategory = ExpenseCategory(
            name: categoryName,
            iconName: getDefaultIcon(for: categoryName)
        )
        self.modelContext.insert(newCategory)
        try? self.modelContext.save()

        return newCategory
    }

    private func getColumnIndex(for columnName: String?, in _: [String]) -> Int? {
        guard let columnName else { return nil }
        // This is a simplified implementation - in a real app you'd have proper CSV parsing
        return 0 // Placeholder
    }

    private func getDefaultCategory(for transactionType: TransactionType) -> ExpenseCategory? {
        let categoryName = transactionType == .income ? "Income" : "General"
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate<ExpenseCategory> { $0.name == categoryName }
        )
        return try? self.modelContext.fetch(descriptor).first
    }

    private func getDefaultIcon(for categoryName: String) -> String {
        let iconMap = [
            "Housing": "house.fill",
            "Transportation": "car.fill",
            "Food": "fork.knife",
            "Utilities": "bolt.fill",
            "Entertainment": "tv.fill",
            "Shopping": "bag.fill",
            "Health": "heart.fill",
            "Travel": "airplane",
            "Education": "book.fill",
            "Income": "dollarsign.circle.fill",
        ]
        return iconMap[categoryName] ?? "circle"
    }
}

// MARK: - Export Engine Service

public final class SwiftDataExportEngineService: Sendable {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func exportToCSV() async throws -> URL {
        let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

        let csvString = self.createCSVString(from: transactions)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions_export.csv")

        try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    public func export(settings: [String: Any]) async throws -> URL {
        // Support different export formats based on settings
        let format = settings["format"] as? String ?? "csv"

        switch format {
        case "json":
            return try await self.exportToJSON()
        case "pdf":
            return try await self.exportToPDF()
        default:
            return try await self.exportToCSV()
        }
    }

    private func exportToJSON() async throws -> URL {
        let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let jsonData = try encoder.encode(transactions)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions_export.json")

        try jsonData.write(to: tempURL)
        return tempURL
    }

    private func exportToPDF() async throws -> URL {
        // Placeholder for PDF export - would require PDF generation library
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions_export.pdf")

        let placeholderContent = "PDF Export - Not yet implemented"
        try placeholderContent.write(to: tempURL, atomically: true, encoding: .utf8)

        return tempURL
    }

    private func createCSVString(from transactions: [FinancialTransaction]) -> String {
        var csvLines = ["Date,Title,Amount,Type,Category,Account,Notes"]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.date)
            let title = transaction.title.replacingOccurrences(of: ",", with: ";")
            let amount = String(format: "%.2f", transaction.amount)
            let type = transaction.transactionType.rawValue
            let category = transaction.category?.name ?? ""
            let account = transaction.account?.name ?? ""
            let notes = transaction.notes?.replacingOccurrences(of: ",", with: ";") ?? ""

            csvLines.append("\(date),\(title),\(amount),\(type),\(category),\(account),\(notes)")
        }

        return csvLines.joined(separator: "\n")
    }
}

// MARK: - Financial ML and Analysis Services

public final class SwiftDataFinancialMLService: Sendable {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func predictSpending(for category: ExpenseCategory? = nil, daysAhead: Int = 30) async -> Double {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            let relevantTransactions = transactions.filter { transaction in
                transaction.transactionType == .expense &&
                    (category == nil || transaction.category == category)
            }

            if relevantTransactions.isEmpty {
                return 0.0
            }

            // Simple average-based prediction
            let totalSpent = relevantTransactions.reduce(0) { $0 + $1.amount }
            let averageDaily = totalSpent / Double(relevantTransactions.count)

            return averageDaily * Double(daysAhead)
        } catch {
            print("Error predicting spending: \(error)")
            return 0.0
        }
    }

    public func analyzeSpendingPatterns() async -> [SpendingPattern] {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            let expenseTransactions = transactions.filter { $0.transactionType == .expense }

            // Group by category
            var categorySpending: [String: Double] = [:]
            for transaction in expenseTransactions {
                let categoryName = transaction.category?.name ?? "Uncategorized"
                categorySpending[categoryName, default: 0] += transaction.amount
            }

            // Convert to patterns
            return categorySpending.map { category, amount in
                SpendingPattern(category: category, totalAmount: amount, trend: .stable)
            }.sorted { $0.totalAmount > $1.totalAmount }
        } catch {
            print("Error analyzing spending patterns: \(error)")
            return []
        }
    }

    public func detectAnomalies() async -> [TransactionAnomaly] {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            var anomalies: [TransactionAnomaly] = []

            // Simple anomaly detection based on amount thresholds
            for transaction in transactions {
                if transaction.amount > 1000 { // High amount threshold
                    anomalies.append(TransactionAnomaly(
                        transaction: transaction,
                        type: .unusuallyHighAmount,
                        severity: .medium
                    ))
                }
            }

            return anomalies
        } catch {
            print("Error detecting anomalies: \(error)")
            return []
        }
    }
}

public struct SpendingPattern {
    public let category: String
    public let totalAmount: Double
    public let trend: Trend

    public enum Trend {
        case increasing, decreasing, stable
    }
}

public struct TransactionAnomaly {
    public let transaction: FinancialTransaction
    public let type: AnomalyType
    public let severity: Severity

    public enum AnomalyType {
        case unusuallyHighAmount, unusualCategory, potentialFraud
    }

    public enum Severity {
        case low, medium, high
    }
}

// MARK: - Transaction Pattern Analyzer

public final class SwiftDataTransactionPatternAnalyzer: Sendable {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func analyzePatterns() async -> [TransactionPattern] {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            // Group transactions by title to find recurring patterns
            var titleCounts: [String: Int] = [:]
            var titleAmounts: [String: [Double]] = [:]

            for transaction in transactions {
                titleCounts[transaction.title, default: 0] += 1
                titleAmounts[transaction.title, default: []].append(transaction.amount)
            }

            // Identify recurring transactions (appear more than once)
            let recurringTitles = titleCounts.filter { $0.value > 1 }

            return recurringTitles.map { title, count in
                let amounts = titleAmounts[title] ?? []
                let averageAmount = amounts.reduce(0, +) / Double(amounts.count)

                return TransactionPattern(
                    title: title,
                    frequency: count,
                    averageAmount: averageAmount,
                    isRecurring: true
                )
            }
        } catch {
            print("Error analyzing transaction patterns: \(error)")
            return []
        }
    }

    public func suggestCategories() async -> [CategorySuggestion] {
        do {
            let transactions = try modelContext.fetch(FetchDescriptor<FinancialTransaction>())

            let uncategorizedTransactions = transactions.filter { $0.category == nil }

            return uncategorizedTransactions.map { transaction in
                CategorySuggestion(
                    transaction: transaction,
                    suggestedCategory: self.suggestCategory(for: transaction),
                    confidence: 0.8
                )
            }
        } catch {
            print("Error suggesting categories: \(error)")
            return []
        }
    }

    private func suggestCategory(for transaction: FinancialTransaction) -> String {
        let title = transaction.title.lowercased()

        if title.contains("grocery") || title.contains("food") || title.contains("restaurant") {
            return "Food & Dining"
        } else if title.contains("gas") || title.contains("fuel") || title.contains("uber") {
            return "Transportation"
        } else if title.contains("electric") || title.contains("water") || title.contains("internet") {
            return "Utilities"
        } else if title.contains("netflix") || title.contains("movie") || title.contains("entertainment") {
            return "Entertainment"
        } else if title.contains("amazon") || title.contains("shopping") {
            return "Shopping"
        } else {
            return "General"
        }
    }
}

public struct TransactionPattern {
    public let title: String
    public let frequency: Int
    public let averageAmount: Double
    public let isRecurring: Bool
}

public struct CategorySuggestion {
    public let transaction: FinancialTransaction
    public let suggestedCategory: String
    public let confidence: Double
}
