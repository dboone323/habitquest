import SwiftUI

struct InsightsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Insights Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add some transactions and accounts to get personalized financial insights.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    InsightsEmptyStateView()
}
