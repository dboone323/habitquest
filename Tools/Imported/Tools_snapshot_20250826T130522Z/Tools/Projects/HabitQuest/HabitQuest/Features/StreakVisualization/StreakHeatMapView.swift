import SwiftData
import SwiftUI

/// GitHub-style contribution heat map for habit streaks
struct StreakHeatMapView: View {
    let habit: Habit
    let analytics: StreakAnalytics
    let timeRange: TimeRange

    @State private var selectedDate: Date?
    @State private var showingDetails = false

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case year = "365D"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            }
        }

        var columns: Int {
            switch self {
            case .week: return 7
            case .month: return 10
            case .quarter: return 13
            case .year: return 53
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            heatMapGrid
            legendSection
            if showingDetails {
                detailsSection
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingDetails)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Streak Pattern")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("\(analytics.currentStreak) day current streak")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showingDetails.toggle() }, label: {
                Image(systemName: showingDetails ? "chevron.up" : "info.circle")
                    .foregroundColor(.blue)
            })
        }
    }

    private var heatMapGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: timeRange.columns), spacing: 2) {
            ForEach(heatMapData, id: \.date) { dayData in
                Rectangle()
                    .fill(intensityColor(for: dayData.intensity))
                    .frame(width: cellSize, height: cellSize)
                    .cornerRadius(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(selectedDate == dayData.date ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedDate = dayData.date
                        hapticFeedback()
                    }
                    .animation(.spring(response: 0.3), value: selectedDate)
            }
        }
        .padding(.horizontal, 4)
    }

    private var legendSection: some View {
        HStack {
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 2) {
                ForEach(0..<5) { intensity in
                    Rectangle()
                        .fill(intensityColor(for: Double(intensity)))
                        .frame(width: 10, height: 10)
                        .cornerRadius(2)
                }
            }

            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)

            Spacer()

            if let selectedDate = selectedDate {
                Text(selectedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pattern Analysis")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                MetricCard(title: "Consistency", value: "\(Int(analytics.streakPercentile * 100))%", color: .green)
                MetricCard(title: "Best Streak", value: "\(analytics.longestStreak) days", color: .orange)
                MetricCard(title: "Total Days", value: "\(completedDays)", color: .blue)
                MetricCard(title: "Success Rate", value: "\(successRate)%", color: .purple)
            }

            if let prediction = streakPrediction {
                PredictionCard(prediction: prediction)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Computed Properties

    private var cellSize: CGFloat {
        switch timeRange {
        case .week: return 32
        case .month: return 24
        case .quarter: return 18
        case .year: return 12
        }
    }

    private var heatMapData: [DayIntensity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeRange.days, to: endDate) ?? endDate

        var data: [DayIntensity] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let intensity = calculateIntensity(for: currentDate)
            data.append(DayIntensity(date: currentDate, intensity: intensity))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return data
    }

    private var completedDays: Int {
        heatMapData.filter { $0.intensity > 0 }.count
    }

    private var successRate: Int {
        let total = heatMapData.count
        return total > 0 ? Int((Double(completedDays) / Double(total)) * 100) : 0
    }

    private var streakPrediction: StreakPrediction? {
        // Advanced ML-based prediction (simplified for now)
        let recentPerformance = heatMapData.suffix(7).map(\.intensity).reduce(0, +) / 7
        let trend = recentPerformance > 0.5 ? "improving" : "declining"
        let probability = min(recentPerformance * 100, 95)

        return StreakPrediction(
            nextMilestone: analytics.nextMilestone?.title ?? "7 days",
            probability: probability,
            trend: trend,
            recommendedAction: generateRecommendation(trend: trend, performance: recentPerformance)
        )
    }

    // MARK: - Helper Methods

    private func calculateIntensity(for date: Date) -> Double {
        // Check if habit was completed on this date
        let completed = habit.logs.contains { log in
            Calendar.current.isDate(log.completionDate, inSameDayAs: date) && log.isCompleted
        }

        if completed {
            // Scale intensity based on streak context
            let dayOfStreak = calculateDayInStreak(for: date)
            return min(1.0, 0.3 + (Double(dayOfStreak) * 0.1))
        }

        return 0.0
    }

    private func calculateDayInStreak(for date: Date) -> Int {
        // Calculate which day of the streak this represents
        var streakDay = 1
        var checkDate = date
        let calendar = Calendar.current

        while checkDate > calendar.date(byAdding: .day, value: -30, to: date) ?? date {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            let wasCompleted = habit.logs.contains { log in
                calendar.isDate(log.completionDate, inSameDayAs: checkDate) && log.isCompleted
            }
            if wasCompleted {
                streakDay += 1
            } else {
                break
            }
        }

        return streakDay
    }

    private func intensityColor(for intensity: Double) -> Color {
        switch intensity {
        case 0:
            return Color(.systemGray5)
        case 0.01..<0.3:
            return Color.green.opacity(0.3)
        case 0.3..<0.6:
            return Color.green.opacity(0.6)
        case 0.6..<0.8:
            return Color.green.opacity(0.8)
        default:
            return Color.green
        }
    }

    private func generateRecommendation(trend: String, performance: Double) -> String {
        switch (trend, performance) {
        case ("improving", let performance) where performance > 0.7:
            return "Great momentum! Keep it up."
        case ("improving", _):
            return "Building consistency. Stay focused."
        case ("declining", let performance) where performance < 0.3:
            return "Consider adjusting your approach."
        default:
            return "Small steps lead to big changes."
        }
    }

    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Supporting Types

struct DayIntensity {
    let date: Date
    let intensity: Double
}

struct StreakPrediction {
    let nextMilestone: String
    let probability: Double
    let trend: String
    let recommendedAction: String
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct PredictionCard: View {
    let prediction: StreakPrediction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("AI Prediction")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text("Next milestone: \(prediction.nextMilestone)")
                .font(.caption)

            HStack {
                Text("Success probability:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(prediction.probability))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }

            Text(prediction.recommendedAction)
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    // Create a preview with proper SwiftData context
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    do {
        let container = try ModelContainer(for: Habit.self, configurations: config)
        let context = container.mainContext

        // Create a sample habit properly
        let sampleHabit = Habit(
            name: "Exercise",
            habitDescription: "Daily workout",
            frequency: HabitFrequency.daily,
            xpValue: 10,
            category: HabitCategory.fitness,
            difficulty: HabitDifficulty.medium
        )

        // Insert into context
        context.insert(sampleHabit)

        return StreakHeatMapView(
            habit: sampleHabit,
            analytics: StreakAnalytics(
                currentStreak: 12,
                longestStreak: 25,
                currentMilestone: StreakMilestone.milestone(for: 12),
                nextMilestone: StreakMilestone.nextMilestone(for: 12),
                progressToNextMilestone: 0.6,
                streakPercentile: 0.85
            ),
            timeRange: .month
        )
        .padding()
        .modelContainer(container)
    } catch {
        // If ModelContainer can't be created in preview, return a simple placeholder view
        return Text("Preview unavailable").padding()
    }
}
