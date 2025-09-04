import SwiftUI

// MARK: - Search Results Component

struct SearchResultsComponent: View {
    let results: [SearchResult]
    let isLoading: Bool
    let onResultTapped: (SearchResult) -> Void

    var body: some View {
        if isLoading {
            SearchLoadingView()
        } else if results.isEmpty {
            SearchEmptyStateComponent()
        } else {
            List(results) { result in
                SearchResultRowComponent(
                    result: result,
                    onTapped: onResultTapped
                )
            }
            .listStyle(PlainListStyle())
        }
    }
}

// MARK: - Search Loading View

private struct SearchLoadingView: View {
    var body: some View {
        ProgressView("Searching...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Search Result Row Component

struct SearchResultRowComponent: View {
    let result: SearchResult
    let onTapped: (SearchResult) -> Void

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

#Preview {
    SearchResultsComponent(
        results: [],
        isLoading: false,
        onResultTapped: { _ in }
    )
}
