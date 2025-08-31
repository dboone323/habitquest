import Foundation

// MARK: - Optimization Suggestions

/// Suggest insights for idle cash optimization
func fi_suggestIdleCashInsights(transactions: [FinancialTransaction], accounts: [FinancialAccount]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let checkingAccounts = accounts.filter { $0.accountType == .checking }
    for account in checkingAccounts {
        guard account.balance > 5000 else { continue }

        let accountTransactions = transactions.filter {
            $0.account?.id == account.id && $0.amount < 0
        }

        let calendar = Calendar.current
        let monthlyTransactions = Dictionary(grouping: accountTransactions) { transaction in
            calendar.startOfMonth(for: transaction.date)
        }

        let monthlyExpenses = monthlyTransactions.map { $0.value.reduce(0) { $0 + abs($1.amount) } }
        let averageMonthlyExpense = monthlyExpenses.isEmpty
            ? 0 : monthlyExpenses.reduce(0, +) / Double(monthlyExpenses.count)

        let recommendedBuffer = averageMonthlyExpense * 2

        if account.balance > recommendedBuffer {
            let excessCash = account.balance - recommendedBuffer
            let excessCashStr = fi_formatCurrency(excessCash, code: account.currencyCode)
            let accountName = account.name
            let idleDescription = "You have \(excessCashStr) more than needed in your \(accountName). "
                + "Consider moving some to a higher-yielding savings or investment account."

            let insight = FinancialInsight(
                title: "Idle Cash Detected",
                description: idleDescription,
                priority: .medium,
                type: .optimization,
                relatedAccountId: String(account.id.hashValue),
                data: [
                    ("Current Balance", account.balance),
                    ("Recommended Buffer", recommendedBuffer),
                    ("Excess Cash", excessCash),
                ]
            )
            insights.append(insight)
        }
    }

    return insights
}

/// Suggest insights for credit utilization optimization
func fi_suggestCreditUtilizationInsights(accounts: [FinancialAccount]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    let creditAccounts = accounts.filter { $0.accountType == .credit }
    for account in creditAccounts {
        guard let creditLimit = account.creditLimit, creditLimit > 0 else { continue }

        let balance = abs(account.balance)
        let utilization = balance / creditLimit

        if utilization > 0.3 {
            let utilDescription = "Your credit utilization on \(account.name) is \(Int(utilization * 100))%. "
                + "It's recommended to keep this under 30% to maintain a good credit score."

            let insight = FinancialInsight(
                title: "High Credit Utilization",
                description: utilDescription,
                priority: utilization > 0.7 ? .critical : .high,
                type: .optimization,
                relatedAccountId: String(account.id.hashValue),
                visualizationType: .progressBar,
                data: [
                    ("Balance", balance),
                    ("Credit Limit", creditLimit),
                    ("Utilization", utilization),
                ]
            )
            insights.append(insight)
        }
    }

    return insights
}
