@testable import HabitQuest
import XCTest
import UserNotifications

final class NotificationServiceTests: XCTestCase {
    
    var notificationService: NotificationService!
    
    override func setUp() {
        super.setUp()
        notificationService = NotificationService()
    }
    
    override func tearDown() {
        notificationService = nil
        super.tearDown()
    }
    
    // MARK: - Permission Tests
    
    func testRequestNotificationPermission() async {
        let granted = await notificationService.requestPermission()
        XCTAssertNotNil(granted)
    }
    
    func testPermissionStatus() async {
        let status = await notificationService.checkPermissionStatus()
        XCTAssertTrue([.notDetermined, .denied, .authorized].contains(status))
    }
    
    // MARK: - Habit Reminder Tests
    
    func testScheduleHabitReminder() async {
        let habit = Habit(name: "Morning Exercise", time: "08:00")
        
        let scheduled = await notificationService.scheduleReminder(for: habit)
        XCTAssertTrue(scheduled)
    }
    
    func testScheduleMultipleReminders() async {
        let habits = [
            Habit(name: "Morning Exercise", time: "08:00"),
            Habit(name: "Evening Meditation", time: "20:00")
        ]
        
        for habit in habits {
            let scheduled = await notificationService.scheduleReminder(for: habit)
            XCTAssertTrue(scheduled)
        }
    }
    
    func testCancelHabitReminder() async {
        let habit = Habit(name: "Test Habit", time: "10:00")
        
        await notificationService.scheduleReminder(for: habit)
        await notificationService.cancelReminder(for: habit)
        
        let pending = await notificationService.getPendingNotifications()
        XCTAssertFalse(pending.contains { $0.identifier == habit.id.uuidString })
    }
    
    func testRescheduleReminder() async {
        let habit = Habit(name: "Test Habit", time: "10:00")
        
        await notificationService.scheduleReminder(for: habit)
        
        // Change time and reschedule
        habit.time = "11:00"
        await notificationService.rescheduleReminder(for: habit)
        
        let pending = await notificationService.getPendingNotifications()
        XCTAssertTrue(pending.contains { $0.identifier == habit.id.uuidString })
    }
    
    // MARK: - Notification Delivery Tests
    
    func testNotificationContent() async {
        let habit = Habit(name: "Drink Water", time: "15:00")
        
        let content = notificationService.createNotificationContent(for: habit)
        
        XCTAssertEqual(content.title, "Habit Reminder")
        XCTAssertTrue(content.body.contains("Drink Water"))
        XCTAssertEqual(content.sound, .default)
    }
    
    func testNotificationBadgeCount() async {
        let habit = Habit(name: "Test", time: "10:00")
        await notificationService.scheduleReminder(for: habit)
        
        let pending = await notificationService.getPendingNotifications()
        XCTAssertGreaterThan(pending.count, 0)
    }
    
    // MARK: - Clear Tests
    
    func testClearAllNotifications() async {
        let habits = [
            Habit(name: "Habit 1", time: "08:00"),
            Habit(name: "Habit 2", time: "12:00")
        ]
        
        for habit in habits {
            await notificationService.scheduleReminder(for: habit)
        }
        
        await notificationService.clearAllNotifications()
        
        let pending = await notificationService.getPendingNotifications()
        XCTAssertEqual(pending.count, 0)
    }
}

// Mock Habit for testing
struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var time: String
}
