//
//  MemoryAnalyzer.swift
//  Memory Profiling System
//
//  This file implements the memory analysis engine that processes memory snapshots
//  and provides detailed analysis, anomaly detection, and performance insights.
//

import Foundation

/// Memory analysis engine for processing and analyzing memory snapshots
@available(macOS 12.0, *)
public class MemoryAnalyzer {

    // MARK: - Properties

    private let anomalyDetector: AnomalyDetector
    private let trendAnalyzer: TrendAnalyzer

    /// Configuration for memory analysis
    public struct Configuration {
        public var anomalyThreshold: Double = 2.0 // Standard deviations
        public var trendWindowSize: Int = 50
        public var fragmentationThreshold: Double = 0.3
        public var growthRateThreshold: Double = 0.1 // MB per minute

        public init() {}
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        self.anomalyDetector = AnomalyDetector(threshold: configuration.anomalyThreshold)
        self.trendAnalyzer = TrendAnalyzer(windowSize: configuration.trendWindowSize)
    }

    // MARK: - Public API

    /// Analyze a single memory snapshot
    public func analyzeSnapshot(_ snapshot: MemorySnapshot) -> MemoryStats {
        let usage = Double(snapshot.usedMemory) / (1024 * 1024) // Convert to MB

        // Calculate basic statistics (would need historical data for full analysis)
        return MemoryStats(
            averageUsage: usage,
            peakUsage: usage,
            growthRate: 0, // Would need previous snapshots
            fragmentationRatio: calculateFragmentationRatio(snapshot),
            allocationEfficiency: 0.8, // Placeholder
            deallocationEfficiency: 0.9 // Placeholder
        )
    }

    /// Analyze multiple memory snapshots
    public func analyzeSnapshots(_ snapshots: [MemorySnapshot]) -> MemoryAnalysis {
        guard !snapshots.isEmpty else {
            return MemoryAnalysis()
        }

        // Analyze trends
        let trend = analyzeTrend(snapshots)

        // Detect anomalies
        let anomalies = detectAnomalies(snapshots)

        // Generate recommendations
        let recommendations = generateRecommendations(snapshots, anomalies: anomalies)

        // Assess risk level
        let riskLevel = assessRiskLevel(snapshots, anomalies: anomalies)

        return MemoryAnalysis(
            trend: trend,
            anomalies: anomalies,
            recommendations: recommendations,
            riskLevel: riskLevel
        )
    }

    /// Calculate memory fragmentation ratio
    public func calculateFragmentationRatio(_ snapshot: MemorySnapshot) -> Double {
        // Simplified fragmentation calculation
        // In a real implementation, this would analyze memory allocation patterns
        let usedRatio = Double(snapshot.usedMemory) / Double(snapshot.totalMemory)
        let residentRatio = Double(snapshot.residentSize) / Double(snapshot.virtualSize)

        // Fragmentation is higher when resident size is much smaller than virtual size
        // relative to memory usage
        if residentRatio > 0 {
            return max(0, min(1, (usedRatio - residentRatio) / usedRatio))
        }

        return 0
    }

    /// Detect memory leaks using growth pattern analysis
    public func detectMemoryLeaks(_ snapshots: [MemorySnapshot]) -> LeakDetection {
        guard snapshots.count >= 10 else {
            return LeakDetection()
        }

        let usages = snapshots.map { Double($0.usedMemory) }
        let growthRate = calculateGrowthRate(usages)

        // Simple leak detection: consistent growth over time
        let leakThreshold = config.growthRateThreshold * 1024 * 1024 // Convert MB to bytes
        let isLeaking = growthRate > leakThreshold

        if isLeaking {
            let estimatedLeakSize = UInt64(growthRate * Double(snapshots.count))
            let confidence = min(1.0, growthRate / (leakThreshold * 2))

            return LeakDetection(
                suspectedLeaks: [
                    SuspectedLeak(
                        allocationSite: "Unknown (growth pattern analysis)",
                        size: estimatedLeakSize,
                        allocationTime: snapshots.first!.timestamp,
                        stackTrace: []
                    ),
                ],
                confidence: confidence,
                estimatedLeakSize: estimatedLeakSize
            )
        }

        return LeakDetection()
    }

