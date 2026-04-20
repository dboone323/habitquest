//
// HabitAnalyticsService.swift
// HabitQuestCore
//

import Foundation
import SwiftData
import SharedKit
import OSLog

private let logger = Logger(subsystem: "com.habitquest.core", category: "HabitAnalyticsService")

/// Unified service for habit data analysis, pattern recognition, and suggestions.
/// Consolidated from legacy AdvancedAnalyticsEngine, TrendAnalysisService, and HabitSuggestionService.
@MainActor
public final class HabitAnalyticsService: Sendable {
    private let ollamaClient: OllamaClient

    public init(ollamaClient: OllamaClient = OllamaClient()) {
        self.ollamaClient = ollamaClient
    }

    // MARK: - Core Metrics

    /// Calculates the overall consistency score (0.0 - 1.0) across all habits.
    public func calculateOverallConsistency(habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0.0 }
        let totalRates = habits.reduce(0.0) { $0 + $1.completionRate }
        return totalRates / Double(habits.count)
    }

    /// Identifies the "Peak Discipline Hour" - the hour of day with the highest completion frequency.
    public func calculatePeakDisciplineHour(logs: [HabitLog]) -> Int? {
        let completedLogs = logs.filter { $0.isCompleted }
        guard !completedLogs.isEmpty else { return nil }

        let hourCounts = completedLogs.reduce(into: [Int: Int]()) { counts, log in
            let hour = Calendar.current.component(.hour, from: log.completionDate)
            counts[hour, default: 0] += 1
        }

        return hourCounts.max(by: { $0.value < $1.value })?.key
    }

    /// Analyzes a set of habits and their history to create a user behavior profile.
    public func analyzeUserProfile(habits: [Habit]) -> UserProfile {
        let consistency = calculateOverallConsistency(habits: habits)
        // For simplicity, we assume yesterday's/today's logs for peak hour if not provided
        let allLogs = habits.flatMap { $0.logs }
        let peakHour = calculatePeakDisciplineHour(logs: allLogs) ?? 9
        
        let preferredCategories = Array(Set(habits.map(\.category)))
        
        return UserProfile(
            existingHabits: habits,
            averageConsistency: consistency,
            peakProductivityHour: peakHour,
            preferredCategories: preferredCategories
        )
    }

    // MARK: - Habit Insights & Trends

    /// Generates high-level behavioral insights based on habit completion patterns.
    public func generateInsights(habits: [Habit], logs: [HabitLog]) -> [HabitInsight] {
        var insights: [HabitInsight] = []

        // 1. Momentum Insight
        let overallConsistency = calculateOverallConsistency(habits: habits)
        if overallConsistency > 0.8 {
            insights.append(HabitInsight(
                title: "Unstoppable Momentum",
                description: "You're completing over 80% of your habits consistently.",
                impact: .positive,
                suggestion: "Consider increasing the difficulty of your most consistent habits."
            ))
        }

        // 2. Discipline Pattern Insight
        if let peakHour = calculatePeakDisciplineHour(logs: logs) {
            let period = peakHour < 12 ? "morning" : (peakHour < 17 ? "afternoon" : "evening")
            insights.append(HabitInsight(
                title: "\(period.capitalized) Powerhouse",
                description: "Your peak completion time is around \(peakHour):00.",
                impact: .neutral,
                suggestion: "Try scheduling harder habits during this highly disciplined window."
            ))
        }

        // 3. Category Balance Insight
        let categories = Set(habits.map(\.category))
        if categories.count < 3 && habits.count > 5 {
            insights.append(HabitInsight(
                title: "Focused Growth",
                description: "Most of your habits are concentrated in a few areas.",
                impact: .neutral,
                suggestion: "Explore habits in new categories for more holistic development."
            ))
        }

        return insights
    }

    // MARK: - AI Suggestions (Ollama Integration)

    /// Generates personalized habit suggestions using AI analysis of existing patterns.
    public func generateHabitSuggestions(habits: [Habit], logs: [HabitLog]) async -> [HabitSuggestion] {
        let habitNames = habits.map(\.name).joined(separator: ", ")
        let consistency = calculateOverallConsistency(habits: habits)
        let peakHour = calculatePeakDisciplineHour(logs: logs) ?? 9

        let prompt = """
        User has the following habits: \(habitNames).
        Overall consistency: \(String(format: "%.0f%%", consistency * 100)).
        Peak discipline hour: \(peakHour):00.
        Generate 3 personalized habit suggestions in valid JSON format.
        Each object must have: "name", "description", "category", "difficulty", "reasoning", "expectedSuccess".
        Return ONLY the JSON.
        """

        do {
            let response = try await ollamaClient.generate(
                model: nil,
                prompt: prompt,
                temperature: 0.7
            )
            return parseAISuggestions(from: response)
        } catch {
            logger.error("AI suggestion failed: \(error.localizedDescription)")
            return generateHeuristicSuggestions(habits: habits)
        }
    }

    private func parseAISuggestions(from response: String) -> [HabitSuggestion] {
        // Simple extraction of JSON block
        let pattern = "\\[\\s*\\{.*\\}\\s*\\]"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let nsRange = NSRange(response.startIndex..<response.endIndex, in: response)
        
        guard let match = regex?.firstMatch(in: response, options: [], range: nsRange),
              let range = Range(match.range, in: response),
              let data = String(response[range]).data(using: .utf8) else {
            return []
        }


        struct AISuggestion: Decodable {
            let name: String
            let description: String
            let category: String
            let difficulty: String
            let reasoning: String
            let expectedSuccess: Double
        }

        do {
            let raw = try JSONDecoder().decode([AISuggestion].self, from: data)
            return raw.map { item in
                HabitSuggestion(
                    name: item.name,
                    description: item.description,
                    category: HabitCategory(rawValue: item.category.lowercased()) ?? .other,
                    difficulty: HabitDifficulty(rawValue: item.difficulty.lowercased()) ?? .medium,
                    reasoning: item.reasoning,
                    expectedSuccess: item.expectedSuccess
                )
            }
        } catch {
            logger.error("Failed to decode AI suggestions: \(error.localizedDescription)")
            return []
        }
    }

    /// Fallback logic for generating suggestions when AI is unavailable.
    private func generateHeuristicSuggestions(habits: [Habit]) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []
        let existingCategories = Set(habits.map(\.category))

        if !existingCategories.contains(.mindfulness) {
            suggestions.append(HabitSuggestion(
                name: "Short Meditation",
                description: "5 minutes of mindful breathing.",
                category: .mindfulness,
                difficulty: .easy,
                reasoning: "High impact on overall focus with minimal daily effort.",
                expectedSuccess: 0.9
            ))
        }

        if !existingCategories.contains(.learning) {
            suggestions.append(HabitSuggestion(
                name: "Read 10 Pages",
                description: "Read a non-fiction book daily.",
                category: .learning,
                difficulty: .medium,
                reasoning: "Consistent knowledge building compound over time.",
                expectedSuccess: 0.75
            ))
        }

        return suggestions
    }
}
