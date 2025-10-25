import Foundation

// MARK: - Transaction Types

public enum TransactionFilter: String, CaseIterable, Sendable {
    case all
    case income
    case expense

    public var displayName: String {
        switch self {
        case .all: "All"
        case .income: "Income"
        case .expense: "Expense"
        }
    }
}
