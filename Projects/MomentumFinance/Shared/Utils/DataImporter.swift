// Momentum Finance - Data Importer
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import SwiftData

<<<<<<< HEAD
/// Handles importing financial data from CSV files
@ModelActor
actor DataImporter {
    /// Imports data from a CSV file
    /// <#Description#>
    /// - Returns: <#description#>
=======
// MARK: - Data Import Coordinator
// This file coordinates the data import process using focused component modules.
// Each component is extracted for better maintainability and testing.

// Minimal helper stubs embedded here so the importer compiles deterministically.
// Replace with full implementations when available.

// Use the project's canonical `ImportResult` defined in
// Shared/Utils/ExportTypes.swift. Do not duplicate the type here.

// Errors thrown during import
enum ImportError: Error {
    case fileAccessDenied
    case invalidFormat(String)
    case parsingError(String)
}

// Column mapping extracted from CSV headers (internal to importer).
// Renamed to CSVColumnMapping to avoid colliding with the project's
// public `ColumnMapping` type defined in model files.
struct CSVColumnMapping {
    var dateIndex: Int?
    var titleIndex: Int?
    var amountIndex: Int?
    var typeIndex: Int?
    var notesIndex: Int?
}

// CSV parsing helpers (naive)
enum CSVParser {
    static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()
        for (i, h) in headers.enumerated() {
            let lower = h.lowercased()
            if lower.contains("date") { mapping.dateIndex = i }
            if lower.contains("title") || lower.contains("description") { mapping.titleIndex = i }
            if lower.contains("amount") || lower.contains("value") { mapping.amountIndex = i }
            if lower.contains("type") { mapping.typeIndex = i }
            if lower.contains("notes") || lower.contains("memo") { mapping.notesIndex = i }
        }
        return mapping
    }

    static func parseCSVRow(_ line: String) -> [String] {
        return line.split(separator: ",").map { String($0) }
    }
}

// Basic validators used by DataImporter
struct ImportValidator {
    let modelContext: ModelContext?
    init(modelContext: ModelContext? = nil) { self.modelContext = modelContext }

    static func validateCSVFormat(content: String) throws -> [String] {
        let lines = content.components(separatedBy: .newlines)
        guard let header = lines.first else { throw ImportError.invalidFormat("Empty CSV") }
        return header.split(separator: ",").map { String($0) }
    }

    static func validateRequiredFields(fields: [String], columnMapping: CSVColumnMapping) throws {
        if columnMapping.dateIndex == nil || columnMapping.titleIndex == nil
            || columnMapping.amountIndex == nil
        {
            throw ImportError.invalidFormat("Required columns missing: date/title/amount")
        }
    }

    func isDuplicate(_ transaction: FinancialTransaction) async throws -> Bool {
        return false
    }
}

// Parsers for individual field types
enum DataParser {
    static func parseDate(_ s: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        if let d = formatter.date(from: s) { return d }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        if let d = f.date(from: s) { return d }
        throw ImportError.parsingError("Invalid date: \(s)")
    }

    static func parseAmount(_ s: String) throws -> Double {
        let cleaned = s.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
        if let v = Double(cleaned) { return v }
        throw ImportError.parsingError("Invalid amount: \(s)")
    }

    static func parseTransactionType(_ s: String, amount: Double) -> TransactionType {
        if s.contains("credit") || s.contains("income") { return .income }
        if s.contains("debit") || s.contains("expense") { return .expense }
        return amount >= 0 ? .income : .expense
    }
}

