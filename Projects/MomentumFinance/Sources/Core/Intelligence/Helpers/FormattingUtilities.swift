import Foundation

// MARK: - Formatting Utilities

/// Format currency amount with optional currency code
func fi_formatCurrency(_ amount: Double, code: String? = nil) -> String {
    let currencyCode = code ?? Locale.current.currency?.identifier ?? "USD"
    return amount.formatted(.currency(code: currencyCode))
}

/// Format date in short format
func fi_formatDateShort(_ date: Date) -> String {
    date.formatted(date: .abbreviated, time: .omitted)
}

/// Format month in abbreviated format
func fi_formatMonthAbbrev(_ date: Date) -> String {
    date.formatted(.dateTime.month(.abbreviated))
}

// Old helper compatibility shim used in forecasting helpers
func formatCurrency(_ amount: Double, code: String? = nil) -> String {
    fi_formatCurrency(amount, code: code)
}

/// Extract features from transaction for analysis
func fi_extractTransactionFeatures(_ transaction: FinancialTransaction) -> [String: Any] {
    var features: [String: Any] = [:]
    features["name"] = transaction.title.lowercased()
    features["amount"] = abs(transaction.amount)
    features["is_expense"] = transaction.amount < 0
    let calendar = Calendar.current
    features["day_of_week"] = calendar.component(.weekday, from: transaction.date)
    features["month"] = calendar.component(.month, from: transaction.date)
    return features
}
