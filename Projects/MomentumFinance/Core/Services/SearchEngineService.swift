//
//  SearchEngineService.swift
//  MomentumFinance
//
//  Service for performing global search across financial data
//

import Foundation
import SwiftData
import SwiftUI

/// Service for performing global search across financial data
public final class SearchEngineService: ObservableObject {
    private var modelContext: ModelContext?

    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    /// Update the model context (useful for initialization timing)
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// Perform search across financial data
    /// - Parameters:
    ///   - query: Search query string
    ///   - filter: Type of data to search
    /// - Returns: Array of search results
    public func search(query: String, filter: SearchFilter) -> [SearchResult] {
        guard self.modelContext != nil, !query.isEmpty else {
            return []
        }

        let normalizedQuery = query.lowercased()

        switch filter {
        case .all:
            return self.searchAll(query: normalizedQuery)
        case .accounts:
            return self.searchAccounts(query: normalizedQuery)
        case .transactions:
            return self.searchTransactions(query: normalizedQuery)
        case .subscriptions:
            return self.searchSubscriptions(query: normalizedQuery)
        case .budgets:
            return self.searchBudgets(query: normalizedQuery)
        }
    }

    private func searchAll(query: String) -> [SearchResult] {
        var results: [SearchResult] = []

        results.append(contentsOf: self.searchAccounts(query: query))
        results.append(contentsOf: self.searchTransactions(query: query))
        results.append(contentsOf: self.searchSubscriptions(query: query))
        results.append(contentsOf: self.searchBudgets(query: query))

        // Sort by relevance score and limit results
        return
            results
                .sorted { $0.relevanceScore > $1.relevanceScore }
                .prefix(SearchConfiguration.maxResults)
                .map(\.self)
    }

    private func searchAccounts(query: String) -> [SearchResult] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<FinancialAccount>()
        guard let accounts = try? modelContext.fetch(descriptor) else { return [] }

        return
            accounts
                .filter { account in
                    account.name.lowercased().contains(query)
                        || account.accountType.rawValue.lowercased().contains(query)
                }
                .map { account in
                    SearchResult(
                        id: String(describing: account.persistentModelID),
                        title: account.name,
                        subtitle:
                        "\(account.accountType.rawValue) • $\(account.balance, default: "%.2f")",
                        type: .accounts,
                        iconName: "creditcard",
                        data: account,
                        relevanceScore: self.calculateRelevance(query: query, text: account.name)
                    )
                }
    }

    private func searchTransactions(query: String) -> [SearchResult] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<FinancialTransaction>(
            sortBy: [SortDescriptor(\FinancialTransaction.date, order: .reverse)]
        )
        guard let transactions = try? modelContext.fetch(descriptor) else { return [] }

        return
            transactions
                .filter { transaction in
                    transaction.title.lowercased().contains(query)
                        || transaction.category?.name.lowercased().contains(query) ?? false
                }
                .prefix(50) // Limit for performance
                .map { transaction in
                    SearchResult(
                        id: String(describing: transaction.persistentModelID),
                        title: transaction.title,
                        subtitle:
                        "\(transaction.category?.name ?? "No Category") • $\(transaction.amount, default: "%.2f")",
                        type: .transactions,
                        iconName: transaction.amount >= 0 ? "arrow.up.circle" : "arrow.down.circle",
                        data: transaction,
                        relevanceScore: self.calculateRelevance(query: query, text: transaction.title)
                    )
                }
    }

    private func searchSubscriptions(query: String) -> [SearchResult] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<Subscription>()
        guard let subscriptions = try? modelContext.fetch(descriptor) else { return [] }

        return
            subscriptions
                .filter { subscription in
                    subscription.name.lowercased().contains(query)
                        || subscription.category?.name.lowercased().contains(query) ?? false
                }
                .map { subscription in
                    SearchResult(
                        id: String(describing: subscription.persistentModelID),
                        title: subscription.name,
                        subtitle:
                        "$\(subscription.amount, default: "%.2f") • \(subscription.billingCycle.rawValue)",
                        type: .subscriptions,
                        iconName: "calendar",
                        data: subscription,
                        relevanceScore: self.calculateRelevance(query: query, text: subscription.name)
                    )
                }
    }

    private func searchBudgets(query: String) -> [SearchResult] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<Budget>()
        guard let budgets = try? modelContext.fetch(descriptor) else { return [] }

        return
            budgets
                .filter { budget in
                    budget.category?.name.lowercased().contains(query) ?? false
                }
                .map { budget in
                    let spentPercent = budget.spentAmount / budget.limitAmount
                    return SearchResult(
                        id: String(describing: budget.persistentModelID),
                        title: budget.category?.name ?? "Budget",
                        subtitle:
                        "$\(budget.spentAmount, default: "%.2f") / $\(budget.limitAmount, default: "%.2f") (\(Int(spentPercent * 100))%)",
                        type: .budgets,
                        iconName: spentPercent > 1.0 ? "exclamationmark.triangle" : "chart.pie",
                        data: budget,
                        relevanceScore: self.calculateRelevance(
                            query: query, text: budget.category?.name ?? ""
                        )
                    )
                }
    }

    /// Calculate relevance score for search results
    private func calculateRelevance(query: String, text: String) -> Double {
        let normalizedText = text.lowercased()

        // Exact match gets highest score
        if normalizedText == query {
            return 1.0
        }

        // Starts with query gets high score
        if normalizedText.hasPrefix(query) {
            return 0.8
        }

        // Contains query gets medium score
        if normalizedText.contains(query) {
            return 0.6
        }

        // Word boundary match gets lower score
        let words = normalizedText.split(separator: " ")
        for word in words {
            if word.hasPrefix(query) {
                return 0.4
            }
        }

        return 0.2
    }
}
