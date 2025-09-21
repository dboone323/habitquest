@testable import MomentumFinanceCore
import SwiftData
import XCTest

@MainActor
final class DataExporterContentTests: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([
            FinancialTransaction.self, FinancialAccount.self, ExpenseCategory.self,
        ])
        self.container = try ModelContainer(
            for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        // Seed 3 transactions (2 incomes, 1 expense)
        for i in 0 ..< 3 {
            let tx = FinancialTransaction(
                title: "SeedTx\(i)",
                amount: Double(100 + i),
                date: Date().addingTimeInterval(Double(i) * 60),
                transactionType: i == 2 ? .expense : .income,
                notes: i == 1 ? "Note, With Comma" : nil
            )
            context.insert(tx)
        }
        try context.save()
    }

    func testExporterIncludesHeaderAndRows() async throws {
        let start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let settings = ExportSettings(format: .csv, dateRange: .custom, startDate: start, endDate: end)
        let exporter = await DataExporter(modelContainer: container)
        let url = try await exporter.exportData(settings: settings)
        let content = try String(contentsOf: url)
        let lines = content.split(separator: "\n")
        XCTAssertTrue(lines.first?.contains("date,title,amount,type,notes,category,account") == true, "Missing header")
        XCTAssertEqual(lines.count, 4, "Expected 1 header + 3 data rows, got \(lines.count)")
        // Validate a row contains expected seed data
        XCTAssertTrue(lines.contains(where: { $0.contains("SeedTx0") }))
    }

    func testExporterWritesNoDataRowWhenEmpty() async throws {
        // Fresh container with no transactions
        let schema = Schema([
            FinancialTransaction.self, FinancialAccount.self, ExpenseCategory.self,
        ])
        let emptyContainer = try ModelContainer(
            for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let settings = ExportSettings(format: .csv, dateRange: .custom, startDate: start, endDate: end)
        let exporter = await DataExporter(modelContainer: emptyContainer)
        let url = try await exporter.exportData(settings: settings)
        let content = try String(contentsOf: url)
        let lines = content.split(separator: "\n")
        XCTAssertEqual(lines.count, 2, "Expected header + placeholder line")
        XCTAssertTrue(lines[1].contains("No Data"))
    }
}
