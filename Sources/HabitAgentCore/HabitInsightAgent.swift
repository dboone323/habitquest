import Foundation
import SharedKit

/// A `BaseAgent`-compliant behavioral insight agent for HabitQuest.
///
/// `HabitInsightAgent` wraps the analytics logic from `HabitSuggestionService` and
/// `BehavioralInsightsService` into the standardized `SharedKit` protocol, enabling
/// HITL approval flows for any gamification reward changes.
public struct HabitInsightAgent: BaseAgent {
    public let id = "habit_insight_agent_001"
    public let name = "Behavioral Insight Agent"

    public init() {}

    /// Analyse habit streak data and return personalised recommendations.
    ///
    /// Expected context keys:
    /// - `"streak_days"`: `Int` – current best streak
    /// - `"completion_rate"`: `Double` – 0.0–1.0 completion ratio over last 30 days
    /// - `"peak_hour"`: `Int` – hour of day (0–23) where most completions occur
    /// - `"active_categories"`: `[String]` – list of habit categories currently tracked
    public func execute(context: [String: Sendable]) async throws -> AgentResult {
        let streakDays      = context["streak_days"] as? Int ?? 0
        let completionRate  = context["completion_rate"] as? Double ?? 0.0
        let peakHour        = context["peak_hour"] as? Int ?? 9
        let activeCategories = context["active_categories"] as? [String] ?? []

        let recommendation  = buildRecommendation(
            streak: streakDays,
            rate: completionRate,
            peakHour: peakHour,
            categories: activeCategories
        )
        let rewardMultiplier = completionRate >= 0.8 ? "2x" : completionRate >= 0.5 ? "1.5x" : "1x"

        // Reward-level changes require human approval per AGENTS.md mandate
        let requiresApproval = completionRate >= 0.9 && streakDays >= 30

        return AgentResult(
            agentId: id,
            success: true,
            summary: recommendation,
            detail: [
                "streak_days": "\(streakDays)",
                "completion_rate": String(format: "%.0f%%", completionRate * 100),
                "peak_time": peakHourLabel(peakHour),
                "suggested_reward_multiplier": rewardMultiplier,
                "top_category": activeCategories.first ?? "none",
            ],
            requiresApproval: requiresApproval
        )
    }

    // MARK: - Private Helpers

    private func buildRecommendation(
        streak: Int,
        rate: Double,
        peakHour: Int,
        categories: [String]
    ) -> String {
        let timeLabel = peakHourLabel(peakHour)

        if rate >= 0.9 && streak >= 30 {
            return "Exceptional consistency (\(streak)-day streak, \(Int(rate * 100))% rate). "
                + "Unlock elite reward tier — awaiting approval."
        } else if rate >= 0.7 {
            return "Strong habit performance detected. Recommend scheduling new habit in \(timeLabel) slot. "
                + "Suggested addition: \(suggestHabit(for: categories))."
        } else if streak > 0 {
            return "Active streak of \(streak) days. Boost consistency with a \(timeLabel) reminder. "
                + "Focus area: \(suggestHabit(for: categories))."
        } else {
            return "No active streak detected. Recommend starting with one easy \(timeLabel) habit to rebuild momentum."
        }
    }

    private func peakHourLabel(_ hour: Int) -> String {
        switch hour {
        case 5..<12:  return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default:      return "night"
        }
    }

    private func suggestHabit(for categories: [String]) -> String {
        if categories.contains("fitness") { return "Morning Meditation" }
        if categories.contains("productivity") { return "Deep Work Session" }
        if categories.contains("learning") { return "Daily Reading (20 min)" }
        return "Gratitude Journaling"
    }
}
