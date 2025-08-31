// Minimal data import helper stubs to satisfy DataImporter compilation.
// These are intentionally small, canonical helpers. Replace with full implementations later.

import Foundation
import SwiftData

// Result type returned by DataImporter
struct ImportResult {
    let success: Bool
    let transactionsImported: Int
    let accountsImported: Int
    let categoriesImported: Int
    let duplicatesSkipped: Int
    let errors: [String]
}

// Errors thrown during import
enum ImportError: Error {
    case fileAccessDenied
    case invalidFormat(String)
    case parsingError(String)
}

// Column mapping extracted from CSV headers
struct ColumnMapping {
    var dateIndex: Int?
    var titleIndex: Int?
    var amountIndex: Int?
    var typeIndex: Int?
    var notesIndex: Int?
}

// CSV parsing helpers (very small, permissive)
enum CSVParser {
    static func mapColumns(headers: [String]) -> ColumnMapping {
        var mapping = ColumnMapping()
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
        // naive split on comma; real CSV support should replace this
        line.split(separator: ",").map { String($0) }
    }
}

// Basic validators used by DataImporter
struct ImportValidator {
    let modelContext: ModelContext?
    init(modelContext: ModelContext? = nil) { self.modelContext = modelContext }

    static func validateCSVFormat(content: String) throws -> [String] {
        let lines = content.components(separatedBy: .newlines)
        guard let header = lines.first else { throw ImportError.invalidFormat("Empty CSV") }
        let headers = header.split(separator: ",").map { String($0) }
        return headers
    }

    static func validateRequiredFields(fields: [String], columnMapping: ColumnMapping) throws {
        if columnMapping.dateIndex == nil || columnMapping.titleIndex == nil
            || columnMapping.amountIndex == nil
        {
            throw ImportError.invalidFormat("Required columns missing: date/title/amount")
        }
    }

    func isDuplicate(_ transaction: FinancialTransaction) async throws -> Bool {
        // naive: always return false; real implementation should check modelContext
        false
    }
}

// Parsers for individual field types
enum DataParser {
    static func parseDate(_ s: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        if let d = formatter.date(from: s) { return d }
        // fallback to a simple date format
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

// Simple EntityManager stub that can create or find accounts/categories
actor EntityManager {
    let modelContext: ModelContext
    init(modelContext: ModelContext) { self.modelContext = modelContext }

    func getOrCreateAccount(from fields: [String], columnMapping: ColumnMapping) async throws
        -> FinancialAccount
    {
        // Create a placeholder account for now
        FinancialAccount(name: "Imported Account", balance: 0.0, currencyCode: "USD")
    }

    func getOrCreateCategory(
        from fields: [String], columnMapping: ColumnMapping, transactionType: TransactionType
    ) async throws -> ExpenseCategory {
        ExpenseCategory(name: "Imported", rule: "imported")
    }
}
