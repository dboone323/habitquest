import Foundation
import HabitQuestCore
import SwiftData

/// Service responsible for generating personalized habit suggestions.
/// Wired up to work with trimmed analytics (no Ollama dependency).
@MainActor
final class HabitSuggestionService {
    private let dataService: HabitDataService
    private let analyticsService: HabitAnalyticsService

    @MainActor
    init(modelContext: ModelContext) {
        self.dataService = HabitDataService(modelContext: modelContext)
        self.analyticsService = HabitAnalyticsService()
    }

    /// Generate personalized habit suggestions using behavioral analysis.
    func generateHabitSuggestions() async -> [HabitQuestCore.HabitSuggestion] {
        guard let existingHabits = try? dataService.fetchAllHabits() else { return [] }
        let allLogs = existingHabits.flatMap(\.logs)
        return await analyticsService.generateHabitSuggestions(habits: existingHabits, logs: allLogs)
    }

    /// Generate suggestions based on category coverage.
    func generateCategoryBasedSuggestions(profile: HabitQuestCore
        .UserProfile) async -> [HabitQuestCore.HabitSuggestion]
    {
        guard let existingHabits = try? dataService.fetchAllHabits() else { return [] }
        return await analyticsService.generateHabitSuggestions(habits: existingHabits, logs: [])
    }

    func generateTimeBasedSuggestions(profile: HabitQuestCore.UserProfile) async -> [HabitQuestCore.HabitSuggestion] {
        await generateHabitSuggestions()
    }

    func generateComplementarySuggestions(existing: [HabitQuestCore.Habit]) async -> [HabitQuestCore.HabitSuggestion] {
        await generateHabitSuggestions()
    }

    func generateTrendingSuggestions() async -> [HabitQuestCore.HabitSuggestion] {
        await generateHabitSuggestions()
    }

    func generateHabitStackingSuggestions(existing: [HabitQuestCore.Habit]) async -> [HabitQuestCore.HabitSuggestion] {
        []
    }

    func generateChallengeSuggestions(profile: HabitQuestCore.UserProfile) async -> [HabitQuestCore.HabitSuggestion] {
        []
    }
}
