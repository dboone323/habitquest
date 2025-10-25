//
//  BuildCache.swift
//  Distributed Build System
//
//  Intelligent caching system for build artifacts with dependency tracking,
//  cache invalidation, and distributed cache synchronization.
//

import CryptoKit
import Foundation

/// Intelligent build cache with dependency tracking and invalidation
@available(macOS 12.0, *)
public class BuildCache {

    // MARK: - Properties

    private var cacheStorage: CacheStorage
    private var dependencyTracker: DependencyTracker
    private var cacheIndex: [CacheKey: CacheEntry] = [:]
    private var accessLog: [CacheKey: Date] = [:]

    private let cacheQueue = DispatchQueue(label: "com.quantum.build-cache", qos: .userInitiated)
    private let cleanupTimer: Timer?

    /// Configuration for build caching
    public struct Configuration {
        public var maxCacheSize: Int64 = 10 * 1024 * 1024 * 1024 // 10GB
        public var cacheDirectory: URL
        public var cleanupInterval: TimeInterval = 3600.0 // 1 hour
        public var enableCompression: Bool = true
        public var enableEncryption: Bool = false
        public var maxEntryAge: TimeInterval = 7 * 24 * 3600.0 // 7 days
        public var dependencyTrackingEnabled: Bool = true

        public init(
            cacheDirectory: URL = FileManager.default.temporaryDirectory.appendingPathComponent(
                "BuildCache")
        ) {
            self.cacheDirectory = cacheDirectory
        }
    }

    private var config: Configuration

    // MARK: - Public Properties

    public var cacheSize: Int64 {
        cacheQueue.sync { cacheIndex.values.reduce(0) { $0 + $1.size } }
    }

    public var entryCount: Int {
        cacheQueue.sync { cacheIndex.count }
    }

