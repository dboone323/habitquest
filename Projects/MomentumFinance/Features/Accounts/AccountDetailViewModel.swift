// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftUI
import SwiftData

@MainActor
@Observable
final class AccountDetailViewModel: ViewModelProtocol {
    // MARK: - State and Action Types for BaseViewModel

    struct State {
        var account: FinancialAccount?
        var transactions: [FinancialTransaction] = []
        var filteredTransactions: [FinancialTransaction] = []
        var timeRange: TimeRange = .month
        var showingAddTransaction: Bool = false
        var isAnalyzingInsights: Bool = false
        var spendingAnalysis: SpendingPatternAnalysis?
        var spendingInsightsSummary: String = ""
        var topSpendingCategories: [CategoryAnalysis] = []
        var financialInsights: [FinancialInsight] = []
        var actionableInsightsCount: Int = 0
        var expensePredictions: ExpensePrediction?
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action {
        case loadAccount(FinancialAccount)
        case filterTransactions
        case toggleAddTransaction
        case loadAIInsights
        case setError(String?)
    }

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "3 Months"
        case year = "Year"
        case all = "All Time"

        var days: Int? {
            switch self {
            case .week: 7
            case .month: 30
            case .quarter: 90
            case .year: 365
            case .all: nil
            }
        }
    }

    var state = State()
    var isLoading: Bool = false
    var errorMessage: String?

    private var modelContext: ModelContext?

    // MARK: - ViewModelProtocol Implementation

    @MainActor
    func handle(_ action: Action) {
        Task {
            await handleAsync(action)
        }
    }

    @MainActor
    private func handleAsync(_ action: Action) async {
        switch action {
        case .loadAccount(let account):
            loadAccount(account)
        case .filterTransactions:
            filterTransactions()
        case .toggleAddTransaction:
            toggleAddTransaction()
        case .loadAIInsights:
            await loadAIInsights()
        case .setError(let message):
            self.state.errorMessage = message
        }
    }

    // MARK: - Public Methods

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Private Methods

    @MainActor
    private func loadAccount(_ account: FinancialAccount) {
        self.state.account = account
        self.state.transactions = account.transactions?.sorted { $0.date > $1.date } ?? []
        filterTransactions()
    }

    @MainActor
    private func filterTransactions() {
        guard let days = self.state.timeRange.days else {
            self.state.filteredTransactions = self.state.transactions
            return
        }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        self.state.filteredTransactions = self.state.transactions.filter { $0.date >= cutoffDate }
    }

    @MainActor
    private func toggleAddTransaction() {
        self.state.showingAddTransaction.toggle()
    }

    @MainActor
    private func loadAIInsights() async {
        guard let account = self.state.account, let modelContext = self.modelContext else { return }

        self.state.isAnalyzingInsights = true
        defer { self.state.isAnalyzingInsights = false }

        do {
            let insightsService = FinancialInsightsService(modelContext: modelContext)

            // Analyze spending patterns
            let spendingAnalysis = try await insightsService.analyzeSpendingPatterns(for: account.id.uuidString)
            self.state.spendingAnalysis = spendingAnalysis

            // Generate insights summary
            self.state.spendingInsightsSummary = generateSpendingInsightsSummary(spendingAnalysis)

            // Get top spending categories
            self.state.topSpendingCategories = spendingAnalysis.categoryAnalysis
                .sorted { $0.amount > $1.amount }
                .prefix(3)
                .map { $0 }

            // Generate personalized insights
            let insights = try await insightsService.generatePersonalizedInsights(for: account.id.uuidString)
            self.state.financialInsights = insights
            self.state.actionableInsightsCount = insights.filter { $0.actionable }.count

            // Get expense predictions
            let predictions = try await insightsService.predictFutureExpenses(for: account.id.uuidString, months: 3)
            self.state.expensePredictions = predictions

        } catch {
            self.state.errorMessage = "Failed to load AI insights: \(error.localizedDescription)"
        }
    }

    private func generateSpendingInsightsSummary(_ analysis: SpendingPatternAnalysis) -> String {
        let savingsRatePercent = Int(analysis.savingsRate * 100)
        let topCategory = analysis.categoryAnalysis.max(by: { $0.amount < $1.amount })

        var summary = "You're saving \(savingsRatePercent)% of your income. "

        if let category = topCategory {
            let categoryPercent = Int(category.percentage * 100)
            summary += "\(category.category.rawValue.capitalized) is your biggest expense at \(categoryPercent)% of total spending."
        }

        if analysis.hasIrregularSpending {
            summary += " Your spending patterns show some irregularity that could benefit from budgeting."
        }

        return summary
    }
}
