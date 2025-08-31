//
//  SearchTypes.swift
//  MomentumFinance - Search-related types
//
//  Created for build compatibility
//

import Foundation
import SwiftUI

// MARK: - Search Types

// This file contains utility helpers for search-related features.
// Canonical Search types and services are implemented under
// `Shared/Features/GlobalSearch/Components` and should be used by consumers.

// MARK: - Data Import Types

public struct ColumnMapping {
    public let sourceColumn: String
    public let targetField: String
    public let dataType: String

    public init(sourceColumn: String, targetField: String, dataType: String) {
        self.sourceColumn = sourceColumn
        self.targetField = targetField
        self.dataType = dataType
    }
}

public class EntityManager {
    public init() {}

    public func createEntity<T>(from data: [String: Any], type: T.Type) -> T? {
        // Placeholder implementation
        nil
    }
}

// MARK: - Intelligence Types

public class FinancialMLModels {
    public init() {}

    public func analyzeBudgetTrends() -> [String: Any] {
        [:]
    }

    public func predictSpending() -> [String: Any] {
        [:]
    }
}

public class TransactionPatternAnalyzer {
    public init() {}

    public func analyzePatterns() -> [String: Any] {
        [:]
    }

    public func findAnomalies() -> [String: Any] {
        [:]
    }
}
