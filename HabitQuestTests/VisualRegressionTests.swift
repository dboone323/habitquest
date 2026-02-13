import Foundation
import XCTest
@testable import HabitQuest

final class VisualRegressionTests: XCTestCase {
    func testDashboardSnapshotBaseline() throws {
        let snapshot = "screen=dashboard|module=HabitQuest|state=baseline-v1"
        try assertSnapshot(snapshot, named: "dashboard_baseline")
    }

    private func assertSnapshot(
        _ snapshot: String,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let currentFile = URL(fileURLWithPath: String(describing: file))
        let fixtureURL = currentFile.deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("\(name).txt")

        let expected = try String(contentsOf: fixtureURL, encoding: .utf8)
        XCTAssertEqual(snapshot, expected.trimmingCharacters(in: .whitespacesAndNewlines), line: line)
    }
}
