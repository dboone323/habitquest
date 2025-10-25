//
//  BenchmarkRunner.swift
//  Performance Benchmarking
//
//  Automated benchmark execution system for measuring and comparing
//  performance across different code versions and configurations.
//

import Foundation
import os
import QuartzCore

/// Automated benchmark runner with comprehensive performance measurement
@available(macOS 12.0, *)
public class BenchmarkRunner {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var benchmarkQueue = DispatchQueue(
        label: "com.quantum.benchmark-runner", qos: .userInitiated
    )

    /// Benchmark configuration
    public struct BenchmarkConfig {
        public var iterations: Int = 10
        public var warmupIterations: Int = 3
        public var timeout: TimeInterval = 300.0 // 5 minutes
        public var memorySamplingInterval: TimeInterval = 0.1
        public var enableMemoryTracking: Bool = true
        public var enableCPUTimeTracking: Bool = true
        public var enableThreadTracking: Bool = true
        public var statisticalConfidence: Double = 0.95

        public init() {}
    }

    private var config: BenchmarkConfig

    /// Active benchmarks
    private var activeBenchmarks: [String: BenchmarkExecution] = [:]

    /// Benchmark results storage
    private var resultsStorage: [String: [BenchmarkResult]] = [:]

    // MARK: - Initialization

    public init(config: BenchmarkConfig = BenchmarkConfig()) {
        self.config = config
    }

    // MARK: - Public API

    /// Run a single benchmark
    public func runBenchmark(_ benchmark: Benchmark, context: BenchmarkContext = BenchmarkContext())
        async throws -> BenchmarkResult
    {
        try await benchmarkQueue.async {
            let execution = BenchmarkExecution(
                benchmark: benchmark, config: self.config, context: context
            )

            // Store active benchmark
            self.activeBenchmarks[benchmark.id] = execution

            defer {
                // Clean up
                self.activeBenchmarks.removeValue(forKey: benchmark.id)
            }

            // Execute benchmark
            let result = try self.executeBenchmark(execution)

            // Store result
            self.storeResult(result, for: benchmark.id)

            return result
        }
    }

