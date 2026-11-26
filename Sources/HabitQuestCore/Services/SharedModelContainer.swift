import Foundation
import SwiftData

/// App Group identifier shared between the main HabitQuest app and its Widget Extension.
public enum HabitQuestAppGroup {
    public static let identifier = "group.com.habitquest.app"
}

/// Simplified, read-only habit representation for WidgetKit timelines.
public struct HabitWidgetItem: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let emoji: String
    public let isCompleted: Bool
    public let streak: Int

    public init(id: UUID, name: String, emoji: String, isCompleted: Bool, streak: Int) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isCompleted = isCompleted
        self.streak = streak
    }
}

/// Factory for the shared SwiftData ModelContainer backed by the App Group container.
public enum SharedModelContainer {
    public static let storeMigrationKey = "habitquest.app_group_store_migrated_v1"

    public struct ContainerResult {
        public let container: ModelContainer
        public let migrationError: Error?

        public init(container: ModelContainer, migrationError: Error? = nil) {
            self.container = container
            self.migrationError = migrationError
        }
    }

    public static var schema: Schema {
        Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self,
        ])
    }

    /// Creates the shared ModelContainer, migrating any existing local store into the App Group store once.
    public static func createContainer(
        inMemoryOnly: Bool = false,
        legacyStoreURL: URL? = nil,
        groupStoreURL: URL? = nil,
        userDefaults: UserDefaults = .standard,
        migrationKey: String = storeMigrationKey
    ) throws -> ModelContainer {
        try createContainerWithMigrationStatus(
            inMemoryOnly: inMemoryOnly,
            legacyStoreURL: legacyStoreURL,
            groupStoreURL: groupStoreURL,
            userDefaults: userDefaults,
            migrationKey: migrationKey
        ).container
    }

    /// Creates the shared ModelContainer and reports any non-fatal migration error when falling back to the local store.
    public static func createContainerWithMigrationStatus(
        inMemoryOnly: Bool = false,
        legacyStoreURL: URL? = nil,
        groupStoreURL: URL? = nil,
        userDefaults: UserDefaults = .standard,
        migrationKey: String = storeMigrationKey
    ) throws -> ContainerResult {
        if inMemoryOnly {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [config])
            return ContainerResult(container: container)
        }

        let legacyConfig: ModelConfiguration = if let legacyStoreURL {
            ModelConfiguration(schema: schema, url: legacyStoreURL)
        } else {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        let resolvedGroupConfig: ModelConfiguration? = if let groupStoreURL {
            ModelConfiguration(schema: schema, url: groupStoreURL)
        } else if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: HabitQuestAppGroup.identifier) != nil {
            ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(HabitQuestAppGroup.identifier)
            )
        } else {
            nil
        }

        guard let groupConfig = resolvedGroupConfig else {
            let container = try ModelContainer(for: schema, configurations: [legacyConfig])
            return ContainerResult(container: container)
        }

        let legacyURL = legacyConfig.url
        let groupURL = groupConfig.url

        if userDefaults.bool(forKey: migrationKey) || legacyURL == groupURL {
            let container = try ModelContainer(for: schema, configurations: [groupConfig])
            return ContainerResult(container: container)
        }

        guard FileManager.default.fileExists(atPath: legacyURL.path) else {
            let container = try ModelContainer(for: schema, configurations: [groupConfig])
            userDefaults.set(true, forKey: migrationKey)
            return ContainerResult(container: container)
        }

        do {
            let legacyContainer = try ModelContainer(for: schema, configurations: [legacyConfig])
            let groupContainer = try ModelContainer(for: schema, configurations: [groupConfig])
            try copyStoreRecords(from: legacyContainer, to: groupContainer)
            userDefaults.set(true, forKey: migrationKey)
            return ContainerResult(container: groupContainer)
        } catch {
            // Keep using the existing local store if migration fails so no user data is lost.
            let legacyContainer = try ModelContainer(for: schema, configurations: [legacyConfig])
            return ContainerResult(container: legacyContainer, migrationError: error)
        }
    }

    private static func copyStoreRecords(from sourceContainer: ModelContainer, to destinationContainer: ModelContainer) throws {
        let sourceContext = ModelContext(sourceContainer)
        let destinationContext = ModelContext(destinationContainer)

        let existingHabits = try destinationContext.fetch(FetchDescriptor<Habit>())
        let existingHabitIDs = Set(existingHabits.map(\.id))
        let existingLogs = try destinationContext.fetch(FetchDescriptor<HabitLog>())
        let existingLogIDs = Set(existingLogs.map(\.id))
        let existingAchievements = try destinationContext.fetch(FetchDescriptor<Achievement>())
        let existingAchievementIDs = Set(existingAchievements.map(\.id))
        let existingProfiles = try destinationContext.fetch(FetchDescriptor<PlayerProfile>())

        var habitMap: [UUID: Habit] = Dictionary(uniqueKeysWithValues: existingHabits.map { ($0.id, $0) })

        let sourceHabits = try sourceContext.fetch(FetchDescriptor<Habit>())
        for sourceHabit in sourceHabits {
            let targetHabit: Habit
            if let existing = habitMap[sourceHabit.id] {
                targetHabit = existing
            } else if !existingHabitIDs.contains(sourceHabit.id) {
                let copy = Habit(
                    name: sourceHabit.name,
                    habitDescription: sourceHabit.habitDescription,
                    frequency: sourceHabit.frequency,
                    xpValue: sourceHabit.xpValue,
                    category: sourceHabit.category,
                    difficulty: sourceHabit.difficulty,
                    healthMetric: sourceHabit.healthMetric,
                    targetValue: sourceHabit.targetValue,
                    scheduledDays: sourceHabit.scheduledDays,
                    customIntervalDays: sourceHabit.customIntervalDays,
                    reminderTime: sourceHabit.reminderTime
                )
                copy.id = sourceHabit.id
                copy.creationDate = sourceHabit.creationDate
                copy.streak = sourceHabit.streak
                copy.isActive = sourceHabit.isActive
                destinationContext.insert(copy)
                habitMap[sourceHabit.id] = copy
                targetHabit = copy
            } else {
                continue
            }

            for sourceLog in sourceHabit.logs where !existingLogIDs.contains(sourceLog.id) {
                let logCopy = HabitLog(
                    habit: targetHabit,
                    completionDate: sourceLog.completionDate,
                    isCompleted: sourceLog.isCompleted,
                    notes: sourceLog.notes,
                    mood: sourceLog.mood,
                    freezesConsumed: sourceLog.freezesConsumed
                )
                logCopy.id = sourceLog.id
                logCopy.xpEarned = sourceLog.xpEarned
                logCopy.completionTime = sourceLog.completionTime
                destinationContext.insert(logCopy)
            }
        }

        let sourceProfiles = try sourceContext.fetch(FetchDescriptor<PlayerProfile>())
        if existingProfiles.isEmpty {
            for sourceProfile in sourceProfiles {
                let profileCopy = PlayerProfile()
                profileCopy.level = sourceProfile.level
                profileCopy.currentXP = sourceProfile.currentXP
                profileCopy.xpForNextLevel = sourceProfile.xpForNextLevel
                profileCopy.longestStreak = sourceProfile.longestStreak
                profileCopy.streakFreezes = sourceProfile.streakFreezes
                profileCopy.creationDate = sourceProfile.creationDate
                destinationContext.insert(profileCopy)
            }
        }

        let sourceAchievements = try sourceContext.fetch(FetchDescriptor<Achievement>())
        for sourceAchievement in sourceAchievements where !existingAchievementIDs.contains(sourceAchievement.id) {
            let achievementCopy = Achievement(
                name: sourceAchievement.name,
                description: sourceAchievement.achievementDescription,
                iconName: sourceAchievement.iconName,
                category: sourceAchievement.category,
                xpReward: sourceAchievement.xpReward,
                isHidden: sourceAchievement.isHidden,
                requirement: sourceAchievement.requirement
            )
            achievementCopy.id = sourceAchievement.id
            achievementCopy.unlockedDate = sourceAchievement.unlockedDate
            achievementCopy.progress = sourceAchievement.progress
            destinationContext.insert(achievementCopy)
        }

        if destinationContext.hasChanges {
            try destinationContext.save()
        }
    }
}

/// Read-only loader that reads today's active habits from SwiftData for WidgetKit.
@MainActor
public enum HabitWidgetDataLoader {
    /// Reads active habits due today from the provided ModelContext.
    public static func loadTodaysHabits(
        from context: ModelContext,
        date: Date = Date(),
        calendar: Calendar = .current
    ) -> [HabitWidgetItem] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\Habit.creationDate)]
        )
        guard let habits = try? context.fetch(descriptor) else {
            return []
        }

        let gamificationService = GamificationService()
        return habits
            .filter { gamificationService.isHabitDueToday($0, on: date, calendar: calendar) }
            .map { habit in
                HabitWidgetItem(
                    id: habit.id,
                    name: habit.name,
                    emoji: habit.category.emoji,
                    isCompleted: habit.isCompletedToday,
                    streak: habit.streak
                )
            }
    }

    /// Reads active habits due today from the shared App Group ModelContainer.
    public static func loadTodaysHabitsFromSharedContainer() -> [HabitWidgetItem] {
        guard let container = try? SharedModelContainer.createContainer() else {
            return []
        }
        return loadTodaysHabits(from: ModelContext(container))
    }
}
