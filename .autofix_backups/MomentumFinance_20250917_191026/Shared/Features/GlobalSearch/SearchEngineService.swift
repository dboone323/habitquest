import Foundation
import Combine
import SwiftData

@MainActor
public final class SearchEngineService: ObservableObject {
    private var modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    public func search(query: String, filter: SearchFilter = .all) -> [SearchResult] {
        guard !query.isEmpty else { return [] }

        var results: [SearchResult] = []

        switch filter {
        case .all:
            results.append(contentsOf: self.searchAccounts(query))
            results.append(contentsOf: self.searchTransactions(query))
            results.append(contentsOf: self.searchSubscriptions(query))
            results.append(contentsOf: self.searchBudgets(query))
        case .accounts:
            results.append(contentsOf: self.searchAccounts(query))
        case .transactions:
            results.append(contentsOf: self.searchTransactions(query))
        case .subscriptions:
            results.append(contentsOf: self.searchSubscriptions(query))
        case .budgets:
            results.append(contentsOf: self.searchBudgets(query))
        }

        // Sort by relevance score
        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    private func searchAccounts(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<FinancialAccount>()
        guard let accounts = try? modelContext.fetch(descriptor) else { return [] }

        return accounts.compactMap { account in
            let titleScore = self.calculateRelevance(account.name, query: query)
            let balanceScore = self.calculateRelevance(String(format: "%.2f", account.balance), query: query)

            let score = max(titleScore, balanceScore)
            if score > 0 {
                return SearchResult(
                    id: String(describing: account.id),
                    title: account.name,
                    subtitle: String(format: "Balance: $%.2f", account.balance),
                    type: .accounts,
                    iconName: "creditcard",
                    relevanceScore: score
                )
            }
            return nil
        }
    }

    private func searchTransactions(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<FinancialTransaction>()
        guard let transactions = try? modelContext.fetch(descriptor) else { return [] }

        return transactions.compactMap { transaction in
            let titleScore = self.calculateRelevance(transaction.title, query: query)
            let amountScore = self.calculateRelevance(String(format: "%.2f", transaction.amount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    id: String(describing: transaction.id),
                    title: transaction.title,
                    subtitle: String(format: "$%.2f • %@", transaction.amount, transaction.date.formatted()),
                    type: .transactions,
                    iconName: "arrow.left.arrow.right",
                    relevanceScore: score
                )
            }
            return nil
        }
    }

    private func searchSubscriptions(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<Subscription>()
        guard let subscriptions = try? modelContext.fetch(descriptor) else { return [] }

        return subscriptions.compactMap { subscription in
            let titleScore = self.calculateRelevance(subscription.name, query: query)
            let amountScore = self.calculateRelevance(String(format: "%.2f", subscription.amount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    id: String(describing: subscription.id),
                    title: subscription.name,
                    subtitle: String(format: "$%.2f • %@", subscription.amount, subscription.billingCycle.rawValue),
                    type: .subscriptions,
                    iconName: "calendar",
                    relevanceScore: score
                )
            }
            return nil
        }
    }

    private func searchBudgets(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<Budget>()
        guard let budgets = try? modelContext.fetch(descriptor) else { return [] }

        return budgets.compactMap { budget in
            let titleScore = self.calculateRelevance(budget.name, query: query)
            let amountScore = self.calculateRelevance(String(format: "%.2f", budget.limitAmount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    id: String(describing: budget.id),
                    title: budget.name,
                    subtitle: String(format: "$%.2f limit", budget.limitAmount),
                    type: .budgets,
                    iconName: "chart.pie",
                    relevanceScore: score
                )
            }
            return nil
        }
    }

    private func calculateRelevance(_ text: String, query: String) -> Double {
        let lowerText = text.lowercased()
        let lowerQuery = query.lowercased()

        if lowerText.contains(lowerQuery) {
            // Exact match gets highest score
            if lowerText == lowerQuery {
                return 1.0
            }
            // Starts with query gets high score
            if lowerText.hasPrefix(lowerQuery) {
                return 0.8
            }
            // Contains query gets medium score
            return 0.6
        }

        return 0.0
    }
}
