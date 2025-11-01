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
        XCTAssertEqual(self.viewModel.state.level, 1)
        XCTAssertEqual(self.viewModel.state.currentXP, 0)
        XCTAssertEqual(self.viewModel.state.xpForNextLevel, 100)
        XCTAssertEqual(self.viewModel.state.xpProgress, 0.0)
        XCTAssertEqual(self.viewModel.state.longestStreak, 0)
        XCTAssertEqual(self.viewModel.state.totalHabits, 0)
        XCTAssertEqual(self.viewModel.state.completedToday, 0)
        XCTAssertTrue(self.viewModel.state.achievements.isEmpty)
    }

    @MainActor
    func testSetModelContextCreatesDefaultProfile() {
        // When setting model context with no existing profile
        self.viewModel = ProfileViewModel()

        let expectation = XCTestExpectation(description: "Profile creation completes")

        // Just check that setModelContext doesn't throw
        XCTAssertNoThrow(self.viewModel.handle(.setModelContext(self.modelContext)))

        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // And profile should exist in database
            let fetchDescriptor = FetchDescriptor<PlayerProfile>()
            do {
                let profiles = try self.modelContext.fetch(fetchDescriptor)
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
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadStatisticsWithHabits() {
        // Given some habits in the database
        self.viewModel = ProfileViewModel()
        let habit1 = Habit(name: "Test Habit 1", habitDescription: "Description 1", frequency: .daily)
        let habit2 = Habit(name: "Test Habit 2", habitDescription: "Description 2", frequency: .daily)
        self.modelContext.insert(habit1)
        self.modelContext.insert(habit2)

        let expectation = XCTestExpectation(description: "Statistics loading completes")

        // When loading statistics
        self.viewModel.handle(.setModelContext(self.modelContext))

        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then statistics should be updated
            XCTAssertEqual(self.viewModel.state.totalHabits, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadStatisticsWithCompletedHabitsToday() {
        // Given a habit with today's completion
        self.viewModel = ProfileViewModel()
        let habit = Habit(name: "Daily Habit", habitDescription: "Complete daily", frequency: .daily)
        let todayLog = HabitLog(habit: habit, completionDate: Date())
        habit.logs.append(todayLog)
        self.modelContext.insert(habit)

        let expectation = XCTestExpectation(description: "Statistics loading completes")

        // When loading statistics
        self.viewModel.handle(.setModelContext(self.modelContext))

        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then completed today should be 1
            XCTAssertEqual(self.viewModel.state.completedToday, 1)
            XCTAssertEqual(self.viewModel.state.totalHabits, 1)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadAchievementsCreatesDefaults() {
        // When setting model context
        self.viewModel = ProfileViewModel()

        let expectation = XCTestExpectation(description: "Achievements loading completes")

        self.viewModel.handle(.setModelContext(self.modelContext))

        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then default achievements should be created
            XCTAssertFalse(self.viewModel.state.achievements.isEmpty)

            // And they should exist in database
            let fetchDescriptor = FetchDescriptor<Achievement>()
            do {
                let achievements = try self.modelContext.fetch(fetchDescriptor)
                XCTAssertFalse(achievements.isEmpty)
                XCTAssertEqual(achievements.count, self.viewModel.state.achievements.count)
            } catch {
                XCTFail("Failed to fetch achievements: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testRefreshProfileReloadsData() {
        // Given initial setup
        self.viewModel = ProfileViewModel()
        self.viewModel.handle(.setModelContext(self.modelContext))

        let expectation = XCTestExpectation(description: "Initial setup completes")

        // Wait for initial setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let initialTotalHabits = self.viewModel.state.totalHabits

            // When adding a new habit and refreshing
            let newHabit = Habit(name: "New Habit", habitDescription: "New habit", frequency: .daily)
            self.modelContext.insert(newHabit)

            self.viewModel.handle(.refreshProfile)

            // Wait for refresh to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then data should be refreshed
                XCTAssertEqual(self.viewModel.state.totalHabits, initialTotalHabits + 1)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
