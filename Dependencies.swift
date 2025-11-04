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
public final class Logger {
    public static let shared = Logger()

    private static let defaultOutputHandler: @Sendable (String) -> Void = { message in
        print(message)
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let queue = DispatchQueue(label: "com.quantumworkspace.logger", qos: .utility)
    private var outputHandler: @Sendable (String) -> Void = Logger.defaultOutputHandler

    private init() {}

    public func log(_ message: String, level: LogLevel = .info) {
        queue.async {
            self.outputHandler(self.formattedMessage(message, level: level))
        }
    }

    public func logSync(_ message: String, level: LogLevel = .info) {
        queue.sync {
            self.outputHandler(self.formattedMessage(message, level: level))
        }
    }

    @inlinable
    public func error(_ message: String) {
        log(message, level: .error)
    }

    @inlinable
    public func warning(_ message: String) {
        log(message, level: .warning)
    }

    @inlinable
    public func info(_ message: String) {
        log(message, level: .info)
    }

    public func setOutputHandler(_ handler: @escaping @Sendable (String) -> Void) {
        queue.sync {
            self.outputHandler = handler
        }
    }

    public func resetOutputHandler() {
        setOutputHandler(Logger.defaultOutputHandler)
    }

    private func formattedMessage(_ message: String, level: LogLevel) -> String {
        let timestamp = Self.isoFormatter.string(from: Date())
        return "[\(timestamp)] [\(level.uppercasedValue)] \(message)"
    }
}

public enum LogLevel: String {
    case debug, info, warning, error

    public var uppercasedValue: String {
        switch self {
        case .debug: "DEBUG"
        case .info: "INFO"
        case .warning: "WARNING"
        case .error: "ERROR"
        }
    }
}
