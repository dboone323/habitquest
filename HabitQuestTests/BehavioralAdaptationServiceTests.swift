//
//  BehavioralAdaptationServiceTests.swift
//  HabitQuestTests
//
//  Comprehensive test suite for BehavioralAdaptationService
//

import SwiftData
import XCTest
@testable import HabitQuest

@MainActor
final class BehavioralAdaptationServiceTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var adaptationService: BehavioralAdaptationService!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        modelContext = modelContainer.mainContext
        adaptationService = BehavioralAdaptationService(modelContext: modelContext)
    }

    override func tearDown() {
        adaptationService = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(adaptationService)
    }

    func testProperties() async {
        let habit = makeHabit(
            name: "Hydrate",
            history: [
                HabitEvent(daysAgo: 2, hour: 9, completed: true),
                HabitEvent(daysAgo: 1, hour: 9, completed: false),
                HabitEvent(daysAgo: 0, hour: 9, completed: true),
            ]
        )

        let response = await adaptationService.analyzeUserResponsePatterns(habitId: habit.id)
        XCTAssertEqual(response.bestResponseTime, 9)
        assertInteractionIsCompleted(response.preferredInteraction)
        assertFrequencyIsDaily(response.optimalFrequency)
        XCTAssertTrue(response.successRateByTime.isEmpty)

        let insights = await adaptationService.getBehavioralInsights(habitId: habit.id)
        XCTAssertEqual(insights.engagementScore, 0.5, accuracy: 0.001)
        assertResponsivenessIsModerate(insights.responsivenessPattern)
        XCTAssertEqual(insights.optimalEngagementWindow.duration, 3600, accuracy: 0.001)
        XCTAssertTrue(insights.fatigueIndicators.isEmpty)
    }

    func testPublicMethods() async {
        let habit = makeHabit(
            name: "Daily Walk",
            history: [
                HabitEvent(daysAgo: 3, hour: 8, completed: true),
                HabitEvent(daysAgo: 2, hour: 8, completed: true),
                HabitEvent(daysAgo: 1, hour: 8, completed: false),
                HabitEvent(daysAgo: 0, hour: 8, completed: true),
            ]
        )

        await adaptationService.adaptToUserBehavior(habitId: habit.id, interactionType: .dismissed)
        await adaptationService.adaptToUserBehavior(habitId: habit.id, interactionType: .completed)
        await adaptationService.adaptToUserBehavior(habitId: habit.id, interactionType: .ignored)
        await adaptationService.adaptToUserBehavior(habitId: habit.id, interactionType: .snoozed)
        await adaptationService.optimizeNotificationFrequency()

        let response = await adaptationService.analyzeUserResponsePatterns(habitId: habit.id)
        XCTAssertEqual(response.bestResponseTime, 9)
        assertInteractionIsCompleted(response.preferredInteraction)
        assertFrequencyIsDaily(response.optimalFrequency)
    }

    func testEdgeCases() async {
        let missingHabitID = UUID()

        let response = await adaptationService.analyzeUserResponsePatterns(habitId: missingHabitID)
        XCTAssertEqual(response.bestResponseTime, 9)
        assertInteractionIsCompleted(response.preferredInteraction)
        assertFrequencyIsDaily(response.optimalFrequency)
        XCTAssertTrue(response.successRateByTime.isEmpty)

        let insights = await adaptationService.getBehavioralInsights(habitId: missingHabitID)
        XCTAssertEqual(insights.engagementScore, 0.0, accuracy: 0.001)
        assertResponsivenessIsLow(insights.responsivenessPattern)
        XCTAssertEqual(insights.optimalEngagementWindow.duration, 3600, accuracy: 0.001)
        XCTAssertTrue(insights.fatigueIndicators.isEmpty)

        await adaptationService.adaptToUserBehavior(habitId: missingHabitID, interactionType: .completed)
    }

    func testErrorHandling() async {
        let habit = makeHabit(
            name: "High Variance Habit",
            history: [
                HabitEvent(daysAgo: 4, hour: 19, completed: false),
                HabitEvent(daysAgo: 3, hour: 19, completed: false),
                HabitEvent(daysAgo: 2, hour: 19, completed: false),
                HabitEvent(daysAgo: 1, hour: 19, completed: true),
                HabitEvent(daysAgo: 0, hour: 19, completed: false),
            ],
            isActive: false
        )

        let baselineLogCount = habit.logs.count
        await adaptationService.optimizeNotificationFrequency()
        await adaptationService.adaptToUserBehavior(habitId: habit.id, interactionType: .ignored)

        XCTAssertEqual(habit.logs.count, baselineLogCount)

        let insights = await adaptationService.getBehavioralInsights(habitId: habit.id)
        XCTAssertTrue((0.0...1.0).contains(insights.engagementScore))
        XCTAssertTrue(insights.fatigueIndicators.isEmpty)
    }

    func testIntegration() async {
        let activeConsistent = makeHabit(
            name: "Morning Study",
            history: [
                HabitEvent(daysAgo: 2, hour: 7, completed: true),
                HabitEvent(daysAgo: 1, hour: 7, completed: true),
                HabitEvent(daysAgo: 0, hour: 7, completed: true),
            ]
        )

        let activeStruggling = makeHabit(
            name: "Evening Journal",
            history: [
                HabitEvent(daysAgo: 2, hour: 21, completed: false),
                HabitEvent(daysAgo: 1, hour: 21, completed: false),
                HabitEvent(daysAgo: 0, hour: 21, completed: true),
            ]
        )

        let inactiveHabit = makeHabit(
            name: "Weekend Project",
            history: [HabitEvent(daysAgo: 0, hour: 12, completed: false)],
            isActive: false
        )

        await adaptationService.optimizeNotificationFrequency()

        for habitID in [activeConsistent.id, activeStruggling.id, inactiveHabit.id] {
            let response = await adaptationService.analyzeUserResponsePatterns(habitId: habitID)
            XCTAssertEqual(response.bestResponseTime, 9)
            assertInteractionIsCompleted(response.preferredInteraction)
            assertFrequencyIsDaily(response.optimalFrequency)

            let insights = await adaptationService.getBehavioralInsights(habitId: habitID)
            XCTAssertTrue((0.0...1.0).contains(insights.engagementScore))
            XCTAssertEqual(insights.optimalEngagementWindow.duration, 3600, accuracy: 0.001)
        }
    }
}

