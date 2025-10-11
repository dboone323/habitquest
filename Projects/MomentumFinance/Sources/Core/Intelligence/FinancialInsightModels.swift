import Foundation
import SwiftUI

public enum FinancialInsightType: String, CaseIterable, Identifiable, Hashable {
    case spendingPattern, anomaly, budget, forecast, optimization, cashManagement,
         creditUtilization, duplicatePayment
    public var id: String { rawValue }
    public var icon: String {
        switch self {
        case .spendingPattern: "chart.pie.fill"
        case .anomaly: "exclamationmark.triangle.fill"
        case .budget: "chart.bar.fill"
        case .forecast: "chart.line.uptrend.xyaxis"
        case .optimization: "lightbulb.fill"
        case .cashManagement: "banknote"
        case .creditUtilization: "creditcard.fill"
        case .duplicatePayment: "repeat"
        }
    }
}

public struct FinancialInsight: Identifiable, Hashable {
    public let id = UUID()
    public let type: FinancialInsightType
    public let title: String
    public let description: String
    public let priority: Int
    public let createdAt: Date
    public init(
        type: FinancialInsightType, title: String, description: String, priority: Int,
        createdAt: Date = Date()
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.createdAt = createdAt
    }
}
