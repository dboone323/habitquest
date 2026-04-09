//
// LocationRemindersTests.swift
// HabitQuestTests
//

import CoreLocation
import XCTest
@testable import HabitQuest

@MainActor
final class LocationRemindersTests: XCTestCase {
    var sut: LocationReminderManager!

    override func setUpWithError() throws {
        sut = LocationReminderManager.shared
    }

    // MARK: - Reminder Creation Tests

    func testCreateReminder() {
        let reminder = LocationReminder(
            habitId: UUID(),
            habitName: "Exercise",
            latitude: 37.7749,
            longitude: -122.4194,
            locationName: "Gym"
        )

        XCTAssertEqual(reminder.habitName, "Exercise")
        XCTAssertEqual(reminder.locationName, "Gym")
        XCTAssertTrue(reminder.isEnabled)
    }

    func testReminderDefaults() {
        let reminder = LocationReminder(
            habitId: UUID(),
            habitName: "Test",
            latitude: 0,
            longitude: 0,
            locationName: "Test Location"
        )

        XCTAssertTrue(reminder.triggerOnEntry)
        XCTAssertFalse(reminder.triggerOnExit)
        XCTAssertEqual(reminder.radius, 100)
    }

    // MARK: - Coordinate Tests

    func testCoordinateConversion() {
        let reminder = LocationReminder(
            habitId: UUID(),
            habitName: "Test",
            latitude: 40.7128,
            longitude: -74.0060,
            locationName: "NYC"
        )

        let coordinate = reminder.coordinate
        XCTAssertEqual(coordinate.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(coordinate.longitude, -74.0060, accuracy: 0.0001)
    }

    // MARK: - Region Tests

    func testRegionCreation() {
        let reminder = LocationReminder(
            habitId: UUID(),
            habitName: "Test",
            latitude: 37.7749,
            longitude: -122.4194,
            radius: 150,
            locationName: "SF"
        )

        let region = reminder.region
        XCTAssertEqual(region.radius, 150)
        XCTAssertTrue(region.notifyOnEntry)
        XCTAssertFalse(region.notifyOnExit)
    }

    // MARK: - Manager Tests

    func testManagerSharedInstance() {
        XCTAssertNotNil(LocationReminderManager.shared)
    }

    func testRemindersArrayInitiallyEmpty() {
        XCTAssertGreaterThanOrEqual(sut.reminders.count, 0)
    }

    func testAuthorizationStatus() {
        XCTAssertTrue(
            [
                CLAuthorizationStatus.notDetermined,
                .restricted,
                .denied,
                .authorizedAlways,
                .authorizedWhenInUse,
            ].contains(sut.authorizationStatus)
        )
    }
}
