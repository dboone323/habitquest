import SwiftData
import SwiftUI

/// Reusable streak visualization component with multiple display modes
struct StreakVisualizationView: View {
    let habit: Habit
    let analytics: StreakAnalytics
    let displayMode: DisplayMode

    @State private var animationOffset: CGFloat = 0
    @State private var flameAnimation: Bool = false

    enum DisplayMode {
        case compact       // Small flame icon with count
        case detailed      // Full stats with progress
        case heatMap       // Calendar-style heat map
        case milestone     // Focus on milestone progress
    }

    var body: some View {
        switch displayMode {
        case .compact:
            compactView
        case .detailed:
            detailedView
        case .heatMap:
            heatMapView
        case .milestone:
            milestoneView
        }
    }

    // MARK: - Compact View

    private var compactView: some View {
        HStack(spacing: 4) {
            flameIcon

            Text("\(analytics.currentStreak)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(streakColor.opacity(0.1))
        .cornerRadius(12)
        .scaleEffect(flameAnimation ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: flameAnimation)
        .onAppear {
            if analytics.currentStreak > 0 {
                flameAnimation = true
            }
        }
    }

    // MARK: - Detailed View

    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with current streak
            HStack {
                flameIcon

                VStack(alignment: .leading) {
                    Text(analytics.streakDescription)
                        .font(.headline)
                        .fontWeight(.bold)

                    if let milestone = analytics.currentMilestone {
                        Text(milestone.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Longest streak badge
                if analytics.longestStreak > analytics.currentStreak {
                    VStack {
                        Text("Best")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(analytics.longestStreak)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            // Progress to next milestone
            if let nextMilestone = analytics.nextMilestone {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Next: \(nextMilestone.title)")
                            .font(.caption)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(nextMilestone.streakCount - analytics.currentStreak) days to go")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: analytics.progressToNextMilestone)
                        .progressViewStyle(LinearProgressViewStyle(tint: streakColor))
                        .scaleEffect(y: 0.8)
                }
            }

            // Motivational message
            Text(analytics.motivationalMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Heat Map View

    private var heatMapView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("30 Day Streak Pattern")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // This would be populated with actual streak data
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(0..<30, id: \.self) { day in
                    HeatMapDay(date: Date().addingTimeInterval(-Double(day) * 86400), intensity: Double.random(in: 0...1), isToday: day == 0)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Milestone View

    private var milestoneView: some View {
        VStack(spacing: 12) {
            // Current milestone
            if let milestone = analytics.currentMilestone {
                VStack(spacing: 4) {
                    Text(milestone.emoji)
                        .font(.largeTitle)
                        .scaleEffect(flameAnimation ? 1.2 : 1.0)

                    Text(milestone.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("\(analytics.currentStreak) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Progress to next
            if let nextMilestone = analytics.nextMilestone {
                VStack(spacing: 8) {
                    HStack {
                        Text("Next Milestone")
                            .font(.caption)
                            .fontWeight(.medium)

                        Spacer()

                        Text(nextMilestone.emoji)
                            .font(.title3)
                    }

                    ProgressView(value: analytics.progressToNextMilestone)
                        .progressViewStyle(LinearProgressViewStyle(tint: streakColor))

                    Text("\(nextMilestone.streakCount - analytics.currentStreak) days to \(nextMilestone.title)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(streakColor.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: flameAnimation)
        .onAppear {
            if analytics.currentStreak > 0 {
                flameAnimation = true
            }
        }
    }

    // MARK: - Supporting Views

    private var flameIcon: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: flameSize))
            .foregroundColor(streakColor)
            .shadow(color: streakColor.opacity(0.3), radius: 2)
    }

    // MARK: - Computed Properties

    private var streakColor: Color {
        switch analytics.currentStreak {
        case 0:
            return .gray
        case 1...6:
            return .orange
        case 7...29:
            return .red
        case 30...99:
            return .purple
        default:
            return .blue
        }
    }

    private var flameSize: CGFloat {
        switch displayMode {
        case .compact:
            return 12
        case .detailed:
            return 16
        case .heatMap:
            return 14
        case .milestone:
            return 20
        }
    }
}

// MARK: - Celebration Animation View

/// Animated celebration view for milestone achievements
struct StreakCelebrationView: View {
    let milestone: StreakMilestone
    @Binding var isPresented: Bool

    @State private var animationPhase: CGFloat = 0
    @State private var particleAnimation: Bool = false
    @State private var scaleAnimation: Bool = false

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCelebration()
                }

            VStack(spacing: 20) {
                // Milestone emoji with animation
                Text(milestone.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(scaleAnimation ? 1.2 : 1.0)
                    .rotationEffect(.degrees(animationPhase * 360))

                // Achievement text
                VStack(spacing: 8) {
                    Text("Milestone Achieved!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(milestone.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(milestone.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Dismiss button
                Button("Continue") {
                    dismissCelebration()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(25)
                .fontWeight(.semibold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .padding()
        }
        .onAppear {
            startCelebrationAnimation()
        }
    }

    private func startCelebrationAnimation() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            animationPhase = 1.0
        }

        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            scaleAnimation = true
        }
    }

    private func dismissCelebration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

// MARK: - Heat Map Day Component

struct HeatMapDay: View {
    let date: Date
    let intensity: Double
    let isToday: Bool

    @State private var showTooltip = false

    var body: some View {
        Rectangle()
            .fill(Color.green.opacity(max(0.1, intensity)))
            .frame(width: 12, height: 12)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
            )
            .scaleEffect(showTooltip ? 1.2 : 1.0)
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    showTooltip.toggle()
                }
            }
            .overlay(
                tooltipView
                    .opacity(showTooltip ? 1 : 0)
                    .offset(y: -30)
            )
    }

    private var tooltipView: some View {
        VStack(spacing: 2) {
            Text(DateFormatter.dayMonth.string(from: date))
                .font(.caption2)
                .fontWeight(.medium)
            Text("\(Int(intensity * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

extension DateFormatter {
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()
}

// MARK: - Preview

#Preview {
    let sampleAnalytics = StreakAnalytics(
        currentStreak: 15,
        longestStreak: 23,
        currentMilestone: StreakMilestone.predefinedMilestones[1],
        nextMilestone: StreakMilestone.predefinedMilestones[3],
        progressToNextMilestone: 0.5,
        streakPercentile: 0.75
    )

    let sampleHabit = Habit(
        name: "Morning Exercise",
        habitDescription: "30 minutes of exercise",
        frequency: .daily,
        xpValue: 20,
        category: .fitness,
        difficulty: .medium
    )

    VStack(spacing: 20) {
        StreakVisualizationView(habit: sampleHabit, analytics: sampleAnalytics, displayMode: .compact)
        StreakVisualizationView(habit: sampleHabit, analytics: sampleAnalytics, displayMode: .detailed)
        StreakVisualizationView(habit: sampleHabit, analytics: sampleAnalytics, displayMode: .milestone)
    }
    .padding()
}
