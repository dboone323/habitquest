//
//  AIHealthMonitor.swift
//  AvoidObstaclesGame
//
//  Created by AI Enhancement System
//  Health monitoring for AI services

import Foundation

/// Health monitor for AI services
public class AIHealthMonitor: @unchecked Sendable {
    public static let shared = AIHealthMonitor()

    private var healthStatus: [String: ServiceHealth] = [:]
    private let queue = DispatchQueue(label: "com.quantum.aihealthmonitor", attributes: .concurrent)

    private init() {}

    /// Record service health
    public func recordHealth(for service: String, status: ServiceHealth) {
        queue.async(flags: .barrier) {
            self.healthStatus[service] = status
        }
    }

    /// Get health status for service
    public func getHealth(for service: String) -> ServiceHealth {
        queue.sync {
            healthStatus[service] ?? .unknown
        }
    }

    /// Get overall health status
    public func getOverallHealth() -> ServiceHealth {
        queue.sync {
            let statuses = healthStatus.values
            if statuses.contains(.unhealthy) {
                return .unhealthy
            } else if statuses.contains(.degraded) {
                return .degraded
            } else if statuses.contains(.healthy) {
                return .healthy
            } else {
                return .unknown
            }
        }
    }

    /// Reset health status
    public func resetHealth(for service: String) {
        queue.async(flags: .barrier) {
            self.healthStatus.removeValue(forKey: service)
        }
    }
}
