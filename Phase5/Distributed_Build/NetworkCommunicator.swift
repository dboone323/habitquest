//
//  NetworkCommunicator.swift
//  Distributed Build System
//
//  Network communication layer for distributed build coordination,
//  supporting both TCP and UDP protocols with message serialization.
//

import Combine
import Foundation
import Network

/// Network communication layer for distributed builds
@available(macOS 12.0, *)
public class NetworkCommunicator {

    // MARK: - Properties

    private var listener: NWListener?
    private var connections: [UUID: NWConnection] = [:]
    private var connectionQueue = DispatchQueue(
        label: "com.quantum.network-communicator", qos: .userInitiated
    )

    private let messageEncoder = JSONEncoder()
    private let messageDecoder = JSONDecoder()

    private var messageHandlers: [MessageType: (NetworkMessage) -> Void] = [:]
    private var responseHandlers: [UUID: (NetworkMessage) -> Void] = [:]

    private let heartbeatTimer: Timer?
    private let heartbeatInterval: TimeInterval = 30.0

    /// Network configuration
    public struct Configuration {
        public var port: UInt16 = 8080
        public var maxConnections: Int = 50
        public var connectionTimeout: TimeInterval = 10.0
        public var enableEncryption: Bool = false
        public var enableCompression: Bool = true
        public var heartbeatEnabled: Bool = true

        public init() {}
    }

    private var config: Configuration

    // MARK: - Public Properties

    public private(set) var isRunning = false
    public private(set) var connectedPeers: [UUID: PeerInfo] = [:]

    public var connectionCount: Int {
        connectionQueue.sync { connections.count }
    }

    // MARK: - Initialization

    public init(configuration: Configuration = Configuration()) {
        self.config = configuration

        // Start heartbeat timer
        if config.heartbeatEnabled {
            heartbeatTimer = Timer.scheduledTimer(
                withTimeInterval: heartbeatInterval, repeats: true
            ) { [weak self] _ in
                self?.sendHeartbeat()
            }
        } else {
            heartbeatTimer = nil
        }

        setupMessageHandlers()
    }

    deinit {
        heartbeatTimer?.invalidate()
        stop()
    }

    // MARK: - Public API

    /// Start the network communicator
    public func start() async throws {
        guard !isRunning else { return }

        try await withCheckedThrowingContinuation { continuation in
            do {
                let parameters = NWParameters.tcp
                if config.enableEncryption {
                    parameters.includePeerToPeer = true
                    sec_protocol_options_set_tls_ocsp_enabled(
                        parameters.defaultProtocolStack.tls?.options, true
                    )
                }

                listener = try NWListener(
                    using: parameters, on: NWEndpoint.Port(rawValue: config.port)!
                )

                listener?.stateUpdateHandler = { [weak self] state in
                    switch state {
                    case .ready:
                        self?.isRunning = true
                        continuation.resume()
                    case let .failed(error):
                        continuation.resume(throwing: error)
                    default:
                        break
                    }
                }

                listener?.newConnectionHandler = { [weak self] connection in
                    self?.handleNewConnection(connection)
                }

                listener?.start(queue: connectionQueue)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Stop the network communicator
    public func stop() {
        listener?.cancel()
        listener = nil

        connectionQueue.sync {
            for connection in connections.values {
                connection.cancel()
            }
            connections.removeAll()
            connectedPeers.removeAll()
        }

        isRunning = false
    }

    /// Connect to a remote peer
    public func connect(to host: String, port: UInt16 = 8080) async throws -> UUID {
        let connectionId = UUID()

        return try await withCheckedThrowingContinuation { continuation in
            let parameters = NWParameters.tcp
            if config.enableEncryption {
                parameters.includePeerToPeer = true
            }

            let connection = NWConnection(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(rawValue: port)!,
                using: parameters
            )

            connection.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    self?.connectionQueue.sync {
                        self?.connections[connectionId] = connection
                        self?.connectedPeers[connectionId] = PeerInfo(
                            id: connectionId,
                            host: host,
                            port: port,
                            connectedAt: Date(),
                            lastHeartbeat: Date()
                        )
                    }
                    continuation.resume(returning: connectionId)
                case let .failed(error):
                    continuation.resume(throwing: error)
                default:
                    break
                }
            }

            connection.start(queue: connectionQueue)
        }
    }

    /// Disconnect from a peer
    public func disconnect(from peerId: UUID) {
        connectionQueue.sync {
            if let connection = connections.removeValue(forKey: peerId) {
                connection.cancel()
            }
            connectedPeers.removeValue(forKey: peerId)
        }
    }

    /// Send a message to a specific peer
    public func sendMessage(_ message: NetworkMessage, to peerId: UUID) async throws {
        guard let connection = connectionQueue.sync(execute: { connections[peerId] }) else {
            throw NetworkError.peerNotConnected(peerId)
        }

        let data = try messageEncoder.encode(message)
        let compressedData = config.enableCompression ? try compressData(data) : data

        try await sendData(compressedData, on: connection)
    }

    /// Send a message to all connected peers
    public func broadcastMessage(_ message: NetworkMessage) async throws {
        let connections = connectionQueue.sync { self.connections }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for (peerId, connection) in connections {
                group.addTask {
                    try await self.sendMessage(message, to: peerId)
                }
            }

            try await group.waitForAll()
        }
    }

