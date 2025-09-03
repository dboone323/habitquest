//
//  NotificationTypes.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import UserNotifications

/// Supporting types and enums for the notification system
struct NotificationTypes {
    // This serves as a namespace for notification-related types
}

// MARK: - Notification Urgency

/// Represents the urgency level of a notification
enum NotificationUrgency {
    case low, medium, high, critical

    /// Title text for the notification based on urgency level
    var title: String {
        switch self {
        case .low:
            "Budget Update"
        case .medium:
            "Budget Warning"
        case .high:
            "Budget Alert"
        case .critical:
            "Budget Exceeded!"
        }
    }

    /// Sound for the notification based on urgency level
    var sound: UNNotificationSound {
        switch self {
        case .low, .medium:
            .default
        case .high:
            UNNotificationSound(named: UNNotificationSoundName("alert.caf"))
        case .critical:
            .defaultCritical
        }
    }
}

// MARK: - Scheduled Notification Model

/// Represents a scheduled notification with its metadata
public struct ScheduledNotification: Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let type: String
    public let scheduledDate: Date?

    public init(id: String, title: String, body: String, type: String, scheduledDate: Date?) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.scheduledDate = scheduledDate
    }
}
