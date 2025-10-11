//
//  ImportValidator.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import SwiftData

/// Handles validation and duplicate detection for imported data
struct ImportValidator {
    let modelContext: ModelContext

    /// Checks if a transaction already exists in the database
    func isDuplicate(_ transaction: FinancialTransaction) async throws -> Bool {
        let title = transaction.title
        let amount = transaction.amount
        let date = transaction.date

        let descriptor = FetchDescriptor<FinancialTransaction>(
            predicate: #Predicate { existingTransaction in
                existingTransaction.title == title &&
                    existingTransaction.amount == amount &&
                    existingTransaction.date == date
            }
        )

        return try !self.modelContext.fetch(descriptor).isEmpty
    }

    /// Validates required fields are present and not empty
    static func validateRequiredFields(
        fields: [String],
        columnMapping: CSVColumnMapping
    ) throws {
        // Validate date field
        guard let dateIndex = columnMapping.dateIndex,
              dateIndex < fields.count
        else {
            throw ImportError.missingRequiredField("date")
        }

        // Validate title field
        guard let titleIndex = columnMapping.titleIndex,
              titleIndex < fields.count
        else {
            throw ImportError.missingRequiredField("title/description")
        }

        let title = fields[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw ImportError.emptyRequiredField("title")
        }

        // Validate amount field
        guard let amountIndex = columnMapping.amountIndex,
              amountIndex < fields.count
        else {
            throw ImportError.missingRequiredField("amount")
        }
    }

    /// Validates CSV format and headers
    static func validateCSVFormat(content: String) throws -> [String] {
        let lines = content.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
            throw ImportError.emptyFile
        }

        // Parse header row
        let headerLine = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let headers = CSVParser.parseCSVRow(headerLine).map { $0.lowercased() }

        guard !headers.isEmpty else {
            throw ImportError.invalidFormat("CSV file has no headers")
        }

        return headers
    }
}
