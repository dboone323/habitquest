import Foundation
import SwiftData
import SwiftUI
import UserNotifications

// Import InsightType from FinancialIntelligenceAnalysis
// NOTE: InsightType is defined in Shared/Intelligence/FinancialIntelligenceAnalysis.swift

// Temporary definition of InsightType to resolve compilation issues
public enum InsightType: Sendable {
    case spendingPattern, anomaly, budgetAlert, forecast, optimization, budgetRecommendation,
         positiveSpendingTrend

    public var displayName: String {
        switch self {
        case .spendingPattern: "Spending Pattern"
        case .anomaly: "Anomaly"
        case .budgetAlert: "Budget Alert"
        case .forecast: "Forecast"
        case .optimization: "Optimization"
        case .budgetRecommendation: "Budget Recommendation"
        case .positiveSpendingTrend: "Positive Spending Trend"
        }
    }

    public var icon: String {
        switch self {
        case .spendingPattern: "chart.line.uptrend.xyaxis"
        case .anomaly: "exclamationmark.triangle"
        case .budgetAlert: "bell"
        case .forecast: "chart.xyaxis.line"
        case .optimization: "arrow.up.right.circle"
        case .budgetRecommendation: "lightbulb"
        case .positiveSpendingTrend: "arrow.down.circle"
        }
    }
}

// MARK: - REMOVED: Types moved to proper files

// - CoreFinancialModels.swift: FinancialAccount, ExpenseCategory, FinancialTransaction, Budget
// - FinancialIntelligenceModels.swift: FinancialInsight, InsightPriority, ForecastData
// - DataImportModels.swift: ValidationError, ImportResult, CSVColumnMapping
// - ThemeModels.swift: ThemeMode, ColorDefinitions, DarkModePreference
// - TransactionModels.swift: TransactionFilter, BreadcrumbItem, DeepLink
// - FinancialServices.swift: EntityManager, DefaultEntityManager, ExportEngineService, FinancialMLModels, TransactionPatternAnalyzer
// - AnimationComponents.swift: AnimatedCardComponent, AnimatedButtonComponent, etc.
// - ImportComponents.swift: DataImportHeaderComponent, FileSelectionComponent, etc.
// - InsightsComponents.swift: InsightsLoadingView, InsightRowView, etc.
// - TransactionComponents.swift: TransactionEmptyStateView, TransactionListView, etc.
// - ButtonStyles.swift: PrimaryButtonStyle, SecondaryButtonStyle, etc.
// - ThemeDemoComponents.swift: ThemeSelectorCard, ThemeFinancialSummaryCard, etc.
// - ThemeSettingsComponents.swift: ThemeBudgetProgress, ThemeSettingsSheet, etc.
// - FinancialUtilities.swift: formatCurrency, fi_* functions

// MARK: - ModelContext for compatibility

#if !canImport(SwiftData)
    public struct ModelContext: Sendable {
        public init() {}
    }
#endif
