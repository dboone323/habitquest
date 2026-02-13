import XCTest
@testable import HabitQuest

final class PerformanceBaselineTests: XCTestCase {
    func testSortingPerformanceBaseline() {
        let values = (0..<5000).map { _ in Int.random(in: 0...100_000) }

        measure {
            _ = values.sorted()
        }
    }
}
