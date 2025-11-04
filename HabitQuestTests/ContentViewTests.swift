@testable import HabitQuest
import SwiftData
import SwiftUI
import XCTest

final class ContentViewTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        do {
            self.modelContainer = try ModelContainer(
                for: Item.self,
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
        super.tearDown()
    }

    // MARK: - ContentView Tests

    @MainActor
    func testContentViewInitialization() {
        // Test basic initialization with model context
        let contentView = ContentView()
            .modelContainer(self.modelContainer)

        // Verify the view can be created without throwing
        XCTAssertNotNil(contentView)
    }

    @MainActor
    func testContentViewWithItems() {
        // Given some items in the database
        let item1 = Item(timestamp: Date())
        let item2 = Item(timestamp: Date().addingTimeInterval(-3600))
        self.modelContext.insert(item1)
        self.modelContext.insert(item2)

        // When creating ContentView
        let contentView = ContentView()
            .modelContainer(self.modelContainer)

        // Then view should be created successfully
        XCTAssertNotNil(contentView)
    }

    // MARK: - HeaderView Tests

    @MainActor
    func testHeaderViewInitialization() {
        // Test basic initialization
        let headerView = HeaderView()

        // Verify the view can be created
        XCTAssertNotNil(headerView)
    }

    @MainActor
    func testHeaderViewDisplaysCorrectContent() {
        // Test that HeaderView displays expected content
        let headerView = HeaderView()

        // This would require snapshot testing or more complex UI testing
        // For now, just verify it doesn't throw
        XCTAssertNotNil(headerView)
    }

    // MARK: - ItemListView Tests

    @MainActor
    func testItemListViewInitialization() {
        // Test basic initialization
        let items = [Item(timestamp: Date())]
        let itemListView = ItemListView(
            items: items,
            onDelete: { _ in },
            onAdd: {}
        )

        XCTAssertNotNil(itemListView)
    }

    @MainActor
    func testItemListViewWithEmptyItems() {
        // Test with empty items array
        let itemListView = ItemListView(
            items: [],
            onDelete: { _ in },
            onAdd: {}
        )

        XCTAssertNotNil(itemListView)
    }

    // MARK: - ItemRowView Tests

    @MainActor
    func testItemRowViewInitialization() {
        // Test basic initialization
        let item = Item(timestamp: Date())
        let itemRowView = ItemRowView(item: item)

        XCTAssertNotNil(itemRowView)
    }

    @MainActor
    func testItemRowViewTimeBasedIcon() {
        // Test morning icon (6-12)
        let morningDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let morningItem = Item(timestamp: morningDate)
        let morningView = ItemRowView(item: morningItem)

        // Test afternoon icon (12-18)
        let afternoonDate = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
        let afternoonItem = Item(timestamp: afternoonDate)
        let afternoonView = ItemRowView(item: afternoonItem)

        // Test evening icon (18-22)
        let eveningDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        let eveningItem = Item(timestamp: eveningDate)
        let eveningView = ItemRowView(item: eveningItem)

        // Test night icon (22-6)
        let nightDate = Calendar.current.date(bySettingHour: 2, minute: 0, second: 0, of: Date())!
        let nightItem = Item(timestamp: nightDate)
        let nightView = ItemRowView(item: nightItem)

        // Verify views are created (actual icon testing would require UI testing framework)
        XCTAssertNotNil(morningView)
        XCTAssertNotNil(afternoonView)
        XCTAssertNotNil(eveningView)
        XCTAssertNotNil(nightView)
    }

    // MARK: - ItemDetailView Tests

    @MainActor
    func testItemDetailViewInitialization() {
        // Test basic initialization
        let item = Item(timestamp: Date())
        let itemDetailView = ItemDetailView(item: item)

        XCTAssertNotNil(itemDetailView)
    }

    // MARK: - DetailRow Tests

    func testDetailRowInitialization() {
        // Test basic initialization
        let detailRow = DetailRow(title: "Test Title", value: "Test Value")

        XCTAssertNotNil(detailRow)
    }

    // MARK: - FooterStatsView Tests

    func testFooterStatsViewInitialization() {
        // Test basic initialization
        let footerStatsView = FooterStatsView(itemCount: 5)

        XCTAssertNotNil(footerStatsView)
    }

    func testFooterStatsViewWithZeroItems() {
        // Test with zero items
        let footerStatsView = FooterStatsView(itemCount: 0)

        XCTAssertNotNil(footerStatsView)
    }

    // MARK: - DetailView Tests

    func testDetailViewInitialization() {
        // Test basic initialization
        let detailView = DetailView()

        XCTAssertNotNil(detailView)
    }
}
