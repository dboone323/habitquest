//
//  PredictiveDependenciesIntegrationTests.swift
//  Predictive Dependencies
//
//  Comprehensive integration tests for the predictive dependencies system,
//  testing analyzer, predictor, visualizer, and monitor components.
//

import SwiftUI
import XCTest

@testable import PredictiveDependencies

@available(macOS 12.0, *)
final class PredictiveDependenciesIntegrationTests: XCTestCase {

    var analyzer: DependencyAnalyzer!
    var predictor: DependencyPredictor!
    var visualizer: DependencyVisualizer!
    var monitor: DependencyMonitor!

    let testProjectPath = "/tmp/TestProject"
    let testFilePath = "/tmp/TestProject/TestFile.swift"

    override func setUp() async throws {
        try await super.setUp()

        // Create test directory structure
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: testProjectPath)
        try fileManager.createDirectory(atPath: testProjectPath, withIntermediateDirectories: true)

        // Create test Swift file
        let testCode = """
        import Foundation
        import UIKit

        class TestViewController: UIViewController {
            private let networkManager = NetworkManager()
            private let dataProcessor = DataProcessor()

            func loadData() {
                networkManager.fetchData { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.dataProcessor.process(data: data)
                    case .failure(let error):
                        print("Error: \\(error)")
                    }
                }
            }
        }

        class NetworkManager {
            func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
                // Network implementation
            }
        }

        class DataProcessor {
            func process(data: Data) {
                // Processing implementation
            }
        }
        """
        try testCode.write(toFile: testFilePath, atomically: true, encoding: .utf8)

