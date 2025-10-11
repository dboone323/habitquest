import Foundation
import SwiftData

public enum ImportError: Error {
    case missingRequiredField(String)
    case invalidDateFormat(String)
    case invalidAmountFormat(String)
    case emptyFile
    case invalidFormat(String)
    case duplicateTransaction
    case invalidTransactionType(String)
    case parsingError(String)
}

public struct CSVColumnMapping {
    public var dateIndex: Int?
    public var titleIndex: Int?
    public var amountIndex: Int?
    public var typeIndex: Int?
    public var notesIndex: Int?
    public var accountIndex: Int?
    public var categoryIndex: Int?
    public init() {}
}

public class CSVParser {
    public static func parseCSVRow(_ row: String) -> [String] {
        row.components(separatedBy: ",")
    }

    public static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()
        for (index, header) in headers.enumerated() {
            let key = header.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            switch key {
            case "date", "transaction date": mapping.dateIndex = index
            case "title", "description", "memo": mapping.titleIndex = index
            case "amount", "value": mapping.amountIndex = index
            case "type", "transaction type": mapping.typeIndex = index
            case "notes", "comments": mapping.notesIndex = index
            case "account", "account name": mapping.accountIndex = index
            case "category", "category name": mapping.categoryIndex = index
            default: break
            }
        }
        return mapping
    }
}

public class DataParser {
    public static func parseDate(_ string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: string) else {
            throw ImportError.invalidDateFormat(string)
        }
        return date
    }

    public static func parseAmount(_ string: String) throws -> Double {
        let cleaned =
            string
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(cleaned) else {
            throw ImportError.invalidAmountFormat(string)
        }
        return value
    }

    public static func parseTransactionType(_ type: String, amount: Double) -> TransactionType {
        switch type {
        case "income", "credit", "deposit": .income
        case "expense", "debit", "withdrawal": .expense
        default: amount >= 0 ? .income : .expense
        }
    }
}

public protocol EntityManager {
    func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping) async throws
        -> FinancialAccount
    func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory
}

public class DefaultEntityManager: EntityManager {
    public init() {}
    public func getOrCreateAccount(from _: [String], columnMapping _: CSVColumnMapping)
        async throws -> FinancialAccount {
        FinancialAccount(name: "Imported Account", balance: 0, iconName: "creditcard")
    }

    public func getOrCreateCategory(
        from _: [String], columnMapping _: CSVColumnMapping, transactionType _: TransactionType
    ) async throws -> ExpenseCategory {
        ExpenseCategory(name: "Imported Category", iconName: "tag")
    }
}

public enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
    case json = "JSON"

    public var displayName: String { rawValue }
    public var icon: String {
        switch self {
        case .csv: "tablecells"
        case .pdf: "doc.richtext"
        case .json: "curlybraces"
        }
    }
}

public enum DateRange: String, CaseIterable {
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case lastThreeMonths = "Last 3 Months"
    case lastSixMonths = "Last 6 Months"
    case lastYear = "Last Year"
    case allTime = "All Time"
    case custom = "Custom"
    public var displayName: String { rawValue }
}

public struct ExportSettings {
    public let format: ExportFormat
    public let dateRange: DateRange
    public let includeCategories: Bool
    public let includeAccounts: Bool
    public let includeBudgets: Bool
    public let startDate: Date
    public let endDate: Date

    public init(
        format: ExportFormat,
        dateRange: DateRange,
        includeCategories: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true,
        startDate: Date,
        endDate: Date
    ) {
        self.format = format
        self.dateRange = dateRange
        self.includeCategories = includeCategories
        self.includeAccounts = includeAccounts
        self.includeBudgets = includeBudgets
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct ImportResult {
    public let success: Bool
    public let itemsImported: Int
    public let errors: [String]
    public let warnings: [String]
    public init(success: Bool, itemsImported: Int, errors: [String] = [], warnings: [String] = []) {
        self.success = success
        self.itemsImported = itemsImported
        self.errors = errors
        self.warnings = warnings
    }
}

@MainActor
public class DataExporter {
    private let modelContainer: ModelContainer
    public init(modelContainer: ModelContainer) { self.modelContainer = modelContainer }

    public func exportData(settings: ExportSettings) async throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "export.\(settings.format.displayName.lowercased())"
        let fileURL = tempDir.appendingPathComponent(fileName)

        var rows = ["date,title,amount,type,notes,category,account"]
        let context = ModelContext(modelContainer)
        let fetch = FetchDescriptor<FinancialTransaction>()
        let transactions = (try? context.fetch(fetch)) ?? []
        let filtered = transactions.filter {
            $0.date >= settings.startDate && $0.date <= settings.endDate
        }

        for t in filtered {
            let dateString = ISO8601DateFormatter().string(from: t.date)
            let safeTitle = t.title.replacingOccurrences(of: ",", with: " ")
            let notes = (t.notes ?? "").replacingOccurrences(of: ",", with: " ")
            let category = t.category?.name.replacingOccurrences(of: ",", with: " ") ?? ""
            let account = t.account?.name.replacingOccurrences(of: ",", with: " ") ?? ""
            rows.append(
                "\(dateString),\(safeTitle),\(t.amount),\(t.transactionType.rawValue),\(notes),\(category),\(account)"
            )
        }
        if filtered.isEmpty {
            rows.append("\(ISO8601DateFormatter().string(from: Date())),No Data,0.0,info,,,")
        }

        try rows.joined(separator: "\n").data(using: .utf8)!.write(to: fileURL)
        return fileURL
    }
}

public class DataImporter {
    private let modelContainer: ModelContainer
    public init(modelContainer: ModelContainer) { self.modelContainer = modelContainer }

    public func importFromCSV(_ content: String) async throws -> ImportResult {
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !lines.isEmpty else {
            return ImportResult(success: false, itemsImported: 0, errors: ["CSV file is empty"])
        }
        let headers = CSVParser.parseCSVRow(lines[0])
        let mapping = CSVParser.mapColumns(headers: headers)
        let entityManager = DefaultEntityManager()
        var imported = 0
        var errors: [String] = []
        let warnings: [String] = []

        for line in lines.dropFirst() {
            let fields = CSVParser.parseCSVRow(line)
            do {
                let date = try DataParser.parseDate(fields[mapping.dateIndex ?? 0])
                let amount = try DataParser.parseAmount(fields[mapping.amountIndex ?? 0])
                let typeString = mapping.typeIndex.flatMap { fields[$0] } ?? ""
                let txType = DataParser.parseTransactionType(typeString, amount: amount)
                let title = mapping.titleIndex.flatMap { fields[$0] } ?? "Imported Transaction"
                let notes = mapping.notesIndex.flatMap { fields[$0] }
                let account = try await entityManager.getOrCreateAccount(
                    from: fields, columnMapping: mapping
                )
                let category = try await entityManager.getOrCreateCategory(
                    from: fields, columnMapping: mapping, transactionType: txType
                )
                let transaction = FinancialTransaction(
                    title: title,
                    amount: amount,
                    date: date,
                    transactionType: txType,
                    notes: notes
                )
                transaction.account = account
                transaction.category = category
                let context = ModelContext(modelContainer)
                context.insert(transaction)
                try context.save()
                imported += 1
            } catch {
                errors.append("Error importing line: \(line) - \(error.localizedDescription)")
            }
        }
        return ImportResult(
            success: errors.isEmpty, itemsImported: imported, errors: errors, warnings: warnings
        )
    }
}
