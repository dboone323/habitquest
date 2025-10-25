//
//  MemoryProfiler.swift
//  Memory Profiling System
//
//  This file implements the core memory profiling engine for Phase 5.
//  It provides comprehensive memory monitoring, leak detection, and performance
//  analysis capabilities for Swift applications.
//

import Combine
import Foundation

/// Main memory profiling engine with real-time monitoring and analysis
@available(macOS 12.0, *)
public class MemoryProfiler {

    // MARK: - Properties

    private let monitor: MemoryMonitor
    private let analyzer: MemoryAnalyzer
    private let leakDetector: LeakDetector
    private let performanceAnalyzer: PerformanceAnalyzer

    /// Configuration for memory profiling
    public struct Configuration {
        public var monitoringInterval: TimeInterval = 0.1
        public var enableRealTimeMonitoring: Bool = true
        public var leakDetectionThreshold: Double = 0.1 // MB
        public var performanceAlertThreshold: Double = 100.0 // MB
        public var maxSnapshots: Int = 1000
        public var enableAutomaticCleanup: Bool = false

        public init() {}
    }

    private var config: Configuration
    private var isMonitoring = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties

    /// Publisher for memory usage updates
    public var memoryUsagePublisher: AnyPublisher<MemorySnapshot, Never> {
        monitor.memoryUsagePublisher
    }

    /// Publisher for memory leak alerts
    public var leakAlertPublisher: AnyPublisher<LeakAlert, Never> {
        leakDetector.leakAlertPublisher
    }

    /// Publisher for performance alerts
    public var performanceAlertPublisher: AnyPublisher<PerformanceAlert, Never> {
        performanceAnalyzer.performanceAlertPublisher
    }

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        self.monitor = MemoryMonitor(interval: configuration.monitoringInterval)
        self.analyzer = MemoryAnalyzer()
        self.leakDetector = LeakDetector(threshold: configuration.leakDetectionThreshold)
        self.performanceAnalyzer = PerformanceAnalyzer(
            threshold: configuration.performanceAlertThreshold)

