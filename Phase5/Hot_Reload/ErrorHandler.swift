//
//  ErrorHandler.swift
//  Hot Reload System
//
//  Comprehensive error handling for hot reload operations with recovery strategies,
//  error classification, and diagnostic information.
//

import Foundation

/// Handles errors and recovery strategies for hot reload operations
@available(macOS 12.0, *)
public class ErrorHandler {

    // MARK: - Properties

    private var errorHistory: [ErrorRecord] = []
    private var recoveryStrategies: [ErrorType: [RecoveryStrategy]] = [:]
    private var errorPatterns: [ErrorPattern] = []

    private let errorQueue = DispatchQueue(label: "com.quantum.error-handler", qos: .userInitiated)

    /// Configuration for error handling
    public struct Configuration {
        public var maxErrorHistory: Int = 100
        public var enableAutoRecovery: Bool = true
        public var recoveryTimeout: TimeInterval = 10.0
        public var enablePatternDetection: Bool = true
        public var logErrorsToConsole: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public private(set) var totalErrors: Int = 0
    public private(set) var recoveredErrors: Int = 0

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        setupDefaultRecoveryStrategies()
    }

    // MARK: - Public API

    /// Handle an error with automatic recovery attempts
    public func handleError(
        _ error: Error,
        context: ErrorContext,
        reloadSession: ReloadSession? = nil
    ) async -> ErrorHandlingResult {

        let errorRecord = ErrorRecord(
            id: UUID(),
            error: error,
            context: context,
            session: reloadSession,
            timestamp: Date()
        )

        // Store error
        await storeError(errorRecord)

        // Classify error
        let errorType = classifyError(error)

        // Log error if enabled
        if config.logErrorsToConsole {
            logError(errorRecord, type: errorType)
        }

        // Attempt recovery if enabled
        if config.enableAutoRecovery {
            let recoveryResult = await attemptRecovery(
                for: errorType, error: error, context: context
            )

            switch recoveryResult {
            case .recovered:
                recoveredErrors += 1
                return .recovered(recoveryResult)
            case .failed, .notApplicable:
                break
            }
        }

        // Detect patterns if enabled
        if config.enablePatternDetection {
            await detectErrorPatterns(errorRecord)
        }

        return .unhandled(errorRecord)
    }

    /// Manually attempt recovery for a specific error type
    public func attemptRecovery(
        for errorType: ErrorType,
        error: Error,
        context: ErrorContext
    ) async -> RecoveryResult {

        guard let strategies = recoveryStrategies[errorType] else {
            return .notApplicable
        }

        for strategy in strategies {
            do {
                try await strategy.execute(error: error, context: context)
                return .recovered(strategy)
            } catch {
                // Strategy failed, try next one
                continue
            }
        }

        return .failed
    }

    /// Get error history with optional filtering
    public func getErrorHistory(filter: ErrorFilter? = nil, limit: Int? = nil) -> [ErrorRecord] {
        errorQueue.sync {
            var filtered = errorHistory

            if let filter {
                filtered = filtered.filter { record in
                    if let errorType = filter.errorType, classifyError(record.error) != errorType {
                        return false
                    }
                    if let sessionId = filter.sessionId, record.session?.id != sessionId {
                        return false
                    }
                    if let timeRange = filter.timeRange {
                        if record.timestamp < timeRange.start || record.timestamp > timeRange.end {
                            return false
                        }
                    }
                    return true
                }
            }

            let sorted = filtered.sorted { $0.timestamp > $1.timestamp }
            if let limit {
                return Array(sorted.prefix(limit))
            }
            return sorted
        }
    }

