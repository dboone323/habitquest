import Foundation
import SwiftData

/// Represents a single completion record (log) for a habit in HabitQuest.
/// Stores completion date, status, notes, XP earned, mood, and links to the associated habit.
@Model
public final class HabitLog {
    /// Unique identifier for the log entry.
    public var id: UUID
    /// The date this habit was completed (or attempted).
    public var completionDate: Date
    /// Whether the habit was completed successfully.
    public var isCompleted: Bool
    /// Optional notes about this completion.
    public var notes: String?
    /// XP earned for this completion (0 if not completed).
    public var xpEarned: Int
    /// Optional mood rating for this completion.
    public var mood: MoodRating?
    /// The exact time the habit was completed (if completed).
    public var completionTime: Date?

    /// The associated habit for this log entry.
    @Relationship public var habit: Habit?

    /// Initializes a new habit log entry.
    /// - Parameters:
    ///   - habit: The associated habit.
    ///   - completionDate: The date of completion (default: now).
    ///   - isCompleted: Whether the habit was completed (default: true).
    ///   - notes: Optional notes for this log.
    ///   - mood: Optional mood rating for this log.
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
        self.xpEarned =
            isCompleted
            ? habit.xpValue * habit.difficulty.xpMultiplier
            : 0
        self.mood = mood
        self.completionTime = isCompleted ? Date() : nil
    }
}

/// Mood rating for habit completion, used to track how the user felt after completing a habit.
public enum MoodRating: String, CaseIterable, Codable {
    case terrible = "😞"
    case bad = "😕"
    case okay = "😐"
    case neutral = "😑"
    case good = "😊"
    case excellent = "😄"

    /// Integer value for the mood rating (1 = worst, 5 = best).
    var value: Int {
        switch self {
        case .terrible: 1
        case .bad: 2
        case .okay: 3
        case .neutral: 3
        case .good: 4
        case .excellent: 5
        }
    }

    /// Human-readable description for the mood rating.
    var description: String {
        switch self {
        case .terrible: "Terrible"
        case .bad: "Bad"
        case .okay: "Okay"
        case .neutral: "Neutral"
        case .good: "Good"
        case .excellent: "Excellent"
        }
    }
}
