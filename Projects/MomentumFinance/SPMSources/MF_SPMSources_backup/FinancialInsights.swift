import Foundation

public enum InsightPriority: Int, Comparable, Sendable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3

    public static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public enum InsightType: Sendable {
    case budgetRecommendation
    case anomaly
    case informational
    case spendingAlert
    case savingsOpportunity
    case prediction
}

public struct FinancialInsight: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let insightDescription: String
    public let type: InsightType
    public let priority: InsightPriority

    public init(
        id: UUID = UUID(),
        title: String,
        insightDescription: String,
        type: InsightType,
        priority: InsightPriority
    ) {
        self.id = id
        self.title = title
        self.insightDescription = insightDescription
        self.type = type
        self.priority = priority
    }
}

// MARK: - Budget Recommendations

public func fi_findBudgetRecommendations(
    transactions: [FinancialTransaction],
    budgets: [Budget],
    calendar: Calendar = .current
) -> [FinancialInsight] {
    let expenses = transactions.filter { $0.transactionType == .expense }
    guard expenses.count >= 3 else { return [] }

    let budgetsByCategory: [String: Budget] = budgets.reduce(into: [:]) { result, budget in
        guard let name = budget.category?.name else { return }
        result[name] = budget
    }

    let groupedTransactions = Dictionary(grouping: expenses) { transaction in
        transaction.category?.name ?? "General"
    }

    var insights: [FinancialInsight] = []

    for (category, categoryTransactions) in groupedTransactions {
        let uniqueMonths = Set(categoryTransactions.map { transaction -> Date in
            calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date)) ?? transaction.date
        })
        guard uniqueMonths.count >= 3 else { continue }

        let totalSpent = categoryTransactions.reduce(0) { $0 + abs($1.amount) }
        let averageSpent = totalSpent / Double(uniqueMonths.count)

        if let budget = budgetsByCategory[category] {
            let limit = budget.limitAmount
            if averageSpent > limit * 1.25 {
                let title = "Review the \(category) budget"
                let description = "The current limit of \(currencyString(for: limit)) appears too low compared to recent spending averaging \(currencyString(for: averageSpent)). This budget may be too low for \(category)."
                insights.append(
                    FinancialInsight(
                        title: title,
                        insightDescription: description,
                        type: .budgetRecommendation,
                        priority: .medium
                    )
                )
            }
        } else {
            let title = "Consider setting a \(category) budget"
            let description = "Historical spending averages \(currencyString(for: averageSpent)) — consider setting a budget to encourage mindful spending for \(category)."
            let priority: InsightPriority = averageSpent > 250 ? .high : .medium
            insights.append(
                FinancialInsight(
                    title: title,
                    insightDescription: description,
                    type: .budgetRecommendation,
                    priority: priority
                )
            )
        }
    }

    return insights
}

// MARK: - Anomaly Detection Helpers

public func fi_detectCategoryOutliers(_ transactions: [FinancialTransaction]) -> [FinancialInsight] {
    let expenses = transactions.filter { $0.transactionType == .expense }
    guard expenses.count >= 2 else { return [] }

    let sortedByMagnitude = expenses.sorted { abs($0.amount) > abs($1.amount) }
    guard let largest = sortedByMagnitude.first else { return [] }
    let remaining = Array(sortedByMagnitude.dropFirst())
    let baselineAverage = remaining.isEmpty ? 0 : remaining.reduce(0) { $0 + abs($1.amount) } / Double(remaining.count)

    if baselineAverage == 0 {
        guard abs(largest.amount) >= 150 else { return [] }
    } else if abs(largest.amount) < baselineAverage * 2 {
        return []
    }

    let categoryName = largest.category?.name ?? "Spending"
    let title = "Unusual Spending Detected in \(categoryName)"
    let description = "Transaction \(largest.title) for \(currencyString(for: abs(largest.amount))) stands out compared to recent history in \(categoryName)."

    return [FinancialInsight(
        title: title,
        insightDescription: description,
        type: .anomaly,
        priority: .high
    )]
}

public func fi_detectRecentFrequencyAnomalies(
    _ transactions: [FinancialTransaction],
    days: Int,
    calendar: Calendar = .current
) -> [FinancialInsight] {
    guard days > 0 else { return [] }
    let cutoff = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    let recent = transactions.filter { $0.date >= cutoff }
    guard !recent.isEmpty else { return [] }

    let groupedByDay = Dictionary(grouping: recent) { transaction in
        calendar.startOfDay(for: transaction.date)
    }

    guard let latestDay = groupedByDay.keys.max(), let latestTransactions = groupedByDay[latestDay] else { return [] }
    let latestCount = latestTransactions.count
    let otherCounts = groupedByDay.filter { $0.key != latestDay }.map(\.value.count)
    let averageCount = otherCounts.isEmpty ? 0 : Double(otherCounts.reduce(0, +)) / Double(otherCounts.count)

    let threshold = max(4, Int(ceil(max(1, averageCount) * 1.8)))
    guard latestCount >= threshold else { return [] }

    let categoryName = latestTransactions.first?.category?.name ?? "Spending"
    let description = "Spending frequency for \(categoryName) spiked to \(latestCount) purchases in a single day, significantly higher than the typical \(String(format: "%.1f", averageCount))."

    return [FinancialInsight(
        title: "High activity detected for \(categoryName)",
        insightDescription: description,
        type: .anomaly,
        priority: .medium
    )]
}

public func fi_suggestDuplicatePaymentInsights(transactions: [FinancialTransaction]) -> [FinancialInsight] {
    guard transactions.count >= 2 else { return [] }

    let groupedByTitle = Dictionary(grouping: transactions) { $0.title }

    var insights: [FinancialInsight] = []
    let calendar = Calendar.current

    for (title, group) in groupedByTitle {
        let sorted = group.sorted { $0.date < $1.date }
        guard sorted.count >= 2 else { continue }

        var foundDuplicate = false
        for index in 1 ..< sorted.count {
            let previous = sorted[index - 1]
            let current = sorted[index]
            let difference = calendar.dateComponents([.day], from: previous.date, to: current.date).day ?? Int.max
            let amountsMatch = abs(previous.amount - current.amount) < 0.01
            if abs(difference) <= 3, amountsMatch {
                foundDuplicate = true
                break
            }
        }

        if foundDuplicate {
            let amountString = currencyString(for: abs(sorted.first?.amount ?? 0))
            let description = "Detected multiple \(title) payments of \(amountString) within a few days."
            insights.append(
                FinancialInsight(
                    title: "Possible duplicate payment for \(title)",
                    insightDescription: description,
                    type: .anomaly,
                    priority: .medium
                )
            )
        }
    }

    return insights
}

// MARK: - Helpers

private func currencyString(for amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
}
