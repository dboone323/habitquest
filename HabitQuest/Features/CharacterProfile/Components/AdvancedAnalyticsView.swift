import SwiftUI

public struct AdvancedAnalyticsView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Analytics Overview Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Streak Heat Map")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(
                            "Advanced heat map visualization will be available when habits are selected."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        #if os(iOS)
                            .background(Color(.systemGray6))
                        #else
                            .background(Color(nsColor: .windowBackgroundColor))
                        #endif
                            .cornerRadius(12)
                    }
                    .padding()
                    #if os(iOS)
                        .background(Color(.systemGray6))
                    #else
                        .background(Color(nsColor: .windowBackgroundColor))
                    #endif
                        .cornerRadius(16)

                    // Detailed Analytics Components
                    AnalyticsInsightsCard()
                    PredictiveAnalyticsCard()
                    BehavioralPatternsCard()
                }
                .padding()
            }
            .navigationTitle("Advanced Analytics")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
            #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .accessibilityLabel("Button")
                    }
                }
        }
    }
}

public struct AnalyticsInsightsCard: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI-Powered Insights")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                InsightRow(
                    icon: "brain",
                    title: "Optimal Scheduling",
                    insight:
                    "Your success rate is 34% higher when habits are scheduled before 10 AM",
                    color: .blue
                )

                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Streak Prediction",
                    insight: "89% probability of maintaining current streak for next 7 days",
                    color: .green
                )

                InsightRow(
                    icon: "heart.text.square",
                    title: "Mood Correlation",
                    insight: "Meditation habit strongly correlates with improved daily mood scores",
                    color: .purple
                )
            }
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

public struct InsightRow: View {
    let icon: String
    let title: String
    let insight: String
    let color: Color

    public init(icon: String, title: String, insight: String, color: Color) {
        self.icon = icon
        self.title = title
        self.insight = insight
        self.color = color
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(insight)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

public struct PredictiveAnalyticsCard: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Predictive Analytics")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                PredictionRow(
                    title: "7-Day Streak Success",
                    probability: 0.89,
                    color: .green
                )

                PredictionRow(
                    title: "Monthly Goal Achievement",
                    probability: 0.76,
                    color: .orange
                )

                PredictionRow(
                    title: "Habit Consistency",
                    probability: 0.92,
                    color: .blue
                )
            }
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

public struct PredictionRow: View {
    let title: String
    let probability: Double
    let color: Color

    public init(title: String, probability: Double, color: Color) {
        self.title = title
        self.probability = probability
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(probability * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            ProgressView(value: probability)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 1.2)
        }
    }
}

public struct BehavioralPatternsCard: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Behavioral Patterns")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                PatternRow(
                    icon: "clock.fill",
                    title: "Peak Performance Time",
                    value: "8:00 - 10:00 AM",
                    color: .blue
                )

                PatternRow(
                    icon: "calendar.badge.clock",
                    title: "Most Consistent Day",
                    value: "Tuesday",
                    color: .green
                )

                PatternRow(
                    icon: "moon.stars.fill",
                    title: "Evening Habit Success",
                    value: "67% completion rate",
                    color: .purple
                )

                PatternRow(
                    icon: "figure.walk",
                    title: "Activity Correlation",
                    value: "Exercise boosts other habits by 24%",
                    color: .orange
                )
            }
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

public struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    public init(icon: String, title: String, value: String, color: Color) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }

    public var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
