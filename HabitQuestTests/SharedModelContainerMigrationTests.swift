import HabitQuestCore
import SwiftData
import XCTest

@MainActor
final class SharedModelContainerMigrationTests: XCTestCase {
    private var tempDirectory: URL!
    private var defaultsSuiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SharedModelContainerMigrationTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defaultsSuiteName = "SharedModelContainerMigrationTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)!
    }

    override func tearDownWithError() throws {
        if let defaultsSuiteName {
            UserDefaults.standard.removePersistentDomain(forName: defaultsSuiteName)
        }
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        try super.tearDownWithError()
    }

    func testMigratesSeededLocalStoreToAppGroupStoreOnce() throws {
        let legacyURL = tempDirectory.appendingPathComponent("legacy.store")
        let groupURL = tempDirectory.appendingPathComponent("group.store")
        let migrationKey = "test.migration.key"

        // Seed the local store as a pre-upgrade installation would have.
        do {
            let legacyConfig = ModelConfiguration(schema: SharedModelContainer.schema, url: legacyURL)
            let legacyContainer = try ModelContainer(for: SharedModelContainer.schema, configurations: [legacyConfig])
            let legacyContext = ModelContext(legacyContainer)

            let habit = Habit(
                name: "Morning Run",
                habitDescription: "5k run",
                frequency: .custom,
                xpValue: 25,
                category: .fitness,
                difficulty: .medium,
                healthMetric: .steps,
                targetValue: 8000,
                scheduledDays: [2, 4, 6],
                customIntervalDays: 2,
                reminderTime: Date(timeIntervalSince1970: 1_700_000_000)
            )
            habit.streak = 9
            legacyContext.insert(habit)

            let log = HabitLog(habit: habit, completionDate: Date(), isCompleted: true, notes: "Felt great")
            legacyContext.insert(log)

            let profile = PlayerProfile()
            profile.level = 4
            profile.currentXP = 350
            profile.xpForNextLevel = 506
            profile.longestStreak = 14
            profile.streakFreezes = 2
            legacyContext.insert(profile)

            let achievement = Achievement(
                name: "Streak Master",
                description: "7 day streak",
                iconName: "flame.fill",
                category: .streak,
                xpReward: 100,
                requirement: .streakDays(7)
            )
            achievement.unlockedDate = Date()
            achievement.progress = 1.0
            legacyContext.insert(achievement)

            try legacyContext.save()
        }

        // First launch after upgrade migrates records into the App Group store.
        let firstResult = try SharedModelContainer.createContainerWithMigrationStatus(
            legacyStoreURL: legacyURL,
            groupStoreURL: groupURL,
            userDefaults: defaults,
            migrationKey: migrationKey
        )
        XCTAssertNil(firstResult.migrationError)
        XCTAssertTrue(defaults.bool(forKey: migrationKey))

        let groupContext = ModelContext(firstResult.container)
        let migratedHabits = try groupContext.fetch(FetchDescriptor<Habit>())
        let migratedLogs = try groupContext.fetch(FetchDescriptor<HabitLog>())
        let migratedProfiles = try groupContext.fetch(FetchDescriptor<PlayerProfile>())
        let migratedAchievements = try groupContext.fetch(FetchDescriptor<Achievement>())

        XCTAssertEqual(migratedHabits.count, 1)
        XCTAssertEqual(migratedHabits.first?.name, "Morning Run")
        XCTAssertEqual(migratedHabits.first?.streak, 9)
        XCTAssertEqual(migratedHabits.first?.healthMetric, .steps)
        XCTAssertEqual(migratedHabits.first?.targetValue, 8000)
        XCTAssertEqual(migratedHabits.first?.scheduledDays, [2, 4, 6])
        XCTAssertEqual(migratedHabits.first?.customIntervalDays, 2)
        XCTAssertNotNil(migratedHabits.first?.reminderTime)

        XCTAssertEqual(migratedLogs.count, 1)
        XCTAssertEqual(migratedLogs.first?.notes, "Felt great")
        XCTAssertEqual(migratedLogs.first?.habit?.id, migratedHabits.first?.id)

        XCTAssertEqual(migratedProfiles.count, 1)
        XCTAssertEqual(migratedProfiles.first?.level, 4)
        XCTAssertEqual(migratedProfiles.first?.currentXP, 350)
        XCTAssertEqual(migratedProfiles.first?.streakFreezes, 2)

        XCTAssertEqual(migratedAchievements.count, 1)
        XCTAssertEqual(migratedAchievements.first?.name, "Streak Master")
        XCTAssertTrue(migratedAchievements.first?.isUnlocked ?? false)

        // Second launch must not duplicate data because of the one-time guard.
        let secondResult = try SharedModelContainer.createContainerWithMigrationStatus(
            legacyStoreURL: legacyURL,
            groupStoreURL: groupURL,
            userDefaults: defaults,
            migrationKey: migrationKey
        )
        XCTAssertNil(secondResult.migrationError)
        let secondContext = ModelContext(secondResult.container)
        XCTAssertEqual(try secondContext.fetch(FetchDescriptor<Habit>()).count, 1)
        XCTAssertEqual(try secondContext.fetch(FetchDescriptor<HabitLog>()).count, 1)
        XCTAssertEqual(try secondContext.fetch(FetchDescriptor<PlayerProfile>()).count, 1)
        XCTAssertEqual(try secondContext.fetch(FetchDescriptor<Achievement>()).count, 1)
    }

    func testMigrationFailureFallsBackToLegacyStoreAndSurfacesError() throws {
        let legacyURL = tempDirectory.appendingPathComponent("legacy.store")
        // Point groupURL at a directory so opening a SQLite file at that path fails.
        let invalidGroupURL = tempDirectory.appendingPathComponent("unwritable-dir", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidGroupURL, withIntermediateDirectories: true)
        let migrationKey = "test.migration.failure"

        do {
            let legacyConfig = ModelConfiguration(schema: SharedModelContainer.schema, url: legacyURL)
            let legacyContainer = try ModelContainer(for: SharedModelContainer.schema, configurations: [legacyConfig])
            let legacyContext = ModelContext(legacyContainer)
            legacyContext.insert(Habit(name: "Preserved Habit", habitDescription: "Must not be lost", frequency: .daily))
            try legacyContext.save()
        }

        let result = try SharedModelContainer.createContainerWithMigrationStatus(
            legacyStoreURL: legacyURL,
            groupStoreURL: invalidGroupURL,
            userDefaults: defaults,
            migrationKey: migrationKey
        )

        XCTAssertNotNil(result.migrationError)
        XCTAssertFalse(defaults.bool(forKey: migrationKey))

        let fallbackContext = ModelContext(result.container)
        let habits = try fallbackContext.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(habits.count, 1)
        XCTAssertEqual(habits.first?.name, "Preserved Habit")
    }
}
