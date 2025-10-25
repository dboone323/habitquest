//
//  IncrementalCompiler.swift
//  Hot Reload System
//
//  Handles incremental compilation of Swift code changes for hot reloading.
//  Manages dependency tracking and selective recompilation.
//

import Foundation

/// Incremental compiler for Swift code changes
@available(macOS 12.0, *)
public class IncrementalCompiler {

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let processQueue = DispatchQueue(label: "com.quantum.incremental-compiler", qos: .userInitiated)

    private var dependencyGraph: DependencyGraph
    private var compilationCache: CompilationCache
    private var buildSettings: BuildSettings

    private var isCompiling = false
    private var forceFullRebuildFlag = false

    /// Publisher for compilation progress
    public let compilationProgress = PassthroughSubject<Void, Never>()

    // MARK: - Initialization

    public init() throws {
        self.dependencyGraph = DependencyGraph()
        self.compilationCache = CompilationCache()
        self.buildSettings = try BuildSettings.detect()

        setupDependencyTracking()
    }

    // MARK: - Public API

    /// Compile the specified files incrementally
    public func compile(files: [URL]) async throws -> CompilationResult {
        guard !isCompiling else {
            throw CompilationError.concurrentCompilation
        }

        isCompiling = true
        defer { isCompiling = false }

        compilationProgress.send()

        do {
            let startTime = Date()

            // Determine what needs to be compiled
            let filesToCompile = try await determineFilesToCompile(files)

            guard !filesToCompile.isEmpty else {
                return CompilationResult(compilationTime: Date().timeIntervalSince(startTime))
            }

            // Perform incremental compilation
            let result = try await performIncrementalCompilation(filesToCompile)

            let compilationTime = Date().timeIntervalSince(startTime)

            // Update dependency graph and cache
            await updateDependenciesAndCache(for: result)

            return CompilationResult(
                compiledFiles: result.compiledFiles,
                objectFiles: result.objectFiles,
                compilationTime: compilationTime,
                warnings: result.warnings,
                errors: result.errors
            )

        } catch {
            throw CompilationError.compilationFailed(error.localizedDescription)
        }
    }

    /// Force the next compilation to be a full rebuild
    public func forceFullRebuild() {
        forceFullRebuildFlag = true
    }

    /// Clear all cached compilation data
    public func clearCache() {
        compilationCache.clear()
        dependencyGraph.clear()
        forceFullRebuildFlag = true
    }

    /// Get dependency information for a file
    public func getDependencies(for file: URL) -> [URL] {
        dependencyGraph.getDependencies(for: file)
    }

    /// Check if a file needs recompilation
    public func needsRecompilation(_ file: URL) -> Bool {
        guard let cachedInfo = compilationCache.getInfo(for: file) else {
            return true // Never compiled
        }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: file.path)
            let modificationDate = attributes[.modificationDate] as? Date ?? Date.distantPast

