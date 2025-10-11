import Foundation
import OSLog
import SwiftData
import os

/// Service for exporting and importing HabitQuest user data
/// Handles backup, restore, and data portability features
public struct DataExportService: Sendable {
    private static let logger = Logger(category: Logger.Category.dataModel)

    /// Structure for exported data
    struct ExportedData: @preconcurrency Codable, @unchecked Sendable {
        let exportDate: Date
        let appVersion: String
        let playerProfile: ExportedPlayerProfile
        let habits: [ExportedHabit]
        let habitLogs: [ExportedHabitLog]
        let achievements: [ExportedAchievement]

        struct ExportedPlayerProfile: @preconcurrency Codable, @unchecked Sendable {
            let level: Int
            let currentXP: Int
            let xpForNextLevel: Int
            let longestStreak: Int
            let creationDate: Date
        }

        struct ExportedHabit: @preconcurrency Codable, @unchecked Sendable {
            let id: String
            let name: String
            let habitDescription: String
            let frequency: String
            let creationDate: Date
            let xpValue: Int
            let streak: Int
        }

        struct ExportedHabitLog: @preconcurrency Codable, @unchecked Sendable {
            let completionDate: Date
            let habitId: String
        }

        struct ExportedAchievement: @preconcurrency Codable, @unchecked Sendable {
            let id: String
            let name: String
            let achievementDescription: String
            let iconName: String
            let category: String
            let xpReward: Int
            let isHidden: Bool
            let unlockedDate: Date?
            let progress: Float
            let requirement: String // JSON string of requirement
        }
    }

    /// Export all user data to JSON
    /// - Parameter modelContext: SwiftData model context
    /// - Returns: JSON data ready for sharing/backup
    @MainActor
    static func exportUserData(from modelContext: ModelContext) throws -> Data {
        self.logger.info("Starting data export...")

        // Fetch player profile
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        guard let profile = profiles.first else {
            throw DataExportError.noDataToExport("No player profile found")
        }

        // Fetch habits
        let habitsDescriptor = FetchDescriptor<Habit>()
        let habits = try modelContext.fetch(habitsDescriptor)

        // Fetch habit logs
        let logsDescriptor = FetchDescriptor<HabitLog>()
        let logs = try modelContext.fetch(logsDescriptor)

        // Fetch achievements
        let achievementsDescriptor = FetchDescriptor<Achievement>()
        let achievements = try modelContext.fetch(achievementsDescriptor)

        // Convert to exportable format
        let exportedProfile = ExportedData.ExportedPlayerProfile(
            level: profile.level,
            currentXP: profile.currentXP,
            xpForNextLevel: profile.xpForNextLevel,
            longestStreak: profile.longestStreak,
            creationDate: profile.creationDate
        )

        let exportedHabits = habits.map { habit in
            ExportedData.ExportedHabit(
                id: habit.id.uuidString,
                name: habit.name,
                habitDescription: habit.habitDescription,
                frequency: habit.frequency.rawValue,
                creationDate: habit.creationDate,
                xpValue: habit.xpValue,
                streak: habit.streak
            )
        }

        let exportedLogs = logs.compactMap { log -> ExportedData.ExportedHabitLog? in
            guard let habitId = log.habit?.id.uuidString else { return nil }
            return ExportedData.ExportedHabitLog(
                completionDate: log.completionDate,
                habitId: habitId
            )
        }

        let exportedAchievements = achievements.map { achievement in
            let requirementData = try? JSONEncoder().encode(achievement.requirement)
            let requirementString = requirementData?.base64EncodedString() ?? ""

            return ExportedData.ExportedAchievement(
                id: achievement.id.uuidString,
                name: achievement.name,
                achievementDescription: achievement.achievementDescription,
                iconName: achievement.iconName,
                category: achievement.category.rawValue,
                xpReward: achievement.xpReward,
                isHidden: achievement.isHidden,
                unlockedDate: achievement.unlockedDate,
                progress: achievement.progress,
                requirement: requirementString
            )
        }

        let exportData = ExportedData(
            exportDate: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            playerProfile: exportedProfile,
            habits: exportedHabits,
            habitLogs: exportedLogs,
            achievements: exportedAchievements
        )

        let jsonData = try JSONEncoder().encode(exportData)
        self.logger.info("Data export completed. Size: \(jsonData.count) bytes")

        return jsonData
    }

