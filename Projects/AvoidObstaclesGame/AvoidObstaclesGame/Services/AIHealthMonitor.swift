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

    /// Security Framework Integration
    private lazy var auditLogger = AuditLogger.shared
    private lazy var securityMonitor = SecurityMonitor.shared
    private lazy var privacyManager = PrivacyManager.shared

    private init() {}

    /// Record service health
    public func recordHealth(for service: String, status: ServiceHealth) {
        queue.async(flags: .barrier) {
            self.healthStatus[service] = status
        }

        // Security: Monitor health data recording
        securityMonitor.monitorDataAccess(operation: .update, entityType: "ai_health", dataCount: 1)
    }

    /// Get health status for service
    public func getHealth(for service: String) -> ServiceHealth {
        var result = ServiceHealth(serviceName: service, isRunning: false, modelsAvailable: false, responseTime: nil, errorRate: 1.0, lastChecked: Date(), recommendations: ["Service not found"])
        queue.sync {
            result = healthStatus[service] ?? ServiceHealth(serviceName: service, isRunning: false, modelsAvailable: false, responseTime: nil, errorRate: 1.0, lastChecked: Date(), recommendations: ["No health data available"])
        }
        return result
    }

    /// Get overall health status
    public func getOverallHealth() -> ServiceHealth {
        var result = ServiceHealth(serviceName: "overall", isRunning: false, modelsAvailable: false, responseTime: nil, errorRate: 1.0, lastChecked: Date(), recommendations: ["No services monitored"])
        queue.sync {
            let statuses = healthStatus.values
            if statuses.isEmpty {
                result = ServiceHealth(serviceName: "overall", isRunning: false, modelsAvailable: false, responseTime: nil, errorRate: 1.0, lastChecked: Date(), recommendations: ["No services monitored"])
            } else {
                let runningCount = statuses.filter(\.isRunning).count
                let avgResponseTime = statuses.compactMap(\.responseTime).reduce(0, +) / Double(statuses.count)
                let avgErrorRate = statuses.map(\.errorRate).reduce(0, +) / Double(statuses.count)

                result = ServiceHealth(
                    serviceName: "overall",
                    isRunning: runningCount > 0,
                    modelsAvailable: statuses.contains { $0.modelsAvailable },
                    responseTime: avgResponseTime > 0 ? avgResponseTime : nil,
                    errorRate: avgErrorRate,
                    lastChecked: Date(),
                    recommendations: ["Monitor individual services for details"]
                )
            }
        }
        return result
    }

    /// Reset health status
    public func resetHealth(for service: String) {
        queue.async(flags: .barrier) {
            self.healthStatus.removeValue(forKey: service)
        }

        // Security: Log health data reset
        auditLogger.logDataAccess(operation: .delete, entityType: "ai_health", dataCount: 1)
    }
}
