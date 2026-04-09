import Foundation
import SwiftData

/// Advanced analytics engine with machine learning predictions and behavioral insights
/// Now refactored to use specialized service classes for better separation of concerns
@Observable
final class AdvancedAnalyticsEngine {
    private let modelContext: ModelContext
    private let streakService: StreakService

    // Service dependencies
    private let predictionService: PredictionService
    private let patternAnalysisService: PatternAnalysisService
    private let behavioralInsightsService: BehavioralInsightsService
    private let habitSuggestionService: HabitSuggestionService

    init(modelContext: ModelContext, streakService: StreakService) {
        self.modelContext = modelContext
        self.streakService = streakService

        // Initialize specialized services
        predictionService = PredictionService(modelContext: modelContext, streakService: streakService)
        patternAnalysisService = PatternAnalysisService(modelContext: modelContext)
        behavioralInsightsService = BehavioralInsightsService(modelContext: modelContext)
        habitSuggestionService = HabitSuggestionService(modelContext: modelContext)
    }

    // MARK: - Predictive Analytics

    /// Predict streak continuation probability using behavioral patterns
    func predictStreakSuccess(for habit: Habit, days: Int = 7) async -> StreakPrediction {
        await predictionService.predictStreakSuccess(for: habit, days: days)
    }

    /// Generate optimal habit scheduling recommendations
    func generateOptimalScheduling(for habit: Habit) async -> SchedulingRecommendation {
        await predictionService.generateOptimalScheduling(for: habit)
    }

    // MARK: - Pattern Analysis

    /// Analyze habit patterns for predictive modeling
    func analyzeHabitPatterns(_ habit: Habit) -> HabitPatterns {
        patternAnalysisService.analyzeHabitPatterns(habit)
    }

    /// Analyze time-based factors affecting habit completion
    func analyzeTimeFactors(_ habit: Habit) -> TimeFactors {
        patternAnalysisService.analyzeTimeFactors(habit)
    }

    /// Calculate streak momentum and acceleration metrics
    func calculateStreakMomentum(_ habit: Habit) -> StreakMomentum {
        patternAnalysisService.calculateStreakMomentum(habit)
    }

    // MARK: - Behavioral Insights

    /// Analyze behavioral patterns and correlations
    func analyzeBehavioralPatterns(for habit: Habit) async -> BehavioralInsights {
        await behavioralInsightsService.analyzeBehavioralPatterns(for: habit)
    }

    /// Calculate correlation between mood and habit completion
    func calculateMoodCorrelation(_ habit: Habit) async -> Double {
        await behavioralInsightsService.calculateMoodCorrelation(habit)
    }

    /// Analyze day-of-week completion patterns
    func analyzeDayOfWeekPattern(_ habit: Habit) -> (strongest: [String], weakest: [String]) {
        behavioralInsightsService.analyzeDayOfWeekPattern(habit)
    }

    /// Analyze factors that commonly break streaks
    func analyzeStreakBreakFactors(_ habit: Habit) -> [String] {
        behavioralInsightsService.analyzeStreakBreakFactors(habit)
    }

    /// Identify motivation triggers based on completion patterns
    func identifyMotivationTriggers(_ habit: Habit) -> [String] {
        behavioralInsightsService.identifyMotivationTriggers(habit)
    }

    /// Generate personality insights based on habit patterns
    func generatePersonalityInsights(_ habit: Habit) -> [String] {
        behavioralInsightsService.generatePersonalityInsights(habit)
    }

    // MARK: - Habit Suggestions

    /// Generate personalized habit suggestions using ML
    func generateHabitSuggestions() async -> [HabitSuggestion] {
        await habitSuggestionService.generateHabitSuggestions()
    }

    /// Generate suggestions based on user's existing habit categories
    func generateCategoryBasedSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        habitSuggestionService.generateCategoryBasedSuggestions(profile: profile)
    }

    /// Generate suggestions based on user's time patterns and availability
    func generateTimeBasedSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        habitSuggestionService.generateTimeBasedSuggestions(profile: profile)
    }

    /// Generate complementary habits that work well with existing ones
    func generateComplementarySuggestions(existing: [Habit]) -> [HabitSuggestion] {
        habitSuggestionService.generateComplementarySuggestions(existing: existing)
    }

    /// Generate trending habit suggestions
    func generateTrendingSuggestions() -> [HabitSuggestion] {
        habitSuggestionService.generateTrendingSuggestions()
    }

    /// Generate habit stacking suggestions based on existing routines
    func generateHabitStackingSuggestions(existing: [Habit]) -> [HabitSuggestion] {
        habitSuggestionService.generateHabitStackingSuggestions(existing: existing)
    }

    /// Generate challenge-based suggestions for advanced users
    func generateChallengeSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        habitSuggestionService.generateChallengeSuggestions(profile: profile)
    }
}

// Supporting types moved to AnalyticsTypes.swift
