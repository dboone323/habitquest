import SwiftUI

// MARK: - Top Performer Row View

/// Interactive performance row with haptic feedback
public struct TopPerformerRow: View {
    let performer: TopPerformer
    @State private var isPressed = false
    @State private var showDetails = false

    public var body: some View {
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
            hapticFeedback()
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

    private func hapticFeedback() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
