import HabitQuestCore
import SwiftData
import XCTest

final class HealthKitServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var modelContext: ModelContext!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainer(
            for: Habit.self, HabitLog.self, PlayerProfile.self, HabitQuestCore.Achievement.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = ModelContext(container)
    }

    @MainActor
    override func tearDown() async throws {
        container = nil
        modelContext = nil
        try await super.tearDown()
    }

    @MainActor
    func testAutoFillCompletesHabitWhenTargetMetAndAwardsXP() throws {
        let profile = PlayerProfile()
        modelContext.insert(profile)

        let stepsHabit = Habit(
            name: "Walk 8,000 Steps",
            habitDescription: "Daily movement",
            frequency: .daily,
            xpValue: 20,
            healthMetric: .steps,
            targetValue: 8000
        )
        let energyHabit = Habit(
            name: "Burn 500 kcal",
            habitDescription: "Active energy",
            frequency: .daily,
            xpValue: 15,
            healthMetric: .activeEnergy,
            targetValue: 500
        )
        let sleepHabit = Habit(
            name: "Sleep 7.5 Hours",
            habitDescription: "Rest well",
            frequency: .daily,
            xpValue: 25,
            healthMetric: .sleepHours,
            targetValue: 7.5
        )

        modelContext.insert(stepsHabit)
        modelContext.insert(energyHabit)
        modelContext.insert(sleepHabit)
        try modelContext.save()

        let snapshot = HealthMetricsSnapshot(steps: 9200, activeEnergy: 320, sleepHours: 8.0)
        let completedCount = HealthKitService.shared.autoFillHabits(
            [stepsHabit, energyHabit, sleepHabit],
            in: modelContext,
            snapshot: snapshot
        )

        XCTAssertEqual(completedCount, 2)
        XCTAssertTrue(stepsHabit.isCompletedToday)
        XCTAssertFalse(energyHabit.isCompletedToday)
        XCTAssertTrue(sleepHabit.isCompletedToday)
        XCTAssertEqual(profile.currentXP, 45)
        XCTAssertTrue(stepsHabit.logs.first?.notes?.contains("Auto-logged from Apple Health") ?? false)
    }

    @MainActor
    func testAutoFillIsIdempotentForSameDay() throws {
        let profile = PlayerProfile()
        modelContext.insert(profile)

        let stepsHabit = Habit(
            name: "Walk 5,000 Steps",
            habitDescription: "Daily steps",
            frequency: .daily,
            xpValue: 10,
            healthMetric: .steps,
            targetValue: 5000
        )
        modelContext.insert(stepsHabit)
        try modelContext.save()

        let snapshot = HealthMetricsSnapshot(steps: 6500)
        let firstCount = HealthKitService.shared.autoFillHabits([stepsHabit], in: modelContext, snapshot: snapshot)
        let secondCount = HealthKitService.shared.autoFillHabits([stepsHabit], in: modelContext, snapshot: snapshot)

        XCTAssertEqual(firstCount, 1)
        XCTAssertEqual(secondCount, 0)
        XCTAssertEqual(stepsHabit.logs.count, 1)
        XCTAssertEqual(profile.currentXP, 10)
    }

    @MainActor
    func testAutoFillDegradesGracefullyWithoutSnapshotWhenUnauthorized() throws {
        let stepsHabit = Habit(
            name: "Walk 10,000 Steps",
            habitDescription: "Daily steps",
            frequency: .daily,
            xpValue: 10,
            healthMetric: .steps,
            targetValue: 10000
        )
        modelContext.insert(stepsHabit)
        try modelContext.save()

        let wasAuthorized = HealthKitService.shared.isAuthorized
        HealthKitService.shared.isAuthorized = false
        defer { HealthKitService.shared.isAuthorized = wasAuthorized }

        let count = HealthKitService.shared.autoFillHabits([stepsHabit], in: modelContext)
        XCTAssertEqual(count, 0)
        XCTAssertFalse(stepsHabit.isCompletedToday)
        XCTAssertTrue(stepsHabit.logs.isEmpty)
    }
}