    /// Get error statistics
    public func getErrorStatistics() -> ErrorStatistics {
        errorQueue.sync {
            let total = errorHistory.count
            let recovered = errorHistory.filter { $0.recoveryStatus == .recovered }.count
            let unhandled = errorHistory.filter { $0.recoveryStatus == .unhandled }.count

            let recoveryRate = total > 0 ? Double(recovered) / Double(total) : 0

            let errorTypeCounts = Dictionary(grouping: errorHistory) { classifyError($0.error) }
                .mapValues { $0.count }

            let recentErrors =
                errorHistory
                    .filter { Date().timeIntervalSince($0.timestamp) < 3600 } // Last hour
                    .count

            return ErrorStatistics(
                totalErrors: total,
                recoveredErrors: recovered,
                unhandledErrors: unhandled,
                recoveryRate: recoveryRate,
                errorTypeDistribution: errorTypeCounts,
                recentErrors: recentErrors
            )
        }
    }

    /// Clear error history
    public func clearHistory() {
        errorQueue.sync {
            errorHistory.removeAll()
        }
    }

    /// Add custom recovery strategy
    public func addRecoveryStrategy(_ strategy: RecoveryStrategy, for errorType: ErrorType) {
        errorQueue.sync {
            if recoveryStrategies[errorType] == nil {
                recoveryStrategies[errorType] = []
            }
            recoveryStrategies[errorType]?.append(strategy)
        }
    }

    /// Get detected error patterns
    public func getErrorPatterns() -> [ErrorPattern] {
        errorQueue.sync {
            errorPatterns
        }
    }

    /// Generate diagnostic report
    public func generateDiagnosticReport() -> DiagnosticReport {
        let statistics = getErrorStatistics()
        let recentErrors = getErrorHistory(limit: 10)
        let patterns = getErrorPatterns()

        return DiagnosticReport(
            timestamp: Date(),
            statistics: statistics,
            recentErrors: recentErrors,
            patterns: patterns,
            recommendations: generateRecommendations()
        )
    }

    // MARK: - Private Methods

    private func setupDefaultRecoveryStrategies() {
        // Compilation errors
        recoveryStrategies[.compilation] = [
            RetryWithCleanBuildStrategy(),
            FixImportStrategy(),
            RevertToLastWorkingStrategy(),
        ]

        // Runtime errors
        recoveryStrategies[.runtime] = [
            RestartApplicationStrategy(),
            RollbackPatchStrategy(),
            IsolateFaultyComponentStrategy(),
        ]

        // File system errors
        recoveryStrategies[.fileSystem] = [
            RetryOperationStrategy(),
            CheckPermissionsStrategy(),
            UseAlternativePathStrategy(),
        ]

        // Network errors
        recoveryStrategies[.network] = [
            RetryWithBackoffStrategy(),
            CheckConnectivityStrategy(),
            UseOfflineModeStrategy(),
        ]
    }

    private func classifyError(_ error: Error) -> ErrorType {
        // Classify based on error type and message
        let errorString = String(describing: error)

        if errorString.contains("compilation") || errorString.contains("swiftc") {
            return .compilation
        } else if errorString.contains("runtime") || errorString.contains("objc") {
            return .runtime
        } else if errorString.contains("file") || errorString.contains("path") {
            return .fileSystem
        } else if errorString.contains("network") || errorString.contains("connection") {
            return .network
        } else if errorString.contains("memory") || errorString.contains("allocation") {
            return .memory
        } else {
            return .unknown
        }
    }

    private func storeError(_ record: ErrorRecord) async {
        await errorQueue.sync {
            errorHistory.append(record)
            totalErrors += 1

            // Maintain history limit
            if errorHistory.count > config.maxErrorHistory {
                errorHistory.removeFirst()
            }
        }
    }

    private func logError(_ record: ErrorRecord, type: ErrorType) {
        let timestamp = ISO8601DateFormatter().string(from: record.timestamp)
        let sessionInfo = record.session.map { " [Session: \($0.id)]" } ?? ""

        print("🔴 [\(timestamp)] Error: \(record.error.localizedDescription)")
        print("   Type: \(type)")
        print("   Context: \(record.context.description)\(sessionInfo)")
        print("   File: \(record.context.file ?? "unknown"):\(record.context.line ?? 0)")
    }

