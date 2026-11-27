import HabitQuestCore
import SwiftData
import XCTest

@MainActor
final class HabitDataServiceBackupTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var dataService: HabitDataService!

    override func setUp() async throws {
        try await super.setUp()
        container = try SharedModelContainer.createContainer(inMemoryOnly: true)
        context = ModelContext(container)
        dataService = HabitDataService(modelContext: context)
    }

    override func tearDown() async throws {
        dataService = nil
        context = nil
        container = nil
        try await super.tearDown()
    }

    func testExportImportRoundTripPreservesAllHabitSettings() throws {
        let profile = PlayerProfile()
        context.insert(profile)

        let reminderDate = Date(timeIntervalSince1970: 1_764_154_800)
        let habit = Habit(
            name: "Zone 2 Cardio",
            habitDescription: "Health + custom schedule",
            frequency: .custom,
            xpValue: 30,
            category: .fitness,
            difficulty: .medium,
            healthMetric: .activeEnergy,
            targetValue: 450,
            scheduledDays: [2, 4, 6],
            customIntervalDays: 3,
            reminderTime: reminderDate
        )
        habit.streak = 5
        context.insert(habit)
        try context.save()

        let exportedData = try dataService.exportData()

        // Mutate/clear and re-import into the context
        try dataService.importData(exportedData)

        let restoredHabits = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(restoredHabits.count, 1)
        let restored = try XCTUnwrap(restoredHabits.first)

        XCTAssertEqual(restored.id, habit.id)
        XCTAssertEqual(restored.name, "Zone 2 Cardio")
        XCTAssertEqual(restored.healthMetric, .activeEnergy)
        XCTAssertEqual(restored.targetValue, 450)
        XCTAssertEqual(restored.scheduledDays, [2, 4, 6])
        XCTAssertEqual(restored.customIntervalDays, 3)
        XCTAssertEqual(
            restored.reminderTime?.timeIntervalSince1970 ?? 0,
            reminderDate.timeIntervalSince1970,
            accuracy: 1.0
        )
    }

    func testImportLegacyBackupWithoutNewHabitFieldsSucceedsWithNilDefaults() throws {
        let legacyJSON = """
        {
          "profile": {
            "level": 2,
            "currentXP": 120,
            "xpForNextLevel": 150,
            "longestStreak": 4,
            "streakFreezes": 1,
            "creationDate": "2026-11-01T00:00:00Z"
          },
          "habits": [
            {
              "id": "11111111-1111-1111-1111-111111111111",
              "name": "Legacy Habit",
              "habitDescription": "Pre-feature backup",
              "frequency": "daily",
              "creationDate": "2026-11-01T00:00:00Z",
              "xpValue": 10,
              "streak": 3,
              "isActive": true,
              "category": "health",
              "difficulty": "easy"
            }
          ],
          "logs": [],
          "achievements": [],
          "exportDate": "2026-11-20T00:00:00Z"
        }
        """
        let data = try XCTUnwrap(legacyJSON.data(using: .utf8))
        try dataService.importData(data)

        let restoredHabits = try context.fetch(FetchDescriptor<Habit>())
        XCTAssertEqual(restoredHabits.count, 1)
        let restored = try XCTUnwrap(restoredHabits.first)
        XCTAssertEqual(restored.name, "Legacy Habit")
        XCTAssertNil(restored.healthMetric)
        XCTAssertNil(restored.targetValue)
        XCTAssertNil(restored.scheduledDays)
        XCTAssertNil(restored.customIntervalDays)
        XCTAssertNil(restored.reminderTime)
    }
}
