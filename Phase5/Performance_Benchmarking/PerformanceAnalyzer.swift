//
//  PerformanceAnalyzer.swift
//  Performance Benchmarking
//
//  Advanced performance analysis engine with statistical modeling,
//  anomaly detection, and predictive performance insights.
//

import Charts
import CoreML
import CreateML
import Foundation
import SwiftUI

/// Advanced performance analysis engine
@available(macOS 12.0, *)
public class PerformanceAnalyzer {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var analysisQueue = DispatchQueue(
        label: "com.quantum.performance-analysis", qos: .userInitiated
    )

    /// Analysis configuration
    public struct AnalysisConfig {
        public var anomalyDetectionThreshold: Double = 2.0 // Standard deviations
        public var trendAnalysisWindow: Int = 10 // Data points
        public var predictionHorizon: Int = 5 // Future data points
        public var statisticalConfidence: Double = 0.95
        public var enablePredictiveAnalysis: Bool = true
        public var enableRegressionAnalysis: Bool = true

        public init() {}
    }

    private var config: AnalysisConfig

    /// Historical performance data
    private var performanceHistory: [String: [BenchmarkResult]] = [:]

    /// Analysis models
    private var regressionModels: [String: MLModel] = [:]
    private var anomalyDetectors: [String: AnomalyDetector] = [:]

    // MARK: - Initialization

    public init(config: AnalysisConfig = AnalysisConfig()) {
        self.config = config
    }

    // MARK: - Public API

    /// Analyze benchmark results
    public func analyzeResults(_ results: [BenchmarkResult]) async throws -> PerformanceAnalysis {
        try await analysisQueue.async {
            var analysisResults: [String: BenchmarkAnalysis] = [:]

            for result in results {
                let analysis = try self.analyzeSingleResult(result)
                analysisResults[result.benchmark.id] = analysis
            }

            // Cross-benchmark analysis
            let correlations = try self.analyzeCorrelations(results)
            let bottlenecks = try self.identifyBottlenecks(results)
            let optimizationOpportunities = try self.findOptimizationOpportunities(results)

            // Overall assessment
            let overallScore = self.calculateOverallPerformanceScore(results)
            let performanceGrade = self.assignPerformanceGrade(overallScore)

            return PerformanceAnalysis(
                benchmarkAnalyses: analysisResults,
                correlations: correlations,
                bottlenecks: bottlenecks,
                optimizationOpportunities: optimizationOpportunities,
                overallScore: overallScore,
                performanceGrade: performanceGrade,
                analysisTimestamp: Date(),
                config: self.config
            )
        }
    }

    /// Analyze performance trends
    public func analyzeTrends(for benchmarkId: String, results: [BenchmarkResult]) async throws
        -> TrendAnalysis
    {
        try await analysisQueue.async {
            guard results.count >= 3 else {
                throw AnalysisError.insufficientData(
                    "Need at least 3 data points for trend analysis")
            }

            let sortedResults = results.sorted(by: { $0.executionTimestamp < $1.executionTimestamp }
            )

            // Extract time series data
            let timestamps = sortedResults.map(\.executionTimestamp.timeIntervalSince1970)
            let executionTimes = sortedResults.map(\.averageTime)
            let memoryUsages = sortedResults.compactMap { $0.memoryStats?.peakUsage }

            // Calculate trends
            let timeTrend = self.calculateTrend(timestamps, executionTimes)
            let memoryTrend =
                memoryUsages.count >= 3
                    ? self.calculateTrend(timestamps, memoryUsages.map { Double($0) }) : nil

            // Detect anomalies
            let timeAnomalies = self.detectAnomalies(executionTimes)
            let memoryAnomalies =
                memoryUsages.count >= 3 ? self.detectAnomalies(memoryUsages.map { Double($0) }) : []

            // Predict future performance
            let timePredictions = try self.predictFuturePerformance(
                timestamps, executionTimes, horizon: self.config.predictionHorizon
            )
            let memoryPredictions =
                memoryUsages.count >= 3
                    ? try self.predictFuturePerformance(
                        timestamps, memoryUsages.map { Double($0) },
                        horizon: self.config.predictionHorizon
                    ) : nil

            // Trend classification
            let timeTrendType = self.classifyTrend(timeTrend.slope, timeTrend.rSquared)
            let memoryTrendType = memoryTrend.map { self.classifyTrend($0.slope, $0.rSquared) }

            return TrendAnalysis(
                benchmarkId: benchmarkId,
                dataPoints: results.count,
                timeSeries: TimeSeries(
                    timestamps: timestamps,
                    values: executionTimes,
                    trend: timeTrend,
                    anomalies: timeAnomalies,
                    predictions: timePredictions,
                    trendType: timeTrendType
                ),
                memorySeries: memoryUsages.isEmpty
                    ? nil
                    : MemorySeries(
                        timestamps: timestamps,
                        values: memoryUsages,
                        trend: memoryTrend!,
                        anomalies: memoryAnomalies,
                        predictions: memoryPredictions!,
                        trendType: memoryTrendType!
                    ),
                analysisTimestamp: Date()
            )
        }
    }

