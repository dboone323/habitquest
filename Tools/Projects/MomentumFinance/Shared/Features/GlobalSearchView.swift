//
//  GlobalSearchView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftData
import SwiftUI

extension Features {
<<<<<<< HEAD
    /// Global search component with advanced filtering and navigation
    struct GlobalSearchView: View {
        @Environment(\.modelContext) private var modelContext
        @Environment(\.dismiss) private var dismiss

        @Query private var accounts: [FinancialAccount]
        @Query private var transactions: [FinancialTransaction]
        @Query private var subscriptions: [Subscription]
        @Query private var budgets: [Budget]
        @Query private var goals: [SavingsGoal]

        @State private var searchText = ""
        @State private var selectedFilter: SearchFilter = .all
        @State private var searchResults: [NavigationCoordinator.SearchResult] = []
        @State private var isLoading = false

        private let navigationCoordinator = NavigationCoordinator.shared

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Search Header
                    SearchHeaderView(
                        searchText: $searchText,
                        selectedFilter: $selectedFilter,
                        onSearchChanged: performSearch,
                        )

                    // Search Results
                    SearchResultsListView(
=======
    /// Global search coordinator with advanced filtering and navigation
    struct GlobalSearchView: View {
        @Environment(\.modelContext) private var modelContext
        @Environment(\.dismiss) private var dismiss
        
        #if canImport(SwiftData)
            private var accounts: [FinancialAccount] = []
            private var transactions: [FinancialTransaction] = []
            private var subscriptions: [Subscription] = []
            private var budgets: [Budget] = []
            private var goals: [SavingsGoal] = []
        #else
            private var accounts: [FinancialAccount] = []
            private var transactions: [FinancialTransaction] = []
            private var subscriptions: [Subscription] = []
            private var budgets: [Budget] = []
            private var goals: [SavingsGoal] = []
        #endif

        @State private var searchText = ""
        @State private var selectedFilter: SearchFilter = .all
        @State private var searchResults: [SearchResult] = []
        @State private var isLoading = false
        @StateObject private var searchEngine: SearchEngineService

        private let navigationCoordinator = NavigationCoordinator.shared

        init() {
            // Initialize search engine with placeholder context
            self._searchEngine = StateObject(wrappedValue: SearchEngineService(modelContext: ModelContext(try! ModelContainer(for: FinancialAccount.self))))
        }

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    SearchHeaderComponent(
                        searchText: $searchText,
                        selectedFilter: $selectedFilter,
                        onSearchChanged: performSearch
                    )

                    SearchResultsComponent(
>>>>>>> 1cf3938 (Create working state for recovery)
                        results: searchResults,
                        isLoading: isLoading,
                        onResultTapped: { result in
                            navigationCoordinator.navigateToSearchResult(result)
                            dismiss()
<<<<<<< HEAD
                        },
                        )
                }
                .navigationTitle("Search")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            navigationCoordinator.deactivateSearch()
                            dismiss()
                        }
                    }
                }
                #else
                .toolbar {
                ToolbarItem(placement: .automatic) {
                Button("Done") {
                navigationCoordinator.deactivateSearch()
                dismiss()
                }
                }
                }
                #endif
            }
            .onAppear {
                // Focus search on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
=======
                        }
                    )
                }
                .navigationTitle("Search")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                NavigationCoordinator.shared.deactivateSearch()
                                dismiss()
                            }
                        }
                    }
                #else
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button("Done") {
                                NavigationCoordinator.shared.deactivateSearch()
                                dismiss()
                            }
                        }
                    }
                #endif
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + SearchConfiguration.searchDebounceDelay) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    performSearch()
                }
            }
        }

        private func performSearch() {
            isLoading = true

            Task {
<<<<<<< HEAD
                let results = await searchAcrossAllModules(query: searchText, filter: selectedFilter)
=======
                let results = await searchEngine.searchAcrossAllModules(
                    query: searchText,
                    filter: selectedFilter,
                    accounts: accounts,
                    transactions: transactions,
                    subscriptions: subscriptions,
                    budgets: budgets,
                    goals: goals
                )
>>>>>>> 1cf3938 (Create working state for recovery)

                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            }
        }
