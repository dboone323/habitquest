//
//  FinancialIntelligenceAutoAnalysis.swift
//  MomentumFinance
//
//  Created by Automated Code Generation
//  Component extracted from AdvancedFinancialIntelligence.swift
//  Contains auto-analysis functionality
//

import Combine
import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

/// Component containing auto-analysis methods
/// Extracted from AdvancedFinancialIntelligence to maintain file size limits
struct FinancialIntelligenceAutoAnalysis {
    let analysisComponent: FinancialIntelligenceAnalysis

    #if canImport(SwiftData)
    let dataProvider: AdvancedFinancialDataProvider?
    let autoAnalysisErrorHandler: (Error) -> Void

    init(
        analysisComponent: FinancialIntelligenceAnalysis,
        dataProvider: AdvancedFinancialDataProvider?,
        autoAnalysisErrorHandler: @escaping (Error) -> Void
    ) {
        self.analysisComponent = analysisComponent
        self.dataProvider = dataProvider
        self.autoAnalysisErrorHandler = autoAnalysisErrorHandler
    }
    #else
    init(analysisComponent: FinancialIntelligenceAnalysis) {
        self.analysisComponent = analysisComponent
        self.dataProvider = nil
        self.autoAnalysisErrorHandler = { _ in }
    }
    #endif

    // MARK: - Auto Analysis Methods

    func setupAutoAnalysis() -> AnyPublisher<Date, Never> {
        #if canImport(SwiftData)
        guard self.dataProvider != nil else { return Empty().eraseToAnyPublisher() }
        #endif
        // Setup automatic analysis every 24 hours
        return Timer.publish(every: 86400, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    func performAutoAnalysis() async {
        #if canImport(SwiftData)
        guard let dataProvider else { return }

        do {
            let snapshot = try await dataProvider.makeSnapshot()
            let payload = self.makeAutoAnalysisPayload(from: snapshot)

            if payload.transactions.isEmpty, payload.accounts.isEmpty, payload.budgets.isEmpty {
                // Return empty results - would normally update published properties
                return
            }

            // Perform analysis using the analysis component
            _ = await self.analysisComponent.analyzeSpendingPatterns(payload.transactions)
            _ = await self.analysisComponent.analyzeSavingsOpportunities(payload.transactions, payload.accounts)
            _ = await self.analysisComponent.analyzeBudgetPerformance(payload.transactions, payload.budgets)
            _ = await self.analysisComponent.assessFinancialRisk(payload.transactions, payload.accounts)
            _ = await self.analysisComponent.generatePredictions(payload.transactions, payload.accounts)

        } catch {
            self.autoAnalysisErrorHandler(error)
        }
        #else
        // Auto-analysis requires SwiftData-backed storage; no-op when unavailable.
        #endif
    }

    #if canImport(SwiftData)
    private func makeAutoAnalysisPayload(from snapshot: AdvancedFinancialSnapshot) -> AutoAnalysisPayload {
        AutoAnalysisPayload(
            transactions: snapshot.transactions,
            accounts: snapshot.accounts,
            budgets: snapshot.budgets
        )
    }
    #endif
}

#if canImport(SwiftData)
private struct AutoAnalysisPayload {
    let transactions: [Transaction]
    let accounts: [Account]
    let budgets: [AIBudget]
}
#endif
