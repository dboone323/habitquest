import Foundation

public protocol FinancialAnalyticsTransactionConvertible {
    var faAmount: Double { get }
    var faDate: Date { get }
    var faCategory: String { get }
    var faMerchant: String? { get }
}

public protocol FinancialAnalyticsAccountConvertible {
    var faType: FinancialAnalyticsAccountKind { get }
    var faBalance: Double { get }
}

public protocol FinancialAnalyticsBudgetConvertible {
    var faCategory: String { get }
    var faAmount: Double { get }
    var faPeriod: FinancialAnalyticsBudgetPeriod { get }
}

public enum FinancialAnalyticsAccountKind {
    case checking
    case savings
    case credit
    case investment
    case other
}

public enum FinancialAnalyticsBudgetPeriod {
    case monthly
    case quarterly
    case yearly
}

public enum FinancialAnalyticsSharedCore {
    public struct CategoryTrendSummary {
        public let category: String
        public let currentSpend: Double
        public let previousSpend: Double
        public let percentChange: Double
        public let changeAmount: Double
        public let transactionCount: Int
    }

    public struct SubscriptionSummary {
        public let identifier: String
        public let name: String
        public let averageAmount: Double
        public let lastUsed: Date?
    }

    public static func spendingVelocityIncrease(
        in transactions: [some FinancialAnalyticsTransactionConvertible],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        guard
            let currentStart = calendar.date(byAdding: .day, value: -30, to: now),
            let previousStart = calendar.date(byAdding: .day, value: -60, to: now)
        else {
            return 0
        }

        let expenses = transactions.filter { $0.faAmount < 0 }
        let currentSpend = expenses
            .filter { $0.faDate >= currentStart }
            .reduce(0) { $0 + abs($1.faAmount) }
        let previousSpend = expenses
            .filter { $0.faDate < currentStart && $0.faDate >= previousStart }
            .reduce(0) { $0 + abs($1.faAmount) }

        guard previousSpend > 0 else {
            return currentSpend > 0 ? 100 : 0
        }

        return (currentSpend - previousSpend) / previousSpend * 100
    }