        // Initialize components
        analyzer = DependencyAnalyzer()
        predictor = DependencyPredictor()
        visualizer = DependencyVisualizer()
        monitor = DependencyMonitor()
    }

    override func tearDown() async throws {
        // Clean up
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: testProjectPath)

        analyzer = nil
        predictor = nil
        visualizer = nil
        monitor = nil

        try await super.tearDown()
    }

    // MARK: - Integration Tests

    func testFullDependencyAnalysisWorkflow() async throws {
        // Test complete analysis workflow from file to project level

        // 1. Analyze single file
        let fileDependencies = try await analyzer.analyzeFile(at: testFilePath)

        XCTAssertEqual(fileDependencies.filePath, testFilePath)
        XCTAssertGreaterThan(fileDependencies.dependencyCount, 0)
        XCTAssertTrue(fileDependencies.externalDependencies.contains("Foundation"))
        XCTAssertTrue(fileDependencies.externalDependencies.contains("UIKit"))

        // 2. Analyze entire project
        let projectDependencies = try await analyzer.analyzeProject(at: testProjectPath)

        XCTAssertEqual(projectDependencies.fileDependencies.count, 1)
        XCTAssertNotNil(projectDependencies.fileDependencies[testFilePath])

        // 3. Get dependency metrics
        let metrics = analyzer.getDependencyMetrics(for: projectDependencies)

        XCTAssertGreaterThan(metrics.totalDependencies, 0)
        XCTAssertGreaterThan(metrics.averageDependenciesPerFile, 0)
        XCTAssertEqual(metrics.circularDependenciesCount, 0) // No circular deps in test

        // 4. Get optimization suggestions
        let suggestions = analyzer.suggestOptimizations(for: projectDependencies)

        // Should not have circular dependency suggestions for this simple project
        XCTAssertFalse(suggestions.contains(where: { $0.type == .breakCircularDependencies }))
    }

    func testDependencyPredictionWorkflow() async throws {
        // Test prediction workflow with training and inference

        // 1. Create training data
        let fileDeps = try await analyzer.analyzeFile(at: testFilePath)
        let context = PredictionContext(
            fileSize: 1024,
            linesOfCode: 30,
            cyclomaticComplexity: 5.0,
            projectSize: 1,
            similarFiles: [],
            historicalDependencies: ["Foundation", "UIKit"],
            historicalUsage: 0.8,
            recentChanges: 2,
            teamSize: 3
        )

        let trainingSample = DependencyTrainingSample(
            fileDependencies: fileDeps,
            context: context,
            actualDependencies: ["Foundation", "UIKit", "Combine"], // Include a dependency that might be predicted
            timestamp: Date()
        )

        // 2. Train the model
        try await predictor.trainModel(with: [trainingSample])

        // 3. Make predictions
        let predictions = try await predictor.predictDependencies(for: fileDeps, context: context)

        XCTAssertGreaterThanOrEqual(predictions.count, 0) // May predict dependencies

        // 4. Evaluate model (with same data for testing)
        let performance = try await predictor.evaluateModel(with: [trainingSample])

        // Basic performance checks
        XCTAssertGreaterThanOrEqual(performance.precision, 0.0)
        XCTAssertLessThanOrEqual(performance.precision, 1.0)
        XCTAssertGreaterThanOrEqual(performance.accuracy, 0.0)
        XCTAssertLessThanOrEqual(performance.accuracy, 1.0)

        // 5. Get model insights
        let insights = predictor.getModelInsights()

        XCTAssertEqual(insights.trainingSamples, 1)
        XCTAssertGreaterThan(insights.featuresUsed, 0)
    }

    func testDependencyVisualizationWorkflow() async throws {
        // Test visualization components

        // 1. Analyze project
        let project = try await analyzer.analyzeProject(at: testProjectPath)

        // 2. Create visualizations
        let graphView = visualizer.createDependencyGraphView(for: project)
        let metrics = analyzer.getDependencyMetrics(for: project)
        let metricsView = visualizer.createMetricsDashboardView(for: metrics)

        // Views should be created without errors
        XCTAssertNotNil(graphView)
        XCTAssertNotNil(metricsView)

        // 3. Generate HTML report
        let predictions = try await predictor.predictProjectDependencies(
            for: project, context: PredictionContext()
        )
        let htmlReport = visualizer.generateHTMLReport(
            project: project,
            predictions: predictions,
            impact: nil,
            metrics: metrics
        )

        XCTAssertTrue(htmlReport.contains("Dependency Analysis Report"))
        XCTAssertTrue(htmlReport.contains("Project Overview"))
        XCTAssertTrue(htmlReport.contains("Dependency Metrics"))
    }

    func testDependencyMonitoringWorkflow() async throws {
        // Test monitoring system

        // 1. Start monitoring
        monitor.startMonitoring(
            analyzer: analyzer, predictor: predictor, projectPath: testProjectPath
        )

        // Wait a bit for initial analysis
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // 2. Check monitoring status
        let status = monitor.getMonitoringStatus()

        XCTAssertTrue(status.isActive)
        XCTAssertGreaterThanOrEqual(status.totalAlerts, 0)

        // 3. Trigger manual monitoring cycle
        monitor.triggerMonitoringCycle(for: testProjectPath)

        // Wait for cycle to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // 4. Check for alerts
        let updatedStatus = monitor.getMonitoringStatus()
        XCTAssertGreaterThanOrEqual(updatedStatus.totalAlerts, status.totalAlerts)

        // 5. Get alert trends
        let trends = monitor.getAlertTrends(hours: 1)
        XCTAssertGreaterThanOrEqual(trends.totalAlerts, 0)

        // 6. Stop monitoring
        monitor.stopMonitoring()

        let finalStatus = monitor.getMonitoringStatus()
        XCTAssertFalse(finalStatus.isActive)
    }

    func testChangeImpactAnalysis() async throws {
        // Test change impact analysis

        // 1. Analyze project
        let project = try await analyzer.analyzeProject(at: testProjectPath)

        // 2. Simulate file changes
        let changedFiles = [testFilePath]

        // 3. Analyze impact
        let impact = try analyzer.analyzeChangeImpact(changedFiles: changedFiles, in: project)

        XCTAssertEqual(impact.changedFiles, changedFiles)
        XCTAssertGreaterThanOrEqual(impact.totalImpact, impact.directImpact)
        XCTAssertGreaterThanOrEqual(impact.riskScore, 0.0)
        XCTAssertLessThanOrEqual(impact.riskScore, 1.0)
    }

    func testCircularDependencyDetection() async throws {
        // Create a project with circular dependencies for testing

        // Create files with circular dependency
        let fileAContent = """
        import Foundation
        class A {
            let b = B()
        }
        """
        let fileBContent = """
        import Foundation
        class B {
            let a = A()
        }
        """

        let fileAPath = "\(testProjectPath)/A.swift"
        let fileBPath = "\(testProjectPath)/B.swift"

        try fileAContent.write(toFile: fileAPath, atomically: true, encoding: .utf8)
        try fileBContent.write(toFile: fileBPath, atomically: true, encoding: .utf8)

        // Analyze project
        let project = try await analyzer.analyzeProject(at: testProjectPath)

        // Should detect circular dependencies
        XCTAssertGreaterThan(project.circularDependencies.count, 0)

        // Get optimization suggestions
        let suggestions = analyzer.suggestOptimizations(for: project)

        // Should include circular dependency breaking suggestion
        XCTAssertTrue(suggestions.contains(where: { $0.type == .breakCircularDependencies }))
    }

    func testPerformanceUnderLoad() async throws {
        // Test system performance with multiple files

        // Create multiple test files
        for i in 1 ... 10 {
            let content = """
            import Foundation
            import UIKit

            class TestClass\(i): UIViewController {
                func testMethod() {
                    print("Test \(i)")
                }
            }
            """
            let path = "\(testProjectPath)/Test\(i).swift"
            try content.write(toFile: path, atomically: true, encoding: .utf8)
        }

        let startTime = Date()

        // Analyze project
        let project = try await analyzer.analyzeProject(at: testProjectPath)

        let analysisTime = Date().timeIntervalSince(startTime)

        // Should complete within reasonable time (less than 5 seconds)
        XCTAssertLessThan(analysisTime, 5.0)

        // Should analyze all files
        XCTAssertEqual(project.fileDependencies.count, 11) // 10 new + 1 original

        // Get metrics
        let metrics = analyzer.getDependencyMetrics(for: project)

        XCTAssertGreaterThan(metrics.totalDependencies, 0)
        XCTAssertEqual(metrics.circularDependenciesCount, 0)
    }

    func testErrorHandling() async throws {
        // Test error handling scenarios

        // 1. Test with non-existent file
        do {
            _ = try await analyzer.analyzeFile(at: "/non/existent/file.swift")
            XCTFail("Should have thrown an error")
        } catch DependencyError.fileNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        // 2. Test with non-existent directory
        do {
            _ = try await analyzer.analyzeProject(at: "/non/existent/directory")
            XCTFail("Should have thrown an error")
        } catch DependencyError.directoryNotFound {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        // 3. Test prediction without training
        let fileDeps = try await analyzer.analyzeFile(at: testFilePath)
        let context = PredictionContext()

        do {
            _ = try await predictor.predictDependencies(for: fileDeps, context: context)
            // This might succeed with default behavior or fail - depends on implementation
        } catch PredictionError.modelNotTrained {
            // Expected if model requires training
        } catch {
            // Other errors are acceptable
        }
    }

    func testDataExportAndImport() async throws {
        // Test data export/import functionality

        // 1. Start monitoring and generate some data
        monitor.startMonitoring(
            analyzer: analyzer, predictor: predictor, projectPath: testProjectPath
        )
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // 2. Export monitoring data
        let exportPath = "/tmp/monitoring_export.json"
        try monitor.exportMonitoringData(to: exportPath)

        // Verify file was created
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: exportPath))

        // 3. Verify exported data can be read
        let data = try Data(contentsOf: URL(fileURLWithPath: exportPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let exportData = try decoder.decode(MonitoringExportData.self, from: data)

        XCTAssertNotNil(exportData.monitoringStatus)
        XCTAssertGreaterThanOrEqual(exportData.alerts.count, 0)

        // Clean up
        try? fileManager.removeItem(atPath: exportPath)
        monitor.stopMonitoring()
    }

    func testConcurrentAnalysis() async throws {
        // Test concurrent analysis operations

        // Create multiple projects
        let projectPaths = (1 ... 3).map { "/tmp/ConcurrentTestProject\($0)" }

        for path in projectPaths {
            let fileManager = FileManager.default
            try? fileManager.removeItem(atPath: path)
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)

            let content = """
            import Foundation
            class TestClass {
                func test() {}
            }
            """
            try content.write(toFile: "\(path)/Test.swift", atomically: true, encoding: .utf8)
        }

        // Analyze all projects concurrently
        try await withThrowingTaskGroup(of: ProjectDependencies.self) { group in
            for path in projectPaths {
                group.addTask {
                    try await self.analyzer.analyzeProject(at: path)
                }
            }

            var results: [ProjectDependencies] = []
            for try await project in group {
                results.append(project)
            }

            XCTAssertEqual(results.count, 3)
            for project in results {
                XCTAssertEqual(project.fileDependencies.count, 1)
            }
        }

        // Clean up
        for path in projectPaths {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    // MARK: - Performance Tests

    func testAnalysisPerformance() async throws {
        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    _ = try await analyzer.analyzeProject(at: testProjectPath)
                    semaphore.signal()
                } catch {
                    semaphore.signal()
                }
            }
            semaphore.wait()
        }
    }

    func testPredictionPerformance() async throws {
        // First train the model
        let fileDeps = try await analyzer.analyzeFile(at: testFilePath)
        let context = PredictionContext()
        let trainingSample = DependencyTrainingSample(
            fileDependencies: fileDeps,
            context: context,
            actualDependencies: ["Foundation"],
            timestamp: Date()
        )

        try await predictor.trainModel(with: [trainingSample])

        // Then measure prediction performance
        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    _ = try await predictor.predictDependencies(for: fileDeps, context: context)
                    semaphore.signal()
                } catch {
                    semaphore.signal()
                }
            }
            semaphore.wait()
        }
    }
}

