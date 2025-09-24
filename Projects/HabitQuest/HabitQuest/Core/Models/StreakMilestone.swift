import Foundation

/// Represents a streak milestone achievement
public struct StreakMilestone: Identifiable, @unchecked Sendable {
    public let id: UUID
    let streakCount: Int
    let title: String
    let description: String
    let emoji: String
    let celebrationLevel: CelebrationLevel

    init(streakCount: Int, title: String, description: String, emoji: String, celebrationLevel: CelebrationLevel) {
        self.id = UUID()
        self.streakCount = streakCount
        self.title = title
        self.description = description
        self.emoji = emoji
        self.celebrationLevel = celebrationLevel
    }

    enum CelebrationLevel: Int, CaseIterable, Codable {
        case basic = 1
        case intermediate = 2
        case advanced = 3
        case epic = 4
        case legendary = 5

        var animationIntensity: Double {
            switch self {
            case .basic: 0.5
            case .intermediate: 0.7
            case .advanced: 0.9
            case .epic: 1.2
            case .legendary: 1.5
            }
        }

        var particleCount: Int {
            switch self {
            case .basic: 10
            case .intermediate: 20
            case .advanced: 35
            case .epic: 50
            case .legendary: 100
            }
        }
    }

    /// Predefined milestone definitions
    static let predefinedMilestones: [StreakMilestone] = [
        StreakMilestone(
            streakCount: 3,
            title: "Getting Started",
            description: "3 days in a row! You're building momentum.",
            emoji: "🔥",
            celebrationLevel: .basic
        ),
        StreakMilestone(
            streakCount: 7,
            title: "One Week Warrior",
            description: "A full week of dedication! You're on fire!",
            emoji: "🔥🔥",
            celebrationLevel: .intermediate
        ),
        StreakMilestone(
            streakCount: 14,
            title: "Two Week Champion",
            description: "Two weeks strong! Your habit is becoming routine.",
            emoji: "🔥🔥",
            celebrationLevel: .intermediate
        ),
        StreakMilestone(
            streakCount: 30,
            title: "Monthly Master",
            description: "30 days of consistency! You're a true habit master.",
            emoji: "🔥🔥🔥",
            celebrationLevel: .advanced
        ),
        StreakMilestone(
            streakCount: 50,
            title: "Halfway Hero",
            description: "50 days! You're halfway to the legendary 100!",
            emoji: "🔥🔥🔥",
            celebrationLevel: .advanced
        ),
        StreakMilestone(
            streakCount: 100,
            title: "Century Streak",
            description: "100 days! This is truly exceptional dedication.",
            emoji: "🔥🔥🔥🔥",
            celebrationLevel: .epic
        ),
        StreakMilestone(
            streakCount: 365,
            title: "Year Long Legend",
            description: "365 days! You are a legend among legends!",
            emoji: "🔥🔥🔥🔥🔥",
            celebrationLevel: .legendary
        )
    ]

    /// Get the milestone for a specific streak count
    static func milestone(for streakCount: Int) -> StreakMilestone? {
        self.predefinedMilestones
            .filter { $0.streakCount <= streakCount }
            .max(by: { $0.streakCount < $1.streakCount })
    }

    /// Get the next milestone to achieve
    static func nextMilestone(for streakCount: Int) -> StreakMilestone? {
        self.predefinedMilestones
            .first { $0.streakCount > streakCount }
    }

    /// Check if a streak count just achieved a new milestone
    static func isNewMilestone(streakCount: Int, previousCount: Int) -> Bool {
        let currentMilestone = self.milestone(for: streakCount)
        let previousMilestone = self.milestone(for: previousCount)

        return currentMilestone?.streakCount != previousMilestone?.streakCount &&
            currentMilestone?.streakCount == streakCount
    }
}

// MARK: - Comparable

extension StreakMilestone: Comparable {
    public static func < (lhs: StreakMilestone, rhs: StreakMilestone) -> Bool {
        lhs.streakCount < rhs.streakCount
    }
}
