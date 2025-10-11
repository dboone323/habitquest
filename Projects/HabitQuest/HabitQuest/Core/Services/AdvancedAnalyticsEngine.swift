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
        self.predictionService = PredictionService(modelContext: modelContext, streakService: streakService)
        self.patternAnalysisService = PatternAnalysisService(modelContext: modelContext)
        self.behavioralInsightsService = BehavioralInsightsService(modelContext: modelContext)
        self.habitSuggestionService = HabitSuggestionService(modelContext: modelContext)
    }

    // MARK: - Predictive Analytics

    /// Predict streak continuation probability using behavioral patterns
    func predictStreakSuccess(for habit: Habit, days: Int = 7) async -> StreakPrediction {
        await self.predictionService.predictStreakSuccess(for: habit, days: days)
    }

    /// Generate optimal habit scheduling recommendations
    func generateOptimalScheduling(for habit: Habit) async -> SchedulingRecommendation {
        await self.predictionService.generateOptimalScheduling(for: habit)
    }

    // MARK: - Pattern Analysis

    /// Analyze habit patterns for predictive modeling
    func analyzeHabitPatterns(_ habit: Habit) -> HabitPatterns {
        self.patternAnalysisService.analyzeHabitPatterns(habit)
    }

    /// Analyze time-based factors affecting habit completion
    func analyzeTimeFactors(_ habit: Habit) -> TimeFactors {
        self.patternAnalysisService.analyzeTimeFactors(habit)
    }

    /// Calculate streak momentum and acceleration metrics
    func calculateStreakMomentum(_ habit: Habit) -> StreakMomentum {
        self.patternAnalysisService.calculateStreakMomentum(habit)
    }

    // MARK: - Behavioral Insights

    /// Analyze behavioral patterns and correlations
    func analyzeBehavioralPatterns(for habit: Habit) async -> BehavioralInsights {
        await self.behavioralInsightsService.analyzeBehavioralPatterns(for: habit)
    }

    /// Calculate correlation between mood and habit completion
    func calculateMoodCorrelation(_ habit: Habit) async -> Double {
        await self.behavioralInsightsService.calculateMoodCorrelation(habit)
    }

    /// Analyze day-of-week completion patterns
    func analyzeDayOfWeekPattern(_ habit: Habit) -> (strongest: [String], weakest: [String]) {
        self.behavioralInsightsService.analyzeDayOfWeekPattern(habit)
    }

    /// Analyze factors that commonly break streaks
    func analyzeStreakBreakFactors(_ habit: Habit) -> [String] {
        self.behavioralInsightsService.analyzeStreakBreakFactors(habit)
    }

    /// Identify motivation triggers based on completion patterns
    func identifyMotivationTriggers(_ habit: Habit) -> [String] {
        self.behavioralInsightsService.identifyMotivationTriggers(habit)
    }

    /// Generate personality insights based on habit patterns
    func generatePersonalityInsights(_ habit: Habit) -> [String] {
        self.behavioralInsightsService.generatePersonalityInsights(habit)
    }

    // MARK: - Habit Suggestions

    /// Generate personalized habit suggestions using ML
    func generateHabitSuggestions() async -> [AnalyticsHabitSuggestion] {
        await self.habitSuggestionService.generateHabitSuggestions()
    }

    /// Generate suggestions based on user's existing habit categories
    func generateCategoryBasedSuggestions(profile: UserProfile) -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateCategoryBasedSuggestions(profile: profile)
    }

    /// Generate suggestions based on user's time patterns and availability
    func generateTimeBasedSuggestions(profile: UserProfile) -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateTimeBasedSuggestions(profile: profile)
    }

    /// Generate complementary habits that work well with existing ones
    func generateComplementarySuggestions(existing: [Habit]) -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateComplementarySuggestions(existing: existing)
    }

    /// Generate trending habit suggestions
    func generateTrendingSuggestions() -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateTrendingSuggestions()
    }

    /// Generate habit stacking suggestions based on existing routines
    func generateHabitStackingSuggestions(existing: [Habit]) -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateHabitStackingSuggestions(existing: existing)
    }

    /// Generate challenge-based suggestions for advanced users
    func generateChallengeSuggestions(profile: UserProfile) -> [AnalyticsHabitSuggestion] {
        self.habitSuggestionService.generateChallengeSuggestions(profile: profile)
    }
}

// Supporting types moved to AnalyticsTypes.swift
