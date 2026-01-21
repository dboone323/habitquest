@testable import HabitQuest
import SwiftData
import XCTest

// Mock Notification Center
final class MockNotificationCenter: NotificationCenterProtocol, @unchecked Sendable {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var removedAllCount = 0

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }

    func removeAllPendingNotificationRequests() {
        removedAllCount += 1
    }
}

@MainActor
final class NotificationSchedulerServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var notificationService: NotificationSchedulerService!
    var mockCenter: MockNotificationCenter!
    var analyticsEngine: AdvancedAnalyticsEngine!
    var streakService: StreakService!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Habit.self, HabitLog.self, configurations: config)
        modelContext = modelContainer.mainContext

        mockCenter = MockNotificationCenter()

        // Setup complex dependency chain for Analytics Engine
        streakService = StreakService(modelContext: modelContext)
        analyticsEngine = AdvancedAnalyticsEngine(modelContext: modelContext, streakService: streakService)

        notificationService = NotificationSchedulerService(
            modelContext: modelContext,
            analyticsEngine: analyticsEngine,
            notificationCenter: mockCenter
        )
    }

    func testScheduleSmartNotifications() async throws {
        // Given
        let habit1 = Habit(name: "Morning Run", habitDescription: "Run 5km", frequency: .daily, category: .fitness)
        let habit2 = Habit(name: "Read Book", habitDescription: "10 pages", frequency: .daily, category: .learning)

        // Habit 2 is inactive, should be skipped
        habit2.isActive = false

        modelContext.insert(habit1)
        modelContext.insert(habit2)
        try? modelContext.save()

        // When
        await notificationService.scheduleSmartNotifications()

        // Then
        XCTAssertEqual(mockCenter.addedRequests.count, 1, "Should only schedule for active habits")

        let request = try XCTUnwrap(mockCenter.addedRequests.first)
        XCTAssertTrue(request.identifier.contains(habit1.id.uuidString))
        XCTAssertEqual(request.content.title, "✨ Time for Morning Run") // Default title for new habit
    }

    func testScheduleOptimalNotification_WithHighStreak() async throws {
        // Given
        let habit = Habit(name: "Meditation", habitDescription: "10 mins", frequency: .daily, category: .mindfulness)
        modelContext.insert(habit)

        // Simulate high streak (21 days)
        habit.streak = 21
        let today = Date()

        // Add logs to support high probability prediction (consistency)
        for i in 0 ..< 21 {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: today) {
                let log = HabitLog(habit: habit, completionDate: date, isCompleted: true)
                habit.logs.append(log)
            }
        }
        try? modelContext.save()

        // When
        await notificationService.scheduleOptimalNotification(for: habit)

        // Then
        let request = try XCTUnwrap(mockCenter.addedRequests.first)
        // High streak title pattern
        XCTAssertTrue(request.content.title.contains("Keep the 21-day streak alive") || request.content.title
            .contains("days strong"))
    }

    func testCancelNotifications() async {
        let id = UUID()
        await notificationService.cancelNotifications(for: id)

        XCTAssertTrue(mockCenter.removedIdentifiers.contains("habit_\(id.uuidString)"))
    }
}
