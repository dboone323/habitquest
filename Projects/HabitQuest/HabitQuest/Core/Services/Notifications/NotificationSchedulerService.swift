import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Service responsible for scheduling notifications at optimal times
@Observable @MainActor
final class NotificationSchedulerService {
    private let modelContext: ModelContext
    private let analyticsEngine: AdvancedAnalyticsEngine

    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    init(modelContext: ModelContext, analyticsEngine: AdvancedAnalyticsEngine) {
        self.modelContext = modelContext
        self.analyticsEngine = analyticsEngine
    }

    /// Schedule AI-optimized notifications for all habits
    func scheduleSmartNotifications() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            await self.scheduleOptimalNotification(for: habit)
        }
    }

    /// Schedule notification at optimal time based on user behavior
    func scheduleOptimalNotification(for habit: Habit) async {
        let scheduling = await analyticsEngine.generateOptimalScheduling(for: habit)
        let prediction = await analyticsEngine.predictStreakSuccess(for: habit)

        let content = self.generateSmartContent(
            for: habit,
            scheduling: scheduling,
            prediction: prediction
        )

        let trigger = self.createOptimalTrigger(
            for: habit,
            recommendedHour: scheduling.optimalTime,
            successRate: scheduling.successRateAtTime
        )

        let request = UNNotificationRequest(
            identifier: "habit_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification for \(habit.name): \(error)")
        }
    }

    /// Cancel all notifications for a specific habit
    func cancelNotifications(for habitId: UUID) async {
        let identifiers = ["habit_\(habitId.uuidString)"]
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        self.notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Private Methods

    private func generateSmartContent(
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

    private func createOptimalTrigger(
        for habit: Habit,
        recommendedHour: Int,
        successRate: Double
    ) -> UNNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.hour = recommendedHour

        // Add variance based on success rate (lower success = earlier reminder)
        if successRate < 0.5 {
            dateComponents.minute = 0 // Early reminder
        } else {
            dateComponents.minute = 15 // Standard time
        }

        // Adjust for habit frequency
        switch habit.frequency {
        case .daily:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .weekly:
            dateComponents.weekday = self.findOptimalWeekday(for: habit)
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .custom:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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

    private func fetchActiveHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        let allHabits = (try? self.modelContext.fetch(descriptor)) ?? []
        return allHabits.filter(\.isActive)
    }

    private func findOptimalWeekday(for habit: Habit) -> Int {
        // Analyze completion patterns to find best weekday
        let weekdayCompletions = Dictionary(grouping: habit.logs.filter(\.isCompleted)) { log in
            Calendar.current.component(.weekday, from: log.completionDate)
        }

        let bestWeekday = weekdayCompletions.max { $0.value.count < $1.value.count }?.key ?? 2
        return bestWeekday
    }
}
