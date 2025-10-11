#if SWIFT_PACKAGE
import Foundation

public typealias InvestmentRecommendation = AdvancedFinancialIntelligence.InvestmentRecommendation
public typealias TransactionAnomaly = AdvancedFinancialIntelligence.TransactionAnomaly
public typealias CashFlowPrediction = AdvancedFinancialIntelligence.CashFlowPrediction

extension AdvancedFinancialIntelligence {
    func calculateSpentAmount(_ transactions: [Transaction], for budget: AIBudget) -> Double {
        let normalizedCategory = budget.category.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let calendar = Calendar.current
        let now = Date()

        let periodBounds: DateInterval? = {
            switch budget.period {
            case .monthly:
                guard
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                    let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)
                else {
                    return nil
                }
                return DateInterval(start: startOfMonth, end: endOfMonth)
            case .yearly:
                guard
                    let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
                    let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)
                else {
                    return nil
                }
                return DateInterval(start: startOfYear, end: endOfYear)
            }
        }()

        return transactions.reduce(0) { runningTotal, transaction in
            guard
                transaction.amount < 0,
                transaction.category.trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == normalizedCategory,
                periodBounds?.contains(transaction.date) ?? true
            else {
                return runningTotal
            }

            return runningTotal + abs(transaction.amount)
        }
    }
}
#endif
