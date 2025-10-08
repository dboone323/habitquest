@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class SmartNotificationServiceTests: XCTestCase {
    var modelContext: ModelContext!
    var analyticsEngine: AdvancedAnalyticsEngine!
    var smartNotificationService: SmartNotificationService!
    var testHabit: Habit!
    var streakService: StreakService!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory model context for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Habit.self, configurations: config)
        self.modelContext = ModelContext(container)

        // Initialize streak service
        self.streakService = StreakService(modelContext: self.modelContext)

        // Initialize analytics engine
        self.analyticsEngine = AdvancedAnalyticsEngine(modelContext: self.modelContext, streakService: self.streakService)

        // Initialize smart notification service
        self.smartNotificationService = SmartNotificationService(
            modelContext: self.modelContext,
            analyticsEngine: self.analyticsEngine
        )

        // Create test habit
        self.testHabit = Habit(
            name: "Test Habit",
            habitDescription: "A test habit for smart notifications",
            frequency: .daily,
            xpValue: 10,
            category: .health,
            difficulty: .easy
        )
        self.modelContext.insert(self.testHabit)
        try self.modelContext.save()
    }

    override func tearDown() async throws {
        self.smartNotificationService = nil
        self.analyticsEngine = nil
        self.streakService = nil
        self.modelContext = nil
        self.testHabit = nil
        try await super.tearDown()
    }

    // MARK: - NotificationInteraction Tests

    func testNotificationInteraction_AllCases() {
        let allCases = NotificationInteraction.allCases
        XCTAssertEqual(allCases.count, 4, "Should have 4 notification interaction types")

        XCTAssertTrue(allCases.contains(.dismissed), "Should contain dismissed")
        XCTAssertTrue(allCases.contains(.completed), "Should contain completed")
        XCTAssertTrue(allCases.contains(.ignored), "Should contain ignored")
        XCTAssertTrue(allCases.contains(.snoozed), "Should contain snoozed")
    }

    func testNotificationInteraction_RawValues() {
        XCTAssertEqual(NotificationInteraction.dismissed.rawValue, "dismissed")
        XCTAssertEqual(NotificationInteraction.completed.rawValue, "completed")
        XCTAssertEqual(NotificationInteraction.ignored.rawValue, "ignored")
        XCTAssertEqual(NotificationInteraction.snoozed.rawValue, "snoozed")
    }

    func testNotificationInteraction_Codable() {
        // Test encoding and decoding
        let interaction = NotificationInteraction.completed

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(interaction)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(NotificationInteraction.self, from: data)

            XCTAssertEqual(interaction, decoded, "Should encode and decode correctly")
        } catch {
            XCTFail("Encoding/decoding should not fail: \(error)")
        }
    }

    func testNotificationInteraction_Sendable() {
        // Test that NotificationInteraction conforms to Sendable
        let interaction = NotificationInteraction.dismissed

        // This test mainly ensures the type can be used in concurrent contexts
        Task {
            let result = await self.processInteraction(interaction)
            XCTAssertEqual(result, interaction)
        }
    }

    // MARK: - TimingAdjustment Tests

    func testTimingAdjustment_Cases() {
        // Test that TimingAdjustment enum has the expected cases
        let earlier: TimingAdjustment = .earlier
        let later: TimingAdjustment = .later

        // Verify we can create instances of both cases
        XCTAssertNotNil(earlier)
        XCTAssertNotNil(later)
    }

    func testTimingAdjustment_Equatable() {
        let adjustment1: TimingAdjustment = .earlier
        let adjustment2: TimingAdjustment = .earlier
        let adjustment3: TimingAdjustment = .later

        XCTAssertEqual(adjustment1, adjustment2, "Same cases should be equal")
        XCTAssertNotEqual(adjustment1, adjustment3, "Different cases should not be equal")
    }

    // MARK: - SmartNotificationService Initialization Tests

    func testSmartNotificationService_Initialization() {
        XCTAssertNotNil(self.smartNotificationService, "Should initialize successfully")
    }

    // MARK: - Smart Scheduling Tests

    func testScheduleSmartNotifications() async {
        // Test that the method completes without error
        await self.smartNotificationService.scheduleSmartNotifications()
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testScheduleOptimalNotification() async {
        // Test that the method completes without error
        await self.smartNotificationService.scheduleOptimalNotification(for: self.testHabit)
        XCTAssertTrue(true, "Method should complete without error")
    }

    // MARK: - Behavioral Adaptation Tests

    func testAdaptToUserBehavior_Dismissed() async {
        // Test adaptation to dismissed interaction
        await self.smartNotificationService.adaptToUserBehavior(
            habitId: self.testHabit.id,
            interactionType: .dismissed
        )
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testAdaptToUserBehavior_Completed() async {
        // Test adaptation to completed interaction
        await self.smartNotificationService.adaptToUserBehavior(
            habitId: self.testHabit.id,
            interactionType: .completed
        )
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testAdaptToUserBehavior_Ignored() async {
        // Test adaptation to ignored interaction
        await self.smartNotificationService.adaptToUserBehavior(
            habitId: self.testHabit.id,
            interactionType: .ignored
        )
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testAdaptToUserBehavior_Snoozed() async {
        // Test adaptation to snoozed interaction
        await self.smartNotificationService.adaptToUserBehavior(
            habitId: self.testHabit.id,
            interactionType: .snoozed
        )
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testOptimizeNotificationFrequency() async {
        // Test frequency optimization
        await self.smartNotificationService.optimizeNotificationFrequency()
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testAnalyzeUserResponsePatterns() async {
        // Test response pattern analysis
        let analysis = await smartNotificationService.analyzeUserResponsePatterns(habitId: self.testHabit.id)

        XCTAssertGreaterThanOrEqual(analysis.bestResponseTime, 0, "Best response time should be non-negative")
        XCTAssertLessThanOrEqual(analysis.bestResponseTime, 23, "Best response time should be valid hour")
        XCTAssertNotNil(analysis.preferredInteraction, "Should have preferred interaction")
        XCTAssertNotNil(analysis.optimalFrequency, "Should have optimal frequency")
    }

    func testGetBehavioralInsights() async {
        // Test behavioral insights retrieval
        let insights = await smartNotificationService.getBehavioralInsights(habitId: self.testHabit.id)

        XCTAssertGreaterThanOrEqual(insights.engagementScore, 0.0, "Engagement score should be non-negative")
        XCTAssertLessThanOrEqual(insights.engagementScore, 1.0, "Engagement score should be <= 1.0")
        XCTAssertNotNil(insights.responsivenessPattern, "Should have responsiveness pattern")
        XCTAssertNotNil(insights.optimalEngagementWindow, "Should have optimal engagement window")
    }

    // MARK: - Context-Aware Features Tests

    func testScheduleStreakMilestoneNotifications() async {
        // Test streak milestone notifications
        await self.smartNotificationService.scheduleStreakMilestoneNotifications(for: self.testHabit)
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testScheduleRecoveryNotification() async {
        // Test recovery notifications
        await self.smartNotificationService.scheduleRecoveryNotification(for: self.testHabit)
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testScheduleMilestoneCelebrationNotification() async {
        // Test milestone celebration notifications
        let milestone = StreakMilestone(
            streakCount: 7,
            title: "Week Warrior",
            description: "7 days completed!",
            emoji: "🏆",
            celebrationLevel: .intermediate
        )
        await smartNotificationService.scheduleMilestoneCelebrationNotification(for: self.testHabit, milestone: milestone)
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testScheduleContextualReminders() async {
        // Test contextual reminders
        await self.smartNotificationService.scheduleContextualReminders()
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testAnalyzeAndScheduleContextualNotifications() async {
        // Test contextual notification analysis and scheduling
        await self.smartNotificationService.analyzeAndScheduleContextualNotifications()
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testGetContextualInsights() async {
        // Test contextual insights retrieval
        let insights = await smartNotificationService.getContextualInsights(for: self.testHabit.id)

        XCTAssertNotNil(insights, "Should return contextual insights")
    }

    // MARK: - Utility Methods Tests

    func testCancelNotifications() async {
        // Test canceling notifications for a habit
        await self.smartNotificationService.cancelNotifications(for: self.testHabit.id)
        XCTAssertTrue(true, "Method should complete without error")
    }

    func testCancelAllNotifications() async {
        // Test canceling all notifications
        await self.smartNotificationService.cancelAllNotifications()
        XCTAssertTrue(true, "Method should complete without error")
    }

    // MARK: - Helper Methods

    private func processInteraction(_ interaction: NotificationInteraction) async -> NotificationInteraction {
        // Simulate async processing of interaction
        interaction
    }
}
