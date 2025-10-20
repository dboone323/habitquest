//
// PerformanceManager.swift
// AvoidObstaclesGame
//
// Manages performance optimization, memory usage, frame rate monitoring,
// and device capability detection.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif
import QuartzCore

/// Protocol for performance-related events
protocol PerformanceDelegate: AnyObject {
    func performanceWarningTriggered(_ warning: PerformanceWarning) async
    func frameRateDropped(below targetFPS: Int) async
}

/// Performance warning types
enum PerformanceWarning {
    case highMemoryUsage
    case lowFrameRate
    case highCPUUsage
    case memoryPressure
}

/// Device capability levels
enum DeviceCapability {
    case high
    case medium
    case low

    var maxObstacles: Int {
        switch self {
        case .high: 15
        case .medium: 10
        case .low: 6
        }
    }

    var particleLimit: Int {
        switch self {
        case .high: 100
        case .medium: 50
        case .low: 25
        }
    }

    var textureQuality: TextureQuality {
        switch self {
        case .high: .high
        case .medium: .medium
        case .low: .low
        }
    }
}

/// Texture quality levels
enum TextureQuality {
    case high
    case medium
    case low
}

/// Manages performance optimization and monitoring
@MainActor
public class PerformanceManager {
    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = PerformanceManager()

    /// Delegate for performance events
    weak var delegate: PerformanceDelegate?

    /// Current device capability
    let deviceCapability: DeviceCapability

    /// Performance monitoring
    private var frameCount = 0
    private var lastFrameTime = CACurrentMediaTime()
    private var currentFPS = 60.0
    private var averageFPS = 60.0

    /// Memory monitoring
    private var lastMemoryCheck = Date()
    private var memoryWarningCount = 0

    /// Performance thresholds
    private let targetFPS = 60.0
    private let lowFPSThreshold = 45.0
    private let highMemoryThreshold = 100 * 1024 * 1024 // 100MB
    private let memoryCheckInterval: TimeInterval = 5.0 // seconds

    /// Adaptive quality settings
    private var currentQualityLevel: QualityLevel = .high
    private var adaptiveQualityEnabled = true

    /// Performance statistics
    private var performanceStats = PerformanceStats()

    // MARK: - Initialization

    private init() {
        self.deviceCapability = PerformanceManager.detectDeviceCapability()
        self.setupPerformanceMonitoring()
        self.setupMemoryPressureHandling()
    }

    // MARK: - Device Capability Detection

    /// Detects the current device's performance capability
    @MainActor
    private static func detectDeviceCapability() -> DeviceCapability {
        let processInfo = ProcessInfo.processInfo

        // Check processor count and device type
        let processorCount = processInfo.processorCount
        let isModernDevice = processorCount >= 6

        #if targetEnvironment(simulator)
            // Simulator - assume high capability
            return .high
        #else
            // Physical device
            #if os(iOS) || os(tvOS)
                let device = UIDevice.current
                if device.userInterfaceIdiom == .pad {
                    return .high
                } else if isModernDevice {
                    return .high
                } else {
                    return .medium
                }
            #else
                // macOS - assume high capability
                return .high
            #endif
        #endif
    }

    // MARK: - Performance Monitoring

    /// Sets up performance monitoring
    private func setupPerformanceMonitoring() {
        #if os(iOS) || os(tvOS)
            // Monitor frame rate using CADisplayLink
            let displayLink = CADisplayLink(target: self, selector: #selector(self.frameUpdate))
            displayLink.add(to: .main, forMode: .common)
        #else
            // For macOS, use a timer-based approach
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                self?.frameUpdate()
            }
        #endif
    }

    /// Called on each frame update
    @objc private func frameUpdate(displayLink: CADisplayLink? = nil) {
        self.frameCount += 1
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - self.lastFrameTime

        if deltaTime >= 1.0 { // Update FPS every second
            self.currentFPS = Double(self.frameCount) / deltaTime
            self.averageFPS = (self.averageFPS + self.currentFPS) / 2.0

            // Check for performance issues
            self.checkFrameRate()

            self.frameCount = 0
            self.lastFrameTime = currentTime

            // Periodic memory check
            if Date().timeIntervalSince(self.lastMemoryCheck) >= self.memoryCheckInterval {
                self.checkMemoryUsage()
                self.lastMemoryCheck = Date()
            }
        }
    }

