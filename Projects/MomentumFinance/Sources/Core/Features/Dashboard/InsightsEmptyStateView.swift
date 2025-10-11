import SwiftUI

public struct InsightsEmptyStateView: View {
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No insights available")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Insights will appear here once you have enough financial data for analysis.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                Text("💡 **Tips to generate insights:**")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 16, height: 16)
                        Text("Add more transactions")
                            .font(.subheadline)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 16, height: 16)
                        Text("Set up budgets and track spending")
                            .font(.subheadline)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 16, height: 16)
                        Text("Add subscription tracking")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