    public var hitRate: Double {
        cacheQueue.sync {
            let totalAccesses = accessLog.count
            guard totalAccesses > 0 else { return 0 }

            let hits = accessLog.filter { cacheIndex[$0.key] != nil }.count
            return Double(hits) / Double(totalAccesses)
        }
    }

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) throws {
        self.config = configuration
        self.cacheStorage = try CacheStorage(directory: configuration.cacheDirectory)
        self.dependencyTracker = DependencyTracker()

        // Start cleanup timer
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: config.cleanupInterval, repeats: true) { [weak self] _ in
            self?.performCleanup()
        }

        // Load existing cache index
        try loadCacheIndex()
    }

    deinit {
        cleanupTimer?.invalidate()
    }

    // MARK: - Public API

    /// Store build artifacts in cache
    public func store(
        _ artifacts: [BuildArtifact], for task: BuildTask, dependencies: [String] = []
    ) async throws {
        let cacheKey = try createCacheKey(for: task, dependencies: dependencies)

        // Create cache entry
        let entry = try CacheEntry(
            key: cacheKey,
            artifacts: artifacts,
            task: task,
            dependencies: dependencies,
            created: Date(),
            size: calculateArtifactsSize(artifacts)
        )

        try await cacheQueue.sync {
            // Store artifacts
            try cacheStorage.storeArtifacts(artifacts, forKey: cacheKey)

            // Update index
            cacheIndex[cacheKey] = entry

            // Track dependencies
            if config.dependencyTrackingEnabled {
                dependencyTracker.addDependencies(for: cacheKey, dependencies: dependencies)
            }

            // Save index
            try saveCacheIndex()
        }
    }

    /// Retrieve cached artifacts
    public func retrieve(for task: BuildTask, dependencies: [String] = []) throws
        -> [BuildArtifact]?
    {
        let cacheKey = try createCacheKey(for: task, dependencies: dependencies)

        return try cacheQueue.sync {
            accessLog[cacheKey] = Date()

            guard let entry = cacheIndex[cacheKey] else {
                return nil
            }

            // Check if entry is still valid
            guard isEntryValid(entry) else {
                // Remove invalid entry
                try? removeEntry(cacheKey)
                return nil
            }

            // Check dependencies
            if config.dependencyTrackingEnabled {
                let affectedKeys = dependencyTracker.getAffectedKeys(forChanges: dependencies)
                if affectedKeys.contains(cacheKey) {
                    // Dependencies changed, invalidate cache
                    try? removeEntry(cacheKey)
                    return nil
                }
            }

            // Retrieve artifacts
            return try cacheStorage.retrieveArtifacts(forKey: cacheKey)
        }
    }

    /// Check if task result is cached
    public func isCached(_ task: BuildTask, dependencies: [String] = []) throws -> Bool {
        let cacheKey = try createCacheKey(for: task, dependencies: dependencies)
        return cacheQueue.sync { cacheIndex[cacheKey] != nil }
    }

    /// Invalidate cache entries based on file changes
    public func invalidateCache(forChanges changes: [String]) async throws {
        try await cacheQueue.sync {
            let affectedKeys = dependencyTracker.getAffectedKeys(forChanges: changes)

            for key in affectedKeys {
                try removeEntry(key)
            }

            // Also check direct file matches
            let keysToRemove = cacheIndex.keys.filter { key in
                changes.contains { change in
                    key.inputHash.contains(change) || key.dependencyHash.contains(change)
                }
            }

            for key in keysToRemove {
                try removeEntry(key)
            }

            try saveCacheIndex()
        }
    }

    /// Clear entire cache
    public func clearCache() async throws {
        try await cacheQueue.sync {
            cacheIndex.removeAll()
            accessLog.removeAll()
            dependencyTracker.clear()
            try cacheStorage.clear()
            try saveCacheIndex()
        }
    }

    /// Get cache statistics
    public func getCacheStatistics() -> CacheStatistics {
        cacheQueue.sync {
            let totalEntries = cacheIndex.count
            let totalSize = cacheSize
            let averageEntrySize = totalEntries > 0 ? totalSize / Int64(totalEntries) : 0

            let entriesByAge = Dictionary(grouping: cacheIndex.values) { entry in
                let age = Date().timeIntervalSince(entry.created)
                if age < 3600 { return "hour" }
                if age < 86400 { return "day" }
                if age < 604_800 { return "week" }
                return "older"
            }.mapValues { $0.count }

            let hitRate = self.hitRate
            let storageEfficiency = calculateStorageEfficiency()

            return CacheStatistics(
                totalEntries: totalEntries,
                totalSize: totalSize,
                averageEntrySize: averageEntrySize,
                entriesByAge: entriesByAge,
                hitRate: hitRate,
                storageEfficiency: storageEfficiency
            )
        }
    }

    /// Optimize cache (remove old/unused entries)
    public func optimizeCache() async throws {
        try await cacheQueue.sync {
            let keysToRemove = cacheIndex.filter { _, entry in
                !isEntryValid(entry) || shouldEvictEntry(entry)
            }.keys

            for key in keysToRemove {
                try removeEntry(key)
            }

            try saveCacheIndex()
        }
    }

    /// Synchronize cache with remote nodes
    public func synchronizeWithRemote(_ remoteCache: BuildCache) async throws {
        // This would implement cache synchronization across distributed nodes
        // For now, it's a placeholder
        print("Cache synchronization not yet implemented")
    }

    // MARK: - Private Methods

    private func createCacheKey(for task: BuildTask, dependencies: [String]) throws -> CacheKey {
        // Create hash of task inputs
        let inputString =
            "\(task.type.rawValue)|\(task.files.joined(separator: ","))|\(task.dependencies.joined(separator: ","))"
        let inputHash = SHA256.hash(data: Data(inputString.utf8)).compactMap {
            String(format: "%02x", $0)
        }.joined()

        // Create hash of dependencies
        let dependencyString = dependencies.sorted().joined(separator: ",")
        let dependencyHash = SHA256.hash(data: Data(dependencyString.utf8)).compactMap {
            String(format: "%02x", $0)
        }.joined()

        return CacheKey(inputHash: inputHash, dependencyHash: dependencyHash)
    }

    private func calculateArtifactsSize(_ artifacts: [BuildArtifact]) throws -> Int64 {
        var totalSize: Int64 = 0

        for artifact in artifacts {
            let attributes = try FileManager.default.attributesOfItem(atPath: artifact.path)
            if let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }

        return totalSize
    }

    private func isEntryValid(_ entry: CacheEntry) -> Bool {
        // Check age
        let age = Date().timeIntervalSince(entry.created)
        if age > config.maxEntryAge {
            return false
        }

        // Check if artifacts still exist
        for artifact in entry.artifacts {
            if !FileManager.default.fileExists(atPath: artifact.path) {
                return false
            }
        }

        return true
    }

    private func shouldEvictEntry(_ entry: CacheEntry) -> Bool {
        // LRU-style eviction based on access time
        guard let lastAccess = accessLog[entry.key] else {
            return true // Never accessed
        }

        let timeSinceAccess = Date().timeIntervalSince(lastAccess)
        return timeSinceAccess > config.maxEntryAge / 2 // Evict if not accessed recently
    }

    private func removeEntry(_ key: CacheKey) throws {
        if let entry = cacheIndex.removeValue(forKey: key) {
            try cacheStorage.removeArtifacts(forKey: key)
            dependencyTracker.removeDependencies(for: key)
            accessLog.removeValue(forKey: key)
        }
    }

    private func performCleanup() {
        Task {
            try? await optimizeCache()
        }
    }

    private func loadCacheIndex() throws {
        let indexURL = config.cacheDirectory.appendingPathComponent("cache_index.json")

        guard FileManager.default.fileExists(atPath: indexURL.path) else {
            return // No existing index
        }

        let data = try Data(contentsOf: indexURL)
        let decoder = JSONDecoder()
        cacheIndex = try decoder.decode([CacheKey: CacheEntry].self, from: data)
    }

    private func saveCacheIndex() throws {
        let indexURL = config.cacheDirectory.appendingPathComponent("cache_index.json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(cacheIndex)

        try data.write(to: indexURL, options: .atomic)
    }

    private func calculateStorageEfficiency() -> Double {
        // Calculate how much space is saved by caching vs rebuilding
        // This is a simplified calculation
        let cachedSize = cacheSize
        let estimatedRebuildSize = Int64(cacheIndex.count) * 1024 * 1024 // Assume 1MB per rebuild

        guard estimatedRebuildSize > 0 else { return 0 }

        return Double(cachedSize) / Double(estimatedRebuildSize)
    }
}