// Internal import-specific entity manager to avoid colliding with the
// project's public `EntityManager` class. Provides minimal helpers used
// during CSV import; replace with canonical implementations when available.
actor ImportEntityManager {
    let modelContext: ModelContext
    init(modelContext: ModelContext) { self.modelContext = modelContext }

    func getOrCreateAccount(from fields: [String], columnMapping: CSVColumnMapping) async throws
        -> FinancialAccount
    {
        return FinancialAccount(
            name: "Imported Account", balance: 0.0, iconName: "", accountType: .checking,
            currencyCode: "USD")
    }

    func getOrCreateCategory(
        from fields: [String], columnMapping: CSVColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory {
        return ExpenseCategory(name: "Imported", iconName: "imported")
    }
}

/// Handles importing financial data from CSV files
@ModelActor
actor DataImporter {

    /// Imports data from a CSV file
>>>>>>> 1cf3938 (Create working state for recovery)
    func importFromCSV(fileURL: URL) async throws -> ImportResult {
        guard fileURL.startAccessingSecurityScopedResource() else {
            throw ImportError.fileAccessDenied
        }

        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }

        let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
        return try await parseAndImportCSV(content: csvContent)
    }

    private func parseAndImportCSV(content: String) async throws -> ImportResult {
<<<<<<< HEAD
        let lines = content.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
            throw ImportError.emptyFile
        }

        // Parse header row
        let headerLine = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let headers = parseCSVRow(headerLine).map { $0.lowercased() }

        guard !headers.isEmpty else {
            throw ImportError.invalidFormat
        }

        // Find column indices
        let columnMapping = mapColumns(headers: headers)

=======
        // Validate CSV format and extract headers
        let headers = try ImportValidator.validateCSVFormat(content: content)
        let lines = content.components(separatedBy: .newlines)

        // Map columns from headers
        let columnMapping = CSVParser.mapColumns(headers: headers)

        // Initialize tracking variables
>>>>>>> 1cf3938 (Create working state for recovery)
        var transactionsImported = 0
        let accountsImported = 0
        let categoriesImported = 0
        var duplicatesSkipped = 0
        var errors: [String] = []

<<<<<<< HEAD
=======
        // Create helper instances
        let entityManager = ImportEntityManager(modelContext: modelContext)
        let validator = ImportValidator(modelContext: modelContext)

>>>>>>> 1cf3938 (Create working state for recovery)
        // Process data rows
        for (index, line) in lines.dropFirst().enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }

            do {
<<<<<<< HEAD
                let fields = parseCSVRow(trimmedLine)
=======
                let fields = CSVParser.parseCSVRow(trimmedLine)
>>>>>>> 1cf3938 (Create working state for recovery)
                let transaction = try await parseTransaction(
                    fields: fields,
                    columnMapping: columnMapping,
                    rowIndex: index + 2,
<<<<<<< HEAD
                    )

                if try await isDuplicate(transaction) {
=======
                    entityManager: entityManager
                )

                if try await validator.isDuplicate(transaction) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    duplicatesSkipped += 1
                } else {
                    modelContext.insert(transaction)
                    transactionsImported += 1
                }
            } catch {
                errors.append("Row \(index + 2): \(error.localizedDescription)")
            }
        }

        // Save context
        try modelContext.save()

        return ImportResult(
            success: errors.isEmpty,
            transactionsImported: transactionsImported,
            accountsImported: accountsImported,
            categoriesImported: categoriesImported,
            duplicatesSkipped: duplicatesSkipped,
<<<<<<< HEAD
            errors: errors,
            )
    }

    private func mapColumns(headers: [String]) -> ColumnMapping {
        var mapping = ColumnMapping()

        for (index, header) in headers.enumerated() {
            let normalizedHeader = header.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            // Date column mapping
            if normalizedHeader.contains("date") || normalizedHeader == "timestamp" {
                mapping.dateIndex = index
            }

            // Title/Description column mapping
            else if normalizedHeader.contains("description") ||
                        normalizedHeader.contains("title") ||
                        normalizedHeader.contains("merchant") ||
                        normalizedHeader.contains("payee") ||
                        normalizedHeader == "name" {
                mapping.titleIndex = index
            }

            // Amount column mapping
            else if normalizedHeader.contains("amount") ||
                        normalizedHeader.contains("value") ||
                        normalizedHeader == "sum" {
                mapping.amountIndex = index
            }

            // Type column mapping
            else if normalizedHeader.contains("type") ||
                        normalizedHeader.contains("transaction") {
                mapping.typeIndex = index
            }

            // Category column mapping
            else if normalizedHeader.contains("category") ||
                        normalizedHeader.contains("tag") {
                mapping.categoryIndex = index
            }

            // Account column mapping
            else if normalizedHeader.contains("account") ||
                        normalizedHeader.contains("bank") {
                mapping.accountIndex = index
            }

            // Notes column mapping
            else if normalizedHeader.contains("note") ||
                        normalizedHeader.contains("memo") ||
                        normalizedHeader.contains("comment") {
                mapping.notesIndex = index
            }
        }

        return mapping
=======
            errors: errors
        )
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    private func parseTransaction(
        fields: [String],
<<<<<<< HEAD
        columnMapping: ColumnMapping,
        rowIndex: Int,
        ) async throws -> FinancialTransaction {
        // Parse date
        guard let dateIndex = columnMapping.dateIndex,
              dateIndex < fields.count
        else {
            throw ImportError.missingRequiredField("date")
        }

        let dateString = fields[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let date = try parseDate(dateString)

        // Parse title
        guard let titleIndex = columnMapping.titleIndex,
              titleIndex < fields.count
        else {
            throw ImportError.missingRequiredField("title/description")
        }

        let title = fields[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw ImportError.emptyRequiredField("title")
        }

        // Parse amount
        guard let amountIndex = columnMapping.amountIndex,
              amountIndex < fields.count
        else {
            throw ImportError.missingRequiredField("amount")
        }

        let amountString = fields[amountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = try parseAmount(amountString)

        // Parse transaction type
        let transactionType: TransactionType
        if let typeIndex = columnMapping.typeIndex, typeIndex < fields.count {
            let typeString = fields[typeIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            transactionType = parseTransactionType(typeString, amount: amount)
        } else {
            // Infer from amount
            transactionType = amount >= 0 ? .income : .expense
        }

        // Get or create account
        let account = try await getOrCreateAccount(
            from: fields,
            columnMapping: columnMapping,
            )

        // Get or create category
        let category = try await getOrCreateCategory(
            from: fields,
            columnMapping: columnMapping,
            transactionType: transactionType,
            )

        // Parse notes
=======
        columnMapping: CSVColumnMapping,
        rowIndex: Int,
        entityManager: ImportEntityManager
    ) async throws -> FinancialTransaction {

        // Validate required fields
        try ImportValidator.validateRequiredFields(fields: fields, columnMapping: columnMapping)

        // Parse date, title, amount using focused parsers
        let dateIndex = columnMapping.dateIndex!
        let dateString = fields[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let date = try DataParser.parseDate(dateString)

        let titleIndex = columnMapping.titleIndex!
        let title = fields[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)

        let amountIndex = columnMapping.amountIndex!
        let amountString = fields[amountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = try DataParser.parseAmount(amountString)

        // Determine transaction type
        let transactionType: TransactionType
        if let typeIndex = columnMapping.typeIndex, typeIndex < fields.count {
            let typeString = fields[typeIndex].lowercased().trimmingCharacters(
                in: .whitespacesAndNewlines)
            transactionType = DataParser.parseTransactionType(typeString, amount: amount)
        } else {
            transactionType = amount >= 0 ? .income : .expense
        }

        // Get or create entities using entity manager
        let account = try await entityManager.getOrCreateAccount(
            from: fields, columnMapping: columnMapping)
        let category = try await entityManager.getOrCreateCategory(
            from: fields, columnMapping: columnMapping, transactionType: transactionType)

        // Parse optional notes
>>>>>>> 1cf3938 (Create working state for recovery)
        let notes: String?
        if let notesIndex = columnMapping.notesIndex, notesIndex < fields.count {
            let notesString = fields[notesIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            notes = notesString.isEmpty ? nil : notesString
        } else {
            notes = nil
        }

<<<<<<< HEAD
        // Create transaction
        let transaction = FinancialTransaction(
            title: title,
            amount: abs(amount), // Store as positive value
            date: date,
            transactionType: transactionType,
            notes: notes,
            )

        transaction.account = account
        transaction.category = category

        return transaction
    }

    private func parseDate(_ dateString: String) throws -> Date {
        let formatters = [
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "yyyy/MM/dd",
            "MM-dd-yyyy",
            "dd-MM-yyyy",
            "yyyy.MM.dd",
            "MM.dd.yyyy",
            "dd.MM.yyyy"
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        throw ImportError.invalidDateFormat(dateString)
    }

    private func parseAmount(_ amountString: String) throws -> Double {
        // Remove currency symbols and whitespace
        let cleanAmount = amountString
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let amount = Double(cleanAmount) else {
            throw ImportError.invalidAmountFormat(amountString)
        }

        return amount
    }

    private func parseTransactionType(_ typeString: String, amount: Double) -> TransactionType {
        let lowerType = typeString.lowercased()

        if lowerType.contains("income") ||
            lowerType.contains("deposit") ||
            lowerType.contains("credit") ||
            lowerType.contains("salary") ||
            lowerType.contains("payment received") {
            return .income
        } else if lowerType.contains("expense") ||
                    lowerType.contains("debit") ||
                    lowerType.contains("withdrawal") ||
                    lowerType.contains("payment") {
            return .expense
        } else {
            // Fallback to amount-based detection
            return amount >= 0 ? .income : .expense
        }
    }

    private func getOrCreateAccount(
        from fields: [String],
        columnMapping: ColumnMapping,
        ) async throws -> FinancialAccount {
        let accountName: String = if let accountIndex = columnMapping.accountIndex, accountIndex < fields.count {
            fields[accountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            "Imported Account"
        }

        // Try to find existing account
        let descriptor = FetchDescriptor<FinancialAccount>(
            predicate: #Predicate { account in
                account.name == accountName
            },
            )

        if let existingAccount = try modelContext.fetch(descriptor).first {
            return existingAccount
        }

        // Create new account
        let newAccount = FinancialAccount(
            name: accountName,
            balance: 0.0,
            iconName: "creditcard.fill",
            )

        modelContext.insert(newAccount)
        return newAccount
    }

    private func getOrCreateCategory(
        from fields: [String],
        columnMapping: ColumnMapping,
        transactionType: TransactionType,
        ) async throws -> ExpenseCategory {
        let categoryName: String = if let categoryIndex = columnMapping.categoryIndex, categoryIndex < fields.count {
            fields[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            transactionType == .income ? "Other Income" : "Other Expenses"
        }

        // Try to find existing category
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { category in
                category.name == categoryName
            },
            )

        if let existingCategory = try modelContext.fetch(descriptor).first {
            return existingCategory
        }

        // Create new category
        let newCategory = ExpenseCategory(
            name: categoryName,
            iconName: "folder.fill",
            )

        modelContext.insert(newCategory)
        return newCategory
    }

    private func isDuplicate(_ transaction: FinancialTransaction) async throws -> Bool {
        let title = transaction.title
        let amount = transaction.amount
        let date = transaction.date

        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { existingTransaction in
                existingTransaction.title == title &&
                    existingTransaction.amount == amount &&
                    existingTransaction.date == date
            },
            )

        return try !modelContext.fetch(descriptor).isEmpty
    }

    private func parseCSVRow(_ row: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = row.startIndex

        while i < row.endIndex {
            let char = row[i]

            if char == "\"" {
                if insideQuotes {
                    // Check if this is an escaped quote
                    let nextIndex = row.index(after: i)
                    if nextIndex < row.endIndex && row[nextIndex] == "\"" {
                        currentField.append("\"")
                        i = nextIndex
                    } else {
                        insideQuotes = false
                    }
                } else {
                    insideQuotes = true
                }
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }

            i = row.index(after: i)
        }

        fields.append(currentField)
        return fields
    }
}

// MARK: - Supporting Types

struct ColumnMapping {
    var dateIndex: Int?
    var titleIndex: Int?
    var amountIndex: Int?
    var typeIndex: Int?
    var categoryIndex: Int?
    var accountIndex: Int?
    var notesIndex: Int?
}

enum ImportError: LocalizedError {
    case fileAccessDenied
    case emptyFile
    case invalidFormat
    case missingRequiredField(String)
    case emptyRequiredField(String)
    case invalidDateFormat(String)
    case invalidAmountFormat(String)

    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            "Unable to access the selected file"
        case .emptyFile:
            "The selected file is empty"
        case .invalidFormat:
            "Invalid CSV format"
        case let .missingRequiredField(field):
            "Missing required field: \(field)"
        case let .emptyRequiredField(field):
            "Empty required field: \(field)"
        case let .invalidDateFormat(date):
            "Invalid date format: \(date)"
        case let .invalidAmountFormat(amount):
            "Invalid amount format: \(amount)"
        }
    }
=======
        // Create and configure transaction
        let transaction = FinancialTransaction(
            title: title,
            amount: abs(amount),
            date: date,
            transactionType: transactionType,
            notes: notes
        )

        transaction.account = account
        transaction.category = category
        return transaction
    }
>>>>>>> 1cf3938 (Create working state for recovery)
}
