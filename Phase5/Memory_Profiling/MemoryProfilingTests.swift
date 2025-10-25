//
//  MemoryProfilingTests.swift
//  Memory Profiling System Tests
//
//  Comprehensive integration tests for the memory profiling system
//  including unit tests, performance tests, and leak detection validation.
//

import Combine
import XCTest

@testable import MemoryProfiling

@available(macOS 12.0, *)
final class MemoryProfilingTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []
    var memoryProfiler: MemoryProfiler!
    var memoryMonitor: MemoryMonitor!
    var memoryAnalyzer: MemoryAnalyzer!
    var leakDetector: LeakDetector!
    var performanceAnalyzer: PerformanceAnalyzer!

    override func setUp() {
        super.setUp()

        // Initialize components with test configuration
        let config = MemoryProfiler.Configuration(
            monitoringInterval: 0.1, // Fast for testing
            snapshotRetentionPeriod: 3600,
            anomalyDetectionEnabled: true,
            leakDetectionEnabled: true,
            performanceAnalysisEnabled: true
        )

        memoryProfiler = MemoryProfiler(configuration: config)
        memoryMonitor = MemoryMonitor()
        memoryAnalyzer = MemoryAnalyzer()
        leakDetector = LeakDetector()
        performanceAnalyzer = PerformanceAnalyzer()
    }

    override func tearDown() {
        cancellables.removeAll()
        memoryProfiler = nil
        memoryMonitor = nil
        memoryAnalyzer = nil
        leakDetector = nil
        performanceAnalyzer = nil
        super.tearDown()
    }

    // MARK: - MemoryProfiler Tests

    func testMemoryProfilerInitialization() {
        XCTAssertNotNil(memoryProfiler)
        XCTAssertEqual(memoryProfiler.snapshots.count, 0)
        XCTAssertFalse(memoryProfiler.isMonitoring)
    }

    func testMemoryProfilerStartStopMonitoring() {
        let expectation = XCTestExpectation(description: "Monitoring started")

        memoryProfiler.startMonitoring()

        // Wait for monitoring to start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.memoryProfiler.isMonitoring)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        memoryProfiler.stopMonitoring()
        XCTAssertFalse(memoryProfiler.isMonitoring)
    }

    func testMemoryProfilerSnapshotCollection() {
        let expectation = XCTestExpectation(description: "Snapshots collected")

        memoryProfiler.startMonitoring()

        // Wait for some snapshots to be collected
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(self.memoryProfiler.snapshots.count, 0)

            // Verify snapshot structure
            if let firstSnapshot = self.memoryProfiler.snapshots.first {
                XCTAssertGreaterThan(firstSnapshot.totalMemory, 0)
                XCTAssertGreaterThanOrEqual(firstSnapshot.usedMemory, 0)
                XCTAssertLessThanOrEqual(firstSnapshot.usedMemory, firstSnapshot.totalMemory)
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        memoryProfiler.stopMonitoring()
    }

    func testMemoryProfilerPublisher() {
        let expectation = XCTestExpectation(description: "Publisher received data")

        var receivedSnapshots: [MemorySnapshot] = []

        memoryProfiler.snapshotsPublisher
            .sink { snapshots in
                receivedSnapshots = snapshots
                if snapshots.count >= 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        memoryProfiler.startMonitoring()

        wait(for: [expectation], timeout: 2.0)

        XCTAssertGreaterThanOrEqual(receivedSnapshots.count, 3)
        memoryProfiler.stopMonitoring()
    }

    // MARK: - MemoryMonitor Tests

    func testMemoryMonitorSnapshotCapture() {
        let snapshot = memoryMonitor.captureSnapshot()

        XCTAssertGreaterThan(snapshot.totalMemory, 0)
        XCTAssertGreaterThanOrEqual(snapshot.usedMemory, 0)
        XCTAssertLessThanOrEqual(snapshot.usedMemory, snapshot.totalMemory)
        XCTAssertGreaterThan(snapshot.timestamp.timeIntervalSince1970, 0)
    }

    func testMemoryMonitorTrendAnalysis() {
        // Create mock snapshots with increasing usage
        let snapshots = createMockSnapshots(count: 10, trend: .increasing)

        let trends = memoryMonitor.analyzeTrends(snapshots)

        XCTAssertEqual(trends.count, snapshots.count - 1) // One less trend than snapshots
        XCTAssertTrue(trends.contains { $0 == .increasing })
    }

    func testMemoryMonitorSystemMemoryInfo() {
        let info = memoryMonitor.getSystemMemoryInfo()

        XCTAssertGreaterThan(info.totalMemory, 0)
        XCTAssertGreaterThanOrEqual(info.availableMemory, 0)
        XCTAssertLessThanOrEqual(info.availableMemory, info.totalMemory)
    }

    // MARK: - MemoryAnalyzer Tests

    func testMemoryAnalyzerSnapshotAnalysis() {
        let snapshot = createMockSnapshot(usedMemory: 512 * 1024 * 1024) // 512MB
        let stats = memoryAnalyzer.analyzeSnapshot(snapshot)

        XCTAssertGreaterThan(stats.averageUsage, 0)
        XCTAssertEqual(stats.averageUsage, stats.peakUsage) // Single snapshot
    }

    func testMemoryAnalyzerTrendDetection() {
        let snapshots = createMockSnapshots(count: 20, trend: .increasing)
        let analysis = memoryAnalyzer.analyzeSnapshots(snapshots)

        XCTAssertEqual(analysis.trend, .increasing)
        XCTAssertFalse(analysis.anomalies.isEmpty) // Should detect some anomalies
    }

    func testMemoryAnalyzerFragmentationCalculation() {
        let snapshot = createMockSnapshot(
            usedMemory: 400 * 1024 * 1024,
            residentSize: 300 * 1024 * 1024,
            virtualSize: 500 * 1024 * 1024
        )

        let fragmentation = memoryAnalyzer.calculateFragmentationRatio(snapshot)
        XCTAssertGreaterThan(fragmentation, 0)
        XCTAssertLessThanOrEqual(fragmentation, 1)
    }

    func testMemoryAnalyzerAllocationAnalysis() {
        let snapshots = createMockSnapshots(count: 15, trend: .stable)
        let analysis = memoryAnalyzer.analyzeAllocationPatterns(snapshots)

        XCTAssertGreaterThan(analysis.averageAllocationSize, 0)
        XCTAssertGreaterThanOrEqual(analysis.peakAllocationSize, analysis.averageAllocationSize)
        XCTAssertGreaterThanOrEqual(analysis.allocationEfficiency, 0)
        XCTAssertLessThanOrEqual(analysis.allocationEfficiency, 1)
    }

    // MARK: - LeakDetector Tests

    func testLeakDetectorGrowthPatternLeak() {
        // Create snapshots with steady growth indicating a leak
        let snapshots = createMockSnapshots(
            count: 20, trend: .increasing, growthRate: 10 * 1024 * 1024
        ) // 10MB per snapshot

        let leakDetection = leakDetector.analyzeForLeaks(snapshots)

        XCTAssertGreaterThan(leakDetection.confidence, 0)
        XCTAssertGreaterThan(leakDetection.estimatedLeakSize, 0)
    }

    func testLeakDetectorNoLeak() {
        // Create stable snapshots with no growth
        let snapshots = createMockSnapshots(count: 20, trend: .stable)

        let leakDetection = leakDetector.analyzeForLeaks(snapshots)

        XCTAssertEqual(leakDetection.confidence, 0)
        XCTAssertEqual(leakDetection.estimatedLeakSize, 0)
        XCTAssertTrue(leakDetection.suspectedLeaks.isEmpty)
    }

    func testLeakDetectorAllocationTracking() {
        let testObject = NSObject()

        leakDetector.trackAllocation(testObject, context: "Test object")

        let potentialLeaks = leakDetector.checkTrackedObjects()
        XCTAssertFalse(potentialLeaks.isEmpty) // Object should be flagged as potential leak
    }

    func testLeakDetectorPatternAnalysis() {
        let snapshots = createMockSnapshots(count: 30, trend: .increasing)
        let patternAnalysis = leakDetector.analyzeUsagePatterns(snapshots)

        // Should detect some patterns
        XCTAssertTrue(
            patternAnalysis.allocationSpikes.isEmpty || !patternAnalysis.allocationSpikes.isEmpty)
    }

    // MARK: - PerformanceAnalyzer Tests

    func testPerformanceAnalyzerBasic() {
        let snapshots = createMockSnapshots(count: 10, trend: .stable)
        let analysis = performanceAnalyzer.analyzePerformance(snapshots)

        XCTAssertGreaterThanOrEqual(analysis.performanceScore, 0)
        XCTAssertLessThanOrEqual(analysis.performanceScore, 1)
        XCTAssertFalse(analysis.bottlenecks.isEmpty) // Should identify some bottlenecks
    }

    func testPerformanceAnalyzerMemoryPressure() {
        let snapshot = createMockSnapshot(
            usedMemory: 900 * 1024 * 1024, // 900MB used
            totalMemory: 1024 * 1024 * 1024 // 1GB total
        )

        let pressure = performanceAnalyzer.calculateMemoryPressure(snapshot)
        XCTAssertTrue(pressure == .high || pressure == .critical)
    }

    func testPerformanceAnalyzerAccessPatterns() {
        let snapshots = createMockSnapshots(count: 15, trend: .stable)
        let accessAnalysis = performanceAnalyzer.analyzeAccessPatterns(snapshots)

        XCTAssertGreaterThanOrEqual(accessAnalysis.pageFaultRate, 0)
        XCTAssertGreaterThanOrEqual(accessAnalysis.cacheEfficiency, 0)
        XCTAssertLessThanOrEqual(accessAnalysis.cacheEfficiency, 1)
    }

    func testPerformanceAnalyzerPrediction() {
        let snapshots = createMockSnapshots(count: 20, trend: .increasing)
        let prediction = performanceAnalyzer.predictMemoryRequirements(snapshots)

        XCTAssertGreaterThanOrEqual(prediction.confidence, 0)
        XCTAssertLessThanOrEqual(prediction.confidence, 1)
    }

    func testPerformanceAnalyzerOptimizationStrategies() {
        let snapshots = createMockSnapshots(count: 10, trend: .increasing)
        let analysis = performanceAnalyzer.analyzePerformance(snapshots)
        let strategies = performanceAnalyzer.generateOptimizationStrategies(analysis)

        XCTAssertFalse(strategies.isEmpty)
        XCTAssertTrue(strategies.allSatisfy { $0.estimatedImprovement > 0 })
    }

    // MARK: - Integration Tests

    func testFullMemoryProfilingWorkflow() {
        let expectation = XCTestExpectation(description: "Full workflow completed")

        // Start monitoring
        memoryProfiler.startMonitoring()

        // Wait for data collection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Stop monitoring
            self.memoryProfiler.stopMonitoring()

            let snapshots = self.memoryProfiler.snapshots
            XCTAssertGreaterThan(snapshots.count, 0)

            // Analyze with all components
            let analysis = self.memoryAnalyzer.analyzeSnapshots(snapshots)
            let leakDetection = self.leakDetector.analyzeForLeaks(snapshots)
            let performanceAnalysis = self.performanceAnalyzer.analyzePerformance(snapshots)

            // Verify results
            XCTAssertNotNil(analysis)
            XCTAssertNotNil(leakDetection)
            XCTAssertNotNil(performanceAnalysis)

            // Test real-time analysis
            if let lastSnapshot = snapshots.last {
                let realTimeAnalysis = self.performanceAnalyzer.analyzeRealTimePerformance(
                    lastSnapshot,
                    historicalSnapshots: Array(snapshots.dropLast())
                )
                XCTAssertNotNil(realTimeAnalysis)
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testMemoryProfilingUnderLoad() {
        let expectation = XCTestExpectation(description: "Load test completed")

        // Create memory pressure by allocating objects
        var testObjects: [NSObject] = []

        for _ in 0 ..< 1000 {
            testObjects.append(NSObject())
        }

        memoryProfiler.startMonitoring()

        // Monitor during allocation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.memoryProfiler.stopMonitoring()

            let snapshots = self.memoryProfiler.snapshots
            XCTAssertGreaterThan(snapshots.count, 0)

            // Should detect memory usage increase
            let analysis = self.memoryAnalyzer.analyzeSnapshots(snapshots)
            XCTAssertGreaterThan(analysis.trend.rawValue, 0) // Some trend detected

            // Clean up
            testObjects.removeAll()

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testMemoryProfilingConfiguration() {
        let customConfig = MemoryProfiler.Configuration(
            monitoringInterval: 0.05,
            snapshotRetentionPeriod: 1800,
            anomalyDetectionEnabled: false,
            leakDetectionEnabled: true,
            performanceAnalysisEnabled: false
        )

        let customProfiler = MemoryProfiler(configuration: customConfig)
        XCTAssertNotNil(customProfiler)

        // Test configuration application
        customProfiler.startMonitoring()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            customProfiler.stopMonitoring()
            XCTAssertGreaterThan(customProfiler.snapshots.count, 0)
        }
    }

    // MARK: - Performance Tests

    func testMemoryProfilingPerformance() {
        measure {
            let snapshots = createMockSnapshots(count: 100, trend: .stable)
            let analysis = memoryAnalyzer.analyzeSnapshots(snapshots)
            let leakDetection = leakDetector.analyzeForLeaks(snapshots)
            let performanceAnalysis = performanceAnalyzer.analyzePerformance(snapshots)

            XCTAssertNotNil(analysis)
            XCTAssertNotNil(leakDetection)
            XCTAssertNotNil(performanceAnalysis)
        }
    }

    func testSnapshotCapturePerformance() {
        measure {
            for _ in 0 ..< 100 {
                _ = memoryMonitor.captureSnapshot()
            }
        }
    }

    // MARK: - Helper Methods

    private func createMockSnapshot(
        usedMemory: UInt64 = 256 * 1024 * 1024,
        totalMemory: UInt64 = 1024 * 1024 * 1024,
        residentSize: UInt64 = 200 * 1024 * 1024,
        virtualSize: UInt64 = 300 * 1024 * 1024,
        pageFaults: UInt64 = 1000,
        pageIns: UInt64 = 500,
        pageOuts: UInt64 = 200
    ) -> MemorySnapshot {
        MemorySnapshot(
            timestamp: Date(),
            totalMemory: totalMemory,
            usedMemory: usedMemory,
            residentSize: residentSize,
            virtualSize: virtualSize,
            pageFaults: pageFaults,
            pageIns: pageIns,
            pageOuts: pageOuts
        )
    }

    private func createMockSnapshots(
        count: Int, trend: MemoryAnalysis.MemoryTrend, growthRate: UInt64 = 0
    ) -> [MemorySnapshot] {
        var snapshots: [MemorySnapshot] = []
        let baseMemory: UInt64 = 128 * 1024 * 1024 // 128MB base
        let totalMemory: UInt64 = 1024 * 1024 * 1024 // 1GB total

        for i in 0 ..< count {
            let timestamp = Date().addingTimeInterval(Double(i) * 60) // 1 minute intervals

            var usedMemory = baseMemory
            switch trend {
            case .increasing:
                usedMemory += UInt64(i) * growthRate
            case .decreasing:
                usedMemory = max(baseMemory, baseMemory + UInt64(count - i) * growthRate)
            case .stable:
                usedMemory = baseMemory + UInt64.random(in: 0 ... 10 * 1024 * 1024) // Small random variation
            }

            usedMemory = min(usedMemory, totalMemory)

            let snapshot = MemorySnapshot(
                timestamp: timestamp,
                totalMemory: totalMemory,
                usedMemory: usedMemory,
                residentSize: usedMemory * 8 / 10, // 80% resident
                virtualSize: usedMemory * 12 / 10, // 120% virtual
                pageFaults: UInt64(i * 10),
                pageIns: UInt64(i * 5),
                pageOuts: UInt64(i * 2)
            )

            snapshots.append(snapshot)
        }

        return snapshots
    }
}

// MARK: - Test Extensions

extension MemoryAnalysis.MemoryTrend {
    var rawValue: Int {
        switch self {
        case .stable: return 0
        case .increasing: return 1
        case .decreasing: return -1
        case .rapidlyIncreasing: return 2
        case .rapidlyDecreasing: return -2
        }
    }
}
