@testable import HabitQuest
import XCTest

final class GamificationServiceTests: XCTestCase {
    var service: GamificationService!

    override func setUp() {
        super.setUp()
        service = GamificationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func testGamificationServiceInitialization() {
        XCTAssertNotNil(service, "GamificationService should optimize initialization")
    }

    func testXPForLevelCalculation() {
        // Level 1 should be 100 XP (100 * 1.5^0)
        XCTAssertEqual(service.calculateXPForLevel(1), 100)

        // Level 2 should be 150 XP (100 * 1.5^1)
        XCTAssertEqual(service.calculateXPForLevel(2), 150)

        // Level 0 should be 0
        XCTAssertEqual(service.calculateXPForLevel(0), 0)
    }

    func testXPForNextLevel() {
        // Next level from 1 is 2
        XCTAssertEqual(service.calculateXPForNextLevel(forLevel: 1), 150)
    }
}
