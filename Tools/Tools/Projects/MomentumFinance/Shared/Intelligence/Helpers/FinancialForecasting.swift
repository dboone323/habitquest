import Foundation

// MARK: - Financial Forecasting

/// Generate financial forecasts based on historical data
func fi_generateFinancialForecasts(transactions: [FinancialTransaction], accounts: [FinancialAccount]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let calendar = Calendar.current
    let now = Date()

    // Income forecast
    let incomeTransactions = transactions.filter { $0.amount > 0 }
    let monthlyIncome = Dictionary(grouping: incomeTransactions) { transaction in
        calendar.startOfMonth(for: transaction.date)
    }

    let recentMonthlyIncomes = monthlyIncome
        .filter { calendar.dateInterval(of: .month, for: $0.key)!.end > calendar.date(byAdding: .month, value: -6, to: now)! }
        .map { $0.value.reduce(0) { $0 + $1.amount } }

    if recentMonthlyIncomes.count >= 3 {
        let avgMonthlyIncome = recentMonthlyIncomes.reduce(0, +) / Double(recentMonthlyIncomes.count)
        let forecastDescription = "Based on recent trends, your estimated monthly income is \(fi_formatCurrency(avgMonthlyIncome)). "
            + "This forecast helps with budgeting and financial planning."

        let insight = FinancialInsight(
            title: "Income Forecast",
            description: forecastDescription,
            priority: InsightPriority.low,
            type: InsightType.forecast,
            visualizationType: VisualizationType.lineChart,
            data: [
                ("Estimated Monthly Income", avgMonthlyIncome),
                ("Data Points", Double(recentMonthlyIncomes.count)),
            ]
        )
        insights.append(insight)
    }

    // Spending forecast
    let expenseTransactions = transactions.filter { $0.amount < 0 }
    let monthlyExpenses = Dictionary(grouping: expenseTransactions) { transaction in
        calendar.startOfMonth(for: transaction.date)
    }

    let recentMonthlyExpenses = monthlyExpenses
        .filter { calendar.dateInterval(of: .month, for: $0.key)!.end > calendar.date(byAdding: .month, value: -6, to: now)! }
        .map { $0.value.reduce(0) { $0 + abs($1.amount) } }

    if recentMonthlyExpenses.count >= 3 {
        let avgMonthlyExpenses = recentMonthlyExpenses.reduce(0, +) / Double(recentMonthlyExpenses.count)
        let forecastDescription = "Your estimated monthly expenses are \(fi_formatCurrency(avgMonthlyExpenses)). "
            + "Use this to plan your budget and savings goals."

        let insight = FinancialInsight(
            title: "Expense Forecast",
            description: forecastDescription,
            priority: InsightPriority.low,
            type: InsightType.forecast,
            visualizationType: VisualizationType.lineChart,
            data: [
                ("Estimated Monthly Expenses", avgMonthlyExpenses),
                ("Data Points", Double(recentMonthlyExpenses.count)),
            ]
        )
        insights.append(insight)
    }

    // Cash flow forecast
    if !recentMonthlyIncomes.isEmpty && !recentMonthlyExpenses.isEmpty {
        let avgIncome = recentMonthlyIncomes.reduce(0, +) / Double(recentMonthlyIncomes.count)
        let avgExpenses = recentMonthlyExpenses.reduce(0, +) / Double(recentMonthlyExpenses.count)
        let netCashFlow = avgIncome - avgExpenses

        var flowDescription: String
        var priority: InsightPriority

        if netCashFlow > 0 {
            flowDescription = "Your projected monthly cash flow is positive at \(fi_formatCurrency(netCashFlow)). "
                + "Consider increasing your savings or investments."
            priority = InsightPriority.low
        } else {
            flowDescription = "Your projected monthly cash flow is negative at \(fi_formatCurrency(netCashFlow)). "
                + "Review your expenses to improve your financial position."
            priority = InsightPriority.high
        }

        let insight = FinancialInsight(
            title: "Cash Flow Forecast",
            description: flowDescription,
            priority: priority,
            type: .forecast,
            visualizationType: .barChart,
            data: [
                ("Projected Income", avgIncome),
                ("Projected Expenses", avgExpenses),
                ("Net Cash Flow", netCashFlow),
            ]
        )
        insights.append(insight)
    }

    return insights
}

// MARK: - Forecasting helpers

func fi_projectedBalances(
    startingBalance: Double, monthlyChange: Double, months: Int, calendar: Calendar
) -> [(String, Double)] {
    var projected: [(String, Double)] = []
    var projectedBalance = startingBalance
    let currentMonth = calendar.startOfMonth(for: Date())
    for monthIndex in 0 ..< months {
        guard
            let futureMonth = calendar.date(
                byAdding: .month, value: monthIndex + 1, to: currentMonth
            )
        else { continue }
        projectedBalance += monthlyChange
        projected.append((fi_formatMonthAbbrev(futureMonth), projectedBalance))
    }
    return projected
}

func fi_monthlyNetCashFlow(_ transactions: [FinancialTransaction], monthsAgo: Int = 6) -> [(Date, Double)] {
    let calendar = Calendar.current
    let since = calendar.date(byAdding: .month, value: -monthsAgo, to: Date()) ?? Date()
    var monthlyNetCashFlow: [Date: Double] = [:]

    for transaction in transactions where transaction.date >= since {
        let month = calendar.startOfMonth(for: transaction.date)
        monthlyNetCashFlow[month] = (monthlyNetCashFlow[month] ?? 0) + transaction.amount
    }

    return monthlyNetCashFlow.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
}

func fi_trendAndForecast(values: [Double]) -> (trendDirection: String, trendPercentage: Double, nextForecast: Double?) {
    guard values.count >= 2 else { return ("stable", 0, nil) }

    let latest = values.last ?? 0
    let previous = values[values.count - 2]
    var trendDirection = "stable"
    var trendPercentage = 0.0

    if previous != 0 {
        trendPercentage = ((latest - previous) / abs(previous)) * 100
        if trendPercentage > 10 {
            trendDirection = "improving"
        } else if trendPercentage < -10 {
            trendDirection = "declining"
        }
    }

    let deltas = zip(values.dropFirst(), values).map { $0 - $1 }
    let avgDelta = deltas.reduce(0, +) / Double(deltas.count)
    let next = (values.last ?? 0) + avgDelta

    return (trendDirection, trendPercentage, next)
}