    private func detectErrorPatterns(_ record: ErrorRecord) async {
        // Simple pattern detection - in a real implementation, this would use ML
        let recentErrors = getErrorHistory(limit: 20)

        // Check for repeated errors
        let similarErrors = recentErrors.filter {
            String(describing: $0.error) == String(describing: record.error)
                && $0.context.file == record.context.file
        }

        if similarErrors.count >= 3 {
            let pattern = ErrorPattern(
                id: UUID(),
                type: .repeated,
                description: "Repeated error: \(record.error.localizedDescription)",
                frequency: similarErrors.count,
                firstOccurrence: similarErrors.last?.timestamp ?? record.timestamp,
                lastOccurrence: record.timestamp,
                affectedFiles: [record.context.file ?? "unknown"]
            )

            await errorQueue.sync {
                // Update existing pattern or add new one
                if let index = errorPatterns.firstIndex(where: {
                    $0.description == pattern.description
                }) {
                    errorPatterns[index] = pattern
                } else {
                    errorPatterns.append(pattern)
                }
            }
        }
    }

    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []

        let stats = getErrorStatistics()

        if stats.recoveryRate < 0.5 {
            recommendations.append(
                "Consider improving recovery strategies - current recovery rate is \(Int(stats.recoveryRate * 100))%"
            )
        }

        if stats.recentErrors > 5 {
            recommendations.append(
                "High error rate detected in the last hour (\(stats.recentErrors) errors)")
        }

        let topErrorType = stats.errorTypeDistribution.max { $0.value < $1.value }
        if let (type, count) = topErrorType, Double(count) / Double(stats.totalErrors) > 0.5 {
            recommendations.append(
                "Most errors are of type \(type) (\(count) occurrences) - focus recovery efforts here"
            )
        }

        return recommendations
    }
}

// MARK: - Supporting Types

/// Error context information
public struct ErrorContext {
    public let file: String?
    public let line: Int?
    public let function: String?
    public let description: String

    public init(
        file: String? = nil,
        line: Int? = nil,
        function: String? = nil,
        description: String
    ) {
        self.file = file
        self.line = line
        self.function = function
        self.description = description
    }
}

/// Error record for history
public struct ErrorRecord {
    public let id: UUID
    public let error: Error
    public let context: ErrorContext
    public let session: ReloadSession?
    public let timestamp: Date
    public var recoveryStatus: RecoveryStatus = .unhandled
}

/// Error type classification
public enum ErrorType: String, Codable {
    case compilation
    case runtime
    case fileSystem
    case network
    case memory
    case unknown
}

/// Recovery status
public enum RecoveryStatus {
    case unhandled
    case recovered
    case failed
}

/// Error handling result
public enum ErrorHandlingResult {
    case recovered(RecoveryResult)
    case unhandled(ErrorRecord)
}

/// Recovery result
public enum RecoveryResult {
    case recovered(RecoveryStrategy)
    case failed
    case notApplicable
}

/// Error filter for querying history
public struct ErrorFilter {
    public let errorType: ErrorType?
    public let sessionId: UUID?
    public let timeRange: ClosedRange<Date>?

    public init(
        errorType: ErrorType? = nil,
        sessionId: UUID? = nil,
        timeRange: ClosedRange<Date>? = nil
    ) {
        self.errorType = errorType
        self.sessionId = sessionId
        self.timeRange = timeRange
    }
}

/// Error statistics
public struct ErrorStatistics {
    public let totalErrors: Int
    public let recoveredErrors: Int
    public let unhandledErrors: Int
    public let recoveryRate: Double
    public let errorTypeDistribution: [ErrorType: Int]
    public let recentErrors: Int
}