    /// Compare performance across versions
    public func compareVersions(baseline: [BenchmarkResult], current: [BenchmarkResult])
        async throws -> VersionComparison
    {
        try await analysisQueue.async {
            var comparisons: [String: BenchmarkComparison] = [:]

            // Match benchmarks by ID
            let baselineById = Dictionary(
                uniqueKeysWithValues: baseline.map { ($0.benchmark.id, $0) })
            let currentById = Dictionary(
                uniqueKeysWithValues: current.map { ($0.benchmark.id, $0) })

            for (benchmarkId, currentResult) in currentById {
                if let baselineResult = baselineById[benchmarkId] {
                    let comparison = BenchmarkRunner().compareResults(baselineResult, currentResult)
                    comparisons[benchmarkId] = comparison
                }
            }

            // Calculate overall metrics
            let timeChanges = comparisons.values.map(\.timeChangePercent)
            let memoryChanges = comparisons.values.compactMap(\.memoryChangePercent)

            let averageTimeChange =
                timeChanges.isEmpty ? 0 : timeChanges.reduce(0, +) / Double(timeChanges.count)
            let averageMemoryChange =
                memoryChanges.isEmpty ? 0 : memoryChanges.reduce(0, +) / Double(memoryChanges.count)

            let significantRegressions = comparisons.values.filter {
                $0.changeType == .regression && $0.isSignificantTimeChange
            }.count
            let significantImprovements = comparisons.values.filter {
                $0.changeType == .improvement && $0.isSignificantTimeChange
            }.count

            // Overall assessment
            var overallChange: VersionChange
            if averageTimeChange < -5.0 && significantRegressions == 0 {
                overallChange = .improvement
            } else if averageTimeChange > 5.0 || significantRegressions > 0 {
                overallChange = .regression
            } else {
                overallChange = .neutral
            }

            return VersionComparison(
                baselineResults: baseline,
                currentResults: current,
                comparisons: comparisons,
                averageTimeChange: averageTimeChange,
                averageMemoryChange: averageMemoryChange,
                significantRegressions: significantRegressions,
                significantImprovements: significantImprovements,
                overallChange: overallChange,
                comparisonTimestamp: Date()
            )
        }
    }

    /// Detect performance anomalies
    public func detectAnomalies(in results: [BenchmarkResult]) async throws -> [PerformanceAnomaly] {
        try await analysisQueue.async {
            var anomalies: [PerformanceAnomaly] = []

            for result in results {
                // Check for statistical anomalies
                if let timeAnomaly = self.detectTimeAnomaly(result) {
                    anomalies.append(timeAnomaly)
                }

                if let memoryAnomaly = self.detectMemoryAnomaly(result) {
                    anomalies.append(memoryAnomaly)
                }

                // Check for measurement inconsistencies
                if let measurementAnomaly = self.detectMeasurementInconsistency(result) {
                    anomalies.append(measurementAnomaly)
                }
            }

            return anomalies.sorted(by: { $0.severity.rawValue > $1.severity.rawValue })
        }
    }

