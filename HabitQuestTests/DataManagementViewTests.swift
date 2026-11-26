import HabitQuestCore
import SwiftData
import SwiftUI
import XCTest
@testable import HabitQuest

final class DataManagementViewTests: XCTestCase {
    private var container: ModelContainer!
    private var modelContext: ModelContext!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainer(
            for: Habit.self, HabitLog.self, HabitQuestCore.Achievement.self, PlayerProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = ModelContext(container)
    }

    @MainActor
    override func tearDown() async throws {
        container = nil
        modelContext = nil
        try await super.tearDown()
    }

    @MainActor
    func testDataManagementViewInitialization() {
        let themeManager = ThemeManager()
        let controller = UIHostingController(
            rootView: DataManagementView().environmentObject(themeManager)
        )
        XCTAssertNotNil(controller.view)
    }

    @MainActor
    func testStreakForgivenessSectionLoadsValues() {
        let profile = PlayerProfile()
        profile.streakFreezes = 4
        modelContext.insert(profile)
        try? modelContext.save()

        let viewModel = DataManagementViewModel()
        viewModel.setModelContext(modelContext)

        XCTAssertEqual(viewModel.streakFreezes, 4)
        XCTAssertEqual(viewModel.forgivenessThreshold, StreakForgivenessConfig.defaultThreshold)

        // Modify threshold
        viewModel.forgivenessThreshold = 8
        XCTAssertEqual(StreakForgivenessConfig.threshold, 8)

        // Reset
        StreakForgivenessConfig.threshold = StreakForgivenessConfig.defaultThreshold
    }
}
