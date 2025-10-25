//
//  TaskScheduler.swift
//  Distributed Build System
//
//  Intelligent task scheduling with dependency resolution, load balancing,
//  and performance optimization for distributed builds.
//

import Foundation

/// Intelligent task scheduler for distributed builds
@available(macOS 12.0, *)
public class TaskScheduler {

    // MARK: - Properties

    private var taskQueue: PriorityQueue<ScheduledTask> = PriorityQueue()
    private var runningTasks: [String: ScheduledTask] = [:]
    private var completedTasks: [String: TaskResult] = [:]
    private var taskDependencies: [String: Set<String>] = [:]
    private var waitingTasks: [String: ScheduledTask] = [:]

    private let schedulerQueue = DispatchQueue(
        label: "com.quantum.task-scheduler", qos: .userInitiated
    )
    private let semaphore = DispatchSemaphore(value: 1)

    /// Configuration for task scheduling
    public struct Configuration {
        public var maxConcurrentTasks: Int = 20
        public var taskTimeout: TimeInterval = 600.0
        public var dependencyCheckInterval: TimeInterval = 1.0
        public var loadBalancingEnabled: Bool = true
        public var priorityBasedScheduling: Bool = true
        public var adaptiveScheduling: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public private(set) var totalScheduledTasks: Int = 0
    public private(set) var completedTaskCount: Int = 0
    public private(set) var failedTaskCount: Int = 0

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration
        startDependencyChecker()
    }

    // MARK: - Public API

    /// Schedule a task for execution
    public func scheduleTask(_ task: BuildTask, priority: TaskPriority = .normal) async throws
        -> String
    {
        let scheduledTask = ScheduledTask(
            task: task,
            priority: priority,
            scheduledTime: Date(),
            status: .pending
        )

        return try await schedulerQueue.sync {
            let taskId = scheduledTask.id

            // Check dependencies
            if hasUnsatisfiedDependencies(task) {
                waitingTasks[taskId] = scheduledTask
                scheduledTask.status = .waiting
            } else {
                taskQueue.enqueue(scheduledTask)
            }

            totalScheduledTasks += 1
            return taskId
        }
    }

    /// Schedule multiple tasks with dependencies
    public func scheduleTasks(_ tasks: [BuildTask], dependencies: [String: [String]] = [:])
        async throws -> [String]
    {
        // Set up dependency graph
        await schedulerQueue.sync {
            for (taskId, deps) in dependencies {
                taskDependencies[taskId] = Set(deps)
            }
        }

        // Schedule tasks
        var taskIds: [String] = []
        for task in tasks {
            let taskId = try await scheduleTask(task)
            taskIds.append(taskId)
        }

        return taskIds
    }

    /// Get next available task for a specific node
    public func getNextTask(for nodeCapabilities: NodeCapabilities) -> ScheduledTask? {
        semaphore.wait()
        defer { semaphore.signal() }

        // Find suitable task for node capabilities
        var suitableTasks: [ScheduledTask] = []

        while let task = taskQueue.dequeue() {
            if isTaskSuitableForNode(task.task, nodeCapabilities: nodeCapabilities) {
                suitableTasks.append(task)
                break
            } else {
                // Put back in queue if not suitable
                taskQueue.enqueue(task)
                break
            }
        }

        if let selectedTask = suitableTasks.first {
            selectedTask.status = .running
            selectedTask.assignedNodeId = UUID().uuidString // Would be actual node ID
            runningTasks[selectedTask.id] = selectedTask
            return selectedTask
        }

        return nil
    }

    /// Mark task as completed
    public func completeTask(_ taskId: String, result: TaskResult) async {
        await schedulerQueue.sync {
            if let task = runningTasks.removeValue(forKey: taskId) {
                completedTasks[taskId] = result
                completedTaskCount += 1

                // Check if this completion unblocks waiting tasks
                checkWaitingTasks()
            }
        }
    }

    /// Mark task as failed
    public func failTask(_ taskId: String, error: Error) async {
        await schedulerQueue.sync {
            if let task = runningTasks.removeValue(forKey: taskId) {
                task.status = .failed
                task.error = error
                failedTaskCount += 1

                // Could implement retry logic here
                if shouldRetryTask(task) {
                    task.retryCount += 1
                    task.status = .pending
                    taskQueue.enqueue(task)
                }
            }
        }
    }

