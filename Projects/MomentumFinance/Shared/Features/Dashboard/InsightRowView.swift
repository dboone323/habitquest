import SwiftUI

public struct InsightRowView: View {
    let insight: FinancialInsight
    let action: () -> Void

    public init(insight: FinancialInsight, action: @escaping () -> Void) {
        self.insight = insight
        self.action = action
    }

    public var body: some View {
        Button(role: .none, action: action) {
            HStack(spacing: 12) {
                // Priority indicator
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(insight.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        Label(insight.type.rawValue, systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(Int(insight.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var priorityColor: Color {
        switch insight.priority {
        case .critical: .red
        case .high: .orange
        case .medium: .yellow
        case .low: .green
        }
    }
}
