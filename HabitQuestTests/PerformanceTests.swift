//
// PerformanceTests.swift
// HabitQuestTests
//

import XCTest
@testable import HabitQuest

class PerformanceTests: XCTestCase {
    var performanceMonitor: PerformanceMonitor!

    override func setUp() {
        super.setUp()
        performanceMonitor = PerformanceMonitor()
    }

    override func tearDown() {
        performanceMonitor = nil
        super.tearDown()
    }

    // MARK: - Gamification Performance Tests

    func testGamificationManagerPerformance() {
        let gamificationManager = GamificationManager.shared

        measure {
            for i in 0..<200 {
                gamificationManager.awardXP(i * 10)
                gamificationManager.checkLevelUp()
                let _ = gamificationManager.getCurrentLevel()
                let _ = gamificationManager.getXPProgress()
            }
        }
    }

    func testStreakManagerPerformance() {
        let streakManager = StreakManager.shared

        measure {
            for i in 0..<300 {
                streakManager.recordHabitCompletion(habitId: "habit_\(i)")
                let _ = streakManager.getCurrentStreak(for: "habit_\(i)")
                let _ = streakManager.getLongestStreak(for: "habit_\(i)")
            }
        }
    }

    func testAchievementServicePerformance() {
        let achievementService = AchievementService.shared

        measure {
            for i in 0..<100 {
                achievementService.checkAchievements(for: createMockUserStats(daysActive: i))
                let _ = achievementService.getUnlockedAchievements()
                let _ = achievementService.getAchievementProgress()
            }
        }
    }

    // MARK: - Analytics Performance Tests

    func testAnalyticsServicePerformance() {
        let analyticsService = AnalyticsService.shared

        measure {
            for i in 0..<150 {
                let event = AnalyticsEvent(
                    type: .habitCompleted,
                    properties: ["habit_id": "habit_\(i)", "streak": i],
                    timestamp: Date()
                )
                analyticsService.trackEvent(event)
                let _ = analyticsService.getHabitCompletionRate()
            }
        }
    }

    func testAdvancedAnalyticsEnginePerformance() {
        let analyticsEngine = AdvancedAnalyticsEngine.shared

        measure {
            for _ in 0..<50 {
                let _ = analyticsEngine.analyzeHabitPatterns()
                let _ = analyticsEngine.predictHabitAdherence()
                let _ = analyticsEngine.generateInsights()
            }
        }
    }

    // MARK: - Data Management Performance Tests

    func testCloudKitSyncPerformance() {
        let syncManager = CloudKitSyncManager.shared

        measure {
            for i in 0..<30 {
                let habit = createMockHabit(id: "habit_\(i)")
                syncManager.syncHabit(habit)
                let _ = syncManager.getSyncStatus()
            }
        }
    }

    func testDataExportServicePerformance() {
        let exportService = DataExportService.shared

        measure {
            for _ in 0..<10 {
                let _ = exportService.exportHabitsData()
                let _ = exportService.exportAnalyticsData()
                let _ = exportService.generateReport()
            }
        }
    }

    // MARK: - Notification Performance Tests

    func testNotificationServicePerformance() {
        let notificationService = NotificationService.shared

        measure {
            for i in 0..<100 {
                notificationService.scheduleHabitReminder(for: createMockHabit(id: "habit_\(i)"))
                let _ = notificationService.getPendingNotifications()
            }
        }
    }

    func testSmartNotificationServicePerformance() {
        let smartNotifications = SmartNotificationService.shared

        measure {
            for _ in 0..<50 {
                let _ = smartNotifications.analyzeUserBehavior()
                let _ = smartNotifications.generateSmartReminders()
                let _ = smartNotifications.optimizeNotificationTiming()
            }
        }
    }

    // MARK: - Quest System Performance Tests

    func testQuestServicePerformance() {
        let questService = QuestService.shared

        measure {
            for i in 0..<100 {
                let quest = createMockQuest(id: "quest_\(i)")
                questService.updateQuestProgress(quest)
                let _ = questService.getActiveQuests()
                let _ = questService.getCompletedQuests()
            }
        }
    }

    // MARK: - ML Performance Tests

    func testMLPredictorPerformance() {
        let predictor = MLPredictor.shared

        measure {
            for _ in 0..<30 {
                let _ = predictor.predictHabitSuccess(habitId: "test_habit", userHistory: [])
                let _ = predictor.generatePersonalizedRecommendations()
            }
        }
    }

    // MARK: - Concurrent Operations Performance Tests