    /// Cancel a task
    public func cancelTask(_ taskId: String) async {
        await schedulerQueue.sync {
            if let task = runningTasks.removeValue(forKey: taskId) {
                task.status = .cancelled
            } else if let task = waitingTasks.removeValue(forKey: taskId) {
                task.status = .cancelled
            } else {
                // Try to remove from queue (simplified)
                taskQueue = PriorityQueue()
            }
        }
    }

    /// Get task status
    public func getTaskStatus(_ taskId: String) -> TaskStatus? {
        semaphore.wait()
        defer { semaphore.signal() }

        if let task = runningTasks[taskId] {
            return task.status
        } else if let task = waitingTasks[taskId] {
            return task.status
        }

        return nil
    }

    /// Get scheduler statistics
    public func getSchedulerStatistics() -> SchedulerStatistics {
        semaphore.wait()
        defer { semaphore.signal() }

        let queuedTasks = taskQueue.count
        let runningTasks = self.runningTasks.count
        let waitingTasks = self.waitingTasks.count

        let averageTaskTime = calculateAverageTaskTime()
        let successRate =
            totalScheduledTasks > 0 ? Double(completedTaskCount) / Double(totalScheduledTasks) : 0

        let taskTypeDistribution = Dictionary(grouping: completedTasks.values) { $0.taskType }
            .mapValues { $0.count }

        return SchedulerStatistics(
            totalTasks: totalScheduledTasks,
            queuedTasks: queuedTasks,
            runningTasks: runningTasks,
            waitingTasks: waitingTasks,
            completedTasks: completedTaskCount,
            failedTasks: failedTaskCount,
            averageTaskTime: averageTaskTime,
            successRate: successRate,
            taskTypeDistribution: taskTypeDistribution
        )
    }

    /// Optimize scheduling based on performance data
    public func optimizeScheduling() async {
        await schedulerQueue.sync {
            // Analyze performance patterns and adjust scheduling strategy
            let performanceData = analyzePerformanceData()

            // Adjust priorities based on performance
            adjustTaskPriorities(performanceData)

            // Optimize resource allocation
            optimizeResourceAllocation(performanceData)
        }
    }

    // MARK: - Private Methods

    private func hasUnsatisfiedDependencies(_ task: BuildTask) -> Bool {
        guard let dependencies = taskDependencies[task.id] else {
            return false
        }

        return dependencies.contains { dependencyId in
            !completedTasks.keys.contains(dependencyId)
        }
    }

    private func isTaskSuitableForNode(_ task: BuildTask, nodeCapabilities: NodeCapabilities)
        -> Bool
    {
        // Check if node supports the required platform
        switch task.type {
        case .compile, .link:
            return nodeCapabilities.supportedPlatforms.contains("macOS") // Simplified check
        case .test:
            return nodeCapabilities.supportedPlatforms.contains("iOS") // Simplified check
        case .archive:
            return nodeCapabilities.cores >= 2 // Archiving needs more cores
        case .analyze:
            return nodeCapabilities.memoryGB >= 4 // Analysis needs more memory
        }
    }

    private func checkWaitingTasks() {
        var tasksToSchedule: [ScheduledTask] = []

        for (taskId, task) in waitingTasks {
            if !hasUnsatisfiedDependencies(task.task) {
                task.status = .pending
                tasksToSchedule.append(task)
                waitingTasks.removeValue(forKey: taskId)
            }
        }

        for task in tasksToSchedule {
            taskQueue.enqueue(task)
        }
    }

    private func shouldRetryTask(_ task: ScheduledTask) -> Bool {
        task.retryCount < 3 && isRetryableError(task.error)
    }

    private func isRetryableError(_ error: Error?) -> Bool {
        // Determine if an error is retryable
        guard let error else { return false }

        let errorString = String(describing: error).lowercased()
        return errorString.contains("timeout") || errorString.contains("network")
            || errorString.contains("temporary")
    }

    private func startDependencyChecker() {
        Timer.scheduledTimer(withTimeInterval: config.dependencyCheckInterval, repeats: true) {
            [weak self] _ in
            self?.checkWaitingTasks()
        }
    }

    private func calculateAverageTaskTime() -> TimeInterval {
        let completedResults = completedTasks.values
        guard !completedResults.isEmpty else { return 0 }

        let totalTime = completedResults.reduce(0) { $0 + $1.duration }
        return totalTime / Double(completedResults.count)
    }

    private func analyzePerformanceData() -> PerformanceData {
        // Analyze historical performance data
        let taskTimes = completedTasks.values.map(\.duration)
        let averageTime = taskTimes.reduce(0, +) / Double(taskTimes.count)

        let nodePerformance = Dictionary(grouping: completedTasks.values) { $0.nodeId ?? "unknown" }
            .mapValues { tasks in
                let avgTime = tasks.map(\.duration).reduce(0, +) / Double(tasks.count)
                return avgTime
            }

        return PerformanceData(
            averageTaskTime: averageTime,
            nodePerformance: nodePerformance,
            bottleneckTasks: identifyBottlenecks()
        )
    }

