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
        case compact // Small flame icon with count
        case detailed // Full stats with progress
        case heatMap // Calendar-style heat map
        case milestone // Focus on milestone progress
    }

    var body: some View {
        switch self.displayMode {
        case .compact:
            self.compactView
        case .detailed:
            self.detailedView
        case .heatMap:
            self.heatMapView
        case .milestone:
            self.milestoneView
        }
    }

    // MARK: - Compact View

    private var compactView: some View {
        HStack(spacing: 4) {
            self.flameIcon

            Text("\(self.analytics.currentStreak)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(self.streakColor.opacity(0.1))
        .cornerRadius(12)
        .scaleEffect(self.flameAnimation ? 1.1 : 1.0)
        .animation(
            .easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: self.flameAnimation
        )
        .onAppear {
            if self.analytics.currentStreak > 0 {
                self.flameAnimation = true
            }
        }
    }

    // MARK: - Detailed View

    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with current streak
            HStack {
                self.flameIcon

                VStack(alignment: .leading) {
                    Text(self.analytics.streakDescription)
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
                if self.analytics.longestStreak > self.analytics.currentStreak {
                    VStack {
                        Text("Best")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(self.analytics.longestStreak)")
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

                        Text("\(nextMilestone.streakCount - self.analytics.currentStreak) days to go")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: self.analytics.progressToNextMilestone)
                        .progressViewStyle(LinearProgressViewStyle(tint: self.streakColor))
                        .scaleEffect(y: 0.8)
                }
            }

            // Motivational message
            Text(self.analytics.motivationalMessage)
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
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2
            ) {
                ForEach(0 ..< 30, id: \.self) { day in
                    HeatMapDay(
                        date: Date().addingTimeInterval(-Double(day) * 86400),
                        intensity: Double.random(in: 0 ... 1),
                        isToday: day == 0
                    )
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
                        .scaleEffect(self.flameAnimation ? 1.2 : 1.0)

                    Text(milestone.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("\(self.analytics.currentStreak) days")
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

                    ProgressView(value: self.analytics.progressToNextMilestone)
                        .progressViewStyle(LinearProgressViewStyle(tint: self.streakColor))

                    Text(
                        "\(nextMilestone.streakCount - self.analytics.currentStreak) days to \(nextMilestone.title)"
                    )
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
                        .stroke(self.streakColor.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(
            .easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: self.flameAnimation
        )
        .onAppear {
            if self.analytics.currentStreak > 0 {
                self.flameAnimation = true
            }
        }
    }

    // MARK: - Supporting Views

    private var flameIcon: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: self.flameSize))
            .foregroundColor(self.streakColor)
            .shadow(color: self.streakColor.opacity(0.3), radius: 2)
    }

    // MARK: - Computed Properties

    private var streakColor: Color {
        switch self.analytics.currentStreak {
        case 0:
            .gray
        case 1 ... 6:
            .orange
        case 7 ... 29:
            .red
        case 30 ... 99:
            .purple
        default:
            .blue
        }
    }

    private var flameSize: CGFloat {
        switch self.displayMode {
        case .compact:
            12
        case .detailed:
            16
        case .heatMap:
            14
        case .milestone:
            20
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
                    self.dismissCelebration()
                }

            VStack(spacing: 20) {
                // Milestone emoji with animation
                Text(self.milestone.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(self.scaleAnimation ? 1.2 : 1.0)
                    .rotationEffect(.degrees(self.animationPhase * 360))

                // Achievement text
                VStack(spacing: 8) {
                    Text("Milestone Achieved!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(self.milestone.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(self.milestone.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Dismiss button
                Button("Continue") {
                    self.dismissCelebration()
                }
                .accessibilityLabel("Button")
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
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .padding()
        }
        .onAppear {
            self.startCelebrationAnimation()
        }
    }

    private func startCelebrationAnimation() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            self.animationPhase = 1.0
        }

        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            self.scaleAnimation = true
        }
    }

    private func dismissCelebration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isPresented = false
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
            .fill(Color.green.opacity(max(0.1, self.intensity)))
            .frame(width: 12, height: 12)
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(self.isToday ? Color.blue : Color.clear, lineWidth: 1)
            )
            .scaleEffect(self.showTooltip ? 1.2 : 1.0)
            .onTapGesture {
                withAnimation(.spring(duration: 0.3)) {
                    self.showTooltip.toggle()
                }
            }
            .overlay(
                self.tooltipView
                    .opacity(self.showTooltip ? 1 : 0)
                    .offset(y: -30)
            )
    }

    private var tooltipView: some View {
        VStack(spacing: 2) {
            Text(DateFormatter.dayMonth.string(from: self.date))
                .font(.caption2)
                .fontWeight(.medium)
            Text("\(Int(self.intensity * 100))%")
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
        StreakVisualizationView(
            habit: sampleHabit, analytics: sampleAnalytics, displayMode: .compact
        )
        StreakVisualizationView(
            habit: sampleHabit, analytics: sampleAnalytics, displayMode: .detailed
        )
        StreakVisualizationView(
            habit: sampleHabit, analytics: sampleAnalytics, displayMode: .milestone
        )
    }
    .padding()
}
