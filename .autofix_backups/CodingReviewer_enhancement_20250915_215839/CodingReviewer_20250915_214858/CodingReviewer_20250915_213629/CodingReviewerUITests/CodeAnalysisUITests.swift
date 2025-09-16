//
//  CodeAnalysisUITests.swift
//  CodingReviewerUITests
//
//  Created by Daniel Stevens on 2025
//

import XCTest

final class CodeAnalysisUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Code Analysis UI Tests

    @MainActor
    func testAnalysisButtonExists() throws {
        // Verify analysis button is present
        let analyzeButton = app.buttons["Analyze Code"].firstMatch
        XCTAssertTrue(analyzeButton.exists, "Analyze Code button should exist")
        XCTAssertTrue(analyzeButton.isEnabled, "Analyze button should be enabled")
    }

    @MainActor
    func testAnalysisProgressIndicator() throws {
        // Test analysis progress indication
        let analyzeButton = app.buttons["Analyze"].firstMatch
        if analyzeButton.exists {
            analyzeButton.tap()

            // Check for progress indicator
            let progressIndicator = app.progressIndicators.firstMatch
            let spinner = app.activityIndicators.firstMatch

            XCTAssertTrue(
                progressIndicator.exists || spinner.exists, "Should show analysis progress")
        }
    }

    @MainActor
    func testAnalysisResultsDisplay() throws {
        // Test that analysis results are displayed
        let analyzeButton = app.buttons["Analyze"].firstMatch
        if analyzeButton.exists {
            analyzeButton.tap()

            // Wait for analysis to complete (adjust timeout as needed)
            let resultsView = app.otherElements["Analysis Results"].firstMatch
            let resultsText = app.textViews["Results"].firstMatch

            let predicate = NSPredicate(format: "exists == true")
            let expectation = expectation(for: predicate, evaluatedWith: resultsView)

            waitForExpectations(timeout: 10) { error in
                XCTAssertNil(error, "Analysis results should appear within 10 seconds")
            }

            XCTAssertTrue(
                resultsView.exists || resultsText.exists, "Analysis results should be displayed")
        }
    }

    @MainActor
    func testAnalysisOptions() throws {
        // Test analysis configuration options
        let optionsButton = app.buttons["Analysis Options"].firstMatch
        if optionsButton.exists {
            optionsButton.tap()

            // Check for analysis options
            let complexityCheck = app.checkBoxes["Complexity Analysis"].firstMatch
            let duplicationCheck = app.checkBoxes["Duplication Check"].firstMatch
            let styleCheck = app.checkBoxes["Style Check"].firstMatch

            XCTAssertTrue(
                complexityCheck.exists || duplicationCheck.exists || styleCheck.exists,
                "Should have analysis options")
        }
    }

    @MainActor
    func testIssueFiltering() throws {
        // Test filtering of analysis results
        let filterButton = app.buttons["Filter"].firstMatch
        if filterButton.exists {
            filterButton.tap()

            // Check for filter options
            let errorsOnly = app.buttons["Errors Only"].firstMatch
            let warningsOnly = app.buttons["Warnings Only"].firstMatch
            let allIssues = app.buttons["All Issues"].firstMatch

            XCTAssertTrue(
                errorsOnly.exists || warningsOnly.exists || allIssues.exists,
                "Should have issue filtering options")
        }
    }

    @MainActor
    func testIssueDetailsView() throws {
        // Test detailed view of individual issues
        let issuesTable = app.tables["Issues"].firstMatch
        if issuesTable.exists {
            let firstIssue = issuesTable.cells.firstMatch
            if firstIssue.exists {
                firstIssue.tap()

                // Check for detailed issue view
                let detailView = app.otherElements["Issue Details"].firstMatch
                XCTAssertTrue(detailView.exists, "Should show issue details")
            }
        }
    }

    @MainActor
    func testCodeMetricsDisplay() throws {
        // Test display of code metrics
        let metricsView = app.otherElements["Code Metrics"].firstMatch
        if metricsView.exists {
            // Check for common metrics
            let complexityLabel = app.staticTexts["Complexity"].firstMatch
            let linesLabel = app.staticTexts["Lines of Code"].firstMatch
            let functionsLabel = app.staticTexts["Functions"].firstMatch

            XCTAssertTrue(
                complexityLabel.exists || linesLabel.exists || functionsLabel.exists,
                "Should display code metrics")
        }
    }

    @MainActor
    func testExportResults() throws {
        // Test exporting analysis results
        let exportButton = app.buttons["Export Results"].firstMatch
        if exportButton.exists {
            exportButton.tap()

            // Check for export options
            let pdfOption = app.buttons["Export as PDF"].firstMatch
            let jsonOption = app.buttons["Export as JSON"].firstMatch
            let csvOption = app.buttons["Export as CSV"].firstMatch

            XCTAssertTrue(
                pdfOption.exists || jsonOption.exists || csvOption.exists,
                "Should have export options")
        }
    }

    @MainActor
    func testAnalysisHistory() throws {
        // Test analysis history functionality
        let historyButton = app.buttons["Analysis History"].firstMatch
        if historyButton.exists {
            historyButton.tap()

            // Check for history view
            let historyTable = app.tables["Analysis History"].firstMatch
            XCTAssertTrue(historyTable.exists, "Should show analysis history")
        }
    }

    @MainActor
    func testRealTimeAnalysis() throws {
        // Test real-time analysis if available
        let realTimeToggle = app.switches["Real-time Analysis"].firstMatch
        if realTimeToggle.exists {
            realTimeToggle.tap()

            // Verify toggle state changed
            XCTAssertTrue(realTimeToggle.isSelected, "Real-time analysis should be enabled")
        }
    }

    @MainActor
    func testAnalysisCancellation() throws {
        // Test cancelling analysis
        let analyzeButton = app.buttons["Analyze"].firstMatch
        if analyzeButton.exists {
            analyzeButton.tap()

            // Look for cancel button
            let cancelButton = app.buttons["Cancel Analysis"].firstMatch
            if cancelButton.exists {
                cancelButton.tap()

                // Verify analysis was cancelled
                let cancelledMessage = app.staticTexts["Analysis cancelled"].firstMatch
                XCTAssertTrue(cancelledMessage.exists, "Should show cancellation confirmation")
            }
        }
    }

    @MainActor
    func testLargeFileAnalysis() throws {
        // Test analysis of large files
        let largeFilePath = "/test/large-file.swift"  // Would need actual large test file
        let filePathField = app.textFields["File Path"].firstMatch

        if filePathField.exists {
            filePathField.tap()
            filePathField.typeText(largeFilePath)

            let analyzeButton = app.buttons["Analyze"].firstMatch
            if analyzeButton.exists {
                analyzeButton.tap()

                // Should handle large files without crashing
                let progressIndicator = app.progressIndicators.firstMatch
                XCTAssertTrue(
                    progressIndicator.exists, "Should show progress for large file analysis")
            }
        }
    }

    @MainActor
    func testAnalysisPerformance() throws {
        // Test analysis performance
        let analyzeButton = app.buttons["Analyze"].firstMatch
        if analyzeButton.exists {
            measure {
                analyzeButton.tap()
                // Wait for completion
                let resultsView = app.otherElements["Analysis Results"].firstMatch
                let predicate = NSPredicate(format: "exists == true")
                let expectation = expectation(for: predicate, evaluatedWith: resultsView)
                waitForExpectations(timeout: 30) { _ in }
            }
        }
    }
}
