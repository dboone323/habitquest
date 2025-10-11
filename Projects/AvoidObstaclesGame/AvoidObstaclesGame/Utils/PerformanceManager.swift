//
// PerformanceManager.swift
// AvoidObstaclesGame
//
// Manages performance optimization, memory usage, frame rate monitoring,
// and device capability detection.
//

import Foundation
import UIKit

/// Protocol for performance-related events
protocol PerformanceDelegate: AnyObject {
    func performanceWarningTriggered(_ warning: PerformanceWarning)
    func frameRateDropped(below targetFPS: Int)
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
    private static func detectDeviceCapability() -> DeviceCapability {
        let device = UIDevice.current
        let processInfo = ProcessInfo.processInfo

        // Check processor count and device type
        let processorCount = processInfo.processorCount
        let isModernDevice = processorCount >= 6

        #if targetEnvironment(simulator)
        // Simulator - assume high capability
        return .high
        #else
        // Physical device
        if device.userInterfaceIdiom == .pad {
            return .high
        } else if isModernDevice {
            return .high
        } else {
            return .medium
        }
        #endif
    }

    // MARK: - Performance Monitoring

    /// Sets up performance monitoring
    private func setupPerformanceMonitoring() {
        // Monitor frame rate using CADisplayLink
        let displayLink = CADisplayLink(target: self, selector: #selector(self.frameUpdate))
        displayLink.add(to: .main, forMode: .common)
    }

    /// Called on each frame update
    @objc private func frameUpdate(displayLink _: CADisplayLink) {
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
            self.delegate?.frameRateDropped(below: Int(self.lowFPSThreshold))

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
            self.delegate?.performanceWarningTriggered(.highMemoryUsage)

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
        #if os(iOS)
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
        self.delegate?.performanceWarningTriggered(.memoryPressure)

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

    /// Resets performance statistics
    func resetStats() {
        self.performanceStats = PerformanceStats()
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

/// Performance statistics tracking
struct PerformanceStats {
    private(set) var averageFPS: Double = 60.0
    private(set) var minFPS: Double = 60.0
    private(set) var maxFPS: Double = 60.0
    private(set) var currentMemoryUsage: UInt64 = 0
    private(set) var peakMemoryUsage: UInt64 = 0
    private(set) var cleanupCount: Int = 0
    var currentQualityLevel: QualityLevel = .high

    private var fpsSamples: [Double] = []

    mutating func updateFPS(_ fps: Double) {
        self.fpsSamples.append(fps)
        if self.fpsSamples.count > 60 { // Keep last 60 samples
            self.fpsSamples.removeFirst()
        }

        self.averageFPS = self.fpsSamples.reduce(0, +) / Double(self.fpsSamples.count)
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

    func toDictionary() -> [String: Any] {
        [
            "averageFPS": self.averageFPS,
            "minFPS": self.minFPS,
            "maxFPS": self.maxFPS,
            "currentMemoryUsage": self.currentMemoryUsage,
            "peakMemoryUsage": self.peakMemoryUsage,
            "cleanupCount": self.cleanupCount,
            "qualityLevel": self.currentQualityLevel,
        ]
    }
}

// MARK: - Object Pooling

/// Object pool for performance optimization
private var objectPool: [Any] = []
private let maxPoolSize = 50

/// Get an object from the pool or create new one
private func getPooledObject<T>() -> T? {
    if let pooled = objectPool.popLast() as? T {
        return pooled
    }
    return nil
}

/// Return an object to the pool
private func returnToPool(_ object: Any) {
    if objectPool.count < maxPoolSize {
        objectPool.append(object)
    }
}
