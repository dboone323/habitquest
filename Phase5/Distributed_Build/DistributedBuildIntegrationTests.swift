//
//  DistributedBuildIntegrationTests.swift
//  Distributed Build System Tests
//
//  Integration tests for the distributed build system,
//  testing coordination between all components.
//

import Foundation
import XCTest

@testable import DistributedBuild

@available(macOS 12.0, *)
final class DistributedBuildIntegrationTests: XCTestCase {

    // MARK: - Properties

    private var coordinator: DistributedBuildCoordinator!
    private var nodeManager: BuildNodeManager!
    private var taskScheduler: TaskScheduler!
    private var buildCache: BuildCache!
    private var networkCommunicator: NetworkCommunicator!

    private var testDirectory: URL!
    private var cacheDirectory: URL!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Create test directories
        testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "DistributedBuildTests_\(UUID().uuidString)")
        cacheDirectory = testDirectory.appendingPathComponent("Cache")

        try FileManager.default.createDirectory(
            at: testDirectory, withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true
        )

        // Initialize components
        let cacheConfig = BuildCache.Configuration(cacheDirectory: cacheDirectory)
        buildCache = try BuildCache(configuration: cacheConfig)

        nodeManager = BuildNodeManager()
        taskScheduler = TaskScheduler()
        networkCommunicator = NetworkCommunicator()

        coordinator = DistributedBuildCoordinator(
            nodeManager: nodeManager,
            taskScheduler: taskScheduler,
            buildCache: buildCache,
            networkCommunicator: networkCommunicator
        )

        // Register local node
        let localNode = BuildNode(
            id: UUID(),
            name: "TestNode",
            host: "localhost",
            capabilities: ["swift", "xcodebuild", "test"],
            maxConcurrentTasks: 4,
            status: .idle
        )
        try await nodeManager.registerNode(localNode)
    }

    override func tearDown() async throws {
        // Clean up
        coordinator = nil
        nodeManager = nil
        taskScheduler = nil
        buildCache = nil
        networkCommunicator = nil

        try? FileManager.default.removeItem(at: testDirectory)
        try await super.tearDown()
    }

    // MARK: - Integration Tests

    func testDistributedBuildWorkflow() async throws {
        // Create test project structure
        let projectURL = testDirectory.appendingPathComponent("TestProject")
        try createTestProject(at: projectURL)

        // Create build request
        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "TestProject",
            configuration: "Debug",
            platform: "macOS",
            dependencies: []
        )

        // Submit build
        let sessionId = try await coordinator.submitBuild(buildRequest)

        // Wait for build completion
        let result = try await waitForBuildCompletion(sessionId, timeout: 60.0)

        // Verify build result
        XCTAssertTrue(result.success, "Build should succeed")
        XCTAssertNotNil(result.artifacts, "Build should produce artifacts")
        XCTAssertGreaterThan(result.artifacts?.count ?? 0, 0, "Should have build artifacts")

        // Verify cache was populated
        let cachedArtifacts = try buildCache.retrieve(for: result.tasks.first!, dependencies: [])
        XCTAssertNotNil(cachedArtifacts, "Build artifacts should be cached")
    }

    func testCacheReuseAcrossBuilds() async throws {
        // Create test project
        let projectURL = testDirectory.appendingPathComponent("CachedProject")
        try createTestProject(at: projectURL)

        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "CachedProject",
            configuration: "Debug",
            platform: "macOS",
            dependencies: []
        )

        // First build
        let sessionId1 = try await coordinator.submitBuild(buildRequest)
        let result1 = try await waitForBuildCompletion(sessionId1, timeout: 60.0)
        XCTAssertTrue(result1.success)

        // Modify a dependency file to trigger cache invalidation
        let dependencyFile = projectURL.appendingPathComponent("Package.swift")
        let newContent = try String(contentsOf: dependencyFile) + "\n// Modified"
        try newContent.write(to: dependencyFile, atomically: true, encoding: .utf8)

        // Second build (should not use cache due to dependency change)
        let sessionId2 = try await coordinator.submitBuild(buildRequest)
        let result2 = try await waitForBuildCompletion(sessionId2, timeout: 60.0)
        XCTAssertTrue(result2.success)

        // Verify cache invalidation worked
        let cachedArtifacts = try buildCache.retrieve(
            for: result2.tasks.first!, dependencies: ["Package.swift"]
        )
        XCTAssertNil(cachedArtifacts, "Cache should be invalidated due to dependency change")
    }

    func testMultiNodeTaskDistribution() async throws {
        // Register additional test nodes
        for i in 1 ... 3 {
            let node = BuildNode(
                id: UUID(),
                name: "TestNode\(i)",
                host: "node\(i).local",
                capabilities: ["swift", "xcodebuild"],
                maxConcurrentTasks: 2,
                status: .idle
            )
            try await nodeManager.registerNode(node)
        }

        // Create project with multiple build tasks
        let projectURL = testDirectory.appendingPathComponent("MultiTaskProject")
        try createMultiTaskProject(at: projectURL)

        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "MultiTaskProject",
            configuration: "Debug",
            platform: "macOS",
            dependencies: []
        )

        // Submit build
        let sessionId = try await coordinator.submitBuild(buildRequest)
        let result = try await waitForBuildCompletion(sessionId, timeout: 120.0)

        XCTAssertTrue(result.success)

        // Verify tasks were distributed across nodes
        let taskAssignments =
            try await coordinator.getBuildSession(sessionId)?.taskAssignments ?? []
        let uniqueNodes = Set(taskAssignments.map(\.nodeId))
        XCTAssertGreaterThan(
            uniqueNodes.count, 1, "Tasks should be distributed across multiple nodes"
        )
    }

    func testBuildFailureHandling() async throws {
        // Create project with intentional build failure
        let projectURL = testDirectory.appendingPathComponent("FailingProject")
        try createFailingProject(at: projectURL)

        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "FailingProject",
            configuration: "Debug",
            platform: "macOS",
            dependencies: []
        )

        // Submit build
        let sessionId = try await coordinator.submitBuild(buildRequest)
        let result = try await waitForBuildCompletion(sessionId, timeout: 60.0)

        // Verify build failed as expected
        XCTAssertFalse(result.success, "Build should fail")
        XCTAssertNotNil(result.error, "Should have error information")
        XCTAssertTrue(
            result.error?.contains("Build failed") ?? false, "Error should indicate build failure"
        )
    }

    func testLoadBalancing() async throws {
        // Register nodes with different capacities
        let highCapacityNode = BuildNode(
            id: UUID(),
            name: "HighCapacityNode",
            host: "high.local",
            capabilities: ["swift", "xcodebuild", "test"],
            maxConcurrentTasks: 8,
            status: .idle
        )

        let lowCapacityNode = BuildNode(
            id: UUID(),
            name: "LowCapacityNode",
            host: "low.local",
            capabilities: ["swift"],
            maxConcurrentTasks: 1,
            status: .idle
        )

        try await nodeManager.registerNode(highCapacityNode)
        try await nodeManager.registerNode(lowCapacityNode)

        // Create project with many parallel tasks
        let projectURL = testDirectory.appendingPathComponent("LoadTestProject")
        try createLoadTestProject(at: projectURL)

        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "LoadTestProject",
            configuration: "Debug",
            platform: "macOS",
            dependencies: []
        )

        // Submit build
        let sessionId = try await coordinator.submitBuild(buildRequest)
        let result = try await waitForBuildCompletion(sessionId, timeout: 180.0)

        XCTAssertTrue(result.success)

        // Verify load balancing - high capacity node should get more tasks
        let taskAssignments =
            try await coordinator.getBuildSession(sessionId)?.taskAssignments ?? []
        let highCapacityTasks = taskAssignments.filter { $0.nodeId == highCapacityNode.id }.count
        let lowCapacityTasks = taskAssignments.filter { $0.nodeId == lowCapacityNode.id }.count

        XCTAssertGreaterThan(
            highCapacityTasks, lowCapacityTasks, "High capacity node should get more tasks"
        )
    }

    func testNetworkCommunication() async throws {
        // Start network communicator
        try await networkCommunicator.start()

        // Test message sending
        let testMessage = NetworkMessage(
            type: .nodeStatus,
            payload: NodeStatusPayload(
                nodeId: UUID(),
                status: .idle,
                capabilities: ["swift", "test"]
            )
        )

        // Register message handler
        let expectation = XCTestExpectation(description: "Message received")
        networkCommunicator.registerHandler(for: .nodeStatus) { message in
            if let payload = message.payload as? NodeStatusPayload {
                XCTAssertEqual(payload.status, .idle)
                expectation.fulfill()
            }
        }

        // Send message to self (for testing)
        try await networkCommunicator.broadcastMessage(testMessage)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testCacheSynchronization() async throws {
        // Create mock remote cache
        let remoteCacheConfig = BuildCache.Configuration(
            cacheDirectory: cacheDirectory.appendingPathComponent("Remote")
        )
        let remoteCache = try BuildCache(configuration: remoteCacheConfig)

        // Store artifact in local cache
        let testArtifact = BuildArtifact(
            name: "test.o",
            path: testDirectory.appendingPathComponent("test.o").path,
            type: .object
        )
        try "test".write(
            to: URL(fileURLWithPath: testArtifact.path), atomically: true, encoding: .utf8
        )

        let testTask = BuildTask(
            id: UUID(),
            type: .compile,
            files: ["test.swift"],
            dependencies: [],
            priority: .normal
        )

        try await buildCache.store([testArtifact], for: testTask, dependencies: [])

        // Synchronize caches
        try await buildCache.synchronizeWithRemote(remoteCache)

        // Verify synchronization (this would be more comprehensive in real implementation)
        let stats = buildCache.getCacheStatistics()
        XCTAssertGreaterThan(stats.totalEntries, 0, "Cache should have entries after sync")
    }

    // MARK: - Performance Tests

    func testBuildPerformance() async throws {
        let projectURL = testDirectory.appendingPathComponent("PerfTestProject")
        try createPerformanceTestProject(at: projectURL)

        let buildRequest = BuildRequest(
            id: UUID(),
            projectPath: projectURL.path,
            target: "PerfTestProject",
            configuration: "Release",
            platform: "macOS",
            dependencies: []
        )

        let startTime = Date()

        // Submit build
        let sessionId = try await coordinator.submitBuild(buildRequest)
        let result = try await waitForBuildCompletion(sessionId, timeout: 300.0)

        let endTime = Date()
        let buildDuration = endTime.timeIntervalSince(startTime)

        XCTAssertTrue(result.success)
        XCTAssertLessThan(buildDuration, 120.0, "Build should complete within 2 minutes")

        // Log performance metrics
        print("Build completed in \(String(format: "%.2f", buildDuration)) seconds")
    }

    // MARK: - Helper Methods

    private func waitForBuildCompletion(_ sessionId: UUID, timeout: TimeInterval) async throws
        -> BuildResult
    {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if let session = try await coordinator.getBuildSession(sessionId) {
                if session.status == .completed || session.status == .failed {
                    return session.result!
                }
            }

            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }

        throw NSError(
            domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Build timeout"]
        )
    }

    private func createTestProject(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        // Create Package.swift
        let packageSwift = """
        // swift-tools-version:5.7
        import PackageDescription

        let package = Package(
            name: "TestProject",
            platforms: [.macOS(.v12)],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "TestProject",
                    dependencies: []
                )
            ]
        )
        """

        try packageSwift.write(
            to: url.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8
        )

        // Create main.swift
        let mainSwift = """
        import Foundation

        print("Hello, World!")
        """

        try mainSwift.write(
            to: url.appendingPathComponent("Sources/TestProject/main.swift"), atomically: true,
            encoding: .utf8
        )
    }

    private func createMultiTaskProject(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        // Create Package.swift with multiple targets
        let packageSwift = """
        // swift-tools-version:5.7
        import PackageDescription

        let package = Package(
            name: "MultiTaskProject",
            platforms: [.macOS(.v12)],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "MultiTaskProject",
                    dependencies: ["LibA", "LibB", "LibC"]
                ),
                .target(name: "LibA"),
                .target(name: "LibB"),
                .target(name: "LibC")
            ]
        )
        """

        try packageSwift.write(
            to: url.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8
        )

        // Create multiple source files
        for lib in ["LibA", "LibB", "LibC"] {
            let sourceDir = url.appendingPathComponent("Sources/\(lib)")
            try FileManager.default.createDirectory(
                at: sourceDir, withIntermediateDirectories: true
            )

            let sourceFile = """
            import Foundation

            public func \(lib.lowercased())Function() -> String {
                return "Hello from \(lib)"
            }
            """

            try sourceFile.write(
                to: sourceDir.appendingPathComponent("\(lib).swift"), atomically: true,
                encoding: .utf8
            )
        }

        // Create main
        let mainSwift = """
        import LibA
        import LibB
        import LibC

        print(LibA.libAFunction())
        print(LibB.libBFunction())
        print(LibC.libCFunction())
        """

        try mainSwift.write(
            to: url.appendingPathComponent("Sources/MultiTaskProject/main.swift"), atomically: true,
            encoding: .utf8
        )
    }

    private func createFailingProject(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let packageSwift = """
        // swift-tools-version:5.7
        import PackageDescription

        let package = Package(
            name: "FailingProject",
            platforms: [.macOS(.v12)],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "FailingProject",
                    dependencies: []
                )
            ]
        )
        """

        try packageSwift.write(
            to: url.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8
        )

        // Create main.swift with syntax error
        let mainSwift = """
        import Foundation

        print("This will fail"
        // Missing closing parenthesis
        """

        try mainSwift.write(
            to: url.appendingPathComponent("Sources/FailingProject/main.swift"), atomically: true,
            encoding: .utf8
        )
    }

    private func createLoadTestProject(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let packageSwift = """
        // swift-tools-version:5.7
        import PackageDescription

        let package = Package(
            name: "LoadTestProject",
            platforms: [.macOS(.v12)],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "LoadTestProject",
                    dependencies: (1...20).map { "Lib\($0)" }
                )
            ] + (1...20).map { .target(name: "Lib\($0)") }
        )
        """

        try packageSwift.write(
            to: url.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8
        )

        // Create 20 library targets
        for i in 1 ... 20 {
            let sourceDir = url.appendingPathComponent("Sources/Lib\(i)")
            try FileManager.default.createDirectory(
                at: sourceDir, withIntermediateDirectories: true
            )

            let sourceFile = """
            import Foundation

            public func lib\(i)Function() -> String {
                return "Library \(i)"
            }
            """

            try sourceFile.write(
                to: sourceDir.appendingPathComponent("Lib\(i).swift"), atomically: true,
                encoding: .utf8
            )
        }

        // Create main
        let imports = (1 ... 20).map { "import Lib\($0)" }.joined(separator: "\n")
        let calls = (1 ... 20).map { "print(Lib\($0).lib\($0)Function())" }.joined(separator: "\n")

        let mainSwift = """
        \(imports)

        \(calls)
        """

        try mainSwift.write(
            to: url.appendingPathComponent("Sources/LoadTestProject/main.swift"), atomically: true,
            encoding: .utf8
        )
    }

    private func createPerformanceTestProject(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let packageSwift = """
        // swift-tools-version:5.7
        import PackageDescription

        let package = Package(
            name: "PerfTestProject",
            platforms: [.macOS(.v12)],
            dependencies: [],
            targets: [
                .executableTarget(
                    name: "PerfTestProject",
                    dependencies: ["PerfLib"]
                ),
                .target(name: "PerfLib")
            ]
        )
        """

        try packageSwift.write(
            to: url.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8
        )

        // Create performance library with computationally intensive code
        let perfLibDir = url.appendingPathComponent("Sources/PerfLib")
        try FileManager.default.createDirectory(at: perfLibDir, withIntermediateDirectories: true)

        let perfLibSwift = """
        import Foundation

        public class PerfLib {
            public static func heavyComputation() -> Int {
                var result = 0
                for i in 0..<1000000 {
                    result += i * i
                }
                return result
            }

            public static func matrixMultiplication(size: Int) -> [[Double]] {
                let matrix = (0..<size).map { _ in (0..<size).map { _ in Double.random(in: 0...1) } }

                // Simple matrix multiplication for demonstration
                var result = [[Double]](repeating: [Double](repeating: 0, count: size), count: size)
                for i in 0..<size {
                    for j in 0..<size {
                        for k in 0..<size {
                            result[i][j] += matrix[i][k] * matrix[k][j]
                        }
                    }
                }

                return result
            }
        }
        """

        try perfLibSwift.write(
            to: perfLibDir.appendingPathComponent("PerfLib.swift"), atomically: true,
            encoding: .utf8
        )

        // Create main
        let mainSwift = """
        import PerfLib
        import Foundation

        let startTime = Date()

        print("Starting performance test...")

        // Run heavy computation
        let result1 = PerfLib.heavyComputation()
        print("Heavy computation result: \\(result1)")

        // Run matrix multiplication
        let matrix = PerfLib.matrixMultiplication(size: 50)
        print("Matrix multiplication completed, size: \\(matrix.count)x\\(matrix[0].count)")

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        print("Performance test completed in \\(String(format: "%.2f", duration)) seconds")
        """

        try mainSwift.write(
            to: url.appendingPathComponent("Sources/PerfTestProject/main.swift"), atomically: true,
            encoding: .utf8
        )
    }
}
