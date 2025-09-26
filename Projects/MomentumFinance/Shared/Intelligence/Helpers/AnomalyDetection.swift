import Foundation

// MARK: - Anomaly Detection

/// Detect unusual spending patterns within categories
func fi_detectCategoryOutliers(_ transactions: [FinancialTransaction]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    var transactionsByCategory: [String: [FinancialTransaction]] = [:]
    for transaction in transactions where transaction.amount < 0 {
        guard let category = transaction.category else { continue }
        let categoryId = category.id.hashValue.description
        transactionsByCategory[categoryId, default: []].append(transaction)
    }

    for (_, categoryTransactions) in transactionsByCategory {
        guard categoryTransactions.count >= 5 else { continue }

        let amounts = categoryTransactions.map { abs($0.amount) }
        let mean = amounts.reduce(0, +) / Double(amounts.count)
        let variance = amounts.map { pow($0 - mean, 2) }.reduce(0, +) / Double(amounts.count)
        let stdDev = sqrt(variance)

        let outlierThreshold = mean + (2 * stdDev)
        let outliers = categoryTransactions.filter { abs($0.amount) > outlierThreshold }
            .sorted { abs($0.amount) > abs($1.amount) }

        if let topOutlier = outliers.first, let category = topOutlier.category {
            let transactionAmount = abs(topOutlier.amount)
            let percentageHigher = mean > 0 ? Int((transactionAmount / mean - 1) * 100) : 0
            let formattedAmount = fi_formatCurrency(transactionAmount, code: "USD")
            let formattedDate = fi_formatDateShort(topOutlier.date)
            let categoryName = category.name
            let titlePart = "\(topOutlier.title) (\(formattedAmount))"
            let restPart = " on \(formattedDate) is \(percentageHigher)% higher than your average \(categoryName) transaction."
            let descriptionText = titlePart + restPart

            let insight = FinancialInsight(
                title: "Unusual Spending in \(categoryName)",
                description: descriptionText,
                priority: .high,
                type: .anomaly,
                relatedTransactionId: topOutlier.id.hashValue.description,
                visualizationType: .boxPlot,
                data: [
                    ("Average", mean),
                    ("This Transaction", transactionAmount),
                    ("Typical Range", mean + stdDev),
                ]
            )
            insights.append(insight)
        }
    }
    return insights
}

/// Detect unusual transaction frequency patterns
func fi_detectRecentFrequencyAnomalies(_ transactions: [FinancialTransaction], days: Int = 30) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []
    let calendar = Calendar.current
    let recentTransactions = transactions.filter {
        calendar.dateComponents([.day], from: $0.date, to: Date()).day ?? 0 < days
    }

    let transactionsByDay = Dictionary(grouping: recentTransactions) { transaction in
        calendar.startOfDay(for: transaction.date)
    }

    let sortedDays = transactionsByDay.sorted { $0.key > $1.key }
    guard sortedDays.count >= 7 else { return insights }

    let last7Days = sortedDays.prefix(7)
    let transactionCounts = last7Days.map(\.value.count)
    let averageCount = Double(transactionCounts.reduce(0, +)) / Double(transactionCounts.count)

    if let highestDay = last7Days.max(by: { $0.value.count < $1.value.count }),
       Double(highestDay.value.count) > averageCount * 2
    {
        let transactionCount = highestDay.value.count
        let percentageMore = Int((Double(transactionCount) / averageCount - 1) * 100)
        let formattedDate = highestDay.key.formatted(date: .abbreviated, time: .omitted)
        let chartData = last7Days.map { dayData in
            (fi_formatDateShort(dayData.key), Double(dayData.value.count))
        }
        let partA = "You had \(transactionCount) transactions on \(formattedDate),"
        let partB = " which is \(percentageMore)% more than your daily average."
        let descriptionText = partA + partB
        let insight = FinancialInsight(
            title: "Unusual Transaction Activity",
            description: descriptionText,
            priority: .medium,
            type: .anomaly,
            visualizationType: .barChart,
            data: chartData
        )
        insights.append(insight)
    }

    return insights
}

/// Generate insights for potential duplicate payments
func fi_suggestDuplicatePaymentInsights(transactions: [FinancialTransaction]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let calendar = Calendar.current
    let recentTransactions = transactions.filter { transaction in
        calendar.dateComponents([.day], from: transaction.date, to: Date()).day ?? 0 < 14
    }

    let duplicateSuspects = fi_findPotentialDuplicates(recentTransactions)
    for duplicate in duplicateSuspects {
        let dupTitle = duplicate.first?.title ?? ""
        let dupAmount = duplicate.first?.amount ?? 0
        let dupDescription = "You may have duplicate payments: \(dupTitle) for "
            + fi_formatCurrency(dupAmount, code: "USD") + " on multiple dates."

        let dupData = duplicate.map { txn in
            (
                DateFormatter.localizedString(from: txn.date, dateStyle: .short, timeStyle: .none),
                abs(txn.amount)
            )
        }

        let insight = FinancialInsight(
            title: "Potential Duplicate Payment",
            description: dupDescription,
            priority: .high,
            type: .anomaly,
            relatedTransactionId: duplicate.first?.id.hashValue.description,
            data: dupData
        )
        insights.append(insight)
    }

    return insights
}

/// Extension for anomaly detection within FinancialIntelligenceService
extension FinancialIntelligenceService {
    func fi_detectAnomalies(transactions: [FinancialTransaction]) -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Combine all anomaly detection methods
        insights += fi_detectCategoryOutliers(transactions)
        insights += fi_detectRecentFrequencyAnomalies(transactions)
        insights += fi_suggestDuplicatePaymentInsights(transactions: transactions)

        return insights
    }
}