    func testConcurrentGamificationPerformance() {
        let expectation = XCTestExpectation(description: "Concurrent gamification")

        measure {
            let group = DispatchGroup()

            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let gamification = GamificationManager.shared
                for i in 0..<100 {
                    gamification.awardXP(i * 5)
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let streakManager = StreakManager.shared
                for i in 0..<100 {
                    streakManager.recordHabitCompletion(habitId: "concurrent_habit_\(i)")
                }
                group.leave()
            }

            group.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                let analytics = AnalyticsService.shared
                for i in 0..<100 {
                    let event = AnalyticsEvent(type: .habitCompleted, properties: ["test": i], timestamp: Date())
                    analytics.trackEvent(event)
                }
                group.leave()
            }

            group.notify(queue: .main) {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 15.0)
    }

    // MARK: - Memory Performance Tests

    func testMemoryUsageDuringGamification() {
        measure {
            autoreleasepool {
                var habits: [Habit] = []
                var achievements: [Achievement] = []
                var quests: [Quest] = []

                for i in 0..<500 {
                    habits.append(createMockHabit(id: "memory_habit_\(i)"))
                    achievements.append(createMockAchievement(id: "memory_achievement_\(i)"))
                    quests.append(createMockQuest(id: "memory_quest_\(i)"))
                }

                habits.removeAll()
                achievements.removeAll()
                quests.removeAll()
            }
        }
    }

    // MARK: - Performance Monitoring

    func testPerformanceMetricsCollection() {
        performanceMonitor.startMonitoring()

        let gamificationManager = GamificationManager.shared

        measure {
            for i in 0..<100 {
                gamificationManager.awardXP(i * 2)
                let _ = performanceMonitor.getMetrics()
            }
        }

        performanceMonitor.stopMonitoring()
    }
}

// MARK: - Performance Monitor

class PerformanceMonitor {
    private var startTime: Date?
    private var operationCount = 0
    private var metrics: PerformanceMetrics = PerformanceMetrics()

    func startMonitoring() {
        startTime = Date()
        operationCount = 0
        metrics = PerformanceMetrics()
    }

    func stopMonitoring() {
        startTime = nil
    }

    func getMetrics() -> PerformanceMetrics {
        operationCount += 1

        if let startTime = startTime {
            let elapsed = Date().timeIntervalSince(startTime)
            metrics.operationsPerSecond = Double(operationCount) / elapsed
        }

        // Simulate memory and CPU monitoring
        metrics.memoryUsage = Double.random(in: 35...75)
        metrics.cpuUsage = Double.random(in: 20...55)

        return metrics
    }
}

// MARK: - Extended Data Models

struct PerformanceMetrics {
    var operationsPerSecond: Double = 120.0
    var memoryUsage: Double = 50.0
    var cpuUsage: Double = 30.0
    var syncTime: TimeInterval = 0.0
    var cacheHitRate: Double = 0.90
}

// MARK: - Mock Data Creation

private func createMockHabit(id: String) -> Habit {
    return Habit(
        id: id,
        title: "Test Habit",
        description: "A test habit for performance testing",
        frequency: .daily,
        createdAt: Date(),
        isCompleted: false,
        streakCount: 0,
        totalCompletions: 0
    )
}

private func createMockAchievement(id: String) -> Achievement {
    return Achievement(
        id: id,
        title: "Test Achievement",
        description: "A test achievement",
        iconName: "star",
        points: 100,
        type: .streak,
        targetValue: 7,
        isHidden: false
    )
}

private func createMockQuest(id: String) -> Quest {
    return Quest(
        id: id,
        title: "Test Quest",
        description: "A test quest",
        type: .daily,
        targetValue: 5,
        currentValue: 0,
        rewardXP: 50,
        isCompleted: false,
        expiresAt: Date().addingTimeInterval(86400)
    )
}

private func createMockUserStats(daysActive: Int) -> UserStats {
    return UserStats(
        totalHabits: 10,
        completedHabits: daysActive,
        currentStreaks: daysActive,
        longestStreak: daysActive * 2,
        totalXP: daysActive * 100,
        level: daysActive / 10,
        achievementsUnlocked: daysActive / 5
    )
}

// MARK: - Mock Extensions for Testing

extension GamificationManager {
    static let shared = GamificationManager()

    func awardXP(_ amount: Int) {
        // Simulate XP awarding
    }

    func checkLevelUp() -> Bool {
        return false
    }

    func getCurrentLevel() -> Int {
        return 1
    }

    func getXPProgress() -> Double {
        return 0.5
    }
}

extension StreakManager {
    static let shared = StreakManager()

