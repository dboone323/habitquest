// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

public enum Features {}

// Dashboard namespace
extension Features {
    public enum Dashboard {}
}

// Transactions namespace
extension Features {
    public enum Transactions {}
}

// Budgets namespace
extension Features {
    public enum Budgets {}
}

// Subscriptions namespace
extension Features {
    public enum Subscriptions {}
}

// GoalsAndReports namespace
extension Features {
    public enum GoalsAndReports {}
}

// Theme namespace
extension Features {
    public enum Theme {}
}

// Global Search namespace
extension Features {
    public enum GlobalSearch {
        /// Global search coordinator with advanced filtering and navigation
        public struct GlobalSearchView: View {
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

            public init() {
                // Initialize search engine with placeholder context - will be updated in onAppear
                let container = try! ModelContainer(
                    for: FinancialAccount.self, FinancialTransaction.self)
                self._searchEngine = StateObject(
                    wrappedValue: SearchEngineService(modelContext: ModelContext(container)))
            }

            public var body: some View {
                NavigationView {
                    VStack(spacing: 0) {
                        // Inline Search Header Component
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search...", text: $searchText)
                                    .textFieldStyle(.plain)
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        performSearch()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)

                            // Filter Picker
                            Picker("Filter", selection: $selectedFilter) {
                                ForEach(SearchFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }
                        .padding(.vertical)

                        // Inline Search Results Component
                        Group {
                            if isLoading {
                                ProgressView("Searching...")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if searchResults.isEmpty && !searchText.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 48))
                                        .foregroundColor(.secondary)
                                    Text("No results found")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Try adjusting your search terms")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(searchResults, id: \.id) { result in
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(result.title)
                                                    .font(.headline)
                                                Text(result.subtitle ?? "No description")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Text(result.type.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(Color.gray.opacity(0.05))
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                navigationCoordinator.navigateToSearchResult(result)
                                                dismiss()
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
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
                            .accessibilityLabel("Done")
                        }
                    }
                    #else
                    .toolbar {
                    ToolbarItem(placement: .automatic) {
                    Button("Done") {
                    NavigationCoordinator.shared.deactivateSearch()
                    dismiss()
                    }
                    .accessibilityLabel("Done")
                    }
                    }
                    #endif
                }
                .onAppear {
                    // Update search engine with actual model context
                    _searchEngine.wrappedValue.setModelContext(modelContext)
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
}
