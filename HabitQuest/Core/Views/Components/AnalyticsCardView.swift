import SwiftUI

// MARK: - Analytics Card View

/// Enhanced analytics card with motion design and accessibility
public struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    let trend: TrendDirection?

    @State private var animateValue = false
    @State private var showTrend = false

    enum TrendDirection {
        case upDirection, down, stable

        var icon: String {
            switch self {
            case .upDirection: "arrow.up.right"
            case .down: "arrow.down.right"
            case .stable: "minus"
            }
        }

        var color: Color {
            switch self {
            case .upDirection: .green
            case .down: .red
            case .stable: .orange
            }
        }
    }

    init(
        title: String, value: String, subtitle: String, color: Color, icon: String,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
        self.trend = trend
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            valueSection
            subtitleSection
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(animateValue ? 1.02 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateValue)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                showTrend = true
            }
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                animateValue = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(subtitle)")
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color.gradient)
                .symbolEffect(.bounce, value: animateValue)

            Spacer()

            if let trend, showTrend {
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption)
                        .foregroundColor(trend.color)

                    Circle()
                        .fill(trend.color)
                        .frame(width: 6, height: 6)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    )
                )
            }
        }
    }

    private var valueSection: some View {
        Text(value)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(color.gradient)
            .contentTransition(.numericText(countsDown: false))
    }

    private var subtitleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
    }
}
