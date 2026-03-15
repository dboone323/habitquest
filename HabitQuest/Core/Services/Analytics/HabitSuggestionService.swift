import Foundation
import SharedKit
import SwiftData

/// Service responsible for generating personalized habit suggestions using ML and behavioral analysis
final class HabitSuggestionService {
    private let modelContext: ModelContext
    private let ollamaClient: OllamaClient

    @MainActor
    init(modelContext: ModelContext, ollamaClient: OllamaClient = OllamaClient()) {
        self.modelContext = modelContext
        self.ollamaClient = ollamaClient
    }

    /// Generate personalized habit suggestions using LLM and behavioral analysis
    func generateHabitSuggestions() async -> [HabitSuggestion] {
        let existingHabits = await fetchAllHabits()
        let userProfile = await analyzeUserProfile(from: existingHabits)

        // Try to get AI suggestions first
        if let aiSuggestions = await generateAISuggestions(profile: userProfile) {
            return aiSuggestions
        }

        // Fallback to heuristic-based suggestions if AI fails or returns empty
        return [
            generateCategoryBasedSuggestions(profile: userProfile),
            generateTimeBasedSuggestions(profile: userProfile),
            generateComplementarySuggestions(existing: existingHabits),
            generateTrendingSuggestions(),
        ].flatMap(\.self)
    }

    /// Use Ollama to generate context-aware habit suggestions
    private func generateAISuggestions(profile: UserProfile) async -> [HabitSuggestion]? {
        let habitNames = profile.existingHabits.map(\.name).joined(separator: ", ")
        let prompt = """
        User has the following habits: \(habitNames).
        Their average consistency is \(String(format: "%.2f", profile.averageConsistency)).
        Their peak productivity hour is \(profile.peakProductivityHour).
        Generate 3 personalized habit suggestions in valid JSON format (a list of objects).
        Each object must have: 
        - "name": String
        - "description": String
        - "category": String (one of: health, fitness, learning, productivity, social, creativity, mindfulness, other)
        - "difficulty": String (one of: easy, medium, hard)
        - "reasoning": String

        Return ONLY the JSON.
        """

        do {
            let response = try await ollamaClient.generate(
                model: nil, // Use default model configured in OllamaClient
                prompt: prompt,
                temperature: 0.7,
                maxTokens: 1000,
                useCache: true
            )

            let suggestions = parseAISuggestions(from: response)
            return suggestions.isEmpty ? nil : suggestions
        } catch {
            print("AI suggestion failed: \(error)")
            return nil
        }
    }

    private func parseAISuggestions(from response: String) -> [HabitSuggestion] {
        // Simple extraction of JSON block if nested in explanations
        let cleanedResponse: String = if let range = response.range(of: "\\[\\s*\\{", options: .regularExpression),
                                         let lastRange = response.range(
                                             of: "\\}\\s*\\]",
                                             options: [.regularExpression, .backwards]
                                         )
        {
            String(response[range.lowerBound...lastRange.upperBound])
        } else {
            response
        }

        guard let data = cleanedResponse.data(using: .utf8) else { return [] }

        struct AISuggestion: Decodable {
            let name: String
            let description: String
            let category: String
            let difficulty: String
            let reasoning: String
        }

        do {
            let rawSuggestions = try JSONDecoder().decode([AISuggestion].self, from: data)
            return rawSuggestions.map { raw in
                HabitSuggestion(
                    name: raw.name,
                    description: raw.description,
                    category: HabitCategory(rawValue: raw.category.lowercased()) ?? .other,
                    difficulty: HabitDifficulty(rawValue: raw.difficulty.lowercased()) ?? .medium,
                    reasoning: raw.reasoning,
                    expectedSuccess: 0.8 // Base success rate for AI-backed suggestions
                )
            }
        } catch {
            print("Failed to decode AI suggestions: \(error)")
            return []
        }
    }

    /// Generate suggestions based on user's existing habit categories
    func generateCategoryBasedSuggestions(profile: UserProfile) async -> [HabitSuggestion] {
        let prompt = "Suggest 2 habits based on these preferred categories: \(profile.preferredCategories.map(\.rawValue).joined(separator: ", ")). Return JSON list of {name, description, category, difficulty, reasoning}."
        return await generateAISuggestions(prompt: prompt) ?? []
    }

    /// Generate suggestions based on user's time patterns and availability
    func generateTimeBasedSuggestions(profile: UserProfile) async -> [HabitSuggestion] {
        let prompt = "Suggest 2 habits for someone whose peak productivity is at \(profile.peakProductivityHour):00. Return JSON list of {name, description, category, difficulty, reasoning}."
        return await generateAISuggestions(prompt: prompt) ?? []
    }

    /// Generate complementary habits that work well with existing ones
    func generateComplementarySuggestions(existing: [Habit]) async -> [HabitSuggestion] {
        let habitNames = existing.map(\.name).joined(separator: ", ")
        let prompt = "Suggest 2 habits that complement these existing ones: \(habitNames). Return JSON list of {name, description, category, difficulty, reasoning}."
        return await generateAISuggestions(prompt: prompt) ?? []
    }

    /// Generate trending habit suggestions based on current popular habits
    func generateTrendingSuggestions() async -> [HabitSuggestion] {
        let prompt = "Suggest 3 trending, high-impact habits for personal growth in 2026. Return JSON list of {name, description, category, difficulty, reasoning}."
        return await generateAISuggestions(prompt: prompt) ?? []
    }

    private func getRelatedCategories(for category: HabitCategory) -> [HabitCategory] {
        switch category {
        case .health:
            [.fitness]
        case .productivity:
            [.learning, .mindfulness]
        case .learning:
            [.productivity, .creativity]
        case .social:
            [.mindfulness]
        case .other:
            [.productivity]
        case .creativity:
            [.learning, .mindfulness]
        case .fitness:
            [.health]
        case .mindfulness:
            [.health, .productivity]
        }
    }
}

// MARK: - Supporting Types

struct UserProfile {
    let existingHabits: [Habit]
    let averageConsistency: Double
    let peakProductivityHour: Int
    let preferredCategories: [HabitCategory]
}