    /// Run multiple benchmarks
    public func runBenchmarks(
        _ benchmarks: [Benchmark], context: BenchmarkContext = BenchmarkContext()
    ) async throws -> [BenchmarkResult] {
        try await withThrowingTaskGroup(of: BenchmarkResult.self) { group in
            for benchmark in benchmarks {
                group.addTask {
                    try await self.runBenchmark(benchmark, context: context)
                }
            }

            var results: [BenchmarkResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }

    /// Run benchmark suite
    public func runBenchmarkSuite(
        _ suite: BenchmarkSuite, context: BenchmarkContext = BenchmarkContext()
    ) async throws -> BenchmarkSuiteResult {
        let startTime = Date()

        // Run all benchmarks in the suite
        let results = try await runBenchmarks(suite.benchmarks, context: context)

        let totalTime = Date().timeIntervalSince(startTime)

        // Calculate suite-level metrics
        let totalIterations = results.reduce(0) { $0 + $1.iterations }
        let averageTimePerIteration =
            results.map(\.averageTime).reduce(0, +) / Double(results.count)
        let totalMemoryUsed = results.compactMap { $0.memoryStats?.peakUsage }.reduce(0, +)

        return BenchmarkSuiteResult(
            suite: suite,
            results: results,
            totalExecutionTime: totalTime,
            totalIterations: totalIterations,
            averageTimePerIteration: averageTimePerIteration,
            totalMemoryUsed: totalMemoryUsed,
            executionTimestamp: Date(),
            context: context
        )
    }

    /// Compare benchmark results
    public func compareResults(_ baseline: BenchmarkResult, _ current: BenchmarkResult)
        -> BenchmarkComparison
    {
        let timeDifference = current.averageTime - baseline.averageTime
        let timeChangePercent =
            baseline.averageTime > 0 ? (timeDifference / baseline.averageTime) * 100 : 0

        let memoryDifference =
            (current.memoryStats?.peakUsage ?? 0) - (baseline.memoryStats?.peakUsage ?? 0)
        let memoryChangePercent =
            (baseline.memoryStats?.peakUsage ?? 0) > 0
                ? (memoryDifference / (baseline.memoryStats?.peakUsage ?? 0)) * 100 : 0

        // Statistical significance test (simplified t-test)
        let isSignificantTimeChange = abs(timeChangePercent) > 5.0 // 5% threshold
        let isSignificantMemoryChange = abs(memoryChangePercent) > 10.0 // 10% threshold

        var changeType: PerformanceChange = .noChange
        if timeChangePercent < -5.0 { // 5% improvement
            changeType = .improvement
        } else if timeChangePercent > 5.0 { // 5% regression
            changeType = .regression
        }

        return BenchmarkComparison(
            baselineResult: baseline,
            currentResult: current,
            timeDifference: timeDifference,
            timeChangePercent: timeChangePercent,
            memoryDifference: memoryDifference,
            memoryChangePercent: memoryChangePercent,
            isSignificantTimeChange: isSignificantTimeChange,
            isSignificantMemoryChange: isSignificantMemoryChange,
            changeType: changeType,
            comparisonTimestamp: Date()
        )
    }

    /// Get benchmark history
    public func getBenchmarkHistory(for benchmarkId: String, limit: Int = 50) -> [BenchmarkResult] {
        resultsStorage[benchmarkId]?.sorted(by: {
            $0.executionTimestamp > $1.executionTimestamp
        }).prefix(limit).reversed() ?? []
    }

    /// Get performance trends
    public func getPerformanceTrends(for benchmarkId: String, days: Int = 30) -> PerformanceTrend? {
        let history = getBenchmarkHistory(for: benchmarkId)
        let cutoffDate = Date().addingTimeInterval(-Double(days) * 24 * 3600)

        let recentResults = history.filter { $0.executionTimestamp > cutoffDate }
        guard recentResults.count >= 2 else { return nil }

        // Calculate trend using linear regression
        let times = recentResults.map(\.executionTimestamp.timeIntervalSince1970)
        let values = recentResults.map(\.averageTime)

        let trend = calculateLinearTrend(x: times, y: values)

        let averageTime = values.reduce(0, +) / Double(values.count)
        let trendDirection: TrendDirection =
            trend.slope > 0 ? .increasing : (trend.slope < 0 ? .decreasing : .stable)

        return PerformanceTrend(
            benchmarkId: benchmarkId,
            periodDays: days,
            dataPoints: recentResults.count,
            averageTime: averageTime,
            trendSlope: trend.slope,
            trendDirection: trendDirection,
            rSquared: trend.rSquared,
            analysisTimestamp: Date()
        )
    }

    /// Cancel running benchmark
    public func cancelBenchmark(_ benchmarkId: String) {
        if let execution = activeBenchmarks[benchmarkId] {
            execution.cancel()
            activeBenchmarks.removeValue(forKey: benchmarkId)
        }
    }

    /// Get active benchmarks
    public func getActiveBenchmarks() -> [String: BenchmarkExecution] {
        activeBenchmarks
    }

    // MARK: - Private Methods

    private func executeBenchmark(_ execution: BenchmarkExecution) throws -> BenchmarkResult {
        let benchmark = execution.benchmark
        let config = execution.config

        // Warmup phase
        for _ in 0 ..< config.warmupIterations {
            _ = try benchmark.block()
        }

        // Measurement phase
        var measurements: [BenchmarkMeasurement] = []
        var memorySamples: [MemorySample] = []
        var threadSamples: [ThreadSample] = []

        let startTime = CACurrentMediaTime()

        for iteration in 0 ..< config.iterations {
            let iterationStart = CACurrentMediaTime()

            // Memory sampling
            if config.enableMemoryTracking {
                let memorySample = sampleMemory()
                memorySamples.append(MemorySample(timestamp: Date(), usage: memorySample))
            }

            // Thread sampling
            if config.enableThreadTracking {
                let threadSample = sampleThreads()
                threadSamples.append(threadSample)
            }

            // Execute benchmark block
            let result = try benchmark.block()

            let iterationEnd = CACurrentMediaTime()
            let iterationTime = iterationEnd - iterationStart

            let measurement = BenchmarkMeasurement(
                iteration: iteration,
                executionTime: iterationTime,
                result: result,
                timestamp: Date()
            )
            measurements.append(measurement)

            // Check for timeout
            if CACurrentMediaTime() - startTime > config.timeout {
                throw BenchmarkError.timeoutExceeded(benchmark.id)
            }

            // Check for cancellation
            if execution.isCancelled {
                throw BenchmarkError.cancelled(benchmark.id)
            }
        }

        let endTime = CACurrentMediaTime()
        let totalTime = endTime - startTime

        // Calculate statistics
        let executionTimes = measurements.map(\.executionTime)
        let stats = calculateStatistics(executionTimes)

        // Memory statistics
        var memoryStats: MemoryStatistics?
        if config.enableMemoryTracking && !memorySamples.isEmpty {
            let peakUsage = memorySamples.map(\.usage).max() ?? 0
            let averageUsage =
                memorySamples.map(\.usage).reduce(0, +) / Double(memorySamples.count)

            memoryStats = MemoryStatistics(
                peakUsage: peakUsage,
                averageUsage: averageUsage,
                samples: memorySamples
            )
        }

        // Thread statistics
        var threadStats: ThreadStatistics?
        if config.enableThreadTracking && !threadSamples.isEmpty {
            let peakThreadCount = threadSamples.map(\.threadCount).max() ?? 0
            let averageThreadCount =
                threadSamples.map(\.threadCount).reduce(0, +) / Double(threadSamples.count)

            threadStats = ThreadStatistics(
                peakThreadCount: peakThreadCount,
                averageThreadCount: averageThreadCount,
                samples: threadSamples
            )
        }

        return BenchmarkResult(
            benchmark: benchmark,
            iterations: config.iterations,
            totalTime: totalTime,
            averageTime: stats.mean,
            medianTime: stats.median,
            minTime: stats.min,
            maxTime: stats.max,
            standardDeviation: stats.standardDeviation,
            confidenceInterval: stats.confidenceInterval,
            memoryStats: memoryStats,
            threadStats: threadStats,
            measurements: measurements,
            executionTimestamp: Date(),
            config: config
        )
    }

    private func sampleMemory() -> UInt64 {
        // Get memory usage for current process
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), intPtr, &count)
            }
        }

        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }

    private func sampleThreads() -> ThreadSample {
        var threadCount: UInt32 = 0
        var threads: UnsafeMutablePointer<thread_act_t>?

        let result = task_threads(mach_task_self_, &threads, &threadCount)

        if result == KERN_SUCCESS && threadCount > 0 {
            // Clean up thread array
            vm_deallocate(
                mach_task_self_, vm_address_t(bitPattern: threads),
                vm_size_t(Int(threadCount) * MemoryLayout<thread_act_t>.size)
            )
        }

        return ThreadSample(
            timestamp: Date(),
            threadCount: Int(threadCount)
        )
    }

    private func calculateStatistics(_ values: [Double]) -> Statistics {
        let sorted = values.sorted()
        let count = Double(values.count)
        let mean = values.reduce(0, +) / count
        let median = sorted[Int(count / 2)]

        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / (count - 1)
        let standardDeviation = sqrt(variance)

        let min = sorted.first ?? 0
        let max = sorted.last ?? 0

        // Simple confidence interval (95%)
        let confidenceInterval = 1.96 * standardDeviation / sqrt(count)

        return Statistics(
            mean: mean,
            median: median,
            min: min,
            max: max,
            standardDeviation: standardDeviation,
            confidenceInterval: confidenceInterval
        )
    }

    private func calculateLinearTrend(x: [Double], y: [Double]) -> LinearTrend {
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumXX = x.map { $0 * $0 }.reduce(0, +)
        let sumYY = y.map { $0 * $0 }.reduce(0, +)

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

    private func storeResult(_ result: BenchmarkResult, for benchmarkId: String) {
        if resultsStorage[benchmarkId] == nil {
            resultsStorage[benchmarkId] = []
        }
        resultsStorage[benchmarkId]?.append(result)

        // Limit stored results
        if let count = resultsStorage[benchmarkId]?.count, count > 1000 {
            resultsStorage[benchmarkId] = Array(resultsStorage[benchmarkId]!.suffix(100))
        }
    }
}

