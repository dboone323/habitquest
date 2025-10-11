import Foundation
import CoreML
import OSLog
import SwiftData
import SwiftUI

// Momentum Finance - Financial Intelligence Services
// Copyright © 2025 Momentum Finance. All rights reserved.

/// Central service that provides financial intelligence and machine learning insights
///
/// This main coordinator delegates to focused component implementations:
/// - TransactionPatternAnalyzer: Pattern detection and duplicate analysis
/// - FinancialMLModels: Machine learning models and predictions
/// - FinancialInsightModels: Insight data structures and enums
/// - FinancialIntelligenceService.Helpers: Analysis algorithms (existing)
@MainActor
public class FinancialIntelligenceService: ObservableObject {
    @MainActor static let shared = FinancialIntelligenceService()

    @Published var insights: [FinancialInsight] = []
    @Published var isAnalyzing: Bool = false
    @Published var lastAnalysisDate: Date?

    private let mlModels = FinancialMLModels.shared
    private let patternAnalyzer = TransactionPatternAnalyzer.shared

    private init() {
        // Initialization handled by component models
    }

    // MARK: - Analysis Methods

    /// Performs a comprehensive analysis of financial data
    func analyzeFinancialData(modelContext: ModelContext) async {
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.insights = []
        }

        do {
            // Fetch all data
            let transactionsDescriptor = FetchDescriptor<FinancialTransaction>()
            let transactions = try modelContext.fetch(transactionsDescriptor)

            let categoriesDescriptor = FetchDescriptor<ExpenseCategory>()
            let categories = try modelContext.fetch(categoriesDescriptor)

            let accountsDescriptor = FetchDescriptor<FinancialAccount>()
            let accounts = try modelContext.fetch(accountsDescriptor)

            let budgetsDescriptor = FetchDescriptor<Budget>()
            let budgets = try modelContext.fetch(budgetsDescriptor)

            // Delegate to specialized analysis methods in Helpers
            let spendingPatternInsights = self.analyzeSpendingPatterns(
                transactions: transactions, categories: categories
            )
            let anomalyInsights = self.detectAnomalies(transactions: transactions)
            let budgetInsights = self.analyzeBudgets(transactions: transactions, budgets: budgets)
            let forecastInsights = fi_generateForecasts(
                transactions: transactions, accounts: accounts
            )
            let optimizationInsights = self.suggestOptimizations(
                transactions: transactions,
                accounts: accounts
            )

            // Combine all insights and sort by priority
            var allInsights =
                spendingPatternInsights + anomalyInsights + budgetInsights + forecastInsights
                    + optimizationInsights
            allInsights.sort { $0.priority > $1.priority }

            // Update the UI
            DispatchQueue.main.async {
                self.insights = allInsights
                self.isAnalyzing = false
                self.lastAnalysisDate = Date()
            }
        } catch {
            print("Error analyzing financial data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAnalyzing = false
            }
        }
    }

    /// Categorizes a new transaction based on historical data
    func suggestCategoryForTransaction(_ transaction: FinancialTransaction) -> ExpenseCategory? {
        self.mlModels.suggestCategoryForTransaction(transaction)
    }

    // MARK: - Specific Analysis Methods (Delegate to Helpers)

    private func analyzeSpendingPatterns(
        transactions: [FinancialTransaction], categories: [ExpenseCategory]
    ) -> [FinancialInsight] {
        fi_analyzeSpendingPatterns(transactions: transactions, categories: categories)
    }

    private func detectAnomalies(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        fi_detectAnomalies(transactions: transactions)
    }

    private func analyzeBudgets(transactions: [FinancialTransaction], budgets: [Budget])
        -> [FinancialInsight] {
        fi_analyzeBudgets(transactions: transactions, budgets: budgets)
    }

    // Forecasting is implemented canonically in
    // FinancialIntelligenceService.Forecasting.swift — use fi_generateForecasts to call it.

    private func suggestOptimizations(
        transactions: [FinancialTransaction], accounts: [FinancialAccount]
    ) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        insights.append(
            contentsOf: fi_suggestIdleCashInsights(transactions: transactions, accounts: accounts)
        )
        insights.append(contentsOf: fi_suggestCreditUtilizationInsights(accounts: accounts))
        insights.append(contentsOf: fi_suggestDuplicatePaymentInsights(transactions: transactions))

        return insights
    }
}