    /// Import user data from JSON
    /// - Parameters:
    ///   - data: JSON data to import
    ///   - modelContext: SwiftData context to import into
    ///   - replaceExisting: Whether to replace existing data or merge
    @MainActor
    static func importUserData(from data: Data, into modelContext: ModelContext, replaceExisting: Bool = false) throws {
        self.logger.info("Starting data import...")

        let decoder = JSONDecoder()
        let importData = try decoder.decode(ExportedData.self, from: data)

        // Validate import data
        try self.validateImportData(importData)

        if replaceExisting {
            // Clear existing data
            try self.clearAllData(from: modelContext)
        }

        // Import player profile
        let profile = PlayerProfile()
        profile.level = importData.playerProfile.level
        profile.currentXP = importData.playerProfile.currentXP
        profile.xpForNextLevel = importData.playerProfile.xpForNextLevel
        profile.longestStreak = importData.playerProfile.longestStreak
        profile.creationDate = importData.playerProfile.creationDate
        modelContext.insert(profile)

        // Import habits
        var habitIdMap: [String: Habit] = [:]
        for exportedHabit in importData.habits {
            let habit = Habit(
                name: exportedHabit.name,
                habitDescription: exportedHabit.habitDescription,
                frequency: HabitFrequency(rawValue: exportedHabit.frequency) ?? .daily,
                xpValue: exportedHabit.xpValue
            )
            habit.id = UUID(uuidString: exportedHabit.id) ?? UUID()
            habit.creationDate = exportedHabit.creationDate
            habit.streak = exportedHabit.streak

            modelContext.insert(habit)
            habitIdMap[exportedHabit.id] = habit
        }

        // Import habit logs
        for exportedLog in importData.habitLogs {
            if let habit = habitIdMap[exportedLog.habitId] {
                let log = HabitLog(habit: habit, completionDate: exportedLog.completionDate)
                modelContext.insert(log)

                habit.logs.append(log)
            }
        }

        // Import achievements
        for exportedAchievement in importData.achievements {
            // Decode requirement
            var requirement: AchievementRequirement = .streakDays(1) // Default
            if let requirementData = Data(base64Encoded: exportedAchievement.requirement) {
                requirement = (try? JSONDecoder().decode(AchievementRequirement.self, from: requirementData)) ??
                    .streakDays(1)
            }

            let achievement = Achievement(
                name: exportedAchievement.name,
                description: exportedAchievement.achievementDescription,
                iconName: exportedAchievement.iconName,
                category: AchievementCategory(rawValue: exportedAchievement.category) ?? .streak,
                xpReward: exportedAchievement.xpReward,
                isHidden: exportedAchievement.isHidden,
                requirement: requirement
            )

            achievement.id = UUID(uuidString: exportedAchievement.id) ?? UUID()
            achievement.unlockedDate = exportedAchievement.unlockedDate
            achievement.progress = exportedAchievement.progress

            modelContext.insert(achievement)
        }

        try modelContext.save()
        self.logger.info("Data import completed successfully")
    }

    /// Generate a formatted filename for export
    static func generateExportFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateString = formatter.string(from: Date())
        return "HabitQuest_Backup_\(dateString).json"
    }

    /// Validate imported data structure
    private static func validateImportData(_ data: ExportedData) throws {
        // Check for required data
        if data.habits.isEmpty {
            self.logger.warning("Import data contains no habits")
        }

        // Validate habit-log relationships
        let habitIds = Set(data.habits.map(\.id))
        let invalidLogs = data.habitLogs.filter { !habitIds.contains($0.habitId) }

        if !invalidLogs.isEmpty {
            self.logger.warning("Found \(invalidLogs.count) habit logs with invalid habit references")
        }

        self.logger.info("Import data validation completed")
    }

    /// Clear all existing data from the model context
    private static func clearAllData(from modelContext: ModelContext) throws {
        // Delete all existing data
        let profileDescriptor = FetchDescriptor<PlayerProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        profiles.forEach { modelContext.delete($0) }

        let habitsDescriptor = FetchDescriptor<Habit>()
        let habits = try modelContext.fetch(habitsDescriptor)
        habits.forEach { modelContext.delete($0) }

        let logsDescriptor = FetchDescriptor<HabitLog>()
        let logs = try modelContext.fetch(logsDescriptor)
        logs.forEach { modelContext.delete($0) }

        let achievementsDescriptor = FetchDescriptor<Achievement>()
        let achievements = try modelContext.fetch(achievementsDescriptor)
        achievements.forEach { modelContext.delete($0) }

        try modelContext.save()
        self.logger.info("Cleared all existing data")
    }
}

/// Errors that can occur during data export/import
public enum DataExportError: LocalizedError, @unchecked Sendable {
    case noProfileFound
    case noDataToExport(String)
    case importFailed(String)
    case encodingFailed(Error)
    case decodingFailed(Error)

    public nonisolated var errorDescription: String? {
        switch self {
        case .noProfileFound:
            "No player profile found to export"
        case let .noDataToExport(message):
            "No data to export: \(message)"
        case let .importFailed(message):
            "Import failed: \(message)"
        case let .encodingFailed(error):
            "Failed to encode data: \(error.localizedDescription)"
        case let .decodingFailed(error):
            "Failed to decode data: \(error.localizedDescription)"
        }
    }
}
