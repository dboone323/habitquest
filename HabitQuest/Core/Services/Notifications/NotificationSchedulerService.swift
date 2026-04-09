import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Protocol abstraction for UNUserNotificationCenter to enable testing
protocol NotificationCenterProtocol: Sendable {
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
}

/// Conformance for the real UNUserNotificationCenter
extension UNUserNotificationCenter: NotificationCenterProtocol {}

/// Service responsible for scheduling notifications at optimal times
@Observable @MainActor
final class NotificationSchedulerService {
    private let modelContext: ModelContext
    private let analyticsEngine: AdvancedAnalyticsEngine
    private let notificationCenter: NotificationCenterProtocol
    private let contentGenerationService: ContentGenerationService

    init(
        modelContext: ModelContext,
        analyticsEngine: AdvancedAnalyticsEngine,
        notificationCenter: NotificationCenterProtocol = UNUserNotificationCenter.current(),
        contentGenerationService: ContentGenerationService = ContentGenerationService()
    ) {
        self.modelContext = modelContext
        self.analyticsEngine = analyticsEngine
        self.notificationCenter = notificationCenter
        self.contentGenerationService = contentGenerationService
    }

    /// Schedule AI-optimized notifications for all habits
    func scheduleSmartNotifications() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            await scheduleOptimalNotification(for: habit)
        }
    }

    /// Schedule notification at optimal time based on user behavior
    func scheduleOptimalNotification(for habit: Habit) async {
        let scheduling = await analyticsEngine.generateOptimalScheduling(for: habit)
        let prediction = await analyticsEngine.predictStreakSuccess(for: habit)

        let content = await contentGenerationService.generateSmartContent(
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

    /// Cancel all notifications for a specific habit
    func cancelNotifications(for habitId: UUID) async {
        let identifiers = ["habit_\(habitId.uuidString)"]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Private Methods

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
        case .monthly:
            // For monthly, schedule for the 1st day of the month by default
            dateComponents.day = 1
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
        let allHabits = (try? modelContext.fetch(descriptor)) ?? []
        return allHabits.filter(\.isActive)
    }

    private func findOptimalWeekday(for habit: Habit) -> Int {
        // Analyze completion patterns to find best weekday
        let weekdayCompletions = Dictionary(grouping: habit.logs.filter(\.isCompleted)) { log in
            Calendar.current.component(.weekday, from: log.completionDate)
        }

        return weekdayCompletions.max { $0.value.count < $1.value.count }?.key ?? 2
    }
}