    /// Analyze memory allocation patterns
    public func analyzeAllocationPatterns(_ snapshots: [MemorySnapshot]) -> AllocationAnalysis {
        guard !snapshots.isEmpty else {
            return AllocationAnalysis()
        }

        let usages = snapshots.map { Double($0.usedMemory) }
        let pageFaults = snapshots.map { Double($0.pageFaults) }

        let averageUsage = usages.reduce(0, +) / Double(usages.count)
        let peakUsage = usages.max() ?? 0
        let totalPageFaults = pageFaults.last! - pageFaults.first!

        let allocationEfficiency = calculateAllocationEfficiency(usages)
        let deallocationEfficiency = calculateDeallocationEfficiency(usages)

        return AllocationAnalysis(
            averageAllocationSize: averageUsage,
            peakAllocationSize: peakUsage,
            totalPageFaults: UInt64(totalPageFaults),
            allocationEfficiency: allocationEfficiency,
            deallocationEfficiency: deallocationEfficiency,
            allocationPattern: determineAllocationPattern(usages)
        )
    }

    /// Generate performance insights
    public func generatePerformanceInsights(_ snapshots: [MemorySnapshot]) -> [PerformanceInsight] {
        var insights: [PerformanceInsight] = []

        let analysis = analyzeSnapshots(snapshots)
        let allocationAnalysis = analyzeAllocationPatterns(snapshots)

        // Memory usage insights
        if analysis.trend == .rapidlyIncreasing {
            insights.append(
                PerformanceInsight(
                    type: .memoryLeak,
                    severity: .high,
                    description:
                    "Memory usage is rapidly increasing, indicating a potential memory leak",
                    recommendation: "Review object lifecycles and ensure proper deallocation"
                ))
        }

        // Allocation pattern insights
        if allocationAnalysis.allocationPattern == .frequent {
            insights.append(
                PerformanceInsight(
                    type: .allocation,
                    severity: .medium,
                    description: "Frequent memory allocations detected",
                    recommendation: "Consider using object pooling or reducing allocation frequency"
                ))
        }

        // Page fault insights
        if allocationAnalysis.totalPageFaults > 10000 {
            insights.append(
                PerformanceInsight(
                    type: .pageFaults,
                    severity: .medium,
                    description: "High number of page faults indicating memory pressure",
                    recommendation:
                    "Consider increasing available memory or optimizing memory usage"
                ))
        }

        return insights
    }

    // MARK: - Private Methods

    private func analyzeTrend(_ snapshots: [MemorySnapshot]) -> MemoryAnalysis.MemoryTrend {
        guard snapshots.count >= 2 else { return .stable }

        let usages = snapshots.map { Double($0.usedMemory) }
        let trendAnalyzer = TrendAnalyzer(windowSize: min(config.trendWindowSize, snapshots.count))

        return trendAnalyzer.analyzeTrend(usages)
    }

    private func detectAnomalies(_ snapshots: [MemorySnapshot]) -> [MemoryAnomaly] {
        guard snapshots.count >= 10 else { return [] }

        let usages = snapshots.map { Double($0.usedMemory) }
        let anomalies = anomalyDetector.detectAnomalies(usages)

        return anomalies.enumerated().compactMap { index, isAnomaly in
            guard isAnomaly else { return nil }

            let snapshot = snapshots[index]
            let usage = Double(snapshot.usedMemory) / (1024 * 1024) // MB

            return MemoryAnomaly(
                timestamp: snapshot.timestamp,
                type: .spike,
                severity: 0.8,
                description: "Memory usage spike detected: \(String(format: "%.1f", usage)) MB"
            )
        }
    }

    private func generateRecommendations(_ snapshots: [MemorySnapshot], anomalies: [MemoryAnomaly])
        -> [String]
    {
        var recommendations: [String] = []

        let analysis = analyzeSnapshots(snapshots)
        let leakDetection = detectMemoryLeaks(snapshots)

        if analysis.trend == .rapidlyIncreasing {
            recommendations.append("Monitor memory usage trends - rapid increase detected")
        }

        if !anomalies.isEmpty {
            recommendations.append(
                "Investigate \(anomalies.count) memory anomalies for potential issues")
        }

        if leakDetection.confidence > 0.7 {
            recommendations.append(
                "High confidence memory leak detected - review allocation patterns")
        }

        if analysis.riskLevel == .high || analysis.riskLevel == .critical {
            recommendations.append(
                "Critical memory issues detected - immediate investigation required")
        }

        return recommendations
    }

    private func assessRiskLevel(_ snapshots: [MemorySnapshot], anomalies: [MemoryAnomaly])
        -> MemoryAnalysis.RiskLevel
    {
        let leakDetection = detectMemoryLeaks(snapshots)
        let anomalyCount = anomalies.count

        if leakDetection.confidence > 0.8 || anomalyCount > 10 {
            return .critical
        } else if leakDetection.confidence > 0.6 || anomalyCount > 5 {
            return .high
        } else if anomalyCount > 2 {
            return .medium
        } else {
            return .low
        }
    }

