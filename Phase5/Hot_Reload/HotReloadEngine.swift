//
//  HotReloadEngine.swift
//  Hot Reload System
//
//  Core engine for managing hot reload operations in Swift applications.
//  Provides incremental compilation, runtime patching, and state preservation.
//

import Combine
import Foundation

/// Main engine for hot reload functionality
@available(macOS 12.0, *)
public class HotReloadEngine {

    // MARK: - Properties

    private let incrementalCompiler: IncrementalCompiler
    private let runtimePatcher: RuntimePatcher
    private let statePreserver: StatePreserver
    private let reloadCoordinator: ReloadCoordinator
    private let errorHandler: ErrorHandler
    private let fileWatcher: FileWatcher

    private var cancellables: Set<AnyCancellable> = []
    private var isEnabled = false

    /// Configuration for hot reload engine
    public struct Configuration {
        public var autoReloadEnabled: Bool = true
        public var compilationTimeout: TimeInterval = 30.0
        public var preserveState: Bool = true
        public var errorRecoveryEnabled: Bool = true
        public var watchDirectories: [URL] = []
        public var excludedPatterns: [String] = []
        public var incrementalBuildEnabled: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Publishers

    /// Publisher for reload events
    public let reloadEvents = PassthroughSubject<ReloadEvent, Never>()

    /// Publisher for compilation status
    public let compilationStatus = CurrentValueSubject<CompilationStatus, Never>(.idle)

    /// Publisher for reload errors
    public let reloadErrors = PassthroughSubject<ReloadError, Never>()

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) throws {
        self.config = configuration

        // Initialize components
        self.incrementalCompiler = try IncrementalCompiler()
        self.runtimePatcher = RuntimePatcher()
        self.statePreserver = StatePreserver()
        self.reloadCoordinator = ReloadCoordinator()
        self.errorHandler = ErrorHandler()
        self.fileWatcher = FileWatcher()

        setupBindings()
        setupFileWatching()
    }

    // MARK: - Public API

    /// Enable hot reload functionality
    public func enable() {
        guard !isEnabled else { return }

        isEnabled = true
        fileWatcher.startWatching()
        reloadEvents.send(.enabled)

        print("🔄 Hot Reload Engine enabled")
    }

    /// Disable hot reload functionality
    public func disable() {
        guard isEnabled else { return }

        isEnabled = false
        fileWatcher.stopWatching()
        reloadEvents.send(.disabled)

        print("🔄 Hot Reload Engine disabled")
    }

    /// Manually trigger a reload for specific files
    public func reload(files: [URL]) async throws {
        guard isEnabled else {
            throw ReloadError.engineDisabled
        }

        reloadEvents.send(.started(files))

        do {
            // Preserve current state
            if config.preserveState {
                try await statePreserver.captureState()
            }

            // Compile changes
            compilationStatus.send(.compiling)
            let compilationResult = try await incrementalCompiler.compile(files: files)

            compilationStatus.send(.completed)

            // Apply patches
            try await runtimePatcher.applyPatches(from: compilationResult)

            // Restore state if needed
            if config.preserveState {
                try await statePreserver.restoreState()
            }

            reloadEvents.send(.completed(files, compilationResult))

        } catch let error as ReloadError {
            reloadErrors.send(error)
            reloadEvents.send(.failed(files, error))

            if config.errorRecoveryEnabled {
                try await errorHandler.attemptRecovery(from: error)
            }

            throw error
        } catch {
            let reloadError = ReloadError.unknown(error)
            reloadErrors.send(reloadError)
            reloadEvents.send(.failed(files, reloadError))
            throw reloadError
        }
    }

    /// Check if a file can be hot reloaded
    public func canReload(file: URL) -> Bool {
        // Check if file is in watched directories
        let isInWatchedDir = config.watchDirectories.contains { watchedDir in
            file.path.hasPrefix(watchedDir.path)
        }

        // Check if file matches excluded patterns
        let isExcluded = config.excludedPatterns.contains { pattern in
            file.lastPathComponent.contains(pattern) || file.path.contains(pattern)
        }

        // Check file extension
        let supportedExtensions = ["swift"]
        let fileExtension = file.pathExtension.lowercased()
        let isSupported = supportedExtensions.contains(fileExtension)

        return isInWatchedDir && !isExcluded && isSupported
    }

    /// Get current reload status
    public func getStatus() -> ReloadStatus {
        ReloadStatus(
            isEnabled: isEnabled,
            compilationStatus: compilationStatus.value,
            activeReloads: reloadCoordinator.activeReloads,
            lastReloadTime: reloadCoordinator.lastReloadTime,
            totalReloads: reloadCoordinator.totalReloads
        )
    }

