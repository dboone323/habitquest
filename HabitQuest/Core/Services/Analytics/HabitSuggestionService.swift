import Foundation
import SwiftData

/// Service responsible for generating personalized habit suggestions using ML and behavioral analysis
final class HabitSuggestionService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generate personalized habit suggestions using ML
    func generateHabitSuggestions() async -> [HabitSuggestion] {
        let existingHabits = await fetchAllHabits()
        let userProfile = await analyzeUserProfile(from: existingHabits)

        return [
            generateCategoryBasedSuggestions(profile: userProfile),
            generateTimeBasedSuggestions(profile: userProfile),
            generateComplementarySuggestions(existing: existingHabits),
            generateTrendingSuggestions(),
        ].flatMap(\.self)
    }

    /// Generate suggestions based on user's existing habit categories
    func generateCategoryBasedSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []

        // Analyze category gaps
        let existingCategories = Set(profile.existingHabits.map(\.category))
        let suggestedCategories: [HabitCategory] = [.health, .productivity, .learning, .social, .other, .creativity]

        for category in suggestedCategories where !existingCategories.contains(category) {
            if let suggestion = createCategorySuggestion(for: category, profile: profile) {
                suggestions.append(suggestion)
            }
        }

        return suggestions
    }

    /// Generate suggestions based on user's time patterns and availability
    func generateTimeBasedSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []

        // Analyze peak productivity times
        let peakHour = profile.peakProductivityHour
        let timeOfDay = peakHour < 12 ? "morning" : peakHour < 17 ? "afternoon" : "evening"

        // Suggest habits that align with peak times
        switch timeOfDay {
        case "morning":
            suggestions.append(HabitSuggestion(
                name: "Morning Meditation",
                description: "Start your day with 10 minutes of mindfulness meditation",
                category: .mindfulness,
                difficulty: .easy,
                reasoning: "Morning routines build strong foundations for the day",
                expectedSuccess: 0.85
            ))
        case "afternoon":
            suggestions.append(HabitSuggestion(
                name: "Afternoon Walk",
                description: "Take a 15-minute walk to recharge and boost creativity",
                category: .fitness,
                difficulty: .easy,
                reasoning: "Afternoon activity combats post-lunch energy dips",
                expectedSuccess: 0.8
            ))
        case "evening":
            suggestions.append(HabitSuggestion(
                name: "Evening Reflection",
                description: "Spend 10 minutes reflecting on your day and planning tomorrow",
                category: .productivity,
                difficulty: .easy,
                reasoning: "Evening reflection improves planning and sleep quality",
                expectedSuccess: 0.75
            ))
        default:
            break
        }

        return suggestions
    }

    /// Generate complementary habits that work well with existing ones
    func generateComplementarySuggestions(existing: [Habit]) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []

        // Analyze existing habits for complementary suggestions
        let categories = Dictionary(grouping: existing, by: \.category)

        // Health habits - suggest complementary wellness activities
        if categories[.health] != nil {
            suggestions.append(HabitSuggestion(
                name: "Healthy Meal Prep",
                description: "Prepare nutritious meals for the week ahead",
                category: .health,
                difficulty: .medium,
                reasoning: "Complements existing health habits with nutrition focus",
                expectedSuccess: 0.7
            ))
        }

        // Productivity habits - suggest focus enhancement
        if categories[.productivity] != nil {
            suggestions.append(HabitSuggestion(
                name: "Deep Work Session",
                description: "Dedicate 90 minutes of uninterrupted focused work",
                category: .productivity,
                difficulty: .hard,
                reasoning: "Builds on existing productivity habits with deeper focus",
                expectedSuccess: 0.8
            ))
        }

        // Learning habits - suggest application of knowledge
        if categories[.learning] != nil {
            suggestions.append(HabitSuggestion(
                name: "Knowledge Application",
                description: "Apply what you've learned to a practical project",
                category: .learning,
                difficulty: .medium,
                reasoning: "Enhances learning by applying knowledge practically",
                expectedSuccess: 0.75
            ))
        }

        return suggestions
    }

    /// Generate trending habit suggestions based on current popular habits
    func generateTrendingSuggestions() -> [HabitSuggestion] {
        // These would be updated based on trending data
        // For now, return some evergreen popular habits
        [
            HabitSuggestion(
                name: "Digital Detox Hour",
                description: "Spend one hour each evening without screens",
                category: .health,
                difficulty: .medium,
                reasoning: "Popular habit for better sleep and mental health",
                expectedSuccess: 0.9
            ),
            HabitSuggestion(
                name: "Gratitude Journaling",
                description: "Write down 3 things you're grateful for each day",
                category: .mindfulness,
                difficulty: .easy,
                reasoning: "Trending practice for improved mental wellbeing",
                expectedSuccess: 0.85
            ),
            HabitSuggestion(
                name: "Skill Building",
                description: "Learn a new skill for 30 minutes daily",
                category: .learning,
                difficulty: .medium,
                reasoning: "Highly popular for personal and professional growth",
                expectedSuccess: 0.8
            ),
        ]
    }

    /// Generate habit stacking suggestions based on existing routines
    func generateHabitStackingSuggestions(existing: [Habit]) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []

        // Find habits that could serve as anchors for stacking
        let morningHabits = existing.filter { habit in
            habit.logs.contains { log in
                Calendar.current.component(.hour, from: log.completionDate) < 10
            }
        }

        let eveningHabits = existing.filter { habit in
            habit.logs.contains { log in
                Calendar.current.component(.hour, from: log.completionDate) > 18
            }
        }

        // Suggest stacking on morning routines
        if !morningHabits.isEmpty {
            suggestions.append(HabitSuggestion(
                name: "Morning Affirmations",
                description: "Add positive affirmations to your existing morning routine",
                category: .mindfulness,
                difficulty: .easy,
                reasoning: "Stacks well with existing morning habits",
                expectedSuccess: 0.7
            ))
        }

        // Suggest stacking on evening routines
        if !eveningHabits.isEmpty {
            suggestions.append(HabitSuggestion(
                name: "Evening Review",
                description: "Review your day while doing your evening routine",
                category: .productivity,
                difficulty: .easy,
                reasoning: "Enhances existing evening routines with reflection",
                expectedSuccess: 0.75
            ))
        }

        return suggestions
    }

    /// Generate challenge-based suggestions for advanced users
    func generateChallengeSuggestions(profile: UserProfile) -> [HabitSuggestion] {
        var suggestions: [HabitSuggestion] = []

        // Only suggest challenges for users with good consistency
        guard profile.averageConsistency > 0.7 else { return suggestions }

        suggestions.append(HabitSuggestion(
            name: "30-Day Challenge",
            description: "Take on a challenging habit for a full month",
            category: .other,
            difficulty: .hard,
            reasoning: "Advanced challenge for experienced habit builders",
            expectedSuccess: 0.6
        ))

        return suggestions
    }

    // MARK: - Private Helper Methods

    private func fetchAllHabits() async -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func analyzeUserProfile(from habits: [Habit]) async -> UserProfile {
        let totalCompletions = habits.reduce(0) { $0 + $1.logs.filter(\.isCompleted).count }
        let totalLogs = habits.reduce(0) { $0 + $1.logs.count }
        let averageConsistency = totalLogs > 0 ? Double(totalCompletions) / Double(totalLogs) : 0.0

        // Calculate peak productivity hour
        var hourCounts: [Int: Int] = [:]
        for habit in habits {
            for log in habit.logs where log.isCompleted {
                let hour = Calendar.current.component(.hour, from: log.completionDate)
                hourCounts[hour, default: 0] += 1
            }
        }
        let peakHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 9

        return UserProfile(
            existingHabits: habits,
            averageConsistency: averageConsistency,
            peakProductivityHour: peakHour,
            preferredCategories: Dictionary(grouping: habits, by: \.category).keys.map(\.self)
        )
    }

    private func createCategorySuggestion(for category: HabitCategory, profile: UserProfile) -> HabitSuggestion? {
        // Only suggest if user has shown interest in related categories
        let relatedCategories = getRelatedCategories(for: category)
        let hasRelatedHabits = profile.preferredCategories.contains { relatedCategories.contains($0) }

        guard hasRelatedHabits || profile.existingHabits.count >= 3 else { return nil }

        switch category {
        case .health:
            return HabitSuggestion(
                name: "Daily Hydration",
                description: "Drink 8 glasses of water throughout the day",
                category: .health,
                difficulty: .easy,
                reasoning: "Essential health habit that complements other wellness activities",
                expectedSuccess: 0.8
            )
        case .productivity:
            return HabitSuggestion(
                name: "Task Prioritization",
                description: "Spend 10 minutes each morning prioritizing your tasks",
                category: .productivity,
                difficulty: .easy,
                reasoning: "Fundamental productivity skill that improves daily effectiveness",
                expectedSuccess: 0.75
            )
        case .learning:
            return HabitSuggestion(
                name: "Daily Reading",
                description: "Read for 20 minutes to expand your knowledge",
                category: .learning,
                difficulty: .easy,
                reasoning: "Consistent reading builds knowledge and mental stimulation",
                expectedSuccess: 0.7
            )
        case .social:
            return HabitSuggestion(
                name: "Quality Connection",
                description: "Have a meaningful conversation with someone you care about",
                category: .social,
                difficulty: .medium,
                reasoning: "Strengthens relationships and provides social support",
                expectedSuccess: 0.65
            )
        case .other:
            return HabitSuggestion(
                name: "Expense Tracking",
                description: "Track all expenses for better financial awareness",
                category: .other,
                difficulty: .easy,
                reasoning: "Essential financial awareness for better money management",
                expectedSuccess: 0.7
            )
        case .creativity:
            return HabitSuggestion(
                name: "Creative Expression",
                description: "Spend 15 minutes on a creative activity you enjoy",
                category: .creativity,
                difficulty: .easy,
                reasoning: "Regular creative practice enhances overall wellbeing",
                expectedSuccess: 0.75
            )
        case .fitness:
            return HabitSuggestion(
                name: "Regular Exercise",
                description: "Engage in physical activity for at least 30 minutes",
                category: .fitness,
                difficulty: .medium,
                reasoning: "Regular exercise improves physical and mental health",
                expectedSuccess: 0.7
            )
        case .mindfulness:
            return HabitSuggestion(
                name: "Mindful Breathing",
                description: "Practice deep breathing exercises for 5 minutes daily",
                category: .mindfulness,
                difficulty: .easy,
                reasoning: "Mindfulness practices reduce stress and improve focus",
                expectedSuccess: 0.8
            )
        }
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
