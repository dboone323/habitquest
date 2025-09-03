import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Intelligent notification service with ML-driven optimal timing
@Observable @MainActor
final class SmartNotificationService {
    private let modelContext: ModelContext
    private let analyticsEngine: AdvancedAnalyticsEngine

    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    init(modelContext: ModelContext, analyticsEngine: AdvancedAnalyticsEngine) {
        self.modelContext = modelContext
        self.analyticsEngine = analyticsEngine
    }

    // MARK: - Smart Scheduling

    /// Schedule AI-optimized notifications for all habits
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleSmartNotifications() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            await scheduleOptimalNotification(for: habit)
        }
    }

    /// Schedule notification at optimal time based on user behavior
    private func scheduleOptimalNotification(for habit: Habit) async {
        let scheduling = await analyticsEngine.generateOptimalScheduling(for: habit)
        let prediction = await analyticsEngine.predictStreakSuccess(for: habit)

        let content = generateSmartContent(
            for: habit,
            scheduling: scheduling,
            prediction: prediction
        )

        let trigger = createOptimalTrigger(
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
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification for \(habit.name): \(error)")
        }
    }

    // MARK: - Adaptive Content Generation

    private func generateSmartContent(
        for habit: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        // Personalized title based on streak status
        content.title = generatePersonalizedTitle(for: habit, prediction: prediction)

        // Context-aware body message
        content.body = generateContextualMessage(
            for: habit,
            scheduling: scheduling,
            prediction: prediction
        )

        // Dynamic notification priority
        content.interruptionLevel = determineInterruptionLevel(
            habit: habit,
            successRate: scheduling.successRateAtTime
        )

        // Custom sound based on habit category
        content.sound = selectOptimalSound(for: habit.category)

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
        case (let streakCount, let probabilityValue) where streakCount >= 21 && probabilityValue > 80:
            return "🔥 Keep the \(streakCount)-day streak alive!"
        case (let streakCount, let probabilityValue) where streakCount >= 7 && probabilityValue > 70:
            return "💪 \(streakCount) days strong - don't break it now!"
        case (let streakCount, _) where streakCount >= 3:
            return "⭐ \(streakCount)-day streak in progress"
        case (_, let probabilityValue) where probabilityValue < 40:
            return "🎯 Small step, big impact"
        default:
            return "✨ Time for \(habit.name)"
        }
    }

    private func generateContextualMessage(
        for habit: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) -> String {
        let timeContext = generateTimeContext(hour: scheduling.optimalTime)
        let motivationalMessage = selectMotivationalMessage(prediction: prediction)

        return "\(timeContext) \(motivationalMessage) \(prediction.recommendedAction)"
    }

    private func generateTimeContext(hour: Int) -> String {
        switch hour {
        case 6...9:
            return "Perfect morning energy!"
        case 10...12:
            return "Mid-morning focus time."
        case 13...17:
            return "Afternoon momentum boost."
        case 18...21:
            return "Evening wind-down ritual."
        default:
            return "Your optimal time."
        }
    }

    private func selectMotivationalMessage(prediction: StreakPrediction) -> String {
        switch prediction.probability {
        case 80...100:
            return "You're crushing it!"
        case 60...79:
            return "Great momentum building."
        case 40...59:
            return "Consistency is key."
        case 20...39:
            return "Every small step counts."
        default:
            return "Fresh start, new opportunity."
        }
    }

    // MARK: - Dynamic Timing

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
            dateComponents.weekday = findOptimalWeekday(for: habit)
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .custom:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
    }

    private func determineInterruptionLevel(habit: Habit, successRate: Double) -> UNNotificationInterruptionLevel {
        // High-priority for struggling streaks, low for established ones
        if habit.streak > 7 && successRate > 0.7 {
            return .passive
        } else if successRate < 0.3 {
            return .timeSensitive
        } else {
            return .active
        }
    }

    private func selectOptimalSound(for category: HabitCategory) -> UNNotificationSound {
        switch category {
        case .health, .fitness:
            return UNNotificationSound(named: UNNotificationSoundName("energetic_chime.wav"))
        case .learning, .productivity:
            return UNNotificationSound(named: UNNotificationSoundName("focused_bell.wav"))
        case .mindfulness, .social:
            return UNNotificationSound(named: UNNotificationSoundName("gentle_tone.wav"))
        default:
            return .default
        }
    }

    // MARK: - Behavioral Adaptation

    /// Learn from user interaction patterns and adjust timing
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func adaptToUserBehavior(habitId: UUID, interactionType: NotificationInteraction) async {
        let habit = await fetchHabit(id: habitId)
        guard let habit = habit else { return }

        // Log interaction for machine learning
        await logNotificationInteraction(
            habit: habit,
            interaction: interactionType,
            timestamp: Date()
        )

        // Adjust future notifications based on response
        if case .dismissed = interactionType {
            await adjustNotificationTiming(for: habit, direction: .later)
        } else if case .completed = interactionType {
            await reinforceCurrentTiming(for: habit)
        }
    }

    /// Dynamically adjust notification frequency based on success patterns
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func optimizeNotificationFrequency() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            let recentSuccess = await calculateRecentSuccessRate(habit: habit)

            if recentSuccess > 0.8 {
                // Reduce frequency for well-established habits
                await adjustNotificationFrequency(for: habit, factor: 0.7)
            } else if recentSuccess < 0.3 {
                // Increase support for struggling habits
                await adjustNotificationFrequency(for: habit, factor: 1.3)
            }
        }
    }

    // MARK: - Context-Aware Features

    /// Schedule motivational notifications for streak milestones
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleStreakMilestoneNotifications(for habit: Habit) async {
        // Get the next milestone for this habit's current streak
        guard let nextMilestone = StreakMilestone.nextMilestone(for: habit.streak) else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎯 Milestone Approaching!"
        content.body = "You're \(nextMilestone.streakCount - habit.streak) days away from \(nextMilestone.title)!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(
            identifier: "milestone_\(habit.id.uuidString)_\(nextMilestone.streakCount)",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    /// Send recovery notifications for broken streaks
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func scheduleRecoveryNotification(for habit: Habit) async {
        let content = UNMutableNotificationContent()
        content.title = "🌱 Fresh Start"
        content.body = "Yesterday is gone, today is a new opportunity to build \(habit.name) back up!"
        content.sound = selectOptimalSound(for: habit.category)
        content.interruptionLevel = .passive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false) // 24 hours

        let request = UNNotificationRequest(
            identifier: "recovery_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    // MARK: - Utility Methods

    private func fetchActiveHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        let allHabits = (try? modelContext.fetch(descriptor)) ?? []
        return allHabits.filter { $0.isActive }
    }

    private func fetchHabit(id: UUID) async -> Habit? {
        let descriptor = FetchDescriptor<Habit>()
        let allHabits = (try? modelContext.fetch(descriptor)) ?? []
        return allHabits.first { $0.id == id }
    }

    private func findOptimalWeekday(for habit: Habit) -> Int {
        // Analyze completion patterns to find best weekday
        let weekdayCompletions = Dictionary(grouping: habit.logs.filter { $0.isCompleted }) { log in
            Calendar.current.component(.weekday, from: log.completionDate)
        }

        let bestWeekday = weekdayCompletions.max { $0.value.count < $1.value.count }?.key ?? 2
        return bestWeekday
    }

    private func calculateRecentSuccessRate(habit: Habit) async -> Double {
        let recentLogs = habit.logs.suffix(7)
        guard !recentLogs.isEmpty else { return 0.5 }

        let successCount = recentLogs.filter { $0.isCompleted }.count
        return Double(successCount) / Double(recentLogs.count)
    }

    private func logNotificationInteraction(
        habit: Habit,
        interaction: NotificationInteraction,
        timestamp: Date
    ) async {
        // Store interaction data for ML learning
        // Implementation would save to analytics database
    }

    private func adjustNotificationTiming(for habit: Habit, direction: TimingAdjustment) async {
        // Implement smart timing adjustment logic
    }

    private func reinforceCurrentTiming(for habit: Habit) async {
        // Strengthen current timing preference
    }

    private func adjustNotificationFrequency(for habit: Habit, factor: Double) async {
        // Modify notification frequency based on success patterns
    }
}

// MARK: - Supporting Types

enum NotificationInteraction {
    case completed(atDate: Date)
    case dismissed
    case ignored
    case snoozed(for: TimeInterval)
}

enum TimingAdjustment {
    case earlier
    case later
}

extension UNNotificationInterruptionLevel {
    static func from(priority: Double) -> UNNotificationInterruptionLevel {
        switch priority {
        case 0.8...1.0: return .critical
        case 0.6..<0.8: return .timeSensitive
        case 0.3..<0.6: return .active
        default: return .passive
        }
    }
}
