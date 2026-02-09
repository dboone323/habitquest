import XCTest
@testable import HabitQuest

@MainActor
final class AnalyticsTypesTests: XCTestCase {
    // MARK: - structHabitPatterns{ Tests

    func testHabitPatternsInitialization() {
        // Given
        let consistency = 0.85
        let momentum = 0.72
        let volatility = 0.15
        let weekdayPreference = 3
        let timePreference = 9

        // When
        let patterns = HabitPatterns(
            consistency: consistency,
            momentum: momentum,
            volatility: volatility,
            weekdayPreference: weekdayPreference,
            timePreference: timePreference
        )

        // Then
        XCTAssertEqual(patterns.consistency, consistency)
        XCTAssertEqual(patterns.momentum, momentum)
        XCTAssertEqual(patterns.volatility, volatility)
        XCTAssertEqual(patterns.weekdayPreference, weekdayPreference)
        XCTAssertEqual(patterns.timePreference, timePreference)
    }

    func testHabitPatternsProperties() {
        // Given
        let patterns = HabitPatterns(
            consistency: 0.95,
            momentum: 0.88,
            volatility: 0.05,
            weekdayPreference: 1,
            timePreference: 8
        )

        // Then - Test that all properties are accessible and correct
        XCTAssertGreaterThanOrEqual(patterns.consistency, 0.0)
        XCTAssertLessThanOrEqual(patterns.consistency, 1.0)
        XCTAssertGreaterThanOrEqual(patterns.momentum, 0.0)
        XCTAssertLessThanOrEqual(patterns.momentum, 1.0)
        XCTAssertGreaterThanOrEqual(patterns.volatility, 0.0)
        XCTAssertLessThanOrEqual(patterns.volatility, 1.0)
        XCTAssertGreaterThanOrEqual(patterns.weekdayPreference, 1)
        XCTAssertLessThanOrEqual(patterns.weekdayPreference, 7)
        XCTAssertGreaterThanOrEqual(patterns.timePreference, 0)
        XCTAssertLessThanOrEqual(patterns.timePreference, 23)
    }

    func testHabitPatternsMethods() {
        // Given - Test edge cases and boundary values
        let edgeCasePatterns = HabitPatterns(
            consistency: 0.0,
            momentum: 1.0,
            volatility: 0.5,
            weekdayPreference: 7,
            timePreference: 0
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCasePatterns.consistency, 0.0, accuracy: 0.001)
        XCTAssertEqual(edgeCasePatterns.momentum, 1.0, accuracy: 0.001)
        XCTAssertEqual(edgeCasePatterns.volatility, 0.5, accuracy: 0.001)
        XCTAssertEqual(edgeCasePatterns.weekdayPreference, 7)
        XCTAssertEqual(edgeCasePatterns.timePreference, 0)
    }

    // MARK: - structTimeFactors{ Tests

    func testTimeFactorsInitialization() {
        // Given
        let currentHourSuccessRate = 0.78
        let currentDaySuccessRate = 0.82
        let timesSinceLastCompletion: TimeInterval = 86400 // 1 day
        let optimalTimeWindow: ClosedRange<Int> = 8 ... 10

        // When
        let timeFactors = TimeFactors(
            currentHourSuccessRate: currentHourSuccessRate,
            currentDaySuccessRate: currentDaySuccessRate,
            timesSinceLastCompletion: timesSinceLastCompletion,
            optimalTimeWindow: optimalTimeWindow
        )

        // Then
        XCTAssertEqual(timeFactors.currentHourSuccessRate, currentHourSuccessRate)
        XCTAssertEqual(timeFactors.currentDaySuccessRate, currentDaySuccessRate)
        XCTAssertEqual(timeFactors.timesSinceLastCompletion, timesSinceLastCompletion)
        XCTAssertEqual(timeFactors.optimalTimeWindow, optimalTimeWindow)
    }

