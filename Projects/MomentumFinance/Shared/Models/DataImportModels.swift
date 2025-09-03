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

/// Manages data entities during import process
public class EntityManager: @unchecked Sendable {
    public init() {}

    public func createEntity(type: EntityType, data: [String: Any]) -> Any? {
        // Implementation would go here
        nil
    }

    public func updateEntity(id: String, type: EntityType, data: [String: Any]) -> Bool {
        // Implementation would go here
        false
    }

    public func deleteEntity(id: String, type: EntityType) -> Bool {
        // Implementation would go here
        false
    }

    public func validateData(_ data: [String: Any], for type: EntityType) -> [ValidationError] {
        // Implementation would go here
        []
    }
}

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
