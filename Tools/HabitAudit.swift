import Foundation
import SharedKit
import HabitAgentCore

@available(macOS 15.0, *)
@main
struct HabitAudit {
    static func main() async {
        print(">>> [HabitQuest Agent] Starting Behavioral Insight Analysis task...")

        let agent = HabitInsightAgent()

        // Simulate a user with a strong 45-day streak and high completion rate
        let context: [String: Sendable] = [
            "streak_days": 45,
            "completion_rate": 0.92,               // 92% – triggers elite reward consideration
            "peak_hour": 7,                         // 7 AM = morning person
            "active_categories": ["fitness", "productivity", "mindfulness"]
        ]

        print(">>> [Task] Analysing streak data and generating habit recommendations...")
        do {
            let result = try await agent.execute(context: context)
            print("\n--- Agent Result: \(result.agentId) ---")
            print("Status: \(result.success ? "SUCCESS" : "FAILURE")")
            print("Summary: \(result.summary)")
            print("Streak: \(result.detail["streak_days"] ?? "0") days")
            print("Completion Rate: \(result.detail["completion_rate"] ?? "0%")")
            print("Peak Time: \(result.detail["peak_time"] ?? "N/A")")
            print("Suggested Reward Multiplier: \(result.detail["suggested_reward_multiplier"] ?? "1x")")
            print("Top Category: \(result.detail["top_category"] ?? "none")")
            print("Requires Approval: \(result.requiresApproval)")
            print("Timestamp: \(result.timestamp)")
        } catch {
            print("Error executing agent: \(error)")
        }

        print("\n>>> [HabitQuest Agent] Task completed.")
    }
}
