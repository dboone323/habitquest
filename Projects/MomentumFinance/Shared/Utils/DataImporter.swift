@preconcurrency import Foundation
@preconcurrency import SwiftData

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
    case missingRequiredField(String)
    case emptyRequiredField(String)
    case emptyFile
    case invalidDateFormat(String)
    case invalidAmountFormat(String)
}

/// Handles importing financial data from CSV files
@ModelActor
actor DataImporter {

    /// Imports data from a CSV file
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
        // Validate CSV format and extract headers
        let headers = try ImportValidator.validateCSVFormat(content: content)
        let lines = content.components(separatedBy: .newlines)

        // Map columns from headers
        let columnMapping = CSVParser.mapColumns(headers: headers)

        // Initialize tracking variables
        var transactionsImported = 0
        let accountsImported = 0
        let categoriesImported = 0
        var duplicatesSkipped = 0
        var errors: [String] = []

        // Create helper instances
        let entityManager = DefaultEntityManager()
        let validator = ImportValidator()

        // Process data rows
        for (index, line) in lines.dropFirst().enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }

            do {
                let fields = CSVParser.parseCSVRow(trimmedLine)
                let transaction = try await parseTransaction(
                    fields: fields,
                    columnMapping: columnMapping,
                    rowIndex: index + 2,
                    entityManager: entityManager
                )

                if try await validator.isDuplicate(transaction) {
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
            errors: errors.map { ValidationError(field: "import", message: $0) }
        )
    }

    private func parseTransaction(
        fields: [String],
        columnMapping: CSVColumnMapping,
        rowIndex: Int,
        entityManager: EntityManager
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
            from: fields, columnMapping: columnMapping
        )
        let category = try await entityManager.getOrCreateCategory(
            from: fields, columnMapping: columnMapping, transactionType: transactionType
        )

        // Parse optional notes
        let notes: String?
        if let notesIndex = columnMapping.notesIndex, notesIndex < fields.count {
            let notesString = fields[notesIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            notes = notesString.isEmpty ? nil : notesString
        } else {
            notes = nil
        }

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
}
