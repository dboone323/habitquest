import Foundation
import SwiftData

// MARK: - Import/Export Service

/// Service for importing and exporting financial data
@MainActor
public class ImportExportService {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    /// Export financial data to CSV format
    public func exportToCSV(settings: ExportSettings) async throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "financial_export.csv"
        let fileURL = tempDir.appendingPathComponent(fileName)

        var rows = ["date,title,amount,type,notes,category,account"]

        let context = ModelContext(modelContainer)
        let fetch = FetchDescriptor<FinancialTransaction>()
        let transactions = (try? context.fetch(fetch)) ?? []

        let filtered = transactions.filter {
            $0.date >= settings.startDate && $0.date <= settings.endDate
        }

        for transaction in filtered {
            let dateString = ISO8601DateFormatter().string(from: transaction.date)
            let safeTitle = transaction.title.replacingOccurrences(of: ",", with: " ")
            let notes = (transaction.notes ?? "").replacingOccurrences(of: ",", with: " ")
            let category = transaction.category?.name.replacingOccurrences(of: ",", with: " ") ?? ""
            let account = transaction.account?.name.replacingOccurrences(of: ",", with: " ") ?? ""
            rows.append(
                "\(dateString),\(safeTitle),\(transaction.amount),\(transaction.transactionType.rawValue),\(notes),\(category),\(account)"
            )
        }

        if filtered.isEmpty {
            rows.append("\(ISO8601DateFormatter().string(from: Date())),No Data,0.0,info,,,")
        }

        try rows.joined(separator: "\n").data(using: .utf8)!.write(to: fileURL)
        return fileURL
    }

    /// Import financial data from CSV content
    public func importFromCSV(_ content: String) async throws -> ImportResult {
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !lines.isEmpty else {
            return ImportResult(
                success: false,
                transactionsImported: 0,
                errors: [ValidationError(field: "file", message: "CSV file is empty", severity: .error)]
            )
        }

        let headers = lines[0].components(separatedBy: ",")
        let columnMapping = mapCSVColumns(headers: headers)

        var imported = 0
        var errors: [ValidationError] = []

        for line in lines.dropFirst() {
            let fields = line.components(separatedBy: ",")
            do {
                let transaction = try await parseTransaction(fields: fields, columnMapping: columnMapping)
                let context = ModelContext(modelContainer)
                context.insert(transaction)
                try context.save()
                imported += 1
            } catch {
                errors.append(ValidationError(field: "row", message: "Error importing line: \(line) - \(error.localizedDescription)", severity: .error))
            }
        }

        return ImportResult(
            success: errors.isEmpty,
            transactionsImported: imported,
            errors: errors
        )
    }

    // MARK: - Private Helpers

    private func mapCSVColumns(headers: [String]) -> CSVIndexMapping {
        var mapping = CSVIndexMapping()
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

    private func parseTransaction(fields: [String], columnMapping: CSVIndexMapping) async throws -> FinancialTransaction {
        // Parse required fields
        guard let dateIndex = columnMapping.dateIndex,
              let amountIndex = columnMapping.amountIndex,
              fields.count > max(dateIndex, amountIndex)
        else {
            throw ImportError.missingRequiredField("date or amount")
        }

        let dateString = fields[dateIndex]
        let amountString = fields[amountIndex]

        let date = try parseDate(dateString)
        let amount = try parseAmount(amountString)

        let typeString = columnMapping.typeIndex.flatMap { fields[$0] } ?? ""
        let transactionType = parseTransactionType(typeString, amount: amount)

        let title = columnMapping.titleIndex.flatMap { fields[$0] } ?? "Imported Transaction"
        let notes = columnMapping.notesIndex.flatMap { fields[$0] }

        let transaction = FinancialTransaction(
            title: title,
            amount: amount,
            date: date,
            transactionType: transactionType,
            notes: notes
        )

        return transaction
    }

    private func parseDate(_ string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: string) else {
            throw ImportError.invalidDateFormat(string)
        }
        return date
    }

    private func parseAmount(_ string: String) throws -> Double {
        let cleaned = string
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(cleaned) else {
            throw ImportError.invalidAmountFormat(string)
        }
        return value
    }

    private func parseTransactionType(_ type: String, amount: Double) -> TransactionType {
        switch type.lowercased() {
        case "income", "credit", "deposit": return .income
        case "expense", "debit", "withdrawal": return .expense
        default: return amount >= 0 ? .income : .expense
        }
    }
}