// MARK: - Supporting Types

/// Cache key for identifying cached entries
public struct CacheKey: Hashable, Codable {
    public let inputHash: String
    public let dependencyHash: String

    public init(inputHash: String, dependencyHash: String) {
        self.inputHash = inputHash
        self.dependencyHash = dependencyHash
    }
}

/// Cache entry metadata
public struct CacheEntry: Codable {
    public let key: CacheKey
    public let artifacts: [BuildArtifact]
    public let task: BuildTask
    public let dependencies: [String]
    public let created: Date
    public let size: Int64
}

/// Cache statistics
public struct CacheStatistics {
    public let totalEntries: Int
    public let totalSize: Int64
    public let averageEntrySize: Int64
    public let entriesByAge: [String: Int]
    public let hitRate: Double
    public let storageEfficiency: Double
}

/// Cache storage backend
private class CacheStorage {
    private let directory: URL
    private let fileManager = FileManager.default

    init(directory: URL) throws {
        self.directory = directory
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func storeArtifacts(_ artifacts: [BuildArtifact], forKey key: CacheKey) throws {
        let entryDirectory = directory.appendingPathComponent(key.inputHash)
        try fileManager.createDirectory(at: entryDirectory, withIntermediateDirectories: true)

        // Copy artifacts to cache directory
        for artifact in artifacts {
            let destinationURL = entryDirectory.appendingPathComponent(artifact.name)
            try fileManager.copyItem(at: URL(fileURLWithPath: artifact.path), to: destinationURL)
        }

        // Store metadata
        let metadataURL = entryDirectory.appendingPathComponent("metadata.json")
        let metadata = CacheMetadata(artifacts: artifacts, key: key)
        let encoder = JSONEncoder()
        let data = try encoder.encode(metadata)
        try data.write(to: metadataURL)
    }

    func retrieveArtifacts(forKey key: CacheKey) throws -> [BuildArtifact] {
        let entryDirectory = directory.appendingPathComponent(key.inputHash)
        let metadataURL = entryDirectory.appendingPathComponent("metadata.json")

        let data = try Data(contentsOf: metadataURL)
        let decoder = JSONDecoder()
        let metadata = try decoder.decode(CacheMetadata.self, from: data)

        return metadata.artifacts
    }

    func removeArtifacts(forKey key: CacheKey) throws {
        let entryDirectory = directory.appendingPathComponent(key.inputHash)
        try fileManager.removeItem(at: entryDirectory)
    }

    func clear() throws {
        let contents = try fileManager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil
        )
        for item in contents {
            try fileManager.removeItem(at: item)
        }
    }
}

/// Cache metadata for storage
private struct CacheMetadata: Codable {
    let artifacts: [BuildArtifact]
    let key: CacheKey
}

/// Dependency tracker for cache invalidation
private class DependencyTracker {
    private var keyDependencies: [CacheKey: Set<String>] = [:]
    private var reverseDependencies: [String: Set<CacheKey>] = [:]

    func addDependencies(for key: CacheKey, dependencies: [String]) {
        keyDependencies[key] = Set(dependencies)

        for dependency in dependencies {
            if reverseDependencies[dependency] == nil {
                reverseDependencies[dependency] = []
            }
            reverseDependencies[dependency]?.insert(key)
        }
    }

    func removeDependencies(for key: CacheKey) {
        if let dependencies = keyDependencies.removeValue(forKey: key) {
            for dependency in dependencies {
                reverseDependencies[dependency]?.remove(key)
            }
        }
    }

    func getAffectedKeys(forChanges changes: [String]) -> Set<CacheKey> {
        var affectedKeys = Set<CacheKey>()

        for change in changes {
            if let keys = reverseDependencies[change] {
                affectedKeys.formUnion(keys)
            }
        }

        return affectedKeys
    }

    func clear() {
        keyDependencies.removeAll()
        reverseDependencies.removeAll()
    }
}

// MARK: - Extensions

extension CacheStatistics: CustomStringConvertible {
    public var description: String {
        """
        Cache Statistics:
        - Total Entries: \(totalEntries)
        - Total Size: \(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))
        - Average Entry Size: \(ByteCountFormatter.string(fromByteCount: averageEntrySize, countStyle: .file))
        - Hit Rate: \(String(format: "%.1f%%", hitRate * 100))
        - Storage Efficiency: \(String(format: "%.1f%%", storageEfficiency * 100))
        - Entries by Age: \(entriesByAge)
        """
    }
}

extension CacheKey: CustomStringConvertible {
    public var description: String {
        "CacheKey(input: \(inputHash.prefix(8))..., deps: \(dependencyHash.prefix(8))...)"
    }
}
