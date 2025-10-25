//
//  LeakDetector.swift
//  Memory Profiling System
//
//  This file implements advanced memory leak detection algorithms including
//  reference cycle detection, allocation tracking, and pattern analysis.
//

import Foundation

/// Advanced memory leak detection engine
@available(macOS 12.0, *)
public class LeakDetector {

    // MARK: - Properties

    private var allocationTracker: AllocationTracker
    private var referenceCycleDetector: ReferenceCycleDetector
    private var patternAnalyzer: LeakPatternAnalyzer

    /// Configuration for leak detection
    public struct Configuration {
        public var growthThreshold: Double = 0.1 // MB per minute
        public var cycleDetectionEnabled: Bool = true
        public var allocationTrackingEnabled: Bool = true
        public var patternAnalysisEnabled: Bool = true
        public var minimumLeakSize: UInt64 = 1024 * 1024 // 1MB
        public var confidenceThreshold: Double = 0.7

        public init() {}
    }

    private var config: Configuration

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        self.allocationTracker = AllocationTracker()
        self.referenceCycleDetector = ReferenceCycleDetector()
        self.patternAnalyzer = LeakPatternAnalyzer()
    }

    // MARK: - Public API

    /// Analyze snapshots for memory leaks
    public func analyzeForLeaks(_ snapshots: [MemorySnapshot]) -> LeakDetection {
        guard snapshots.count >= 10 else {
            return LeakDetection()
        }

        var suspectedLeaks: [SuspectedLeak] = []

        // Growth pattern analysis
        if let growthLeak = detectGrowthPatternLeak(snapshots) {
            suspectedLeaks.append(growthLeak)
        }

        // Allocation pattern analysis
        let allocationLeaks = detectAllocationPatternLeaks(snapshots)
        suspectedLeaks.append(contentsOf: allocationLeaks)

        // Reference cycle detection (if enabled)
        if config.cycleDetectionEnabled {
            let cycleLeaks = detectReferenceCycles(snapshots)
            suspectedLeaks.append(contentsOf: cycleLeaks)
        }

        // Calculate overall confidence and estimated leak size
        let totalLeakSize = suspectedLeaks.reduce(0) { $0 + $1.size }
        let averageConfidence =
            suspectedLeaks.isEmpty
                ? 0 : suspectedLeaks.map(\.confidence).reduce(0, +) / Double(suspectedLeaks.count)

        return LeakDetection(
            suspectedLeaks: suspectedLeaks,
            confidence: averageConfidence,
            estimatedLeakSize: totalLeakSize
        )
    }

    /// Track object allocation for leak detection
    public func trackAllocation(_ object: AnyObject, context: String = "") {
        guard config.allocationTrackingEnabled else { return }

        allocationTracker.track(object, context: context)
    }

    /// Check for potential leaks in tracked objects
    public func checkTrackedObjects() -> [SuspectedLeak] {
        allocationTracker.findPotentialLeaks()
    }

    /// Analyze memory usage patterns for leak indicators
    public func analyzeUsagePatterns(_ snapshots: [MemorySnapshot]) -> LeakPatternAnalysis {
        patternAnalyzer.analyzePatterns(snapshots)
    }

    /// Detect reference cycles using allocation patterns
    public func detectReferenceCycles(_ snapshots: [MemorySnapshot]) -> [SuspectedLeak] {
        // This is a simplified implementation
        // In a real system, this would integrate with runtime tools
        // or use specialized memory analysis techniques

        guard config.cycleDetectionEnabled && snapshots.count >= 20 else {
            return []
        }

        let usages = snapshots.map { Double($0.usedMemory) }
        let smoothedUsages = smoothData(usages, windowSize: 5)

        // Look for patterns that might indicate reference cycles
        var cycleLeaks: [SuspectedLeak] = []

        for i in 10 ..< smoothedUsages.count {
            let recentWindow = Array(smoothedUsages[(i - 10) ... i])
            let trend = calculateTrend(recentWindow)

            // If memory is consistently growing with small fluctuations,
            // it might indicate reference cycles
            if trend > config.growthThreshold && isStableGrowth(recentWindow) {
                let leakSize = UInt64((trend * Double(snapshots.count)) * 1024 * 1024)
                if leakSize >= config.minimumLeakSize {
                    let leak = SuspectedLeak(
                        allocationSite: "Potential reference cycle (pattern analysis)",
                        size: leakSize,
                        allocationTime: snapshots[i].timestamp,
                        stackTrace: [],
                        confidence: 0.6,
                        leakType: .referenceCycle
                    )
                    cycleLeaks.append(leak)
                }
            }
        }

        return cycleLeaks
    }

    // MARK: - Private Methods

    private func detectGrowthPatternLeak(_ snapshots: [MemorySnapshot]) -> SuspectedLeak? {
        let usages = snapshots.map { Double($0.usedMemory) / (1024 * 1024) } // Convert to MB

        guard usages.count >= 10 else { return nil }

        // Calculate growth rate over the entire period
        let firstUsage = usages.first!
        let lastUsage = usages.last!
        let totalGrowth = lastUsage - firstUsage
        let growthRate = totalGrowth / Double(usages.count - 1) // MB per snapshot

        // Convert to MB per minute (assuming snapshots are taken regularly)
        let growthRatePerMinute = growthRate * 60 // Rough estimate

        if growthRatePerMinute > config.growthThreshold {
            let estimatedLeakSize = UInt64(totalGrowth * 1024 * 1024) // Convert back to bytes
            let confidence = min(1.0, growthRatePerMinute / (config.growthThreshold * 2))

            if confidence >= config.confidenceThreshold
                && estimatedLeakSize >= config.minimumLeakSize
            {
                return SuspectedLeak(
                    allocationSite: "Growth pattern analysis",
                    size: estimatedLeakSize,
                    allocationTime: snapshots.first!.timestamp,
                    stackTrace: [],
                    confidence: confidence,
                    leakType: .growth
                )
            }
        }

        return nil
    }

    private func detectAllocationPatternLeaks(_ snapshots: [MemorySnapshot]) -> [SuspectedLeak] {
        guard config.patternAnalysisEnabled else { return [] }

        let patternAnalysis = patternAnalyzer.analyzePatterns(snapshots)
        var leaks: [SuspectedLeak] = []

        // Analyze allocation spikes
        for spike in patternAnalysis.allocationSpikes {
            if spike.size >= config.minimumLeakSize
                && spike.confidence >= config.confidenceThreshold
            {
                let leak = SuspectedLeak(
                    allocationSite: "Allocation spike at \(spike.timestamp)",
                    size: spike.size,
                    allocationTime: spike.timestamp,
                    stackTrace: [],
                    confidence: spike.confidence,
                    leakType: .allocation
                )
                leaks.append(leak)
            }
        }

        // Analyze sustained high usage
        if let sustainedHigh = patternAnalysis.sustainedHighUsage {
            if sustainedHigh.duration > 300 { // 5 minutes
                let leakSize = UInt64(sustainedHigh.averageUsage * 1024 * 1024)
                if leakSize >= config.minimumLeakSize {
                    let leak = SuspectedLeak(
                        allocationSite: "Sustained high memory usage",
                        size: leakSize,
                        allocationTime: sustainedHigh.startTime,
                        stackTrace: [],
                        confidence: 0.75,
                        leakType: .sustained
                    )
                    leaks.append(leak)
                }
            }
        }

        return leaks
    }

    private func smoothData(_ data: [Double], windowSize: Int) -> [Double] {
        guard windowSize > 1 && data.count >= windowSize else { return data }

        var smoothed: [Double] = []

        for i in 0 ..< data.count {
            let start = max(0, i - windowSize / 2)
            let end = min(data.count, i + windowSize / 2 + 1)
            let window = Array(data[start ..< end])
            let average = window.reduce(0, +) / Double(window.count)
            smoothed.append(average)
        }

        return smoothed
    }

    private func calculateTrend(_ data: [Double]) -> Double {
        guard data.count >= 2 else { return 0 }

        let n = Double(data.count)
        let sumX = (n * (n - 1)) / 2
        let sumY = data.reduce(0, +)
        let sumXY = data.enumerated().reduce(0) { $0 + Double($1.offset) * $1.element }
        let sumXX = (n * (n - 1) * (2 * n - 1)) / 6

        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        return slope
    }

    private func isStableGrowth(_ data: [Double]) -> Bool {
        guard data.count >= 3 else { return false }

        // Check if the data shows consistent growth with small variations
        var growthCount = 0
        var totalCount = 0

        for i in 1 ..< data.count {
            if data[i] > data[i - 1] {
                growthCount += 1
            }
            totalCount += 1
        }

        let growthRatio = Double(growthCount) / Double(totalCount)

        // Consider it stable growth if > 70% of points show growth
        return growthRatio > 0.7
    }
}

