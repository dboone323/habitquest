import XCTest
@testable import HabitQuest

final class IntegrationBaselineTests: XCTestCase {
    func testUserDefaultsIntegrationBaseline() {
        let key = "integration_baseline_HabitQuest"
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: key)
        XCTAssertTrue(defaults.bool(forKey: key))
        defaults.removeObject(forKey: key)
    }
}
