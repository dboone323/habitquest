//
// HabitDataService.swift
// HabitQuestCore
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.habitquest.core", category: "HabitDataService")

/// Unified service for managing application data lifecycle, including backups, exports, and templates.
/// Consolidated from legacy BackupService, DataExportService, and HabitTemplateService.
@MainActor
public final class HabitDataService: Sendable {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Fetches all habits from the database.
    public func fetchAllHabits() throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Habit Templates

    /// Provides a standardized set of habit presets.
    public func getTemplates() -> [HabitTemplate] {
        [
            HabitTemplate(
                name: "Drink Water",
                description: "Drink 8 glasses of water daily",
                category: .health,
                frequency: .daily,
                difficulty: .easy,
                xpValue: 10
            ),
            HabitTemplate(
                name: "Read 30 Minutes",
                description: "Read a book for 30 minutes",
                category: .learning,
                frequency: .daily,
                difficulty: .medium,
                xpValue: 20
            ),
            HabitTemplate(
                name: "Exercise",
                description: "30 minutes of physical activity",
                category: .fitness,
                frequency: .daily,
                difficulty: .hard,
                xpValue: 30
            ),
            HabitTemplate(
                name: "Weekly Planning",
                description: "Plan the week ahead",
                category: .productivity,
                frequency: .weekly,
                difficulty: .medium,
                xpValue: 50
            ),
            HabitTemplate(
                name: "Meditation",
                description: "10 minutes of mindfulness",
                category: .mindfulness,
                frequency: .daily,
                difficulty: .easy,
                xpValue: 15
            )
        ]
    }

    // MARK: - Export & Backup

    /// Exports all user data into an encrypted or plain JSON format for backup.
    public func exportData() throws -> Data {
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        guard let profile = profiles.first else {
            throw DataError.noProfileFound
        }

        let habitsDescriptor = FetchDescriptor<Habit>()
        let habits = try modelContext.fetch(habitsDescriptor)
        
        let logsDescriptor = FetchDescriptor<HabitLog>()
        let logs = try modelContext.fetch(logsDescriptor)

        let achievementsDescriptor = FetchDescriptor<Achievement>()
        let achievements = try modelContext.fetch(achievementsDescriptor)

        let exportPayload = ExportPayload(
            profile: profile,
            habits: habits,
            logs: logs,
            achievements: achievements,
            exportDate: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(exportPayload)
    }

    /// Imports user data from a previously exported payload.
    public func importData(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let payload = try decoder.decode(ExportPayload.self, from: data)
            try clearCurrentData()
            
            modelContext.insert(payload.profile.toModel())
            
            let habits = payload.habits.map { $0.toModel() }
            for habit in habits {
                modelContext.insert(habit)
            }
            
            for logDTO in payload.logs {
                if let log = logDTO.toModel(allHabits: habits) {
                    modelContext.insert(log)
                }
            }

            for achievementDTO in payload.achievements {
                modelContext.insert(achievementDTO.toModel())
            }
            
            try modelContext.save()
            logger.info("Successfully imported \(payload.habits.count) habits and \(payload.achievements.count) achievements.")
        } catch {
            logger.error("Data import failed: \(error.localizedDescription)")
            throw DataError.importFailed(error.localizedDescription)
        }
    }


    private func clearCurrentData() throws {
        try modelContext.delete(model: PlayerProfile.self)
        try modelContext.delete(model: Habit.self)
        try modelContext.delete(model: HabitLog.self)
        try modelContext.delete(model: Achievement.self)
        try modelContext.save()
    }

    // MARK: - Supporting Types

    public enum DataError: LocalizedError {
        case noProfileFound
        case importFailed(String)
        
        public var errorDescription: String? {
            switch self {
            case .noProfileFound: "No player profile found."
            case .importFailed(let msg): "Import failed: \(msg)"
            }
        }
    }

    private struct ExportPayload: Codable {
        let profile: PlayerProfileDTO
        let habits: [HabitDTO]
        let logs: [HabitLogDTO]
        let achievements: [AchievementDTO]
        let exportDate: Date

        enum CodingKeys: String, CodingKey {
            case profile
            case habits
            case logs
            case achievements
            case exportDate
        }