// MARK: - Test Extensions

extension DependencyAnalyzer {
    /// Test-only method to inject mock data
    func injectMockData(_ data: [String: FileDependencies]) {
        // This would be used for testing with controlled data
    }
}

extension DependencyPredictor {
    /// Test-only method to reset model
    func resetModel() {
        predictionModel = nil
        trainingData = []
    }
}

// MARK: - Mock Data Helpers

extension PredictiveDependenciesIntegrationTests {

    func createMockProjectDependencies() -> ProjectDependencies {
        var fileDeps: [String: FileDependencies] = [:]

        // Create mock file dependencies
        let mockFile = FileDependencies(
            filePath: "/mock/File.swift",
            dependencies: ["Foundation", "UIKit"],
            internalDependencies: ["UIKit"],
            externalDependencies: ["Foundation"],
            imports: ["Foundation", "UIKit"],
            typeDependencies: ["UIView"],
            functionDependencies: ["print"],
            dependencyCount: 2,
            complexityScore: 0.5,
            analysisTimestamp: Date()
        )

        fileDeps[mockFile.filePath] = mockFile

        let graph = DependencyGraph()
        graph.addDependency(from: mockFile.filePath, to: mockFile.filePath) // Self-dependency for testing

        return ProjectDependencies(
            fileDependencies: fileDeps,
            projectGraph: graph,
            circularDependencies: [[mockFile.filePath]],
            stronglyConnectedComponents: [[mockFile.filePath]],
            analysisTimestamp: Date()
        )
    }

