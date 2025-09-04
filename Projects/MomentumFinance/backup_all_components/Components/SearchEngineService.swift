import SwiftData
import SwiftUI

// MARK: - Search Engine Service

@MainActor
class SearchEngineService: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func searchAcrossAllModules(
        query: String,
        filter: Features.GlobalSearchView.SearchFilter,
        accounts: [FinancialAccount],
        transactions: [FinancialTransaction],
        subscriptions: [Subscription],
        budgets: [Budget],
        goals: [SavingsGoal]
    ) async -> [SearchResult] {

        let lowercasedQuery = query.lowercased()
        var results: [SearchResult] = []

        // Search Accounts
        if filter == .all || filter == .accounts {
            let accountResults = searchAccounts(
                accounts: accounts,
                query: lowercasedQuery
            )
            results.append(contentsOf: accountResults)
        }

        // Search Transactions
        if filter == .all || filter == .transactions {
            let transactionResults = searchTransactions(
                transactions: transactions,
                query: lowercasedQuery
            )
            results.append(contentsOf: transactionResults)
        }

        // Search Subscriptions
        if filter == .all || filter == .subscriptions {
            let subscriptionResults = searchSubscriptions(
                subscriptions: subscriptions,
                query: lowercasedQuery
            )
            results.append(contentsOf: subscriptionResults)
        }

        // Search Budgets
        if filter == .all || filter == .budgets {
            let budgetResults = searchBudgets(
                budgets: budgets,
                query: lowercasedQuery
            )
            results.append(contentsOf: budgetResults)
        }

        // Search Goals
        if filter == .all || filter == .goals {
            let goalResults = searchGoals(
                goals: goals,
                query: lowercasedQuery
            )
            results.append(contentsOf: goalResults)
        }

        return results.sorted { $0.title < $1.title }
    }

    // MARK: - Private Search Methods

    private func searchAccounts(
        accounts: [FinancialAccount],
        query: String
    ) -> [SearchResult] {
        accounts
            .filter { account in
                account.name.lowercased().contains(query)
            }
            .map { account in
                SearchResult(
                    id: "\(account.persistentModelID)",
                    title: account.name,
                    subtitle: "Account • \(account.balance.formatted(.currency(code: "USD")))",
                    type: .account,
                    relatedId: nil
                )
            }
    }

    private func searchTransactions(
        transactions: [FinancialTransaction],
        query: String
    ) -> [SearchResult] {
        transactions
            .filter { transaction in
                transaction.title.lowercased().contains(query) ||
                    (transaction.category?.name.lowercased().contains(query) ?? false)
            }
            .prefix(SearchConfiguration.transactionResultLimit)
            .map { transaction in
                SearchResult(
                    id: "\(transaction.persistentModelID)",
                    title: transaction.title,
                    subtitle: "\(transaction.amount.formatted(.currency(code: "USD"))) • \(transaction.date.formatted(date: .abbreviated, time: .omitted))",
                    type: .transaction,
                    relatedId: transaction.account != nil ? "\(transaction.account!.persistentModelID)" : nil
                )
            }
    }

    private func searchSubscriptions(
        subscriptions: [Subscription],
        query: String
    ) -> [SearchResult] {
        subscriptions
            .filter { subscription in
                subscription.name.lowercased().contains(query) ||
                    (subscription.category?.name.lowercased().contains(query) ?? false)
            }
            .map { subscription in
                SearchResult(
                    id: "\(subscription.persistentModelID)",
                    title: subscription.name,
                    subtitle: "\(subscription.amount.formatted(.currency(code: "USD"))) • \(subscription.billingCycle.rawValue)",
                    type: .subscription,
                    relatedId: subscription.account != nil ? "\(subscription.account!.persistentModelID)" : nil
                )
            }
    }

    private func searchBudgets(
        budgets: [Budget],
        query: String
    ) -> [SearchResult] {
        budgets
            .filter { budget in
                budget.category?.name.lowercased().contains(query) ?? false
            }
            .map { budget in
                SearchResult(
                    id: "\(budget.persistentModelID)",
                    title: "Budget: \(budget.category?.name ?? "Unknown")",
                    subtitle: "\(budget.spentAmount.formatted(.currency(code: "USD"))) / \(budget.limitAmount.formatted(.currency(code: "USD")))",
                    type: .budget,
                    relatedId: budget.category != nil ? "\(budget.category!.persistentModelID)" : nil
                )
            }
    }

    private func searchGoals(
        goals: [SavingsGoal],
        query: String
    ) -> [SearchResult] {
        goals
            .filter { goal in
                goal.name.lowercased().contains(query)
            }
            .map { goal in
                SearchResult(
                    id: "\(goal.persistentModelID)",
                    title: goal.name,
                    subtitle: "\(goal.currentAmount.formatted(.currency(code: "USD"))) / \(goal.targetAmount.formatted(.currency(code: "USD")))",
                    type: .goal,
                    relatedId: nil
                )
            }
    }
}
