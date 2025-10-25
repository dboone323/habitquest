//
//  BuildNodeManager.swift
//  Distributed Build System
//
//  Manages build nodes, monitors their health, and handles node discovery
//  and registration in the distributed build network.
//

import Combine
import Foundation

/// Manages build nodes in the distributed system
@available(macOS 12.0, *)
public class BuildNodeManager {

    // MARK: - Properties

    private var nodes: [String: BuildNode] = [:]
    private var nodeHealthMonitors: [String: NodeHealthMonitor] = [:]
    private var discoveryService: NodeDiscoveryService?

    private let managerQueue = DispatchQueue(label: "com.quantum.node-manager", qos: .userInitiated)
    private let healthCheckTimer: Timer?

    /// Configuration for node management
    public struct Configuration {
        public var healthCheckInterval: TimeInterval = 30.0
        public var nodeTimeout: TimeInterval = 300.0
        public var maxNodes: Int = 50
        public var autoDiscoveryEnabled: Bool = true
        public var discoveryPort: Int = 8080
        public var enableLoadBalancing: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public var nodeCount: Int {
        managerQueue.sync { nodes.count }
    }

    public var activeNodeCount: Int {
        managerQueue.sync { nodes.values.filter { $0.status == .active }.count }
    }

    public var totalCapacity: Int {
        managerQueue.sync { nodes.values.reduce(0) { $0 + $1.capabilities.cores } }
    }

    public var availableCapacity: Int {
        managerQueue.sync { nodes.values.reduce(0) { $0 + $1.availableCapacity } }
    }

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration

        if config.autoDiscoveryEnabled {
            self.discoveryService = NodeDiscoveryService(port: config.discoveryPort)
            startDiscovery()
        }

        // Start health monitoring
        healthCheckTimer = Timer.scheduledTimer(
            withTimeInterval: config.healthCheckInterval, repeats: true
        ) { [weak self] _ in
            self?.performHealthChecks()
        }
    }

    deinit {
        healthCheckTimer?.invalidate()
        discoveryService?.stop()
    }

    // MARK: - Public API

    /// Register a new build node
    public func registerNode(_ node: BuildNode) async {
        await managerQueue.sync {
            guard nodes.count < config.maxNodes else {
                print("Maximum node limit reached (\(config.maxNodes))")
                return
            }

            nodes[node.id] = node

            // Start health monitoring for this node
            let monitor = NodeHealthMonitor(node: node, timeout: config.nodeTimeout)
            nodeHealthMonitors[node.id] = monitor

            print("Registered build node: \(node.id) at \(node.host)")
            notifyNodeChange(.registered(node))
        }
    }

    /// Unregister a build node
    public func unregisterNode(_ nodeId: String) async {
        await managerQueue.sync {
            if let node = nodes.removeValue(forKey: nodeId) {
                nodeHealthMonitors.removeValue(forKey: nodeId)
                print("Unregistered build node: \(nodeId)")
                notifyNodeChange(.unregistered(node))
            }
        }
    }

    /// Get all registered nodes
    public func getAllNodes() -> [BuildNode] {
        managerQueue.sync { Array(nodes.values) }
    }

    /// Get node by ID
    public func getNode(_ nodeId: String) -> BuildNode? {
        managerQueue.sync { nodes[nodeId] }
    }

    /// Get nodes by capability
    public func getNodesWithCapability(_ capability: NodeCapability) -> [BuildNode] {
        managerQueue.sync {
            nodes.values.filter { node in
                switch capability {
                case let .platform(platform):
                    return node.capabilities.supportedPlatforms.contains(platform)
                case let .minCores(cores):
                    return node.capabilities.cores >= cores
                case let .minMemory(memory):
                    return node.capabilities.memoryGB >= memory
                case let .minStorage(storage):
                    return node.capabilities.storageGB >= storage
                }
            }
        }
    }

