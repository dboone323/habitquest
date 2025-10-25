//
//  FileWatcher.swift
//  Hot Reload System
//
//  Monitors file system changes and triggers hot reload operations
//  with debouncing and filtering capabilities.
//

import Combine
import Foundation

/// Monitors file system changes and coordinates reload triggers
@available(macOS 12.0, *)
public class FileWatcher {

    // MARK: - Properties

    private var watchedDirectories: [URL: DirectoryWatcher] = [:]
    private var fileChangeSubject = PassthroughSubject<FileChange, Never>()
    private var debounceTimer: Timer?
    private var pendingChanges: [FileChange] = []

    private let watcherQueue = DispatchQueue(label: "com.quantum.file-watcher", qos: .userInitiated)
    private let debounceQueue = DispatchQueue(
        label: "com.quantum.file-debounce", qos: .userInitiated
    )

    /// Configuration for file watching
    public struct Configuration {
        public var debounceInterval: TimeInterval = 0.5
        public var ignoredPatterns: [String] = [".git", ".build", "DerivedData", "*.tmp", "*.log"]
        public var watchedExtensions: [String] = ["swift", "h", "m", "xib", "storyboard", "plist"]
        public var enableRecursiveWatching: Bool = true
        public var maxWatchDepth: Int = 5
        public var batchChanges: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public var fileChanges: AnyPublisher<FileChange, Never> {
        fileChangeSubject.eraseToAnyPublisher()
    }

    public private(set) var isWatching: Bool = false
    public private(set) var watchedPaths: [URL] = []

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
    }

    deinit {
        stopWatching()
    }

    // MARK: - Public API

    /// Start watching a directory for changes
    public func startWatching(directory: URL) throws {
        try watcherQueue.sync {
            guard !isWatching else { return }

            // Create directory watcher
            let watcher = try DirectoryWatcher(directory: directory, configuration: config)
            watcher.changeHandler = { [weak self] changes in
                self?.handleFileChanges(changes)
            }

            watchedDirectories[directory] = watcher
            watchedPaths.append(directory)
            isWatching = true

            try watcher.start()
        }
    }

    /// Stop watching all directories
    public func stopWatching() {
        watcherQueue.sync {
            for watcher in watchedDirectories.values {
                watcher.stop()
            }
            watchedDirectories.removeAll()
            watchedPaths.removeAll()
            isWatching = false
            debounceTimer?.invalidate()
            debounceTimer = nil
            pendingChanges.removeAll()
        }
    }

    /// Add a directory to watch
    public func addWatchDirectory(_ directory: URL) throws {
        try watcherQueue.sync {
            guard !watchedDirectories.keys.contains(directory) else { return }

            let watcher = try DirectoryWatcher(directory: directory, configuration: config)
            watcher.changeHandler = { [weak self] changes in
                self?.handleFileChanges(changes)
            }

            watchedDirectories[directory] = watcher
            watchedPaths.append(directory)

            if isWatching {
                try watcher.start()
            }
        }
    }

    /// Remove a watched directory
    public func removeWatchDirectory(_ directory: URL) {
        watcherQueue.sync {
            if let watcher = watchedDirectories.removeValue(forKey: directory) {
                watcher.stop()
            }
            watchedPaths.removeAll { $0 == directory }
        }
    }

    /// Get current watched directories
    public func getWatchedDirectories() -> [URL] {
        watcherQueue.sync {
            Array(watchedDirectories.keys)
        }
    }

    /// Check if a file should be watched based on configuration
    public func shouldWatchFile(_ fileURL: URL) -> Bool {
        let filename = fileURL.lastPathComponent

        // Check ignored patterns
        for pattern in config.ignoredPatterns {
            if filename.contains(pattern) || fileURL.path.contains(pattern) {
                return false
            }
        }

        // Check file extension
        let fileExtension = fileURL.pathExtension
        return config.watchedExtensions.contains(fileExtension) || fileExtension.isEmpty
    }

    /// Manually trigger a file change event
    public func triggerFileChange(_ change: FileChange) {
        fileChangeSubject.send(change)
    }

    // MARK: - Private Methods

    private func handleFileChanges(_ changes: [FileChange]) {
        debounceQueue.async { [weak self] in
            guard let self else { return }

            // Filter changes
            let filteredChanges = changes.filter { self.shouldWatchFile($0.fileURL) }

            guard !filteredChanges.isEmpty else { return }

            if self.config.batchChanges {
                // Batch changes with debouncing
                self.pendingChanges.append(contentsOf: filteredChanges)
                self.scheduleDebouncedEmit()
            } else {
                // Emit immediately
                for change in filteredChanges {
                    self.fileChangeSubject.send(change)
                }
            }
        }
    }

    private func scheduleDebouncedEmit() {
        debounceTimer?.invalidate()

        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: config.debounceInterval, repeats: false
        ) { [weak self] _ in
            self?.emitBatchedChanges()
        }
    }

    private func emitBatchedChanges() {
        debounceQueue.async { [weak self] in
            guard let self else { return }

            guard !self.pendingChanges.isEmpty else { return }

            // Group changes by file (keep only the latest change per file)
            var latestChanges: [URL: FileChange] = [:]
            for change in self.pendingChanges {
                latestChanges[change.fileURL] = change
            }

            // Emit batched changes
            for change in latestChanges.values.sorted(by: { $0.timestamp < $1.timestamp }) {
                self.fileChangeSubject.send(change)
            }

            self.pendingChanges.removeAll()
        }
    }
}

