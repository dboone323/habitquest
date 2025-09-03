import SwiftUI

// MARK: - Search Empty State Component

struct SearchEmptyStateComponent: View {
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

#Preview {
    SearchEmptyStateComponent()
}