// MARK: - Supporting Types

/// Leak detection results
public struct LeakDetection {
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
public struct SuspectedLeak {
    public let allocationSite: String
    public let size: UInt64
    public let allocationTime: Date
    public let stackTrace: [String]
    public let confidence: Double
    public let leakType: LeakType

    public init(
        allocationSite: String,
        size: UInt64,
        allocationTime: Date,
        stackTrace: [String] = [],
        confidence: Double = 0.5,
        leakType: LeakType = .unknown
    ) {
        self.allocationSite = allocationSite
        self.size = size
        self.allocationTime = allocationTime
        self.stackTrace = stackTrace
        self.confidence = confidence
        self.leakType = leakType
    }
}

/// Type of memory leak
public enum LeakType {
    case growth
    case allocation
    case referenceCycle
    case sustained
    case unknown
}

/// Leak pattern analysis results
public struct LeakPatternAnalysis {
    public let allocationSpikes: [AllocationSpike]
    public let sustainedHighUsage: SustainedHighUsage?
    public let periodicPatterns: [PeriodicPattern]

    public init(
        allocationSpikes: [AllocationSpike] = [],
        sustainedHighUsage: SustainedHighUsage? = nil,
        periodicPatterns: [PeriodicPattern] = []
    ) {
        self.allocationSpikes = allocationSpikes
        self.sustainedHighUsage = sustainedHighUsage
        self.periodicPatterns = periodicPatterns
    }
}

/// Allocation spike detection
public struct AllocationSpike {
    public let timestamp: Date
    public let size: UInt64
    public let confidence: Double

