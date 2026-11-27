////
// HabitAnalyticsService.swift
// HabitQuestCore
////
// Unified service for habit data analysis focused on suggestion generation.
// Consolidated from legacy AdvancedAnalyticsEngine, TrendAnalysisService, and HabitSuggestionService.
//
//

import Foundation
import OSLog
import SwiftData

private let logger = Logger(subsystem: "com.habitquest.core", category: "HabitAnalyticsService")

/// Unified service for habit data analysis focused on generating suggestions.
/// Trimmed down from legacy analytics engines to only what the suggestion service needs.
@MainActor
public final class HabitAnalyticsService: Sendable {
    public init() {}

    // MARK: - Core Metrics for Suggestions

    /// Calculates the overall consistency score (0.0 - 1.0) across all habits.
    public func calculateOverallConsistency(habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0.0 }
        let totalRates = habits.reduce(0.0) { $0 + $1.completionRate }
        return totalRates / Double(habits.count)
    }

    /// Identifies the "Peak Discipline Hour" - the hour of day with the highest completion frequency.
    public func calculatePeakDisciplineHour(logs: [HabitLog]) -> Int? {
        let completedLogs = logs.filter(\.isCompleted)
        guard !completedLogs.isEmpty else { return nil }

        let hourCounts = completedLogs.reduce(into: [Int: Int]()) { counts, log in
            let hour = Calendar.current.component(.hour, from: log.completionDate)
            counts[hour, default: 0] += 1
        }

        return hourCounts.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - AI Suggestions (Heuristic fallback, no Ollama dependency)

    /// Generates personalized habit suggestions using behavioral analysis (heuristic, no AI).
    public func generateHabitSuggestions(habits: [Habit], logs: [HabitLog]) async -> [HabitSuggestion] {
        _ = calculateOverallConsistency(habits: habits)
        let peakHour = calculatePeakDisciplineHour(logs: logs) ?? 9
        let existingCategories = Set(habits.map(\.category))

        var suggestions: [HabitSuggestion] = []

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
                reasoning: "Consistent knowledge building compounds over time.",
                expectedSuccess: 0.75
            ))
        }

        if peakHour >= 6 && peakHour < 12 && !existingCategories.contains(.productivity) {
            suggestions.append(HabitSuggestion(
                name: "Morning Planning",
                description: "Plan your top 3 priorities for the day.",
                category: .productivity,
                difficulty: .easy,
                reasoning: "Starting the day with clear priorities increases follow-through.",
                expectedSuccess: 0.85
            ))
        }

        return suggestions
    }

    // MARK: - Heuristic Suggestions (AI-free fallback)

    /// Generates basic heuristic suggestions when AI is unavailable.
    public func generateHeuristicSuggestions(habits: [Habit]) -> [HabitSuggestion] {
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
                reasoning: "Consistent knowledge building compounds over time.",
                expectedSuccess: 0.75
            ))
        }

        return suggestions
    }
}
