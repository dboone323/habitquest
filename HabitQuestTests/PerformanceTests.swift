import HabitQuestCore
import XCTest
@testable import HabitQuest

@MainActor
final class PerformanceTests: XCTestCase {
    func testAchievementServiceDefaultCreationPerformance() {
        measure {
            for _ in 0..<250 {
                _ = AchievementService.createDefaultAchievements()
            }
        }
    }

    func testExportFilenameGenerationPerformance() {
        measure {
            for _ in 0..<2000 {
                _ = DataExportService.generateExportFilename()
            }
        }
    }
}
