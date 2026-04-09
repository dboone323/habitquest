import SwiftUI

// MARK: - Consistency Insight View

/// Enhanced insights with interactive elements
public struct ConsistencyInsightView: View {
    let insights: [ConsistencyInsight]
    @State private var expandedInsight: String?

    public var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(insights, id: \.title) { insight in
                InsightCard(
                    insight: insight,
                    isExpanded: expandedInsight == insight.title
                ) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        expandedInsight = expandedInsight == insight.title ? nil : insight.title
                    }
                }
            }
        }
    }
}

public struct InsightCard: View {
    let insight: ConsistencyInsight
    let isExpanded: Bool
    let onTap: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader

            if isExpanded {
                expandedContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(perform: onTap)
    }

    private var cardHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.type.icon)
                .font(.title3)
                .foregroundColor(insight.type.color)
                .symbolEffect(.bounce, value: isExpanded)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
            }

            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.spring(response: 0.4), value: isExpanded)
        }
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()

            Text("Actionable insights coming soon...")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(insight.type.color.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(insight.type.color.opacity(0.2), lineWidth: 1)
            )
    }
}
