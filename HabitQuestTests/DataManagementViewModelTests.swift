import SwiftData
import XCTest
@testable import HabitQuest

final class DataManagementViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: DataManagementViewModel!

    override func setUp() {
        super.setUp()
        do {
            modelContainer = try ModelContainer(
                for: Habit.self, HabitLog.self, Achievement.self, PlayerProfile.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            modelContext = ModelContext(modelContainer)
            // viewModel will be initialized in each test method
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    @MainActor
    func testDataManagementViewModelInitialization() {
        // Test basic initialization
        self.viewModel = DataManagementViewModel()
        guard let viewModel else {
            XCTFail("Failed to create DataManagementViewModel")
            return
        }

        // Verify initial state
        XCTAssertFalse(viewModel.isExporting)
        XCTAssertFalse(viewModel.isImporting)
        XCTAssertFalse(viewModel.showingFileExporter)
        XCTAssertFalse(viewModel.showingFileImporter)
        XCTAssertFalse(viewModel.showingExportSuccess)
        XCTAssertFalse(viewModel.showingImportSuccess)
        XCTAssertFalse(viewModel.showingClearDataAlert)
        XCTAssertFalse(viewModel.showingError)
        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertEqual(viewModel.totalHabits, 0)
        XCTAssertEqual(viewModel.totalCompletions, 0)
        XCTAssertEqual(viewModel.unlockedAchievements, 0)
        XCTAssertEqual(viewModel.currentLevel, 1)
        XCTAssertEqual(viewModel.lastBackupDate, "Never")
        XCTAssertNil(viewModel.exportDocument)
    }

    // MARK: - Model Context Setup Tests

    @MainActor
    func testSetModelContextLoadsStatistics() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given some data in the model context
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let log = HabitLog(habit: habit, completionDate: Date())
        let achievement = Achievement(
            name: "Test Achievement",
            description: "Test",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        achievement.unlockedDate = Date()

        let profile = PlayerProfile()
        profile.level = 5

        modelContext.insert(habit)
        modelContext.insert(log)
        modelContext.insert(achievement)
        modelContext.insert(profile)

        // When setting model context
        viewModel.setModelContext(modelContext)

        // Then statistics should be loaded
        XCTAssertEqual(viewModel.totalHabits, 1)
        XCTAssertEqual(viewModel.totalCompletions, 1)
        XCTAssertEqual(viewModel.unlockedAchievements, 1)
        XCTAssertEqual(viewModel.currentLevel, 5)
    }

    @MainActor
    func testSetModelContextWithEmptyData() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // When setting model context with no data
        viewModel.setModelContext(modelContext)

        // Then statistics should be zero/default
        XCTAssertEqual(viewModel.totalHabits, 0)
        XCTAssertEqual(viewModel.totalCompletions, 0)
        XCTAssertEqual(viewModel.unlockedAchievements, 0)
        XCTAssertEqual(viewModel.currentLevel, 1)
    }

    // MARK: - Export Tests

    @MainActor
    func testExportFilenameGeneration() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Test that filename is generated correctly
        let filename = viewModel.exportFilename

        // Should contain "HabitQuest_Backup_" and current date
        XCTAssertTrue(filename.hasPrefix("HabitQuest_Backup_"))
        XCTAssertTrue(filename.hasSuffix(".json"))
    }

    @MainActor
    func testExportDataSuccess() async throws {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given data in the model context
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let profile = PlayerProfile()
        modelContext.insert(habit)
        modelContext.insert(profile)

        viewModel.setModelContext(modelContext)

        // When exporting data
        viewModel.exportData()

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then export should succeed
        XCTAssertFalse(viewModel.isExporting)
        XCTAssertNotNil(viewModel.exportDocument)
        XCTAssertTrue(viewModel.showingFileExporter)
    }

    @MainActor
    func testExportDataWithoutModelContext() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // When exporting without model context
        viewModel.exportData()

        // Then nothing should happen (no crash)
        XCTAssertFalse(viewModel.isExporting)
        XCTAssertNil(viewModel.exportDocument)
        XCTAssertFalse(viewModel.showingFileExporter)
    }

    @MainActor
    func testHandleExportResultSuccess() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given
        let mockURL = URL(fileURLWithPath: "/test/path/backup.json")

        // When handling successful export result
        viewModel.handleExportResult(.success(mockURL))

        // Then success state should be shown
        XCTAssertTrue(viewModel.showingExportSuccess)
        XCTAssertNotEqual(viewModel.lastBackupDate, "Never")
    }

    @MainActor
    func testHandleExportResultFailure() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given
        let mockError = NSError(domain: "Test", code: 1, userInfo: nil)

        // When handling failed export result
        viewModel.handleExportResult(.failure(mockError))

        // Then error should be shown
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(viewModel.errorMessage.isEmpty)
    }

    // MARK: - Import Tests

    @MainActor
    func testImportDataShowsFileImporter() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // When calling import data
        viewModel.importData()

        // Then file importer should be shown
        XCTAssertTrue(viewModel.showingFileImporter)
    }

    @MainActor
    func testHandleImportResultSuccess() async throws {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given a temporary file with valid export data
        let habit = Habit(name: "Import Test", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let profile = PlayerProfile()
        modelContext.insert(habit)
        modelContext.insert(profile)

        let exportData = try DataExportService.exportUserData(from: modelContext)

        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_import.json")
        try exportData.write(to: tempURL)

        viewModel.setModelContext(modelContext)

        // When handling successful import result
        viewModel.handleImportResult(.success([tempURL]))

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then import should succeed
        XCTAssertFalse(viewModel.isImporting)
        XCTAssertTrue(viewModel.showingImportSuccess)

        // Clean up
        try? FileManager.default.removeItem(at: tempURL)
    }

    @MainActor
    func testHandleImportResultFailure() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given
        let mockError = NSError(domain: "Test", code: 1, userInfo: nil)

        // When handling failed import result
        viewModel.handleImportResult(.failure(mockError))

        // Then error should be shown
        XCTAssertTrue(viewModel.showingError)
        XCTAssertFalse(viewModel.errorMessage.isEmpty)
    }

    // MARK: - Clear Data Tests

    @MainActor
    func testClearAllDataSuccess() async throws {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given data in the model context
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let log = HabitLog(habit: habit, completionDate: Date())
        let achievement = Achievement(
            name: "Test Achievement",
            description: "Test",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        let profile = PlayerProfile()

        modelContext.insert(habit)
        modelContext.insert(log)
        modelContext.insert(achievement)
        modelContext.insert(profile)

        viewModel.setModelContext(modelContext)

        // Verify data exists
        XCTAssertEqual(viewModel.totalHabits, 1)
        XCTAssertEqual(viewModel.totalCompletions, 1)
        XCTAssertEqual(viewModel.unlockedAchievements, 0) // Not unlocked
        XCTAssertEqual(viewModel.currentLevel, 1)

        // When clearing all data
        viewModel.clearAllData()

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then data should be cleared and statistics updated
        XCTAssertEqual(viewModel.totalHabits, 0)
        XCTAssertEqual(viewModel.totalCompletions, 0)
        XCTAssertEqual(viewModel.unlockedAchievements, 0)
        XCTAssertEqual(viewModel.currentLevel, 1) // Profile recreated with default level
        XCTAssertEqual(viewModel.lastBackupDate, "Never")
    }

    @MainActor
    func testClearAllDataWithoutModelContext() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // When clearing data without model context
        viewModel.clearAllData()

        // Then nothing should happen (no crash)
        XCTAssertEqual(viewModel.totalHabits, 0)
    }

    // MARK: - Property Tests

    @MainActor
    func testPublishedProperties() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Test that all published properties can be set
        viewModel.isExporting = true
        viewModel.isImporting = true
        viewModel.showingFileExporter = true
        viewModel.showingFileImporter = true
        viewModel.showingExportSuccess = true
        viewModel.showingImportSuccess = true
        viewModel.showingClearDataAlert = true
        viewModel.showingError = true
        viewModel.errorMessage = "Test error"
        viewModel.totalHabits = 5
        viewModel.totalCompletions = 10
        viewModel.unlockedAchievements = 3
        viewModel.currentLevel = 7
        viewModel.lastBackupDate = "2024-01-01"

        // Verify values are set
        XCTAssertTrue(viewModel.isExporting)
        XCTAssertTrue(viewModel.isImporting)
        XCTAssertTrue(viewModel.showingFileExporter)
        XCTAssertTrue(viewModel.showingFileImporter)
        XCTAssertTrue(viewModel.showingExportSuccess)
        XCTAssertTrue(viewModel.showingImportSuccess)
        XCTAssertTrue(viewModel.showingClearDataAlert)
        XCTAssertTrue(viewModel.showingError)
        XCTAssertEqual(viewModel.errorMessage, "Test error")
        XCTAssertEqual(viewModel.totalHabits, 5)
        XCTAssertEqual(viewModel.totalCompletions, 10)
        XCTAssertEqual(viewModel.unlockedAchievements, 3)
        XCTAssertEqual(viewModel.currentLevel, 7)
        XCTAssertEqual(viewModel.lastBackupDate, "2024-01-01")
    }

    // MARK: - Statistics Loading Tests

    @MainActor
    func testLoadDataStatisticsWithMultipleAchievements() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given multiple achievements, some unlocked
        let achievement1 = Achievement(
            name: "Achievement 1",
            description: "Test",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        achievement1.unlockedDate = Date()

        let achievement2 = Achievement(
            name: "Achievement 2",
            description: "Test",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        achievement2.unlockedDate = nil

        let achievement3 = Achievement(
            name: "Achievement 3",
            description: "Test",
            iconName: "star",
            category: .streak,
            xpReward: 50,
            isHidden: false,
            requirement: .streakDays(1)
        )
        achievement3.unlockedDate = Date()

        modelContext.insert(achievement1)
        modelContext.insert(achievement2)
        modelContext.insert(achievement3)

        // When loading statistics
        viewModel.setModelContext(modelContext)

        // Then only unlocked achievements should be counted
        XCTAssertEqual(viewModel.unlockedAchievements, 2)
    }

    @MainActor
    func testLoadDataStatisticsWithMultipleHabitsAndLogs() {
        // Initialize viewModel
        viewModel = DataManagementViewModel()
        // Given multiple habits and logs
        let habit1 = Habit(name: "Habit 1", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let habit2 = Habit(name: "Habit 2", habitDescription: "Test", frequency: .daily, xpValue: 10)

        let log1 = HabitLog(habit: habit1, completionDate: Date())
        let log2 = HabitLog(habit: habit1, completionDate: Date().addingTimeInterval(-3600))
        let log3 = HabitLog(habit: habit2, completionDate: Date())

        modelContext.insert(habit1)
        modelContext.insert(habit2)
        modelContext.insert(log1)
        modelContext.insert(log2)
        modelContext.insert(log3)

        // When loading statistics
        viewModel.setModelContext(modelContext)

        // Then counts should be correct
        XCTAssertEqual(viewModel.totalHabits, 2)
        XCTAssertEqual(viewModel.totalCompletions, 3)
    }
}
