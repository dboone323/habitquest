import SwiftUI

public struct SearchResultsComponent: View {
    let results: [SearchResult]
    let isLoading: Bool
    var onResultTapped: ((SearchResult) -> Void)?

    public init(results: [SearchResult], isLoading: Bool, onResultTapped: ((SearchResult) -> Void)? = nil) {
        self.results = results
        self.isLoading = isLoading
        self.onResultTapped = onResultTapped
    }

    public var body: some View {
        Group {
            if self.isLoading {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if self.results.isEmpty {
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
                List(self.results) { result in
                    SearchResultRow(result: result, onResultTapped: self.onResultTapped)
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct SearchResultRow: View {
    let result: SearchResult
    var onResultTapped: ((SearchResult) -> Void)?

    var body: some View {
        Button(action: { self.onResultTapped?(self.result).accessibilityLabel("Button").accessibilityLabel("Button") }) {
            HStack(spacing: 12) {
                // Icon based on type
                Image(systemName: self.result.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(self.result.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let subtitle = result.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Type indicator
                Text(self.result.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
