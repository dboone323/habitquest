import SwiftData
import XCTest

@testable import MomentumFinanceCore

final class DataImporterErrorTests: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([
            FinancialTransaction.self, FinancialAccount.self, ExpenseCategory.self,
        ])
        self.container = try ModelContainer(
            for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    func testEmptyCSV() async throws {
        let importer = DataImporter(modelContainer: container)
        let result = try await importer.importFromCSV("")
        XCTAssertFalse(result.success)
        XCTAssertTrue(result.errors.contains(where: { $0.contains("empty") }))
    }

    func testInvalidAmount() async throws {
        let importer = DataImporter(modelContainer: container)
        let csv = "date,title,amount\n2025-09-01,Bad,NOTNUM"
        let result = try await importer.importFromCSV(csv)
        XCTAssertEqual(result.itemsImported, 0)
        XCTAssertFalse(result.success)
        XCTAssertTrue(result.errors.first?.contains("Error importing line") == true)
    }

    func testPartialValidRows() async throws {
        let importer = DataImporter(modelContainer: container)
        let csv = "date,title,amount\n2025-09-01,Good,100\n2025-09-02,Bad,XYZ\n2025-09-03,Good2,50"
        let result = try await importer.importFromCSV(csv)
        XCTAssertEqual(result.itemsImported, 2)
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.errors.count, 1)
    }
}