    /// Generate performance insights
    public func generateInsights(from analysis: PerformanceAnalysis) async -> [PerformanceInsight] {
        await analysisQueue.async {
            var insights: [PerformanceInsight] = []

            // Analyze correlations
            for correlation in analysis.correlations.filter({ abs($0.coefficient) > 0.7 }) {
                let insight = PerformanceInsight(
                    type: .correlation,
                    title: "Strong Performance Correlation",
                    description:
                    "\(correlation.benchmarkA) and \(correlation.benchmarkB) show strong correlation (\(String(format: "%.2f", correlation.coefficient)))",
                    severity: .medium,
                    affectedBenchmarks: [correlation.benchmarkA, correlation.benchmarkB],
                    suggestedActions: [
                        "Monitor both benchmarks together", "Consider optimizing shared code paths",
                    ],
                    insightTimestamp: Date()
                )
                insights.append(insight)
            }

            // Analyze bottlenecks
            for bottleneck in analysis.bottlenecks {
                let insight = PerformanceInsight(
                    type: .bottleneck,
                    title: "Performance Bottleneck Identified",
                    description:
                    "\(bottleneck.benchmarkId) shows consistent performance degradation",
                    severity: bottleneck.severity,
                    affectedBenchmarks: [bottleneck.benchmarkId],
                    suggestedActions: [
                        "Profile \(bottleneck.benchmarkId)", "Optimize critical code paths",
                        "Consider algorithmic improvements",
                    ],
                    insightTimestamp: Date()
                )
                insights.append(insight)
            }

            // Analyze optimization opportunities
            for opportunity in analysis.optimizationOpportunities {
                let insight = PerformanceInsight(
                    type: .optimization,
                    title: "Optimization Opportunity",
                    description: opportunity.description,
                    severity: .low,
                    affectedBenchmarks: opportunity.affectedBenchmarks,
                    suggestedActions: opportunity.suggestedActions,
                    insightTimestamp: Date()
                )
                insights.append(insight)
            }

            // Overall performance assessment
            let gradeInsight = PerformanceInsight(
                type: .assessment,
                title: "Overall Performance Assessment",
                description:
                "Performance grade: \(analysis.performanceGrade.rawValue) (Score: \(String(format: "%.1f", analysis.overallScore)))",
                severity: analysis.performanceGrade == .a
                    ? .low : (analysis.performanceGrade == .f ? .high : .medium),
                affectedBenchmarks: [],
                suggestedActions: self.getGradeBasedActions(analysis.performanceGrade),
                insightTimestamp: Date()
            )
            insights.append(gradeInsight)

            return insights.sorted(by: { $0.severity.rawValue > $1.severity.rawValue })
        }
    }

