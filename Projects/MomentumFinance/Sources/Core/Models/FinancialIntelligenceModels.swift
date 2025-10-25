import Foundation

// MARK: - Financial Intelligence Types

/// Intelligence priority levels for financial insights
public enum IntelligencePriority: String, CaseIterable, Sendable {
    case low, medium, high, urgent

    public var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    public var color: String {
        switch self {
        case .low: "green"
        case .medium: "yellow"
        case .high: "orange"
        case .urgent: "red"
        }
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
