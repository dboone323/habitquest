import SwiftUI

// MARK: - Consistency Insight View

/// Enhanced insights with interactive elements
public struct ConsistencyInsightView: View {
    let insights: [ConsistencyInsight]
    @State private var expandedInsight: String?

    public var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(self.insights, id: \.title) { insight in
                InsightCard(
                    insight: insight,
                    isExpanded: self.expandedInsight == insight.title
                ) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.expandedInsight = self.expandedInsight == insight.title ? nil : insight.title
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
            self.cardHeader

            if self.isExpanded {
                self.expandedContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
        .padding(16)
        .background(self.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(perform: self.onTap)
    }

    private var cardHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: self.insight.type.icon)
                .font(.title3)
                .foregroundColor(self.insight.type.color)
                .symbolEffect(.bounce, value: self.isExpanded)

            VStack(alignment: .leading, spacing: 4) {
                Text(self.insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(self.insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(self.isExpanded ? nil : 2)
            }

            Spacer()

            Image(systemName: self.isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(self.isExpanded ? 180 : 0))
                .animation(.spring(response: 0.4), value: self.isExpanded)
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
            .fill(self.insight.type.color.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(self.insight.type.color.opacity(0.2), lineWidth: 1)
            )
    }
}
