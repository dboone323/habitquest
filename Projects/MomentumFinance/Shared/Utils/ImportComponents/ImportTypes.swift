//
//  ImportTypes.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

/// Result of a data import operation
struct ImportResult {
    let success: Bool
    let transactionsImported: Int
    let accountsImported: Int
    let categoriesImported: Int
    let duplicatesSkipped: Int
    let errors: [String]
}

/// Errors that can occur during data import
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
}
