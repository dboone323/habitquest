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
            let container = try! ModelContainer(for: FinancialAccount.self, FinancialTransaction.self)
            self._searchEngine = StateObject(wrappedValue: SearchEngineService(modelContext: ModelContext(container)))
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
                        results: searchResults,
                        isLoading: isLoading,
                        onResultTapped: { result in
                            navigationCoordinator.navigateToSearchResult(result)
                            dismiss()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    performSearch()
                }
            }
        }

        private func performSearch() {
            guard !searchText.isEmpty else {
                searchResults = []
                isLoading = false
                return
            }

            isLoading = true

            Task {
                let results = searchEngine.search(query: searchText, filter: selectedFilter)
                searchResults = results
                isLoading = false
            }
        }
    }
}

#Preview {
    Features.GlobalSearchView()
}
