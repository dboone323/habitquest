//
//  PerformanceManager.swift
//  CodingReviewer
//
//  Created by Quality Infrastructure Implementation
//  Date: October 12, 2024
//

import Foundation

/// Manages performance tracking and optimization for the application
/// Not marked as @MainActor to avoid actor isolation issues
class PerformanceManager {
    private var metrics: [String: PerformanceMetric] = [:]
    private let metricsQueue = DispatchQueue(label: "com.quantum.codingreviewer.performance", attributes: .concurrent)

    init() {
        // Initialize with empty metrics
    }

    /// Record a performance metric
    /// - Parameters:
    ///   - operation: Name of the operation
    ///   - duration: Duration in seconds
    ///   - success: Whether the operation succeeded
    func recordMetric(operation: String, duration: TimeInterval, success: Bool) {
        metricsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            if var metric = self.metrics[operation] {
                metric.recordExecution(duration: duration, success: success)
                self.metrics[operation] = metric
            } else {
                var metric = PerformanceMetric(operation: operation)
                metric.recordExecution(duration: duration, success: success)
                self.metrics[operation] = metric
            }
        }
    }

    /// Get metrics for a specific operation
    /// - Parameter operation: Name of the operation
    /// - Returns: Performance metric if available
    func getMetric(for operation: String) -> PerformanceMetric? {
        metricsQueue.sync {
            return metrics[operation]
        }
    }

    /// Get all tracked metrics
    /// - Returns: Dictionary of all metrics
    func getAllMetrics() -> [String: PerformanceMetric] {
        metricsQueue.sync {
            return metrics
        }
    }

    /// Clear all metrics
    func clearMetrics() {
        metricsQueue.async(flags: .barrier) { [weak self] in
            self?.metrics.removeAll()
        }
    }

    /// Get performance summary
    /// - Returns: Summary of performance metrics
    func getPerformanceSummary() -> PerformanceSummary {
        metricsQueue.sync {
            let totalOperations = metrics.values.reduce(0) { $0 + $1.executionCount }
            let totalDuration = metrics.values.reduce(0.0) { $0 + $1.totalDuration }
            let successfulOperations = metrics.values.reduce(0) { $0 + $1.successCount }

            let averageDuration = totalOperations > 0 ? totalDuration / Double(totalOperations) : 0.0
            let successRate = totalOperations > 0 ? Double(successfulOperations) / Double(totalOperations) : 0.0

            return PerformanceSummary(
                totalOperations: totalOperations,
                averageDuration: averageDuration,
                successRate: successRate,
                metrics: Array(metrics.values)
            )
        }
    }
}

// MARK: - Supporting Types

struct PerformanceMetric {
    let operation: String
    private(set) var executionCount: Int = 0
    private(set) var successCount: Int = 0
    private(set) var totalDuration: TimeInterval = 0.0
    private(set) var minDuration: TimeInterval = .infinity
    private(set) var maxDuration: TimeInterval = 0.0

    var averageDuration: TimeInterval {
        executionCount > 0 ? totalDuration / Double(executionCount) : 0.0
    }

    var successRate: Double {
        executionCount > 0 ? Double(successCount) / Double(executionCount) : 0.0
    }

    init(operation: String) {
        self.operation = operation
    }

    mutating func recordExecution(duration: TimeInterval, success: Bool) {
        executionCount += 1
        if success {
            successCount += 1
        }
        totalDuration += duration
        minDuration = min(minDuration, duration)
        maxDuration = max(maxDuration, duration)
    }
}

struct PerformanceSummary {
    let totalOperations: Int
    let averageDuration: TimeInterval
    let successRate: Double
    let metrics: [PerformanceMetric]

    var description: String {
        """
        Performance Summary:
        - Total Operations: \(totalOperations)
        - Average Duration: \(String(format: "%.3f", averageDuration))s
        - Success Rate: \(String(format: "%.1f", successRate * 100))%
        - Tracked Operations: \(metrics.count)
        """
    }
}
