//
//  AdvancedAnalyticsEngineTests.swift
//  HabitQuestTests
//
//  Comprehensive test suite for AdvancedAnalyticsEngine
//

import SwiftData
import XCTest
@testable import HabitQuest

@MainActor
final class AdvancedAnalyticsEngineTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var streakService: StreakService!
    private var analyticsEngine: AdvancedAnalyticsEngine!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        modelContext = modelContainer.mainContext
        streakService = StreakService(modelContext: modelContext)
        analyticsEngine = AdvancedAnalyticsEngine(modelContext: modelContext, streakService: streakService)
    }

    override func tearDown() {
        analyticsEngine = nil
        streakService = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(analyticsEngine)

        let trending = analyticsEngine.generateTrendingSuggestions()
        XCTAssertEqual(trending.count, 3)
        XCTAssertTrue(trending.allSatisfy { $0.expectedSuccess > 0 && $0.expectedSuccess <= 1.0 })
    }

    func testProperties() {
        let habit = makeHabit(name: "Read", category: .learning)

        let patterns = analyticsEngine.analyzeHabitPatterns(habit)
        XCTAssertEqual(patterns.consistency, 0.0, accuracy: 0.001)
        XCTAssertEqual(patterns.momentum, 0.5, accuracy: 0.001)
        XCTAssertEqual(patterns.volatility, 0.0, accuracy: 0.001)

        let timeFactors = analyticsEngine.analyzeTimeFactors(habit)
        XCTAssertEqual(timeFactors.currentHourSuccessRate, 0.5, accuracy: 0.001)
        XCTAssertEqual(timeFactors.currentDaySuccessRate, 0.5, accuracy: 0.001)
        XCTAssertEqual(timeFactors.optimalTimeWindow, 9...11)
        XCTAssertGreaterThanOrEqual(timeFactors.timesSinceLastCompletion, 0)
    }

    func testPublicMethods() async {
        var history: [HabitHistoryEntry] = []

        for day in stride(from: 13, through: 7, by: -1) {
            history.append(
                HabitHistoryEntry(daysAgo: day, hour: 7, completed: false, mood: .bad)
            )
        }

        for day in stride(from: 6, through: 0, by: -1) {
            history.append(
                HabitHistoryEntry(daysAgo: day, hour: 7, completed: true, mood: .good)
            )
        }

        let habit = makeHabit(
            name: "Morning Workout",
            category: .fitness,
            streak: 7,
            history: history
        )

        let patterns = analyticsEngine.analyzeHabitPatterns(habit)
        XCTAssertGreaterThan(patterns.momentum, 0.5)

        let momentum = analyticsEngine.calculateStreakMomentum(habit)
        XCTAssertGreaterThanOrEqual(momentum.weeklyMomentum, 0.0)
        XCTAssertLessThanOrEqual(momentum.weeklyMomentum, 1.0)
        XCTAssertGreaterThan(momentum.longestRecentStreak, 0)

        let dayPattern = analyticsEngine.analyzeDayOfWeekPattern(habit)
        XCTAssertLessThanOrEqual(dayPattern.strongest.count, 2)
        XCTAssertLessThanOrEqual(dayPattern.weakest.count, 2)

        let prediction = await analyticsEngine.predictStreakSuccess(for: habit, days: 7)
        XCTAssertGreaterThanOrEqual(prediction.probability, 5.0)
        XCTAssertLessThanOrEqual(prediction.probability, 95.0)
        XCTAssertFalse(prediction.recommendedAction.isEmpty)

        let scheduling = await analyticsEngine.generateOptimalScheduling(for: habit)
        XCTAssertTrue((0...23).contains(scheduling.optimalTime))
        XCTAssertTrue((0.0...1.0).contains(scheduling.successRateAtTime))
        XCTAssertFalse(scheduling.alternativeTimes.isEmpty)

        let insights = await analyticsEngine.analyzeBehavioralPatterns(for: habit)
        XCTAssertTrue((0.0...1.0).contains(insights.moodCorrelation))
        XCTAssertFalse(insights.streakBreakFactors.isEmpty)
        XCTAssertFalse(insights.motivationTriggers.isEmpty)
        XCTAssertFalse(insights.personalityInsights.isEmpty)
    }

    func testEdgeCases() async {
        let habit = makeHabit(name: "No History", category: .mindfulness)

        let prediction = await analyticsEngine.predictStreakSuccess(for: habit)
        XCTAssertGreaterThanOrEqual(prediction.probability, 5.0)
        XCTAssertLessThanOrEqual(prediction.probability, 95.0)

        let scheduling = await analyticsEngine.generateOptimalScheduling(for: habit)
        XCTAssertEqual(scheduling.optimalTime, 9)
        XCTAssertEqual(scheduling.successRateAtTime, 0.5, accuracy: 0.001)
        XCTAssertTrue(scheduling.alternativeTimes.isEmpty)

        let insights = await analyticsEngine.analyzeBehavioralPatterns(for: habit)
        XCTAssertTrue(insights.strongestDays.isEmpty)
        XCTAssertTrue(insights.weakestDays.isEmpty)
        XCTAssertFalse(insights.streakBreakFactors.isEmpty)
        XCTAssertFalse(insights.motivationTriggers.isEmpty)

        XCTAssertTrue(analyticsEngine.generateComplementarySuggestions(existing: []).isEmpty)
        XCTAssertTrue(analyticsEngine.generateHabitStackingSuggestions(existing: []).isEmpty)
    }

    func testErrorHandling() async {
        let history: [HabitHistoryEntry] = [
            HabitHistoryEntry(daysAgo: 5, hour: 18, completed: false, mood: nil),
            HabitHistoryEntry(daysAgo: 4, hour: 18, completed: false, mood: nil),
            HabitHistoryEntry(daysAgo: 3, hour: 18, completed: false, mood: nil),
            HabitHistoryEntry(daysAgo: 2, hour: 18, completed: false, mood: nil),
            HabitHistoryEntry(daysAgo: 1, hour: 18, completed: false, mood: nil),
            HabitHistoryEntry(daysAgo: 0, hour: 18, completed: false, mood: nil),
        ]

        let habit = makeHabit(name: "Evening Reflection", category: .productivity, history: history)

        let correlation = await analyticsEngine.calculateMoodCorrelation(habit)
        XCTAssertTrue((0.0...1.0).contains(correlation))

        let insights = await analyticsEngine.analyzeBehavioralPatterns(for: habit)
        XCTAssertTrue(insights.streakBreakFactors.contains("Recent setbacks"))

        let emptyProfile = UserProfile(
            existingHabits: [],
            averageConsistency: 0.0,
            peakProductivityHour: 22,
            preferredCategories: []
        )

        XCTAssertTrue(analyticsEngine.generateCategoryBasedSuggestions(profile: emptyProfile).isEmpty)
        XCTAssertTrue(analyticsEngine.generateChallengeSuggestions(profile: emptyProfile).isEmpty)
    }

    func testIntegration() async {
        let morningHabit = makeHabit(
            name: "Morning Run",
            category: .health,
            history: [
                HabitHistoryEntry(daysAgo: 2, hour: 7, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 1, hour: 7, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 0, hour: 7, completed: true, mood: .excellent),
            ]
        )

        let eveningHabit = makeHabit(
            name: "Deep Work",
            category: .productivity,
            history: [
                HabitHistoryEntry(daysAgo: 2, hour: 20, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 1, hour: 20, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 0, hour: 20, completed: true, mood: .good),
            ]
        )

        _ = makeHabit(
            name: "Daily Learning",
            category: .learning,
            history: [
                HabitHistoryEntry(daysAgo: 2, hour: 19, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 1, hour: 19, completed: true, mood: .good),
                HabitHistoryEntry(daysAgo: 0, hour: 19, completed: true, mood: .good),
            ]
        )

        let profile = UserProfile(
            existingHabits: [morningHabit, eveningHabit],
            averageConsistency: 0.85,
            peakProductivityHour: 8,
            preferredCategories: [.health, .productivity, .learning]
        )

        let timeBased = analyticsEngine.generateTimeBasedSuggestions(profile: profile)
        XCTAssertEqual(timeBased.first?.name, "Morning Meditation")

        let complementary = analyticsEngine.generateComplementarySuggestions(
            existing: [morningHabit, eveningHabit]
        )
        XCTAssertEqual(complementary.count, 2)

        let stacking = analyticsEngine.generateHabitStackingSuggestions(
            existing: [morningHabit, eveningHabit]
        )
        XCTAssertEqual(stacking.count, 2)

        let challenge = analyticsEngine.generateChallengeSuggestions(profile: profile)
        XCTAssertEqual(challenge.count, 1)

        let generated = await analyticsEngine.generateHabitSuggestions()
        XCTAssertFalse(generated.isEmpty)
        XCTAssertTrue(generated.contains { $0.name == "Digital Detox Hour" })
    }
}

private struct HabitHistoryEntry {
    let daysAgo: Int
    let hour: Int
    let completed: Bool
    let mood: MoodRating?
}

private extension AdvancedAnalyticsEngineTests {
    func makeHabit(
        name: String,
        category: HabitCategory,
        streak: Int = 0,
        history: [HabitHistoryEntry] = []
    ) -> Habit {
        let habit = Habit(name: name, habitDescription: "Test", frequency: .daily, category: category)
        habit.streak = streak
        modelContext.insert(habit)

        for entry in history {
            let baseDate = Calendar.current.date(byAdding: .day, value: -entry.daysAgo, to: Date()) ?? Date()
            let completionDate = Calendar.current.date(
                bySettingHour: entry.hour,
                minute: 0,
                second: 0,
                of: baseDate
            ) ?? baseDate

            let log = HabitLog(
                habit: habit,
                completionDate: completionDate,
                isCompleted: entry.completed,
                mood: entry.mood
            )
            habit.logs.append(log)
            modelContext.insert(log)
        }

        try? modelContext.save()
        return habit
    }
}
