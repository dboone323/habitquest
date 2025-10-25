//
//  PerformanceBenchmarkingIntegrationTests.swift
//  Performance Benchmarking
//
//  Comprehensive integration tests for the performance benchmarking system,
//  validating end-to-end workflows and component interactions.
//

import Foundation
import XCTest

/// Integration tests for performance benchmarking system
@available(macOS 12.0, *)
final class PerformanceBenchmarkingIntegrationTests: XCTestCase {

    // MARK: - Properties

    private var benchmarkRunner: BenchmarkRunner!
    private var performanceAnalyzer: PerformanceAnalyzer!
    private var reportGenerator: ReportGenerator!
    private var ciIntegration: CIIntegration!

    private var testBenchmarks: [Benchmark] = []
    private var testResults: [BenchmarkResult] = []

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Initialize components
        benchmarkRunner = BenchmarkRunner()
        performanceAnalyzer = PerformanceAnalyzer()
        reportGenerator = ReportGenerator()
        ciIntegration = CIIntegration()

        // Create test benchmarks
        testBenchmarks = createTestBenchmarks()

        // Run initial benchmarks to get baseline data
        testResults = []
        for benchmark in testBenchmarks {
            let result = try await benchmarkRunner.runBenchmark(benchmark)
            testResults.append(result)
        }
    }

    override func tearDown() async throws {
        benchmarkRunner = nil
        performanceAnalyzer = nil
        reportGenerator = nil
        ciIntegration = nil
        testBenchmarks = []
        testResults = []

        try await super.tearDown()
    }

    // MARK: - Integration Test Cases

    /// Test complete performance analysis workflow
    func testCompletePerformanceAnalysisWorkflow() async throws {
        // Given: Benchmark results from setup

        // When: Run complete analysis workflow
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)

        // Then: Validate analysis results
        XCTAssertGreaterThan(analysis.benchmarkAnalyses.count, 0)
        XCTAssertGreaterThanOrEqual(analysis.overallScore, 0)
        XCTAssertLessThanOrEqual(analysis.overallScore, 100)
        XCTAssertNotNil(analysis.performanceGrade)

        // Validate individual benchmark analyses
        for (id, benchmarkAnalysis) in analysis.benchmarkAnalyses {
            XCTAssertEqual(benchmarkAnalysis.benchmarkId, id)
            XCTAssertGreaterThan(benchmarkAnalysis.timeStats.mean, 0)
            XCTAssertGreaterThanOrEqual(benchmarkAnalysis.timeStats.standardDeviation, 0)
        }
    }

    /// Test trend analysis workflow
    func testTrendAnalysisWorkflow() async throws {
        // Given: Multiple result sets over time
        let historicalResults = createHistoricalResults()

        // When: Analyze trends for each benchmark
        var trendAnalyses: [TrendAnalysis] = []
        for benchmark in testBenchmarks {
            let benchmarkResults = historicalResults.filter { $0.benchmark.id == benchmark.id }
            if benchmarkResults.count >= 3 {
                let trend = try await performanceAnalyzer.analyzeTrends(
                    for: benchmark.id, results: benchmarkResults
                )
                trendAnalyses.append(trend)
            }
        }

        // Then: Validate trend analysis
        XCTAssertGreaterThan(trendAnalyses.count, 0)

        for trend in trendAnalyses {
            XCTAssertEqual(
                trend.dataPoints,
                historicalResults.filter { $0.benchmark.id == trend.benchmarkId }.count
            )
            XCTAssertNotNil(trend.timeSeries.trendType)
            XCTAssertGreaterThanOrEqual(trend.timeSeries.trend.rSquared, 0)
            XCTAssertLessThanOrEqual(trend.timeSeries.trend.rSquared, 1)
        }
    }

    /// Test version comparison workflow
    func testVersionComparisonWorkflow() async throws {
        // Given: Baseline and current results
        let baselineResults = testResults
        let currentResults = createModifiedResults(from: baselineResults, modificationFactor: 0.9) // 10% improvement

        // When: Compare versions
        let comparison = try await performanceAnalyzer.compareVersions(
            baseline: baselineResults, current: currentResults
        )

        // Then: Validate comparison
        XCTAssertEqual(comparison.baselineResults.count, baselineResults.count)
        XCTAssertEqual(comparison.currentResults.count, currentResults.count)
        XCTAssertEqual(comparison.comparisons.count, testBenchmarks.count)
        XCTAssertLessThan(comparison.averageTimeChange, 0) // Should be negative (improvement)
        XCTAssertEqual(comparison.overallChange, .improvement)
    }

    /// Test anomaly detection workflow
    func testAnomalyDetectionWorkflow() async throws {
        // Given: Results with intentional anomalies
        let anomalousResults = createAnomalousResults()

        // When: Detect anomalies
        let anomalies = try await performanceAnalyzer.detectAnomalies(in: anomalousResults)

        // Then: Validate anomaly detection
        XCTAssertGreaterThan(anomalies.count, 0)

        for anomaly in anomalies {
            XCTAssertFalse(anomaly.benchmarkId.isEmpty)
            XCTAssertNotNil(anomaly.type)
            XCTAssertFalse(anomaly.description.isEmpty)
            XCTAssertGreaterThanOrEqual(anomaly.severity.rawValue, 1)
            XCTAssertLessThanOrEqual(anomaly.severity.rawValue, 4)
        }
    }

    /// Test performance insights generation
    func testPerformanceInsightsWorkflow() async throws {
        // Given: Analysis results
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)

        // When: Generate insights
        let insights = await performanceAnalyzer.generateInsights(from: analysis)

        // Then: Validate insights
        XCTAssertGreaterThanOrEqual(insights.count, 1) // At least overall assessment

        for insight in insights {
            XCTAssertFalse(insight.title.isEmpty)
            XCTAssertFalse(insight.description.isEmpty)
            XCTAssertGreaterThanOrEqual(insight.severity.rawValue, 1)
            XCTAssertLessThanOrEqual(insight.severity.rawValue, 4)
            XCTAssertGreaterThanOrEqual(insight.suggestedActions.count, 0)
        }
    }

    /// Test report generation workflow
    func testReportGenerationWorkflow() async throws {
        // Given: Analysis results and optional data
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)
        let trends = try await createTrendData()
        let comparison = try await createComparisonData()

        // When: Generate comprehensive report
        let report = try await reportGenerator.generatePerformanceReport(
            analysis: analysis,
            trends: trends,
            comparison: comparison
        )

        // Then: Validate report structure
        XCTAssertFalse(report.id.isEmpty)
        XCTAssertFalse(report.title.isEmpty)
        XCTAssertFalse(report.executiveSummary.isEmpty)
        XCTAssertNotNil(report.benchmarkSection)
        XCTAssertNotNil(report.correlationSection)
        XCTAssertNotNil(report.bottleneckSection)
        XCTAssertNotNil(report.optimizationSection)
        XCTAssertGreaterThanOrEqual(report.recommendations.count, 0)
        XCTAssertGreaterThanOrEqual(report.charts.count, 0)
    }

    /// Test HTML dashboard generation
    func testHTMLDashboardGeneration() async throws {
        // Given: Analysis results
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)

        // When: Generate HTML dashboard
        let html = try await reportGenerator.generateHTMLDashboard(analysis: analysis)

        // Then: Validate HTML content
        XCTAssertTrue(html.contains("Performance Dashboard"))
        XCTAssertTrue(html.contains("Executive Summary"))
        XCTAssertTrue(html.contains("Benchmark Results"))
        XCTAssertTrue(html.contains(analysis.performanceGrade.rawValue))
        XCTAssertTrue(html.contains(String(format: "%.1f", analysis.overallScore)))
    }

    /// Test CI integration workflow
    func testCIIntegrationWorkflow() async throws {
        // Given: CI configuration and benchmarks
        let ciConfig = CIIntegration.CIConfig(
            enablePerformanceGates: true,
            performanceGateThreshold: 50.0, // Low threshold for testing
            enableRegressionDetection: true,
            regressionThreshold: 1.0,
            enableTrendAnalysis: true
        )
        ciIntegration.updateConfiguration(ciConfig)

        // When: Run CI performance tests
        let ciResult = try await ciIntegration.runPerformanceTests(benchmarks: testBenchmarks)

        // Then: Validate CI result
        XCTAssertNotNil(ciResult.status)
        XCTAssertEqual(ciResult.benchmarkResults.count, testBenchmarks.count)
        XCTAssertNotNil(ciResult.analysis)
        XCTAssertNotNil(ciResult.gateResult)
        XCTAssertNotNil(ciResult.regressionResult)
        XCTAssertNotNil(ciResult.report)
    }

    /// Test performance gates
    func testPerformanceGates() async throws {
        // Given: Analysis with known performance characteristics
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)

        // When: Check performance gates
        let gateResult = try ciIntegration.checkPerformanceGates(analysis)

        // Then: Validate gate checking
        XCTAssertNotNil(gateResult.passed)
        XCTAssertEqual(gateResult.score, analysis.overallScore)
        XCTAssertGreaterThanOrEqual(gateResult.violations.count, 0)
    }

    /// Test regression detection
    func testRegressionDetection() async throws {
        // Given: Current results and baseline
        let baselineResults = testResults
        let currentResults = createModifiedResults(from: baselineResults, modificationFactor: 1.1) // 10% regression

        // When: Detect regressions
        let regressionResult = try ciIntegration.detectRegressions(currentResults)

        // Then: Validate regression detection
        XCTAssertGreaterThanOrEqual(regressionResult.regressions.count, 0)
        XCTAssertGreaterThanOrEqual(regressionResult.improvements.count, 0)
        XCTAssertEqual(regressionResult.threshold, ciIntegration.config.regressionThreshold)
    }

    /// Test concurrent analysis
    func testConcurrentAnalysis() async throws {
        // Given: Multiple benchmark sets
        let benchmarkSets = (0 ..< 3).map { _ in createTestBenchmarks() }

        // When: Run concurrent analyses
        async let analysis1 = performanceAnalyzer.analyzeResults(
            benchmarkSets[0].map { try await benchmarkRunner.runBenchmark($0) })
        async let analysis2 = performanceAnalyzer.analyzeResults(
            benchmarkSets[1].map { try await benchmarkRunner.runBenchmark($0) })
        async let analysis3 = performanceAnalyzer.analyzeResults(
            benchmarkSets[2].map { try await benchmarkRunner.runBenchmark($0) })

        let results = try await [analysis1, analysis2, analysis3]

        // Then: Validate concurrent execution
        XCTAssertEqual(results.count, 3)
        for analysis in results {
            XCTAssertGreaterThan(analysis.benchmarkAnalyses.count, 0)
            XCTAssertGreaterThanOrEqual(analysis.overallScore, 0)
            XCTAssertLessThanOrEqual(analysis.overallScore, 100)
        }
    }

    /// Test error handling and recovery
    func testErrorHandlingAndRecovery() async throws {
        // Given: Invalid benchmark configuration
        let invalidBenchmark = Benchmark(
            id: "invalid",
            name: "Invalid Benchmark",
            category: .custom,
            setup: { throw BenchmarkError.invalidConfiguration("Test error") },
            execution: { _ in },
            teardown: {}
        )

        // When: Attempt to run invalid benchmark
        do {
            _ = try await benchmarkRunner.runBenchmark(invalidBenchmark)
            XCTFail("Expected error was not thrown")
        } catch let error as BenchmarkError {
            // Then: Validate error handling
            XCTAssertEqual(error, .invalidConfiguration("Test error"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        // Test recovery: Run valid benchmarks after error
        let validResults = try await benchmarkRunner.runBenchmarks(testBenchmarks)
        XCTAssertEqual(validResults.count, testBenchmarks.count)
    }

    /// Test performance under load
    func testPerformanceUnderLoad() async throws {
        // Given: Large number of benchmarks
        let largeBenchmarkSet = (0 ..< 50).map { index in
            Benchmark(
                id: "load_test_\(index)",
                name: "Load Test \(index)",
                category: .performance,
                setup: {},
                execution: { context in
                    // Simulate some work
                    let start = Date()
                    var sum = 0
                    for i in 0 ..< 1000 {
                        sum += i * i
                    }
                    let end = Date()
                    context.measurement = end.timeIntervalSince(start)
                },
                teardown: {}
            )
        }

        // When: Run load test
        let startTime = Date()
        let results = try await benchmarkRunner.runBenchmarks(largeBenchmarkSet)
        let endTime = Date()

        // Then: Validate performance under load
        XCTAssertEqual(results.count, largeBenchmarkSet.count)
        let totalTime = endTime.timeIntervalSince(startTime)
        let avgTimePerBenchmark = totalTime / Double(results.count)

        // Should complete within reasonable time (adjust threshold as needed)
        XCTAssertLessThan(avgTimePerBenchmark, 1.0) // Less than 1 second per benchmark
    }

    /// Test memory management
    func testMemoryManagement() async throws {
        // Given: Benchmarks that allocate memory
        let memoryBenchmarks = createMemoryIntensiveBenchmarks()

        // When: Run memory-intensive benchmarks
        let results = try await benchmarkRunner.runBenchmarks(memoryBenchmarks)

        // Then: Validate memory measurements
        XCTAssertEqual(results.count, memoryBenchmarks.count)

        for result in results {
            if let memoryStats = result.memoryStats {
                XCTAssertGreaterThan(memoryStats.peakUsage, 0)
                XCTAssertGreaterThanOrEqual(memoryStats.averageUsage, 0)
                XCTAssertGreaterThanOrEqual(memoryStats.averageUsage, memoryStats.peakUsage * 0.1) // At least 10% of peak
            }
        }
    }

    /// Test data persistence and retrieval
    func testDataPersistenceAndRetrieval() async throws {
        // Given: Analysis results
        let analysis = try await performanceAnalyzer.analyzeResults(testResults)

        // When: Export and re-import analysis
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try performanceAnalyzer.exportAnalysis(
            analysis, to: tempDir.appendingPathComponent("analysis.json").path
        )

        // Then: Validate file was created and contains expected data
        let exportedURL = tempDir.appendingPathComponent("analysis.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportedURL.path))

        let data = try Data(contentsOf: exportedURL)
        let reimportedAnalysis = try JSONDecoder().decode(PerformanceAnalysis.self, from: data)

        XCTAssertEqual(reimportedAnalysis.benchmarkAnalyses.count, analysis.benchmarkAnalyses.count)
        XCTAssertEqual(reimportedAnalysis.overallScore, analysis.overallScore)
        XCTAssertEqual(reimportedAnalysis.performanceGrade, analysis.performanceGrade)
    }

    // MARK: - Helper Methods

    private func createTestBenchmarks() -> [Benchmark] {
        [
            Benchmark(
                id: "simple_calculation",
                name: "Simple Calculation",
                category: .performance,
                setup: {},
                execution: { context in
                    let start = Date()
                    var result = 0
                    for i in 0 ..< 10000 {
                        result += i * i
                    }
                    let end = Date()
                    context.measurement = end.timeIntervalSince(start)
                },
                teardown: {}
            ),
            Benchmark(
                id: "string_processing",
                name: "String Processing",
                category: .performance,
                setup: {},
                execution: { context in
                    let start = Date()
                    let testString = String(repeating: "test", count: 1000)
                    var processed = ""
                    for _ in 0 ..< 100 {
                        processed = testString.uppercased().lowercased()
                    }
                    let end = Date()
                    context.measurement = end.timeIntervalSince(start)
                },
                teardown: {}
            ),
            Benchmark(
                id: "array_operations",
                name: "Array Operations",
                category: .memory,
                setup: {},
                execution: { context in
                    let start = Date()
                    var array = [Int]()
                    for i in 0 ..< 10000 {
                        array.append(i)
                    }
                    array.sort()
                    array.reverse()
                    let end = Date()
                    context.measurement = end.timeIntervalSince(start)
                },
                teardown: {}
            ),
        ]
    }

    private func createHistoricalResults() -> [BenchmarkResult] {
        var results: [BenchmarkResult] = []

        // Create 5 data points for each benchmark over time
        for i in 0 ..< 5 {
            let timestamp = Date().addingTimeInterval(-Double(i) * 24 * 60 * 60) // Days ago

            for benchmark in testBenchmarks {
                var result = testResults.first { $0.benchmark.id == benchmark.id }!
                result.executionTimestamp = timestamp

                // Add some variation
                let variation = Double.random(in: 0.9 ... 1.1)
                result.measurements = result.measurements.map { measurement in
                    var modified = measurement
                    modified.executionTime *= variation
                    return modified
                }

                results.append(result)
            }
        }

        return results
    }

    private func createModifiedResults(from results: [BenchmarkResult], modificationFactor: Double)
        -> [BenchmarkResult]
    {
        results.map { result in
            var modified = result
            modified.measurements = result.measurements.map { measurement in
                var modifiedMeasurement = measurement
                modifiedMeasurement.executionTime *= modificationFactor
                return modifiedMeasurement
            }
            return modified
        }
    }

    private func createAnomalousResults() -> [BenchmarkResult] {
        var anomalousResults = testResults

        // Create anomalies in first benchmark
        if var firstResult = anomalousResults.first {
            // Add an extremely slow measurement
            let normalTime = firstResult.averageTime
            let anomalousMeasurement = BenchmarkMeasurement(
                executionTime: normalTime * 10, // 10x slower
                timestamp: Date(),
                metadata: ["anomalous": "true"]
            )

            firstResult.measurements.append(anomalousMeasurement)
            anomalousResults[0] = firstResult
        }

        return anomalousResults
    }

    private func createTrendData() async throws -> [TrendAnalysis] {
        var trends: [TrendAnalysis] = []

        for benchmark in testBenchmarks {
            let historicalResults = createHistoricalResults().filter {
                $0.benchmark.id == benchmark.id
            }
            if historicalResults.count >= 3 {
                let trend = try await performanceAnalyzer.analyzeTrends(
                    for: benchmark.id, results: historicalResults
                )
                trends.append(trend)
            }
        }

        return trends
    }

    private func createComparisonData() async throws -> VersionComparison {
        let baselineResults = testResults
        let currentResults = createModifiedResults(from: baselineResults, modificationFactor: 0.95) // 5% improvement

        return try await performanceAnalyzer.compareVersions(
            baseline: baselineResults, current: currentResults
        )
    }

    private func createMemoryIntensiveBenchmarks() -> [Benchmark] {
        [
            Benchmark(
                id: "memory_allocation",
                name: "Memory Allocation Test",
                category: .memory,
                setup: {},
                execution: { context in
                    let start = Date()
                    var arrays = [[Int]]()
                    for _ in 0 ..< 100 {
                        arrays.append(Array(0 ..< 1000))
                    }
                    _ = arrays // Prevent optimization
                    let end = Date()
                    context.measurement = end.timeIntervalSince(start)
                },
                teardown: {}
            ),
        ]
    }
}

// MARK: - Performance Test Cases

extension PerformanceBenchmarkingIntegrationTests {

    /// Performance test for benchmark execution
    func testBenchmarkExecutionPerformance() async throws {
        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    _ = try await benchmarkRunner.runBenchmarks(testBenchmarks)
                    semaphore.signal()
                } catch {
                    semaphore.signal()
                }
            }
            semaphore.wait()
        }
    }

    /// Performance test for analysis
    func testAnalysisPerformance() async throws {
        let results = try await benchmarkRunner.runBenchmarks(testBenchmarks)

        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    _ = try await performanceAnalyzer.analyzeResults(results)
                    semaphore.signal()
                } catch {
                    semaphore.signal()
                }
            }
            semaphore.wait()
        }
    }

    /// Performance test for report generation
    func testReportGenerationPerformance() async throws {
        let results = try await benchmarkRunner.runBenchmarks(testBenchmarks)
        let analysis = try await performanceAnalyzer.analyzeResults(results)

        measure {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    _ = try await reportGenerator.generatePerformanceReport(analysis: analysis)
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

extension BenchmarkRunner {
    func runBenchmarks(_ benchmarks: [Benchmark]) async throws -> [BenchmarkResult] {
        var results: [BenchmarkResult] = []
        for benchmark in benchmarks {
            let result = try await runBenchmark(benchmark)
            results.append(result)
        }
        return results
    }
}
