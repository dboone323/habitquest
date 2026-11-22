import Foundation
import SwiftData
import HabitQuestCore

/// Service responsible for generating personalized habit suggestions using ML and behavioral analysis
final class HabitSuggestionService {
    private let dataService: HabitDataService
    private let analyticsService: HabitAnalyticsService

    @MainActor
    init(modelContext: ModelContext, ollamaClient: OllamaClient = OllamaClient()) {
        self.dataService = HabitDataService(modelContext: modelContext)
        self.analyticsService = HabitAnalyticsService(ollamaClient: ollamaClient)
    }

    /// Generate personalized habit suggestions using LLM and behavioral analysis
    func generateHabitSuggestions() async -> [HabitQuestCore.HabitSuggestion] {
        guard let existingHabits = try? dataService.fetchAllHabits() else { return [] }
        let allLogs = existingHabits.flatMap { $0.logs }
        return await analyticsService.generateHabitSuggestions(habits: existingHabits, logs: allLogs)
    }

    /// Support methods for legacy features
    func generateCategoryBasedSuggestions(profile: HabitQuestCore.UserProfile) async -> [HabitQuestCore.HabitSuggestion] {
        guard let existingHabits = try? dataService.fetchAllHabits() else { return [] }
        return await analyticsService.generateHabitSuggestions(habits: existingHabits, logs: [])
    }

    func generateTimeBasedSuggestions(profile: HabitQuestCore.UserProfile) async -> [HabitQuestCore.HabitSuggestion] {
        return await generateHabitSuggestions()
    }

    func generateComplementarySuggestions(existing: [HabitQuestCore.Habit]) async -> [HabitQuestCore.HabitSuggestion] {
        return await generateHabitSuggestions()
    }

    func generateTrendingSuggestions() async -> [HabitQuestCore.HabitSuggestion] {
        return await generateHabitSuggestions()
    }

    func generateHabitStackingSuggestions(existing: [HabitQuestCore.Habit]) async -> [HabitQuestCore.HabitSuggestion] {
        return []
    }

    func generateChallengeSuggestions(profile: HabitQuestCore.UserProfile) async -> [HabitQuestCore.HabitSuggestion] {
        return []
    }
}
