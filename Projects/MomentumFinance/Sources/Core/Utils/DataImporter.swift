@preconcurrency import Foundation
@preconcurrency import SwiftData

// MARK: - Supporting Types

// ValidationError and ValidationSeverity moved to DataImportModels.swift

// MARK: - Data Import Coordinator

// This file coordinates the data import process using focused component modules.
// Each component is extracted for better maintainability and testing.

// Minimal helper stubs embedded here so the importer compiles deterministically.
// Replace with full implementations when available.

// Use the project's canonical `ImportResult` defined in
// Shared/Utils/ExportTypes.swift. Do not duplicate the type here.

// Errors thrown during import
public enum ImportError: Error {
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
    nonisolated func importFromCSV(fileURL: URL) async throws -> ImportResult {
        // Read the CSV file
        let csvContent = try String(contentsOf: fileURL, encoding: .utf8)

        // Parse CSV content
        let rows = parseCSV(csvContent)

        if rows.isEmpty {
            throw ImportError.emptyFile
        }

        // Assume first row is headers
        guard rows.count > 1 else {
            throw ImportError.invalidFormat("CSV must contain header row and at least one data row")
        }

        let headers = rows[0]
        let dataRows = Array(rows[1...])

        // Validate required columns exist
        guard let dateIndex = headers.firstIndex(of: "date"),
              let amountIndex = headers.firstIndex(of: "amount"),
              let descriptionIndex = headers.firstIndex(of: "description") else {
            throw ImportError.missingRequiredField("Required columns: date, amount, description")
        }

        var importedTransactions = 0
        var errors: [ValidationError] = []
        var warnings: [ValidationError] = []

        // Process each data row
        for (rowIndex, row) in dataRows.enumerated() {
            do {
                let transaction = try parseTransaction(from: row,
                                                     headers: headers,
                                                     dateIndex: dateIndex,
                                                     amountIndex: amountIndex,
                                                     descriptionIndex: descriptionIndex)

                // Save transaction to database
                try await saveTransaction(transaction)
                importedTransactions += 1

            } catch let error as ImportError {
                let validationError = ValidationError(
                    id: UUID(),
                    field: "import",
                    message: "Row \(rowIndex + 2): \(error.localizedDescription)",
                    severity: .error
                )
                errors.append(validationError)
            } catch {
                let validationError = ValidationError(
                    id: UUID(),
                    field: "import",
                    message: "Row \(rowIndex + 2): Unexpected error - \(error.localizedDescription)",
                    severity: .error
                )
                errors.append(validationError)
            }
        }

        return ImportResult(
            success: errors.isEmpty,
            transactionsImported: importedTransactions,
            accountsImported: 0,
            categoriesImported: 0,
            duplicatesSkipped: 0,
            errors: errors,
            warnings: warnings
        )
    }

    private nonisolated func parseCSV(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false

        for character in content {
            switch character {
            case "\"":
                insideQuotes.toggle()
            case ",":
                if insideQuotes {
                    currentField.append(character)
                } else {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentField = ""
                }
            case "\n":
                if insideQuotes {
                    currentField.append(character)
                } else {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    rows.append(currentRow)
                    currentRow = []
                    currentField = ""
                }
            default:
                currentField.append(character)
            }
        }

        // Handle last field and row
        currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private nonisolated func parseTransaction(from row: [String], headers: [String], dateIndex: Int, amountIndex: Int, descriptionIndex: Int) throws -> FinancialTransaction {
        guard row.count > max(dateIndex, amountIndex, descriptionIndex) else {
            throw ImportError.invalidFormat("Row has insufficient columns")
        }

        // Parse date
        let dateString = row[dateIndex]
        guard !dateString.isEmpty else {
            throw ImportError.emptyRequiredField("date")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Assume ISO format
        guard let date = dateFormatter.date(from: dateString) else {
            throw ImportError.invalidDateFormat(dateString)
        }

        // Parse amount
        let amountString = row[amountIndex]
        guard !amountString.isEmpty else {
            throw ImportError.emptyRequiredField("amount")
        }

        guard let amount = Double(amountString.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) else {
            throw ImportError.invalidAmountFormat(amountString)
        }

        // Parse description
        let description = row[descriptionIndex]
        guard !description.isEmpty else {
            throw ImportError.emptyRequiredField("description")
        }

        // Determine transaction type based on amount sign
        let transactionType: TransactionType = amount >= 0 ? .income : .expense

        return FinancialTransaction(
            title: description,
            amount: abs(amount),
            date: date,
            transactionType: transactionType
        )
    }

    private func saveTransaction(_ transaction: FinancialTransaction) async throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }
}
