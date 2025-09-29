import Foundation

public enum TransactionType {
    case income
    case expense
}

public final class ExpenseCategory: ObservableObject {
    public let name: String
    public let iconName: String
    public var transactions: [FinancialTransaction]

    public init(name: String, iconName: String, transactions: [FinancialTransaction] = []) {
        self.name = name
        self.iconName = iconName
        self.transactions = transactions
    }
}

public final class FinancialTransaction: Identifiable {
    public let id: UUID
    public let title: String
    public let amount: Double
    public let date: Date
    public let transactionType: TransactionType
    public weak var category: ExpenseCategory?

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date,
        transactionType: TransactionType,
        category: ExpenseCategory? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.transactionType = transactionType
        self.category = category
    }
}

public final class Budget: Identifiable {
    public let id: UUID
    public let name: String
    public let limitAmount: Double
    public let month: Date
    public var category: ExpenseCategory?

    public init(id: UUID = UUID(), name: String, limitAmount: Double, month: Date) {
        self.id = id
        self.name = name
        self.limitAmount = limitAmount
        self.month = month
    }

    public var spentAmount: Double {
        guard let category else { return 0 }
        return category.transactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + abs($1.amount) }
    }
}

public struct BudgetProgressSummary: Equatable {
    public let totalBudgeted: Double
    public let totalSpent: Double
    public let totalBudgets: Int
    public let onTrackCount: Int
    public let overBudgetCount: Int
}

@MainActor
public final class BudgetsViewModel: ObservableObject {
    private let calendar = Calendar(identifier: .gregorian)

    public init() {}

    public func budgetsForMonth(_ budgets: [Budget], month: Date) -> [Budget] {
        budgets.filter { self.calendar.isDate($0.month, equalTo: month, toGranularity: .month) }
    }

    public func totalBudgetedAmount(_ budgets: [Budget], for month: Date) -> Double {
        self.budgetsForMonth(budgets, month: month).reduce(0) { $0 + $1.limitAmount }
    }

    public func remainingBudget(_ budgets: [Budget], for month: Date) -> Double {
        let filtered = self.budgetsForMonth(budgets, month: month)
        let spent = filtered.reduce(0) { $0 + $1.spentAmount }
        let total = filtered.reduce(0) { $0 + $1.limitAmount }
        return total - spent
    }

    public func hasOverBudgetCategories(_ budgets: [Budget], for month: Date) -> Bool {
        !self.overBudgetCategories(budgets, for: month).isEmpty
    }

    public func overBudgetCategories(_ budgets: [Budget], for month: Date) -> [Budget] {
        self.budgetsForMonth(budgets, month: month).filter { $0.spentAmount > $0.limitAmount }
    }

    public func budgetProgressSummary(_ budgets: [Budget], for month: Date) -> BudgetProgressSummary {
        let filtered = self.budgetsForMonth(budgets, month: month)
        let totalBudgeted = filtered.reduce(0) { $0 + $1.limitAmount }
        let totalSpent = filtered.reduce(0) { $0 + $1.spentAmount }
        let overBudget = filtered.filter { $0.spentAmount > $0.limitAmount }
        let onTrack = filtered.count - overBudget.count

        return BudgetProgressSummary(
            totalBudgeted: totalBudgeted,
            totalSpent: totalSpent,
            totalBudgets: filtered.count,
            onTrackCount: max(0, onTrack),
            overBudgetCount: overBudget.count
        )
    }
}
