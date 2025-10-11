//
// AIHabitRecommender.swift
// AI-powered habit recommendation service
//

import Foundation
import SwiftData

/// AI-powered service for generating personalized habit recommendations
public final class AIHabitRecommender {
    public static let shared = AIHabitRecommender()

    private let queue = DispatchQueue(label: "com.quantumworkspace.aihabit", qos: .userInitiated)

    private init() {}

    /// Generate personalized habit recommendations based on user data
    /// - Parameters:
    ///   - habits: User's current habits
    ///   - playerProfile: User's profile data
    ///   - completion: Callback with recommendations
    internal func generateRecommendations(
        habits: [Habit],
        playerProfile: PlayerProfile,
        completion: @escaping ([HabitRecommendation]) -> Void
    ) {
        queue.async {
            let recommendations = self.analyzeAndRecommend(habits: habits, playerProfile: playerProfile)
            DispatchQueue.main.async {
                completion(recommendations)
            }
        }
    }

    /// Analyze user patterns and generate recommendations
    private func analyzeAndRecommend(habits: [Habit], playerProfile: PlayerProfile) -> [HabitRecommendation] {
        var recommendations: [HabitRecommendation] = []

        // Analyze completion patterns
        let completionRates = analyzeCompletionPatterns(habits: habits)
        let successfulCategories = identifySuccessfulCategories(habits: habits)
        let timePatterns = analyzeTimePatterns(habits: habits)

        // Generate category-based recommendations
        recommendations.append(contentsOf: generateCategoryRecommendations(
            successfulCategories: successfulCategories,
            existingHabits: habits
        ))

        // Generate difficulty progression recommendations
        recommendations.append(contentsOf: generateDifficultyRecommendations(
            habits: habits,
            playerProfile: playerProfile
        ))

        // Generate timing-based recommendations
        recommendations.append(contentsOf: generateTimingRecommendations(
            timePatterns: timePatterns,
            habits: habits
        ))

        // Generate streak-building recommendations
        recommendations.append(contentsOf: generateStreakRecommendations(
            habits: habits,
            completionRates: completionRates
        ))

        // Limit to top 5 recommendations
        return Array(recommendations.sorted { $0.confidence > $1.confidence }.prefix(5))
    }

    /// Analyze completion patterns across habits
    private func analyzeCompletionPatterns(habits: [Habit]) -> [String: Double] {
        var completionRates: [String: (total: Int, completed: Int)] = [:]

        for habit in habits {
            let category = habit.category.rawValue
            let recentLogs = habit.logs.filter {
                $0.completionDate > Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            }

            let completed = recentLogs.filter { $0.isCompleted }.count
            let total = recentLogs.count

            if let existing = completionRates[category] {
                completionRates[category] = (existing.total + total, existing.completed + completed)
            } else {
                completionRates[category] = (total, completed)
            }
        }

        return completionRates.mapValues { rates in
            rates.total > 0 ? Double(rates.completed) / Double(rates.total) : 0.0
        }
    }

    /// Identify categories where user is most successful
    private func identifySuccessfulCategories(habits: [Habit]) -> [HabitCategory] {
        let completionRates = analyzeCompletionPatterns(habits: habits)
        return completionRates
            .filter { $0.value >= 0.7 } // 70%+ success rate
            .sorted { $0.value > $1.value }
            .compactMap { HabitCategory(rawValue: $0.key) }
    }

    /// Analyze when user is most active
    private func analyzeTimePatterns(habits: [Habit]) -> [Int: Int] {
        var hourCounts: [Int: Int] = [:]

        for habit in habits {
            for log in habit.logs where log.isCompleted {
                let hour = Calendar.current.component(.hour, from: log.completionTime ?? log.completionDate)
                hourCounts[hour, default: 0] += 1
            }
        }

        return hourCounts
    }

    /// Generate recommendations based on successful categories
    private func generateCategoryRecommendations(
        successfulCategories: [HabitCategory],
        existingHabits: [Habit]
    ) -> [HabitRecommendation] {
        let existingCategories = Set(existingHabits.map { $0.category })
        var recommendations: [HabitRecommendation] = []

        for category in successfulCategories where !existingCategories.contains(category) {
            let suggestion = generateHabitSuggestion(for: category)
            recommendations.append(HabitRecommendation(
                suggestedHabit: suggestion,
                reason: "Based on your success in \(category.rawValue) habits",
                confidence: 0.8,
                category: .categoryBased
            ))
        }

        return recommendations
    }

    /// Generate recommendations for difficulty progression
    private func generateDifficultyRecommendations(
        habits: [Habit],
        playerProfile: PlayerProfile
    ) -> [HabitRecommendation] {
        let easyHabits = habits.filter { $0.difficulty == .easy }
        let mediumHabits = habits.filter { $0.difficulty == .medium }

        // If user has successful easy habits, suggest medium difficulty
        if easyHabits.contains(where: { $0.streak >= 7 }) && mediumHabits.count < easyHabits.count {
            return [HabitRecommendation(
                suggestedHabit: generateHabitSuggestion(for: easyHabits.first?.category ?? .health, difficulty: .medium),
                reason: "You've mastered several easy habits - try a medium challenge",
                confidence: 0.7,
                category: .difficultyProgression
            )]
        }

        return []
    }

