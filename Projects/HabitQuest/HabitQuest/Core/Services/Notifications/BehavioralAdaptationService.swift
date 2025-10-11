import Foundation
import SwiftData

/// Service responsible for adapting notifications based on user behavior patterns
@Observable @MainActor
final class BehavioralAdaptationService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Learn from user interaction patterns and adjust timing
    func adaptToUserBehavior(habitId: UUID, interactionType: NotificationInteraction) async {
        let habit = await fetchHabit(id: habitId)
        guard let habit else { return }

        // Log interaction for machine learning
        await self.logNotificationInteraction(
            habit: habit,
            interaction: interactionType,
            timestamp: Date()
        )

        // Adjust future notifications based on response
        switch interactionType {
        case .dismissed:
            await self.adjustNotificationTiming(for: habit, direction: .later)
        case .completed:
            await self.reinforceCurrentTiming(for: habit)
        case .ignored:
            await self.adjustNotificationTiming(for: habit, direction: .earlier)
        case .snoozed:
            await self.adjustNotificationFrequency(for: habit, factor: 0.8) // Reduce frequency
        }
    }

    /// Dynamically adjust notification frequency based on success patterns
    func optimizeNotificationFrequency() async {
        let habits = await fetchActiveHabits()

        for habit in habits {
            let recentSuccess = await calculateRecentSuccessRate(habit: habit)

            if recentSuccess > 0.8 {
                // Reduce frequency for well-established habits
                await self.adjustNotificationFrequency(for: habit, factor: 0.7)
            } else if recentSuccess < 0.3 {
                // Increase support for struggling habits
                await self.adjustNotificationFrequency(for: habit, factor: 1.3)
            }
        }
    }

    /// Analyze user response patterns to determine optimal notification strategies
    func analyzeUserResponsePatterns(habitId: UUID) async -> UserResponseAnalysis {
        let habit = await fetchHabit(id: habitId)
        guard let habit else {
            return UserResponseAnalysis(
                bestResponseTime: 9,
                preferredInteraction: .completed,
                optimalFrequency: .daily,
                successRateByTime: [:]
            )
        }

        let interactions = await fetchNotificationInteractions(for: habit)

        // Analyze response patterns
        let successRateByTime = self.calculateSuccessRateByTime(interactions: interactions)
        let bestResponseTime = self.findBestResponseTime(from: successRateByTime)
        let preferredInteraction = self.determinePreferredInteraction(interactions: interactions)
        let optimalFrequency = self.determineOptimalFrequency(habit: habit, interactions: interactions)

        return UserResponseAnalysis(
            bestResponseTime: bestResponseTime,
            preferredInteraction: preferredInteraction,
            optimalFrequency: optimalFrequency,
            successRateByTime: successRateByTime
        )
    }

    /// Get behavioral insights for notification optimization
    func getBehavioralInsights(habitId: UUID) async -> NotificationBehavioralInsights {
        let habit = await fetchHabit(id: habitId)
        guard let habit else {
            return NotificationBehavioralInsights(
                engagementScore: 0.0,
                responsivenessPattern: .low,
                optimalEngagementWindow: DateInterval(start: Date(), duration: 3600),
                fatigueIndicators: []
            )
        }

        let interactions = await fetchNotificationInteractions(for: habit)
        let recentInteractions = interactions.filter { $0.timestamp > Date().addingTimeInterval(-7 * 24 * 3600) }

        let engagementScore = self.calculateEngagementScore(interactions: recentInteractions)
        let responsivenessPattern = self.determineResponsivenessPattern(interactions: recentInteractions)
        let optimalWindow = self.findOptimalEngagementWindow(interactions: recentInteractions)
        let fatigueIndicators = self.detectFatigueIndicators(interactions: recentInteractions)

        return NotificationBehavioralInsights(
            engagementScore: engagementScore,
            responsivenessPattern: responsivenessPattern,
            optimalEngagementWindow: optimalWindow,
            fatigueIndicators: fatigueIndicators
        )
    }

    // MARK: - Private Methods

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

    private func calculateRecentSuccessRate(habit: Habit) async -> Double {
        let recentLogs = habit.logs.suffix(7)
        guard !recentLogs.isEmpty else { return 0.5 }

        let successCount = recentLogs.filter(\.isCompleted).count
        return Double(successCount) / Double(recentLogs.count)
    }

    private func logNotificationInteraction(
        habit _: Habit,
        interaction _: NotificationInteraction,
        timestamp _: Date
    ) async {
        // Store interaction data for ML learning
        // Implementation would save to analytics database
        // For now, this is a placeholder for future implementation
    }

    private func adjustNotificationTiming(for _: Habit, direction _: TimingAdjustment) async {
        // Implement smart timing adjustment logic
        // This would modify stored preferences for the habit
    }

    private func reinforceCurrentTiming(for _: Habit) async {
        // Strengthen current timing preference
        // This would increase confidence in current timing choice
    }

    private func adjustNotificationFrequency(for _: Habit, factor _: Double) async {
        // Modify notification frequency based on success patterns
        // This would update frequency settings in habit preferences
    }

    private func fetchNotificationInteractions(for _: Habit) async -> [NotificationInteractionData] {
        // Fetch stored interaction data from database
        // For now, return empty array as placeholder
        []
    }

    private func calculateSuccessRateByTime(interactions _: [NotificationInteractionData]) -> [Int: Double] {
        // Calculate success rates by hour of day
        // Placeholder implementation
        [:]
    }

    private func findBestResponseTime(from _: [Int: Double]) -> Int {
        // Find the hour with highest success rate
        9 // Default to 9 AM
    }

    private func determinePreferredInteraction(interactions _: [NotificationInteractionData])
    -> NotificationInteraction {
        // Analyze which interaction type is most common
        .completed // Default assumption
    }

    private func determineOptimalFrequency(
        habit _: Habit,
        interactions _: [NotificationInteractionData]
    ) -> HabitFrequency {
        // Determine optimal frequency based on interaction patterns
        .daily // Default to daily
    }

    private func calculateEngagementScore(interactions _: [NotificationInteractionData]) -> Double {
        // Calculate overall engagement score (0.0 to 1.0)
        0.5 // Neutral default
    }

    private func determineResponsivenessPattern(interactions _: [NotificationInteractionData])
    -> ResponsivenessPattern {
        // Determine if user is highly responsive, moderately, or low
        .moderate
    }

    private func findOptimalEngagementWindow(interactions _: [NotificationInteractionData]) -> DateInterval {
        // Find the time window when user is most likely to engage
        DateInterval(start: Date(), duration: 3600) // Default 1-hour window
    }

    private func detectFatigueIndicators(interactions _: [NotificationInteractionData]) -> [FatigueIndicator] {
        // Detect signs of notification fatigue
        [] // No fatigue detected by default
    }
}

// MARK: - Supporting Types

enum NotificationInteraction: String, Codable, CaseIterable, Sendable {
    case dismissed
    case completed
    case ignored
    case snoozed
}

enum TimingAdjustment {
    case earlier
    case later
}

struct UserResponseAnalysis {
    let bestResponseTime: Int
    let preferredInteraction: NotificationInteraction
    let optimalFrequency: HabitFrequency
    let successRateByTime: [Int: Double]
}

struct NotificationBehavioralInsights {
    let engagementScore: Double
    let responsivenessPattern: ResponsivenessPattern
    let optimalEngagementWindow: DateInterval
    let fatigueIndicators: [FatigueIndicator]
}

enum ResponsivenessPattern {
    case high
    case moderate
    case low
}

struct FatigueIndicator {
    let type: FatigueType
    let severity: Double
    let detectedAt: Date
}

enum FatigueType {
    case dismissalRate
    case ignoreRate
    case snoozeRate
    case decliningEngagement
}

struct NotificationInteractionData {
    let habitId: UUID
    let interaction: NotificationInteraction
    let timestamp: Date
    let scheduledTime: Date
}
