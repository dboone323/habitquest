//
//  CIIntegration.swift
//  Performance Benchmarking
//
//  CI/CD integration system for automated performance testing,
//  regression detection, and performance gate enforcement.
//

import Combine
import Foundation

/// CI/CD integration system for performance benchmarking
@available(macOS 12.0, *)
public class CIIntegration {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var ciQueue = DispatchQueue(label: "com.quantum.ci-integration", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()

    /// CI configuration
    public struct CIConfig {
        public var enablePerformanceGates: Bool = true
        public var performanceGateThreshold: Double = 80.0 // Minimum score
        public var enableRegressionDetection: Bool = true
        public var regressionThreshold: Double = 5.0 // 5% degradation allowed
        public var enableTrendAnalysis: Bool = true
        public var baselineUpdateStrategy: BaselineUpdateStrategy = .manual
        public var notificationChannels: [NotificationChannel] = [.console]
        public var artifactRetentionDays: Int = 30
        public var enableHistoricalComparison: Bool = true

        public init() {}
    }

    private var config: CIConfig

    /// Performance baseline data
    private var baselineData: [String: BenchmarkResult] = [:]

    /// CI status
    private var currentStatus: CIStatus = .idle

    /// Performance history for trend analysis
    private var performanceHistory: [String: [PerformanceSnapshot]] = [:]

    // MARK: - Initialization

    public init(config: CIConfig = CIConfig()) {
        self.config = config
        loadBaselineData()
        setupNotificationChannels()
    }

    // MARK: - Public API

    /// Run performance tests in CI environment
    public func runPerformanceTests(
        benchmarks: [Benchmark],
        baselinePath: String? = nil,
        outputPath: String? = nil
    ) async throws -> CIResult {
        try await ciQueue.async {
            self.currentStatus = .running

            defer {
                self.currentStatus = .idle
            }

            do {
                // Load baseline if provided
                if let baselinePath {
                    try self.loadBaselineFromPath(baselinePath)
                }

                // Run benchmarks
                let runner = BenchmarkRunner()
                var results: [BenchmarkResult] = []

                for benchmark in benchmarks {
                    self.notify(.info, "Running benchmark: \(benchmark.id)")
                    let result = try await runner.runBenchmark(benchmark)
                    results.append(result)
                }

                // Analyze results
                let analyzer = PerformanceAnalyzer()
                let analysis = try await analyzer.analyzeResults(results)

                // Check performance gates
                let gateResult = try self.checkPerformanceGates(analysis)

                // Detect regressions
                let regressionResult = try self.detectRegressions(results)

                // Update trends
                try self.updatePerformanceTrends(results)

                // Generate reports
                let reportGenerator = ReportGenerator()
                let report = try await reportGenerator.generatePerformanceReport(analysis)

                // Export results
                if let outputPath {
                    try await reportGenerator.exportReport(report, to: outputPath)
                }

                // Update baseline if needed
                try self.updateBaselineIfNeeded(results, analysis)

                // Create CI result
                let ciResult = CIResult(
                    status: gateResult.passed ? .success : .failure,
                    benchmarkResults: results,
                    analysis: analysis,
                    gateResult: gateResult,
                    regressionResult: regressionResult,
                    report: report,
                    executionTimestamp: Date(),
                    config: self.config
                )

                // Notify completion
                self.notifyResult(ciResult)

                return ciResult

            } catch {
                self.currentStatus = .failed
                self.notify(.error, "CI performance tests failed: \(error.localizedDescription)")
                throw error
            }
        }
    }

    /// Check performance gates
    public func checkPerformanceGates(_ analysis: PerformanceAnalysis) throws -> GateResult {
        guard config.enablePerformanceGates else {
            return GateResult(
                passed: true, score: analysis.overallScore,
                threshold: config.performanceGateThreshold, violations: []
            )
        }

        var violations: [GateViolation] = []

        // Overall score check
        if analysis.overallScore < config.performanceGateThreshold {
            violations.append(
                GateViolation(
                    type: .overallScore,
                    description:
                    "Overall performance score \(String(format: "%.1f", analysis.overallScore)) below threshold \(config.performanceGateThreshold)",
                    severity: .high
                ))
        }

        // Individual benchmark checks
        for (id, benchmarkAnalysis) in analysis.benchmarkAnalyses {
            // Performance class check
            if benchmarkAnalysis.performanceClass == .unacceptable {
                violations.append(
                    GateViolation(
                        type: .benchmarkPerformance,
                        description: "Benchmark \(id) has unacceptable performance",
                        severity: .high
                    ))
            }

            // Stability check
            if benchmarkAnalysis.stability == .unstable {
                violations.append(
                    GateViolation(
                        type: .benchmarkStability,
                        description: "Benchmark \(id) shows unstable performance",
                        severity: .medium
                    ))
            }
        }

        // Bottleneck check
        for bottleneck in analysis.bottlenecks where bottleneck.severity == .critical {
            violations.append(
                GateViolation(
                    type: .bottleneck,
                    description: "Critical bottleneck detected in \(bottleneck.benchmarkId)",
                    severity: .critical
                ))
        }

        let passed = violations.isEmpty || violations.allSatisfy { $0.severity != .critical }

        return GateResult(
            passed: passed,
            score: analysis.overallScore,
            threshold: config.performanceGateThreshold,
            violations: violations
        )
    }

    /// Detect performance regressions
    public func detectRegressions(_ results: [BenchmarkResult]) throws -> RegressionResult {
        guard config.enableRegressionDetection else {
            return RegressionResult(
                regressions: [], improvements: [], threshold: config.regressionThreshold
            )
        }

        var regressions: [PerformanceRegression] = []
        var improvements: [PerformanceRegression] = []

        for result in results {
            if let baselineResult = baselineData[result.benchmark.id] {
                let comparison = BenchmarkRunner().compareResults(baselineResult, result)

                if comparison.changeType == .regression
                    && abs(comparison.timeChangePercent) >= config.regressionThreshold
                {
                    regressions.append(
                        PerformanceRegression(
                            benchmarkId: result.benchmark.id,
                            baselineTime: baselineResult.averageTime,
                            currentTime: result.averageTime,
                            changePercent: comparison.timeChangePercent,
                            severity: abs(comparison.timeChangePercent) > 10 ? .high : .medium
                        ))
                } else if comparison.changeType == .improvement
                    && abs(comparison.timeChangePercent) >= config.regressionThreshold
                {
                    improvements.append(
                        PerformanceRegression(
                            benchmarkId: result.benchmark.id,
                            baselineTime: baselineResult.averageTime,
                            currentTime: result.averageTime,
                            changePercent: comparison.timeChangePercent,
                            severity: .low
                        ))
                }
            }
        }

        return RegressionResult(
            regressions: regressions,
            improvements: improvements,
            threshold: config.regressionThreshold
        )
    }

    /// Update performance trends
    public func updatePerformanceTrends(_ results: [BenchmarkResult]) throws {
        guard config.enableTrendAnalysis else { return }

        let snapshot = PerformanceSnapshot(
            timestamp: Date(),
            results: results
        )

        for result in results {
            if performanceHistory[result.benchmark.id] == nil {
                performanceHistory[result.benchmark.id] = []
            }
            performanceHistory[result.benchmark.id]?.append(snapshot)
        }

        // Clean up old data
        let cutoffDate = Date().addingTimeInterval(
            -Double(config.artifactRetentionDays) * 24 * 60 * 60)
        for (key, snapshots) in performanceHistory {
            performanceHistory[key] = snapshots.filter { $0.timestamp > cutoffDate }
        }
    }

    /// Get performance trends
    public func getPerformanceTrends(for benchmarkId: String, days: Int = 30) throws
        -> [PerformanceSnapshot]?
    {
        guard let snapshots = performanceHistory[benchmarkId] else { return nil }

        let cutoffDate = Date().addingTimeInterval(-Double(days) * 24 * 60 * 60)
        return snapshots.filter { $0.timestamp > cutoffDate }.sorted(by: {
            $0.timestamp < $1.timestamp
        })
    }

    /// Export CI artifacts
    public func exportCIArtifacts(_ result: CIResult, to directory: String) throws {
        let baseURL = URL(fileURLWithPath: directory)
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)

        // Export results as JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let resultsData = try encoder.encode(result.benchmarkResults)
        try resultsData.write(to: baseURL.appendingPathComponent("benchmark_results.json"))

        let analysisData = try encoder.encode(result.analysis)
        try analysisData.write(to: baseURL.appendingPathComponent("performance_analysis.json"))

        // Export gate results
        let gateData = try encoder.encode(result.gateResult)
        try gateData.write(to: baseURL.appendingPathComponent("gate_results.json"))

        // Export regression results
        let regressionData = try encoder.encode(result.regressionResult)
        try regressionData.write(to: baseURL.appendingPathComponent("regression_results.json"))

        // Export status
        let statusData = try encoder.encode([
            "status": result.status.rawValue, "timestamp": result.executionTimestamp,
        ])
        try statusData.write(to: baseURL.appendingPathComponent("ci_status.json"))
    }

