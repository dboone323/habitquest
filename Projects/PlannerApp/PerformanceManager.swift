//
// PerformanceManager.swift
// AI-generated performance monitoring
//

import Foundation
import QuartzCore

/// Monitors application performance metrics with caching and thread safety
public final class PerformanceManager {
    public static let shared = PerformanceManager()

    private let frameQueue = DispatchQueue(
        label: "com.quantumworkspace.performance.frames",
        qos: .userInteractive,
        attributes: .concurrent
    )
    private let metricsQueue = DispatchQueue(
        label: "com.quantumworkspace.performance.metrics",
        qos: .utility,
        attributes: .concurrent
    )

    private let maxFrameHistory = 120
    private let fpsSampleSize = 10
    private let fpsCacheInterval: CFTimeInterval = 0.1
    private let metricsCacheInterval: CFTimeInterval = 0.5
    private let fpsThreshold: Double = 30
    private let memoryThreshold: Double = 500

    private var frameTimes: [CFTimeInterval]
    private var frameWriteIndex = 0
    private var recordedFrameCount = 0

    private var cachedFPS: Double = 0
    private var lastFPSUpdate: CFTimeInterval = 0

    private var cachedMemoryUsage: Double = 0
    private var memoryUsageTimestamp: CFTimeInterval = 0

    private var cachedPerformanceDegraded: Bool = false
    private var performanceTimestamp: CFTimeInterval = 0

    private var machInfoCache = mach_task_basic_info()

    private init() {
        self.frameTimes = Array(repeating: 0, count: self.maxFrameHistory)
    }

    /// Record a frame time for FPS calculation using a circular buffer
    public func recordFrame() {
        let currentTime = CACurrentMediaTime()
        self.frameQueue.async(flags: .barrier) {
            self.frameTimes[self.frameWriteIndex] = currentTime
            self.frameWriteIndex = (self.frameWriteIndex + 1) % self.maxFrameHistory
            if self.recordedFrameCount < self.maxFrameHistory {
                self.recordedFrameCount += 1
            }
            self.lastFPSUpdate = 0 // force recalculation on next read
        }
    }

    /// Get the current FPS, using cached values when possible
    public func getCurrentFPS() -> Double {
        let now = CACurrentMediaTime()
        return self.frameQueue.sync {
            if now - self.lastFPSUpdate < self.fpsCacheInterval {
                return self.cachedFPS
            }

            let fps = self.calculateCurrentFPSLocked()
            self.cachedFPS = fps
            self.lastFPSUpdate = now
            return fps
        }
    }

    /// Fetch the current FPS asynchronously
    public func getCurrentFPS(completion: @escaping (Double) -> Void) {
        self.frameQueue.async {
            let now = CACurrentMediaTime()
            let fps: Double

            if now - self.lastFPSUpdate < self.fpsCacheInterval {
                fps = self.cachedFPS
            } else {
                fps = self.calculateCurrentFPSLocked()
                self.cachedFPS = fps
                self.lastFPSUpdate = now
            }

            DispatchQueue.main.async {
                completion(fps)
            }
        }
    }

    /// Get memory usage in MB with caching
    public func getMemoryUsage() -> Double {
        let now = CACurrentMediaTime()
        return self.metricsQueue.sync {
            self.fetchMemoryUsageLocked(currentTime: now)
        }
    }

    /// Fetch memory usage asynchronously
    public func getMemoryUsage(completion: @escaping (Double) -> Void) {
        self.metricsQueue.async {
            let usage = self.fetchMemoryUsageLocked(currentTime: CACurrentMediaTime())
            DispatchQueue.main.async {
                completion(usage)
            }
        }
    }

    /// Determine if performance is degraded based on FPS and memory thresholds
    public func isPerformanceDegraded() -> Bool {
        self.metricsQueue.sync {
            let now = CACurrentMediaTime()
            if now - self.performanceTimestamp < self.metricsCacheInterval {
                return self.cachedPerformanceDegraded
            }

            let fps = self.calculateFPSForDegradedCheck()
            let memory = self.fetchMemoryUsageLocked(currentTime: now)
            let isDegraded = fps < self.fpsThreshold || memory > self.memoryThreshold

            self.cachedPerformanceDegraded = isDegraded
            self.performanceTimestamp = now
            return isDegraded
        }
    }

    /// Determine performance degradation asynchronously
    public func isPerformanceDegraded(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let degraded = self.isPerformanceDegraded()
            DispatchQueue.main.async {
                completion(degraded)
            }
        }
    }

    // MARK: - Private Helpers

    private func calculateCurrentFPSLocked() -> Double {
        let availableFrames = min(recordedFrameCount, fpsSampleSize)
        guard availableFrames >= 2 else { return 0 }

        let lastIndex = (frameWriteIndex - 1 + self.maxFrameHistory) % self.maxFrameHistory
        let firstIndex = (lastIndex - (availableFrames - 1) + self.maxFrameHistory) % self.maxFrameHistory

        let startTime = self.frameTimes[firstIndex]
        let endTime = self.frameTimes[lastIndex]

        guard startTime > 0, endTime > startTime else { return 0 }

        let elapsed = endTime - startTime
        return Double(availableFrames - 1) / elapsed
    }

    private func calculateFPSForDegradedCheck() -> Double {
        self.frameQueue.sync {
            let now = CACurrentMediaTime()
            if now - self.lastFPSUpdate < self.fpsCacheInterval {
                return self.cachedFPS
            }

            let fps = self.calculateCurrentFPSLocked()
            self.cachedFPS = fps
            self.lastFPSUpdate = now
            return fps
        }
    }

    private func fetchMemoryUsageLocked(currentTime: CFTimeInterval) -> Double {
        if currentTime - self.memoryUsageTimestamp < self.metricsCacheInterval {
            return self.cachedMemoryUsage
        }

        let usage = self.calculateMemoryUsageLocked()
        self.cachedMemoryUsage = usage
        self.memoryUsageTimestamp = currentTime
        return usage
    }

    private func calculateMemoryUsageLocked() -> Double {
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result: kern_return_t = withUnsafeMutablePointer(to: &self.machInfoCache) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }
        return Double(self.machInfoCache.resident_size) / (1024 * 1024)
    }
}
