////
// BaseAgent.swift
// HabitQuestCore
//
// Local definition of the agent contract used by HabitInsightAgent.
//
// `BaseAgent` and `AgentResult` are defined here so `HabitInsightAgent` can
// compile with no external package dependency (HabitQuest is a standalone app).
//
import Foundation

/// A behavioral insight agent protocol.
///
/// Conforming agents analyse habit context and return an `AgentResult`.
/// Reward-level changes require human approval (HITL) per the AGENTS.md mandate.
public protocol BaseAgent {
    /// Stable agent identifier.
    var id: String { get }

    /// Human-readable agent name.
    var name: String { get }

    /// Analyse `context` and return an `AgentResult`.
    func execute(context: [String: any Sendable]) async throws -> AgentResult
}

/// Result of a `BaseAgent` execution.
public struct AgentResult {
    public let agentId: String
    public let success: Bool
    public let summary: String
    public let detail: [String: String]
    public let requiresApproval: Bool
    public let timestamp: Date

    public init(
        agentId: String,
        success: Bool,
        summary: String,
        detail: [String: String],
        requiresApproval: Bool,
        timestamp: Date = Date()
    ) {
        self.agentId = agentId
        self.success = success
        self.summary = summary
        self.detail = detail
        self.requiresApproval = requiresApproval
        self.timestamp = timestamp
    }
}