    func testTimeFactorsProperties() {
        // Given
        let timeFactors = TimeFactors(
            currentHourSuccessRate: 0.65,
            currentDaySuccessRate: 0.70,
            timesSinceLastCompletion: 43200, // 12 hours
            optimalTimeWindow: 14 ... 16
        )

        // Then - Test that all properties are accessible and within valid ranges
        XCTAssertGreaterThanOrEqual(timeFactors.currentHourSuccessRate, 0.0)
        XCTAssertLessThanOrEqual(timeFactors.currentHourSuccessRate, 1.0)
        XCTAssertGreaterThanOrEqual(timeFactors.currentDaySuccessRate, 0.0)
        XCTAssertLessThanOrEqual(timeFactors.currentDaySuccessRate, 1.0)
        XCTAssertGreaterThanOrEqual(timeFactors.timesSinceLastCompletion, 0)
        XCTAssertGreaterThanOrEqual(timeFactors.optimalTimeWindow.lowerBound, 0)
        XCTAssertLessThanOrEqual(timeFactors.optimalTimeWindow.upperBound, 23)
    }

    func testTimeFactorsMethods() {
        // Given - Test edge cases and boundary values
        let edgeCaseTimeFactors = TimeFactors(
            currentHourSuccessRate: 1.0,
            currentDaySuccessRate: 0.0,
            timesSinceLastCompletion: 0,
            optimalTimeWindow: 0 ... 23
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCaseTimeFactors.currentHourSuccessRate, 1.0, accuracy: 0.001)
        XCTAssertEqual(edgeCaseTimeFactors.currentDaySuccessRate, 0.0, accuracy: 0.001)
        XCTAssertEqual(edgeCaseTimeFactors.timesSinceLastCompletion, 0)
        XCTAssertEqual(edgeCaseTimeFactors.optimalTimeWindow.lowerBound, 0)
        XCTAssertEqual(edgeCaseTimeFactors.optimalTimeWindow.upperBound, 23)
    }

    // MARK: - structStreakMomentum{ Tests

    func testStreakMomentumInitialization() {
        // Given
        let weeklyMomentum = 0.86
        let longestRecentStreak = 15
        let acceleration = 0.12

        // When
        let streakMomentum = StreakMomentum(
            weeklyMomentum: weeklyMomentum,
            longestRecentStreak: longestRecentStreak,
            acceleration: acceleration
        )

        // Then
        XCTAssertEqual(streakMomentum.weeklyMomentum, weeklyMomentum)
        XCTAssertEqual(streakMomentum.longestRecentStreak, longestRecentStreak)
        XCTAssertEqual(streakMomentum.acceleration, acceleration)
    }

    func testStreakMomentumProperties() {
        // Given
        let streakMomentum = StreakMomentum(
            weeklyMomentum: 0.71,
            longestRecentStreak: 30,
            acceleration: 0.05
        )

        // Then - Test that all properties are accessible and within valid ranges
        XCTAssertGreaterThanOrEqual(streakMomentum.weeklyMomentum, 0.0)
        XCTAssertLessThanOrEqual(streakMomentum.weeklyMomentum, 1.0)
        XCTAssertGreaterThanOrEqual(streakMomentum.longestRecentStreak, 0)
        // Acceleration can be negative (declining) or positive (improving)
        XCTAssertNotNil(streakMomentum.acceleration)
    }

    func testStreakMomentumMethods() {
        // Given - Test edge cases and boundary values
        let edgeCaseStreakMomentum = StreakMomentum(
            weeklyMomentum: 0.0,
            longestRecentStreak: 0,
            acceleration: -0.5
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCaseStreakMomentum.weeklyMomentum, 0.0, accuracy: 0.001)
        XCTAssertEqual(edgeCaseStreakMomentum.longestRecentStreak, 0)
        XCTAssertEqual(edgeCaseStreakMomentum.acceleration, -0.5, accuracy: 0.001)
    }

    // MARK: - structSchedulingRecommendation{ Tests

