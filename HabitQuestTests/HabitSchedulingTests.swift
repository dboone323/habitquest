import HabitQuestCore
import XCTest

final class HabitSchedulingTests: XCTestCase {
    @MainActor
    func testCustomScheduledDaysDueToday() throws {
        let service = GamificationService()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // 2026-11-23 is Monday (weekday = 2)
        let monday = calendar.date(from: DateComponents(year: 2026, month: 11, day: 23))!
        let tuesday = calendar.date(byAdding: .day, value: 1, to: monday)!
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!
        let friday = calendar.date(byAdding: .day, value: 4, to: monday)!
        let saturday = calendar.date(byAdding: .day, value: 5, to: monday)!

        let habit = Habit(
            name: "Gym Workout",
            habitDescription: "MWF training",
            frequency: .custom,
            scheduledDays: [2, 4, 6]
        )

        XCTAssertTrue(service.isHabitDueToday(habit, on: monday, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: tuesday, calendar: calendar))
        XCTAssertTrue(service.isHabitDueToday(habit, on: wednesday, calendar: calendar))
        XCTAssertTrue(service.isHabitDueToday(habit, on: friday, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: saturday, calendar: calendar))
    }

    @MainActor
    func testCustomIntervalDaysDueToday() throws {
        let service = GamificationService()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let habit = Habit(
            name: "Water Plants",
            habitDescription: "Every 3 days",
            frequency: .custom,
            customIntervalDays: 3
        )
        let startDay = calendar.startOfDay(for: habit.creationDate)
        let day1 = calendar.date(byAdding: .day, value: 1, to: startDay)!
        let day2 = calendar.date(byAdding: .day, value: 2, to: startDay)!
        let day3 = calendar.date(byAdding: .day, value: 3, to: startDay)!

        XCTAssertTrue(service.isHabitDueToday(habit, on: startDay, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: day1, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: day2, calendar: calendar))
        XCTAssertTrue(service.isHabitDueToday(habit, on: day3, calendar: calendar))
    }

    @MainActor
    func testNotificationTriggerDateComponentsWithScheduledDaysAndTime() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let reminder = calendar.date(from: DateComponents(year: 2026, month: 11, day: 26, hour: 8, minute: 30))!

        let habit = Habit(
            name: "Morning Run",
            habitDescription: "Mon/Fri",
            frequency: .custom,
            scheduledDays: [6, 2],
            reminderTime: reminder
        )

        let triggers = HabitNotificationService.shared.notificationTriggerDateComponents(for: habit, calendar: calendar)
        XCTAssertEqual(triggers.count, 2)
        XCTAssertEqual(triggers[0].weekday, 2)
        XCTAssertEqual(triggers[0].hour, 8)
        XCTAssertEqual(triggers[0].minute, 30)
        XCTAssertEqual(triggers[1].weekday, 6)
        XCTAssertEqual(triggers[1].hour, 8)
        XCTAssertEqual(triggers[1].minute, 30)
    }

    @MainActor
    func testNotificationTriggerDateComponentsDailyFallback() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let reminder = calendar.date(from: DateComponents(year: 2026, month: 11, day: 26, hour: 21, minute: 15))!

        let habit = Habit(
            name: "Evening Journal",
            habitDescription: "Daily",
            frequency: .daily,
            reminderTime: reminder
        )

        let triggers = HabitNotificationService.shared.notificationTriggerDateComponents(for: habit, calendar: calendar)
        XCTAssertEqual(triggers.count, 1)
        XCTAssertNil(triggers[0].weekday)
        XCTAssertEqual(triggers[0].hour, 21)
        XCTAssertEqual(triggers[0].minute, 15)
    }

    @MainActor
    func testNotificationTriggerDateComponentsForCustomInterval() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        // 2026-11-23 is Monday (weekday = 2)
        let monday = calendar.date(from: DateComponents(year: 2026, month: 11, day: 23))!
        let reminder = calendar.date(from: DateComponents(year: 2026, month: 11, day: 23, hour: 9, minute: 45))!

        let habit = Habit(
            name: "Every 3 Days",
            habitDescription: "Interval",
            frequency: .custom,
            customIntervalDays: 3,
            reminderTime: reminder
        )
        habit.creationDate = monday

        let triggers = HabitNotificationService.shared.notificationTriggerDateComponents(for: habit, calendar: calendar)
        // Monday (2) + 0d = Mon (2), +3d = Thu (5), +6d = Sun (1) -> sorted [1, 2, 5]
        XCTAssertEqual(triggers.map(\.weekday), [1, 2, 5])
        XCTAssertTrue(triggers.allSatisfy { $0.hour == 9 && $0.minute == 45 })
    }

    @MainActor
    func testNotificationTriggerDateComponentsForMonthlyAndDefaultWeekly() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let reminder = calendar.date(from: DateComponents(year: 2026, month: 11, day: 26, hour: 10, minute: 0))!

        let monthlyHabit = Habit(
            name: "Monthly Review",
            habitDescription: "First of month",
            frequency: .monthly,
            reminderTime: reminder
        )
        let monthlyTriggers = HabitNotificationService.shared.notificationTriggerDateComponents(for: monthlyHabit, calendar: calendar)
        XCTAssertEqual(monthlyTriggers.count, 1)
        XCTAssertEqual(monthlyTriggers[0].day, 1)
        XCTAssertNil(monthlyTriggers[0].weekday)
        XCTAssertEqual(monthlyTriggers[0].hour, 10)
        XCTAssertEqual(monthlyTriggers[0].minute, 0)

        let weeklyHabit = Habit(
            name: "Weekly Sync",
            habitDescription: "Default Monday",
            frequency: .weekly,
            reminderTime: reminder
        )
        let weeklyTriggers = HabitNotificationService.shared.notificationTriggerDateComponents(for: weeklyHabit, calendar: calendar)
        XCTAssertEqual(weeklyTriggers.count, 1)
        XCTAssertEqual(weeklyTriggers[0].weekday, 2)
        XCTAssertNil(weeklyTriggers[0].day)
        XCTAssertEqual(weeklyTriggers[0].hour, 10)
        XCTAssertEqual(weeklyTriggers[0].minute, 0)
    }
}
