import SwiftUI

struct InsightActionButtons: View {
    let insight: FinancialInsight
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Priority-specific actions
            switch insight.priority {
            case .critical:
                Button("Take Action Now") {
                    // Handle critical action
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

            case .high:
                Button("Review & Act") {
                    // Handle high priority action
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

            case .medium:
                Button("Learn More") {
                    // Handle medium priority action
                }
                .buttonStyle(.bordered)

            case .low:
                Button("Dismiss") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }

            // Generic actions
            Button("Share Insight") {
                // Handle sharing
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    InsightActionButtons(
        insight: FinancialInsight(
            id: UUID(),
            title: "Budget Alert",
            description: "You're approaching your monthly budget limit.",
            type: .budgets,
            priority: .high,
            data: [("Spent", 800.0), ("Budget", 1000.0)]
        )
    ) {
        print("Dismissed")
    }
}
