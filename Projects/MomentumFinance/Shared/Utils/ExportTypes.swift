// Momentum Finance - Export Types
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation

// MARK: - Export Settings

public struct ExportSettings: Sendable {
    public let format: ExportFormat
    public let startDate: Date
    public let endDate: Date
    public let includeTransactions: Bool
    public let includeAccounts: Bool
    public let includeBudgets: Bool
    public let includeSubscriptions: Bool
    public let includeGoals: Bool

    public init(
        format: ExportFormat,
        startDate: Date,
        endDate: Date,
        includeTransactions: Bool,
        includeAccounts: Bool,
        includeBudgets: Bool,
        includeSubscriptions: Bool,
        includeGoals: Bool,
<<<<<<< HEAD
        ) {
=======
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        self.format = format
        self.startDate = startDate
        self.endDate = endDate
        self.includeTransactions = includeTransactions
        self.includeAccounts = includeAccounts
        self.includeBudgets = includeBudgets
        self.includeSubscriptions = includeSubscriptions
        self.includeGoals = includeGoals
    }
}

// MARK: - Export Format

public enum ExportFormat: String, CaseIterable, Sendable {
    case csv
    case pdf
    case json

    public var displayName: String {
        switch self {
        case .csv:
            "CSV"
        case .pdf:
            "PDF"
        case .json:
            "JSON"
        }
    }

    public var icon: String {
        switch self {
        case .csv:
            "tablecells"
        case .pdf:
            "doc.richtext"
        case .json:
            "curlybraces"
        }
    }

    public var description: String {
        switch self {
        case .csv:
            "Spreadsheet format, compatible with Excel and other apps"
        case .pdf:
            "Professional report format with charts and summaries"
        case .json:
            "Technical format for developers and data analysis"
        }
    }

    public var fileExtension: String {
        rawValue
    }

    public var mimeType: String {
        switch self {
        case .csv:
            "text/csv"
        case .pdf:
            "application/pdf"
        case .json:
            "application/json"
        }
    }
}

// MARK: - Date Range

public enum DateRange: String, CaseIterable, Sendable {
    case lastMonth
    case lastThreeMonths
    case lastSixMonths
    case lastYear
    case allTime
    case custom

    public var displayName: String {
        switch self {
        case .lastMonth:
            "Last Month"
        case .lastThreeMonths:
            "Last 3 Months"
        case .lastSixMonths:
            "Last 6 Months"
        case .lastYear:
            "Last Year"
        case .allTime:
            "All Time"
        case .custom:
            "Custom Range"
        }
    }
}
<<<<<<< HEAD
=======

// MARK: - Import Result

public struct ImportResult: Sendable {
    public let success: Bool
    public let transactionsImported: Int
    public let accountsImported: Int
    public let categoriesImported: Int
    public let duplicatesSkipped: Int
    public let errors: [String]

    public init(
        success: Bool,
        transactionsImported: Int,
        accountsImported: Int,
        categoriesImported: Int,
        duplicatesSkipped: Int,
        errors: [String]
    ) {
        self.success = success
        self.transactionsImported = transactionsImported
        self.accountsImported = accountsImported
        self.categoriesImported = categoriesImported
        self.duplicatesSkipped = duplicatesSkipped
        self.errors = errors
    }
}
>>>>>>> 1cf3938 (Create working state for recovery)