// MARK: - Supporting Types

/// Benchmark definition
public struct Benchmark {
    public let id: String
    public let name: String
    public let description: String
    public let category: BenchmarkCategory
    public let block: () throws -> Any

    public enum BenchmarkCategory {
        case performance
        case memory
        case concurrency
        case io
        case custom(String)
    }

    public init(
        id: String, name: String, description: String, category: BenchmarkCategory,
        block: @escaping () throws -> Any
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.block = block
    }
}

/// Benchmark suite
public struct BenchmarkSuite {
    public let id: String
    public let name: String
    public let description: String
    public let benchmarks: [Benchmark]
    public let tags: [String]

    public init(
        id: String, name: String, description: String, benchmarks: [Benchmark], tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.benchmarks = benchmarks
        self.tags = tags
    }
}

/// Benchmark context
public struct BenchmarkContext {
    public let environment: String
    public let deviceInfo: String
    public let commitHash: String?
    public let branch: String?
    public let tags: [String]

    public init(
        environment: String = "development", deviceInfo: String = "", commitHash: String? = nil,
        branch: String? = nil, tags: [String] = []
    ) {
        self.environment = environment
        self.deviceInfo = deviceInfo
        self.commitHash = commitHash
        self.branch = branch
        self.tags = tags
    }
}

/// Benchmark execution
public class BenchmarkExecution {
    public let benchmark: Benchmark
    public let config: BenchmarkRunner.BenchmarkConfig
    public let context: BenchmarkContext
    public private(set) var isCancelled: Bool = false

    init(benchmark: Benchmark, config: BenchmarkRunner.BenchmarkConfig, context: BenchmarkContext) {
        self.benchmark = benchmark
        self.config = config
        self.context = context
    }