    public init(timestamp: Date, size: UInt64, confidence: Double) {
        self.timestamp = timestamp
        self.size = size
        self.confidence = confidence
    }
}

/// Sustained high memory usage
public struct SustainedHighUsage {
    public let startTime: Date
    public let duration: TimeInterval
    public let averageUsage: Double // MB

    public init(startTime: Date, duration: TimeInterval, averageUsage: Double) {
        self.startTime = startTime
        self.duration = duration
        self.averageUsage = averageUsage
    }
}

/// Periodic memory usage pattern
public struct PeriodicPattern {
    public let period: TimeInterval
    public let amplitude: Double
    public let confidence: Double

    public init(period: TimeInterval, amplitude: Double, confidence: Double) {
        self.period = period
        self.amplitude = amplitude
        self.confidence = confidence
    }
}

// MARK: - Helper Classes

/// Allocation tracking for objects
private class AllocationTracker {
    private var trackedObjects: [ObjectIdentifier: TrackedObject] = [:]
    private let queue = DispatchQueue(
        label: "com.quantum.allocation-tracker", attributes: .concurrent
    )

    func track(_ object: AnyObject, context: String) {
        let id = ObjectIdentifier(object)
        let tracked = TrackedObject(object: object, context: context, allocationTime: Date())

        queue.async(flags: .barrier) {
            self.trackedObjects[id] = tracked
        }
    }

    func findPotentialLeaks() -> [SuspectedLeak] {
        var leaks: [SuspectedLeak] = []
        let now = Date()
        let threshold: TimeInterval = 300 // 5 minutes

        queue.sync {
            for (id, tracked) in self.trackedObjects {
                let age = now.timeIntervalSince(tracked.allocationTime)
                if age > threshold {
                    // This is a simplified check - in reality, we'd need weak references
                    // or other mechanisms to detect if the object is still alive
                    let leak = SuspectedLeak(
                        allocationSite: tracked.context,
                        size: 0, // Unknown size
                        allocationTime: tracked.allocationTime,
                        stackTrace: [],
                        confidence: 0.5,
                        leakType: .unknown
                    )
                    leaks.append(leak)
                }
            }
        }

        return leaks
    }
}

/// Reference cycle detection (simplified)
private class ReferenceCycleDetector {
    // This would integrate with advanced runtime analysis tools
    // For now, it's a placeholder for future implementation
}

/// Leak pattern analyzer
private class LeakPatternAnalyzer {

