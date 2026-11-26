import HabitQuestCore
import SwiftData
import UserNotifications
import XCTest
@testable import HabitQuest

@MainActor
final class QuestLogReminderRescheduleTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var viewModel: QuestLogViewModel!

    override func setUp() async throws {
        try await super.setUp()
        container = try SharedModelContainer.createContainer(inMemoryOnly: true)
        context = ModelContext(container)
        viewModel = QuestLogViewModel()
        viewModel.setModelContext(context)
    }

    override func tearDown() async throws {
        if let habits = try? context.fetch(FetchDescriptor<Habit>()) {
            for habit in habits {
                HabitNotificationService.shared.cancelNotifications(for: habit.id)
            }
        }
        viewModel = nil
        context = nil
        container = nil
        try await super.tearDown()
    }

    func testUpdateHabitReschedulesAndDisablesPendingNotifications() async throws {
        let calendar = Calendar.current
        let initialTime = calendar.date(from: DateComponents(year: 2026, month: 11, day: 26, hour: 8, minute: 0))!
        let habit = Habit(
            name: "Stretch",
            habitDescription: "Morning mobility",
            frequency: .custom,
            scheduledDays: [2, 4],
            reminderTime: initialTime
        )
        context.insert(habit)
        try context.save()
        defer { HabitNotificationService.shared.cancelNotifications(for: habit.id) }

        await HabitNotificationService.shared.scheduleCalendarReminders(for: habit)

        let center = UNUserNotificationCenter.current()
        let prefix = "scheduled_\(habit.id.uuidString)_"

        let initialPending = await center.pendingNotificationRequests()
            .filter { $0.identifier.hasPrefix(prefix) }
        XCTAssertEqual(Set(initialPending.map(\.identifier)), ["\(prefix)2", "\(prefix)4"])

        // Edit reminder time and scheduled days via QuestLogViewModel.updateHabit
        let updatedTime = calendar.date(from: DateComponents(year: 2026, month: 11, day: 26, hour: 19, minute: 30))!
        habit.scheduledDays = [3, 5, 7]
        habit.reminderTime = updatedTime

        viewModel.updateHabit(habit)
        await viewModel.lastReminderTask?.value

        let updatedPending = await center.pendingNotificationRequests()
            .filter { $0.identifier.hasPrefix(prefix) }
        XCTAssertEqual(Set(updatedPending.map(\.identifier)), ["\(prefix)3", "\(prefix)5", "\(prefix)7"])
        for request in updatedPending {
            let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
            XCTAssertEqual(trigger.dateComponents.hour, 19)
            XCTAssertEqual(trigger.dateComponents.minute, 30)
        }

        // Disable reminder and verify all pending requests for this habit are removed
        habit.reminderTime = nil
        viewModel.updateHabit(habit)
        await viewModel.lastReminderTask?.value

        let remainingPending = await center.pendingNotificationRequests()
            .filter { $0.identifier.contains(habit.id.uuidString) }
        XCTAssertTrue(remainingPending.isEmpty)
    }
}
