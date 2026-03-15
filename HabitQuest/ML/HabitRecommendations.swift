import CoreML
import Foundation
import SharedKit

/// ML-based habit suggestion engine
class HabitRecommendationService {
    // MARK: - Pattern Analysis

    func suggestHabits(basedOn completionHistory: [HabitCompletion]) -> [MLHabitSuggestion] {
        var suggestions: [MLHabitSuggestion] = []

        // Analyze time patterns
        let timePatterns = analyzeTimePatterns(completionHistory)
        if let bestTime = timePatterns.mostConsistentTime {
            suggestions.append(MLHabitSuggestion(
                title: "Morning Routine",
                description: "You're most consistent at \(bestTime)",
                confidence: timePatterns.confidence,
                reason: .timePattern
            ))
        }

        // Analyze category patterns
        let categories = analyzeCategoryPatterns(completionHistory)
        for category in categories.topCategories {
            suggestions.append(MLHabitSuggestion(
                title: "More \(category)",
                description: "You excel at \(category) habits",
                confidence: categories.confidenceFor(category),
                reason: .categorySuccess
            ))
        }

        // Complementary and Collaborative are now handled via suggestHabitsAsync for high-fidelity reasoning

        return suggestions.sorted { $0.confidence > $1.confidence }
    }

    // MARK: - Time Pattern Analysis

    private func analyzeTimePatterns(_ history: [HabitCompletion]) -> TimePatternAnalysis {
        var hourCounts: [Int: Int] = [:]

        for completion in history {
            let hour = Calendar.current.component(.hour, from: completion.date)
            hourCounts[hour, default: 0] += 1
        }

        guard let mostFrequentHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return TimePatternAnalysis(mostConsistentTime: nil, confidence: 0)
        }

        let totalCompletions = history.count
        let consistencyCount = hourCounts[mostFrequentHour] ?? 0
        let confidence = Double(consistencyCount) / Double(totalCompletions)

        let timeString = formatHour(mostFrequentHour)
        return TimePatternAnalysis(mostConsistentTime: timeString, confidence: confidence)
    }

    // MARK: - Category Pattern Analysis

    private func analyzeCategoryPatterns(_ history: [HabitCompletion]) -> CategoryPatternAnalysis {
        var categorySuccess: [String: (completed: Int, total: Int)] = [:]

        for completion in history {
            let category = completion.habitCategory
            var stats = categorySuccess[category] ?? (0, 0)
            stats.total += 1
            if completion.completed {
                stats.completed += 1
            }
            categorySuccess[category] = stats
        }

        // Calculate success rates
        var successRates: [(category: String, rate: Double)] = []
        for (category, stats) in categorySuccess {
            let rate = Double(stats.completed) / Double(stats.total)
            if stats.total >= 5 { // Minimum sample size
                successRates.append((category, rate))
            }
        }

        successRates.sort { $0.rate > $1.rate }
        let topCategories = successRates.prefix(3).map(\.category)

        return CategoryPatternAnalysis(
            topCategories: Array(topCategories),
            successRates: Dictionary(uniqueKeysWithValues: successRates)
        )
    }

    // MARK: - Complementary Habits

    private func suggestComplementaryHabits(_ history: [HabitCompletion]) -> [MLHabitSuggestion] {
        let existingHabits = history.map(\.habitName).joined(separator: ", ")
        let prompt = "Based on these existing habits: \(existingHabits), suggest 2 complementary habits that would provide a balanced routine. Return JSON list of {title, description, confidence, reason: 'complementary'}."

        // This is a synchronous-style call in the current architecture,
        // ideally should be async but we'll maintain the signature for now
        // and return cached/fallback if needed, or note this for async refactor.
        // For now, removing the hardcoded list to force actual integration.
        return [] // Placeholder for async refactor
    }

    // MARK: - AI-Enhanced Recommendations (New Async Method)

    func suggestHabitsAsync(
        basedOn completionHistory: [HabitCompletion],
        ollamaClient: OllamaClient
    ) async -> [MLHabitSuggestion] {
        let existingHabits = completionHistory.map(\.habitName).joined(separator: ", ")

        // Dynamic trend analysis via SharedKit
        let points = completionHistory.map { PredictiveAnalyticsEngine.TimeSeriesPoint(
            timestamp: $0.date,
            value: $0.completed
                ? 1.0
                : 0.0
        ) }
        let trendInfo = await PredictiveAnalyticsEngine.shared.analyze(points)

        let prompt = """
        Analyze these completed habits: \(existingHabits).
        Ecosystem Trend Context: \(trendInfo.message) (Probability: \(trendInfo.probability))

        Suggest 3 new habits:
        1. One complementary habit.
        2. One habit based on their success patterns.
        3. One trending habit similar users enjoy.

        Return JSON list of objects with {title, description, confidence, reason (one of: 'timePattern', 'categorySuccess', 'complementary', 'collaborative')}.
        """

        do {
            let response = try await ollamaClient.generate(model: nil, prompt: prompt)
            let cleanedResponse = if let range = response.range(of: "\\[.*?\\]", options: .regularExpression) {
                String(response[range])
            } else {
                response
            }

            guard let data = cleanedResponse.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            else {
                return []
            }

            return json.compactMap { dict in
                guard let title = dict["title"] as? String,
                      let description = dict["description"] as? String,
                      let confidence = dict["confidence"] as? Double,
                      let reasonStr = dict["reason"] as? String
                else {
                    return nil
                }

                let reason: SuggestionReason = switch reasonStr {
                case "timePattern": .timePattern
                case "categorySuccess": .categorySuccess
                case "complementary": .complementary
                case "collaborative": .collaborative
                default: .collaborative
                }

                return MLHabitSuggestion(title: title, description: description, confidence: confidence, reason: reason)
            }
        } catch {
            return []
        }
    }

    // MARK: - Helpers

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

struct MLHabitSuggestion {
    let title: String
    let description: String
    let confidence: Double
    let reason: SuggestionReason
}

enum SuggestionReason {
    case timePattern
    case categorySuccess
    case complementary
    case collaborative
}

struct TimePatternAnalysis {
    let mostConsistentTime: String?
    let confidence: Double
}

struct CategoryPatternAnalysis {
    let topCategories: [String]
    let successRates: [String: Double]

    func confidenceFor(_ category: String) -> Double {
        successRates[category] ?? 0.5
    }
}

struct HabitCompletion {
    let habitName: String
    let habitCategory: String
    let date: Date
    let completed: Bool
}