    private func calculateGrowthRate(_ usages: [Double]) -> Double {
        guard usages.count >= 2 else { return 0 }

        let first = usages.first!
        let last = usages.last!
        let periods = Double(usages.count - 1)

        return (last - first) / periods
    }

    private func calculateAllocationEfficiency(_ usages: [Double]) -> Double {
        // Simplified efficiency calculation
        // In a real implementation, this would analyze allocation/deallocation patterns
        guard usages.count >= 2 else { return 0.8 }

        let changes = zip(usages.dropFirst(), usages).map { abs($0 - $1) }
        let averageChange = changes.reduce(0, +) / Double(changes.count)
        let averageUsage = usages.reduce(0, +) / Double(usages.count)

        if averageUsage > 0 {
            return max(0, min(1, 1 - (averageChange / averageUsage)))
        }

        return 0.8
    }

    private func calculateDeallocationEfficiency(_ usages: [Double]) -> Double {
        // Simplified deallocation efficiency
        // Would need more sophisticated analysis in production
        0.85
    }

    private func determineAllocationPattern(_ usages: [Double]) -> AllocationPattern {
        guard usages.count >= 10 else { return .unknown }

        let changes = zip(usages.dropFirst(), usages).map { abs($0 - $1) }
        let averageChange = changes.reduce(0, +) / Double(changes.count)
        let maxChange = changes.max() ?? 0

        if maxChange > averageChange * 3 {
            return .bursty
        } else if averageChange > Double(usages.first ?? 0) * 0.01 {
            return .frequent
        } else {
            return .stable
        }
    }
}

// MARK: - Supporting Types

/// Allocation analysis results
public struct AllocationAnalysis {
    public let averageAllocationSize: Double
    public let peakAllocationSize: Double
    public let totalPageFaults: UInt64
    public let allocationEfficiency: Double
    public let deallocationEfficiency: Double
    public let allocationPattern: AllocationPattern

    public init(
        averageAllocationSize: Double = 0,
        peakAllocationSize: Double = 0,
        totalPageFaults: UInt64 = 0,
        allocationEfficiency: Double = 0,
        deallocationEfficiency: Double = 0,
        allocationPattern: AllocationPattern = .unknown
    ) {
        self.averageAllocationSize = averageAllocationSize
        self.peakAllocationSize = peakAllocationSize
        self.totalPageFaults = totalPageFaults
        self.allocationEfficiency = allocationEfficiency
        self.deallocationEfficiency = deallocationEfficiency
        self.allocationPattern = allocationPattern
    }
}

/// Memory allocation pattern
public enum AllocationPattern {
    case stable
    case frequent
    case bursty
    case unknown
}

/// Performance insight
public struct PerformanceInsight {
    public let type: InsightType
    public let severity: Severity
    public let description: String
    public let recommendation: String

    public enum InsightType {
        case memoryLeak
        case allocation
        case pageFaults
        case fragmentation
        case performance
    }

    public enum Severity {
        case low
        case medium
        case high
        case critical
    }

    public init(
        type: InsightType,
        severity: Severity,
        description: String,
        recommendation: String
    ) {
        self.type = type
        self.severity = severity
        self.description = description
        self.recommendation = recommendation
    }
}

// MARK: - Helper Classes

/// Anomaly detection engine
private class AnomalyDetector {
    private let threshold: Double

    init(threshold: Double) {
        self.threshold = threshold
    }

    func detectAnomalies(_ data: [Double]) -> [Bool] {
        guard data.count >= 3 else { return Array(repeating: false, count: data.count) }

        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / Double(data.count)
        let stdDev = sqrt(variance)

        return data.map { abs($0 - mean) > (threshold * stdDev) }
    }
}

/// Trend analysis engine
private class TrendAnalyzer {
    private let windowSize: Int

    init(windowSize: Int) {
        self.windowSize = windowSize
    }

    func analyzeTrend(_ data: [Double]) -> MemoryAnalysis.MemoryTrend {
        guard data.count >= windowSize else { return .stable }

        let window = Array(data.suffix(windowSize))
        let first = window.first!
        let last = window.last!

        let change = last - first
        let changePercent = abs(change / first)

        if changePercent < 0.02 {
            return .stable
        } else if change > 0 {
            return changePercent > 0.1 ? .increasing : .stable
        } else {
            return changePercent > 0.1 ? .decreasing : .stable
        }
    }
}
