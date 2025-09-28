import Foundation
import SwiftData

/// Stores notification timing and frequency preferences for a specific habit.
@Model
final class NotificationPreference {
    var id: UUID
    var habitId: UUID
    var preferredHour: Int
    var frequencyMultiplier: Double
    var confidence: Double
    var lastAdjusted: Date

    init(
        habitId: UUID,
        preferredHour: Int,
        frequencyMultiplier: Double = 1.0,
        confidence: Double = 0.5,
        lastAdjusted: Date = Date()
    ) {
        self.id = UUID()
        self.habitId = habitId
        self.preferredHour = preferredHour
        self.frequencyMultiplier = frequencyMultiplier
        self.confidence = confidence
        self.lastAdjusted = lastAdjusted
    }
}

/// Captures individual notification interactions for behavioral analytics.
@Model
final class NotificationInteractionLog {
    var id: UUID
    var habitId: UUID
    var interaction: NotificationInteraction
    var timestamp: Date
    var scheduledHour: Int
    var responseDelay: TimeInterval?

    init(
        habitId: UUID,
        interaction: NotificationInteraction,
        timestamp: Date,
        scheduledHour: Int,
        responseDelay: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.habitId = habitId
        self.interaction = interaction
        self.timestamp = timestamp
        self.scheduledHour = scheduledHour
        self.responseDelay = responseDelay
    }
}
