import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Service responsible for context-aware notification features
@Observable @MainActor
final class ContextAwarenessService {
    private let modelContext: ModelContext
    private let contentGenerationService: ContentGenerationService

    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    init(modelContext: ModelContext, contentGenerationService: ContentGenerationService) {
        self.modelContext = modelContext
        self.contentGenerationService = contentGenerationService
    }

    /// Schedule motivational notifications for streak milestones
    func scheduleStreakMilestoneNotifications(for habit: Habit) async {
        // Get the next milestone for this habit's current streak
        guard let nextMilestone = StreakMilestone.nextMilestone(for: habit.streak) else { return }

        let content = self.contentGenerationService.generateMilestoneContent(for: habit, milestone: nextMilestone)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(
            identifier: "milestone_\(habit.id.uuidString)_\(nextMilestone.streakCount)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule milestone notification for \(habit.name): \(error)")
        }
    }

    /// Send recovery notifications for broken streaks
    func scheduleRecoveryNotification(for habit: Habit) async {
        let content = self.contentGenerationService.generateRecoveryContent(for: habit)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false) // 24 hours

        let request = UNNotificationRequest(
            identifier: "recovery_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule recovery notification for \(habit.name): \(error)")
        }
    }

    /// Schedule celebration notifications for achieved milestones
    func scheduleMilestoneCelebrationNotification(for habit: Habit, milestone: StreakMilestone) async {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Milestone Achieved!"
        content.body = "Congratulations! You've reached \(milestone.title) with \(habit.name)!"
        content.sound = .default
        content.interruptionLevel = .active
        content.categoryIdentifier = "CELEBRATION"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "milestoneStreak": milestone.streakCount,
            "notificationType": "celebration"
        ]

        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "celebration_\(habit.id.uuidString)_\(milestone.streakCount)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule celebration notification for \(habit.name): \(error)")
        }
    }

    /// Schedule contextual reminders based on time and location patterns
    func scheduleContextualReminders() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            await self.scheduleContextualReminder(for: habit)
        }
    }

    /// Analyze user context and schedule appropriate notifications
    func analyzeAndScheduleContextualNotifications() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            let context = await analyzeHabitContext(habit: habit)

            switch context {
            case .streakAtRisk:
                await self.scheduleRecoveryNotification(for: habit)
            case .milestoneApproaching:
                await self.scheduleStreakMilestoneNotifications(for: habit)
            case .lowEngagement:
                await self.scheduleMotivationalReminder(for: habit)
            case .optimalTime:
                // Already handled by scheduler service
                break
            case .normal:
                // No special context needed
                break
            }
        }
    }

    /// Get context-aware insights for a habit
    func getContextualInsights(for habitId: UUID) async -> ContextualInsights {
        let habit = await fetchHabit(id: habitId)
        guard let habit else {
            return ContextualInsights(
                currentContext: .normal,
                riskLevel: .low,
                opportunities: [],
                recommendations: []
            )
        }

        let context = await analyzeHabitContext(habit: habit)
        let riskLevel = self.calculateRiskLevel(habit: habit, context: context)
        let opportunities = self.identifyOpportunities(habit: habit, context: context)
        let recommendations = self.generateRecommendations(habit: habit, context: context)

        return ContextualInsights(
            currentContext: context,
            riskLevel: riskLevel,
            opportunities: opportunities,
            recommendations: recommendations
        )
    }

    // MARK: - Private Methods

    private func scheduleContextualReminder(for habit: Habit) async {
        let context = await analyzeHabitContext(habit: habit)

        switch context {
        case .streakAtRisk:
            await self.scheduleUrgentReminder(for: habit)
        case .milestoneApproaching:
            await self.scheduleStreakMilestoneNotifications(for: habit)
        case .lowEngagement:
            await self.scheduleMotivationalReminder(for: habit)
        case .optimalTime, .normal:
            // No contextual reminder needed
            break
        }
    }

    private func scheduleUrgentReminder(for habit: Habit) async {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Streak Alert!"
        content.body = "Your \(habit.name) streak is at risk. Don't let it break today!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "URGENT_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "notificationType": "urgent"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 minutes

        let request = UNNotificationRequest(
            identifier: "urgent_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule urgent reminder for \(habit.name): \(error)")
        }
    }

    private func scheduleMotivationalReminder(for habit: Habit) async {
        let content = UNMutableNotificationContent()
        content.title = "💪 You've Got This!"
        content.body = "Remember why you started \(habit.name). Every step counts!"
        content.sound = .default
        content.interruptionLevel = .active
        content.categoryIdentifier = "MOTIVATIONAL_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "notificationType": "motivational"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false) // 2 hours

        let request = UNNotificationRequest(
            identifier: "motivational_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await self.notificationCenter.add(request)
        } catch {
            print("Failed to schedule motivational reminder for \(habit.name): \(error)")
        }
    }

    private func analyzeHabitContext(habit: Habit) async -> HabitContext {
        let recentLogs = habit.logs.suffix(7)
        let completionRate = Double(recentLogs.filter(\.isCompleted).count) / Double(max(recentLogs.count, 1))

        // Check for streak at risk
        if habit.streak > 0, completionRate < 0.3 {
            return .streakAtRisk
        }

        // Check for milestone approaching
        if let _ = StreakMilestone.nextMilestone(for: habit.streak) {
            let daysToMilestone = (StreakMilestone.nextMilestone(for: habit.streak)?.streakCount ?? 0) - habit.streak
            if daysToMilestone <= 3 {
                return .milestoneApproaching
            }
        }

        // Check for low engagement
        if completionRate < 0.5, habit.logs.count > 14 {
            return .lowEngagement
        }

        // Check for optimal time (this would be more sophisticated in real implementation)
        let currentHour = Calendar.current.component(.hour, from: Date())
        if (9 ... 11).contains(currentHour) {
            return .optimalTime
        }

        return .normal
    }

    private func calculateRiskLevel(habit: Habit, context: HabitContext) -> RiskLevel {
        switch context {
        case .streakAtRisk:
            habit.streak > 7 ? .high : .medium
        case .lowEngagement:
            .medium
        case .milestoneApproaching:
            .low
        case .optimalTime, .normal:
            .low
        }
    }

    private func identifyOpportunities(habit _: Habit, context _: HabitContext) -> [ContextualOpportunity] {
        // This would analyze patterns to identify opportunities
        // For now, return empty array as placeholder
        []
    }

    private func generateRecommendations(habit _: Habit, context _: HabitContext) -> [ContextualRecommendation] {
        // This would generate personalized recommendations
        // For now, return empty array as placeholder
        []
    }

    private func fetchActiveHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        let allHabits = (try? self.modelContext.fetch(descriptor)) ?? []
        return allHabits.filter(\.isActive)
    }

    private func fetchHabit(id: UUID) async -> Habit? {
        let descriptor = FetchDescriptor<Habit>()
        let allHabits = (try? self.modelContext.fetch(descriptor)) ?? []
        return allHabits.first { $0.id == id }
    }
}

// MARK: - Supporting Types

enum HabitContext {
    case normal
    case optimalTime
    case streakAtRisk
    case milestoneApproaching
    case lowEngagement
}

enum RiskLevel {
    case low
    case medium
    case high
}

struct ContextualInsights {
    let currentContext: HabitContext
    let riskLevel: RiskLevel
    let opportunities: [ContextualOpportunity]
    let recommendations: [ContextualRecommendation]
}

struct ContextualOpportunity {
    let type: OpportunityType
    let description: String
    let potentialImpact: Double
}

enum OpportunityType {
    case optimalTiming
    case motivationalTrigger
    case socialSupport
    case environmentalCue
}

struct ContextualRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let priority: RecommendationPriority
}

enum RecommendationType {
    case timingAdjustment
    case frequencyChange
    case contentPersonalization
    case motivationalApproach
}

enum RecommendationPriority {
    case low
    case medium
    case high
}