            return modificationDate > cachedInfo.compilationDate
        } catch {
            return true // Can't check modification date, assume needs recompilation
        }
    }

    // MARK: - Private Methods

    private func determineFilesToCompile(_ changedFiles: [URL]) async throws -> [URL] {
        if forceFullRebuildFlag {
            forceFullRebuildFlag = false
            return try findAllSwiftFiles()
        }

        var filesToCompile = Set(changedFiles)

        // Add dependent files that need recompilation
        for changedFile in changedFiles {
            let dependents = dependencyGraph.getDependents(of: changedFile)
            filesToCompile.formUnion(dependents)
        }

        // Filter to only files that actually need recompilation
        let filteredFiles = filesToCompile.filter { needsRecompilation($0) }

        return Array(filteredFiles)
    }

    private func performIncrementalCompilation(_ files: [URL]) async throws -> IncrementalCompilationResult {
        let tempDir = try createTempDirectory()
        defer { try? fileManager.removeItem(at: tempDir) }

        // Prepare compilation arguments
        let arguments = try buildCompilationArguments(for: files, tempDir: tempDir)

        // Execute compilation
        let result = try await executeCompilation(arguments: arguments)

        return result
    }

    private func buildCompilationArguments(for files: [URL], tempDir: URL) throws -> [String] {
        var arguments = [
            "swiftc",
            "-incremental",
            "-emit-object",
            "-parse-as-library",
            "-target", buildSettings.target,
            "-sdk", buildSettings.sdkPath,
            "-I", buildSettings.includePath,
            "-L", buildSettings.libraryPath,
        ]

        // Add framework paths
        for framework in buildSettings.frameworks {
            arguments.append(contentsOf: ["-F", framework.path])
        }

        // Add module paths
        for modulePath in buildSettings.modulePaths {
            arguments.append(contentsOf: ["-I", modulePath.path])
        }

        // Add output directory
        arguments.append(contentsOf: ["-o", tempDir.appendingPathComponent("output.o").path])

        // Add source files
        arguments.append(contentsOf: files.map(\.path))

        return arguments
    }

    private func executeCompilation(arguments: [String]) async throws -> IncrementalCompilationResult {
        try await withCheckedThrowingContinuation { continuation in
            processQueue.async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                process.arguments = arguments

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                do {
                    try process.run()

                    // Read output asynchronously
                    var warnings: [String] = []
                    var errors: [String] = []

                    let outputHandle = outputPipe.fileHandleForReading
                    let errorHandle = errorPipe.fileHandleForReading

                    // Read error output
                    let errorData = errorHandle.readDataToEndOfFile()
                    if let errorString = String(data: errorData, encoding: .utf8) {
                        let lines = errorString.components(separatedBy: .newlines)
                        for line in lines where !line.isEmpty {
                            if line.contains("warning:") {
                                warnings.append(line)
                            } else if line.contains("error:") {
                                errors.append(line)
                            }
                        }
                    }

                    process.waitUntilExit()

                    if process.terminationStatus == 0 {
                        // Success - find generated object files
                        let tempDir = URL(fileURLWithPath: arguments[arguments.firstIndex(of: "-o")! + 1])
                            .deletingLastPathComponent()

                        let objectFiles = try self.findObjectFiles(in: tempDir)

                        continuation.resume(returning: IncrementalCompilationResult(
                            compiledFiles: [], // Will be filled by caller
                            objectFiles: objectFiles,
                            warnings: warnings,
                            errors: errors
                        ))
                    } else {
                        continuation.resume(throwing: CompilationError.compilationFailed(
                            "Compilation failed with exit code \(process.terminationStatus)"
                        ))
                    }

                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func updateDependenciesAndCache(for result: IncrementalCompilationResult) async {
        // Update compilation cache
        for file in result.compiledFiles {
            compilationCache.updateInfo(for: file, compilationDate: Date())
        }

        // Update dependency graph (simplified - would need AST parsing for full implementation)
        for file in result.compiledFiles {
            dependencyGraph.updateDependencies(for: file, dependencies: [])
        }
    }

    private func findAllSwiftFiles() throws -> [URL] {
        let workspaceURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        var swiftFiles: [URL] = []

        let enumerator = fileManager.enumerator(at: workspaceURL,
                                                includingPropertiesForKeys: [.isRegularFileKey],
                                                options: [.skipsHiddenFiles])

        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.pathExtension == "swift" {
                swiftFiles.append(fileURL)
            }
        }

        return swiftFiles
    }

    private func findObjectFiles(in directory: URL) throws -> [URL] {
        let contents = try fileManager.contentsOfDirectory(at: directory,
                                                           includingPropertiesForKeys: nil)
        return contents.filter { $0.pathExtension == "o" }
    }

    private func createTempDirectory() throws -> URL {
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("quantum-hot-reload")
            .appendingPathComponent(UUID().uuidString)

        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }

    private func setupDependencyTracking() {
        // Initialize dependency graph with existing files
        Task {
            do {
                let swiftFiles = try findAllSwiftFiles()
                for file in swiftFiles {
                    dependencyGraph.addFile(file)
                }
            } catch {
                print("Failed to setup dependency tracking: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

/// Compilation error types
public enum CompilationError: Error, LocalizedError {
    case concurrentCompilation
    case compilationFailed(String)
    case invalidArguments(String)
    case missingDependencies(String)

    public var errorDescription: String? {
        switch self {
        case .concurrentCompilation:
            return "Another compilation is already in progress"
        case let .compilationFailed(reason):
            return "Compilation failed: \(reason)"
        case let .invalidArguments(reason):
            return "Invalid compilation arguments: \(reason)"
        case let .missingDependencies(reason):
            return "Missing dependencies: \(reason)"
        }
    }
}

/// Result of incremental compilation
private struct IncrementalCompilationResult {
    let compiledFiles: [URL]
    let objectFiles: [URL]
    let warnings: [String]
    let errors: [String]
}

/// Build settings for compilation
private struct BuildSettings {
    let target: String
    let sdkPath: String
    let includePath: String
    let libraryPath: String
    let frameworks: [URL]
    let modulePaths: [URL]

    static func detect() throws -> BuildSettings {
        // Detect current Xcode/SDK settings
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["--show-sdk-path"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let sdkPath = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"

        return BuildSettings(
            target: "x86_64-apple-macosx12.0",
            sdkPath: sdkPath,
            includePath: "\(sdkPath)/usr/include",
            libraryPath: "\(sdkPath)/usr/lib",
            frameworks: [
                URL(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks"),
            ],
            modulePaths: [
                URL(fileURLWithPath: "\(sdkPath)/usr/lib/swift"),
            ]
        )
    }
}

/// Dependency graph for tracking file relationships
private class DependencyGraph {
    private var dependencies: [URL: Set<URL>] = [:]
    private var dependents: [URL: Set<URL>] = [:]
    private let queue = DispatchQueue(label: "com.quantum.dependency-graph", attributes: .concurrent)

    func addFile(_ file: URL) {
        queue.async(flags: .barrier) {
            self.dependencies[file] = []
            self.dependents[file] = []
        }
    }

    func updateDependencies(for file: URL, dependencies: [URL]) {
        queue.async(flags: .barrier) {
            self.dependencies[file] = Set(dependencies)

            // Update reverse dependencies
            for dep in dependencies {
                self.dependents[dep, default: []].insert(file)
            }
        }
    }

    func getDependencies(for file: URL) -> [URL] {
        queue.sync {
            Array(self.dependencies[file] ?? [])
        }
    }

    func getDependents(of file: URL) -> [URL] {
        queue.sync {
            Array(self.dependents[file] ?? [])
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.dependencies.removeAll()
            self.dependents.removeAll()
        }
    }
}

/// Compilation cache for tracking file compilation status
private class CompilationCache {
    private var cache: [URL: CompilationInfo] = [:]
    private let queue = DispatchQueue(label: "com.quantum.compilation-cache", attributes: .concurrent)

    struct CompilationInfo {
        let compilationDate: Date
        let hash: String
    }

    func getInfo(for file: URL) -> CompilationInfo? {
        queue.sync {
            cache[file]
        }
    }

    func updateInfo(for file: URL, compilationDate: Date) {
        // Calculate file hash (simplified)
        let hash = "\(file.path.hashValue)_\(compilationDate.timeIntervalSince1970)"

        queue.async(flags: .barrier) {
            self.cache[file] = CompilationInfo(compilationDate: compilationDate, hash: hash)
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
