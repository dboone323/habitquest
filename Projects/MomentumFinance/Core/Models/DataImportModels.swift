//
//  DataImportModels.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-01-27.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation

// MARK: - Column Mapping

/// Represents mapping between CSV columns and data model properties
public struct ColumnMapping: Codable {
    public let csvColumn: String
    public let modelProperty: String
    public let dataType: DataType
    public let isRequired: Bool
    public let defaultValue: String?

    public init(
        csvColumn: String,
        modelProperty: String,
        dataType: DataType,
        isRequired: Bool = false,
        defaultValue: String? = nil
    ) {
        self.csvColumn = csvColumn
        self.modelProperty = modelProperty
        self.dataType = dataType
        self.isRequired = isRequired
        self.defaultValue = defaultValue
    }
}

// MARK: - Data Type

/// Supported data types for import mapping
public enum DataType: String, CaseIterable, Codable {
    case string
    case integer
    case decimal
    case date
    case boolean

    public var displayName: String {
        switch self {
        case .string:
            "Text"
        case .integer:
            "Whole Number"
        case .decimal:
            "Decimal Number"
        case .date:
            "Date"
        case .boolean:
            "Yes/No"
        }
    }
}

// MARK: - Entity Manager

// EntityManager implementation moved to Shared/Utils/ImportComponents/EntityManager.swift

// MARK: - Entity Type

/// Types of entities that can be imported
public enum EntityType: String, CaseIterable, Codable {
    case transaction
    case account
    case category
    case budget
    case goal

    public var displayName: String {
        switch self {
        case .transaction:
            "Transaction"
        case .account:
            "Account"
        case .category:
            "Category"
        case .budget:
            "Budget"
        case .goal:
            "Goal"
        }
    }
}

// MARK: - Validation Error

/// Represents a data validation error during import
public struct ValidationError: Identifiable, Codable {
    public let id: UUID
    public let field: String
    public let message: String
    public let severity: Severity

    public init(
        id: UUID = UUID(),
        field: String,
        message: String,
        severity: Severity = .error
    ) {
        self.id = id
        self.field = field
        self.message = message
        self.severity = severity
    }

    public enum Severity: String, Codable {
        case warning
        case error

        public var displayName: String {
            switch self {
            case .warning:
                "Warning"
            case .error:
                "Error"
            }
        }
    }
}

// MARK: - Import Result

/// Represents the result of a data import operation
public struct ImportResult: Codable {
    public let success: Bool
    public let transactionsImported: Int
    public let accountsImported: Int
    public let categoriesImported: Int
    public let duplicatesSkipped: Int
    public let errors: [ValidationError]
    public let warnings: [ValidationError]

    public init(
        success: Bool,
        transactionsImported: Int,
        accountsImported: Int = 0,
        categoriesImported: Int = 0,
        duplicatesSkipped: Int = 0,
        errors: [ValidationError] = [],
        warnings: [ValidationError] = []
    ) {
        self.success = success
        self.transactionsImported = transactionsImported
        self.accountsImported = accountsImported
        self.categoriesImported = categoriesImported
        self.duplicatesSkipped = duplicatesSkipped
        self.errors = errors
        self.warnings = warnings
    }
}

// MARK: - CSV Column Mapping

/// CSV column mapping configuration
public struct CSVColumnMapping: Sendable {
    public let dateColumn: String
    public let amountColumn: String
    public let descriptionColumn: String
    public let categoryColumn: String?
    public let accountColumn: String?

    public init(
        dateColumn: String,
        amountColumn: String,
        descriptionColumn: String,
        categoryColumn: String? = nil,
        accountColumn: String? = nil
    ) {
        self.dateColumn = dateColumn
        self.amountColumn = amountColumn
        self.descriptionColumn = descriptionColumn
        self.categoryColumn = categoryColumn
        self.accountColumn = accountColumn
    }
}

// MARK: - CSV Column Mapping Extensions

extension CSVColumnMapping {
    var notesIndex: Int? {
        // Return a default notes column index or nil
        nil
    }
}