        setupBindings()
    }

    // MARK: - Public API

    /// Start memory profiling
    public func startProfiling() throws {
        guard !isMonitoring else { return }

        try monitor.startMonitoring()
        isMonitoring = true

        print("Memory profiling started")
    }

    /// Stop memory profiling
    public func stopProfiling() {
        guard isMonitoring else { return }

        monitor.stopMonitoring()
        isMonitoring = false

        print("Memory profiling stopped")
    }

    /// Take a memory snapshot
    public func takeSnapshot() -> MemorySnapshot {
        monitor.takeSnapshot()
    }

    /// Get current memory statistics
    public func getCurrentStats() -> MemoryStats {
        analyzer.analyzeSnapshot(takeSnapshot())
    }

    /// Analyze memory usage over time
    public func analyzeMemoryUsage(snapshots: [MemorySnapshot]) -> MemoryAnalysis {
        analyzer.analyzeSnapshots(snapshots)
    }

    /// Detect memory leaks
    public func detectLeaks(snapshots: [MemorySnapshot]) -> [LeakDetection] {
        leakDetector.detectLeaks(in: snapshots)
    }

    /// Get performance recommendations
    public func getPerformanceRecommendations(stats: MemoryStats) -> [PerformanceRecommendation] {
        performanceAnalyzer.generateRecommendations(for: stats)
    }

    /// Export profiling data
    public func exportData(snapshots: [MemorySnapshot], to url: URL) throws {
        let data = try JSONEncoder().encode(ProfilingData(snapshots: snapshots))
        try data.write(to: url)
    }

    /// Import profiling data
    public func importData(from url: URL) throws -> [MemorySnapshot] {
        let data = try Data(contentsOf: url)
        let profilingData = try JSONDecoder().decode(ProfilingData.self, from: data)
        return profilingData.snapshots
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Connect monitor to analyzer
        monitor.memoryUsagePublisher
            .sink { [weak self] snapshot in
                guard let self else { return }
                let stats = self.analyzer.analyzeSnapshot(snapshot)

                // Check for performance issues
                self.performanceAnalyzer.analyzePerformance(stats: stats)
            }
            .store(in: &cancellables)

        // Connect leak detector to monitor
        monitor.memoryUsagePublisher
            .buffer(size: 100, prefetch: .byRequest, whenFull: .dropOldest)
            .sink { [weak self] snapshots in
                guard let self else { return }
                self.leakDetector.analyzeSnapshots(snapshots)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

/// Memory usage snapshot
public struct MemorySnapshot: Codable {
    public let timestamp: Date
    public let totalMemory: UInt64
    public let usedMemory: UInt64
    public let freeMemory: UInt64
    public let residentSize: UInt64
    public let virtualSize: UInt64
    public let pageIns: UInt64
    public let pageOuts: UInt64
    public let pageFaults: UInt64

    public var memoryPressure: Double {
        Double(usedMemory) / Double(totalMemory)
    }

    public init(
        timestamp: Date = Date(),
        totalMemory: UInt64,
        usedMemory: UInt64,
        freeMemory: UInt64,
        residentSize: UInt64,
        virtualSize: UInt64,
        pageIns: UInt64 = 0,
        pageOuts: UInt64 = 0,
        pageFaults: UInt64 = 0
    ) {
        self.timestamp = timestamp
        self.totalMemory = totalMemory
        self.usedMemory = usedMemory
        self.freeMemory = freeMemory
        self.residentSize = residentSize
        self.virtualSize = virtualSize
        self.pageIns = pageIns
        self.pageOuts = pageOuts
        self.pageFaults = pageFaults
    }
}

/// Memory statistics
public struct MemoryStats: Codable {
    public let averageUsage: Double
    public let peakUsage: Double
    public let growthRate: Double
    public let fragmentationRatio: Double
    public let allocationEfficiency: Double
    public let deallocationEfficiency: Double

    public init(
        averageUsage: Double = 0,
        peakUsage: Double = 0,
        growthRate: Double = 0,
        fragmentationRatio: Double = 0,
        allocationEfficiency: Double = 0,
        deallocationEfficiency: Double = 0
    ) {
        self.averageUsage = averageUsage
        self.peakUsage = peakUsage
        self.growthRate = growthRate
        self.fragmentationRatio = fragmentationRatio
        self.allocationEfficiency = allocationEfficiency
        self.deallocationEfficiency = deallocationEfficiency
    }
}

/// Memory analysis results
public struct MemoryAnalysis: Codable {
    public let trend: MemoryTrend
    public let anomalies: [MemoryAnomaly]
    public let recommendations: [String]
    public let riskLevel: RiskLevel

    public enum MemoryTrend {
        case stable
        case increasing
        case decreasing
        case fluctuating
    }

    public enum RiskLevel {
        case low
        case medium
        case high
        case critical
    }

    public init(
        trend: MemoryTrend = .stable,
        anomalies: [MemoryAnomaly] = [],
        recommendations: [String] = [],
        riskLevel: RiskLevel = .low
    ) {
        self.trend = trend
        self.anomalies = anomalies
        self.recommendations = recommendations
        self.riskLevel = riskLevel
    }
}

/// Memory anomaly
public struct MemoryAnomaly: Codable {
    public let timestamp: Date
    public let type: AnomalyType
    public let severity: Double
    public let description: String

    public enum AnomalyType {
        case spike
        case leak
        case fragmentation
        case thrashing
    }

    public init(
        timestamp: Date,
        type: AnomalyType,
        severity: Double,
        description: String
    ) {
        self.timestamp = timestamp
        self.type = type
        self.severity = severity
        self.description = description
    }
}

/// Leak detection result
public struct LeakDetection: Codable {
    public let suspectedLeaks: [SuspectedLeak]
    public let confidence: Double
    public let estimatedLeakSize: UInt64

    public init(
        suspectedLeaks: [SuspectedLeak] = [],
        confidence: Double = 0,
        estimatedLeakSize: UInt64 = 0
    ) {
        self.suspectedLeaks = suspectedLeaks
        self.confidence = confidence
        self.estimatedLeakSize = estimatedLeakSize
    }
}

/// Suspected memory leak
public struct SuspectedLeak: Codable {
    public let allocationSite: String?
    public let size: UInt64
    public let allocationTime: Date
    public let stackTrace: [String]

    public init(
        allocationSite: String? = nil,
        size: UInt64,
        allocationTime: Date,
        stackTrace: [String] = []
    ) {
        self.allocationSite = allocationSite
        self.size = size
        self.allocationTime = allocationTime
        self.stackTrace = stackTrace
    }
}

/// Performance recommendation
public struct PerformanceRecommendation: Codable {
    public let type: RecommendationType
    public let priority: Priority
    public let description: String
    public let estimatedImpact: Double

    public enum RecommendationType {
        case optimization
        case refactoring
        case configuration
        case monitoring
    }

    public enum Priority {
        case low
        case medium
        case high
        case critical
    }

    public init(
        type: RecommendationType,
        priority: Priority,
        description: String,
        estimatedImpact: Double
    ) {
        self.type = type
        self.priority = priority
        self.description = description
        self.estimatedImpact = estimatedImpact
    }
}

/// Leak alert
public struct LeakAlert: Codable {
    public let timestamp: Date
    public let leakSize: UInt64
    public let confidence: Double
    public let description: String

    public init(
        timestamp: Date,
        leakSize: UInt64,
        confidence: Double,
        description: String
    ) {
        self.timestamp = timestamp
        self.leakSize = leakSize
        self.confidence = confidence
        self.description = description
    }
}

/// Performance alert
public struct PerformanceAlert: Codable {
    public let timestamp: Date
    public let memoryUsage: UInt64
    public let threshold: UInt64
    public let description: String

    public init(
        timestamp: Date,
        memoryUsage: UInt64,
        threshold: UInt64,
        description: String
    ) {
        self.timestamp = timestamp
        self.memoryUsage = memoryUsage
        self.threshold = threshold
        self.description = description
    }
}

/// Profiling data for export/import
private struct ProfilingData: Codable {
    let snapshots: [MemorySnapshot]
}