    /// Export analysis data
    public func exportAnalysis(_ analysis: PerformanceAnalysis, to path: String) throws {
        let exportData = AnalysisExportData(
            analysis: analysis,
            exportTimestamp: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(exportData)
        try data.write(to: URL(fileURLWithPath: path))
    }

    // MARK: - Private Methods

    private func analyzeSingleResult(_ result: BenchmarkResult) throws -> BenchmarkAnalysis {
        // Statistical analysis
        let timeStats = StatisticalSummary(
            mean: result.averageTime,
            median: result.medianTime,
            standardDeviation: result.standardDeviation,
            min: result.minTime,
            max: result.maxTime,
            confidenceInterval: result.confidenceInterval
        )

        // Performance classification
        let performanceClass = classifyPerformance(result.averageTime, result.benchmark.category)

        // Memory analysis
        var memoryAnalysis: MemoryAnalysis?
        if let memoryStats = result.memoryStats {
            let memoryEfficiency = calculateMemoryEfficiency(
                memoryStats.peakUsage, result.benchmark.category
            )
            memoryAnalysis = MemoryAnalysis(
                peakUsage: memoryStats.peakUsage,
                averageUsage: memoryStats.averageUsage,
                efficiency: memoryEfficiency,
                hasMemoryLeaks: detectMemoryLeaks(memoryStats.samples)
            )
        }

        // Threading analysis
        var threadingAnalysis: ThreadingAnalysis?
        if let threadStats = result.threadStats {
            threadingAnalysis = ThreadingAnalysis(
                peakThreadCount: threadStats.peakThreadCount,
                averageThreadCount: threadStats.averageThreadCount,
                threadEfficiency: calculateThreadEfficiency(threadStats)
            )
        }

        // Stability assessment
        let stability = assessStability(result.measurements.map(\.executionTime))

        return BenchmarkAnalysis(
            benchmarkId: result.benchmark.id,
            timeStats: timeStats,
            memoryAnalysis: memoryAnalysis,
            threadingAnalysis: threadingAnalysis,
            performanceClass: performanceClass,
            stability: stability,
            analysisTimestamp: Date()
        )
    }

    private func analyzeCorrelations(_ results: [BenchmarkResult]) throws -> [BenchmarkCorrelation] {
        guard results.count >= 2 else { return [] }

        var correlations: [BenchmarkCorrelation] = []

        for i in 0 ..< results.count {
            for j in (i + 1) ..< results.count {
                let resultA = results[i]
                let resultB = results[j]

                // Calculate correlation coefficient
                let timesA = resultA.measurements.map(\.executionTime)
                let timesB = resultB.measurements.map(\.executionTime)

                if let correlation = calculateCorrelation(timesA, timesB) {
                    correlations.append(
                        BenchmarkCorrelation(
                            benchmarkA: resultA.benchmark.id,
                            benchmarkB: resultB.benchmark.id,
                            coefficient: correlation,
                            significance: abs(correlation) > 0.5
                        ))
                }
            }
        }

        return correlations.sorted(by: { abs($0.coefficient) > abs($1.coefficient) })
    }

    private func identifyBottlenecks(_ results: [BenchmarkResult]) throws -> [PerformanceBottleneck] {
        var bottlenecks: [PerformanceBottleneck] = []

        for result in results {
            // Check for consistently slow performance
            if result.averageTime > self.getPerformanceThreshold(result.benchmark.category) {
                let severity: AnomalySeverity
                let ratio =
                    result.averageTime / self.getPerformanceThreshold(result.benchmark.category)

                if ratio > 2.0 {
                    severity = .critical
                } else if ratio > 1.5 {
                    severity = .high
                } else {
                    severity = .medium
                }

                bottlenecks.append(
                    PerformanceBottleneck(
                        benchmarkId: result.benchmark.id,
                        averageTime: result.averageTime,
                        threshold: self.getPerformanceThreshold(result.benchmark.category),
                        severity: severity
                    ))
            }
        }

        return bottlenecks.sorted(by: { $0.severity.rawValue > $1.severity.rawValue })
    }

    private func findOptimizationOpportunities(_ results: [BenchmarkResult]) throws
        -> [OptimizationOpportunity]
    {
        var opportunities: [OptimizationOpportunity] = []

        for result in results {
            // Memory optimization opportunities
            if let memoryStats = result.memoryStats, memoryStats.peakUsage > 100 * 1024 * 1024 { // 100MB
                opportunities.append(
                    OptimizationOpportunity(
                        type: .memory,
                        description:
                        "\(result.benchmark.id) uses high memory (\(memoryStats.peakUsage / 1024 / 1024)MB)",
                        affectedBenchmarks: [result.benchmark.id],
                        suggestedActions: [
                            "Profile memory usage", "Implement memory pooling",
                            "Optimize data structures",
                        ]
                    ))
            }

            // Threading optimization opportunities
            if let threadStats = result.threadStats, threadStats.peakThreadCount > 10 {
                opportunities.append(
                    OptimizationOpportunity(
                        type: .concurrency,
                        description:
                        "\(result.benchmark.id) creates many threads (\(threadStats.peakThreadCount))",
                        affectedBenchmarks: [result.benchmark.id],
                        suggestedActions: [
                            "Use thread pools", "Implement async/await", "Reduce thread contention",
                        ]
                    ))
            }

            // Algorithm optimization opportunities
            if result.standardDeviation / result.averageTime > 0.5 { // High variance
                opportunities.append(
                    OptimizationOpportunity(
                        type: .algorithm,
                        description: "\(result.benchmark.id) shows high timing variance",
                        affectedBenchmarks: [result.benchmark.id],
                        suggestedActions: [
                            "Profile hotspots", "Optimize algorithms", "Reduce I/O operations",
                        ]
                    ))
            }
        }

        return opportunities
    }

    private func calculateOverallPerformanceScore(_ results: [BenchmarkResult]) -> Double {
        var totalScore = 0.0
        var totalWeight = 0.0

        for result in results {
            let weight = getBenchmarkWeight(result.benchmark.category)
            let score = calculateBenchmarkScore(result)
            totalScore += score * weight
            totalWeight += weight
        }

        return totalWeight > 0 ? totalScore / totalWeight : 0.0
    }

    private func assignPerformanceGrade(_ score: Double) -> PerformanceGrade {
        switch score {
        case 90 ... 100: return .a
        case 80 ..< 90: return .b
        case 70 ..< 80: return .c
        case 60 ..< 70: return .d
        default: return .f
        }
    }

    private func calculateTrend(_ x: [Double], _ y: [Double]) -> LinearTrend {
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumXX = x.map { $0 * $0 }.reduce(0, +)

        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n

        // Calculate R-squared
        let yMean = sumY / n
        let ssRes = zip(y, x).map { y, x in pow(y - (slope * x + intercept), 2) }.reduce(0, +)
        let ssTot = y.map { pow($0 - yMean, 2) }.reduce(0, +)
        let rSquared = 1 - (ssRes / ssTot)

        return LinearTrend(
            slope: slope, intercept: intercept, rSquared: rSquared.isNaN ? 0 : rSquared
        )
    }

    private func detectAnomalies(_ values: [Double]) -> [Int] {
        guard values.count >= 3 else { return [] }

        let mean = values.reduce(0, +) / Double(values.count)
        let stdDev = sqrt(values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count - 1))

        var anomalies: [Int] = []
        for (index, value) in values.enumerated() {
            let zScore = abs(value - mean) / stdDev
            if zScore > config.anomalyDetectionThreshold {
                anomalies.append(index)
            }
        }

        return anomalies
    }

