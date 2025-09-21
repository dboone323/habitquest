import XCTest

@testable import MomentumFinanceCore

final class CSVParserTests: XCTestCase {
    func testParseSimpleRow() {
        let row = "2025-09-01,Salary,5000,income,September salary,Income,Checking"
        let fields = CSVParser.parseCSVRow(row)
        XCTAssertEqual(fields.count, 7)
        XCTAssertEqual(fields[1], "Salary")
    }

    func testMapColumnsStandardHeaders() {
        let headers = ["date", "title", "amount", "type", "notes", "category", "account"]
        let mapping = CSVParser.mapColumns(headers: headers)
        XCTAssertEqual(mapping.dateIndex, 0)
        XCTAssertEqual(mapping.titleIndex, 1)
        XCTAssertEqual(mapping.amountIndex, 2)
        XCTAssertEqual(mapping.typeIndex, 3)
        XCTAssertEqual(mapping.categoryIndex, 5)
        XCTAssertEqual(mapping.accountIndex, 6)
    }

    func testParseAmountFormats() throws {
        XCTAssertEqual(try DataParser.parseAmount("$1,234.56"), 1234.56, accuracy: 0.001)
        XCTAssertThrowsError(try DataParser.parseAmount("abc"))
    }

    func testParseDateValidInvalid() throws {
        XCTAssertNoThrow(try DataParser.parseDate("2025-01-15"))
        XCTAssertThrowsError(try DataParser.parseDate("15-01-2025"))
    }
}