        init(profile: PlayerProfile, habits: [Habit], logs: [HabitLog], achievements: [Achievement], exportDate: Date) {
            self.profile = PlayerProfileDTO(from: profile)
            self.habits = habits.map { HabitDTO(from: $0) }
            self.logs = logs.map { HabitLogDTO(from: $0) }
            self.achievements = achievements.map { AchievementDTO(from: $0) }
            self.exportDate = exportDate
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            profile = try container.decode(PlayerProfileDTO.self, forKey: .profile)
            habits = try container.decode([HabitDTO].self, forKey: .habits)
            logs = try container.decode([HabitLogDTO].self, forKey: .logs)
            achievements = try container.decodeIfPresent([AchievementDTO].self, forKey: .achievements) ?? []
            exportDate = try container.decode(Date.self, forKey: .exportDate)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(profile, forKey: .profile)
            try container.encode(habits, forKey: .habits)
            try container.encode(logs, forKey: .logs)
            try container.encode(achievements, forKey: .achievements)
            try container.encode(exportDate, forKey: .exportDate)
        }
    }

    private struct PlayerProfileDTO: Codable {
        let level: Int
        let currentXP: Int
        let xpForNextLevel: Int
        let longestStreak: Int
        let creationDate: Date

        init(from profile: PlayerProfile) {
            self.level = profile.level
            self.currentXP = profile.currentXP
            self.xpForNextLevel = profile.xpForNextLevel
            self.longestStreak = profile.longestStreak
            self.creationDate = profile.creationDate
        }

        func toModel() -> PlayerProfile {
            let model = PlayerProfile()
            model.level = level
            model.currentXP = currentXP
            model.xpForNextLevel = xpForNextLevel
            model.longestStreak = longestStreak
            model.creationDate = creationDate
            return model
        }
    }

    private struct HabitDTO: Codable {
        let id: UUID
        let name: String
        let habitDescription: String
        let frequency: HabitFrequency
        let creationDate: Date
        let xpValue: Int
        let streak: Int
        let isActive: Bool
        let category: HabitCategory
        let difficulty: HabitDifficulty

        init(from model: Habit) {
            self.id = model.id
            self.name = model.name
            self.habitDescription = model.habitDescription
            self.frequency = model.frequency
            self.creationDate = model.creationDate
            self.xpValue = model.xpValue
            self.streak = model.streak
            self.isActive = model.isActive
            self.category = model.category
            self.difficulty = model.difficulty
        }

        func toModel() -> Habit {
            let model = Habit(name: name, habitDescription: habitDescription, frequency: frequency, xpValue: xpValue, category: category, difficulty: difficulty)
            model.id = id
            model.creationDate = creationDate
            model.streak = streak
            model.isActive = isActive
            return model
        }
    }

    private struct HabitLogDTO: Codable {
        let id: UUID
        let completionDate: Date
        let isCompleted: Bool
        let notes: String?
        let xpEarned: Int
        let mood: MoodRating?
        let completionTime: Date?
        let habitId: UUID?

        init(from model: HabitLog) {
            self.id = model.id
            self.completionDate = model.completionDate
            self.isCompleted = model.isCompleted
            self.notes = model.notes
            self.xpEarned = model.xpEarned
            self.mood = model.mood
            self.completionTime = model.completionTime
            self.habitId = model.habit?.id
        }

        func toModel(allHabits: [Habit]) -> HabitLog? {
            guard let habit = (allHabits.first { $0.id == habitId }) else { return nil }
            let model = HabitLog(habit: habit, completionDate: completionDate, isCompleted: isCompleted, notes: notes, mood: mood)
            model.id = id
            model.xpEarned = xpEarned
            model.completionTime = completionTime
            return model
        }
    }

    private struct AchievementDTO: Codable {
        let id: UUID
        let name: String
        let achievementDescription: String
        let iconName: String
        let category: AchievementCategory
        let xpReward: Int
        let isHidden: Bool
        let unlockedDate: Date?
        let progress: Float
        let requirement: AchievementRequirement

        init(from model: Achievement) {
            self.id = model.id
            self.name = model.name
            self.achievementDescription = model.achievementDescription
            self.iconName = model.iconName
            self.category = model.category
            self.xpReward = model.xpReward
            self.isHidden = model.isHidden
            self.unlockedDate = model.unlockedDate
            self.progress = model.progress
            self.requirement = model.requirement
        }

        func toModel() -> Achievement {
            let model = Achievement(
                name: name,
                description: achievementDescription,
                iconName: iconName,
                category: category,
                xpReward: xpReward,
                isHidden: isHidden,
                requirement: requirement
            )
            model.id = id
            model.unlockedDate = unlockedDate
            model.progress = progress
            return model
        }
    }
}