    /// Checks frame rate and triggers warnings if needed
    private func checkFrameRate() {
        if self.currentFPS < self.lowFPSThreshold {
            Task { @MainActor in
                await self.delegate?.frameRateDropped(below: Int(self.lowFPSThreshold))
            }

            if self.adaptiveQualityEnabled {
                self.reduceQuality()
            }
        }

        // Update performance stats
        self.performanceStats.updateFPS(self.currentFPS)
    }

    /// Checks memory usage and triggers warnings if needed
    private func checkMemoryUsage() {
        let memoryUsage = self.getMemoryUsage()

        if memoryUsage > self.highMemoryThreshold {
            self.memoryWarningCount += 1
            Task { @MainActor in
                await self.delegate?.performanceWarningTriggered(.highMemoryUsage)
            }

            if self.adaptiveQualityEnabled, self.memoryWarningCount >= 2 {
                self.reduceQuality()
            }
        } else {
            self.memoryWarningCount = max(0, self.memoryWarningCount - 1)
        }

        self.performanceStats.updateMemoryUsage(memoryUsage)
    }

    /// Gets current memory usage
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }

    // MARK: - Memory Pressure Handling

    /// Sets up memory pressure handling
    private func setupMemoryPressureHandling() {
        #if os(iOS) || os(tvOS)
            if #available(iOS 13.0, *) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleMemoryPressure),
                    name: UIApplication.didReceiveMemoryWarningNotification,
                    object: nil
                )
            }
        #endif
    }

    /// Handles memory pressure warnings
    @objc private func handleMemoryPressure() {
        Task { @MainActor in
            await self.delegate?.performanceWarningTriggered(.memoryPressure)
        }

        // Aggressive cleanup
        self.forceCleanup()
    }

    // MARK: - Adaptive Quality

    /// Reduces quality settings to improve performance
    private func reduceQuality() {
        switch self.currentQualityLevel {
        case .high:
            self.currentQualityLevel = .medium
        case .medium:
            self.currentQualityLevel = .low
        case .low:
            // Already at lowest quality
            break
        }

        self.applyQualitySettings()
    }

    /// Increases quality settings when performance allows
    func increaseQuality() {
        switch self.currentQualityLevel {
        case .low:
            self.currentQualityLevel = .medium
        case .medium:
            self.currentQualityLevel = .high
        case .high:
            // Already at highest quality
            break
        }

        self.applyQualitySettings()
    }

    /// Applies current quality settings
    private func applyQualitySettings() {
        // This would be implemented to adjust various game systems
        // For now, just update the stats
        self.performanceStats.currentQualityLevel = self.currentQualityLevel
    }

    /// Enables or disables adaptive quality
    func setAdaptiveQuality(enabled: Bool) {
        self.adaptiveQualityEnabled = enabled
    }

    // MARK: - Object Pooling Management

    /// Gets the recommended pool sizes based on device capability
    func getRecommendedPoolSizes() -> PoolSizes {
        PoolSizes(
            obstaclePoolSize: self.deviceCapability.maxObstacles * 2,
            particlePoolSize: self.deviceCapability.particleLimit,
            effectPoolSize: self.deviceCapability == .high ? 10 : 5
        )
    }

    // MARK: - Cleanup

    /// Forces cleanup of resources
    func forceCleanup() {
        // Clear any cached resources
        // This would trigger cleanup in other managers
        self.performanceStats.recordCleanup()
    }

    /// Gets current performance statistics
    func getPerformanceStats() -> PerformanceStats {
        self.performanceStats
    }

    /// Gets detailed performance report
    func getDetailedPerformanceReport() -> PerformanceReport {
        PerformanceReport(
            currentStats: self.performanceStats,
            deviceCapability: self.deviceCapability,
            recommendations: generatePerformanceRecommendations(),
            bottlenecks: identifyBottlenecks(),
            optimizationOpportunities: suggestOptimizations()
        )
    }

    /// Generates performance recommendations based on current stats
    private func generatePerformanceRecommendations() -> [String] {
        var recommendations: [String] = []

        if self.performanceStats.averageFPS < 50.0 {
            recommendations.append("Consider reducing particle effects or texture quality")
        }

        if self.performanceStats.currentMemoryUsage > 150 * 1024 * 1024 { // 150MB
            recommendations.append("Memory usage is high - consider implementing object pooling")
        }

        if self.performanceStats.cleanupCount > 10 {
            recommendations.append("Frequent cleanup suggests memory management issues")
        }

        if self.currentQualityLevel != .low && self.performanceStats.averageFPS < 45.0 {
            recommendations.append("Automatically reduce quality to improve performance")
        }

        return recommendations
    }

    /// Identifies performance bottlenecks
    private func identifyBottlenecks() -> [PerformanceBottleneck] {
        var bottlenecks: [PerformanceBottleneck] = []

        if self.performanceStats.averageFPS < self.targetFPS * 0.8 {
            bottlenecks.append(.frameRate)
        }

        if self.performanceStats.currentMemoryUsage > self.highMemoryThreshold {
            bottlenecks.append(.memory)
        }

        if self.performanceStats.minFPS < 30.0 {
            bottlenecks.append(.cpu)
        }

        return bottlenecks
    }

    /// Suggests optimization opportunities
    private func suggestOptimizations() -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []

        if self.deviceCapability == .low {
            suggestions.append(.reduceEffects)
            suggestions.append(.lowerTextures)
        }

        if self.performanceStats.averageFPS < 50.0 {
            suggestions.append(.optimizeRendering)
        }

        if self.performanceStats.currentMemoryUsage > 100 * 1024 * 1024 {
            suggestions.append(.implementPooling)
        }

        return suggestions
    }

    /// Resets performance statistics
    func resetStats() {
        self.performanceStats = PerformanceStats()
    }

    /// Gets performance trend analysis
    func getPerformanceTrend() -> PerformanceTrend {
        // Analyze performance trends over time
        let currentFPS = self.performanceStats.averageFPS
        let memoryUsage = self.performanceStats.currentMemoryUsage

        return PerformanceTrend(
            fpsTrend: currentFPS >= self.targetFPS ? .stable : .degrading,
            memoryTrend: memoryUsage <= self.highMemoryThreshold ? .stable : .degrading,
            overallHealth: calculateOverallHealth()
        )
    }

    /// Calculates overall performance health score
    private func calculateOverallHealth() -> Double {
        let fpsScore = min(self.performanceStats.averageFPS / self.targetFPS, 1.0)
        let memoryScore = self.performanceStats.currentMemoryUsage <= self.highMemoryThreshold ? 1.0 :
            max(0.0, 1.0 - Double(Int(self.performanceStats.currentMemoryUsage) - self.highMemoryThreshold) / Double(100 * 1024 * 1024))
        let stabilityScore = self.performanceStats.minFPS / self.targetFPS

        return (fpsScore + memoryScore + stabilityScore) / 3.0
    }
}

