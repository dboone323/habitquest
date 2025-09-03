import SwiftUI

// MARK: - Shared Analytics Components

/// Enhanced analytics card with motion design and accessibility
struct AnalyticsCard: View {
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
            case .upDirection: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }

        var color: Color {
            switch self {
            case .upDirection: return .green
            case .down: return .red
            case .stable: return .orange
            }
        }
    }

    init(title: String, value: String, subtitle: String, color: Color, icon: String, trend: TrendDirection? = nil) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
        self.trend = trend
    }

    var body: some View {
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

            if let trend = trend, showTrend {
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption)
                        .foregroundColor(trend.color)

                    Circle()
                        .fill(trend.color)
                        .frame(width: 6, height: 6)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
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

/// Interactive performance row with haptic feedback
struct TopPerformerRow: View {
    let performer: TopPerformer
    @State private var isPressed = false
    @State private var showDetails = false

    var body: some View {
        HStack(spacing: 16) {
            performerInfo
            Spacer()
            streakVisualization
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            hapticFeedback(.light)
            showDetails.toggle()
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
        .sheet(isPresented: $showDetails) {
            HabitDetailSheet(habit: performer.habit)
        }
    }

    private var performerInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(performer.habit.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                streakBadge
                consistencyIndicator
            }
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundColor(.orange)

            Text("\(performer.currentStreak)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.orange.opacity(0.1))
        .clipShape(Capsule())
    }

    private var consistencyIndicator: some View {
        Text("\(Int(performer.consistency * 100))% consistent")
            .font(.caption2)
            .foregroundColor(.secondary)
    }

    private var streakVisualization: some View {
        StreakVisualizationView(
            habit: performer.habit,
            analytics: StreakAnalytics(
                currentStreak: performer.currentStreak,
                longestStreak: performer.longestStreak,
                currentMilestone: StreakMilestone.milestone(for: performer.currentStreak),
                nextMilestone: StreakMilestone.nextMilestone(for: performer.currentStreak),
                progressToNextMilestone: 0.5,
                streakPercentile: performer.consistency
            ),
            displayMode: .compact
        )
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.separator.opacity(0.5), lineWidth: 0.5)
            )
    }

    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

/// Animated distribution chart with smooth transitions
struct StreakDistributionChartView: View {
    let data: [StreakDistributionData]
    @State private var animateChart = false

    var body: some View {
        VStack(spacing: 16) {
            chartTitle
            chartBars
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateChart = true
            }
        }
    }

    private var chartTitle: some View {
        HStack {
            Text("Distribution")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Text("Habits by streak length")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var chartBars: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Array(data.enumerated()), id: \.element.range) { index, item in
                VStack(spacing: 8) {
                    barColumn(for: item, index: index)
                    barLabel(for: item)
                }
            }
        }
        .frame(height: 180)
    }

    private func barColumn(for item: StreakDistributionData, index: Int) -> some View {
        let maxCount = data.map(\.count).max() ?? 1
        let normalizedHeight = max(0.1, Double(item.count) / Double(maxCount))
        let barHeight = animateChart ? normalizedHeight * 120 : 0

        return VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 6)
                .fill(barGradient(for: index))
                .frame(height: barHeight)
                .overlay(
                    Text("\(item.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(item.count > 0 ? 1 : 0)
                )
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateChart)
        }
    }

    private func barLabel(for item: StreakDistributionData) -> some View {
        Text(item.range)
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    private func barGradient(for index: Int) -> LinearGradient {
        let colors = [Color.blue, Color.green, Color.orange, Color.purple, Color.red]
        let color = colors[index % colors.count]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// Enhanced insights with interactive elements
struct ConsistencyInsightView: View {
    let insights: [ConsistencyInsight]
    @State private var expandedInsight: String?

    var body: some View {
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

struct InsightCard: View {
    let insight: ConsistencyInsight
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardHeader

            if isExpanded {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
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

/// Animated weekly pattern visualization
struct WeeklyPatternChartView: View {
    let patterns: [WeeklyPattern]
    @State private var animatePattern = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(patterns.enumerated()), id: \.element.day) { index, pattern in
                VStack(spacing: 6) {
                    patternBar(for: pattern, index: index)
                    dayLabel(pattern.day)
                }
            }
        }
        .frame(height: 100)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.2)) {
                animatePattern = true
            }
        }
    }

    private func patternBar(for pattern: WeeklyPattern, index: Int) -> some View {
        let barHeight = animatePattern ? pattern.completionRate * 70 : 0

        return VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(barColor(for: pattern.completionRate))
                .frame(height: barHeight)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animatePattern)
        }
    }

    private func dayLabel(_ day: String) -> some View {
        Text(day)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
    }

    private func barColor(for rate: Double) -> LinearGradient {
        let color = rate > 0.7 ? Color.green : rate > 0.4 ? Color.orange : Color.red
        return LinearGradient(
            colors: [color, color.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Supporting Views

struct HabitDetailSheet: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Habit details for \(habit.name)")
                    .font(.title2)
                Spacer()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AnalyticsExportView: View {
    let analyticsData: StreakAnalyticsData?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Export Streak Analytics")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let data = analyticsData {
                        exportDetailView(title: "Total Active Streaks", value: "\(data.totalActiveStreaks)")
                        exportDetailView(title: "Longest Overall Streak", value: "\(data.longestOverallStreak)")
                        exportDetailView(title: "Average Consistency", value: "\(Int(data.averageConsistency * 100))%")
                        exportDetailView(title: "Milestones Achieved", value: "\(data.milestonesAchieved)")

                        Divider()

                        Text("Streak Distribution")
                            .font(.headline)

                        ForEach(data.streakDistribution, id: \.range) { item in
                            exportDetailView(title: item.range, value: "\(item.count)")
                        }

                        Divider()

                        Text("Top Performing Habits")
                            .font(.headline)

                        ForEach(data.topPerformingHabits.prefix(5), id: \.habit.id) { performer in
                            exportDetailView(title: performer.habit.name, value: "\(performer.currentStreak) days")
                        }
                    } else {
                        Text("No analytics data available for export.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Export Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func exportDetailView(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
