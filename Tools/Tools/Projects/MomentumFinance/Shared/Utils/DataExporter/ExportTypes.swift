import Foundation

// MARK: - Export Settings

/// Configuration for data export operations
struct ExportSettings {
    let format: ExportFormat
    let startDate: Date
    let endDate: Date

    // Data inclusion flags
    let includeTransactions: Bool
    let includeAccounts: Bool
    let includeBudgets: Bool
    let includeSubscriptions: Bool
    let includeGoals: Bool

    init(
        format: ExportFormat,
        startDate: Date,
        endDate: Date,
        includeTransactions: Bool = true,
        includeAccounts: Bool = true,
        includeBudgets: Bool = true,
        includeSubscriptions: Bool = true,
        includeGoals: Bool = true
    ) {
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

/// Supported export formats
enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
    case json = "JSON"

    var fileExtension: String {
        switch self {
        case .csv: "csv"
        case .pdf: "pdf"
        case .json: "json"
        }
    }

    var mimeType: String {
        switch self {
        case .csv: "text/csv"
        case .pdf: "application/pdf"
        case .json: "application/json"
        }
    }
}

// MARK: - Export Error

/// Errors that can occur during export operations
enum ExportError: LocalizedError {
    case invalidSettings
    case dataFetchFailed
    case fileCreationFailed
    case pdfGenerationFailed

    var errorDescription: String? {
        switch self {
        case .invalidSettings:
            "Invalid export settings"
        case .dataFetchFailed:
            "Failed to fetch data"
        case .fileCreationFailed:
            "Failed to create export file"
        case .pdfGenerationFailed:
            "Failed to generate PDF"
        }
    }
}
