//
// PerformanceTests.swift
// HabitQuestTests
//

import XCTest
@testable import HabitQuest

@MainActor
final class PerformanceTests: XCTestCase {
    func testGamificationManagerPerformance() {
        let manager = GamificationManager()
        let start = CFAbsoluteTimeGetCurrent()
        let iterations = 500

        for _ in 0..<iterations {
            for index in manager.achievements.indices {
                manager.achievements[index].unlockedDate = nil
                manager.achievements[index].progress = 0
            }

            for i in 0..<200 {
                manager.checkAchievements(habitsCompleted: i % 3, currentStreak: i % 10)
            }
        }

        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThan(
            elapsed,
            1.0,
            "Gamification checks took too long: \(elapsed)s for \(iterations * 200) operations"
        )
    }

    func testStreakManagerPerformance() {
        let manager = StreakManager()
        let calendar = Calendar.current
        let baseDate = Date()
        let completions = (0..<365).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: baseDate)
        }

        measure {
            for _ in 0..<200 {
                _ = manager.calculateStreak(completions: completions)
                _ = manager.getStatistics(completions: completions)
            }
        }
    }

    func testAchievementServiceDefaultCreationPerformance() {
        measure {
            for _ in 0..<250 {
                _ = AchievementService.createDefaultAchievements()
            }
        }
    }

    func testQuestGenerationPerformance() {
        measure {
            for _ in 0..<500 {
                _ = QuestService.shared.generateDailyQuests()
            }
        }
    }

    func testExportFilenameGenerationPerformance() {
        measure {
            for _ in 0..<2_000 {
                _ = DataExportService.generateExportFilename()
            }
        }
    }
}
