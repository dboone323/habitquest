//
//  MemoryProfilingExamples.swift
//  Memory Profiling System Usage Examples
//
//  Comprehensive examples demonstrating how to use the memory profiling system
//  in various scenarios including monitoring, analysis, leak detection, and optimization.
//

import Combine
import Foundation

@available(macOS 12.0, *)
class MemoryProfilingExamples {

    private var cancellables: Set<AnyCancellable> = []
    private var memoryProfiler: MemoryProfiler!
    private var leakDetector: LeakDetector!
    private var performanceAnalyzer: PerformanceAnalyzer!

    init() {
        setupComponents()
    }

    private func setupComponents() {
        // Configure memory profiler for real-time monitoring
        let config = MemoryProfiler.Configuration(
            monitoringInterval: 1.0, // 1 second intervals
            snapshotRetentionPeriod: 3600, // 1 hour retention
            anomalyDetectionEnabled: true,
            leakDetectionEnabled: true,
            performanceAnalysisEnabled: true
        )

        memoryProfiler = MemoryProfiler(configuration: config)
        leakDetector = LeakDetector()
        performanceAnalyzer = PerformanceAnalyzer()
    }

    // MARK: - Basic Monitoring Example

    /// Example 1: Basic memory monitoring and snapshot collection
    func example1_BasicMonitoring() {
        print("=== Example 1: Basic Memory Monitoring ===")

        // Start monitoring
        memoryProfiler.startMonitoring()
        print("Memory monitoring started...")

        // Monitor for 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.memoryProfiler.stopMonitoring()
            print("Memory monitoring stopped.")

            let snapshots = self.memoryProfiler.snapshots
            print("Collected \(snapshots.count) memory snapshots")

            // Display basic statistics
            if let first = snapshots.first, let last = snapshots.last {
                let duration = last.timestamp.timeIntervalSince(first.timestamp)
                print("Monitoring duration: \(String(format: "%.1f", duration)) seconds")
                print(
                    "Average memory usage: \(self.formatBytes(self.averageMemoryUsage(snapshots)))")
                print("Peak memory usage: \(self.formatBytes(self.peakMemoryUsage(snapshots)))")
            }
        }
    }

    // MARK: - Real-time Analysis Example

    /// Example 2: Real-time memory analysis with publishers
    func example2_RealTimeAnalysis() {
        print("\n=== Example 2: Real-time Memory Analysis ===")

        // Subscribe to memory snapshots
        memoryProfiler.snapshotsPublisher
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
            .sink { snapshots in
                if snapshots.count >= 2 {
                    let analysis = self.memoryProfiler.analyzeSnapshots(snapshots)
                    print("Real-time Analysis:")
                    print("  Trend: \(analysis.trend)")
                    print("  Risk Level: \(analysis.riskLevel)")
                    print("  Anomalies: \(analysis.anomalies.count)")

                    if !analysis.recommendations.isEmpty {
                        print("  Recommendations:")
                        for recommendation in analysis.recommendations {
                            print("    - \(recommendation)")
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // Subscribe to alerts
        memoryProfiler.alertsPublisher
            .sink { alert in
                print("🚨 Memory Alert: \(alert.message)")
                print("   Severity: \(alert.severity)")
                print("   Timestamp: \(alert.timestamp)")
            }
            .store(in: &cancellables)

        memoryProfiler.startMonitoring()
        print("Real-time analysis started. Monitoring for alerts...")

        // Stop after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.memoryProfiler.stopMonitoring()
            print("Real-time analysis completed.")
        }
    }

    // MARK: - Leak Detection Example

    /// Example 3: Memory leak detection and analysis
    func example3_LeakDetection() {
        print("\n=== Example 3: Memory Leak Detection ===")

        // Simulate a memory leak scenario
        var leakingObjects: [NSObject] = []

        memoryProfiler.startMonitoring()

        // Phase 1: Normal operation
        print("Phase 1: Normal memory usage...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {

            // Phase 2: Start leaking memory
            print("Phase 2: Simulating memory leak...")
            for i in 0 ..< 100 {
                leakingObjects.append(NSObject())
                // Track some objects for leak detection
                if i % 10 == 0 {
                    self.leakDetector.trackAllocation(
                        leakingObjects.last!, context: "Example leak object \(i)"
                    )
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {

                // Phase 3: Analyze for leaks
                print("Phase 3: Analyzing for memory leaks...")
                self.memoryProfiler.stopMonitoring()

                let snapshots = self.memoryProfiler.snapshots
                let leakDetection = self.leakDetector.analyzeForLeaks(snapshots)

                print("Leak Detection Results:")
                print("  Confidence: \(String(format: "%.2f", leakDetection.confidence))")
                print("  Estimated leak size: \(self.formatBytes(leakDetection.estimatedLeakSize))")
                print("  Suspected leaks: \(leakDetection.suspectedLeaks.count)")

                for leak in leakDetection.suspectedLeaks {
                    print(
                        "    - \(leak.allocationSite): \(self.formatBytes(leak.size)) (\(String(format: "%.2f", leak.confidence)))"
                    )
                }

                // Check tracked objects
                let potentialLeaks = self.leakDetector.checkTrackedObjects()
                print("  Tracked objects analysis: \(potentialLeaks.count) potential leaks")

                // Cleanup
                leakingObjects.removeAll()
            }
        }
    }

    // MARK: - Performance Analysis Example

    /// Example 4: Comprehensive performance analysis
    func example4_PerformanceAnalysis() {
        print("\n=== Example 4: Performance Analysis ===")

        memoryProfiler.startMonitoring()

        // Simulate varying memory usage patterns
        simulateMemoryWorkload()

        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.memoryProfiler.stopMonitoring()

            let snapshots = self.memoryProfiler.snapshots
            let performanceAnalysis = self.performanceAnalyzer.analyzePerformance(snapshots)

            print("Performance Analysis Results:")
            print(
                "  Overall Score: \(String(format: "%.2f", performanceAnalysis.performanceScore))")

            print("  Metrics:")
            let metrics = performanceAnalysis.metrics
            print("    - Average Usage: \(self.formatBytes(UInt64(metrics.averageMemoryUsage)))")
            print("    - Peak Usage: \(self.formatBytes(UInt64(metrics.peakMemoryUsage)))")
            print("    - Page Fault Rate: \(String(format: "%.1f", metrics.pageFaultRate))/sec")
            print("    - Fragmentation: \(String(format: "%.2f", metrics.fragmentationRatio))")
            print("    - Cache Hit Rate: \(String(format: "%.2f", metrics.cacheHitRate))")

            print("  Bottlenecks (\(performanceAnalysis.bottlenecks.count)):")
            for bottleneck in performanceAnalysis.bottlenecks {
                print("    - \(bottleneck.description) (\(bottleneck.severity))")
                print("      Impact: \(bottleneck.impact)")
            }

            print("  Recommendations (\(performanceAnalysis.recommendations.count)):")
            for recommendation in performanceAnalysis.recommendations {
                print("    - \(recommendation)")
            }

            // Generate optimization strategies
            let strategies = self.performanceAnalyzer.generateOptimizationStrategies(
                performanceAnalysis)
            print("  Optimization Strategies (\(strategies.count)):")
            for strategy in strategies {
                print(
                    "    - \(strategy.name): \(String(format: "%.0f", strategy.estimatedImprovement * 100))% improvement"
                )
                print("      Time: \(self.formatDuration(strategy.implementationTime))")
                print("      Risk: \(strategy.riskLevel)")
            }
        }
    }

    // MARK: - Access Pattern Analysis Example

    /// Example 5: Memory access pattern analysis
    func example5_AccessPatternAnalysis() {
        print("\n=== Example 5: Access Pattern Analysis ===")

        memoryProfiler.startMonitoring()

        // Simulate different access patterns
        simulateAccessPatterns()

        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            self.memoryProfiler.stopMonitoring()

            let snapshots = self.memoryProfiler.snapshots
            let accessAnalysis = self.performanceAnalyzer.analyzeAccessPatterns(snapshots)

            print("Access Pattern Analysis:")
            print("  Pattern: \(accessAnalysis.accessPattern)")
            print("  Page Fault Rate: \(String(format: "%.1f", accessAnalysis.pageFaultRate))/sec")
            print(
                "  Page In/Out Rates: \(String(format: "%.1f", accessAnalysis.pageInRate))/\(String(format: "%.1f", accessAnalysis.pageOutRate))/sec"
            )
            print("  Working Set Size: \(self.formatBytes(accessAnalysis.workingSetSize))")
            print("  Cache Efficiency: \(String(format: "%.2f", accessAnalysis.cacheEfficiency))")

            // Memory prediction
            let prediction = self.performanceAnalyzer.predictMemoryRequirements(
                snapshots, predictionHorizon: 3600
            )
            print("  Memory Prediction (1 hour):")
            print("    Predicted Peak: \(self.formatBytes(UInt64(prediction.predictedPeakUsage)))")
            print("    Confidence: \(String(format: "%.2f", prediction.confidence))")
            print(
                "    Recommended Buffer: \(self.formatBytes(UInt64(prediction.recommendedBuffer)))")
        }
    }

    // MARK: - Custom Configuration Example

    /// Example 6: Custom configuration and advanced features
    func example6_CustomConfiguration() {
        print("\n=== Example 6: Custom Configuration ===")

        // Create custom configuration
        let customConfig = MemoryProfiler.Configuration(
            monitoringInterval: 0.5, // 500ms intervals
            snapshotRetentionPeriod: 7200, // 2 hours
            anomalyDetectionEnabled: true,
            leakDetectionEnabled: true,
            performanceAnalysisEnabled: true,
            alertThresholds: MemoryProfiler.AlertThresholds(
                memoryUsageThreshold: 0.8, // 80%
                leakGrowthThreshold: 50 * 1024 * 1024, // 50MB
                anomalyThreshold: 3.0 // 3 standard deviations
            )
        )

        let customProfiler = MemoryProfiler(configuration: customConfig)

        // Custom alert handling
        customProfiler.alertsPublisher
            .sink { alert in
                print("Custom Alert: \(alert.message)")
                // Custom handling logic here
                self.handleCustomAlert(alert)
            }
            .store(in: &cancellables)

        customProfiler.startMonitoring()
        print("Custom monitoring started with 500ms intervals...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            customProfiler.stopMonitoring()
            print("Custom monitoring completed.")

            let snapshots = customProfiler.snapshots
            print("Collected \(snapshots.count) snapshots with custom configuration")

            // Export data
            self.exportMemoryData(snapshots, filename: "custom_memory_analysis.json")
        }
    }

    // MARK: - Integration with Application Lifecycle

    /// Example 7: Integration with application lifecycle
    func example7_ApplicationLifecycleIntegration() {
        print("\n=== Example 7: Application Lifecycle Integration ===")

        // Simulate application startup
        print("Application starting...")
        memoryProfiler.startMonitoring()

        // Setup lifecycle observers
        setupLifecycleObservers()

        // Simulate application operation
        simulateApplicationWorkload()

        // Simulate application backgrounding
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            print("Application entering background...")
            self.memoryProfiler.pauseMonitoring()

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                print("Application returning to foreground...")
                self.memoryProfiler.resumeMonitoring()

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    print("Application terminating...")
                    self.memoryProfiler.stopMonitoring()

                    // Final analysis
                    let snapshots = self.memoryProfiler.snapshots
                    let finalAnalysis = self.memoryProfiler.analyzeSnapshots(snapshots)

                    print("Final Memory Analysis:")
                    print("  Total snapshots: \(snapshots.count)")
                    print(
                        "  Monitoring duration: \(self.formatDuration(self.totalMonitoringTime(snapshots)))"
                    )
                    print("  Final trend: \(finalAnalysis.trend)")
                    print("  Risk assessment: \(finalAnalysis.riskLevel)")

                    // Cleanup
                    self.exportMemoryData(
                        snapshots, filename: "application_lifecycle_analysis.json"
                    )
                    print("Application lifecycle analysis complete.")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func simulateMemoryWorkload() {
        var objects: [NSObject] = []

        // Phase 1: Light usage
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            for _ in 0 ..< 50 {
                objects.append(NSObject())
            }
        }

        // Phase 2: Heavy usage
        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            for _ in 0 ..< 200 {
                objects.append(NSObject())
            }
        }

        // Phase 3: Cleanup
        DispatchQueue.global().asyncAfter(deadline: .now() + 12) {
            objects.removeAll()
        }
    }

    private func simulateAccessPatterns() {
        var data: [[Int]] = []

        // Sequential access pattern
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            for i in 0 ..< 100 {
                data.append(Array(0 ..< 1000))
                // Access sequentially
                if let last = data.last {
                    _ = last.reduce(0, +)
                }
            }
        }

        // Random access pattern
        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            for _ in 0 ..< 50 {
                let randomIndex = Int.random(in: 0 ..< data.count)
                if randomIndex < data.count {
                    let randomElement = Int.random(in: 0 ..< data[randomIndex].count)
                    _ = data[randomIndex][randomElement]
                }
            }
        }
    }

    private func setupLifecycleObservers() {
        // Simulate memory warnings
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            print("Memory warning received!")
            let currentSnapshot =
                self.memoryProfiler.snapshots.last
                    ?? self.memoryProfiler.memoryMonitor.captureSnapshot()
            let realTimeAnalysis = self.performanceAnalyzer.analyzeRealTimePerformance(
                currentSnapshot,
                historicalSnapshots: self.memoryProfiler.snapshots
            )

            print("Real-time analysis during memory warning:")
            print("  Current pressure: \(realTimeAnalysis.currentPressure)")
            print("  Immediate optimizations: \(realTimeAnalysis.immediateOptimizations.count)")

            for optimization in realTimeAnalysis.immediateOptimizations {
                print("    - \(optimization.description) (\(optimization.urgency))")
            }
        }
    }

    private func simulateApplicationWorkload() {
        // Simulate typical application memory usage patterns
        DispatchQueue.global().async {
            var cache: [String: NSObject] = [:]

            for i in 0 ..< 100 {
                let key = "object_\(i)"
                cache[key] = NSObject()

                // Periodic cleanup
                if i % 20 == 0 {
                    let keysToRemove = cache.keys.prefix(10)
                    for key in keysToRemove {
                        cache.removeValue(forKey: key)
                    }
                }

                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }

    private func handleCustomAlert(_ alert: MemoryAlert) {
        switch alert.severity {
        case .low:
            print("  → Low priority alert handled automatically")
        case .medium:
            print("  → Medium priority alert logged")
        case .high:
            print("  → High priority alert requires attention")
        case .critical:
            print("  → Critical alert triggering emergency measures")
        }
    }

    private func exportMemoryData(_ snapshots: [MemorySnapshot], filename: String) {
        let exportData = MemoryExportData(
            snapshots: snapshots,
            analysis: memoryProfiler.analyzeSnapshots(snapshots),
            metadata: ExportMetadata(
                exportTime: Date(),
                systemInfo: getSystemInfo(),
                configuration: memoryProfiler.configuration
            )
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(exportData)
            let url = URL(fileURLWithPath: "/tmp/\(filename)")

            try data.write(to: url)
            print("Memory data exported to \(url.path)")
        } catch {
            print("Failed to export memory data: \(error)")
        }
    }

    private func getSystemInfo() -> SystemInfo {
        // This would gather actual system information
        SystemInfo(
            osVersion: "macOS 12.0",
            totalMemory: 16 * 1024 * 1024 * 1024, // 16GB
            processorCount: 8
        )
    }

    private func averageMemoryUsage(_ snapshots: [MemorySnapshot]) -> UInt64 {
        let total = snapshots.reduce(0) { $0 + $1.usedMemory }
        return total / UInt64(snapshots.count)
    }

    private func peakMemoryUsage(_ snapshots: [MemorySnapshot]) -> UInt64 {
        snapshots.map(\.usedMemory).max() ?? 0
    }

    private func totalMonitoringTime(_ snapshots: [MemorySnapshot]) -> TimeInterval {
        guard let first = snapshots.first?.timestamp,
              let last = snapshots.last?.timestamp
        else { return 0 }
        return last.timeIntervalSince(first)
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0s"
    }
}

// MARK: - Export Data Structures

struct MemoryExportData: Codable {
    let snapshots: [MemorySnapshot]
    let analysis: MemoryAnalysis
    let metadata: ExportMetadata
}

struct ExportMetadata: Codable {
    let exportTime: Date
    let systemInfo: SystemInfo
    let configuration: MemoryProfiler.Configuration
}

struct SystemInfo: Codable {
    let osVersion: String
    let totalMemory: UInt64
    let processorCount: Int
}

// MARK: - Usage Demonstration

@available(macOS 12.0, *)
extension MemoryProfilingExamples {

    /// Run all examples in sequence
    func runAllExamples() {
        print("🚀 Starting Memory Profiling Examples")
        print("=====================================")

        example1_BasicMonitoring()

        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            self.example2_RealTimeAnalysis()

            DispatchQueue.main.asyncAfter(deadline: .now() + 32) {
                self.example3_LeakDetection()

                DispatchQueue.main.asyncAfter(deadline: .now() + 22) {
                    self.example4_PerformanceAnalysis()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 17) {
                        self.example5_AccessPatternAnalysis()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 14) {
                            self.example6_CustomConfiguration()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.example7_ApplicationLifecycleIntegration()

                                DispatchQueue.main.asyncAfter(deadline: .now() + 42) {
                                    print("\n✅ All examples completed!")
                                    print("Check /tmp/ for exported analysis files.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// Quick start example for new users
    static func quickStart() {
        print("🧠 Memory Profiling System - Quick Start")
        print("========================================")

        let profiler = MemoryProfiler()

        print("1. Starting memory monitoring...")
        profiler.startMonitoring()

        print("2. Monitoring for 5 seconds...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            profiler.stopMonitoring()

            let snapshots = profiler.snapshots
            print("3. Collected \(snapshots.count) memory snapshots")

            let analysis = profiler.analyzeSnapshots(snapshots)
            print("4. Analysis Results:")
            print("   - Memory Trend: \(analysis.trend)")
            print("   - Risk Level: \(analysis.riskLevel)")
            print("   - Anomalies Detected: \(analysis.anomalies.count)")

            if !analysis.recommendations.isEmpty {
                print("   - Recommendations:")
                for rec in analysis.recommendations {
                    print("     • \(rec)")
                }
            }

            print("\n✅ Quick start completed! Ready for advanced usage.")
        }
    }
}