    /// Get optimal nodes for a build request
    public func getOptimalNodes(for request: BuildRequest, count: Int = 3) -> [BuildNode] {
        managerQueue.sync {
            let suitableNodes = nodes.values.filter { node in
                node.status == .active
                    && node.capabilities.supportedPlatforms.contains(request.target)
                    && node.availableCapacity > 0
            }

            // Sort by available capacity (descending) and load
            return
                suitableNodes
                    .sorted { node1, node2 -> Bool in
                        if node1.availableCapacity != node2.availableCapacity {
                            return node1.availableCapacity > node2.availableCapacity
                        }
                        return node1.capabilities.cores > node2.capabilities.cores
                    }
                    .prefix(count)
                    .map { $0 }
        }
    }

    /// Update node status
    public func updateNodeStatus(_ nodeId: String, status: BuildNode.NodeStatus) async {
        await managerQueue.sync {
            if var node = nodes[nodeId] {
                let oldStatus = node.status
                node.status = status
                nodes[nodeId] = node

                if oldStatus != status {
                    print("Node \(nodeId) status changed: \(oldStatus) -> \(status)")
                    notifyNodeChange(.statusChanged(node, oldStatus, status))
                }
            }
        }
    }

    /// Get node statistics
    public func getNodeStatistics() -> NodeStatistics {
        managerQueue.sync {
            let totalNodes = nodes.count
            let activeNodes = nodes.values.filter { $0.status == .active }.count
            let idleNodes = nodes.values.filter { $0.status == .idle }.count
            let offlineNodes = nodes.values.filter { $0.status == .offline }.count

            let totalCores = nodes.values.reduce(0) { $0 + $1.capabilities.cores }
            let availableCores = nodes.values.reduce(0) { $0 + $1.availableCapacity }

            let utilizationRate =
                totalCores > 0 ? Double(totalCores - availableCores) / Double(totalCores) : 0

            let platformDistribution = Dictionary(grouping: nodes.values) {
                $0.capabilities.supportedPlatforms
            }
            .mapValues { $0.count }

            return NodeStatistics(
                totalNodes: totalNodes,
                activeNodes: activeNodes,
                idleNodes: idleNodes,
                offlineNodes: offlineNodes,
                totalCores: totalCores,
                availableCores: availableCores,
                utilizationRate: utilizationRate,
                platformDistribution: platformDistribution
            )
        }
    }

    /// Perform load balancing
    public func performLoadBalancing() async {
        guard config.enableLoadBalancing else { return }

        await managerQueue.sync {
            let activeNodes = nodes.values.filter { $0.status == .active }
            guard activeNodes.count > 1 else { return }

            // Calculate average utilization
            let totalCapacity = activeNodes.reduce(0) { $0 + $1.capabilities.cores }
            let totalAvailable = activeNodes.reduce(0) { $0 + $1.availableCapacity }
            let averageUtilization = Double(totalCapacity - totalAvailable) / Double(totalCapacity)

            // Identify overloaded and underloaded nodes
            let overloadedNodes = activeNodes.filter { node in
                let utilization =
                    Double(node.capabilities.cores - node.availableCapacity)
                        / Double(node.capabilities.cores)
                return utilization > averageUtilization + 0.2 // 20% above average
            }

            let underloadedNodes = activeNodes.filter { node in
                let utilization =
                    Double(node.capabilities.cores - node.availableCapacity)
                        / Double(node.capabilities.cores)
                return utilization < averageUtilization - 0.2 // 20% below average
            }

            // Perform load balancing (simplified)
            for overloadedNode in overloadedNodes {
                for underloadedNode in underloadedNodes {
                    if overloadedNode.availableCapacity < underloadedNode.availableCapacity {
                        // Could migrate tasks here in a real implementation
                        print("Load balancing: \(overloadedNode.id) -> \(underloadedNode.id)")
                    }
                }
            }
        }
    }

    // MARK: - Private Methods

    private func startDiscovery() {
        discoveryService?.start { [weak self] discoveredNode in
            Task {
                await self?.handleDiscoveredNode(discoveredNode)
            }
        }
    }

