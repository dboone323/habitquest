import Combine
import Foundation
import SwiftData

@MainActor
public final class SearchEngineService: ObservableObject {
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func search(query: String, filter: SearchFilter = .all) -> [SearchResult] {
        guard !query.isEmpty else { return [] }

        var results: [SearchResult] = []

        switch filter {
        case .all:
            results.append(contentsOf: searchAccounts(query))
            results.append(contentsOf: searchTransactions(query))
            results.append(contentsOf: searchSubscriptions(query))
            results.append(contentsOf: searchBudgets(query))
        case .accounts:
            results.append(contentsOf: searchAccounts(query))
        case .transactions:
            results.append(contentsOf: searchTransactions(query))
        case .subscriptions:
            results.append(contentsOf: searchSubscriptions(query))
        case .budgets:
            results.append(contentsOf: searchBudgets(query))
        }

        // Sort by relevance score
        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    private func searchAccounts(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<FinancialAccount>()
        guard let accounts = try? modelContext.fetch(descriptor) else { return [] }

        return accounts.compactMap { account in
            let titleScore = calculateRelevance(account.name, query: query)
            let balanceScore = calculateRelevance(String(format: "%.2f", account.balance), query: query)

            let score = max(titleScore, balanceScore)
            if score > 0 {
                return SearchResult(
                    title: account.name,
                    subtitle: String(format: "Balance: $%.2f", account.balance),
                    type: .accounts,
                    relevanceScore: score,
                    associatedId: String(describing: account.id)
                )
            }
            return nil
        }
    }

    private func searchTransactions(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<FinancialTransaction>()
        guard let transactions = try? modelContext.fetch(descriptor) else { return [] }

        return transactions.compactMap { transaction in
            let titleScore = calculateRelevance(transaction.title, query: query)
            let amountScore = calculateRelevance(String(format: "%.2f", transaction.amount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    title: transaction.title,
                    subtitle: String(format: "$%.2f • %@", transaction.amount, transaction.date.formatted()),
                    type: .transactions,
                    relevanceScore: score,
                    associatedId: String(describing: transaction.id)
                )
            }
            return nil
        }
    }

    private func searchSubscriptions(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<Subscription>()
        guard let subscriptions = try? modelContext.fetch(descriptor) else { return [] }

        return subscriptions.compactMap { subscription in
            let titleScore = calculateRelevance(subscription.name, query: query)
            let amountScore = calculateRelevance(String(format: "%.2f", subscription.amount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    title: subscription.name,
                    subtitle: String(format: "$%.2f • %@", subscription.amount, subscription.billingCycle.rawValue),
                    type: .subscriptions,
                    relevanceScore: score,
                    associatedId: String(describing: subscription.id)
                )
            }
            return nil
        }
    }

    private func searchBudgets(_ query: String) -> [SearchResult] {
        let descriptor = FetchDescriptor<Budget>()
        guard let budgets = try? modelContext.fetch(descriptor) else { return [] }

        return budgets.compactMap { budget in
            let titleScore = calculateRelevance(budget.name, query: query)
            let amountScore = calculateRelevance(String(format: "%.2f", budget.limitAmount), query: query)

            let score = max(titleScore, amountScore)
            if score > 0 {
                return SearchResult(
                    title: budget.name,
                    subtitle: String(format: "$%.2f limit", budget.limitAmount),
                    type: .budgets,
                    relevanceScore: score,
                    associatedId: String(describing: budget.id)
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
