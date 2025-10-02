//
//  FinancialIntelligenceModels.swift
//  MomentumFinance
//
//  Data models and types for Advanced Financial Intelligence
//  Extracted from AdvancedFinancialIntelligence.swift to reduce file size
//

import Foundation

// MARK: - Enhanced Financial Insight Model

/// Comprehensive financial insight with AI-generated recommendations
public struct EnhancedFinancialInsight: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let priority: InsightPriority
    public let type: InsightType
    public let confidence: Double
    public let relatedAccountId: String?
    public let relatedTransactionId: String?
    public let relatedCategoryId: String?
    public let relatedBudgetId: String?
    public let actionRecommendations: [String]
    public let potentialSavings: Double?
    public let impactScore: Double // 0-10 scale
    public let createdAt: Date

    public init(
        title: String,
        description: String,
        priority: InsightPriority,
        type: InsightType,
        confidence: Double = 0.8,
        relatedAccountId: String? = nil,
        relatedTransactionId: String? = nil,
        relatedCategoryId: String? = nil,
        relatedBudgetId: String? = nil,
        actionRecommendations: [String] = [],
        potentialSavings: Double? = nil,
        impactScore: Double = 5.0
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.confidence = confidence
        self.relatedAccountId = relatedAccountId
        self.relatedTransactionId = relatedTransactionId
        self.relatedCategoryId = relatedCategoryId
        self.relatedBudgetId = relatedBudgetId
        self.actionRecommendations = actionRecommendations
        self.potentialSavings = potentialSavings
        self.impactScore = impactScore
        self.createdAt = Date()
    }
}

// MARK: - Supporting Types

/// Priority levels for financial insights
public enum InsightPriority: Int, CaseIterable, Hashable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

/// Types of financial insights that can be generated
public enum InsightType: Hashable {
    case spendingAlert
    case savingsOpportunity
    case budgetAlert
    case categoryInsight
    case riskAlert
    case prediction
    case recommendation
}

/// Comprehensive risk assessment across different financial areas
public struct RiskAssessment {
    let overallRiskLevel: RiskLevel
    let emergencyFundRisk: RiskLevel
    let debtRisk: RiskLevel
    let investmentRisk: RiskLevel
    let cashFlowRisk: RiskLevel
}

/// Risk severity levels
public enum RiskLevel {
    case low, medium, moderate, high, critical
}

/// Predictive analytics for future financial performance
public struct PredictiveAnalytics {
    let nextMonthSpending: Double
    let nextMonthIncome: Double
    let savingsProjection: Double
    let budgetVarianceProjection: Double // 0-1 scale
}

/// Rate of spending change over time
public struct SpendingVelocity {
    let percentageIncrease: Double
}

/// Trend analysis for spending categories
public struct CategoryTrend {
    let category: String
    let categoryId: String
    let isSignificant: Bool
    let description: String
    let priority: InsightPriority
    let confidence: Double
    let recommendations: [String]
    let impactScore: Double
}

/// Subscription service information
public struct Subscription {
    let name: String
    let monthlyAmount: Double
    let lastUsed: Date?
}

/// Investment recommendation with risk and return estimates
public struct InvestmentRecommendation {
    let type: String
    let allocation: Double
    let riskLevel: RiskLevel
    let expectedReturn: Double
}

/// Cash flow prediction for future months
public struct CashFlowPrediction {
    let month: Date
    let predictedIncome: Double
    let predictedExpenses: Double
    let netCashFlow: Double
}

/// Detected transaction anomaly
public struct TransactionAnomaly {
    let transaction: Transaction
    let anomalyType: AnomalyType
    let confidence: Double
}

/// Types of transaction anomalies that can be detected
public enum AnomalyType {
    case unusualAmount
    case unusualMerchant
    case unusualLocation
    case unusualTime
    case possibleFraud
}

/// Investment holding information
public struct Investment {
    let symbol: String
    let shares: Double
    let currentValue: Double
}

/// Risk tolerance preferences for investment recommendations
public enum RiskTolerance {
    case conservative, moderate, aggressive
}

/// Investment time horizon preferences
public enum TimeHorizon {
    case shortTerm, mediumTerm, longTerm
}

/// Budget period types
public enum BudgetPeriod {
    case monthly, yearly
}
