//
// CloudKitSyncManagerTests.swift
// HabitQuestTests
//

import XCTest
@testable import HabitQuest

@MainActor
final class CloudKitSyncManagerTests: XCTestCase {
    private var sut: CloudKitSyncManager!

    override func setUpWithError() throws {
        sut = CloudKitSyncManager.shared
        sut.conflictResolution = .serverWins
    }

    // MARK: - Core State

    func testSharedInstanceIdentity() {
        XCTAssertTrue(CloudKitSyncManager.shared === sut)
    }

    func testSyncStatusIsValidValue() {
        XCTAssertTrue(
            [
                CloudKitSyncManager.SyncStatus.idle,
                .syncing,
                .synced,
                .error,
                .offline,
            ].contains(sut.syncStatus)
        )
    }

    func testLastSyncDateIsNilOrInPast() {
        if let lastSyncDate = sut.lastSyncDate {
            XCTAssertLessThanOrEqual(lastSyncDate, Date())
        } else {
            XCTAssertNil(sut.lastSyncDate)
        }
    }

    func testConflictResolutionDefaultIsServerWins() {
        XCTAssertEqual(sut.conflictResolution, .serverWins)
    }

    func testConflictResolutionCanBeUpdated() {
        sut.conflictResolution = .merge
        XCTAssertEqual(sut.conflictResolution, .merge)
    }

    // MARK: - Status Presentation Mapping

    func testSyncStatusSymbolMapping() {
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.idle.symbolName, "icloud")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.syncing.symbolName, "arrow.triangle.2.circlepath.icloud")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.synced.symbolName, "checkmark.icloud")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.error.symbolName, "exclamationmark.icloud")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.offline.symbolName, "icloud.slash")
    }

    func testSyncStatusColorMapping() {
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.idle.colorName, "gray")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.syncing.colorName, "blue")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.synced.colorName, "green")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.error.colorName, "red")
        XCTAssertEqual(CloudKitSyncManager.SyncStatus.offline.colorName, "orange")
    }

}
