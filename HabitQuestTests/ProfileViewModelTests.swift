import SwiftData
import XCTest
@testable import HabitQuest

final class ProfileViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: ProfileViewModel!

    override func setUp() {
        super.setUp()
        do {
            modelContainer = try ModelContainer(
                for: Habit.self,
                HabitLog.self,
                PlayerProfile.self,
                Achievement.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            XCTFail("Failed to create model container: \(error)")
        }
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - ProfileViewModel Tests

    @MainActor
    func testProfileViewModelInitialization() {
        // Test basic initialization
        viewModel = ProfileViewModel()
        XCTAssertEqual(viewModel.level, 1)
        XCTAssertEqual(viewModel.currentXP, 0)
        XCTAssertEqual(viewModel.xpForNextLevel, 100)
        XCTAssertEqual(viewModel.xpProgress, 0.0)
        XCTAssertEqual(viewModel.longestStreak, 0)
        XCTAssertEqual(viewModel.totalHabits, 0)
        XCTAssertEqual(viewModel.completedToday, 0)
        XCTAssertTrue(viewModel.achievements.isEmpty)
    }

    @MainActor
    func testSetModelContextCreatesDefaultProfile() {
        // When setting model context with no existing profile
        viewModel = ProfileViewModel()

        // Just check that setModelContext doesn't throw
        XCTAssertNoThrow(viewModel.setModelContext(modelContext))

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
        viewModel = ProfileViewModel()
        let habit1 = Habit(name: "Test Habit 1", habitDescription: "Description 1", frequency: .daily)
        let habit2 = Habit(name: "Test Habit 2", habitDescription: "Description 2", frequency: .daily)
        modelContext.insert(habit1)
        modelContext.insert(habit2)

        // When loading statistics
        viewModel.setModelContext(modelContext)

        // Then statistics should be updated
        XCTAssertEqual(viewModel.totalHabits, 2)
    }

    @MainActor
    func testLoadStatisticsWithCompletedHabitsToday() {
        // Given a habit with today's completion
        viewModel = ProfileViewModel()
        let habit = Habit(name: "Daily Habit", habitDescription: "Complete daily", frequency: .daily)
        let todayLog = HabitLog(habit: habit, completionDate: Date())
        habit.logs.append(todayLog)
        modelContext.insert(habit)

        // When loading statistics
        viewModel.setModelContext(modelContext)

        // Then completed today should be 1
        XCTAssertEqual(viewModel.completedToday, 1)
        XCTAssertEqual(viewModel.totalHabits, 1)
    }

    @MainActor
    func testLoadAchievementsCreatesDefaults() {
        // When setting model context
        viewModel = ProfileViewModel()
        viewModel.setModelContext(modelContext)

        // Then default achievements should be created
        XCTAssertFalse(viewModel.achievements.isEmpty)

        // And they should exist in database
        let fetchDescriptor = FetchDescriptor<Achievement>()
        do {
            let achievements = try modelContext.fetch(fetchDescriptor)
            XCTAssertFalse(achievements.isEmpty)
            XCTAssertEqual(achievements.count, viewModel.achievements.count)
        } catch {
            XCTFail("Failed to fetch achievements: \(error)")
        }
    }

    @MainActor
    func testRefreshProfileReloadsData() {
        // Given initial setup
        viewModel = ProfileViewModel()
        viewModel.setModelContext(modelContext)
        let initialTotalHabits = viewModel.totalHabits

        // When adding a new habit and refreshing
        let newHabit = Habit(name: "New Habit", habitDescription: "New habit", frequency: .daily)
        modelContext.insert(newHabit)
        viewModel.refreshProfile()

        // Then data should be refreshed
        XCTAssertEqual(viewModel.totalHabits, initialTotalHabits + 1)
    }
}