private struct HabitEvent {
    let daysAgo: Int
    let hour: Int
    let completed: Bool
}

private extension BehavioralAdaptationServiceTests {
    func makeHabit(
        name: String,
        history: [HabitEvent],
        isActive: Bool = true
    ) -> Habit {
        let habit = Habit(name: name, habitDescription: "Test", frequency: .daily)
        habit.isActive = isActive
        modelContext.insert(habit)

        for entry in history {
            let baseDate = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: Date()) ?? Date()
            let completionDate = Calendar.current.date(
                bySettingHour: entry.hour,
                minute: 0,
                second: 0,
                of: baseDate
            ) ?? baseDate
            let mood: MoodRating? = entry.completed ? .good : .bad
            let log = HabitLog(
                habit: habit,
                completionDate: completionDate,
                isCompleted: entry.completed,
                mood: mood
            )
            habit.logs.append(log)
            modelContext.insert(log)
        }

        try? modelContext.save()
        return habit
    }

    func assertInteractionIsCompleted(
        _ interaction: NotificationInteraction,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if case .completed = interaction {
            return
        }
        XCTFail("Expected preferred interaction to be completed.", file: file, line: line)
    }

    func assertFrequencyIsDaily(
        _ frequency: HabitFrequency,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if case .daily = frequency {
            return
        }
        XCTFail("Expected optimal frequency to be daily.", file: file, line: line)
    }

    func assertResponsivenessIsModerate(
        _ pattern: ResponsivenessPattern,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if case .moderate = pattern {
            return
        }
        XCTFail("Expected responsiveness pattern to be moderate.", file: file, line: line)
    }

    func assertResponsivenessIsLow(
        _ pattern: ResponsivenessPattern,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if case .low = pattern {
            return
        }
        XCTFail("Expected responsiveness pattern to be low.", file: file, line: line)
    }
}