    /// Generate CI summary for PR comments
    public func generateCISummary(_ result: CIResult) -> String {
        var summary = "## 🚀 Performance Test Results\n\n"

        // Status
        let statusEmoji = result.status == .success ? "✅" : "❌"
        summary += "### \(statusEmoji) Status: \(result.status.rawValue.capitalized)\n\n"

        // Overall score
        summary += "### 📊 Overall Performance\n"
        summary += "- **Score**: \(String(format: "%.1f", result.analysis.overallScore))/100\n"
        summary += "- **Grade**: \(result.analysis.performanceGrade.rawValue)\n"
        summary += "- **Benchmarks**: \(result.benchmarkResults.count)\n\n"

        // Gates
        if config.enablePerformanceGates {
            let gateEmoji = result.gateResult.passed ? "✅" : "❌"
            summary += "### 🚪 Performance Gates\n"
            summary +=
                "\(gateEmoji) **Result**: \(result.gateResult.passed ? "PASSED" : "FAILED")\n"

            if !result.gateResult.violations.isEmpty {
                summary += "**Violations**:\n"
                for violation in result.gateResult.violations {
                    let severityEmoji =
                        violation.severity == .critical
                            ? "🚨" : violation.severity == .high ? "⚠️" : "ℹ️"
                    summary += "- \(severityEmoji) \(violation.description)\n"
                }
                summary += "\n"
            }
        }

        // Regressions
        if config.enableRegressionDetection {
            summary += "### 📈 Performance Changes\n"

            if !result.regressionResult.regressions.isEmpty {
                summary += "**⚠️ Regressions**:\n"
                for regression in result.regressionResult.regressions {
                    summary +=
                        "- `\(regression.benchmarkId)`: \(String(format: "%+.1f%%", regression.changePercent))\n"
                }
                summary += "\n"
            }

            if !result.regressionResult.improvements.isEmpty {
                summary += "**✅ Improvements**:\n"
                for improvement in result.regressionResult.improvements {
                    summary +=
                        "- `\(improvement.benchmarkId)`: \(String(format: "%+.1f%%", improvement.changePercent))\n"
                }
                summary += "\n"
            }

            if result.regressionResult.regressions.isEmpty
                && result.regressionResult.improvements.isEmpty
            {
                summary += "No significant performance changes detected.\n\n"
            }
        }

        // Recommendations
        if !result.report.recommendations.isEmpty {
            summary += "### 💡 Recommendations\n"
            for recommendation in result.report.recommendations.prefix(3) { // Show top 3
                let priorityEmoji =
                    recommendation.priority == .critical
                        ? "🚨" : recommendation.priority == .high ? "⚠️" : "ℹ️"
                summary += "- \(priorityEmoji) \(recommendation.description)\n"
            }

            if result.report.recommendations.count > 3 {
                summary +=
                    "- ... and \(result.report.recommendations.count - 3) more recommendations\n"
            }
            summary += "\n"
        }

        // Links
        summary += "### 📋 Details\n"
        summary += "- [Full Report](\(result.report.id).html)\n"
        summary += "- [Performance Analysis](\(result.report.id)_analysis.json)\n"
        summary += "- [Benchmark Results](\(result.report.id)_results.json)\n\n"

        summary += "*Generated by Quantum Performance Benchmarking CI Integration*"

        return summary
    }

