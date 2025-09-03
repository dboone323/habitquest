import Foundation

func fi_computeMonthlySpendingByCategory(transactions: [FinancialTransaction]) -> [String: [Date:
        Double]]
{
    let calendar = Calendar.current
    var monthlySpendingByCategory: [String: [Date: Double]] = [:]

    for txn in transactions where txn.amount < 0 {
        guard let category = txn.category else { continue }
        let categoryId = category.id.hashValue.description
        let month = calendar.startOfMonth(for: txn.date)
        monthlySpendingByCategory[categoryId, default: [:]][month] =
            (monthlySpendingByCategory[categoryId]?[month] ?? 0) + abs(txn.amount)
    }

    return monthlySpendingByCategory
}

func fi_generateSpendingInsightsFromMonthlyData(
    monthlySpendingByCategory: [String: [Date: Double]],
    categories: [ExpenseCategory]
) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    for (categoryId, monthlySpending) in monthlySpendingByCategory {
        guard let category = categories.first(where: { $0.id.hashValue.description == categoryId })
        else { continue }

        let sorted = monthlySpending.sorted { $0.key < $1.key }
        guard sorted.count >= 2 else { continue }

        let values = sorted.map(\.value)
        let average = values.reduce(0, +) / Double(values.count)

        let last = sorted.last?.value ?? 0
        let prev = sorted.count > 1 ? sorted[sorted.count - 2].value : 0

        if last > average * 1.2 && last > prev * 1.1 {
            let percentIncrease = prev > 0 ? Int(((last - prev) / prev) * 100) : 0
            insights.append(
                FinancialInsight(
                    title: "Increased Spending in \(category.name)",
                    description:
                    "Your spending in \(category.name) increased by \(percentIncrease)% last month.",
                    priority: .medium,
                    type: .spendingPattern,
                    relatedCategoryId: categoryId,
                    visualizationType: .lineChart,
                    data: sorted.map { ($0.key.formatted(.dateTime.month(.abbreviated)), $0.value) }
                ))
        } else if last < average * 0.8 && last < prev * 0.9 {
            let percentDecrease = prev > 0 ? Int(((prev - last) / prev) * 100) : 0
            insights.append(
                FinancialInsight(
                    title: "Reduced Spending in \(category.name)",
                    description:
                    "Your spending in \(category.name) decreased by \(percentDecrease)% last month.",
                    priority: .low,
                    type: .positiveSpendingTrend,
                    relatedCategoryId: categoryId,
                    visualizationType: .lineChart,
                    data: sorted.map { ($0.key.formatted(.dateTime.month(.abbreviated)), $0.value) }
                ))
        }
    }

    return insights
}

func fi_topCategoriesInsight(
    monthlySpendingByCategory: [String: [Date: Double]], categories: [ExpenseCategory]
) -> FinancialInsight? {
    let totalByCategory = monthlySpendingByCategory.mapValues { $0.values.reduce(0, +) }
    let sorted = totalByCategory.sorted { $0.value > $1.value }
    guard !sorted.isEmpty else { return nil }

    let top = sorted.prefix(3)
    let topCategoryData = top.compactMap { categoryId, total -> (String, Double)? in
        guard let category = categories.first(where: { $0.id.hashValue.description == categoryId })
        else { return nil }
        return (category.name, total)
    }
    guard !topCategoryData.isEmpty else { return nil }

    return FinancialInsight(
        title: "Top Spending Categories",
        description:
        "Your highest spending categories are \(topCategoryData.map(\.0).joined(separator: ", ")).",
        priority: .medium,
        type: .spendingPattern,
        visualizationType: .pieChart,
        data: topCategoryData
    )
}

func fi_analyzeSpendingPatterns(
    transactions: [FinancialTransaction], categories: [ExpenseCategory]
) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let monthly = fi_computeMonthlySpendingByCategory(transactions: transactions)
    insights.append(
        contentsOf: fi_generateSpendingInsightsFromMonthlyData(
            monthlySpendingByCategory: monthly, categories: categories
        ))

    if let topInsight = fi_topCategoriesInsight(
        monthlySpendingByCategory: monthly, categories: categories
    ) {
        insights.append(topInsight)
    }

    let recurring = fi_findRecurringTransactions(transactions)
    if !recurring.isEmpty {
        insights.append(
            FinancialInsight(
                title: "Potential Recurring Expenses",
                description:
                "You may have \(recurring.count) recurring payments that are not tracked as subscriptions.",
                priority: .medium,
                type: .subscriptionDetection,
                data: recurring.prefix(5).map { ($0.title, abs($0.amount)) }
            ))
    }

    return insights
}

func fi_checkBudgetExceeded(
    budget: Budget, totalSpent: Double, categoryId: String
) -> FinancialInsight? {
    guard totalSpent >= budget.limitAmount else { return nil }

    let overspent = totalSpent - budget.limitAmount
    let overspentFormatted = overspent.formatted(
        .currency(code: Locale.current.currency?.identifier ?? "USD"))

    return FinancialInsight(
        title: "Budget Exceeded",
        description: "You've exceeded your \(budget.name) budget by \(overspentFormatted).",
        priority: .critical,
        type: .budgetAlert,
        relatedBudgetId: budget.id.hashValue.description,
        visualizationType: .progressBar,
        data: [
            ("Budget", budget.limitAmount), ("Spent", totalSpent),
            ("Overspent", overspent),
        ]
    )
}