    /// Send a request and wait for response
    public func sendRequest(
        _ request: NetworkMessage, to peerId: UUID, timeout: TimeInterval = 10.0
    ) async throws -> NetworkMessage {
        let requestId = request.id

        return try await withCheckedThrowingContinuation { continuation in
            // Set up response handler
            responseHandlers[requestId] = { response in
                continuation.resume(returning: response)
            }

            // Send request
            Task {
                do {
                    try await sendMessage(request, to: peerId)

                    // Set timeout
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    responseHandlers.removeValue(forKey: requestId)
                    continuation.resume(throwing: NetworkError.timeout)
                } catch {
                    responseHandlers.removeValue(forKey: requestId)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Register a message handler
    public func registerHandler(for type: MessageType, handler: @escaping (NetworkMessage) -> Void) {
        messageHandlers[type] = handler
    }

    /// Get network statistics
    public func getNetworkStatistics() -> NetworkStatistics {
        connectionQueue.sync {
            let totalConnections = connections.count
            let totalMessagesSent = 0 // Would track this in real implementation
            let totalMessagesReceived = 0 // Would track this in real implementation
            let averageLatency = 0.0 // Would measure this in real implementation

            let connectionsByAge = Dictionary(grouping: connectedPeers.values) { peer in
                let age = Date().timeIntervalSince(peer.connectedAt)
                if age < 300 { return "recent" }
                if age < 3600 { return "hour" }
                if age < 86400 { return "day" }
                return "older"
            }.mapValues { $0.count }

            return NetworkStatistics(
                totalConnections: totalConnections,
                totalMessagesSent: totalMessagesSent,
                totalMessagesReceived: totalMessagesReceived,
                averageLatency: averageLatency,
                connectionsByAge: connectionsByAge
            )
        }
    }

    // MARK: - Private Methods

    private func handleNewConnection(_ connection: NWConnection) {
        let connectionId = UUID()

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.connectionQueue.sync {
                    self?.connections[connectionId] = connection
                    // Extract peer info from connection
                    if let endpoint = connection.endpoint as? NWEndpoint.HostPort {
                        self?.connectedPeers[connectionId] = PeerInfo(
                            id: connectionId,
                            host: endpoint.host.debugDescription,
                            port: endpoint.port.rawValue,
                            connectedAt: Date(),
                            lastHeartbeat: Date()
                        )
                    }
                }
                self?.receiveMessages(on: connection, connectionId: connectionId)
            case .failed, .cancelled:
                self?.connectionQueue.sync {
                    self?.connections.removeValue(forKey: connectionId)
                    self?.connectedPeers.removeValue(forKey: connectionId)
                }
            default:
                break
            }
        }

        connection.start(queue: connectionQueue)
    }

    private func receiveMessages(on connection: NWConnection, connectionId: UUID) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            [weak self] data, _, isComplete, error in
            if let error {
                print("Network error: \(error)")
                return
            }

            if let data {
                Task {
                    await self?.handleReceivedData(data, from: connectionId)
                }
            }

            if !isComplete {
                self?.receiveMessages(on: connection, connectionId: connectionId)
            }
        }
    }

    private func handleReceivedData(_ data: Data, from peerId: UUID) async {
        do {
            let decompressedData = config.enableCompression ? try decompressData(data) : data
            let message = try messageDecoder.decode(NetworkMessage.self, from: decompressedData)

            // Update heartbeat
            connectionQueue.sync {
                if var peer = connectedPeers[peerId] {
                    peer.lastHeartbeat = Date()
                    connectedPeers[peerId] = peer
                }
            }

            // Handle response if it's a response
            if let responseHandler = responseHandlers[message.id] {
                responseHandler(message)
                responseHandlers.removeValue(forKey: message.id)
                return
            }

            // Handle message by type
            if let handler = messageHandlers[message.type] {
                handler(message)
            } else {
                print("No handler for message type: \(message.type)")
            }

        } catch {
            print("Failed to decode message: \(error)")
        }
    }