    /// Force a full rebuild instead of incremental
    public func forceFullRebuild() async throws {
        incrementalCompiler.forceFullRebuild()
        reloadEvents.send(.fullRebuildTriggered)
    }

    /// Clear all cached compilation data
    public func clearCache() {
        incrementalCompiler.clearCache()
        runtimePatcher.clearPatches()
        reloadEvents.send(.cacheCleared)
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Bind file watcher to reload trigger
        fileWatcher.fileChanges
            .filter { [weak self] _ in self?.config.autoReloadEnabled ?? false }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] changes in
                self?.handleFileChanges(changes)
            }
            .store(in: &cancellables)

        // Bind compilation status updates
        incrementalCompiler.compilationProgress
            .sink { [weak self] _ in
                self?.compilationStatus.send(.compiling)
            }
            .store(in: &cancellables)
    }

    private func setupFileWatching() {
        // Set up default watch directories if none specified
        if config.watchDirectories.isEmpty {
            let workspaceURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            config.watchDirectories = [
                workspaceURL.appendingPathComponent("Sources"),
                workspaceURL.appendingPathComponent("Tests"),
            ].filter { FileManager.default.fileExists(atPath: $0.path) }
        }

        fileWatcher.watchDirectories(config.watchDirectories)
    }

    private func handleFileChanges(_ changes: [FileChange]) {
        let reloadableFiles =
            changes
                .filter { canReload(file: $0.url) }
                .map(\.url)

        guard !reloadableFiles.isEmpty else { return }

        Task {
            do {
                try await reload(files: reloadableFiles)
            } catch {
                print("🔄 Auto-reload failed: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

/// Reload event types
public enum ReloadEvent {
    case enabled
    case disabled
    case started([URL])
    case completed([URL], CompilationResult)
    case failed([URL], ReloadError)
    case fullRebuildTriggered
    case cacheCleared
}

/// Compilation status
public enum CompilationStatus {
    case idle
    case compiling
    case completed
    case failed(Error)
}

/// Reload error types
public enum ReloadError: Error, LocalizedError {
    case engineDisabled
    case compilationFailed(String)
    case patchingFailed(String)
    case statePreservationFailed(String)
    case fileNotFound(URL)
    case unsupportedFileType(String)
    case timeout(TimeInterval)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .engineDisabled:
            return "Hot reload engine is disabled"
        case let .compilationFailed(reason):
            return "Compilation failed: \(reason)"
        case let .patchingFailed(reason):
            return "Runtime patching failed: \(reason)"
        case let .statePreservationFailed(reason):
            return "State preservation failed: \(reason)"
        case let .fileNotFound(url):
            return "File not found: \(url.path)"
        case let .unsupportedFileType(type):
            return "Unsupported file type: \(type)"
        case let .timeout(seconds):
            return "Operation timed out after \(seconds) seconds"
        case let .unknown(error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

/// File change information
public struct FileChange {
    public let url: URL
    public let changeType: ChangeType
    public let timestamp: Date

    public enum ChangeType {
        case created
        case modified
        case deleted
    }

    public init(url: URL, changeType: ChangeType, timestamp: Date = Date()) {
        self.url = url
        self.changeType = changeType
        self.timestamp = timestamp
    }
}

/// Reload status information
public struct ReloadStatus {
    public let isEnabled: Bool
    public let compilationStatus: CompilationStatus
    public let activeReloads: Int
    public let lastReloadTime: Date?
    public let totalReloads: Int

    public init(
        isEnabled: Bool = false,
        compilationStatus: CompilationStatus = .idle,
        activeReloads: Int = 0,
        lastReloadTime: Date? = nil,
        totalReloads: Int = 0
    ) {
        self.isEnabled = isEnabled
        self.compilationStatus = compilationStatus
        self.activeReloads = activeReloads
        self.lastReloadTime = lastReloadTime
        self.totalReloads = totalReloads
    }
}

/// Compilation result
public struct CompilationResult {
    public let compiledFiles: [URL]
    public let objectFiles: [URL]
    public let compilationTime: TimeInterval
    public let warnings: [String]
    public let errors: [String]

    public init(
        compiledFiles: [URL] = [],
        objectFiles: [URL] = [],
        compilationTime: TimeInterval = 0,
        warnings: [String] = [],
        errors: [String] = []
    ) {
        self.compiledFiles = compiledFiles
        self.objectFiles = objectFiles
        self.compilationTime = compilationTime
        self.warnings = warnings
        self.errors = errors
    }
}
