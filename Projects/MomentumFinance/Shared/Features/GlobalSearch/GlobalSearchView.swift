import SwiftData
import SwiftUI

public struct GlobalSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var selectedResult: SearchResult?

    private var searchEngine: SearchEngineService {
        SearchEngineService(modelContext: modelContext)
    }

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search transactions, accounts, budgets...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { _, newValue in
                            performSearch(query: newValue)
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)

                // Results
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyStateView
                } else if !searchResults.isEmpty {
                    resultsList
                } else {
                    recentSearchesView
                }
            }
            .navigationTitle("Search")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedResult) { result in
                SearchResultDetailView(result: result)
            }
            .onAppear {
                // Model context is now passed to searchEngine via computed property
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))

            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Try adjusting your search terms")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private var recentSearchesView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))

            VStack(spacing: 8) {
                Text("Recent Searches")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Your recent searches will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { result in
                    SearchResultRow(result: result)
                        .onTapGesture {
                            selectedResult = result
                            navigationCoordinator.navigateToSearchResult(result)
                            dismiss()
                        }

                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        let results = searchEngine.search(query: query)
        searchResults = results
        isSearching = false
    }
}

// MARK: - Supporting Views

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)

                Image(systemName: result.iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let subtitle = result.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(result.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private var iconBackgroundColor: Color {
        switch result.type {
        case .accounts:
            return .blue
        case .transactions:
            return .green
        case .budgets:
            return .orange
        case .subscriptions:
            return .purple
        case .all:
            return .gray
        }
    }
}

struct SearchResultDetailView: View {
    let result: SearchResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(iconBackgroundColor)
                            .frame(width: 60, height: 60)

                        Image(systemName: result.iconName)
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                    }

                    Text(result.title)
                        .font(.title)
                        .fontWeight(.bold)

                    if let subtitle = result.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)

                // Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Type", value: result.type.rawValue.capitalized)

                    if let data = result.data as? [String: Any] {
                        ForEach(data.keys.sorted(), id: \.self) { key in
                            if let value = data[key] {
                                DetailRow(label: key.capitalized, value: String(describing: value))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var iconBackgroundColor: Color {
        switch result.type {
        case .accounts:
            return .blue
        case .transactions:
            return .green
        case .budgets:
            return .orange
        case .subscriptions:
            return .purple
        case .all:
            return .gray
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}
