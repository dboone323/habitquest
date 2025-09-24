//
// Dependencies.swift
// AI-generated dependency injection container
//

import Foundation

/// Dependency injection container
public struct Dependencies {
    public let performanceManager: PerformanceManager
    public let logger: Logger

    public init(
        performanceManager: PerformanceManager = .shared,
        logger: Logger = .shared
    ) {
        self.performanceManager = performanceManager
        self.logger = logger
    }

    /// Default shared dependencies
    public static let `default` = Dependencies()
}

/// Logger for debugging and analytics
public class Logger {
    public static let shared = Logger()

    private init() {}

    public func log(_ message: String, level: LogLevel = .info) {
        let timestamp = Date().ISO8601Format()
        print("[\(timestamp)] [\(level.rawValue.uppercased())] \(message)")
    }

    public func error(_ message: String) {
        self.log(message, level: .error)
    }

    public func warning(_ message: String) {
        self.log(message, level: .warning)
    }

    public func info(_ message: String) {
        self.log(message, level: .info)
    }
}

public enum LogLevel: String {
    case debug, info, warning, error
}
