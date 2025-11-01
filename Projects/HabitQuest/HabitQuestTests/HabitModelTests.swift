import XCTest
import SwiftData
@testable import HabitQuest

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
        let _ = HabitLog(habit: habit, completionDate: Date(), isCompleted: true)

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
        for i in 0..<10 {
            let date = cal.date(byAdding: .day, value: -i*2, to: Date())!
            let completed = i % 2 == 0 // 5 completed + maybe one today
            let _ = HabitLog(habit: habit, completionDate: date, isCompleted: completed)
        }
        // Ensure today completed (to make 6)
        let _ = HabitLog(habit: habit, completionDate: Date(), isCompleted: true)

        let rate = habit.completionRate
        XCTAssertGreaterThan(rate, 0.0)
        XCTAssertLessThanOrEqual(rate, 1.0)
    }
}