    func testSchedulingRecommendationInitialization() {
        // Given
        let optimalTime = 9
        let successRateAtTime = 0.87
        let reasoning = "Morning routines show highest success rate"
        let alternativeTimes = [7, 8, 10]

        // When
        let recommendation = SchedulingRecommendation(
            optimalTime: optimalTime,
            successRateAtTime: successRateAtTime,
            reasoning: reasoning,
            alternativeTimes: alternativeTimes
        )

        // Then
        XCTAssertEqual(recommendation.optimalTime, optimalTime)
        XCTAssertEqual(recommendation.successRateAtTime, successRateAtTime)
        XCTAssertEqual(recommendation.reasoning, reasoning)
        XCTAssertEqual(recommendation.alternativeTimes, alternativeTimes)
    }

    func testSchedulingRecommendationProperties() {
        // Given
        let recommendation = SchedulingRecommendation(
            optimalTime: 14,
            successRateAtTime: 0.92,
            reasoning: "Afternoon energy peak detected",
            alternativeTimes: [13, 15, 16]
        )

        // Then - Test that all properties are accessible and within valid ranges
        XCTAssertGreaterThanOrEqual(recommendation.optimalTime, 0)
        XCTAssertLessThanOrEqual(recommendation.optimalTime, 23)
        XCTAssertGreaterThanOrEqual(recommendation.successRateAtTime, 0.0)
        XCTAssertLessThanOrEqual(recommendation.successRateAtTime, 1.0)
        XCTAssertFalse(recommendation.reasoning.isEmpty)
        XCTAssertGreaterThan(recommendation.alternativeTimes.count, 0)
    }

    func testSchedulingRecommendationMethods() {
        // Given - Test edge cases and boundary values
        let edgeCaseRecommendation = SchedulingRecommendation(
            optimalTime: 0,
            successRateAtTime: 1.0,
            reasoning: "Late night productivity",
            alternativeTimes: []
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCaseRecommendation.optimalTime, 0)
        XCTAssertEqual(edgeCaseRecommendation.successRateAtTime, 1.0, accuracy: 0.001)
        XCTAssertEqual(edgeCaseRecommendation.reasoning, "Late night productivity")
        XCTAssertEqual(edgeCaseRecommendation.alternativeTimes.count, 0)
    }

    // MARK: - structBehavioralInsights{ Tests

    func testBehavioralInsightsInitialization() {
        // Given
        let moodCorrelation = 0.75
        let strongestDays = ["Monday", "Wednesday", "Friday"]
        let weakestDays = ["Saturday", "Sunday"]
        let streakBreakFactors = ["Stress", "Travel"]
        let motivationTriggers = ["Morning routine", "Social accountability"]
        let personalityInsights = ["Highly disciplined", "Morning person"]

        // When
        let insights = BehavioralInsights(
            moodCorrelation: moodCorrelation,
            strongestDays: strongestDays,
            weakestDays: weakestDays,
            streakBreakFactors: streakBreakFactors,
            motivationTriggers: motivationTriggers,
            personalityInsights: personalityInsights
        )

        // Then
        XCTAssertEqual(insights.moodCorrelation, moodCorrelation)
        XCTAssertEqual(insights.strongestDays, strongestDays)
        XCTAssertEqual(insights.weakestDays, weakestDays)
        XCTAssertEqual(insights.streakBreakFactors, streakBreakFactors)
        XCTAssertEqual(insights.motivationTriggers, motivationTriggers)
        XCTAssertEqual(insights.personalityInsights, personalityInsights)
    }

    func testBehavioralInsightsProperties() {
        // Given
        let insights = BehavioralInsights(
            moodCorrelation: 0.68,
            strongestDays: ["Tuesday", "Thursday"],
            weakestDays: ["Monday"],
            streakBreakFactors: ["Work stress"],
            motivationTriggers: ["Habit stacking"],
            personalityInsights: ["Consistent performer"]
        )

        // Then - Test that all properties are accessible and within valid ranges
        XCTAssertGreaterThanOrEqual(insights.moodCorrelation, -1.0)
        XCTAssertLessThanOrEqual(insights.moodCorrelation, 1.0)
        XCTAssertNotNil(insights.strongestDays)
        XCTAssertNotNil(insights.weakestDays)
        XCTAssertNotNil(insights.streakBreakFactors)
        XCTAssertNotNil(insights.motivationTriggers)
        XCTAssertNotNil(insights.personalityInsights)
    }

