import Foundation
import SwiftData

/// Represents a single completion record for a habit
@Model
final class HabitLog {
    var id: UUID
    var completionDate: Date
    var isCompleted: Bool
    var notes: String?
    var xpEarned: Int
    var mood: MoodRating?
    var completionTime: Date?

    @Relationship var habit: Habit?

    init(
        habit: Habit,
        completionDate: Date = Date(),
        isCompleted: Bool = true,
        notes: String? = nil,
        mood: MoodRating? = nil
    ) {
        self.id = UUID()
        self.habit = habit
        self.completionDate = completionDate
        self.isCompleted = isCompleted
        self.notes = notes
        self.xpEarned = isCompleted
            ? habit.xpValue * habit.difficulty.xpMultiplier
            : 0
        self.mood = mood
        self.completionTime = isCompleted ? Date() : nil
    }
}

/// Mood rating for habit completion
enum MoodRating: String, CaseIterable, Codable {
    case terrible = "😞"
    case bad = "😕"
    case okay = "😐"
    case neutral = "😑"
    case good = "😊"
    case excellent = "😄"

    var value: Int {
        switch self {
        case .terrible: return 1
        case .bad: return 2
        case .okay: return 3
        case .neutral: return 3
        case .good: return 4
        case .excellent: return 5
        }
    }

    var description: String {
        switch self {
        case .terrible: return "Terrible"
        case .bad: return "Bad"
        case .okay: return "Okay"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }
}
