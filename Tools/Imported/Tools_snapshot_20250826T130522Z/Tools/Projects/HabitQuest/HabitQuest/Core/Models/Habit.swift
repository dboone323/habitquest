import Foundation
import SwiftData

/// Represents a single habit or "quest" that the user wants to track
@Model
final class Habit {
    /// Unique identifier for the habit
    var id: UUID

    /// Display name of the habit
    var name: String

    /// Detailed description of what the habit involves
    var habitDescription: String

    /// How often this habit should be completed
    var frequency: HabitFrequency

    /// When this habit was first created
    var creationDate: Date

    /// Experience points awarded when this habit is completed
    var xpValue: Int

    /// Current consecutive completion streak for this habit
    var streak: Int

    /// Indicates if the habit is currently active
    var isActive: Bool

    /// Category of the habit (e.g., health, fitness, learning)
    var category: HabitCategory

    /// Difficulty level of the habit
    var difficulty: HabitDifficulty

    /// All completion records for this habit (one-to-many relationship)
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog] = []

    /// Initialize a new habit
    /// - Parameters:
    ///   - name: The name of the habit
    ///   - habitDescription: Description of the habit
    ///   - frequency: How often the habit should be completed
    ///   - xpValue: Experience points awarded for completion (default: 10)
    ///   - category: The category of the habit (default: health)
    ///   - difficulty: The difficulty level of the habit (default: easy)
    init(
        name: String,
        habitDescription: String,
        frequency: HabitFrequency,
        xpValue: Int = 10,
        category: HabitCategory = .health,
        difficulty: HabitDifficulty = .easy
    ) {
        self.id = UUID()
        self.name = name
        self.habitDescription = habitDescription
        self.frequency = frequency
        self.creationDate = Date()
        self.xpValue = xpValue
        self.streak = 0
        self.isActive = true
        self.category = category
        self.difficulty = difficulty
    }

    /// Check if habit was completed today
    var isCompletedToday: Bool {
        guard let todaysLog = logs.first(where: { Calendar.current.isDateInToday($0.completionDate) }) else {
            return false
        }
        return todaysLog.isCompleted
    }

    /// Get completion rate for the last 30 days
    var completionRate: Double {
        let thirtyDaysAgo = Calendar.current.date(
            byAdding: .day,
            value: -30,
            to: Date()
        ) ?? Date()

        let recentLogs = logs.filter { $0.completionDate >= thirtyDaysAgo }

        guard !recentLogs.isEmpty else { return 0.0 }

        let completedCount = recentLogs.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(recentLogs.count)
    }
}

/// Defines how frequently a habit should be completed
enum HabitFrequency: String, CaseIterable, Codable {
    case daily
    case weekly
    case custom

    /// Display name for the frequency
    var displayName: String {
        return self.rawValue
    }
}

/// Defines categories for habits
enum HabitCategory: String, CaseIterable, Codable {
    case health
    case fitness
    case learning
    case productivity
    case social
    case creativity
    case mindfulness
    case other

    /// Emoji representation for each category
    var emoji: String {
        switch self {
        case .health: return "🏥"
        case .fitness: return "🏋️‍♀️"
        case .learning: return "📚"
        case .productivity: return "💼"
        case .social: return "👥"
        case .creativity: return "🎨"
        case .mindfulness: return "🧘‍♀️"
        case .other: return "📋"
        }
    }

    /// Color representation for each category
    var color: String {
        switch self {
        case .health: return "red"
        case .fitness: return "orange"
        case .learning: return "blue"
        case .productivity: return "green"
        case .social: return "purple"
        case .creativity: return "yellow"
        case .mindfulness: return "indigo"
        case .other: return "gray"
        }
    }
}

/// Defines difficulty levels for habits
enum HabitDifficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard

    /// Experience point multiplier based on difficulty
    var xpMultiplier: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}