    func cancel() {
        isCancelled = true
    }
}

/// Benchmark result
public struct BenchmarkResult {
    public let benchmark: Benchmark
    public let iterations: Int
    public let totalTime: TimeInterval
    public let averageTime: TimeInterval
    public let medianTime: TimeInterval
    public let minTime: TimeInterval
    public let maxTime: TimeInterval
    public let standardDeviation: TimeInterval
    public let confidenceInterval: TimeInterval
    public let memoryStats: MemoryStatistics?
    public let threadStats: ThreadStatistics?
    public let measurements: [BenchmarkMeasurement]
    public let executionTimestamp: Date
    public let config: BenchmarkRunner.BenchmarkConfig
}

/// Benchmark suite result
public struct BenchmarkSuiteResult {
    public let suite: BenchmarkSuite
    public let results: [BenchmarkResult]
    public let totalExecutionTime: TimeInterval
    public let totalIterations: Int
    public let averageTimePerIteration: TimeInterval
    public let totalMemoryUsed: UInt64
    public let executionTimestamp: Date
    public let context: BenchmarkContext
}

/// Benchmark comparison
public struct BenchmarkComparison {
    public let baselineResult: BenchmarkResult
    public let currentResult: BenchmarkResult
    public let timeDifference: TimeInterval
    public let timeChangePercent: Double
    public let memoryDifference: Int64
    public let memoryChangePercent: Double
    public let isSignificantTimeChange: Bool
    public let isSignificantMemoryChange: Bool
    public let changeType: PerformanceChange
    public let comparisonTimestamp: Date

    public enum PerformanceChange {
        case improvement
        case regression
        case noChange
    }
}

/// Performance trend
public struct PerformanceTrend {
    public let benchmarkId: String
    public let periodDays: Int
    public let dataPoints: Int
    public let averageTime: TimeInterval
    public let trendSlope: Double
    public let trendDirection: TrendDirection
    public let rSquared: Double
    public let analysisTimestamp: Date

    public enum TrendDirection {
        case increasing
        case decreasing
        case stable
    }
}

/// Benchmark measurement
public struct BenchmarkMeasurement {
    public let iteration: Int
    public let executionTime: TimeInterval
    public let result: Any
    public let timestamp: Date
}

/// Memory statistics
public struct MemoryStatistics {
    public let peakUsage: UInt64
    public let averageUsage: Double
    public let samples: [MemorySample]
}

/// Memory sample
public struct MemorySample {
    public let timestamp: Date
    public let usage: UInt64
}

/// Thread statistics
public struct ThreadStatistics {
    public let peakThreadCount: Int
    public let averageThreadCount: Double
    public let samples: [ThreadSample]
}

/// Thread sample
public struct ThreadSample {
    public let timestamp: Date
    public let threadCount: Int
}

/// Statistics helper
private struct Statistics {
    let mean: Double
    let median: Double
    let min: Double
    let max: Double
    let standardDeviation: Double
    let confidenceInterval: Double
}

/// Linear trend
private struct LinearTrend {
    let slope: Double
    let intercept: Double
    let rSquared: Double
}

/// Benchmark errors
public enum BenchmarkError: Error {
    case timeoutExceeded(String)
    case cancelled(String)
    case executionFailed(String)
    case invalidConfiguration(String)
}

// MARK: - Extensions

extension BenchmarkResult: CustomStringConvertible {
    public var description: String {
        """
        Benchmark Result: \(benchmark.name)
        - Iterations: \(iterations)
        - Average Time: \(String(format: "%.6f", averageTime))s
        - Median Time: \(String(format: "%.6f", medianTime))s
        - Std Dev: \(String(format: "%.6f", standardDeviation))s
        - Memory Peak: \(memoryStats?.peakUsage ?? 0) bytes
        """
    }
}

extension BenchmarkComparison: CustomStringConvertible {
    public var description: String {
        let timeChange = String(format: "%+.1f%%", timeChangePercent)
        let memoryChange = String(format: "%+.1f%%", memoryChangePercent)

        return """
        Performance Comparison:
        - Time Change: \(timeChange)
        - Memory Change: \(memoryChange)
        - Change Type: \(changeType)
        - Significant: Time=\(isSignificantTimeChange), Memory=\(isSignificantMemoryChange)
        """
    }
}

extension PerformanceTrend: CustomStringConvertible {
    public var description: String {
        let slopeDesc = String(format: "%.6f", trendSlope)

        return """
        Performance Trend (\(periodDays) days):
        - Direction: \(trendDirection)
        - Slope: \(slopeDesc)
        - R²: \(String(format: "%.3f", rSquared))
        - Data Points: \(dataPoints)
        """
    }
}
