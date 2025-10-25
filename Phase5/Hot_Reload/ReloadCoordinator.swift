//
//  ReloadCoordinator.swift
//  Hot Reload System
//
//  Coordinates the entire hot reload process, managing timing, dependencies,
//  and ensuring safe reload execution.
//

import Foundation

/// Coordinates hot reload operations and manages reload lifecycle
@available(macOS 12.0, *)
public class ReloadCoordinator {

    // MARK: - Properties

    private var activeReloads: Set<ReloadSession> = []
    private var reloadQueue: [ReloadRequest] = []
    private var reloadHistory: [ReloadRecord] = []

    private let coordinationQueue = DispatchQueue(
        label: "com.quantum.reload-coordinator", qos: .userInitiated
    )
    private let semaphore = DispatchSemaphore(value: 1) // Control concurrent reloads

    /// Configuration for reload coordination
    public struct Configuration {
        public var maxConcurrentReloads: Int = 1
        public var reloadTimeout: TimeInterval = 30.0
        public var queueSizeLimit: Int = 10
        public var enableDependencyResolution: Bool = true
        public var prioritizeCriticalReloads: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public private(set) var totalReloads: Int = 0
    public private(set) var lastReloadTime: Date?

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
    }

    // MARK: - Public API

    /// Request a reload operation
    public func requestReload(_ request: ReloadRequest) async throws -> ReloadSession {
        try await coordinationQueue.sync {
            // Check queue limits
            guard reloadQueue.count < config.queueSizeLimit else {
                throw CoordinationError.queueFull
            }

            // Check concurrent reload limits
            guard activeReloads.count < config.maxConcurrentReloads else {
                // Queue the request
                reloadQueue.append(request)
                throw CoordinationError.reloadInProgress
            }

            // Create reload session
            let session = ReloadSession(
                id: UUID(),
                request: request,
                startTime: Date(),
                status: .preparing
            )

            activeReloads.insert(session)

            return session
        }
    }

    /// Start a reload session
    public func startReload(_ session: ReloadSession) async throws {
        try await coordinationQueue.sync {
            guard var updatedSession = activeReloads.first(where: { $0.id == session.id }) else {
                throw CoordinationError.sessionNotFound
            }

            updatedSession.status = .inProgress
            activeReloads.update(with: updatedSession)

            // Set timeout
            Task {
                try await Task.sleep(nanoseconds: UInt64(config.reloadTimeout * 1_000_000_000))
                await timeoutReload(session.id)
            }
        }
    }

    /// Complete a reload session
    public func completeReload(_ session: ReloadSession, result: ReloadResult) async {
        await coordinationQueue.sync {
            guard var updatedSession = activeReloads.first(where: { $0.id == session.id }) else {
                return
            }

            updatedSession.status = .completed
            updatedSession.endTime = Date()
            activeReloads.update(with: updatedSession)

            // Record in history
            let record = ReloadRecord(
                session: updatedSession,
                result: result,
                timestamp: Date()
            )
            reloadHistory.append(record)

            // Update statistics
            totalReloads += 1
            lastReloadTime = Date()

            // Process queued reloads
            processQueuedReloads()
        }
    }

    /// Fail a reload session
    public func failReload(_ session: ReloadSession, error: Error) async {
        await coordinationQueue.sync {
            guard var updatedSession = activeReloads.first(where: { $0.id == session.id }) else {
                return
            }

            updatedSession.status = .failed
            updatedSession.endTime = Date()
            updatedSession.error = error
            activeReloads.update(with: updatedSession)

            // Record in history
            let record = ReloadRecord(
                session: updatedSession,
                result: .failure(error),
                timestamp: Date()
            )
            reloadHistory.append(record)

            // Process queued reloads
            processQueuedReloads()
        }
    }

    /// Cancel a reload session
    public func cancelReload(_ sessionId: UUID) async throws {
        try await coordinationQueue.sync {
            guard let session = activeReloads.first(where: { $0.id == sessionId }) else {
                throw CoordinationError.sessionNotFound
            }

            guard session.status == .queued || session.status == .preparing else {
                throw CoordinationError.cannotCancel(session.status)
            }

            var updatedSession = session
            updatedSession.status = .cancelled
            updatedSession.endTime = Date()
            activeReloads.update(with: updatedSession)

            // Record in history
            let record = ReloadRecord(
                session: updatedSession,
                result: .cancelled,
                timestamp: Date()
            )
            reloadHistory.append(record)
        }
    }

    /// Get active reload sessions
    public func getActiveReloads() -> [ReloadSession] {
        coordinationQueue.sync {
            Array(activeReloads)
        }
    }

    /// Get reload history
    public func getReloadHistory(limit: Int? = nil) -> [ReloadRecord] {
        coordinationQueue.sync {
            let history = reloadHistory.sorted { $0.timestamp > $1.timestamp }
            if let limit {
                return Array(history.prefix(limit))
            }
            return history
        }
    }

    /// Get reload statistics
    public func getReloadStatistics() -> ReloadStatistics {
        coordinationQueue.sync {
            let total = reloadHistory.count
            let successful = reloadHistory.filter(\.result.isSuccess).count
            let failed = reloadHistory.filter(\.result.isFailure).count
            let cancelled = reloadHistory.filter(\.result.isCancelled).count

            let successRate = total > 0 ? Double(successful) / Double(total) : 0

            let averageDuration =
                reloadHistory
                    .filter(\.result.isSuccess)
                    .compactMap(\.session.duration)
                    .reduce(0, +) / Double(max(successful, 1))

            return ReloadStatistics(
                totalReloads: total,
                successfulReloads: successful,
                failedReloads: failed,
                cancelledReloads: cancelled,
                successRate: successRate,
                averageDuration: averageDuration,
                lastReloadTime: lastReloadTime
            )
        }
    }