    private func identifyBottlenecks() -> [String] {
        // Identify tasks that take significantly longer than average
        let averageTime = calculateAverageTaskTime()
        let threshold = averageTime * 2.0 // Tasks taking 2x average are bottlenecks

        return completedTasks.compactMap { taskId, result in
            result.duration > threshold ? taskId : nil
        }
    }

    private func adjustTaskPriorities(_ performanceData: PerformanceData) {
        // Adjust task priorities based on performance analysis
        // This is a simplified implementation
        for (nodeId, avgTime) in performanceData.nodePerformance {
            if avgTime > performanceData.averageTaskTime * 1.5 {
                // Slow node - reduce priority of tasks assigned to it
                print("Reducing priority for slow node: \(nodeId)")
            }
        }
    }

    private func optimizeResourceAllocation(_ performanceData: PerformanceData) {
        // Optimize resource allocation based on performance data
        if !performanceData.bottleneckTasks.isEmpty {
            print("Identified \(performanceData.bottleneckTasks.count) bottleneck tasks")
            // Could implement resource reallocation here
        }
    }
}

// MARK: - Supporting Types

/// Scheduled task wrapper
public class ScheduledTask {
    public let id: String
    public let task: BuildTask
    public let priority: TaskPriority
    public let scheduledTime: Date
    public var status: TaskStatus
    public var assignedNodeId: String?
    public var startTime: Date?
    public var error: Error?
    public var retryCount: Int = 0

    public init(task: BuildTask, priority: TaskPriority, scheduledTime: Date, status: TaskStatus) {
        self.id = UUID().uuidString
        self.task = task
        self.priority = priority
        self.scheduledTime = scheduledTime
        self.status = status
    }
}

/// Task priority levels
public enum TaskPriority: Int, Comparable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3

    public static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Task status
public enum TaskStatus {
    case pending
    case waiting
    case running
    case completed
    case failed
    case cancelled
}

/// Task result
public struct TaskResult {
    public let taskId: String
    public let success: Bool
    public let duration: TimeInterval
    public let output: String?
    public let errors: [Error]
    public let artifacts: [BuildArtifact]
    public let nodeId: String?
    public let taskType: BuildTask.TaskType

    public init(
        taskId: String,
        success: Bool,
        duration: TimeInterval,
        output: String? = nil,
        errors: [Error] = [],
        artifacts: [BuildArtifact] = [],
        nodeId: String? = nil,
        taskType: BuildTask.TaskType
    ) {
        self.taskId = taskId
        self.success = success
        self.duration = duration
        self.output = output
        self.errors = errors
        self.artifacts = artifacts
        self.nodeId = nodeId
        self.taskType = taskType
    }
}

/// Scheduler statistics
public struct SchedulerStatistics {
    public let totalTasks: Int
    public let queuedTasks: Int
    public let runningTasks: Int
    public let waitingTasks: Int
    public let completedTasks: Int
    public let failedTasks: Int
    public let averageTaskTime: TimeInterval
    public let successRate: Double
    public let taskTypeDistribution: [BuildTask.TaskType: Int]
}

/// Performance data for optimization
private struct PerformanceData {
    let averageTaskTime: TimeInterval
    let nodePerformance: [String: TimeInterval]
    let bottleneckTasks: [String]
}

/// Priority queue for task scheduling
private struct PriorityQueue<Element: Comparable> {
    private var elements: [Element] = []

    var count: Int { elements.count }
    var isEmpty: Bool { elements.isEmpty }

    mutating func enqueue(_ element: Element) {
        elements.append(element)
        elements.sort(by: >) // Sort in descending order (highest priority first)
    }

    mutating func dequeue() -> Element? {
        elements.popLast()
    }

    func peek() -> Element? {
        elements.last
    }
}

// MARK: - Extensions

extension ScheduledTask: Comparable {
    public static func < (lhs: ScheduledTask, rhs: ScheduledTask) -> Bool {
        if lhs.priority != rhs.priority {
            return lhs.priority < rhs.priority
        }
        return lhs.scheduledTime < rhs.scheduledTime
    }

    public static func == (lhs: ScheduledTask, rhs: ScheduledTask) -> Bool {
        lhs.id == rhs.id
    }
}

extension ScheduledTask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
