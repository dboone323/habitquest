import SwiftUI

public struct AnalyticsTabView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics Overview")
                .font(.headline)
                .fontWeight(.semibold)

            Picker("Analytics Tab", selection: self.$selectedTab) {
                Text("Trends").tag(0)
                Text("Patterns").tag(1)
                Text("Insights").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())

            Group {
                switch self.selectedTab {
                case 0:
                    TrendsView()
                case 1:
                    PatternsView()
                case 2:
                    InsightsView()
                default:
                    TrendsView()
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(16)
    }
}

public struct TrendsView: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Completion Rate")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 12%")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            HStack {
                Image(systemName: "flame")
                    .foregroundColor(.orange)
                Text("Streak Performance")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 8%")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            HStack {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
                Text("XP Growth")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("↗ 15%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}

public struct PatternsView: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Best Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("9:00 AM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Most Active Day")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Monday")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                Text("Mood Correlation")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("Positive")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}

public struct InsightsView: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                Text("AI Recommendation")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text(
                "Consider adding a morning meditation habit. Your completion rate is 23% higher for morning activities."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)

            HStack {
                Image(systemName: "target")
                    .foregroundColor(.green)
                Text("Next Milestone")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("You're 3 days away from your longest streak record!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
    }
}
