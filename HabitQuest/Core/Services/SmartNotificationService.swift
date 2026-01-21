import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Intelligent notification service with ML-driven optimal timing
/// Now acts as an orchestrator for specialized notification services
@Observable @MainActor
final class SmartNotificationService {
    private let modelContext: ModelContext
    private let analyticsEngine: AdvancedAnalyticsEngine

    // Specialized services
    private let schedulerService: NotificationSchedulerService
    private let contentService: ContentGenerationService
    private let adaptationService: BehavioralAdaptationService
    private let contextService: ContextAwarenessService

    init(modelContext: ModelContext, analyticsEngine: AdvancedAnalyticsEngine) {
        self.modelContext = modelContext
        self.analyticsEngine = analyticsEngine

        // Initialize specialized services
        contentService = ContentGenerationService()
        schedulerService = NotificationSchedulerService(
            modelContext: modelContext,
            analyticsEngine: analyticsEngine
        )
        adaptationService = BehavioralAdaptationService(modelContext: modelContext)
        contextService = ContextAwarenessService(
            modelContext: modelContext,
            contentGenerationService: contentService
        )
    }

    // MARK: - Smart Scheduling

    /// Schedule AI-optimized notifications for all habits
    func scheduleSmartNotifications() async {
        await schedulerService.scheduleSmartNotifications()
    }

    /// Schedule notification at optimal time based on user behavior
    func scheduleOptimalNotification(for habit: Habit) async {
        await schedulerService.scheduleOptimalNotification(for: habit)
    }

    // MARK: - Behavioral Adaptation

    /// Learn from user interaction patterns and adjust timing
    func adaptToUserBehavior(habitId: UUID, interactionType: NotificationInteraction) async {
        await adaptationService.adaptToUserBehavior(habitId: habitId, interactionType: interactionType)
    }

    /// Dynamically adjust notification frequency based on success patterns
    func optimizeNotificationFrequency() async {
        await adaptationService.optimizeNotificationFrequency()
    }

    /// Analyze user response patterns to determine optimal notification strategies
    func analyzeUserResponsePatterns(habitId: UUID) async -> UserResponseAnalysis {
        await adaptationService.analyzeUserResponsePatterns(habitId: habitId)
    }

    /// Get behavioral insights for notification optimization
    func getBehavioralInsights(habitId: UUID) async -> NotificationBehavioralInsights {
        await adaptationService.getBehavioralInsights(habitId: habitId)
    }

    // MARK: - Context-Aware Features

    /// Schedule motivational notifications for streak milestones
    func scheduleStreakMilestoneNotifications(for habit: Habit) async {
        await contextService.scheduleStreakMilestoneNotifications(for: habit)
    }

    /// Send recovery notifications for broken streaks
    func scheduleRecoveryNotification(for habit: Habit) async {
        await contextService.scheduleRecoveryNotification(for: habit)
    }

    /// Schedule celebration notifications for achieved milestones
    func scheduleMilestoneCelebrationNotification(for habit: Habit, milestone: StreakMilestone) async {
        await contextService.scheduleMilestoneCelebrationNotification(for: habit, milestone: milestone)
    }

    /// Schedule contextual reminders based on time and location patterns
    func scheduleContextualReminders() async {
        await contextService.scheduleContextualReminders()
    }

    /// Analyze user context and schedule appropriate notifications
    func analyzeAndScheduleContextualNotifications() async {
        await contextService.analyzeAndScheduleContextualNotifications()
    }

    /// Get context-aware insights for a habit
    func getContextualInsights(for habitId: UUID) async -> ContextualInsights {
        await contextService.getContextualInsights(for: habitId)
    }

    // MARK: - Utility Methods

    /// Cancel all notifications for a specific habit
    func cancelNotifications(for habitId: UUID) async {
        await schedulerService.cancelNotifications(for: habitId)
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        await schedulerService.cancelAllNotifications()
    }
}