<<<<<<< HEAD

        private func searchAcrossAllModules(
            query: String,
            filter: SearchFilter,
            ) async -> [NavigationCoordinator.SearchResult] {
            let lowercasedQuery = query.lowercased()
            var results: [NavigationCoordinator.SearchResult] = []

            // Search Accounts
            if filter == .all || filter == .accounts {
                let accountResults = accounts
                    .filter { account in
                        account.name.lowercased().contains(lowercasedQuery) ||
                            account.name.lowercased().contains(lowercasedQuery)
                    }
                    .map { account in
                        NavigationCoordinator.SearchResult(
                            id: "\(account.persistentModelID)",
                            title: account.name,
                            subtitle: "Account • \(account.balance.formatted(.currency(code: "USD")))",
                            type: .account,
                            relatedId: nil,
                            )
                    }
                results.append(contentsOf: accountResults)
            }

            // Search Transactions
            if filter == .all || filter == .transactions {
                let transactionResults = transactions
                    .filter { transaction in
                        transaction.title.lowercased().contains(lowercasedQuery) ||
                            (transaction.category?.name.lowercased().contains(lowercasedQuery) ?? false)
                    }
                    .prefix(20) // Limit transaction results
                    .map { transaction in
                        NavigationCoordinator.SearchResult(
                            id: "\(transaction.persistentModelID)",
                            title: transaction.title,
                            subtitle: "\(transaction.amount.formatted(.currency(code: "USD"))) • \(transaction.date.formatted(date: .abbreviated, time: .omitted))",
                            type: .transaction,
                            relatedId: transaction.account != nil ? "\(transaction.account!.persistentModelID)" : nil,
                            )
                    }
                results.append(contentsOf: transactionResults)
            }

            // Search Subscriptions
            if filter == .all || filter == .subscriptions {
                let subscriptionResults = subscriptions
                    .filter { subscription in
                        subscription.name.lowercased().contains(lowercasedQuery) ||
                            subscription.name.lowercased().contains(lowercasedQuery) ||
                            (subscription.category?.name.lowercased().contains(lowercasedQuery) ?? false)
                    }
                    .map { subscription in
                        NavigationCoordinator.SearchResult(
                            id: "\(subscription.persistentModelID)",
                            title: subscription.name,
                            subtitle: "\(subscription.amount.formatted(.currency(code: "USD"))) • \(subscription.billingCycle.rawValue)",
                            type: .subscription,
                            relatedId: subscription.account != nil ? "\(subscription.account!.persistentModelID)" : nil,
                            )
                    }
                results.append(contentsOf: subscriptionResults)
            }

            // Search Budgets
            if filter == .all || filter == .budgets {
                let budgetResults = budgets
                    .filter { budget in
                        budget.category?.name.lowercased().contains(lowercasedQuery) ?? false
                    }
                    .map { budget in
                        NavigationCoordinator.SearchResult(
                            id: "\(budget.persistentModelID)",
                            title: "Budget: \(budget.category?.name ?? "Unknown")",
                            subtitle: "\(budget.spentAmount.formatted(.currency(code: "USD"))) / \(budget.limitAmount.formatted(.currency(code: "USD")))",
                            type: .budget,
                            relatedId: budget.category != nil ? "\(budget.category!.persistentModelID)" : nil,
                            )
                    }
                results.append(contentsOf: budgetResults)
            }

            // Search Goals
            if filter == .all || filter == .goals {
                let goalResults = goals
                    .filter { goal in
                        goal.name.lowercased().contains(lowercasedQuery)
                    }
                    .map { goal in
                        NavigationCoordinator.SearchResult(
                            id: "\(goal.persistentModelID)",
                            title: goal.name,
                            subtitle: "\(goal.currentAmount.formatted(.currency(code: "USD"))) / \(goal.targetAmount.formatted(.currency(code: "USD")))",
                            type: .goal,
                            relatedId: nil,
                            )
                    }
                results.append(contentsOf: goalResults)
            }

            return results.sorted { $0.title < $1.title }
        }
    }

    // MARK: - Search Filter Enum

    enum SearchFilter: String, CaseIterable {
        case all = "All"
        case accounts = "Accounts"
        case transactions = "Transactions"
        case subscriptions = "Subscriptions"
        case budgets = "Budgets"
        case goals = "Goals"

        var icon: String {
            switch self {
            case .all: "magnifyingglass"
            case .accounts: "building.columns"
            case .transactions: "creditcard"
            case .subscriptions: "arrow.clockwise.circle"
            case .budgets: "chart.pie"
            case .goals: "target"
            }
        }
    }

    // MARK: - Search Header View

    struct SearchHeaderView: View {
        @Binding var searchText: String
        @Binding var selectedFilter: SearchFilter
        let onSearchChanged: () -> Void

        var body: some View {
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search everything...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { _, _ in
                            onSearchChanged()
                        }

                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            onSearchChanged()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Filter Segments
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SearchFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                filter: filter,
                                isSelected: selectedFilter == filter,
                                onTap: {
                                    selectedFilter = filter
                                    onSearchChanged()
                                },
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
            .background(Color.primary.colorInvert())
        }
    }

    // MARK: - Filter Chip

    struct FilterChip: View {
        let filter: SearchFilter
        let isSelected: Bool
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 6) {
                    Image(systemName: filter.icon)
                        .font(.caption)
                    Text(filter.rawValue)
                        .font(.caption.weight(.medium))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.blue : Color.gray.opacity(0.2),
                    )
                .foregroundColor(
                    isSelected ? .white : .primary,
                    )
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Search Results List

    struct SearchResultsListView: View {
        let results: [NavigationCoordinator.SearchResult]
        let isLoading: Bool
        let onResultTapped: (NavigationCoordinator.SearchResult) -> Void

        var body: some View {
            if isLoading {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if results.isEmpty {
                EmptySearchResultsView()
            } else {
                List(results) { result in
                    SearchResultRow(result: result, onTapped: onResultTapped)
                }
                .listStyle(PlainListStyle())
            }
        }
    }

    // MARK: - Search Result Row

    struct SearchResultRow: View {
        let result: NavigationCoordinator.SearchResult
        let onTapped: (NavigationCoordinator.SearchResult) -> Void

        var body: some View {
            Button {
                onTapped(result)
            } label: {
                HStack {
                    // Type Icon
                    Image(systemName: result.type.icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if let subtitle = result.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Empty Search Results

    struct EmptySearchResultsView: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("No Results Found")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Try adjusting your search terms or filters")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.colorInvert())
        }
    }
}

// MARK: - Search Result Type Extensions

extension NavigationCoordinator.SearchResult.SearchResultType {
    var icon: String {
        switch self {
        case .account: "building.columns"
        case .transaction: "creditcard"
        case .subscription: "arrow.clockwise.circle"
        case .budget: "chart.pie"
        case .goal: "target"
        }
=======
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}

#Preview {
    Features.GlobalSearchView()
}