/// Quality level settings
enum QualityLevel {
    case high
    case medium
    case low
}

/// Pool size recommendations
struct PoolSizes {
    let obstaclePoolSize: Int
    let particlePoolSize: Int
    let effectPoolSize: Int
}

/// Performance bottleneck types
enum PerformanceBottleneck {
    case frameRate
    case memory
    case cpu
    case gpu
}

/// Optimization suggestion types
enum OptimizationSuggestion {
    case reduceEffects
    case lowerTextures
    case optimizeRendering
    case implementPooling
    case reduceParticles
}

/// Performance trend analysis
struct PerformanceTrend {
    let fpsTrend: TrendDirection
    let memoryTrend: TrendDirection
    let overallHealth: Double
}

/// Trend direction
enum TrendDirection {
    case improving
    case stable
    case degrading
    case critical
}

/// Comprehensive performance report
struct PerformanceReport {
    let currentStats: PerformanceStats
    let deviceCapability: DeviceCapability
    let recommendations: [String]
    let bottlenecks: [PerformanceBottleneck]
    let optimizationOpportunities: [OptimizationSuggestion]
}

/// Performance statistics tracking
struct PerformanceStats {
    var averageFPS: Double = 60.0
    var minFPS: Double = 60.0
    var maxFPS: Double = 60.0
    var currentMemoryUsage: UInt64 = 0
    var peakMemoryUsage: UInt64 = 0
    var cleanupCount: Int = 0
    var currentQualityLevel: QualityLevel = .high

    mutating func updateFPS(_ fps: Double) {
        self.averageFPS = fps
        self.minFPS = min(self.minFPS, fps)
        self.maxFPS = max(self.maxFPS, fps)
    }

    mutating func updateMemoryUsage(_ usage: UInt64) {
        self.currentMemoryUsage = usage
        self.peakMemoryUsage = max(self.peakMemoryUsage, usage)
    }

    mutating func recordCleanup() {
        self.cleanupCount += 1
    }
}
