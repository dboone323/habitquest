@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class HabitModelTests: XCTestCase {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        return ModelContext(container)
    }

    func testIsCompletedToday_trueWhenCompleted() throws {
        _ = try makeContext()
        let habit = Habit(name: "Meditate", habitDescription: "10 minutes", frequency: .daily)
        _ = HabitLog(habit: habit, completionDate: Date(), isCompleted: true)

        XCTAssertTrue(habit.isCompletedToday)
    }

    func testIsCompletedToday_falseWhenNoLogs() throws {
        _ = try makeContext()
        let habit = Habit(name: "Meditate", habitDescription: "10 minutes", frequency: .daily)
        XCTAssertFalse(habit.isCompletedToday)
    }

    func testCompletionRate_last30Days() throws {
        _ = try makeContext()
        let habit = Habit(name: "Walk", habitDescription: "30 minutes", frequency: .daily)
        let cal = Calendar.current

        // 10 logs in last 30 days, 6 completed
        for i in 0 ..< 10 {
            let date = cal.date(byAdding: .day, value: -i * 2, to: Date())!
            let completed = i % 2 == 0 // 5 completed + maybe one today
            _ = HabitLog(habit: habit, completionDate: date, isCompleted: completed)
        }
        // Ensure today completed (to make 6)
        _ = HabitLog(habit: habit, completionDate: Date(), isCompleted: true)

        let rate = habit.completionRate
        XCTAssertGreaterThan(rate, 0.0)
        XCTAssertLessThanOrEqual(rate, 1.0)
    }

    func testHabitCreation_withValidData() throws {
        _ = try makeContext()
        let habitName = "Morning Exercise"
        let habitDescription = "30 minutes of cardio"
        let frequency = Habit.Frequency.daily

        let habit = Habit(name: habitName, habitDescription: habitDescription, frequency: frequency)

        XCTAssertEqual(habit.name, habitName)
        XCTAssertEqual(habit.habitDescription, habitDescription)
        XCTAssertEqual(habit.frequency, frequency)
        XCTAssertEqual(habit.logs.count, 0)
        XCTAssertFalse(habit.isCompletedToday)
    }

    func testCurrentStreak_noLogs() throws {
        _ = try makeContext()
        let habit = Habit(name: "Read", habitDescription: "20 pages", frequency: .daily)

        XCTAssertEqual(habit.currentStreak, 0)
    }

    func testCurrentStreak_withConsecutiveDays() throws {
        _ = try makeContext()
        let habit = Habit(name: "Read", habitDescription: "20 pages", frequency: .daily)
        let cal = Calendar.current

        // Create 5 consecutive completed logs
        for i in 0 ..< 5 {
            let date = cal.date(byAdding: .day, value: -i, to: Date())!
            _ = HabitLog(habit: habit, completionDate: date, isCompleted: true)
        }

        XCTAssertGreaterThanOrEqual(habit.currentStreak, 5)
    }
}
