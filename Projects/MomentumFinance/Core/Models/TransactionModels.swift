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

// MARK: - Navigation Types

public struct BreadcrumbItem: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let destination: String?

    public init(title: String, destination: String? = nil) {
        self.title = title
        self.destination = destination
    }
}

public struct DeepLink: Sendable {
    public let path: String
    public let parameters: [String: String]

    public init(path: String, parameters: [String: String] = [:]) {
        self.path = path
        self.parameters = parameters
    }
}
