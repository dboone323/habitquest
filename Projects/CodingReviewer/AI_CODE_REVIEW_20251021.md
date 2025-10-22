# AI Code Review for CodingReviewer
Generated: Tue Oct 21 13:05:56 CDT 2025


## SidebarViewTests.swift
import XCTest
@testable import CodingReviewer

class SidebarViewTests: XCTestCase {
    var sut: SidebarView!

    override func setUp() {
        super.setUp()

        let selectedFileURL = URL(fileURLWithPath: "/example/file.swift")
        let showFilePicker = false
        let selectedAnalysisType = AnalysisType.comprehensive
        let currentView = ContentViewType.analysis

        sut = SidebarView(selectedFileURL: selectedFileURL, showFilePicker: showFilePicker, selectedAnalysisType: selectedAnalysisType, currentView: currentView)
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    // MARK: - Tests

    func test_init() {
        XCTAssertNotNil(sut, "SidebarView should not be nil")
    }

    func test_body_whenShowFilePickerIsFalse() {
        let showFilePicker = false
        sut.showFilePicker = showFilePicker

        XCTAssertEqual(sut.body, VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("CodingReviewer")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("AI-Powered Code Analysis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Analyze for:
            HStack {
                Text("Analyze for:")
                    .font(.headline)

                Spacer()
            }

            VStack(spacing: 16) {
                ForEach(AnalysisType.allCases, id: \.self) { analysisType in
                    Button(action: {}, label: {
                        Text(analysisType.description)
                    })
                }
            }

            Spacer()
        }, alignment: .leading)
    }
}
```
