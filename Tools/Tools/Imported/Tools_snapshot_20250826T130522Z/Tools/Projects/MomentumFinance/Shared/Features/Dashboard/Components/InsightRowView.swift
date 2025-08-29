import SwiftUI

struct InsightRowView: View {
    let insight: FinancialInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Priority Icon
                Image(systemName: insight.priority.icon)
                    .foregroundColor(insight.priority.color)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    // Description
                    Text(insight.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Type Badge
                    HStack {
                        Image(systemName: insight.type.icon)
                            .font(.caption)
                        Text(insight.type.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    InsightRowView(
        insight: FinancialInsight(
            id: UUID(),
            title: "High Spending Alert",
            description: "Your dining out spending is 30% above average this month.",
            type: .spending,
            priority: .high,
            data: [("Dining", 450.0), ("Average", 350.0)]
        )
    ) {
        print("Insight tapped")
    }
}
