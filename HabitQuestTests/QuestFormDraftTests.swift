import HabitQuestCore
import XCTest
@testable import HabitQuest

@MainActor
final class QuestFormDraftTests: XCTestCase {
    func testMakeHabitAndApplyPreservesScheduleHealthAndReminderFields() {
        let reminder = Date(timeIntervalSince1970: 1_764_154_800)
        var draft = QuestFormDraft()
        draft.name = "Evening Walk"
        draft.description = "30 min walk"
        draft.frequency = .custom
        draft.xpValue = 25
        draft.scheduledDays = [2, 4, 6]
        draft.hasReminderTime = true
        draft.reminderTime = reminder
        draft.syncWithHealth = true
        draft.healthMetric = .steps
        draft.targetValue = 7500

        let created = draft.makeHabit()
        XCTAssertEqual(created.name, "Evening Walk")
        XCTAssertEqual(created.scheduledDays, [2, 4, 6])
        XCTAssertNil(created.customIntervalDays)
        XCTAssertEqual(created.reminderTime, reminder)
        XCTAssertEqual(created.healthMetric, .steps)
        XCTAssertEqual(created.targetValue, 7500)

        var editDraft = QuestFormDraft(habit: created)
        editDraft.scheduledDays = []
        editDraft.customIntervalDays = 3
        editDraft.hasReminderTime = false
        editDraft.syncWithHealth = false

        editDraft.apply(to: created)
        XCTAssertNil(created.scheduledDays)
        XCTAssertEqual(created.customIntervalDays, 3)
        XCTAssertNil(created.reminderTime)
        XCTAssertNil(created.healthMetric)
        XCTAssertNil(created.targetValue)
    }
}