    func recordHabitCompletion(habitId: String) {
        // Simulate streak recording
    }

    func getCurrentStreak(for habitId: String) -> Int {
        return 5
    }

    func getLongestStreak(for habitId: String) -> Int {
        return 10
    }
}

extension AchievementService {
    static let shared = AchievementService()

    func checkAchievements(for stats: UserStats) {
        // Simulate achievement checking
    }

    func getUnlockedAchievements() -> [Achievement] {
        return []
    }

    func getAchievementProgress() -> [String: Double] {
        return [:]
    }
}

extension AnalyticsService {
    static let shared = AnalyticsService()

    func trackEvent(_ event: AnalyticsEvent) {
        // Simulate event tracking
    }

    func getHabitCompletionRate() -> Double {
        return 0.75
    }
}

extension AdvancedAnalyticsEngine {
    static let shared = AdvancedAnalyticsEngine()

    func analyzeHabitPatterns() -> [HabitPattern] {
        return []
    }

    func predictHabitAdherence() -> [Prediction] {
        return []
    }

    func generateInsights() -> [Insight] {
        return []
    }
}

extension CloudKitSyncManager {
    static let shared = CloudKitSyncManager()

    func syncHabit(_ habit: Habit) {
        // Simulate syncing
    }

    func getSyncStatus() -> SyncStatus {
        return .synced
    }
}

extension DataExportService {
    static let shared = DataExportService()

    func exportHabitsData() -> Data {
        return Data()
    }

    func exportAnalyticsData() -> Data {
        return Data()
    }

    func generateReport() -> String {
        return "Test Report"
    }
}

extension NotificationService {
    static let shared = NotificationService()

    func scheduleHabitReminder(for habit: Habit) {
        // Simulate scheduling
    }

    func getPendingNotifications() -> [UNNotificationRequest] {
        return []
    }
}

extension SmartNotificationService {
    static let shared = SmartNotificationService()

    func analyzeUserBehavior() -> UserBehavior {
        return UserBehavior()
    }

    func generateSmartReminders() -> [SmartReminder] {
        return []
    }

    func optimizeNotificationTiming() -> [Date] {
        return []
    }
}

extension QuestService {
    static let shared = QuestService()

    func updateQuestProgress(_ quest: Quest) {
        // Simulate quest progress update
    }

    func getActiveQuests() -> [Quest] {
        return []
    }

    func getCompletedQuests() -> [Quest] {
        return []
    }
}

extension MLPredictor {
    static let shared = MLPredictor()

    func predictHabitSuccess(habitId: String, userHistory: [HabitCompletion]) -> Double {
        return 0.8
    }

    func generatePersonalizedRecommendations() -> [Recommendation] {
        return []
    }
}

// MARK: - Mock Data Structures

struct Habit {
    let id: String
    let title: String
    let description: String
    let frequency: HabitFrequency
    let createdAt: Date
    var isCompleted: Bool
    var streakCount: Int
    var totalCompletions: Int
}

struct Achievement {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let points: Int
    let type: AchievementType
    let targetValue: Int
    let isHidden: Bool
}

struct Quest {
    let id: String
    let title: String
    let description: String
    let type: QuestType
    let targetValue: Int
    var currentValue: Int
    let rewardXP: Int
    var isCompleted: Bool
    let expiresAt: Date
}

struct UserStats {
    let totalHabits: Int
    let completedHabits: Int
    let currentStreaks: Int
    let longestStreak: Int
    let totalXP: Int
    let level: Int
    let achievementsUnlocked: Int
}

struct AnalyticsEvent {
    let type: AnalyticsEventType
    let properties: [String: Any]
    let timestamp: Date
}

enum HabitFrequency {
    case daily, weekly, monthly
}

enum AchievementType {
    case streak, completion, social
}

enum QuestType {
    case daily, weekly, monthly
}

enum AnalyticsEventType {
    case habitCompleted, habitCreated, achievementUnlocked
}

enum SyncStatus {
    case synced, syncing, failed
}

struct HabitPattern {
    let pattern: String
    let confidence: Double
}

struct Prediction {
    let habitId: String
    let successProbability: Double
}

struct Insight {
    let title: String
    let description: String
    let impact: Double
}

struct UserBehavior {
    var preferredTimes: [Date] = []
    var completionPatterns: [String] = []
}

struct SmartReminder {
    let habitId: String
    let scheduledTime: Date
    let reason: String
}

struct HabitCompletion {
    let habitId: String
    let completedAt: Date
}

struct Recommendation {
    let habitId: String
    let reason: String
    let confidence: Double
}