// MARK: - Supporting Types

/// File change event
public struct FileChange {
    public let fileURL: URL
    public let changeType: ChangeType
    public let timestamp: Date
    public let oldURL: URL?
    public let attributes: [FileAttributeKey: Any]?

    public init(
        fileURL: URL,
        changeType: ChangeType,
        timestamp: Date = Date(),
        oldURL: URL? = nil,
        attributes: [FileAttributeKey: Any]? = nil
    ) {
        self.fileURL = fileURL
        self.changeType = changeType
        self.timestamp = timestamp
        self.oldURL = oldURL
        self.attributes = attributes
    }

    public enum ChangeType {
        case created
        case modified
        case deleted
        case renamed
        case attributeChanged
    }
}

/// Directory watcher using DispatchSource
private class DirectoryWatcher {

    private let directory: URL
    private let config: FileWatcher.Configuration
    private var source: DispatchSourceFileSystemObject?
    private let fileManager = FileManager.default

    var changeHandler: (([FileChange]) -> Void)?

    private var lastEventId: UInt64 = 0
    private var knownFiles: Set<URL> = []

    init(directory: URL, configuration: FileWatcher.Configuration) throws {
        self.directory = directory
        self.config = configuration

        // Initial scan
        try scanDirectory()
    }

    deinit {
        stop()
    }

    func start() throws {
        let fileDescriptor = open(directory.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            throw WatcherError.cannotOpenDirectory(directory)
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename, .attrib],
            queue: DispatchQueue.global(qos: .userInitiated)
        )

        source?.setEventHandler { [weak self] in
            self?.handleFileSystemEvent()
        }

        source?.setCancelHandler {
            close(fileDescriptor)
        }

        source?.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    private func scanDirectory() throws {
        let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey, .modificationDateKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )

        knownFiles.removeAll()
        while let fileURL = enumerator?.nextObject() as? URL {
            if config.watchedExtensions.contains(fileURL.pathExtension)
                || fileURL.pathExtension.isEmpty
            {
                knownFiles.insert(fileURL)
            }
        }
    }

    private func handleFileSystemEvent() {
        do {
            let enumerator = fileManager.enumerator(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey, .modificationDateKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )

            var currentFiles: Set<URL> = []
            var changes: [FileChange] = []

            while let fileURL = enumerator?.nextObject() as? URL {
                guard
                    config.watchedExtensions.contains(fileURL.pathExtension)
                    || fileURL.pathExtension.isEmpty
                else {
                    continue
                }

                currentFiles.insert(fileURL)

                if !knownFiles.contains(fileURL) {
                    // New file
                    changes.append(
                        FileChange(
                            fileURL: fileURL,
                            changeType: .created,
                            attributes: try? fileManager.attributesOfItem(atPath: fileURL.path)
                        ))
                } else {
                    // Check if modified
                    if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                       let modDate = attributes[.modificationDate] as? Date,
                       let lastModDate =
                       (try? fileManager.attributesOfItem(atPath: fileURL.path))?[
                           .modificationDate
                       ] as? Date,
                       modDate > lastModDate ?? Date.distantPast
                    {
                        changes.append(
                            FileChange(
                                fileURL: fileURL,
                                changeType: .modified,
                                attributes: attributes
                            ))
                    }
                }
            }

            // Check for deleted files
            for oldFile in knownFiles {
                if !currentFiles.contains(oldFile) {
                    changes.append(
                        FileChange(
                            fileURL: oldFile,
                            changeType: .deleted
                        ))
                }
            }

            knownFiles = currentFiles

            if !changes.isEmpty {
                changeHandler?(changes)
            }

        } catch {
            print("Error handling file system event: \(error)")
        }
    }
}

/// Watcher error types
public enum WatcherError: Error, LocalizedError {
    case cannotOpenDirectory(URL)
    case invalidPath(URL)
    case permissionDenied(URL)

    public var errorDescription: String? {
        switch self {
        case let .cannotOpenDirectory(url):
            return "Cannot open directory for watching: \(url.path)"
        case let .invalidPath(url):
            return "Invalid path: \(url.path)"
        case let .permissionDenied(url):
            return "Permission denied for path: \(url.path)"
        }
    }
}

// MARK: - File Change Extensions

extension FileChange: CustomStringConvertible {
    public var description: String {
        let typeString: String
        switch changeType {
        case .created: typeString = "created"
        case .modified: typeString = "modified"
        case .deleted: typeString = "deleted"
        case .renamed: typeString = "renamed"
        case .attributeChanged: typeString = "attribute changed"
        }

        return "\(typeString): \(fileURL.lastPathComponent)"
    }
}

extension FileChange: Equatable {
    public static func == (lhs: FileChange, rhs: FileChange) -> Bool {
        lhs.fileURL == rhs.fileURL && lhs.changeType == rhs.changeType
            && abs(lhs.timestamp.timeIntervalSince(rhs.timestamp)) < 0.1 // Within 100ms
    }
}

extension FileChange: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
        hasher.combine(changeType)
        hasher.combine(Int(timestamp.timeIntervalSince1970 * 1000)) // Hash timestamp with second precision
    }
}
