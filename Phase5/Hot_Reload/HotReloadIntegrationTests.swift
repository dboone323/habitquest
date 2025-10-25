//
//  HotReloadIntegrationTests.swift
//  Hot Reload System Integration Tests
//
//  Comprehensive integration tests for the hot reload system
//  covering all components and real-world scenarios.
//

import Combine
import XCTest

@testable import HotReload

@available(macOS 12.0, *)
final class HotReloadIntegrationTests: XCTestCase {

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private var tempDirectory: URL!
    private var testFiles: [URL] = []

    private var hotReloadEngine: HotReloadEngine!
    private var incrementalCompiler: IncrementalCompiler!
    private var runtimePatcher: RuntimePatcher!
    private var statePreserver: StatePreserver!
    private var reloadCoordinator: ReloadCoordinator!
    private var errorHandler: ErrorHandler!
    private var fileWatcher: FileWatcher!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary directory for tests
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HotReloadTests")
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(
            at: tempDirectory, withIntermediateDirectories: true
        )

        // Initialize components
        await setupComponents()
        await createTestFiles()
    }

    override func tearDown() async throws {
        // Clean up
        fileWatcher?.stopWatching()
        try? FileManager.default.removeItem(at: tempDirectory)

        cancellables.removeAll()
        testFiles.removeAll()

        await super.tearDown()
    }

    // MARK: - Test Setup

    private func setupComponents() async {
        let engineConfig = HotReloadEngine.Configuration()
        hotReloadEngine = HotReloadEngine(configuration: engineConfig)

        let compilerConfig = IncrementalCompiler.Configuration()
        incrementalCompiler = IncrementalCompiler(configuration: compilerConfig)

        let patcherConfig = RuntimePatcher.Configuration()
        runtimePatcher = RuntimePatcher(configuration: patcherConfig)

        let preserverConfig = StatePreserver.Configuration()
        statePreserver = StatePreserver(configuration: preserverConfig)

        let coordinatorConfig = ReloadCoordinator.Configuration()
        reloadCoordinator = ReloadCoordinator(configuration: coordinatorConfig)

        let errorConfig = ErrorHandler.Configuration()
        errorHandler = ErrorHandler(configuration: errorConfig)

        let watcherConfig = FileWatcher.Configuration()
        fileWatcher = FileWatcher(configuration: watcherConfig)
    }

    private func createTestFiles() async throws {
        // Create test Swift files
        let testClassURL = tempDirectory.appendingPathComponent("TestClass.swift")
        let testClassContent = """
        import Foundation

        @objc public class TestClass: NSObject {
            @objc public var name: String = "Test"

            @objc public func greet() -> String {
                return "Hello, \\(name)!"
            }

            @objc public func calculate(_ a: Int, _ b: Int) -> Int {
                return a + b
            }
        }
        """
        try testClassContent.write(to: testClassURL, atomically: true, encoding: .utf8)
        testFiles.append(testClassURL)

        let viewModelURL = tempDirectory.appendingPathComponent("TestViewModel.swift")
        let viewModelContent = """
        import Foundation
        import Combine

        @MainActor
        public class TestViewModel: ObservableObject {
            @Published public var count: Int = 0
            @Published public var message: String = "Initial"

            public func increment() {
                count += 1
                message = "Count: \\(count)"
            }

            public func reset() {
                count = 0
                message = "Reset"
            }
        }
        """
        try viewModelContent.write(to: viewModelURL, atomically: true, encoding: .utf8)
        testFiles.append(viewModelURL)
    }

    // MARK: - Integration Tests

    func testFullHotReloadCycle() async throws {
        // Test a complete hot reload cycle from file change to runtime update

        // 1. Start file watching
        try fileWatcher.startWatching(directory: tempDirectory)

        // 2. Set up expectation for file change detection
        let changeExpectation = expectation(description: "File change detected")
        var detectedChanges: [FileChange] = []

        fileWatcher.fileChanges
            .sink { change in
                detectedChanges.append(change)
                if detectedChanges.count >= 2 { // Expect changes for both files
                    changeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // 3. Modify test files to trigger reload
        try await modifyTestFiles()

        // 4. Wait for file changes to be detected
        await fulfillment(of: [changeExpectation], timeout: 5.0)

        XCTAssertEqual(detectedChanges.count, 2)

        // 5. Test incremental compilation
        let compileResult = try await incrementalCompiler.compile(files: testFiles)
        XCTAssertTrue(compileResult.success)

        // 6. Test state preservation
        let testViewModel = TestViewModel()
        testViewModel.count = 5
        testViewModel.message = "Modified"

        let stateId = try await statePreserver.captureState(for: testViewModel)
        XCTAssertNotNil(stateId)

        // 7. Test runtime patching
        let patchResult = try await runtimePatcher.applyPatches(from: compileResult)
        XCTAssertTrue(patchResult.success)

        // 8. Test reload coordination
        let reloadRequest = ReloadRequest(
            files: testFiles,
            priority: .high,
            context: "Integration test reload"
        )

        let session = try await reloadCoordinator.requestReload(reloadRequest)
        try await reloadCoordinator.startReload(session)

        // Simulate successful reload
        await reloadCoordinator.completeReload(session, result: .success(compileResult))

        // 9. Verify state restoration
        try await statePreserver.restoreState(stateId, for: testViewModel)
        XCTAssertEqual(testViewModel.count, 5)
        XCTAssertEqual(testViewModel.message, "Modified")

        // 10. Check reload statistics
        let stats = reloadCoordinator.getReloadStatistics()
        XCTAssertEqual(stats.successfulReloads, 1)
        XCTAssertGreaterThan(stats.successRate, 0)
    }

    func testErrorHandlingAndRecovery() async throws {
        // Test error handling and recovery mechanisms

        // 1. Create a file with syntax errors
        let errorFileURL = tempDirectory.appendingPathComponent("ErrorFile.swift")
        let errorContent = """
        import Foundation

        public class ErrorClass {
            public func brokenMethod() {
                // Missing closing brace and syntax error
                return "broken"
        """
        try errorContent.write(to: errorFileURL, atomically: true, encoding: .utf8)

        // 2. Attempt compilation (should fail)
        let compileResult = try await incrementalCompiler.compile(files: [errorFileURL])
        XCTAssertFalse(compileResult.success)
        XCTAssertNotNil(compileResult.errors)

        // 3. Test error handling
        let errorContext = ErrorContext(
            file: errorFileURL.path,
            line: 5,
            function: "brokenMethod()",
            description: "Syntax error in test file"
        )

        let handlingResult = await errorHandler.handleError(
            CompilationError.syntaxError("Missing closing brace"),
            context: errorContext
        )

        switch handlingResult {
        case .unhandled:
            // Expected for syntax errors that can't be auto-fixed
            break
        case .recovered:
            XCTFail("Syntax errors should not be auto-recovered")
        }

        // 4. Check error statistics
        let stats = errorHandler.getErrorStatistics()
        XCTAssertEqual(stats.totalErrors, 1)
        XCTAssertEqual(stats.unhandledErrors, 1)

        // 5. Test error history
        let history = errorHandler.getErrorHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.context.file, errorFileURL.path)
    }

    func testConcurrentReloads() async throws {
        // Test handling multiple concurrent reload requests

        // 1. Create multiple reload requests
        let requests = (0 ..< 5).map { index in
            ReloadRequest(
                files: [testFiles[index % testFiles.count]],
                priority: index % 2 == 0 ? .high : .normal,
                context: "Concurrent test \(index)"
            )
        }

        // 2. Submit all requests concurrently
        async let sessions = try await withThrowingTaskGroup(of: ReloadSession.self) { group in
            for request in requests {
                group.addTask {
                    try await self.reloadCoordinator.requestReload(request)
                }
            }

            var results: [ReloadSession] = []
            for try await session in group {
                results.append(session)
            }
            return results
        }

        let sessionResults = try await sessions
        XCTAssertEqual(sessionResults.count, 5)

        // 3. Verify queuing behavior (only one should be active initially)
        let activeReloads = reloadCoordinator.getActiveReloads()
        XCTAssertEqual(activeReloads.count, 1) // Max concurrent is 1

        // 4. Complete the active reload and check queue processing
        let firstSession = activeReloads.first!
        await reloadCoordinator.completeReload(
            firstSession, result: .success(CompilationResult(success: true))
        )

        // Should now have another active reload
        let newActive = reloadCoordinator.getActiveReloads()
        XCTAssertEqual(newActive.count, 1)
        XCTAssertNotEqual(newActive.first?.id, firstSession.id)
    }

    func testStatePreservationWithComplexObjects() async throws {
        // Test state preservation with complex nested objects

        // 1. Create complex test object
        let complexObject = ComplexTestObject()
        complexObject.configure()

        // 2. Capture state
        let stateId = try await statePreserver.captureState(for: complexObject)

        // 3. Modify object
        complexObject.counter = 42
        complexObject.data.append("modified")
        complexObject.nested.value = 99.5

        // 4. Restore state
        try await statePreserver.restoreState(stateId, for: complexObject)

        // 5. Verify restoration
        XCTAssertEqual(complexObject.counter, 0) // Should be restored to initial value
        XCTAssertEqual(complexObject.data, ["initial"])
        XCTAssertEqual(complexObject.nested.value, 10.0)
    }

    func testFileWatchingWithFiltering() async throws {
        // Test file watching with pattern filtering

        // 1. Start watching
        try fileWatcher.startWatching(directory: tempDirectory)

        let changeExpectation = expectation(description: "Filtered file changes")
        var receivedChanges: [FileChange] = []

        fileWatcher.fileChanges
            .sink { change in
                receivedChanges.append(change)
                if receivedChanges.count >= 2 {
                    changeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // 2. Create files that should and shouldn't be watched
        let swiftFile = tempDirectory.appendingPathComponent("WatchedFile.swift")
        try "public func test() {}".write(to: swiftFile, atomically: true, encoding: .utf8)

        let ignoredFile = tempDirectory.appendingPathComponent("ignored.tmp")
        try "ignored content".write(to: ignoredFile, atomically: true, encoding: .utf8)

        // 3. Wait for changes
        await fulfillment(of: [changeExpectation], timeout: 3.0)

        // 4. Verify only Swift files were watched
        XCTAssertTrue(
            receivedChanges.contains { $0.fileURL.lastPathComponent == "WatchedFile.swift" })
        XCTAssertFalse(receivedChanges.contains { $0.fileURL.lastPathComponent == "ignored.tmp" })
    }

    func testReloadHistoryAndStatistics() async throws {
        // Test reload history tracking and statistics

        let request = ReloadRequest(
            files: testFiles,
            priority: .normal,
            context: "Statistics test"
        )

        // Perform multiple reloads
        for i in 0 ..< 3 {
            let session = try await reloadCoordinator.requestReload(request)
            try await reloadCoordinator.startReload(session)

            // Alternate between success and failure
            if i % 2 == 0 {
                await reloadCoordinator.completeReload(
                    session, result: .success(CompilationResult(success: true))
                )
            } else {
                await reloadCoordinator.failReload(
                    session, error: CompilationError.unknown("Test error")
                )
            }
        }

        // Check statistics
        let stats = reloadCoordinator.getReloadStatistics()
        XCTAssertEqual(stats.totalReloads, 3)
        XCTAssertEqual(stats.successfulReloads, 2)
        XCTAssertEqual(stats.failedReloads, 1)
        XCTAssertEqual(stats.successRate, 2.0 / 3.0)

        // Check history
        let history = reloadCoordinator.getReloadHistory()
        XCTAssertEqual(history.count, 3)

        // Verify chronological order (newest first)
        XCTAssertGreaterThanOrEqual(history[0].timestamp, history[1].timestamp)
        XCTAssertGreaterThanOrEqual(history[1].timestamp, history[2].timestamp)
    }

    // MARK: - Helper Methods

    private func modifyTestFiles() async throws {
        // Modify the test class
        let testClassURL = testFiles[0]
        var content = try String(contentsOf: testClassURL)
        content = content.replacingOccurrences(of: "return a + b", with: "return a * b")
        try content.write(to: testClassURL, atomically: true, encoding: .utf8)

        // Modify the view model
        let viewModelURL = testFiles[1]
        content = try String(contentsOf: viewModelURL)
        content = content.replacingOccurrences(of: "Initial", with: "Updated")
        try content.write(to: viewModelURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Test Helper Classes

// Mock compilation result
private struct CompilationResult {
    let success: Bool
    let errors: [Error]?
    let outputURL: URL?

    init(success: Bool, errors: [Error]? = nil, outputURL: URL? = nil) {
        self.success = success
        self.errors = errors
        self.outputURL = outputURL
    }
}

// Mock compilation error
private enum CompilationError: Error {
    case syntaxError(String)
    case unknown(String)
}

// Complex test object for state preservation testing
@MainActor
private class ComplexTestObject: ObservableObject {
    @Published var counter: Int = 0
    @Published var data: [String] = []
    @Published var nested: NestedObject = .init()

    func configure() {
        counter = 0
        data = ["initial"]
        nested.value = 10.0
    }
}

@MainActor
private class NestedObject: ObservableObject {
    @Published var value: Double = 0.0
}

// MARK: - Usage Examples

/// Example usage of the Hot Reload System
@available(macOS 12.0, *)
public class HotReloadUsageExample {

    private var hotReloadEngine: HotReloadEngine!
    private var fileWatcher: FileWatcher!
    private var cancellables = Set<AnyCancellable>()

    public init() {
        setupHotReload()
    }

    private func setupHotReload() {
        // Configure components
        let engineConfig = HotReloadEngine.Configuration(
            enableLogging: true,
            maxConcurrentReloads: 2
        )
        hotReloadEngine = HotReloadEngine(configuration: engineConfig)

        let watcherConfig = FileWatcher.Configuration(
            debounceInterval: 0.3,
            watchedExtensions: ["swift", "h", "m"]
        )
        fileWatcher = FileWatcher(configuration: watcherConfig)

        // Set up file watching
        do {
            try fileWatcher.startWatching(directory: URL(fileURLWithPath: "./Sources"))
        } catch {
            print("Failed to start file watching: \(error)")
            return
        }

        // Connect file changes to hot reload
        fileWatcher.fileChanges
            .filter { $0.changeType == .modified }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] change in
                self?.handleFileChange(change)
            }
            .store(in: &cancellables)

        // Monitor reload status
        hotReloadEngine.reloadStatus
            .sink { status in
                print("Reload status: \(status)")
            }
            .store(in: &cancellables)
    }

    private func handleFileChange(_ change: FileChange) {
        Task {
            do {
                try await hotReloadEngine.reload(files: [change.fileURL])
                print("Successfully reloaded \(change.fileURL.lastPathComponent)")
            } catch {
                print("Failed to reload \(change.fileURL.lastPathComponent): \(error)")
            }
        }
    }

    /// Example of preserving application state during reload
    public func demonstrateStatePreservation() async {
        // Create a view model
        let viewModel = TestViewModel()
        viewModel.count = 10
        viewModel.message = "Before reload"

        // Capture state before reload
        do {
            let stateId = try await hotReloadEngine.captureApplicationState()

            // Simulate reload
            try await hotReloadEngine.reload(files: [])

            // Restore state after reload
            try await hotReloadEngine.restoreApplicationState(stateId)

            // Verify state is preserved
            XCTAssertEqual(viewModel.count, 10)
            XCTAssertEqual(viewModel.message, "Before reload")

        } catch {
            print("State preservation failed: \(error)")
        }
    }

    /// Example of handling reload errors
    public func demonstrateErrorHandling() async {
        do {
            try await hotReloadEngine.reload(files: [])
        } catch let error as HotReloadError {
            switch error {
            case let .compilationFailed(errors):
                print("Compilation failed with \(errors.count) errors")
            // Show errors to user or attempt recovery
            case let .patchingFailed(reason):
                print("Runtime patching failed: \(reason)")
            // Fallback to full restart
            case .statePreservationFailed:
                print("State preservation failed")
                // Continue without state preservation
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

// MARK: - Performance Tests

@available(macOS 12.0, *)
final class HotReloadPerformanceTests: XCTestCase {

    func testReloadPerformance() async throws {
        // Measure reload performance under load

        let engine = HotReloadEngine()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("PerfTest")

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        // Create multiple test files
        var testFiles: [URL] = []
        for i in 0 ..< 10 {
            let fileURL = tempDir.appendingPathComponent("Test\(i).swift")
            let content = """
            public class Test\(i) {
                public func method() -> Int { return \(i) }
            }
            """
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            testFiles.append(fileURL)
        }

        // Measure reload time
        let startTime = Date()
        try await engine.reload(files: testFiles)
        let duration = Date().timeIntervalSince(startTime)

        // Assert reasonable performance (should complete within 5 seconds)
        XCTAssertLessThan(duration, 5.0, "Reload took too long: \(duration) seconds")
    }

    func testConcurrentReloadPerformance() async throws {
        // Test performance with concurrent reload requests

        let coordinator = ReloadCoordinator()

        let requests = (0 ..< 5).map { index in
            ReloadRequest(
                files: [URL(fileURLWithPath: "/tmp/test\(index).swift")],
                priority: .normal,
                context: "Performance test \(index)"
            )
        }

        let startTime = Date()

        // Submit all requests concurrently
        async let sessions = try await withThrowingTaskGroup(of: ReloadSession.self) { group in
            for request in requests {
                group.addTask {
                    try await coordinator.requestReload(request)
                }
            }

            var results: [ReloadSession] = []
            for try await session in group {
                results.append(session)
            }
            return results
        }

        _ = try await sessions
        let duration = Date().timeIntervalSince(startTime)

        // Should handle concurrent requests efficiently
        XCTAssertLessThan(duration, 2.0, "Concurrent requests took too long: \(duration) seconds")
    }
}
