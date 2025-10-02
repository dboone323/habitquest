//
//  FinancialIntelligenceDataProvider.swift
//  MomentumFinance
//
//  Data provider protocol and implementation for Advanced Financial Intelligence
//  Extracted from AdvancedFinancialIntelligence.swift to reduce file size
//

import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

// MARK: - Data Provider Protocol

#if canImport(SwiftData)
/// Protocol for providing financial data snapshots to the AI system
@MainActor
public protocol AdvancedFinancialDataProvider: AnyObject {
    /// Create a snapshot of current financial data
    func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot
}

// MARK: - Domain Snapshot

/// Snapshot of financial domain objects for AI analysis
public struct AdvancedFinancialDomainSnapshot {
    public let transactions: [FinancialTransaction]
    public let accounts: [FinancialAccount]
    public let budgets: [Budget]

    public init(
        transactions: [FinancialTransaction],
        accounts: [FinancialAccount],
        budgets: [Budget]
    ) {
        self.transactions = transactions
        self.accounts = accounts
        self.budgets = budgets
    }
}

// MARK: - SwiftData Implementation

/// SwiftData-based implementation of the financial data provider
@MainActor
public final class SwiftDataAdvancedFinancialDataProvider: AdvancedFinancialDataProvider {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func makeSnapshot() async throws -> AdvancedFinancialDomainSnapshot {
        let transactions = try self.modelContext.fetch(FetchDescriptor<FinancialTransaction>())
        let accounts = try self.modelContext.fetch(FetchDescriptor<FinancialAccount>())
        let budgets = try self.modelContext.fetch(FetchDescriptor<Budget>())

        return AdvancedFinancialDomainSnapshot(
            transactions: transactions,
            accounts: accounts,
            budgets: budgets
        )
    }
}
#endif
