@testable import MomentumFinanceCore
import XCTest

final class CSVParserEdgeCasesTests: XCTestCase {
    func testMalformedRowExtraCommas() {
        let row = "2025-01-01,Title,100,income,Notes,Category,Account,EXTRA"
        let fields = CSVParser.parseCSVRow(row)
        XCTAssertEqual(fields.count, 8)
    }

    func testEmptyFieldsRow() {
        let row = ",,,,"
        let fields = CSVParser.parseCSVRow(row)
        XCTAssertEqual(fields.count, 5)
    }

    func testQuotedCommaPreservationSimpleFallback() {
        // Current parser splits naively; a quoted value with comma will split into two fields
        let row = "2025-01-01,\"Title With, Comma\",100,income"
        let fields = CSVParser.parseCSVRow(row)
        // Expect 5 fields because the comma inside quotes is not preserved by naive split
        XCTAssertEqual(fields.count, 5)
    }

    func testHeaderMappingAlternateNames() {
        let headers = ["Transaction Date", "Description", "Value", "Transaction Type", "Comments", "Account Name", "Category Name"]
        let mapping = CSVParser.mapColumns(headers: headers)
        XCTAssertNotNil(mapping.dateIndex)
        XCTAssertNotNil(mapping.titleIndex)
        XCTAssertNotNil(mapping.amountIndex)
        XCTAssertNotNil(mapping.typeIndex)
        XCTAssertNotNil(mapping.notesIndex)
        XCTAssertNotNil(mapping.accountIndex)
        XCTAssertNotNil(mapping.categoryIndex)
    }
}
