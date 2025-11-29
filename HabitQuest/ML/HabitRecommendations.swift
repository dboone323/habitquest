import Foundation
import CoreML

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
        
        // Complementary habits
        let complementary = suggestComplementaryHabits(completionHistory)
        suggestions.append(contentsOf: complementary)
        
        // Popular habits among similar users (collaborative filtering)
        let collaborative = suggestCollaborativeHabits(completionHistory)
        suggestions.append(contentsOf: collaborative)
        
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
        let topCategories = successRates.prefix(3).map { $0.category }
        
        return CategoryPatternAnalysis(
            topCategories: Array(topCategories),
            successRates: Dictionary(uniqueKeysWithValues: successRates)
        )
    }
    
    // MARK: - Complementary Habits
    
    private func suggestComplementaryHabits(_ history: [HabitCompletion]) -> [MLHabitSuggestion] {
        let existingCategories = Set(history.map { $0.habitCategory })
        var suggestions: [MLHabitSuggestion] = []
        
        // Complementary pairs
        let pairs: [(String, String, String)] = [
            ("Exercise", "Meditation", "Balance fitness with mindfulness"),
            ("Reading", "Writing", "Complement input with output"),
            ("Learning", "Practice", "Apply what you learn"),
            ("Planning", "Execution", "Balance planning with action")
        ]
        
        for (category1, category2, reason) in pairs {
            if existingCategories.contains(category1) && !existingCategories.contains(category2) {
                suggestions.append(MLHabitSuggestion(
                    title: category2,
                    description: reason,
                    confidence: 0.7,
                    reason: .complementary
                ))
            }
        }
        
        return suggestions
    }
    
    // MARK: - Collaborative Filtering
    
    private func suggestCollaborativeHabits(_ history: [HabitCompletion]) -> [MLHabitSuggestion] {
        // Simulated collaborative filtering
        // In production, would query backend for similar user patterns
        let popularHabits = [
            "Drink Water": 0.85,
            "Morning Walk": 0.78,
            "Journal": 0.72,
            "Stretch": 0.69
        ]
        
        let existingHabits = Set(history.map { $0.habitName })
        
        return popularHabits.compactMap { name, confidence in
            if !existingHabits.contains(name) {
                return MLHabitSuggestion(
                    title: name,
                    description: "Popular among similar users",
                    confidence: confidence,
                    reason: .collaborative
                )
            }
            return nil
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