    /// Generate timing-based recommendations
    private func generateTimingRecommendations(
        timePatterns: [Int: Int],
        habits: [Habit]
    ) -> [HabitRecommendation] {
        guard let peakHour = timePatterns.max(by: { $0.value < $1.value })?.key else { return [] }

        let morningHabits = habits.filter { $0.frequency == .daily }
        if peakHour >= 6 && peakHour <= 10 && morningHabits.count < 2 {
            return [HabitRecommendation(
                suggestedHabit: HabitSuggestion(
                    name: "Morning Routine",
                    description: "Start your day with a consistent morning habit",
                    category: .health,
                    difficulty: .easy,
                    frequency: .daily
                ),
                reason: "You're most active in the morning - build on that momentum",
                confidence: 0.6,
                category: .timingBased
            )]
        }

        return []
    }

    /// Generate streak-building recommendations
    private func generateStreakRecommendations(
        habits: [Habit],
        completionRates: [String: Double]
    ) -> [HabitRecommendation] {
        let lowPerformingHabits = habits.filter { habit in
            let rate = completionRates[habit.category.rawValue] ?? 0.0
            return rate < 0.5 // Less than 50% completion rate
        }

        if !lowPerformingHabits.isEmpty {
            return [HabitRecommendation(
                suggestedHabit: HabitSuggestion(
                    name: "Streak Builder",
                    description: "A simple habit to help rebuild your momentum",
                    category: .productivity,
                    difficulty: .easy,
                    frequency: .daily
                ),
                reason: "Some habits need attention - start with something achievable",
                confidence: 0.9,
                category: .streakBuilding
            )]
        }

        return []
    }

    /// Generate a habit suggestion for a category
    private func generateHabitSuggestion(
        for category: HabitCategory,
        difficulty: HabitDifficulty = .easy
    ) -> HabitSuggestion {
        let suggestions = habitTemplates[category] ?? habitTemplates[.health]!
        let template = suggestions[Int.random(in: 0..<suggestions.count)]

        return HabitSuggestion(
            name: template.name,
            description: template.description,
            category: category,
            difficulty: difficulty,
            frequency: template.frequency
        )
    }

    /// Predefined habit templates for each category
    private let habitTemplates: [HabitCategory: [HabitTemplate]] = [
        .health: [
            HabitTemplate(name: "Drink Water", description: "Drink 8 glasses of water daily", frequency: .daily),
            HabitTemplate(name: "Healthy Breakfast", description: "Eat a nutritious breakfast", frequency: .daily),
            HabitTemplate(name: "Evening Walk", description: "Take a 20-minute walk in the evening", frequency: .daily)
        ],
        .fitness: [
            HabitTemplate(name: "Daily Exercise", description: "Complete 30 minutes of exercise", frequency: .daily),
            HabitTemplate(name: "Stretching Routine", description: "Do daily stretching exercises", frequency: .daily),
            HabitTemplate(name: "Step Goal", description: "Walk 10,000 steps per day", frequency: .daily)
        ],
        .learning: [
            HabitTemplate(name: "Read 30 Minutes", description: "Read for at least 30 minutes", frequency: .daily),
            HabitTemplate(name: "Learn New Skill", description: "Spend time learning something new", frequency: .daily),
            HabitTemplate(name: "Language Practice", description: "Practice a foreign language", frequency: .daily)
        ],
        .productivity: [
            HabitTemplate(name: "Morning Planning", description: "Plan your day every morning", frequency: .daily),
            HabitTemplate(name: "Task Prioritization", description: "Review and prioritize tasks", frequency: .daily),
            HabitTemplate(name: "Digital Detox", description: "Take breaks from screens", frequency: .daily)
        ],
        .social: [
            HabitTemplate(name: "Family Time", description: "Spend quality time with family", frequency: .daily),
            HabitTemplate(name: "Reach Out", description: "Contact a friend or family member", frequency: .daily),
            HabitTemplate(name: "Social Activity", description: "Participate in a social activity", frequency: .weekly)
        ],
        .creativity: [
            HabitTemplate(name: "Creative Writing", description: "Write creatively for 20 minutes", frequency: .daily),
            HabitTemplate(name: "Art Practice", description: "Practice your art form", frequency: .daily),
            HabitTemplate(name: "Music Time", description: "Play or listen to music mindfully", frequency: .daily)
        ],
        .mindfulness: [
            HabitTemplate(name: "Meditation", description: "Practice meditation for 10 minutes", frequency: .daily),
            HabitTemplate(name: "Gratitude Journal", description: "Write down 3 things you're grateful for", frequency: .daily),
            HabitTemplate(name: "Mindful Breathing", description: "Practice deep breathing exercises", frequency: .daily)
        ],
        .other: [
            HabitTemplate(name: "Personal Project", description: "Work on a personal project", frequency: .daily),
            HabitTemplate(name: "Hobby Time", description: "Dedicate time to your favorite hobby", frequency: .daily),
            HabitTemplate(name: "Skill Building", description: "Practice and improve a skill", frequency: .daily)
        ]
    ]
}

/// Template for habit suggestions
private struct HabitTemplate {
    let name: String
    let description: String
    let frequency: HabitFrequency
}

/// A recommended habit suggestion with reasoning
public struct HabitRecommendation {
    public let suggestedHabit: HabitSuggestion
    public let reason: String
    public let confidence: Double
    public let category: RecommendationCategory

    public enum RecommendationCategory {
        case categoryBased
        case difficultyProgression
        case timingBased
        case streakBuilding
    }
}

/// A suggested habit with all necessary details
public struct HabitSuggestion {
    public let name: String
    public let description: String
    public let category: HabitCategory
    public let difficulty: HabitDifficulty
    public let frequency: HabitFrequency
}
