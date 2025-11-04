@testable import HabitQuest
import SwiftData
import XCTest

final class ProfileViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: ProfileViewModel!

    override func setUp() {
        super.setUp()
        do {
            self.modelContainer = try ModelContainer(
                for: Habit.self,
                HabitLog.self,
                PlayerProfile.self,
                Achievement.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            self.modelContext = ModelContext(self.modelContainer)
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        self.modelContainer = nil
        self.modelContext = nil
        self.viewModel = nil
        super.tearDown()
    }

    // MARK: - ProfileViewModel Tests

    @MainActor
    func testProfileViewModelInitialization() {
        // Test basic initialization
        self.viewModel = ProfileViewModel()
        XCTAssertEqual(self.viewModel.level, 1)
        XCTAssertEqual(self.viewModel.currentXP, 0)
        XCTAssertEqual(self.viewModel.xpForNextLevel, 100)
        XCTAssertEqual(self.viewModel.xpProgress, 0.0)
        XCTAssertEqual(self.viewModel.longestStreak, 0)
        XCTAssertEqual(self.viewModel.totalHabits, 0)
        XCTAssertEqual(self.viewModel.completedToday, 0)
        XCTAssertTrue(self.viewModel.achievements.isEmpty)
    }

    @MainActor
    func testSetModelContextCreatesDefaultProfile() {
        // When setting model context with no existing profile
        self.viewModel = ProfileViewModel()

        // Just check that setModelContext doesn't throw
        XCTAssertNoThrow(self.viewModel.setModelContext(self.modelContext))

        // And profile should exist in database
        let fetchDescriptor = FetchDescriptor<PlayerProfile>()
        do {
            let profiles = try modelContext.fetch(fetchDescriptor)
            print("DEBUG: Found \(profiles.count) profiles in database")
            XCTAssertEqual(profiles.count, 1, "Should have exactly 1 profile")
            if let profile = profiles.first {
                print("DEBUG: Profile level: \(profile.level), currentXP: \(profile.currentXP)")
                XCTAssertEqual(profile.level, 1, "Profile level should be 1")
                XCTAssertEqual(profile.currentXP, 0, "Profile currentXP should be 0")
            }
        } catch {
            print("Failed to fetch profile: \(error)")
            XCTFail("Failed to fetch profile: \(error)")
        }
    }

    @MainActor
    func testLoadStatisticsWithHabits() {
        // Given some habits in the database
        self.viewModel = ProfileViewModel()
        let habit1 = Habit(name: "Test Habit 1", habitDescription: "Description 1", frequency: .daily)
        let habit2 = Habit(name: "Test Habit 2", habitDescription: "Description 2", frequency: .daily)
        self.modelContext.insert(habit1)
        self.modelContext.insert(habit2)

        // When loading statistics
        self.viewModel.setModelContext(self.modelContext)

        // Then statistics should be updated
        XCTAssertEqual(self.viewModel.totalHabits, 2)
    }

    @MainActor
    func testLoadStatisticsWithCompletedHabitsToday() {
        // Given a habit with today's completion
        self.viewModel = ProfileViewModel()
        let habit = Habit(name: "Daily Habit", habitDescription: "Complete daily", frequency: .daily)
        let todayLog = HabitLog(habit: habit, completionDate: Date())
        habit.logs.append(todayLog)
        self.modelContext.insert(habit)

        // When loading statistics
        self.viewModel.setModelContext(self.modelContext)

        // Then completed today should be 1
        XCTAssertEqual(self.viewModel.completedToday, 1)
        XCTAssertEqual(self.viewModel.totalHabits, 1)
    }

    @MainActor
    func testLoadAchievementsCreatesDefaults() {
        // When setting model context
        self.viewModel = ProfileViewModel()
        self.viewModel.setModelContext(self.modelContext)

        // Then default achievements should be created
        XCTAssertFalse(self.viewModel.achievements.isEmpty)

        // And they should exist in database
        let fetchDescriptor = FetchDescriptor<Achievement>()
        do {
            let achievements = try modelContext.fetch(fetchDescriptor)
            XCTAssertFalse(achievements.isEmpty)
            XCTAssertEqual(achievements.count, self.viewModel.achievements.count)
        } catch {
            XCTFail("Failed to fetch achievements: \(error)")
        }
    }

    @MainActor
    func testRefreshProfileReloadsData() {
        // Given initial setup
        self.viewModel = ProfileViewModel()
        self.viewModel.setModelContext(self.modelContext)
        let initialTotalHabits = self.viewModel.totalHabits

        // When adding a new habit and refreshing
        let newHabit = Habit(name: "New Habit", habitDescription: "New habit", frequency: .daily)
        self.modelContext.insert(newHabit)
        self.viewModel.refreshProfile()

        // Then data should be refreshed
        XCTAssertEqual(self.viewModel.totalHabits, initialTotalHabits + 1)
    }
}
