import Foundation

public enum TransactionFilter: String, CaseIterable, Identifiable {
    case all, income, expense, transfer
    public var id: String { rawValue }
    public var displayName: String {
        switch self {
        case .all: "All"
        case .income: "Income"
        case .expense: "Expenses"
        case .transfer: "Transfers"
        }
    }
}
