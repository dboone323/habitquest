// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

public enum Features {}

// Dashboard namespace
public extension Features {
    enum FinancialDashboard {}
}

// Transactions namespace
public extension Features {
    enum Transactions {}
}

// Budgets namespace
public extension Features {
    enum Budgets {}
}

// Subscriptions namespace
public extension Features {
    enum Subscriptions {}
}

// GoalsAndReports namespace
public extension Features {
    enum GoalsAndReports {}
}

// Theme namespace
public extension Features {
    enum Theme {}
}

// Global Search namespace
public extension Features {
    enum GlobalSearch {
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
                do {
                    let container = try ModelContainer(
                        for: FinancialAccount.self, FinancialTransaction.self
                    )
                    _searchEngine = StateObject(
                        wrappedValue: SearchEngineService(modelContext: ModelContext(container))
                    )
                } catch {
                    // Fallback to empty container if initialization fails
                    do {
                        let container = try ModelContainer()
                        _searchEngine = StateObject(
                            wrappedValue: SearchEngineService(modelContext: ModelContext(container))
                        )
                    } catch {
                        // If even the empty container fails, create a minimal fallback
                        _searchEngine = StateObject(
                            wrappedValue: SearchEngineService(modelContext: nil)
                        )
                    }
                }
            }

            public var body: some View {
                NavigationView {
                    VStack(spacing: 0) {
                        // Inline Search Header Component
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search...", text: self.$searchText).accessibilityLabel(
                                    "Text Field"
                                )
                                .textFieldStyle(.plain)
                                if !self.searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                        self.performSearch()
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
                            Picker("Filter", selection: self.$selectedFilter) {
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
                            if self.isLoading {
                                ProgressView("Searching...")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if self.searchResults.isEmpty, !self.searchText.isEmpty {
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
                                        ForEach(self.searchResults, id: \.id) { result in
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
                                                self.navigationCoordinator.navigateToSearchResult(
                                                    result
                                                )
                                                self.dismiss()
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
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    NavigationCoordinator.shared.deactivateSearch()
                                    self.dismiss()
                                }
                                .accessibilityLabel("Done")
                            }
                        })
                    #else
                        .toolbar(content: {
                            ToolbarItem(placement: .automatic) {
                                Button("Done") {
                                    NavigationCoordinator.shared.deactivateSearch()
                                    self.dismiss()
                                }
                                .accessibilityLabel("Done")
                            }
                        })
                    #endif
                }
                .onAppear {
                    // Update search engine with actual model context
                    _searchEngine.wrappedValue.setModelContext(self.modelContext)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.performSearch()
                    }
                }
            }

            private func performSearch() {
                guard !self.searchText.isEmpty else {
                    self.searchResults = []
                    self.isLoading = false
                    return
                }

                self.isLoading = true

                Task {
                    let results = self.searchEngine.search(
                        query: self.searchText, filter: self.selectedFilter
                    )
                    self.searchResults = results
                    self.isLoading = false
                }
            }
        }
    }
}
