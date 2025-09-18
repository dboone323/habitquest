import Foundation
import SwiftData

/// Represents a single habit or "quest" that the user wants to track
@Model
public final class Habit {
    /// Unique identifier for the habit
    public var id: UUID

    /// Display name of the habit
    public var name: String

    /// Detailed description of what the habit involves
    public var habitDescription: String

    /// How often this habit should be completed
    public var frequency: HabitFrequency

    /// When this habit was first created
    public var creationDate: Date

    /// Experience points awarded when this habit is completed
    public var xpValue: Int

    /// Current consecutive completion streak for this habit
    public var streak: Int

    /// Indicates if the habit is currently active
    public var isActive: Bool

    /// Category of the habit (e.g., health, fitness, learning)
    public var category: HabitCategory

    /// Difficulty level of the habit
    public var difficulty: HabitDifficulty

    /// All completion records for this habit (one-to-many relationship)
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    public var logs: [HabitLog] = []

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
        guard
            let todaysLog = logs.first(where: { Calendar.current.isDateInToday($0.completionDate) })
        else {
            return false
        }
        return todaysLog.isCompleted
    }

    /// Get completion rate for the last 30 days
    var completionRate: Double {
        let thirtyDaysAgo =
            Calendar.current.date(
                byAdding: .day,
                value: -30,
                to: Date()
            ) ?? Date()

        let recentLogs = self.logs.filter { $0.completionDate >= thirtyDaysAgo }

        guard !recentLogs.isEmpty else { return 0.0 }

        let completedCount = recentLogs.count(where: { $0.isCompleted })
        return Double(completedCount) / Double(recentLogs.count)
    }
}

/// Defines how frequently a habit should be completed
public enum HabitFrequency: String, CaseIterable, Codable {
    case daily
    case weekly
    case custom

    /// Display name for the frequency
    var displayName: String {
        self.rawValue
    }
}

/// Defines categories for habits
public enum HabitCategory: String, CaseIterable, Codable {
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
        case .health: "🏥"
        case .fitness: "🏋️‍♀️"
        case .learning: "📚"
        case .productivity: "💼"
        case .social: "👥"
        case .creativity: "🎨"
        case .mindfulness: "🧘‍♀️"
        case .other: "📋"
        }
    }

    /// Color representation for each category
    var color: String {
        switch self {
        case .health: "red"
        case .fitness: "orange"
        case .learning: "blue"
        case .productivity: "green"
        case .social: "purple"
        case .creativity: "yellow"
        case .mindfulness: "indigo"
        case .other: "gray"
        }
    }
}

/// Defines difficulty levels for habits
public enum HabitDifficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard

    /// Experience point multiplier based on difficulty
    nonisolated var xpMultiplier: Int {
        switch self {
        case .easy: 1
        case .medium: 2
        case .hard: 3
        }
    }
}