    private func predictFuturePerformance(_ timestamps: [Double], _ values: [Double], horizon: Int)
        throws -> [PredictionPoint]
    {
        // Simple linear regression prediction
        let trend = calculateTrend(timestamps, values)

        let lastTimestamp = timestamps.last!
        let timeStep =
            timestamps.count > 1
                ? (timestamps.last! - timestamps.first!) / Double(timestamps.count - 1) : 1.0

        var predictions: [PredictionPoint] = []
        for i in 1 ... horizon {
            let futureTime = lastTimestamp + timeStep * Double(i)
            let predictedValue = trend.slope * futureTime + trend.intercept
            let confidence = max(0, trend.rSquared) // Use R-squared as confidence measure

            predictions.append(
                PredictionPoint(
                    timestamp: futureTime,
                    value: predictedValue,
                    confidence: confidence
                ))
        }

        return predictions
    }

    private func classifyTrend(_ slope: Double, _ rSquared: Double) -> TrendType {
        let absSlope = abs(slope)
        if absSlope < 0.001 || rSquared < 0.3 {
            return .stable
        } else if slope > 0 {
            return .increasing
        } else {
            return .decreasing
        }
    }

    // Helper methods for anomaly detection
    private func detectTimeAnomaly(_ result: BenchmarkResult) -> PerformanceAnomaly? {
        let threshold = getPerformanceThreshold(result.benchmark.category) * 2.0
        if result.averageTime > threshold {
            return PerformanceAnomaly(
                benchmarkId: result.benchmark.id,
                type: .timing,
                description:
                "Execution time (\(String(format: "%.6f", result.averageTime))s) exceeds threshold (\(String(format: "%.6f", threshold))s)",
                severity: .high,
                timestamp: result.executionTimestamp
            )
        }
        return nil
    }

    private func detectMemoryAnomaly(_ result: BenchmarkResult) -> PerformanceAnomaly? {
        guard let memoryStats = result.memoryStats else { return nil }

        let threshold: UInt64 = 500 * 1024 * 1024 // 500MB
        if memoryStats.peakUsage > threshold {
            return PerformanceAnomaly(
                benchmarkId: result.benchmark.id,
                type: .memory,
                description:
                "Memory usage (\(memoryStats.peakUsage / 1024 / 1024)MB) exceeds threshold (500MB)",
                severity: .high,
                timestamp: result.executionTimestamp
            )
        }
        return nil
    }

