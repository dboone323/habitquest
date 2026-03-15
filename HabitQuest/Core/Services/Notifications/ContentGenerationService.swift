import Foundation
import SharedKit
@preconcurrency import UserNotifications

/// Service responsible for generating intelligent notification content
@Observable @MainActor
final class ContentGenerationService {
    private let ollamaClient: OllamaClient

    init(ollamaClient: OllamaClient = OllamaClient()) {
        self.ollamaClient = ollamaClient
    }

    /// Generate smart notification content based on habit data and predictions
    func generateSmartContent(
        for habit: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) async -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        // Attempt to generate AI title and body
        if let aiContent = await generateAIContent(for: habit, prediction: prediction) {
            content.title = aiContent.title
            content.body = aiContent.body
        } else {
            // Fallback to heuristic-based content (now also AI-backed)
            content.title = await generatePersonalizedTitle(for: habit, prediction: prediction)
            content.body = await generateContextualMessage(
                for: habit,
                scheduling: scheduling,
                prediction: prediction
            )
        }

        // Dynamic notification priority
        content.interruptionLevel = determineInterruptionLevel(
            habit: habit,
            successRate: scheduling.successRateAtTime
        )

        // Custom sound based on habit category
        content.sound = selectOptimalSound(for: habit.category)

        // Rich actions for quick interaction
        content.categoryIdentifier = "HABIT_REMINDER"

        // Add custom data for analytics
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "optimalTime": scheduling.optimalTime,
            "successProbability": prediction.probability,
            "schedulingVersion": "smart_v2_ai",
        ]

        return content
    }

    @MainActor
    private func generateAIContent(
        for habit: Habit,
        prediction: StreakPrediction
    ) async -> (title: String, body: String)? {
        let prompt = """
        User habit: \(habit.name)
        Description: \(habit.habitDescription)
        Current streak: \(habit.streak) days
        Success probability: \(Int(prediction.probability * 100))%

        Generate a highly personalized, motivating notification for this habit.
        Return JSON with "title" and "body".
        Keep it short and encouraging. Include an emoji.
        """

        return await performAICall(prompt: prompt)
    }

    /// Generate milestone notification content
    func generateMilestoneContent(for habit: Habit, milestone: StreakMilestone) async -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        if let aiContent = await generateAIMilestoneContent(for: habit, milestone: milestone) {
            content.title = aiContent.title
            content.body = aiContent.body
        } else {
            content.title = "🎯 Milestone Approaching!"
            content.body = "You're \(milestone.streakCount - habit.streak) days away from \(milestone.title)!"
        }

        content.sound = selectOptimalSound(for: habit.category)
        content.categoryIdentifier = "MILESTONE_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "milestoneStreak": milestone.streakCount,
            "notificationType": "milestone",
        ]

        return content
    }

    /// Generate recovery notification content
    func generateRecoveryContent(for habit: Habit) async -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        if let aiContent = await generateAIRecoveryContent(for: habit) {
            content.title = aiContent.title
            content.body = aiContent.body
        } else {
            content.title = "🌱 Fresh Start"
            content.body = "Yesterday is gone, today is a new opportunity to build \(habit.name) back up!"
        }

        content.sound = selectOptimalSound(for: habit.category)
        content.interruptionLevel = .passive
        content.categoryIdentifier = "RECOVERY_REMINDER"

        content.userInfo = [
            "habitId": habit.id.uuidString,
            "notificationType": "recovery",
        ]

        return content
    }

    private func generateAIMilestoneContent(
        for habit: Habit,
        milestone: StreakMilestone
    ) async -> (title: String, body: String)? {
        let prompt = "User is close to a milestone for '\(habit.name)': '\(milestone.title)' at \(milestone.streakCount) days. Current streak is \(habit.streak). Generate a short, exciting title and body for a notification in JSON."
        return await performAICall(prompt: prompt)
    }

    private func generateAIRecoveryContent(for habit: Habit) async -> (title: String, body: String)? {
        let prompt = "User broke their streak for '\(habit.name)'. Generate a gentle, encouraging 'fresh start' notification title and body in JSON."
        return await performAICall(prompt: prompt)
    }

    private func performAICall(prompt: String) async -> (title: String, body: String)? {
        do {
            let response = try await ollamaClient.generate(
                model: nil,
                prompt: prompt,
                temperature: 0.7,
                maxTokens: 200,
                useCache: true
            )
            // Robust JSON extraction
            let cleanedResponse = if let range = response.range(of: "\\{.*\\}", options: .regularExpression) {
                String(response[range])
            } else {
                response
            }

            guard let data = cleanedResponse.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let title = json["title"],
                  let body = json["body"]
            else {
                return nil
            }
            return (title, body)
        } catch {
            return nil
        }
    }

    // MARK: - Private Methods

    private func generatePersonalizedTitle(for habit: Habit, prediction: StreakPrediction) async -> String {
        let prompt = "Generate a very short, personalized notification title for \(habit.name) with \(habit.streak) day streak and success probability \(Int(prediction.probability * 100))%. Include an emoji."
        if let content = await performAICall(prompt: prompt) {
            return content.title
        }
        return "✨ Time for \(habit.name)"
    }

    private func generateContextualMessage(
        for habit: Habit,
        scheduling: SchedulingRecommendation,
        prediction: StreakPrediction
    ) async -> String {
        let prompt = "Generate a short, motivational reminder for \(habit.name) at \(scheduling.optimalTime):00. Success probability is \(Int(prediction.probability * 100))%. Recommended action: \(prediction.recommendedAction)."
        if let content = await performAICall(prompt: prompt) {
            return content.body
        }
        return "You've got this! \(prediction.recommendedAction)"
    }

    private func determineInterruptionLevel(habit: Habit, successRate: Double) -> UNNotificationInterruptionLevel {
        // High-priority for struggling streaks, low for established ones
        if habit.streak > 7, successRate > 0.7 {
            .passive
        } else if successRate < 0.3 {
            .timeSensitive
        } else {
            .active
        }
    }

    private func selectOptimalSound(for category: HabitCategory) -> UNNotificationSound {
        switch category {
        case .health, .fitness:
            UNNotificationSound(named: UNNotificationSoundName("energetic_chime.wav"))
        case .learning, .productivity:
            UNNotificationSound(named: UNNotificationSoundName("focused_bell.wav"))
        case .mindfulness, .social:
            UNNotificationSound(named: UNNotificationSoundName("gentle_tone.wav"))
        default:
            .default
        }
    }
}