    /// Clear reload history
    public func clearHistory() {
        coordinationQueue.sync {
            reloadHistory.removeAll()
        }
    }

    /// Resolve reload dependencies
    public func resolveDependencies(for request: ReloadRequest) -> [ReloadRequest] {
        guard config.enableDependencyResolution else {
            return [request]
        }

        // Simplified dependency resolution
        // In a real implementation, this would analyze file dependencies
        var dependentRequests: [ReloadRequest] = [request]

        // Add dependent files (simplified example)
        for file in request.files {
            if file.lastPathComponent.hasSuffix("ViewModel.swift") {
                // Find corresponding view file
                let viewFile = file.deletingPathExtension().appendingPathExtension("swift")
                    .deletingLastPathComponent()
                    .appendingPathComponent("Views")
                    .appendingPathComponent(
                        file.lastPathComponent.replacingOccurrences(of: "ViewModel", with: "View"))

                if FileManager.default.fileExists(atPath: viewFile.path) {
                    dependentRequests.append(
                        ReloadRequest(
                            files: [viewFile],
                            priority: request.priority,
                            context: request.context + " (dependency)"
                        ))
                }
            }
        }

        return dependentRequests
    }

    // MARK: - Private Methods

    private func processQueuedReloads() {
        guard !reloadQueue.isEmpty && activeReloads.count < config.maxConcurrentReloads else {
            return
        }

        // Sort by priority if enabled
        var sortedQueue = reloadQueue
        if config.prioritizeCriticalReloads {
            sortedQueue.sort { $0.priority.rawValue > $1.priority.rawValue }
        }

        // Process next reload
        if let nextRequest = sortedQueue.first {
            reloadQueue.removeFirst()

            Task {
                do {
                    let session = try await requestReload(nextRequest)
                    try await startReload(session)
                    // The actual reload logic would be handled by the caller
                } catch {
                    print("Failed to process queued reload: \(error)")
                }
            }
        }
    }

    private func timeoutReload(_ sessionId: UUID) async {
        await coordinationQueue.sync {
            guard var session = activeReloads.first(where: { $0.id == sessionId }) else {
                return
            }

            guard session.status == .inProgress else {
                return
            }

            // Mark as timed out
            session.status = .timedOut
            session.endTime = Date()
            activeReloads.update(with: session)

            // Record in history
            let record = ReloadRecord(
                session: session,
                result: .timeout,
                timestamp: Date()
            )
            reloadHistory.append(record)

            // Process queued reloads
            processQueuedReloads()
        }
    }
}

// MARK: - Supporting Types

/// Reload request
public struct ReloadRequest {
    public let files: [URL]
    public let priority: Priority
    public let context: String
    public let requester: String?

    public enum Priority: Int {
        case low = 0
        case normal = 1
        case high = 2
        case critical = 3
    }

    public init(
        files: [URL],
        priority: Priority = .normal,
        context: String = "",
        requester: String? = nil
    ) {
        self.files = files
        self.priority = priority
        self.context = context
        self.requester = requester
    }
}

/// Reload session
public struct ReloadSession: Hashable {
    public let id: UUID
    public let request: ReloadRequest
    public let startTime: Date
    public var status: ReloadStatus
    public var endTime: Date?
    public var error: Error?

    public var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    public init(
        id: UUID,
        request: ReloadRequest,
        startTime: Date,
        status: ReloadStatus
    ) {
        self.id = id
        self.request = request
        self.startTime = startTime
        self.status = status
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ReloadSession, rhs: ReloadSession) -> Bool {
        lhs.id == rhs.id
    }
}

/// Reload status
public enum ReloadStatus {
    case queued
    case preparing
    case inProgress
    case completed
    case failed
    case cancelled
    case timedOut
}

/// Reload result
public enum ReloadResult {
    case success(CompilationResult)
    case failure(Error)
    case cancelled
    case timeout

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isFailure: Bool {
        if case .failure = self { return true }
        return false
    }

    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }
}

/// Reload record for history
public struct ReloadRecord {
    public let session: ReloadSession
    public let result: ReloadResult
    public let timestamp: Date
}

/// Reload statistics
public struct ReloadStatistics {
    public let totalReloads: Int
    public let successfulReloads: Int
    public let failedReloads: Int
    public let cancelledReloads: Int
    public let successRate: Double
    public let averageDuration: TimeInterval
    public let lastReloadTime: Date?
}

/// Coordination error types
public enum CoordinationError: Error, LocalizedError {
    case queueFull
    case reloadInProgress
    case sessionNotFound
    case cannotCancel(ReloadStatus)
    case dependencyResolutionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .queueFull:
            return "Reload queue is full"
        case .reloadInProgress:
            return "Another reload is currently in progress"
        case .sessionNotFound:
            return "Reload session not found"
        case let .cannotCancel(status):
            return "Cannot cancel reload with status: \(status)"
        case let .dependencyResolutionFailed(reason):
            return "Dependency resolution failed: \(reason)"
        }
    }
}