    private func detectMeasurementInconsistency(_ result: BenchmarkResult) -> PerformanceAnomaly? {
        let times = result.measurements.map(\.executionTime)
        let coefficientOfVariation = result.standardDeviation / result.averageTime

        if coefficientOfVariation > 1.0 { // Very high variance
            return PerformanceAnomaly(
                benchmarkId: result.benchmark.id,
                type: .consistency,
                description:
                "High measurement variance (CV = \(String(format: "%.2f", coefficientOfVariation))) indicates inconsistent performance",
                severity: .medium,
                timestamp: result.executionTimestamp
            )
        }
        return nil
    }

    // Helper methods for analysis
    private func calculateCorrelation(_ x: [Double], _ y: [Double]) -> Double? {
        guard x.count == y.count && x.count > 1 else { return nil }

        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumXX = x.map { $0 * $0 }.reduce(0, +)
        let sumYY = y.map { $0 * $0 }.reduce(0, +)

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY))

        return denominator != 0 ? numerator / denominator : nil
    }

    private func classifyPerformance(_ time: TimeInterval, _ category: Benchmark.BenchmarkCategory)
        -> PerformanceClass
    {
        let threshold = getPerformanceThreshold(category)
        let ratio = time / threshold

        switch ratio {
        case ..<0.5: return .excellent
        case 0.5 ..< 0.8: return .good
        case 0.8 ..< 1.2: return .acceptable
        case 1.2 ..< 2.0: return .poor
        default: return .unacceptable
        }
    }

    private func getPerformanceThreshold(_ category: Benchmark.BenchmarkCategory) -> TimeInterval {
        switch category {
        case .performance: return 0.001 // 1ms
        case .memory: return 0.01 // 10ms
        case .concurrency: return 0.1 // 100ms
        case .io: return 1.0 // 1s
        case .custom: return 0.1 // 100ms
        }
    }

    private func getBenchmarkWeight(_ category: Benchmark.BenchmarkCategory) -> Double {
        switch category {
        case .performance: return 1.0
        case .memory: return 0.8
        case .concurrency: return 0.9
        case .io: return 0.7
        case .custom: return 0.5
        }
    }

    private func calculateBenchmarkScore(_ result: BenchmarkResult) -> Double {
        let timeScore = max(
            0, 100 - (result.averageTime / getPerformanceThreshold(result.benchmark.category)) * 50
        )
        let consistencyScore = max(0, 100 - (result.standardDeviation / result.averageTime) * 100)
        let memoryScore =
            result.memoryStats.map { max(0, 100 - Double($0.peakUsage) / 100_000_000 * 10) } ?? 100

        return timeScore * 0.5 + consistencyScore * 0.3 + memoryScore * 0.2
    }

    private func calculateMemoryEfficiency(_ usage: UInt64, _ category: Benchmark.BenchmarkCategory)
        -> Double
    {
        let baseline = getMemoryBaseline(category)
        return baseline > 0 ? min(1.0, Double(baseline) / Double(usage)) : 1.0
    }

    private func getMemoryBaseline(_ category: Benchmark.BenchmarkCategory) -> UInt64 {
        switch category {
        case .performance: return 50 * 1024 * 1024 // 50MB
        case .memory: return 200 * 1024 * 1024 // 200MB
        case .concurrency: return 100 * 1024 * 1024 // 100MB
        case .io: return 20 * 1024 * 1024 // 20MB
        case .custom: return 50 * 1024 * 1024 // 50MB
        }
    }

    private func detectMemoryLeaks(_ samples: [MemorySample]) -> Bool {
        guard samples.count >= 3 else { return false }

        // Simple leak detection: check if memory consistently increases
        let firstHalf = samples.prefix(samples.count / 2)
        let secondHalf = samples.suffix(samples.count / 2)

        let firstAvg = firstHalf.map { Double($0.usage) }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map { Double($0.usage) }.reduce(0, +) / Double(secondHalf.count)

        return secondAvg > firstAvg * 1.2 // 20% increase
    }

    private func calculateThreadEfficiency(_ stats: ThreadStatistics) -> Double {
        // Efficiency based on thread count vs performance
        // Lower thread counts are generally more efficient
        let optimalThreads = 4.0 // Assume 4 is optimal
        let efficiency = max(
            0, 1.0 - abs(Double(stats.averageThreadCount) - optimalThreads) / optimalThreads
        )
        return efficiency
    }

    private func assessStability(_ times: [TimeInterval]) -> StabilityRating {
        let coefficientOfVariation =
            calculateStandardDeviation(times) / (times.reduce(0, +) / Double(times.count))

        switch coefficientOfVariation {
        case ..<0.1: return .excellent
        case 0.1 ..< 0.2: return .good
        case 0.2 ..< 0.5: return .moderate
        case 0.5 ..< 1.0: return .poor
        default: return .unstable
        }
    }

    private func calculateStandardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count - 1)
        return sqrt(variance)
    }

    private func getGradeBasedActions(_ grade: PerformanceGrade) -> [String] {
        switch grade {
        case .a:
            return ["Maintain current performance standards", "Monitor for regressions"]
        case .b:
            return ["Look for minor optimizations", "Monitor performance trends"]
        case .c:
            return ["Identify performance bottlenecks", "Implement targeted optimizations"]
        case .d:
            return ["Conduct comprehensive performance audit", "Implement major optimizations"]
        case .f:
            return [
                "Immediate performance investigation required", "Consider architectural changes",
            ]
        }
    }
}