    public static func categoryTrends<T: FinancialAnalyticsTransactionConvertible>(
        in transactions: [T],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [CategoryTrendSummary] {
        guard
            let currentStart = calendar.date(byAdding: .day, value: -30, to: now),
            let previousStart = calendar.date(byAdding: .day, value: -60, to: now)
        else {
            return []
        }

        let expenses = transactions.filter { $0.faAmount < 0 }
        let grouped = Dictionary(grouping: expenses, by: \T.faCategory)

        return grouped.compactMap { category, categoryTransactions in
            let currentSpend = categoryTransactions
                .filter { $0.faDate >= currentStart }
                .reduce(0) { $0 + abs($1.faAmount) }
            let previousSpend = categoryTransactions
                .filter { $0.faDate < currentStart && $0.faDate >= previousStart }
                .reduce(0) { $0 + abs($1.faAmount) }

            if currentSpend == 0, previousSpend == 0 {
                return nil
            }

            let changeAmount = currentSpend - previousSpend
            let percentChange = previousSpend == 0
                ? (currentSpend > 0 ? 1 : 0)
                : changeAmount / previousSpend

            return CategoryTrendSummary(
                category: category,
                currentSpend: currentSpend,
                previousSpend: previousSpend,
                percentChange: percentChange,
                changeAmount: changeAmount,
                transactionCount: categoryTransactions.count
            )
        }
    }

    public static func detectSubscriptions(
        in transactions: [some FinancialAnalyticsTransactionConvertible],
        calendar: Calendar = .current
    ) -> [SubscriptionSummary] {
        let expenses = transactions.filter { $0.faAmount < 0 }
        let grouped = Dictionary(grouping: expenses) { ($0.faMerchant ?? $0.faCategory).lowercased() }

        return grouped.compactMap { identifier, merchantTransactions in
            let sorted = merchantTransactions.sorted(by: { $0.faDate < $1.faDate })
            guard sorted.count >= 2 else { return nil }

            let intervals = zip(sorted.dropFirst(), sorted).map { $0.faDate.timeIntervalSince($1.faDate) }
            let averageIntervalDays = intervals.isEmpty
                ? 0
                : intervals.reduce(0, +) / Double(intervals.count) / 86400

            let amounts = sorted.map { abs($0.faAmount) }
            guard let maxAmount = amounts.max(), let minAmount = amounts.min() else { return nil }
            let averageAmount = amounts.reduce(0, +) / Double(amounts.count)
            let amountVariance = maxAmount - minAmount

            let looksRecurring = (!intervals.isEmpty && averageIntervalDays >= 25 && averageIntervalDays <= 40)
                || sorted.count >= 3
            let amountsConsistent = amountVariance <= max(5, averageAmount * 0.15)

            guard looksRecurring, amountsConsistent else { return nil }

            return SubscriptionSummary(
                identifier: identifier,
                name: sorted.last?.faMerchant ?? sorted.last?.faCategory ?? "Subscription",
                averageAmount: averageAmount,
                lastUsed: sorted.last?.faDate
            )
        }
    }

    public static func unusedSubscriptions(
        _ subscriptions: [SubscriptionSummary],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [SubscriptionSummary] {
        let threshold = calendar.date(byAdding: .day, value: -45, to: now) ?? now
        return subscriptions.filter { summary in
            guard let lastUsed = summary.lastUsed else { return true }
            return lastUsed < threshold
        }
    }

    public static func spentAmount(
        transactions: [some FinancialAnalyticsTransactionConvertible],
        budget: some FinancialAnalyticsBudgetConvertible,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        let lookbackDays = switch budget.faPeriod {
        case .monthly:
            30
        case .quarterly:
            90
        case .yearly:
            365
        }

        let periodStart = calendar.date(byAdding: .day, value: -lookbackDays, to: now) ?? now

        return transactions
            .filter { $0.faCategory == budget.faCategory && $0.faAmount < 0 && $0.faDate >= periodStart }
            .reduce(0) { $0 + abs($1.faAmount) }
    }

    public static func monthlyExpenses(
        transactions: [some FinancialAnalyticsTransactionConvertible],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        let periodStart = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let total = transactions
            .filter { $0.faAmount < 0 && $0.faDate >= periodStart }
            .reduce(0) { $0 + abs($1.faAmount) }
        return max(total, 1)
    }

    public static func liquidBalance(accounts: [some FinancialAnalyticsAccountConvertible]) -> Double {
        accounts.reduce(0) { partialResult, account in
            switch account.faType {
            case .checking, .savings:
                partialResult + account.faBalance
            default:
                partialResult
            }
        }
    }

    public static func emergencyCoverage(
        accounts: [some FinancialAnalyticsAccountConvertible],
        monthlyExpenses: Double
    ) -> Double {
        guard monthlyExpenses > 0 else { return Double.infinity }
        let savings = accounts.reduce(0) { total, account in
            let isSavings = switch account.faType {
            case .savings:
                true
            default:
                false
            }
            return isSavings ? total + account.faBalance : total
        }
        return savings / monthlyExpenses
    }

    public static func cashFlowWindow(
        transactions: [some FinancialAnalyticsTransactionConvertible],
        windowDays: Int = 30,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (income: Double, expenses: Double, net: Double) {
        let start = calendar.date(byAdding: .day, value: -windowDays, to: now) ?? now
        let window = transactions.filter { $0.faDate >= start }
        let income = window.filter { $0.faAmount > 0 }.reduce(0) { $0 + $1.faAmount }
        let expenses = window.filter { $0.faAmount < 0 }.reduce(0) { $0 + abs($1.faAmount) }
        return (income, expenses, income - expenses)
    }
}
