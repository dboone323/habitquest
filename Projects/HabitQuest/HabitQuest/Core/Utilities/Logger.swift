import Foundation
import os

/// Centralized logging utility for the HabitQuest app
/// Provides structured logging with different levels and categories
struct Logger {

    /// Log categories for different parts of the application
    enum Category: String {
        case general = "HabitQuest.General"
        case dataModel = "HabitQuest.DataModel"
        case gameLogic = "HabitQuest.GameLogic"
        case uiCategory = "HabitQuest.UI"
        case networking = "HabitQuest.Networking"
    }

    /// Log levels for different severity
    enum Level {
        case debug, info, warning, error, critical

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }

        var prefix: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }
    }

    private let osLog: OSLog
    private let category: Category

    /// Initialize logger for specific category
    init(category: Category = .general) {
        self.category = category
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "HabitQuest", category: category.rawValue)
    }

    /// Log a message at the specified level
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func log(_ level: Level, _ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(level.prefix) [\(fileName):\(line)] \(function) - \(message)"

        #if DEBUG
        print(logMessage)
        #endif

        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
    }

    /// Convenience methods for different log levels
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, message, file: file, function: function, line: line)
    }
}
