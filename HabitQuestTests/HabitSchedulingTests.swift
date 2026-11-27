import HabitQuestCore
import XCTest

final class HabitSchedulingTests: XCTestCase {
    @MainActor
    func testCustomScheduledDaysDueToday() throws {
        let service = GamificationService()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))

        // 2026-11-23 is Monday (weekday = 2)
        let monday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 23)))
        let tuesday = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: monday))
        let wednesday = try XCTUnwrap(calendar.date(byAdding: .day, value: 2, to: monday))
        let friday = try XCTUnwrap(calendar.date(byAdding: .day, value: 4, to: monday))
        let saturday = try XCTUnwrap(calendar.date(byAdding: .day, value: 5, to: monday))

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
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))

        let habit = Habit(
            name: "Water Plants",
            habitDescription: "Every 3 days",
            frequency: .custom,
            customIntervalDays: 3
        )
        let startDay = calendar.startOfDay(for: habit.creationDate)
        let day1 = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: startDay))
        let day2 = try XCTUnwrap(calendar.date(byAdding: .day, value: 2, to: startDay))
        let day3 = try XCTUnwrap(calendar.date(byAdding: .day, value: 3, to: startDay))

        XCTAssertTrue(service.isHabitDueToday(habit, on: startDay, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: day1, calendar: calendar))
        XCTAssertFalse(service.isHabitDueToday(habit, on: day2, calendar: calendar))
        XCTAssertTrue(service.isHabitDueToday(habit, on: day3, calendar: calendar))
    }

    @MainActor
    func testNotificationTriggerDateComponentsWithScheduledDaysAndTime() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let reminder = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 11,
            day: 26,
            hour: 8,
            minute: 30
        )))

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
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let reminder = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 11,
            day: 26,
            hour: 21,
            minute: 15
        )))

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
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        // 2026-11-23 is Monday (weekday = 2)
        let monday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 11, day: 23)))
        let reminder = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 11,
            day: 23,
            hour: 9,
            minute: 45
        )))

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
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let reminder = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026,
            month: 11,
            day: 26,
            hour: 10,
            minute: 0
        )))

        let monthlyHabit = Habit(
            name: "Monthly Review",
            habitDescription: "First of month",
            frequency: .monthly,
            reminderTime: reminder
        )
        let monthlyTriggers = HabitNotificationService.shared.notificationTriggerDateComponents(
            for: monthlyHabit,
            calendar: calendar
        )
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
        let weeklyTriggers = HabitNotificationService.shared.notificationTriggerDateComponents(
            for: weeklyHabit,
            calendar: calendar
        )
        XCTAssertEqual(weeklyTriggers.count, 1)
        XCTAssertEqual(weeklyTriggers[0].weekday, 2)
        XCTAssertNil(weeklyTriggers[0].day)
        XCTAssertEqual(weeklyTriggers[0].hour, 10)
        XCTAssertEqual(weeklyTriggers[0].minute, 0)
    }

    @MainActor
    func testCustomIntervalSevenDaysPreservesStreakWithoutConsumingFreezes() throws {
        let service = GamificationService()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // 3 scheduled occurrences: 16 days ago, 9 days ago, 2 days ago (every 7 days).
        // Next occurrence isn't due until 5 days from today, so 0 scheduled occurrences were missed.
        let creationDate = try XCTUnwrap(calendar.date(byAdding: .day, value: -16, to: today))
        let secondDate = try XCTUnwrap(calendar.date(byAdding: .day, value: -9, to: today))
        let thirdDate = try XCTUnwrap(calendar.date(byAdding: .day, value: -2, to: today))

        let habit = Habit(
            name: "Weekly Deep Clean",
            habitDescription: "Every 7 days",
            frequency: .custom,
            customIntervalDays: 7
        )
        habit.creationDate = creationDate

        let profile = PlayerProfile()
        profile.streakFreezes = 3

        let log1 = HabitLog(habit: habit, completionDate: creationDate)
        let log2 = HabitLog(habit: habit, completionDate: secondDate)
        let log3 = HabitLog(habit: habit, completionDate: thirdDate)
        habit.logs = [log1, log2, log3]

        service.updateHabitStreak(habit: habit, profile: profile, forgivenessThreshold: 5)

        XCTAssertEqual(habit.streak, 3)
        XCTAssertEqual(profile.streakFreezes, 3)
        XCTAssertEqual(log1.freezesConsumed, 0)
        XCTAssertEqual(log2.freezesConsumed, 0)
        XCTAssertEqual(log3.freezesConsumed, 0)
    }

    @MainActor
    func testCustomScheduledWeekdaysPreservesStreakWithoutConsumingFreezes() throws {
        let service = GamificationService()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayWeekday = calendar.component(.weekday, from: today)
        // Pick a single weekday matching 14 days ago / 7 days ago / today (same weekday)
        let fourteenDaysAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -14, to: today))
        let sevenDaysAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -7, to: today))

        let habit = Habit(
            name: "Specific Weekday Habit",
            habitDescription: "Once a week on same weekday",
            frequency: .custom,
            scheduledDays: [todayWeekday]
        )
        habit.creationDate = fourteenDaysAgo

        let profile = PlayerProfile()
        profile.streakFreezes = 2

        let log1 = HabitLog(habit: habit, completionDate: fourteenDaysAgo)
        let log2 = HabitLog(habit: habit, completionDate: sevenDaysAgo)
        let log3 = HabitLog(habit: habit, completionDate: today)
        habit.logs = [log1, log2, log3]

        service.updateHabitStreak(habit: habit, profile: profile, forgivenessThreshold: 5)

        XCTAssertEqual(habit.streak, 3)
        XCTAssertEqual(profile.streakFreezes, 2)
    }
}
