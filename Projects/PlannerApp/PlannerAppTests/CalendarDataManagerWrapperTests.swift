//
//  CalendarDataManagerWrapperTests.swift
//  PlannerAppTests
//
//  Created by Daniel Stevens on 4/28/25.
//

import CloudKit
import Foundation
import SwiftData
import XCTest

@testable import PlannerApp

final class CalendarDataManagerWrapperTests: XCTestCase {
    // MARK: - CalendarDataManager wrapper (delegates to CloudKitManager.shared)

    @MainActor
    func testRealCalendarDataManagerLoadAndSave() {
        // Test that CalendarDataManager delegates correctly to CloudKitManager
        // We test the delegation by verifying the behavior, not internal state
        let dm = CalendarDataManager.shared

        let e1 = CalendarEvent(id: UUID(), title: "A", date: Date())
        let e2 = CalendarEvent(id: UUID(), title: "B", date: Date().addingTimeInterval(3600))

        // Save events
        dm.save(events: [e1, e2])

        // Load events and verify they were saved
        let loaded = dm.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertTrue(loaded.contains(where: { $0.title == "A" }))
        XCTAssertTrue(loaded.contains(where: { $0.title == "B" }))
    }

    @MainActor
    func testRealCalendarDataManagerAddUpdateDeleteFind() {
        let dm = CalendarDataManager.shared
        let id = UUID()
        let now = Date()
        let original = CalendarEvent(id: id, title: "Orig", date: now)

        // Add
        dm.add(original)
        XCTAssertEqual(dm.find(by: id)?.title, "Orig")

        // Update
        let updated = CalendarEvent(id: id, title: "Updated", date: now)
        dm.update(updated)
        XCTAssertEqual(dm.find(by: id)?.title, "Updated")

        // Delete
        dm.delete(updated)
        XCTAssertNil(dm.find(by: id))
    }

    @MainActor
    func testRealCalendarDataManagerQueryHelpers() {
        let dm = CalendarDataManager.shared
        let cal = Calendar.current
        let today = Date()
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let dayAfter = cal.date(byAdding: .day, value: 2, to: today)!

        let eToday = CalendarEvent(id: UUID(), title: "Today", date: today)
        let eTomorrow = CalendarEvent(id: UUID(), title: "Tomorrow", date: tomorrow)
        let eDayAfter = CalendarEvent(id: UUID(), title: "DayAfter", date: dayAfter)

        dm.save(events: [eTomorrow, eDayAfter, eToday])

        // events(for:)
        let todays = dm.events(for: today)
        XCTAssertEqual(todays.count, 1)
        XCTAssertEqual(todays.first?.title, "Today")

        // events(between:and:)
        let rangeEvents = dm.events(between: today, and: dayAfter)
        XCTAssertEqual(rangeEvents.count, 3)

        // eventsSortedByDate()
        let sorted = dm.eventsSortedByDate()
        XCTAssertEqual(sorted.map(\.title), ["Today", "Tomorrow", "DayAfter"])

        // upcomingEvents(within:)
        let upcoming2 = dm.upcomingEvents(within: 2)
        // Should include today through dayAfter
        XCTAssertEqual(upcoming2.count, 3)

        // clearAllEvents and stats
        dm.clearAllEvents()
        XCTAssertEqual(dm.load().count, 0)

        // Repopulate for stats
        dm.save(events: [eToday, eTomorrow])
        let stats = dm.getEventStatistics()
        XCTAssertEqual(stats["total"], 2)
        XCTAssertGreaterThanOrEqual(stats["eventsThisWeek"] ?? 0, 1)
    }
}
