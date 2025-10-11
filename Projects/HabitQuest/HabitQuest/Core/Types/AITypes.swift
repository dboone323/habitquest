// MARK: - AI Types for Habit Management

import Foundation

public enum AIProcessingStatus {
    case idle
    case processing
    case completed
    case failed
}

public enum AIMotivationLevel {
    case low
    case medium
    case high
}

public struct AIHabitInsight: Identifiable {
    public let id: UUID
    public let habitId: UUID
    public let title: String
    public let description: String
    public let confidence: Double
    public let timestamp: Date
    public let category: AIInsightCategory
    public let type: AIInsightCategory // Alias for category for backward compatibility
    public let motivationLevel: AIMotivationLevel

    public enum AIInsightCategory {
        case success
        case warning
        case opportunity
        case trend
        case journalAnalysis
    }
}

public struct AIHabitPrediction: Identifiable {
    public let id: UUID
    public let habitId: UUID
    public let predictedSuccess: Double
    public let confidence: Double
    public let factors: [String]
    public let timestamp: Date
    public let successProbability: Double // Alias for predictedSuccess for backward compatibility
}

public struct AIHabitSuggestion: Identifiable {
    public let id: UUID
    public let title: String
    public let description: String
    public let priority: AIPriority
    public let category: AISuggestionCategory

    public enum AIPriority {
        case low
        case medium
        case high
        case urgent
    }

    public enum AISuggestionCategory {
        case timing
        case difficulty
        case motivation
        case consistency
    }
}

// MARK: - Mock Habit Types for Demo

/// Mock habit structure for demonstration
public struct AIHabit: Identifiable {
    public let id: UUID
    public let name: String
    public let habitDescription: String
    public let frequency: AIHabitFrequency
    public let category: AIHabitCategory
    public let difficulty: AIHabitDifficulty
    public let creationDate: Date
    public let isActive: Bool
    public let completionRate: Double
    public let streak: Int
    public let logs: [AIHabitLog]

    public init(
        name: String,
        habitDescription: String,
        frequency: AIHabitFrequency,
        category: AIHabitCategory,
        difficulty: AIHabitDifficulty,
        creationDate: Date = Date(),
        isActive: Bool = true,
        completionRate: Double = 0.8,
        streak: Int = 5,
        logs: [AIHabitLog] = []
    ) {
        self.id = UUID()
        self.name = name
        self.habitDescription = habitDescription
        self.frequency = frequency
        self.category = category
        self.difficulty = difficulty
        self.creationDate = creationDate
        self.isActive = isActive
        self.completionRate = completionRate
        self.streak = streak
        self.logs = logs
    }
}

/// Habit frequency options
public enum AIHabitFrequency {
    case daily
    case weekly
    case monthly
}

/// Habit category options
public enum AIHabitCategory {
    case health
    case fitness
    case learning
    case productivity
    case social
    case creativity
    case mindfulness
    case other
}

/// Habit difficulty levels
public enum AIHabitDifficulty {
    case easy
    case medium
    case hard

    public var xpMultiplier: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}

/// Habit completion log entry
public struct AIHabitLog {
    public let completionDate: Date
    public let isCompleted: Bool
    public let notes: String?

    public init(completionDate: Date, isCompleted: Bool, notes: String? = nil) {
        self.completionDate = completionDate
        self.isCompleted = isCompleted
        self.notes = notes
    }
}