    /// Get current CI status
    public func getCIStatus() -> CIStatus {
        currentStatus
    }

    /// Configure CI settings
    public func updateConfiguration(_ newConfig: CIConfig) {
        config = newConfig
        setupNotificationChannels()
    }

    // MARK: - Private Methods

    private func loadBaselineData() {
        // Load baseline from standard location
        let baselineURL = getBaselineURL()
        if fileManager.fileExists(atPath: baselineURL.path) {
            do {
                let data = try Data(contentsOf: baselineURL)
                let decoder = JSONDecoder()
                baselineData = try decoder.decode([String: BenchmarkResult].self, from: data)
                notify(.info, "Loaded baseline data for \(baselineData.count) benchmarks")
            } catch {
                notify(.warning, "Failed to load baseline data: \(error.localizedDescription)")
            }
        }
    }

    private func loadBaselineFromPath(_ path: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        baselineData = try decoder.decode([String: BenchmarkResult].self, from: data)
        notify(.info, "Loaded baseline data from \(path)")
    }

    private func updateBaselineIfNeeded(
        _ results: [BenchmarkResult], _ analysis: PerformanceAnalysis
    ) throws {
        guard config.baselineUpdateStrategy == .automatic else { return }

        // Only update baseline if performance is good
        guard analysis.overallScore >= config.performanceGateThreshold else {
            notify(.info, "Baseline not updated due to low performance score")
            return
        }

        // Update baseline with current results
        for result in results {
            baselineData[result.benchmark.id] = result
        }

        // Save updated baseline
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(baselineData)
        try data.write(to: getBaselineURL())

        notify(.info, "Updated baseline data for \(results.count) benchmarks")
    }

