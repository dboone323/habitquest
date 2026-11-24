import CoreData
import Foundation
import HabitQuestCore
import SwiftData
import XCTest
@testable import HabitQuest

@MainActor
final class SwiftDataMigrationTests: XCTestCase {
    nonisolated(unsafe) private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftDataMigrationTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        if let tempDirectory {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        super.tearDown()
    }

    /// Build an NSManagedObjectModel representing the pre-PR #79 schema:
    /// - PlayerProfile without `streakFreezes`
    /// - HabitLog without `freezesConsumed`
    private func makePrePRManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // 1. PlayerProfile (pre-PR: no streakFreezes)
        let profileEntity = NSEntityDescription()
        profileEntity.name = "PlayerProfile"
        profileEntity.managedObjectClassName = "PlayerProfile"

        let levelAttr = NSAttributeDescription()
        levelAttr.name = "level"
        levelAttr.attributeType = .integer64AttributeType
        levelAttr.isOptional = false

        let currentXPAttr = NSAttributeDescription()
        currentXPAttr.name = "currentXP"
        currentXPAttr.attributeType = .integer64AttributeType
        currentXPAttr.isOptional = false

        let xpForNextLevelAttr = NSAttributeDescription()
        xpForNextLevelAttr.name = "xpForNextLevel"
        xpForNextLevelAttr.attributeType = .integer64AttributeType
        xpForNextLevelAttr.isOptional = false

        let longestStreakAttr = NSAttributeDescription()
        longestStreakAttr.name = "longestStreak"
        longestStreakAttr.attributeType = .integer64AttributeType
        longestStreakAttr.isOptional = false

        let creationDateAttr = NSAttributeDescription()
        creationDateAttr.name = "creationDate"
        creationDateAttr.attributeType = .dateAttributeType
        creationDateAttr.isOptional = false

        profileEntity.properties = [levelAttr, currentXPAttr, xpForNextLevelAttr, longestStreakAttr, creationDateAttr]

        // 2. Habit
        let habitEntity = NSEntityDescription()
        habitEntity.name = "Habit"
        habitEntity.managedObjectClassName = "Habit"

        let habitIdAttr = NSAttributeDescription()
        habitIdAttr.name = "id"
        habitIdAttr.attributeType = .UUIDAttributeType
        habitIdAttr.isOptional = false

        let habitNameAttr = NSAttributeDescription()
        habitNameAttr.name = "name"
        habitNameAttr.attributeType = .stringAttributeType
        habitNameAttr.isOptional = false

        let habitDescAttr = NSAttributeDescription()
        habitDescAttr.name = "habitDescription"
        habitDescAttr.attributeType = .stringAttributeType
        habitDescAttr.isOptional = false

        let habitFreqAttr = NSAttributeDescription()
        habitFreqAttr.name = "frequency"
        habitFreqAttr.attributeType = .stringAttributeType
        habitFreqAttr.isOptional = false

        let habitDiffAttr = NSAttributeDescription()
        habitDiffAttr.name = "difficulty"
        habitDiffAttr.attributeType = .stringAttributeType
        habitDiffAttr.isOptional = false

        let habitStreakAttr = NSAttributeDescription()
        habitStreakAttr.name = "streak"
        habitStreakAttr.attributeType = .integer64AttributeType
        habitStreakAttr.isOptional = false

        let habitActiveAttr = NSAttributeDescription()
        habitActiveAttr.name = "isActive"
        habitActiveAttr.attributeType = .booleanAttributeType
        habitActiveAttr.isOptional = false

        let habitCreatedAttr = NSAttributeDescription()
        habitCreatedAttr.name = "creationDate"
        habitCreatedAttr.attributeType = .dateAttributeType
        habitCreatedAttr.isOptional = false

        let habitCategoryAttr = NSAttributeDescription()
        habitCategoryAttr.name = "category"
        habitCategoryAttr.attributeType = .stringAttributeType
        habitCategoryAttr.isOptional = false

        let habitXPAttr = NSAttributeDescription()
        habitXPAttr.name = "xpValue"
        habitXPAttr.attributeType = .integer64AttributeType
        habitXPAttr.isOptional = false

        // 3. HabitLog (pre-PR: no freezesConsumed)
        let logEntity = NSEntityDescription()
        logEntity.name = "HabitLog"
        logEntity.managedObjectClassName = "HabitLog"

