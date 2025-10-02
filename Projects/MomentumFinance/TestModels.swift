import Foundation

// MARK: - Mock Models for Testing

enum TransactionType {
    case income, expense
}

struct Transaction {
    var amount: Double
    var description: String
    var date: Date
    var type: TransactionType
    var categoryName: String
}

enum AccountType {
    case checking, savings, investment, credit
}

struct FinancialAccount {
    var name: String
    var balance: Double
    var iconName: String
    var accountType: AccountType
    var creditLimit: Double?

    mutating func updateBalance(for transaction: FinancialTransaction) {
        switch transaction.transactionType {
        case .income:
            self.balance += transaction.amount
        case .expense:
            self.balance -= transaction.amount
        }
    }
}

enum TransactionType2 {
    case income, expense
}

struct FinancialTransaction {
    var title: String
    var amount: Double
    var date: Date
    var transactionType: TransactionType2

    var formattedAmount: String {
        let prefix = self.transactionType == .income ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", abs(self.amount)))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self.date)
    }
}

struct ExpenseCategory {
    var name: String
    var iconName: String
    var colorHex: String
    var budgetAmount: Double
    var spentAmount: Double = 0.0
    var transactions: [FinancialTransaction] = []

    var remainingBudget: Double {
        self.budgetAmount - self.spentAmount
    }

    var isOverBudget: Bool {
        self.spentAmount > self.budgetAmount
    }

    func totalSpent(for date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return self.transactions.filter { transaction in
            let transactionMonth = calendar.component(.month, from: transaction.date)
            let transactionYear = calendar.component(.year, from: transaction.date)
            return transactionMonth == month && transactionYear == year
        }.reduce(0) { $0 + $1.amount }
    }
}
