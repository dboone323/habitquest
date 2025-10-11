import Foundation
@preconcurrency import UserNotifications

/// Service responsible for generating intelligent notification content
@Observable @MainActor
final class ContentGenerationService {
    /// Generate smart notification content based on habit data and predictions
    func generateSmartContent(
        for habit: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        // Personalized title based on streak status
        content.title = self.generatePersonalizedTitle(for: habit, prediction: prediction)

        // Context-aware body message
        content.body = self.generateContextualMessage(
            for: habit,
            scheduling: scheduling,
            prediction: prediction
        )

        // Dynamic notification priority
        content.interruptionLevel = self.determineInterruptionLevel(
            habit: habit,
            successRate: scheduling.successRateAtTime
        )

        // Custom sound based on habit category
        content.sound = self.selectOptimalSound(for: habit.category)

        // Rich actions for quick interaction
        content.categoryIdentifier = "HABIT_REMINDER"

        // Add custom data for analytics
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "optimalTime": scheduling.optimalTime,
            "successProbability": prediction.probability,
            "schedulingVersion": "smart_v2"
        ]

        return content
    }

    /// Generate milestone notification content
    func generateMilestoneContent(for habit: Habit, milestone: StreakMilestone) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Milestone Approaching!"
        content.body = "You're \(milestone.streakCount - habit.streak) days away from \(milestone.title)!"
        content.sound = self.selectOptimalSound(for: habit.category)
        content.categoryIdentifier = "MILESTONE_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "milestoneStreak": milestone.streakCount,
            "notificationType": "milestone"
        ]

        return content
    }

    /// Generate recovery notification content
    func generateRecoveryContent(for habit: Habit) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "🌱 Fresh Start"
        content.body = "Yesterday is gone, today is a new opportunity to build \(habit.name) back up!"
        content.sound = self.selectOptimalSound(for: habit.category)
        content.interruptionLevel = .passive
        content.categoryIdentifier = "RECOVERY_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "notificationType": "recovery"
        ]

        return content
    }

    // MARK: - Private Methods

    private func generatePersonalizedTitle(for habit: Habit, prediction: StreakPrediction) -> String {
        let streak = habit.streak

        switch (streak, prediction.probability) {
        case let (streakCount, probabilityValue) where streakCount >= 21 && probabilityValue > 80:
            return "🔥 Keep the \(streakCount)-day streak alive!"
        case let (streakCount, probabilityValue) where streakCount >= 7 && probabilityValue > 70:
            return "💪 \(streakCount) days strong - don't break it now!"
        case let (streakCount, _) where streakCount >= 3:
            return "⭐ \(streakCount)-day streak in progress"
        case let (_, probabilityValue) where probabilityValue < 40:
            return "🎯 Small step, big impact"
        default:
            return "✨ Time for \(habit.name)"
        }
    }

    private func generateContextualMessage(
        for _: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) -> String {
        let timeContext = self.generateTimeContext(hour: scheduling.optimalTime)
        let motivationalMessage = self.selectMotivationalMessage(prediction: prediction)

        return "\(timeContext) \(motivationalMessage) \(prediction.recommendedAction)"
    }

    private func generateTimeContext(hour: Int) -> String {
        switch hour {
        case 6 ... 9:
            "Perfect morning energy!"
        case 10 ... 12:
            "Mid-morning focus time."
        case 13 ... 17:
            "Afternoon momentum boost."
        case 18 ... 21:
            "Evening wind-down ritual."
        default:
            "Your optimal time."
        }
    }

    private func selectMotivationalMessage(prediction: StreakPrediction) -> String {
        switch prediction.probability {
        case 80 ... 100:
            "You're crushing it!"
        case 60 ... 79:
            "Great momentum building."
        case 40 ... 59:
            "Consistency is key."
        case 20 ... 39:
            "Every small step counts."
        default:
            "Fresh start, new opportunity."
        }
    }

    private func determineInterruptionLevel(habit: Habit, successRate: Double) -> UNNotificationInterruptionLevel {
        // High-priority for struggling streaks, low for established ones
        if habit.streak > 7, successRate > 0.7 {
            .passive
        } else if successRate < 0.3 {
            .timeSensitive
        } else {
            .active
        }
    }

    private func selectOptimalSound(for category: HabitCategory) -> UNNotificationSound {
        switch category {
        case .health, .fitness:
            UNNotificationSound(named: UNNotificationSoundName("energetic_chime.wav"))
        case .learning, .productivity:
            UNNotificationSound(named: UNNotificationSoundName("focused_bell.wav"))
        case .mindfulness, .social:
            UNNotificationSound(named: UNNotificationSoundName("gentle_tone.wav"))
        default:
            .default
        }
    }
}
