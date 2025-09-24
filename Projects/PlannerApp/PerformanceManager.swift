//
// PerformanceManager.swift
// AI-generated performance monitoring
//

import Foundation
import QuartzCore

/// Monitors application performance metrics
public class PerformanceManager {
    public static let shared = PerformanceManager()

    private var frameTimes: [CFTimeInterval] = []
    private let maxFrameHistory = 60

    private init() {}

    /// Record a frame time for FPS calculation
    public func recordFrame() {
        let currentTime = CACurrentMediaTime()
        self.frameTimes.append(currentTime)

        if self.frameTimes.count > self.maxFrameHistory {
            self.frameTimes.removeFirst()
        }
    }

    /// Get current FPS
    public func getCurrentFPS() -> Double {
        guard self.frameTimes.count >= 2 else { return 0 }

        let recentFrames = self.frameTimes.suffix(10)
        guard let first = recentFrames.first, let last = recentFrames.last else {
            return 0
        }

        let timeDiff = last - first
        let frameCount = Double(recentFrames.count - 1)

        return frameCount / timeDiff
    }

    /// Get memory usage in MB
    public func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / (1024 * 1024)
        }

        return 0
    }

    /// Check if performance is degraded
    public func isPerformanceDegraded() -> Bool {
        let fps = self.getCurrentFPS()
        let memory = self.getMemoryUsage()

        return fps < 30 || memory > 500 // 30 FPS threshold, 500MB memory threshold
    }
}
