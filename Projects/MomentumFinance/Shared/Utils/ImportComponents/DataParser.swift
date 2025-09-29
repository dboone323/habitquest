//
//  DataParser.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Handles parsing and validation of financial data from CSV fields
enum DataParser {
    /// Parses date strings using multiple common formats
    static func parseDate(_ dateString: String) throws -> Date {
        let formatters = [
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd/MM/yyyy",
            "yyyy/MM/dd",
            "MM-dd-yyyy",
            "dd-MM-yyyy",
            "yyyy.MM.dd",
            "MM.dd.yyyy",
            "dd.MM.yyyy",
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

    /// Parses amount strings removing currency symbols and formatting
    static func parseAmount(_ amountString: String) throws -> Double {
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

    /// Determines transaction type from string indicators or amount
    static func parseTransactionType(_ typeString: String, amount: Double) -> TransactionType {
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
}