    func analyzePatterns(_ snapshots: [MemorySnapshot]) -> LeakPatternAnalysis {
        let usages = snapshots.map { Double($0.usedMemory) / (1024 * 1024) } // MB
        let timestamps = snapshots.map(\.timestamp)

        let spikes = detectAllocationSpikes(usages, timestamps: timestamps)
        let sustained = detectSustainedHighUsage(usages, timestamps: timestamps)
        let periodic = detectPeriodicPatterns(usages, timestamps: timestamps)

        return LeakPatternAnalysis(
            allocationSpikes: spikes,
            sustainedHighUsage: sustained,
            periodicPatterns: periodic
        )
    }

    private func detectAllocationSpikes(_ usages: [Double], timestamps: [Date]) -> [AllocationSpike] {
        guard usages.count >= 3 else { return [] }

        var spikes: [AllocationSpike] = []
        let mean = usages.reduce(0, +) / Double(usages.count)
        let stdDev = sqrt(usages.map { pow($0 - mean, 2) }.reduce(0, +) / Double(usages.count))

        for i in 1 ..< (usages.count - 1) {
            let current = usages[i]
            let prev = usages[i - 1]
            let next = usages[i + 1]

            // Local maximum with significant increase
            if current > prev && current > next && (current - prev) > (2 * stdDev) {
                let spike = AllocationSpike(
                    timestamp: timestamps[i],
                    size: UInt64((current - prev) * 1024 * 1024), // Convert to bytes
                    confidence: min(1.0, (current - prev) / (3 * stdDev))
                )
                spikes.append(spike)
            }
        }

        return spikes
    }

    private func detectSustainedHighUsage(_ usages: [Double], timestamps: [Date])
        -> SustainedHighUsage?
    {
        guard usages.count >= 10 else { return nil }

        let mean = usages.reduce(0, +) / Double(usages.count)
        let threshold = mean * 1.5 // 150% of average

        var startIndex: Int?
        var endIndex: Int?

        for i in 0 ..< usages.count {
            if usages[i] > threshold {
                if startIndex == nil {
                    startIndex = i
                }
                endIndex = i
            } else if startIndex != nil {
                // End of sustained period
                if let start = startIndex, let end = endIndex {
                    let duration = timestamps[end].timeIntervalSince(timestamps[start])
                    if duration > 60 { // At least 1 minute
                        let averageUsage =
                            usages[start ... end].reduce(0, +) / Double(end - start + 1)
                        return SustainedHighUsage(
                            startTime: timestamps[start],
                            duration: duration,
                            averageUsage: averageUsage
                        )
                    }
                }
                startIndex = nil
                endIndex = nil
            }
        }

        // Check if sustained period continues to end
        if let start = startIndex, let end = endIndex {
            let duration = timestamps[end].timeIntervalSince(timestamps[start])
            if duration > 60 {
                let averageUsage = usages[start ... end].reduce(0, +) / Double(end - start + 1)
                return SustainedHighUsage(
                    startTime: timestamps[start],
                    duration: duration,
                    averageUsage: averageUsage
                )
            }
        }

        return nil
    }

    private func detectPeriodicPatterns(_ usages: [Double], timestamps: [Date]) -> [PeriodicPattern] {
        // Simplified periodic pattern detection using autocorrelation
        // This is a basic implementation - production systems would use more sophisticated methods
        guard usages.count >= 20 else { return [] }

        let mean = usages.reduce(0, +) / Double(usages.count)
        let normalized = usages.map { $0 - mean }

        // Check for common periods (in indices)
        let testPeriods = [5, 10, 15, 20] // Different window sizes

        var patterns: [PeriodicPattern] = []

        for period in testPeriods {
            if period >= usages.count / 2 { continue }

            var correlation = 0.0
            var count = 0

            for i in 0 ..< (usages.count - period) {
                correlation += normalized[i] * normalized[i + period]
                count += 1
            }

            if count > 0 {
                correlation /= Double(count)
                let amplitude = sqrt(abs(correlation)) // Rough amplitude estimate

                if correlation > 0.3 { // Significant correlation
                    let timePeriod = Double(period) * 60.0 // Assuming 1 minute intervals
                    patterns.append(
                        PeriodicPattern(
                            period: timePeriod,
                            amplitude: amplitude,
                            confidence: correlation
                        ))
                }
            }
        }

        return patterns
    }
}

/// Tracked object information
private struct TrackedObject {
    let object: AnyObject
    let context: String
    let allocationTime: Date
}