        let logIdAttr = NSAttributeDescription()
        logIdAttr.name = "id"
        logIdAttr.attributeType = .UUIDAttributeType
        logIdAttr.isOptional = false

        let logCompDateAttr = NSAttributeDescription()
        logCompDateAttr.name = "completionDate"
        logCompDateAttr.attributeType = .dateAttributeType
        logCompDateAttr.isOptional = false

        let logIsCompAttr = NSAttributeDescription()
        logIsCompAttr.name = "isCompleted"
        logIsCompAttr.attributeType = .booleanAttributeType
        logIsCompAttr.isOptional = false

        let logNotesAttr = NSAttributeDescription()
        logNotesAttr.name = "notes"
        logNotesAttr.attributeType = .stringAttributeType
        logNotesAttr.isOptional = true

        let logXPEarnedAttr = NSAttributeDescription()
        logXPEarnedAttr.name = "xpEarned"
        logXPEarnedAttr.attributeType = .integer64AttributeType
        logXPEarnedAttr.isOptional = false

        let logMoodAttr = NSAttributeDescription()
        logMoodAttr.name = "mood"
        logMoodAttr.attributeType = .stringAttributeType
        logMoodAttr.isOptional = true

        let logCompTimeAttr = NSAttributeDescription()
        logCompTimeAttr.name = "completionTime"
        logCompTimeAttr.attributeType = .dateAttributeType
        logCompTimeAttr.isOptional = true

        // Relationships between Habit and HabitLog
        let habitLogsRel = NSRelationshipDescription()
        habitLogsRel.name = "logs"
        habitLogsRel.destinationEntity = logEntity
        habitLogsRel.minCount = 0
        habitLogsRel.maxCount = 0
        habitLogsRel.deleteRule = .cascadeDeleteRule

        let logHabitRel = NSRelationshipDescription()
        logHabitRel.name = "habit"
        logHabitRel.destinationEntity = habitEntity
        logHabitRel.minCount = 0
        logHabitRel.maxCount = 1
        logHabitRel.deleteRule = .nullifyDeleteRule

        habitLogsRel.inverseRelationship = logHabitRel
        logHabitRel.inverseRelationship = habitLogsRel

        habitEntity.properties = [
            habitIdAttr, habitNameAttr, habitDescAttr, habitFreqAttr, habitDiffAttr,
            habitStreakAttr, habitActiveAttr, habitCreatedAttr, habitCategoryAttr, habitXPAttr, habitLogsRel
        ]
        logEntity.properties = [
            logIdAttr, logCompDateAttr, logIsCompAttr, logNotesAttr, logXPEarnedAttr,
            logMoodAttr, logCompTimeAttr, logHabitRel
        ]

        // 4. Achievement
        let achEntity = NSEntityDescription()
        achEntity.name = "Achievement"
        achEntity.managedObjectClassName = "Achievement"

        let achIdAttr = NSAttributeDescription()
        achIdAttr.name = "id"
        achIdAttr.attributeType = .UUIDAttributeType
        achIdAttr.isOptional = false

        let achNameAttr = NSAttributeDescription()
        achNameAttr.name = "name"
        achNameAttr.attributeType = .stringAttributeType
        achNameAttr.isOptional = false

        let achDescAttr = NSAttributeDescription()
        achDescAttr.name = "achievementDescription"
        achDescAttr.attributeType = .stringAttributeType
        achDescAttr.isOptional = false

        let achIconAttr = NSAttributeDescription()
        achIconAttr.name = "iconName"
        achIconAttr.attributeType = .stringAttributeType
        achIconAttr.isOptional = false

        let achCatAttr = NSAttributeDescription()
        achCatAttr.name = "category"
        achCatAttr.attributeType = .stringAttributeType
        achCatAttr.isOptional = false

        let achXPAttr = NSAttributeDescription()
        achXPAttr.name = "xpReward"
        achXPAttr.attributeType = .integer64AttributeType
        achXPAttr.isOptional = false

        let achHiddenAttr = NSAttributeDescription()
        achHiddenAttr.name = "isHidden"
        achHiddenAttr.attributeType = .booleanAttributeType
        achHiddenAttr.isOptional = false

