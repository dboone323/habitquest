import Foundation

@MainActor
public final class AppLogger {
    public enum LogLevel: CaseIterable, Sendable {
        case debug
        case info
        case warning
        case error
        case critical
    }

    public enum Category: CaseIterable, Sendable {
        case network
        case database
        case analytics
        case ui
    }

    public static let shared = AppLogger(logger: Logger.shared)

    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    public func log(_ message: String, level: LogLevel, category: Category) {
        self.logger.record(message: message, level: level, category: category)
    }

    public func debug(_ message: String) {
        self.log(message, level: .debug, category: .analytics)
    }

    public func logWarning(_ message: String) {
        self.log(message, level: .warning, category: .ui)
    }

    public func logError(_ error: Error) {
        self.log("Error: \(error.localizedDescription)", level: .error, category: .analytics)
    }
}

@MainActor
public final class Logger {
    public static let shared = Logger()

    private init() {}

    func record(message: String, level: AppLogger.LogLevel, category: AppLogger.Category) {
        #if DEBUG
        print("[\(level)] [\(category)] \(message)")
        #endif
    }
}