struct BudgetAnalysisContext {
    let budget: Budget
    let totalSpent: Double
    let percentUsed: Double
    let idealPercentage: Double
    let daysInMonth: Int
    let day: Int
    let daysRemaining: Int
}

func fi_checkBudgetAtRisk(context: BudgetAnalysisContext) -> FinancialInsight? {
    guard context.percentUsed > context.idealPercentage * 1.1 && context.percentUsed > 0.7 else {
        return nil
    }

    let projectedTotal =
        context.totalSpent * Double(context.daysInMonth) / Double(max(1, context.day - 1))
    guard projectedTotal > context.budget.limitAmount else { return nil }

    let projectedOverage = projectedTotal - context.budget.limitAmount
    let remainingBudget = context.budget.limitAmount - context.totalSpent
    let projectedOverageFormatted = projectedOverage.formatted(
        .currency(code: Locale.current.currency?.identifier ?? "USD"))
    let remainingBudgetFormatted = remainingBudget.formatted(
        .currency(code: Locale.current.currency?.identifier ?? "USD"))

    let baseMessage =
        "At your current rate, you'll exceed your \(context.budget.name) budget by \(projectedOverageFormatted)."
    let remainingMessage =
        " You have \(remainingBudgetFormatted) left for \(context.daysRemaining) days."
    let descriptionText = baseMessage + remainingMessage

    return FinancialInsight(
        title: "Budget at Risk",
        description: descriptionText,
        priority: .high,
        type: .budgetAlert,
        relatedBudgetId: context.budget.id.hashValue.description,
        visualizationType: .progressBar,
        data: [
            ("Budget", context.budget.limitAmount), ("Spent", context.totalSpent),
            ("Projected", projectedTotal),
        ]
    )
}

func fi_checkBudgetUnderutilized(
    budget: Budget, totalSpent: Double, percentUsed: Double,
    idealPercentage: Double, daysRemaining: Int
) -> FinancialInsight? {
    guard percentUsed < idealPercentage * 0.5 && idealPercentage > 0.5 else { return nil }

    let percentUsedInt = Int(percentUsed * 100)
    let baseMessage = "You've only used \(percentUsedInt)% of your \(budget.name) budget"
    let remainingMessage = " with \(daysRemaining) days remaining. Consider reallocating funds."
    let descriptionText = baseMessage + remainingMessage

    return FinancialInsight(
        title: "Budget Underutilized",
        description: descriptionText,
        priority: .low,
        type: .budgetInsight,
        relatedBudgetId: budget.id.hashValue.description,
        visualizationType: .progressBar,
        data: [
            ("Budget", budget.limitAmount), ("Spent", totalSpent),
            ("Remaining", budget.limitAmount - totalSpent),
        ]
    )
}

func fi_analyzeBudgets(transactions: [FinancialTransaction], budgets: [Budget])
    -> [FinancialInsight]
{
    var insights: [FinancialInsight] = []
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: Date())
    let currentYear = calendar.component(.year, from: Date())

    let currentMonthTransactions = transactions.filter { transaction in
        let month = calendar.component(.month, from: transaction.date)
        let year = calendar.component(.year, from: transaction.date)
        return month == currentMonth && year == currentYear
    }

    for budget in budgets {
        guard let category = budget.category else { continue }
        let categoryId = category.id.hashValue.description

        let categoryTransactions = currentMonthTransactions.filter {
            $0.category?.id.hashValue.description == categoryId && $0.amount < 0
        }
        let totalSpent = categoryTransactions.reduce(0) { $0 + abs($1.amount) }
        let percentUsed = totalSpent / budget.limitAmount

        let today = Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
        let day = calendar.component(.day, from: today)
        let daysRemaining = daysInMonth - day + 1
        let idealPercentage = Double(day - 1) / Double(daysInMonth)

        let context = BudgetAnalysisContext(
            budget: budget,
            totalSpent: totalSpent,
            percentUsed: percentUsed,
            idealPercentage: idealPercentage,
            daysInMonth: daysInMonth,
            day: day,
            daysRemaining: daysRemaining
        )

        if let exceededInsight = fi_checkBudgetExceeded(
            budget: budget, totalSpent: totalSpent, categoryId: categoryId
        ) {
            insights.append(exceededInsight)
        } else if let atRiskInsight = fi_checkBudgetAtRisk(context: context) {
            insights.append(atRiskInsight)
        } else if let underutilizedInsight = fi_checkBudgetUnderutilized(
            budget: budget, totalSpent: totalSpent, percentUsed: percentUsed,
            idealPercentage: idealPercentage, daysRemaining: daysRemaining
        ) {
            insights.append(underutilizedInsight)
        }
    }

    // Identify categories without budgets
    insights.append(
        contentsOf: fi_findBudgetRecommendations(transactions: transactions, budgets: budgets))

    return insights
}

@MainActor
extension FinancialIntelligenceService {
    private func findRecurringTransactionInsights(from transactions: [FinancialTransaction])
        -> [FinancialInsight]
    {
        let recurringTransactions = fi_findRecurringTransactions(transactions)
        guard !recurringTransactions.isEmpty else { return [] }

        let topFive = recurringTransactions.prefix(5).map { ($0.title, abs($0.amount)) }

        let insight = FinancialInsight(
            title: "Potential Recurring Expenses",
            description:
            "You may have \(recurringTransactions.count) recurring payments that are not tracked as subscriptions.",
            priority: .medium,
            type: .subscriptionDetection,
            visualizationType: .none,
            data: topFive
        )

        return [insight]
    }
}