// MARK: - Supporting Types

/// Performance analysis result
public struct PerformanceAnalysis {
    public let benchmarkAnalyses: [String: BenchmarkAnalysis]
    public let correlations: [BenchmarkCorrelation]
    public let bottlenecks: [PerformanceBottleneck]
    public let optimizationOpportunities: [OptimizationOpportunity]
    public let overallScore: Double
    public let performanceGrade: PerformanceGrade
    public let analysisTimestamp: Date
    public let config: PerformanceAnalyzer.AnalysisConfig
}

/// Benchmark analysis
public struct BenchmarkAnalysis {
    public let benchmarkId: String
    public let timeStats: StatisticalSummary
    public let memoryAnalysis: MemoryAnalysis?
    public let threadingAnalysis: ThreadingAnalysis?
    public let performanceClass: PerformanceClass
    public let stability: StabilityRating
    public let analysisTimestamp: Date
}

/// Statistical summary
public struct StatisticalSummary {
    public let mean: Double
    public let median: Double
    public let standardDeviation: Double
    public let min: Double
    public let max: Double
    public let confidenceInterval: Double
}

/// Memory analysis
public struct MemoryAnalysis {
    public let peakUsage: UInt64
    public let averageUsage: Double
    public let efficiency: Double
    public let hasMemoryLeaks: Bool
}

/// Threading analysis
public struct ThreadingAnalysis {
    public let peakThreadCount: Int
    public let averageThreadCount: Double
    public let threadEfficiency: Double
}

/// Performance classes
public enum PerformanceClass {
    case excellent, good, acceptable, poor, unacceptable
}

/// Stability ratings
public enum StabilityRating {
    case excellent, good, moderate, poor, unstable
}

/// Performance grades
public enum PerformanceGrade: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case f = "F"
}

/// Benchmark correlation
public struct BenchmarkCorrelation {
    public let benchmarkA: String
    public let benchmarkB: String
    public let coefficient: Double
    public let significance: Bool
}

/// Performance bottleneck
public struct PerformanceBottleneck {
    public let benchmarkId: String
    public let averageTime: TimeInterval
    public let threshold: TimeInterval
    public let severity: AnomalySeverity
}

/// Optimization opportunity
public struct OptimizationOpportunity {
    public let type: OptimizationType
    public let description: String
    public let affectedBenchmarks: [String]
    public let suggestedActions: [String]

    public enum OptimizationType {
        case memory, concurrency, algorithm
    }
}