        let achUnlockedDateAttr = NSAttributeDescription()
        achUnlockedDateAttr.name = "unlockedDate"
        achUnlockedDateAttr.attributeType = .dateAttributeType
        achUnlockedDateAttr.isOptional = true

        achEntity.properties = [
            achIdAttr, achNameAttr, achDescAttr, achIconAttr,
            achCatAttr, achXPAttr, achHiddenAttr, achUnlockedDateAttr
        ]

        model.entities = [profileEntity, habitEntity, logEntity, achEntity]
        return model
    }

    /// Creates a persistent SQLite store populated with the old pre-PR schema
    private func createOldPrePRStore(at storeURL: URL) throws {
        let oldModel = makePrePRManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldModel)
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: nil
        )

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        // Insert pre-PR PlayerProfile (level 5, longestStreak 12, no streakFreezes attribute)
        let profile = NSEntityDescription.insertNewObject(forEntityName: "PlayerProfile", into: context)
        profile.setValue(5, forKey: "level")
        profile.setValue(350, forKey: "currentXP")
        profile.setValue(500, forKey: "xpForNextLevel")
        profile.setValue(12, forKey: "longestStreak")
        profile.setValue(Date(), forKey: "creationDate")

        // Insert pre-PR Habit
        let habit = NSEntityDescription.insertNewObject(forEntityName: "Habit", into: context)
        let habitId = UUID()
        habit.setValue(habitId, forKey: "id")
        habit.setValue("Morning Run", forKey: "name")
        habit.setValue("5km jog", forKey: "habitDescription")
        habit.setValue("daily", forKey: "frequency")
        habit.setValue("medium", forKey: "difficulty")
        habit.setValue(3, forKey: "streak")
        habit.setValue(true, forKey: "isActive")
        habit.setValue(Date(), forKey: "creationDate")
        habit.setValue("fitness", forKey: "category")
        habit.setValue(20, forKey: "xpValue")

        // Insert pre-PR HabitLog (no freezesConsumed attribute)
        let log = NSEntityDescription.insertNewObject(forEntityName: "HabitLog", into: context)
        log.setValue(UUID(), forKey: "id")
        log.setValue(Date(), forKey: "completionDate")
        log.setValue(true, forKey: "isCompleted")
        log.setValue(20, forKey: "xpEarned")
        log.setValue(habit, forKey: "habit")

        try context.save()
        try coordinator.remove(store)
    }

    /// Issue #89: Proves that opening a store created with the old pre-PR schema
    /// succeeds with the new models without losing existing data or falling back to in-memory store.
    func testMigrationFromOldSchemaPreservesRowsWithDefaults() throws {
        let storeURL = tempDirectory.appendingPathComponent("old_habitquest.sqlite")
        try createOldPrePRStore(at: storeURL)

        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path), "Old store file must exist on disk")

        let schema = Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self,
        ])
        let config = ModelConfiguration(schema: schema, url: storeURL)

        // On unfixed code, this throws a migration error because streakFreezes and freezesConsumed
        // are required non-optional attributes without property-level defaults.
        let container = try ModelContainer(for: schema, configurations: [config])
        XCTAssertFalse(config.isStoredInMemoryOnly, "Store must remain persistent, not in-memory")

        let context = ModelContext(container)

        // Existing rows must survive
        let profiles = try context.fetch(FetchDescriptor<PlayerProfile>())
        XCTAssertEqual(profiles.count, 1, "Existing PlayerProfile row must survive migration")
        XCTAssertEqual(profiles.first?.level, 5, "Existing profile level must be preserved")
        XCTAssertEqual(profiles.first?.longestStreak, 12, "Existing profile longestStreak must be preserved")
        XCTAssertEqual(profiles.first?.streakFreezes, 0, "Migrated profile must receive sensible default 0 for streakFreezes")

        let logs = try context.fetch(FetchDescriptor<HabitLog>())
        XCTAssertEqual(logs.count, 1, "Existing HabitLog row must survive migration")
        XCTAssertEqual(logs.first?.freezesConsumed, 0, "Migrated habit log must receive sensible default 0 for freezesConsumed")

        let habits = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(habits.count, 1, "Existing Habit row must survive migration")
        XCTAssertEqual(habits.first?.name, "Morning Run", "Existing habit name must be preserved")
    }
}
