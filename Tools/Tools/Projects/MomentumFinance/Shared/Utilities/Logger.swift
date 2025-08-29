// filepath: /Users/danielstevens/Desktop/MomentumFinaceApp/./Shared/Utilities/Logger.swift
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

//
//  Logger.swift
//  MomentumFinance
//
//  Created by Daniel Stevens
//

import Foundation
import OSLog

/// Centralized logging system for MomentumFinance
/// Provides structured logging across different categories and severity levels
<<<<<<< HEAD
enum Logger {
=======
struct Logger {
>>>>>>> 1cf3938 (Create working state for recovery)
    // MARK: - Core Logger Categories

    static let ui = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "UI",
<<<<<<< HEAD
        )
    static let data = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Data",
        )
    static let business = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Business",
        )
    static let network = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Network",
        )
    static let performance = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Performance",
        )
=======
    )
    static let data = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Data",
    )
    static let business = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Business",
    )
    static let network = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Network",
    )
    static let performance = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "Performance",
    )
>>>>>>> 1cf3938 (Create working state for recovery)

    private static let defaultLog = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "MomentumFinance",
        category: "General",
<<<<<<< HEAD
        )
=======
    )
>>>>>>> 1cf3938 (Create working state for recovery)
}

// MARK: - Core Logging Methods

extension Logger {
    /// Log error messages with context
    static func logError(
        _ error: Error,
        context: String = "",
        file: String = #file,
        function: String = #function,
        line: Int = #line,
<<<<<<< HEAD
        ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        let message = "\(context.isEmpty ? "" : "\(context) - ")\(error.localizedDescription) [\(source)]"
=======
    ) {
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        let message =
            "\(context.isEmpty ? "" : "\(context) - ")\(error.localizedDescription) [\(source)]"
>>>>>>> 1cf3938 (Create working state for recovery)
        os_log("%@", log: defaultLog, type: .error, message)
    }

    /// Log debug information
    static func logDebug(
        _ message: String,
        category: OSLog = defaultLog,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
<<<<<<< HEAD
        ) {
        #if DEBUG
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        os_log("[DEBUG] %@ [%@]", log: category, type: .debug, message, source)
=======
    ) {
        #if DEBUG
            let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
            os_log("[DEBUG] %@ [%@]", log: category, type: .debug, message, source)
>>>>>>> 1cf3938 (Create working state for recovery)
        #endif
    }

    /// Log informational messages
    static func logInfo(_ message: String, category: OSLog = defaultLog) {
        os_log("%@", log: category, type: .info, message)
    }

    /// Log warning messages
    static func logWarning(_ message: String, category: OSLog = defaultLog) {
        os_log("%@", log: category, type: .default, message)
    }
}

// MARK: - Business Logic Logging

extension Logger {
    /// Log business-related events and decisions
<<<<<<< HEAD
    static func logBusiness(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
=======
    static func logBusiness(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        os_log("[BUSINESS] %@ [%@]", log: business, type: .info, message, source)
    }

    /// Log UI-related events
<<<<<<< HEAD
    static func logUI(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
=======
    static func logUI(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        os_log("[UI] %@ [%@]", log: ui, type: .info, message, source)
    }

    /// Log data operations
<<<<<<< HEAD
    static func logData(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
=======
    static func logData(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        os_log("[DATA] %@ [%@]", log: data, type: .info, message, source)
    }

    /// Log network operations
<<<<<<< HEAD
    static func logNetwork(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
=======
    static func logNetwork(
        _ message: String, file: String = #file, function: String = #function, line: Int = #line
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        let source = "\(URL(fileURLWithPath: file).lastPathComponent):\(line) \(function)"
        os_log("[NETWORK] %@ [%@]", log: network, type: .info, message, source)
    }
}

// MARK: - Performance Measurement

extension Logger {
    /// Measure and log execution time of a code block
    static func measurePerformance<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

<<<<<<< HEAD
        os_log("[PERFORMANCE] %@ completed in %.4f seconds", log: performance, type: .info, operation, timeElapsed)
=======
        os_log(
            "[PERFORMANCE] %@ completed in %.4f seconds", log: performance, type: .info, operation,
            timeElapsed)
>>>>>>> 1cf3938 (Create working state for recovery)
        return result
    }

    /// Start a performance measurement session
    static func startPerformanceMeasurement(_ operation: String) -> PerformanceMeasurement {
        PerformanceMeasurement(operation: operation, startTime: CFAbsoluteTimeGetCurrent())
    }
}

// MARK: - Context-Aware Logging

extension Logger {
    /// Log with additional context information
<<<<<<< HEAD
    static func logWithContext(_ message: String, context: [String: Any], category: OSLog = defaultLog, type: OSLogType = .info) {
=======
    static func logWithContext(
        _ message: String, context: [String: Any], category: OSLog = defaultLog,
        type: OSLogType = .info
    ) {
>>>>>>> 1cf3938 (Create working state for recovery)
        let contextString = context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        let fullMessage = "\(message) | Context: [\(contextString)]"
        os_log("%@", log: category, type: type, fullMessage)
    }

    /// Log analytics events
    static func logAnalytics(_ event: String, parameters: [String: Any] = [:]) {
        let paramString = parameters.isEmpty ? "" : " | Parameters: \(parameters)"
        os_log("[ANALYTICS] %@%@", log: defaultLog, type: .info, event, paramString)
    }
}

// MARK: - File Logging Support

extension Logger {
    /// Write log to file for debugging purposes
    static func writeToFile(_ message: String, fileName: String = "momentum_finance.log") {
        #if DEBUG
<<<<<<< HEAD
        guard let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask,
            ).first else { return }
        let logURL = documentsPath.appendingPathComponent(fileName)

        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logEntry = "[\(timestamp)] \(message)\n"

        if FileManager.default.fileExists(atPath: logURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(logEntry.data(using: .utf8) ?? Data())
                fileHandle.closeFile()
            }
        } else {
            try? logEntry.write(to: logURL, atomically: true, encoding: .utf8)
        }
=======
            guard
                let documentsPath = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask,
                ).first
            else { return }
            let logURL = documentsPath.appendingPathComponent(fileName)

            let timestamp = DateFormatter.logFormatter.string(from: Date())
            let logEntry = "[\(timestamp)] \(message)\n"

            if FileManager.default.fileExists(atPath: logURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(logEntry.data(using: .utf8) ?? Data())
                    fileHandle.closeFile()
                }
            } else {
                try? logEntry.write(to: logURL, atomically: true, encoding: .utf8)
            }
>>>>>>> 1cf3938 (Create working state for recovery)
        #endif
    }
}

// MARK: - Supporting Types

struct PerformanceMeasurement {
    let operation: String
    let startTime: CFAbsoluteTime

    /// <#Description#>
    /// - Returns: <#description#>
    func end() {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        Logger.logInfo(
            "[PERFORMANCE] \(operation) completed in \(String(format: "%.4f", timeElapsed)) seconds",
            category: Logger.performance,
<<<<<<< HEAD
            )
=======
        )
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}

// MARK: - Extensions

<<<<<<< HEAD
private extension DateFormatter {
    static let logFormatter: DateFormatter = {
=======
extension DateFormatter {
    fileprivate static let logFormatter: DateFormatter = {
>>>>>>> 1cf3938 (Create working state for recovery)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
