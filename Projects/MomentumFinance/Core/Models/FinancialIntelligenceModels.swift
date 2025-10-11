import Foundation

// MARK: - Financial Intelligence Types

/// Represents the type of financial insight
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

/// Represents a financial insight
public struct FinancialInsight: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let type: InsightType
    public let priority: InsightPriority
    public let confidence: Double
    public let value: Double?
    public let category: String?
    public let dateGenerated: Date
    public let actionable: Bool

    public init(
        title: String,
        description: String,
        type: InsightType,
        priority: InsightPriority,
        confidence: Double = 0.8,
        value: Double? = nil,
        category: String? = nil,
        dateGenerated: Date = Date(),
        actionable: Bool = false
    ) {
        self.title = title
        self.description = description
        self.type = type
        self.priority = priority
        self.confidence = confidence
        self.value = value
        self.category = category
        self.dateGenerated = dateGenerated
        self.actionable = actionable
    }
}

/// Priority levels for insights
public enum InsightPriority: Int, CaseIterable, Sendable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3

    public static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Represents forecast data
public struct ForecastData: Identifiable, Sendable {
    public let id = UUID()
    public let date: Date
    public let predictedBalance: Double
    public let confidence: Double

    public init(date: Date, predictedBalance: Double, confidence: Double) {
        self.date = date
        self.predictedBalance = predictedBalance
        self.confidence = confidence
    }
}
