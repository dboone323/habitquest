import SwiftData
import XCTest

@testable import HabitQuest

final class DataExportServiceTests: XCTestCase {
    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    @MainActor
    func testExportImportRoundTrip() throws {
        // Arrange: create source in-memory store with sample data
        let sourceContainer = try makeInMemoryContainer()
        let sourceContext = ModelContext(sourceContainer)

        // Player profile (required by export)
        let profile = PlayerProfile()
        profile.level = 3
        profile.currentXP = 120
        profile.xpForNextLevel = 200
        profile.longestStreak = 5
        profile.creationDate = Date(timeIntervalSince1970: 1_700_000_000)
        sourceContext.insert(profile)

        // Habit
        let habit = Habit(name: "Read", habitDescription: "Read 10 pages", frequency: .daily, xpValue: 10)
        habit.creationDate = Date(timeIntervalSince1970: 1_700_000_100)
        habit.streak = 2
        sourceContext.insert(habit)

        // Habit Log
        let log = HabitLog(habit: habit, completionDate: Date(timeIntervalSince1970: 1_700_000_500))
        sourceContext.insert(log)
        habit.logs.append(log)

        // Achievement
        let achievement = Achievement(
            name: "First Steps",
            description: "Complete 1 habit",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        achievement.unlockedDate = Date(timeIntervalSince1970: 1_700_000_900)
        achievement.progress = 1.0
        sourceContext.insert(achievement)

        try sourceContext.save()

        // Act: export from source and import into destination in-memory store
        let exported = try DataExportService.exportUserData(from: sourceContext)

        let destContainer = try makeInMemoryContainer()
        let destContext = ModelContext(destContainer)
        try DataExportService.importUserData(from: exported, into: destContext, replaceExisting: true)

        // Assert: verify basic counts and fields
        let habitCount = try destContext.fetch(FetchDescriptor<Habit>()).count
        let logCount = try destContext.fetch(FetchDescriptor<HabitLog>()).count
        let achCount = try destContext.fetch(FetchDescriptor<Achievement>()).count
        let profiles = try destContext.fetch(FetchDescriptor<PlayerProfile>())

        XCTAssertEqual(habitCount, 1)
        XCTAssertEqual(logCount, 1)
        XCTAssertEqual(achCount, 1)
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles.first?.level, 3)
    }
}