    private func handleDiscoveredNode(_ nodeInfo: DiscoveredNode) async {
        // Create BuildNode from discovery info
        let capabilities = NodeCapabilities(
            cores: nodeInfo.cores,
            memoryGB: nodeInfo.memoryGB,
            storageGB: nodeInfo.storageGB,
            supportedPlatforms: nodeInfo.platforms
        )

        let node = BuildNode(
            id: nodeInfo.id,
            host: nodeInfo.host,
            capabilities: capabilities
        )

        await registerNode(node)
    }

    private func performHealthChecks() {
        Task {
            await managerQueue.sync {
                for (nodeId, monitor) in nodeHealthMonitors {
                    Task {
                        let isHealthy = await monitor.checkHealth()
                        if !isHealthy {
                            await updateNodeStatus(nodeId, status: .offline)
                        }
                    }
                }
            }
        }
    }

    private func notifyNodeChange(_ change: NodeChange) {
        // In a real implementation, this would notify subscribers
        print("Node change: \(change)")
    }
}

// MARK: - Supporting Types

/// Node capability filter
public enum NodeCapability {
    case platform(String)
    case minCores(Int)
    case minMemory(Int)
    case minStorage(Int)
}

/// Node change event
public enum NodeChange {
    case registered(BuildNode)
    case unregistered(BuildNode)
    case statusChanged(BuildNode, BuildNode.NodeStatus, BuildNode.NodeStatus)
}

/// Node statistics
public struct NodeStatistics {
    public let totalNodes: Int
    public let activeNodes: Int
    public let idleNodes: Int
    public let offlineNodes: Int
    public let totalCores: Int
    public let availableCores: Int
    public let utilizationRate: Double
    public let platformDistribution: [String: Int]
}

/// Discovered node information
public struct DiscoveredNode {
    public let id: String
    public let host: String
    public let cores: Int
    public let memoryGB: Int
    public let storageGB: Int
    public let platforms: [String]
}

/// Node health monitor
private class NodeHealthMonitor {
    private let node: BuildNode
    private let timeout: TimeInterval
    private var lastHeartbeat: Date

    init(node: BuildNode, timeout: TimeInterval) {
        self.node = node
        self.timeout = timeout
        self.lastHeartbeat = Date()
    }

    func checkHealth() async -> Bool {
        // Simple health check - in a real implementation, this would
        // ping the node and check its actual status
        let timeSinceLastHeartbeat = Date().timeIntervalSince(lastHeartbeat)

        if timeSinceLastHeartbeat > timeout {
            return false
        }

        // Simulate network health check
        do {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            lastHeartbeat = Date()
            return true
        } catch {
            return false
        }
    }

    func updateHeartbeat() {
        lastHeartbeat = Date()
    }
}

/// Node discovery service
private class NodeDiscoveryService {
    private let port: Int
    private var isRunning = false
    private var discoveryHandler: ((DiscoveredNode) -> Void)?

    init(port: Int) {
        self.port = port
    }

    func start(handler: @escaping (DiscoveredNode) -> Void) {
        guard !isRunning else { return }

        discoveryHandler = handler
        isRunning = true

        // Simulate node discovery - in a real implementation, this would
        // use network discovery protocols like Bonjour or custom UDP broadcasting
        Task {
            while isRunning {
                // Simulate discovering a node every 60 seconds
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds

                let discoveredNode = DiscoveredNode(
                    id: "discovered_node_\(UUID().uuidString.prefix(8))",
                    host: "192.168.1.\(Int.random(in: 100 ... 200))",
                    cores: Int.random(in: 4 ... 16),
                    memoryGB: Int.random(in: 8 ... 64),
                    storageGB: Int.random(in: 100 ... 1000),
                    platforms: ["macOS", "iOS"]
                )

                discoveryHandler?(discoveredNode)
            }
        }
    }

    func stop() {
        isRunning = false
        discoveryHandler = nil
    }
}

// MARK: - Extensions

extension BuildNode: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: BuildNode, rhs: BuildNode) -> Bool {
        lhs.id == rhs.id
    }
}

extension BuildNode: CustomStringConvertible {
    public var description: String {
        "\(id)@\(host) [\(capabilities.cores) cores, \(status)]"
    }
}