    func testBehavioralInsightsMethods() {
        // Given - Test edge cases with empty arrays
        let edgeCaseInsights = BehavioralInsights(
            moodCorrelation: 0.0,
            strongestDays: [],
            weakestDays: [],
            streakBreakFactors: [],
            motivationTriggers: [],
            personalityInsights: []
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCaseInsights.moodCorrelation, 0.0, accuracy: 0.001)
        XCTAssertEqual(edgeCaseInsights.strongestDays.count, 0)
        XCTAssertEqual(edgeCaseInsights.weakestDays.count, 0)
        XCTAssertEqual(edgeCaseInsights.streakBreakFactors.count, 0)
        XCTAssertEqual(edgeCaseInsights.motivationTriggers.count, 0)
        XCTAssertEqual(edgeCaseInsights.personalityInsights.count, 0)
    }

    // MARK: - structHabitSuggestion{ Tests

    func testHabitSuggestionInitialization() {
        // Given
        let name = "Morning Meditation"
        let description = "Start your day with 10 minutes of mindfulness"
        let category = HabitCategory.mindfulness
        let difficulty = HabitDifficulty.easy
        let reasoning = "Morning routines build strong foundations"
        let expectedSuccess = 0.85

        // When
        let suggestion = HabitSuggestion(
            name: name,
            description: description,
            category: category,
            difficulty: difficulty,
            reasoning: reasoning,
            expectedSuccess: expectedSuccess
        )

        // Then
        XCTAssertEqual(suggestion.name, name)
        XCTAssertEqual(suggestion.description, description)
        XCTAssertEqual(suggestion.category, category)
        XCTAssertEqual(suggestion.difficulty, difficulty)
        XCTAssertEqual(suggestion.reasoning, reasoning)
        XCTAssertEqual(suggestion.expectedSuccess, expectedSuccess)
    }

    func testHabitSuggestionProperties() {
        // Given
        let suggestion = HabitSuggestion(
            name: "Evening Walk",
            description: "Take a 15-minute walk to unwind",
            category: .fitness,
            difficulty: .easy,
            reasoning: "Evening activity combats stress",
            expectedSuccess: 0.80
        )

        // Then - Test that all properties are accessible and within valid ranges
        XCTAssertFalse(suggestion.name.isEmpty)
        XCTAssertFalse(suggestion.description.isEmpty)
        XCTAssertNotNil(suggestion.category)
        XCTAssertNotNil(suggestion.difficulty)
        XCTAssertFalse(suggestion.reasoning.isEmpty)
        XCTAssertGreaterThanOrEqual(suggestion.expectedSuccess, 0.0)
        XCTAssertLessThanOrEqual(suggestion.expectedSuccess, 1.0)
    }

    func testHabitSuggestionMethods() {
        // Given - Test edge cases with different categories and difficulties
        let edgeCaseSuggestion = HabitSuggestion(
            name: "Advanced Coding Challenge",
            description: "Complete a difficult algorithm problem",
            category: .learning,
            difficulty: .hard,
            reasoning: "Builds problem-solving skills",
            expectedSuccess: 0.35
        )

        // Then - Verify edge case values are handled correctly
        XCTAssertEqual(edgeCaseSuggestion.name, "Advanced Coding Challenge")
        XCTAssertEqual(edgeCaseSuggestion.category, .learning)
        XCTAssertEqual(edgeCaseSuggestion.difficulty, .hard)
        XCTAssertEqual(edgeCaseSuggestion.expectedSuccess, 0.35, accuracy: 0.001)
    }
}