    private func getBaselineURL() -> URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        return appSupport.appendingPathComponent("Quantum").appendingPathComponent(
            "performance_baseline.json")
    }

    private func setupNotificationChannels() {
        // Setup notification channels based on config
        // This would integrate with various notification systems
    }

    private func notify(_ level: NotificationLevel, _ message: String) {
        let notification = NotificationMessage(level: level, message: message, timestamp: Date())

        for channel in config.notificationChannels {
            switch channel {
            case .console:
                print("[\(level.rawValue.uppercased())] \(message)")
            case .slack:
                // Integrate with Slack API
                sendSlackNotification(notification)
            case .email:
                // Integrate with email service
                sendEmailNotification(notification)
            case .webhook:
                // Send to webhook
                sendWebhookNotification(notification)
            }
        }
    }

    private func notifyResult(_ result: CIResult) {
        let message =
            result.status == .success
                ? "✅ Performance tests completed successfully" : "❌ Performance tests failed"

        notify(.info, message)

        // Send detailed results to appropriate channels
        if result.status == .failure {
            let summary = generateCISummary(result)
            notify(.error, "Performance test failure details:\n\(summary)")
        }
    }

    private func sendSlackNotification(_ notification: NotificationMessage) {
        // Placeholder for Slack integration
        print("Slack notification: \(notification.message)")
    }

    private func sendEmailNotification(_ notification: NotificationMessage) {
        // Placeholder for email integration
        print("Email notification: \(notification.message)")
    }

    private func sendWebhookNotification(_ notification: NotificationMessage) {
        // Placeholder for webhook integration
        print("Webhook notification: \(notification.message)")
    }
}

// MARK: - Supporting Types

/// CI result
public struct CIResult {
    public let status: CIStatus
    public let benchmarkResults: [BenchmarkResult]
    public let analysis: PerformanceAnalysis
    public let gateResult: GateResult
    public let regressionResult: RegressionResult
    public let report: PerformanceReport
    public let executionTimestamp: Date
    public let config: CIIntegration.CIConfig
}

/// CI status
public enum CIStatus: String {
    case idle, running, success, failure, failed
}

/// Gate result
public struct GateResult {
    public let passed: Bool
    public let score: Double
    public let threshold: Double
    public let violations: [GateViolation]
}

/// Gate violation
public struct GateViolation {
    public let type: ViolationType
    public let description: String
    public let severity: ViolationSeverity

    public enum ViolationType {
        case overallScore, benchmarkPerformance, benchmarkStability, bottleneck
    }

    public enum ViolationSeverity {
        case low, medium, high, critical
    }
}

/// Regression result
public struct RegressionResult {
    public let regressions: [PerformanceRegression]
    public let improvements: [PerformanceRegression]
    public let threshold: Double
}

/// Performance regression
public struct PerformanceRegression {
    public let benchmarkId: String
    public let baselineTime: TimeInterval
    public let currentTime: TimeInterval
    public let changePercent: Double
    public let severity: ViolationSeverity
}

/// Performance snapshot
public struct PerformanceSnapshot {
    public let timestamp: Date
    public let results: [BenchmarkResult]
}

/// Notification channel
public enum NotificationChannel {
    case console, slack, email, webhook
}

/// Notification level
public enum NotificationLevel: String {
    case info, warning, error
}

/// Notification message
public struct NotificationMessage {
    public let level: NotificationLevel
    public let message: String
    public let timestamp: Date
}

/// Baseline update strategy
public enum BaselineUpdateStrategy {
    case manual, automatic
}

// MARK: - Extensions

extension CIResult: CustomStringConvertible {
    public var description: String {
        """
        CI Result:
        - Status: \(status.rawValue.capitalized)
        - Benchmarks: \(benchmarkResults.count)
        - Score: \(String(format: "%.1f", analysis.overallScore))
        - Gates Passed: \(gateResult.passed)
        - Regressions: \(regressionResult.regressions.count)
        - Improvements: \(regressionResult.improvements.count)
        """
    }
}

extension GateResult: CustomStringConvertible {
    public var description: String {
        """
        Gate Result:
        - Passed: \(passed)
        - Score: \(String(format: "%.1f", score))/\(threshold)
        - Violations: \(violations.count)
        """
    }
}

extension RegressionResult: CustomStringConvertible {
    public var description: String {
        """
        Regression Result:
        - Regressions: \(regressions.count)
        - Improvements: \(improvements.count)
        - Threshold: \(String(format: "%.1f%%", threshold))
        """
    }
}

extension CIIntegration.CIConfig: Codable {}
extension CIIntegration.CIConfig: CustomStringConvertible {
    public var description: String {
        "CIConfig(enableGates: \(enablePerformanceGates), threshold: \(performanceGateThreshold), enableRegression: \(enableRegressionDetection))"
    }
}

extension NotificationChannel: Codable {}
extension NotificationLevel: Codable {}
extension BaselineUpdateStrategy: Codable {}
