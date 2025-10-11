//
//  CSVParser.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Handles CSV parsing and column mapping functionality
enum CSVParser {
    /// Parses a CSV row handling quoted fields and escaped quotes
    static func parseCSVRow(_ row: String) -> [String] {
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
                    if nextIndex < row.endIndex, row[nextIndex] == "\"" {
                        currentField.append("\"")
                        i = nextIndex
                    } else {
                        insideQuotes = false
                    }
                } else {
                    insideQuotes = true
                }
            } else if char == ",", !insideQuotes {
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

    /// Maps CSV headers to column indices for data extraction
    static func mapColumns(headers: [String]) -> CSVColumnMapping {
        var mapping = CSVColumnMapping()

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
    }
}

/// Maps CSV column headers to their respective indices
struct CSVColumnMapping {
    var dateIndex: Int?
    var titleIndex: Int?
    var amountIndex: Int?
    var typeIndex: Int?
    var categoryIndex: Int?
    var accountIndex: Int?
    var notesIndex: Int?
}