    private func sendData(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { continuation in
            connection.send(
                content: data,
                completion: .contentProcessed { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            )
        }
    }

    private func sendHeartbeat() {
        let heartbeatMessage = NetworkMessage(
            id: UUID(),
            type: .heartbeat,
            payload: HeartbeatPayload(timestamp: Date())
        )

        Task {
            try? await broadcastMessage(heartbeatMessage)
        }
    }

    private func setupMessageHandlers() {
        registerHandler(for: .heartbeat) { [weak self] message in
            if let payload = message.payload as? HeartbeatPayload {
                self?.handleHeartbeat(from: message.sender ?? UUID(), timestamp: payload.timestamp)
            }
        }
    }

    private func handleHeartbeat(from peerId: UUID, timestamp: Date) {
        connectionQueue.sync {
            if var peer = connectedPeers[peerId] {
                peer.lastHeartbeat = timestamp
                connectedPeers[peerId] = peer
            }
        }
    }

    private func compressData(_ data: Data) throws -> Data {
        // Simple compression using zlib
        // In a real implementation, you'd use a proper compression library
        data // Placeholder
    }

    private func decompressData(_ data: Data) throws -> Data {
        // Simple decompression
        data // Placeholder
    }
}

// MARK: - Supporting Types

/// Network message types
public enum MessageType: String, Codable {
    case buildRequest = "build_request"
    case buildResponse = "build_response"
    case taskAssignment = "task_assignment"
    case taskResult = "task_result"
    case heartbeat
    case nodeStatus = "node_status"
    case cacheSync = "cache_sync"
}

/// Network message
public struct NetworkMessage: Codable {
    public let id: UUID
    public let type: MessageType
    public let sender: UUID?
    public let payload: Codable

    public init(id: UUID = UUID(), type: MessageType, sender: UUID? = nil, payload: Codable) {
        self.id = id
        self.type = type
        self.sender = sender
        self.payload = payload
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, sender, payload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(MessageType.self, forKey: .type)
        sender = try container.decodeIfPresent(UUID.self, forKey: .sender)

        // Decode payload based on type
        switch type {
        case .buildRequest:
            payload = try container.decode(BuildRequestPayload.self, forKey: .payload)
        case .buildResponse:
            payload = try container.decode(BuildResponsePayload.self, forKey: .payload)
        case .taskAssignment:
            payload = try container.decode(TaskAssignmentPayload.self, forKey: .payload)
        case .taskResult:
            payload = try container.decode(TaskResultPayload.self, forKey: .payload)
        case .heartbeat:
            payload = try container.decode(HeartbeatPayload.self, forKey: .payload)
        case .nodeStatus:
            payload = try container.decode(NodeStatusPayload.self, forKey: .payload)
        case .cacheSync:
            payload = try container.decode(CacheSyncPayload.self, forKey: .payload)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(sender, forKey: .sender)

        // Encode payload based on type
        switch type {
        case .buildRequest:
            try container.encode(payload as! BuildRequestPayload, forKey: .payload)
        case .buildResponse:
            try container.encode(payload as! BuildResponsePayload, forKey: .payload)
        case .taskAssignment:
            try container.encode(payload as! TaskAssignmentPayload, forKey: .payload)
        case .taskResult:
            try container.encode(payload as! TaskResultPayload, forKey: .payload)
        case .heartbeat:
            try container.encode(payload as! HeartbeatPayload, forKey: .payload)
        case .nodeStatus:
            try container.encode(payload as! NodeStatusPayload, forKey: .payload)
        case .cacheSync:
            try container.encode(payload as! CacheSyncPayload, forKey: .payload)
        }
    }
}

/// Peer information
public struct PeerInfo {
    public let id: UUID
    public let host: String
    public let port: UInt16
    public let connectedAt: Date
    public var lastHeartbeat: Date
}

/// Network statistics
public struct NetworkStatistics {
    public let totalConnections: Int
    public let totalMessagesSent: Int
    public let totalMessagesReceived: Int
    public let averageLatency: TimeInterval
    public let connectionsByAge: [String: Int]
}

/// Message payloads
public struct BuildRequestPayload: Codable {
    public let task: BuildTask
    public let priority: TaskPriority
}

public struct BuildResponsePayload: Codable {
    public let success: Bool
    public let result: BuildResult?
    public let error: String?
}

public struct TaskAssignmentPayload: Codable {
    public let task: BuildTask
    public let nodeId: UUID
}

public struct TaskResultPayload: Codable {
    public let taskId: UUID
    public let result: BuildResult
}

public struct HeartbeatPayload: Codable {
    public let timestamp: Date
}

public struct NodeStatusPayload: Codable {
    public let nodeId: UUID
    public let status: NodeStatus
    public let capabilities: [String]
}

public struct CacheSyncPayload: Codable {
    public let cacheKey: CacheKey
    public let artifacts: [BuildArtifact]
}

/// Network errors
public enum NetworkError: Error {
    case peerNotConnected(UUID)
    case timeout
    case connectionFailed(String)
    case messageEncodingFailed
    case messageDecodingFailed
}

// MARK: - Extensions

extension NetworkStatistics: CustomStringConvertible {
    public var description: String {
        """
        Network Statistics:
        - Total Connections: \(totalConnections)
        - Messages Sent: \(totalMessagesSent)
        - Messages Received: \(totalMessagesReceived)
        - Average Latency: \(String(format: "%.2fms", averageLatency * 1000))
        - Connections by Age: \(connectionsByAge)
        """
    }
}

extension PeerInfo: CustomStringConvertible {
    public var description: String {
        "Peer(id: \(id), host: \(host):\(port), connected: \(connectedAt.timeIntervalSinceNow)s ago)"
    }
}