/// Trend analysis
public struct TrendAnalysis {
    public let benchmarkId: String
    public let dataPoints: Int
    public let timeSeries: TimeSeries
    public let memorySeries: MemorySeries?
    public let analysisTimestamp: Date
}

/// Time series data
public struct TimeSeries {
    public let timestamps: [Double]
    public let values: [Double]
    public let trend: LinearTrend
    public let anomalies: [Int]
    public let predictions: [PredictionPoint]
    public let trendType: TrendType
}

/// Memory series data
public struct MemorySeries {
    public let timestamps: [Double]
    public let values: [UInt64]
    public let trend: LinearTrend
    public let anomalies: [Int]
    public let predictions: [PredictionPoint]
    public let trendType: TrendType
}

/// Linear trend
public struct LinearTrend {
    public let slope: Double
    public let intercept: Double
    public let rSquared: Double
}

/// Prediction point
public struct PredictionPoint {
    public let timestamp: Double
    public let value: Double
    public let confidence: Double
}

/// Trend types
public enum TrendType {
    case increasing, decreasing, stable
}

/// Version comparison
public struct VersionComparison {
    public let baselineResults: [BenchmarkResult]
    public let currentResults: [BenchmarkResult]
    public let comparisons: [String: BenchmarkComparison]
    public let averageTimeChange: Double
    public let averageMemoryChange: Double
    public let significantRegressions: Int
    public let significantImprovements: Int
    public let overallChange: VersionChange
    public let comparisonTimestamp: Date

    public enum VersionChange {
        case improvement, regression, neutral
    }
}

/// Performance anomaly
public struct PerformanceAnomaly {
    public let benchmarkId: String
    public let type: AnomalyType
    public let description: String
    public let severity: AnomalySeverity
    public let timestamp: Date

    public enum AnomalyType {
        case timing, memory, consistency
    }
}

/// Anomaly severity
public enum AnomalySeverity: Int {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
}

/// Performance insight
public struct PerformanceInsight {
    public let type: InsightType
    public let title: String
    public let description: String
    public let severity: AnomalySeverity
    public let affectedBenchmarks: [String]
    public let suggestedActions: [String]
    public let insightTimestamp: Date

    public enum InsightType {
        case correlation, bottleneck, optimization, assessment
    }
}

/// Analysis export data
public struct AnalysisExportData: Codable {
    public let analysis: PerformanceAnalysis
    public let exportTimestamp: Date
}

/// Anomaly detector (placeholder for ML-based detection)
private class AnomalyDetector {
    // Implementation would use ML for anomaly detection
}

/// Analysis errors
public enum AnalysisError: Error {
    case insufficientData(String)
    case invalidInput(String)
    case analysisFailed(String)
}

// MARK: - Extensions

extension PerformanceAnalysis: CustomStringConvertible {
    public var description: String {
        """
        Performance Analysis:
        - Benchmarks Analyzed: \(benchmarkAnalyses.count)
        - Overall Score: \(String(format: "%.1f", overallScore))
        - Grade: \(performanceGrade.rawValue)
        - Correlations Found: \(correlations.count)
        - Bottlenecks Identified: \(bottlenecks.count)
        - Optimization Opportunities: \(optimizationOpportunities.count)
        """
    }
}

extension TrendAnalysis: CustomStringConvertible {
    public var description: String {
        """
        Trend Analysis for \(benchmarkId):
        - Data Points: \(dataPoints)
        - Time Trend: \(timeSeries.trendType)
        - Memory Trend: \(memorySeries?.trendType.rawValue ?? "N/A")
        - Anomalies Detected: \(timeSeries.anomalies.count + (memorySeries?.anomalies.count ?? 0))
        """
    }
}

extension VersionComparison: CustomStringConvertible {
    public var description: String {
        let timeChange = String(format: "%+.1f%%", averageTimeChange)
        let memoryChange = String(format: "%+.1f%%", averageMemoryChange)

        return """
        Version Comparison:
        - Benchmarks Compared: \(comparisons.count)
        - Average Time Change: \(timeChange)
        - Average Memory Change: \(memoryChange)
        - Significant Regressions: \(significantRegressions)
        - Significant Improvements: \(significantImprovements)
        - Overall Change: \(overallChange)
        """
    }
}
