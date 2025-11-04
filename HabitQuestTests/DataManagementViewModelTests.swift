@testable import HabitQuest
import SwiftData
import XCTest

@MainActor
final class DataManagementViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: DataManagementViewModel!

    override func setUp() {
        super.setUp()
        do {
            self.modelContainer = try ModelContainer(
                for: Habit.self, HabitLog.self, Achievement.self, PlayerProfile.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            self.modelContext = ModelContext(self.modelContainer)
            // viewModel will be initialized in each test method
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        self.viewModel = nil
        self.modelContext = nil
        self.modelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    @MainActor func testDataManagementViewModelInitialization() {
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

    @MainActor func testSetModelContextLoadsStatistics() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
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

        self.modelContext.insert(habit)
        self.modelContext.insert(log)
        self.modelContext.insert(achievement)
        self.modelContext.insert(profile)

        // When setting model context
        self.viewModel.setModelContext(self.modelContext)

        // Then statistics should be loaded
        XCTAssertEqual(self.viewModel.totalHabits, 1)
        XCTAssertEqual(self.viewModel.totalCompletions, 1)
        XCTAssertEqual(self.viewModel.unlockedAchievements, 1)
        XCTAssertEqual(self.viewModel.currentLevel, 5)
    }

    @MainActor func testSetModelContextWithEmptyData() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // When setting model context with no data
        self.viewModel.setModelContext(self.modelContext)

        // Then statistics should be zero/default
        XCTAssertEqual(self.viewModel.totalHabits, 0)
        XCTAssertEqual(self.viewModel.totalCompletions, 0)
        XCTAssertEqual(self.viewModel.unlockedAchievements, 0)
        XCTAssertEqual(self.viewModel.currentLevel, 1)
    }

    // MARK: - Export Tests

    @MainActor func testExportFilenameGeneration() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Test that filename is generated correctly
        let filename = self.viewModel.exportFilename

        // Should contain "HabitQuest_Backup_" and current date
        XCTAssertTrue(filename.hasPrefix("HabitQuest_Backup_"))
        XCTAssertTrue(filename.hasSuffix(".json"))
    }

    @MainActor func testExportDataSuccess() async throws {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given data in the model context
        let habit = Habit(name: "Test Habit", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let profile = PlayerProfile()
        self.modelContext.insert(habit)
        self.modelContext.insert(profile)

        self.viewModel.setModelContext(self.modelContext)

        // When exporting data
        self.viewModel.exportData()

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then export should succeed
        XCTAssertFalse(self.viewModel.isExporting)
        XCTAssertNotNil(self.viewModel.exportDocument)
        XCTAssertTrue(self.viewModel.showingFileExporter)
    }

    @MainActor func testExportDataWithoutModelContext() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // When exporting without model context
        self.viewModel.exportData()

        // Then nothing should happen (no crash)
        XCTAssertFalse(self.viewModel.isExporting)
        XCTAssertNil(self.viewModel.exportDocument)
        XCTAssertFalse(self.viewModel.showingFileExporter)
    }

    @MainActor func testHandleExportResultSuccess() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given
        let mockURL = URL(fileURLWithPath: "/test/path/backup.json")

        // When handling successful export result
        self.viewModel.handleExportResult(.success(mockURL))

        // Then success state should be shown
        XCTAssertTrue(self.viewModel.showingExportSuccess)
        XCTAssertNotEqual(self.viewModel.lastBackupDate, "Never")
    }

    @MainActor func testHandleExportResultFailure() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given
        let mockError = NSError(domain: "Test", code: 1, userInfo: nil)

        // When handling failed export result
        self.viewModel.handleExportResult(.failure(mockError))

        // Then error should be shown
        XCTAssertTrue(self.viewModel.showingError)
        XCTAssertFalse(self.viewModel.errorMessage.isEmpty)
    }

    // MARK: - Import Tests

    @MainActor func testImportDataShowsFileImporter() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // When calling import data
        self.viewModel.importData()

        // Then file importer should be shown
        XCTAssertTrue(self.viewModel.showingFileImporter)
    }

    @MainActor func testHandleImportResultSuccess() async throws {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given a temporary file with valid export data
        let habit = Habit(name: "Import Test", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let profile = PlayerProfile()
        self.modelContext.insert(habit)
        self.modelContext.insert(profile)

        let exportData = try DataExportService.exportUserData(from: self.modelContext)

        // Create temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_import.json")
        try exportData.write(to: tempURL)

        self.viewModel.setModelContext(self.modelContext)

        // When handling successful import result
        self.viewModel.handleImportResult(.success([tempURL]))

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then import should succeed
        XCTAssertFalse(self.viewModel.isImporting)
        XCTAssertTrue(self.viewModel.showingImportSuccess)

        // Clean up
        try? FileManager.default.removeItem(at: tempURL)
    }

    @MainActor func testHandleImportResultFailure() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given
        let mockError = NSError(domain: "Test", code: 1, userInfo: nil)

        // When handling failed import result
        self.viewModel.handleImportResult(.failure(mockError))

        // Then error should be shown
        XCTAssertTrue(self.viewModel.showingError)
        XCTAssertFalse(self.viewModel.errorMessage.isEmpty)
    }

    // MARK: - Clear Data Tests

    @MainActor func testClearAllDataSuccess() async throws {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
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

        self.modelContext.insert(habit)
        self.modelContext.insert(log)
        self.modelContext.insert(achievement)
        self.modelContext.insert(profile)

        self.viewModel.setModelContext(self.modelContext)

        // Verify data exists
        XCTAssertEqual(self.viewModel.totalHabits, 1)
        XCTAssertEqual(self.viewModel.totalCompletions, 1)
        XCTAssertEqual(self.viewModel.unlockedAchievements, 0) // Not unlocked
        XCTAssertEqual(self.viewModel.currentLevel, 1)

        // When clearing all data
        self.viewModel.clearAllData()

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then data should be cleared and statistics updated
        XCTAssertEqual(self.viewModel.totalHabits, 0)
        XCTAssertEqual(self.viewModel.totalCompletions, 0)
        XCTAssertEqual(self.viewModel.unlockedAchievements, 0)
        XCTAssertEqual(self.viewModel.currentLevel, 1) // Profile recreated with default level
        XCTAssertEqual(self.viewModel.lastBackupDate, "Never")
    }

    @MainActor func testClearAllDataWithoutModelContext() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // When clearing data without model context
        self.viewModel.clearAllData()

        // Then nothing should happen (no crash)
        XCTAssertEqual(self.viewModel.totalHabits, 0)
    }

    // MARK: - Property Tests

    @MainActor func testPublishedProperties() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Test that all published properties can be set
        self.viewModel.isExporting = true
        self.viewModel.isImporting = true
        self.viewModel.showingFileExporter = true
        self.viewModel.showingFileImporter = true
        self.viewModel.showingExportSuccess = true
        self.viewModel.showingImportSuccess = true
        self.viewModel.showingClearDataAlert = true
        self.viewModel.showingError = true
        self.viewModel.errorMessage = "Test error"
        self.viewModel.totalHabits = 5
        self.viewModel.totalCompletions = 10
        self.viewModel.unlockedAchievements = 3
        self.viewModel.currentLevel = 7
        self.viewModel.lastBackupDate = "2024-01-01"

        // Verify values are set
        XCTAssertTrue(self.viewModel.isExporting)
        XCTAssertTrue(self.viewModel.isImporting)
        XCTAssertTrue(self.viewModel.showingFileExporter)
        XCTAssertTrue(self.viewModel.showingFileImporter)
        XCTAssertTrue(self.viewModel.showingExportSuccess)
        XCTAssertTrue(self.viewModel.showingImportSuccess)
        XCTAssertTrue(self.viewModel.showingClearDataAlert)
        XCTAssertTrue(self.viewModel.showingError)
        XCTAssertEqual(self.viewModel.errorMessage, "Test error")
        XCTAssertEqual(self.viewModel.totalHabits, 5)
        XCTAssertEqual(self.viewModel.totalCompletions, 10)
        XCTAssertEqual(self.viewModel.unlockedAchievements, 3)
        XCTAssertEqual(self.viewModel.currentLevel, 7)
        XCTAssertEqual(self.viewModel.lastBackupDate, "2024-01-01")
    }

    // MARK: - Statistics Loading Tests

    @MainActor func testLoadDataStatisticsWithMultipleAchievements() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
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

        self.modelContext.insert(achievement1)
        self.modelContext.insert(achievement2)
        self.modelContext.insert(achievement3)

        // When loading statistics
        self.viewModel.setModelContext(self.modelContext)

        // Then only unlocked achievements should be counted
        XCTAssertEqual(self.viewModel.unlockedAchievements, 2)
    }

    @MainActor func testLoadDataStatisticsWithMultipleHabitsAndLogs() {
        // Initialize viewModel
        self.viewModel = DataManagementViewModel()
        // Given multiple habits and logs
        let habit1 = Habit(name: "Habit 1", habitDescription: "Test", frequency: .daily, xpValue: 10)
        let habit2 = Habit(name: "Habit 2", habitDescription: "Test", frequency: .daily, xpValue: 10)

        let log1 = HabitLog(habit: habit1, completionDate: Date())
        let log2 = HabitLog(habit: habit1, completionDate: Date().addingTimeInterval(-3600))
        let log3 = HabitLog(habit: habit2, completionDate: Date())

        self.modelContext.insert(habit1)
        self.modelContext.insert(habit2)
        self.modelContext.insert(log1)
        self.modelContext.insert(log2)
        self.modelContext.insert(log3)

        // When loading statistics
        self.viewModel.setModelContext(self.modelContext)

        // Then counts should be correct
        XCTAssertEqual(self.viewModel.totalHabits, 2)
        XCTAssertEqual(self.viewModel.totalCompletions, 3)
    }
}