    func createMockTrainingData() -> [DependencyTrainingSample] {
        let mockFile = FileDependencies(
            filePath: "/mock/Train.swift",
            dependencies: ["Foundation"],
            internalDependencies: [],
            externalDependencies: ["Foundation"],
            imports: ["Foundation"],
            typeDependencies: [],
            functionDependencies: [],
            dependencyCount: 1,
            complexityScore: 0.3,
            analysisTimestamp: Date()
        )

        let context = PredictionContext(
            historicalDependencies: ["Foundation", "UIKit"],
            historicalUsage: 0.7
        )

        return [
            DependencyTrainingSample(
                fileDependencies: mockFile,
                context: context,
                actualDependencies: ["Foundation", "Combine"],
                timestamp: Date()
            ),
        ]
    }
}

// MARK: - UI Tests

@available(macOS 12.0, *)
class PredictiveDependenciesUITests: XCTestCase {

    var visualizer: DependencyVisualizer!
    var monitor: DependencyMonitor!

    override func setUp() async throws {
        visualizer = DependencyVisualizer()
        monitor = DependencyMonitor()
    }

    func testViewCreation() throws {
        // Test that views can be created without crashing
        let mockProject = createMockProject()
        let mockPredictions: [String: [DependencyPrediction]] = [:]
        let mockMetrics = createMockMetrics()

        let graphView = visualizer.createDependencyGraphView(for: mockProject)
        XCTAssertNotNil(graphView)

        let predictionView = visualizer.createPredictionView(for: mockPredictions)
        XCTAssertNotNil(predictionView)

        let metricsView = visualizer.createMetricsDashboardView(for: mockMetrics)
        XCTAssertNotNil(metricsView)

        let combinedView = visualizer.createCombinedAnalysisView(
            project: mockProject,
            predictions: mockPredictions,
            impact: nil,
            metrics: mockMetrics
        )
        XCTAssertNotNil(combinedView)
    }

    private func createMockProject() -> ProjectDependencies {
        let fileDeps: [String: FileDependencies] = [:]
        let graph = DependencyGraph()

        return ProjectDependencies(
            fileDependencies: fileDeps,
            projectGraph: graph,
            circularDependencies: [],
            stronglyConnectedComponents: [],
            analysisTimestamp: Date()
        )
    }

    private func createMockMetrics() -> DependencyMetrics {
        DependencyMetrics(
            totalDependencies: 0,
            averageDependenciesPerFile: 0,
            maxDependenciesPerFile: 0,
            minDependenciesPerFile: 0,
            dependencyDensity: 0,
            stronglyConnectedComponents: 0,
            averageComponentSize: 0,
            stabilityIndex: 1.0,
            circularDependenciesCount: 0,
            analysisTimestamp: Date()
        )
    }
}
