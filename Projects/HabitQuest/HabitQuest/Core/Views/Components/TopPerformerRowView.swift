import SwiftUI

// MARK: - Top Performer Row View

/// Interactive performance row with haptic feedback
public struct TopPerformerRow: View {
    let performer: TopPerformer
    @State private var isPressed = false
    @State private var showDetails = false

    public var body: some View {
        HStack(spacing: 16) {
            self.performerInfo
            Spacer()
            self.streakVisualization
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(self.rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(self.isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: self.isPressed)
        .onTapGesture {
            self.hapticFeedback(.light)
            self.showDetails.toggle()
        }
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                self.isPressed = pressing
            },
            perform: {}
        )
        .sheet(isPresented: self.$showDetails) {
            HabitDetailSheet(habit: self.performer.habit)
        }
    }

    private var performerInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(self.performer.habit.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                self.streakBadge
                self.consistencyIndicator
            }
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundColor(.orange)

            Text("\(self.performer.currentStreak)")
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
        Text("\(Int(self.performer.consistency * 100))% consistent")
            .font(.caption2)
            .foregroundColor(.secondary)
    }

    private var streakVisualization: some View {
        StreakVisualizationView(
            habit: self.performer.habit,
            analytics: StreakAnalytics(
                currentStreak: self.performer.currentStreak,
                longestStreak: self.performer.longestStreak,
                currentMilestone: StreakMilestone.milestone(for: self.performer.currentStreak),
                nextMilestone: StreakMilestone.nextMilestone(for: self.performer.currentStreak),
                progressToNextMilestone: 0.5,
                streakPercentile: self.performer.consistency
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

    private enum HapticStyle {
        case light, medium, heavy, soft, rigid
    }

    private func hapticFeedback(_ style: HapticStyle) {
        #if canImport(UIKit)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        case .soft: uiStyle = .soft
        case .rigid: uiStyle = .rigid
        }
        let generator = UIImpactFeedbackGenerator(style: uiStyle)
        generator.impactOccurred()
        #endif
    }
}
