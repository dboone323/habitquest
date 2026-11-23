import HabitQuestCore
import SwiftData
import SwiftUI
import XCTest
@testable import HabitQuest

final class ProfileViewTests: XCTestCase {
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

    // MARK: - ProfileView Tests

    @MainActor
    func testProfileViewInitialization() {
        let view = ProfileView()
        XCTAssertNotNil(view.body)
    }

    // MARK: - AchievementsSection Tests

    @MainActor
    func testAchievementsSectionEmptyState() {
        let section = AchievementsSection(achievements: [])
        XCTAssertNotNil(section.body)
    }

    @MainActor
    func testAchievementsSectionWithAchievements() {
        let achievements = AchievementService.createDefaultAchievements()
        var viewAllTapped = false
        var selectedAchievement: Achievement? = nil

        let section = AchievementsSection(
            achievements: achievements,
            onViewAll: {
                viewAllTapped = true
            },
            onSelectAchievement: { achievement in
                selectedAchievement = achievement
            }
        )

        XCTAssertNotNil(section.body)
        section.onViewAll()
        XCTAssertTrue(viewAllTapped, "Tapping View All invokes onViewAll closure")

        let first = achievements[0]
        section.onSelectAchievement(first)
        XCTAssertEqual(selectedAchievement?.name, first.name, "Tapping badge invokes onSelectAchievement closure")
    }

    @MainActor
    func testAchievementBadgeRendering() {
        let achievement = Achievement(
            name: "Week Warrior",
            description: "Maintain a 7-day streak",
            iconName: "flame.fill",
            category: .streak,
            xpReward: 100,
            requirement: .streakDays(7)
        )

        let badge = AchievementBadge(achievement: achievement)
        XCTAssertNotNil(badge.body)
        XCTAssertFalse(achievement.isUnlocked)

        achievement.unlockedDate = Date()
        XCTAssertTrue(achievement.isUnlocked)
        let unlockedBadge = AchievementBadge(achievement: achievement)
        XCTAssertNotNil(unlockedBadge.body)
    }

    // MARK: - AchievementGalleryView Tests (Issue #76)

    @MainActor
    func testAchievementGalleryViewInitialization() {
        let achievements = AchievementService.createDefaultAchievements()
        let gallery = AchievementGalleryView(achievements: achievements)
        XCTAssertNotNil(gallery.body)
    }

    @MainActor
    func testAchievementGalleryCardInteraction() {
        let achievement = Achievement(
            name: "Legend",
            description: "Maintain a 100-day streak",
            iconName: "crown.fill",
            category: .streak,
            xpReward: 1000,
            requirement: .streakDays(100)
        )

        var cardTapped = false
        let card = AchievementGalleryCard(achievement: achievement) {
            cardTapped = true
        }

        XCTAssertNotNil(card.body)
        card.onTap()
        XCTAssertTrue(cardTapped, "Tapping gallery card invokes onTap handler")
    }

    @MainActor
    func testAchievementDetailSheetRendering() {
        let achievement = Achievement(
            name: "Master Adventurer",
            description: "Reach level 25",
            iconName: "diamond.fill",
            category: .level,
            xpReward: 1000,
            requirement: .reachLevel(25)
        )
        achievement.progress = 0.4

        let sheet = AchievementDetailSheet(achievement: achievement)
        XCTAssertNotNil(sheet.body)
    }
}
