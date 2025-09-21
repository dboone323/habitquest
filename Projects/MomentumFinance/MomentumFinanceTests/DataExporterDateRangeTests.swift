import SwiftData
import XCTest

@testable import MomentumFinanceCore

@MainActor
final class DataExporterDateRangeTests: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        let schema = Schema([
            FinancialTransaction.self, FinancialAccount.self, ExpenseCategory.self,
        ])
        self.container = try ModelContainer(
            for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        // Seed transactions across dates
        let dates: [Date] = (-5 ... 5).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: Date())
        }
        for (i, d) in dates.enumerated() {
            let t = FinancialTransaction(
                title: "T\(i)", amount: Double(i) * 10.0, date: d, transactionType: .income,
                notes: nil
            )
            context.insert(t)
        }
        try context.save()
    }

    func testExportFiltersByDateRange() async throws {
        let start = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let end = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let settings = ExportSettings(
            format: .csv, dateRange: .custom, startDate: start, endDate: end
        )
        let exporter = await DataExporter(modelContainer: container)
        let url = try await exporter.exportData(settings: settings)
        let content = try String(contentsOf: url)
        let lines = content.split(separator: "\n").dropFirst() // skip header
        // Only dates within +-2 days expected (~5 entries)
        XCTAssert(lines.count <= 6 && lines.count >= 4, "Unexpected filtered count: \(lines.count)")
    }
}