/// Error pattern for analysis
public struct ErrorPattern {
    public let id: UUID
    public let type: PatternType
    public let description: String
    public let frequency: Int
    public let firstOccurrence: Date
    public let lastOccurrence: Date
    public let affectedFiles: [String]

    public enum PatternType {
        case repeated
        case cascading
        case intermittent
    }
}

/// Diagnostic report
public struct DiagnosticReport {
    public let timestamp: Date
    public let statistics: ErrorStatistics
    public let recentErrors: [ErrorRecord]
    public let patterns: [ErrorPattern]
    public let recommendations: [String]
}

// MARK: - Recovery Strategies

/// Protocol for recovery strategies
public protocol RecoveryStrategy {
    var name: String { get }
    var description: String { get }
    func execute(error: Error, context: ErrorContext) async throws
}

/// Retry with clean build strategy
public struct RetryWithCleanBuildStrategy: RecoveryStrategy {
    public let name = "Clean Build Retry"
    public let description = "Attempts to fix compilation errors by performing a clean build"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would trigger a clean build
        print("Executing clean build retry strategy")
        // Simulate clean build process
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
}

/// Fix import strategy
public struct FixImportStrategy: RecoveryStrategy {
    public let name = "Import Fix"
    public let description = "Attempts to fix import-related compilation errors"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would analyze and fix import statements
        print("Executing import fix strategy")
    }
}

/// Revert to last working strategy
public struct RevertToLastWorkingStrategy: RecoveryStrategy {
    public let name = "Revert to Last Working"
    public let description = "Reverts to the last known working state"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would revert to last working version
        print("Executing revert to last working strategy")
    }
}

/// Restart application strategy
public struct RestartApplicationStrategy: RecoveryStrategy {
    public let name = "Application Restart"
    public let description = "Restarts the application to clear runtime state"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would trigger application restart
        print("Executing application restart strategy")
    }
}

/// Rollback patch strategy
public struct RollbackPatchStrategy: RecoveryStrategy {
    public let name = "Patch Rollback"
    public let description = "Rolls back the last applied patch"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would rollback last patch
        print("Executing patch rollback strategy")
    }
}

/// Isolate faulty component strategy
public struct IsolateFaultyComponentStrategy: RecoveryStrategy {
    public let name = "Component Isolation"
    public let description = "Isolates the faulty component to prevent cascading failures"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would isolate faulty component
        print("Executing component isolation strategy")
    }
}

/// Retry operation strategy
public struct RetryOperationStrategy: RecoveryStrategy {
    public let name = "Operation Retry"
    public let description = "Retries the failed operation"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would retry the operation
        print("Executing operation retry strategy")
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}

/// Check permissions strategy
public struct CheckPermissionsStrategy: RecoveryStrategy {
    public let name = "Permission Check"
    public let description = "Checks and fixes file permissions"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would check and fix permissions
        print("Executing permission check strategy")
    }
}

/// Use alternative path strategy
public struct UseAlternativePathStrategy: RecoveryStrategy {
    public let name = "Alternative Path"
    public let description = "Uses an alternative file path"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would use alternative path
        print("Executing alternative path strategy")
    }
}

/// Retry with backoff strategy
public struct RetryWithBackoffStrategy: RecoveryStrategy {
    public let name = "Backoff Retry"
    public let description = "Retries with exponential backoff"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would retry with backoff
        print("Executing backoff retry strategy")
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }
}

/// Check connectivity strategy
public struct CheckConnectivityStrategy: RecoveryStrategy {
    public let name = "Connectivity Check"
    public let description = "Checks network connectivity"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would check connectivity
        print("Executing connectivity check strategy")
    }
}

/// Use offline mode strategy
public struct UseOfflineModeStrategy: RecoveryStrategy {
    public let name = "Offline Mode"
    public let description = "Switches to offline mode"

    public func execute(error: Error, context: ErrorContext) async throws {
        // Implementation would enable offline mode
        print("Executing offline mode strategy")
    }
}
