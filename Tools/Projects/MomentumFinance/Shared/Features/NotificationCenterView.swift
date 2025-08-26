//
//  NotificationCenterView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftData
import SwiftUI
@preconcurrency import UserNotifications

/// Centralized notification center for viewing and managing smart alerts
@MainActor
struct NotificationCenterView: View {
    @Environment(\.dismiss)
    private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared

<<<<<<< HEAD
    @Query private var budgets: [Budget]
    @Query private var subscriptions: [Subscription]
    @Query private var accounts: [FinancialAccount]
=======
    #if canImport(SwiftData)
        #if canImport(SwiftData)
            private var budgets: [Budget] = []
            private var subscriptions: [Subscription] = []
            private var accounts: [FinancialAccount] = []
        #else
            private var budgets: [Budget] = []
            private var subscriptions: [Subscription] = []
            private var accounts: [FinancialAccount] = []
        #endif
    #else
        private var budgets: [Budget] = []
        private var subscriptions: [Subscription] = []
        private var accounts: [FinancialAccount] = []
    #endif
>>>>>>> 1cf3938 (Create working state for recovery)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if notificationManager.pendingNotifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    notificationsList()
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !notificationManager.pendingNotifications.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button("Clear All") {
                            notificationManager.clearAllNotifications()
                        }
                    }
                }
            }
        }
        .task {
            await loadNotifications()
        }
    }

    private func loadNotifications() async {
<<<<<<< HEAD
        notificationManager.pendingNotifications = await notificationManager.getPendingNotifications()
=======
        notificationManager.pendingNotifications =
            await notificationManager.getPendingNotifications()
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    @ViewBuilder
    private func notificationsList() -> some View {
        List {
            ForEach(notificationManager.pendingNotifications, id: \.id) { notification in
                ScheduledNotificationRow(
                    notification: notification,
                    onDismiss: {
                        dismissNotification(notification)
                    },
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func dismissNotification(_ notification: ScheduledNotification) {
        notificationManager.pendingNotifications.removeAll { $0.id == notification.id }
<<<<<<< HEAD
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
=======
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            notification.id
        ])
>>>>>>> 1cf3938 (Create working state for recovery)
    }
}

// MARK: - Empty Notifications View

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Notifications")
                .font(.title2.bold())
                .foregroundColor(.primary)

            Text("You're all caught up! Any important financial alerts will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Scheduled Notification Row

struct ScheduledNotificationRow: View {
    let notification: ScheduledNotification
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Notification Type Icon
            Image(systemName: iconForType(notification.type))
                .font(.title2)
                .foregroundColor(colorForType(notification.type))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(colorForType(notification.type).opacity(0.1)),
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)

            // Notification Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if let date = notification.scheduledDate {
                        Text(date.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(notification.body)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Dismiss Button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighPriority ? Color.red.opacity(0.05) : Color.clear),
<<<<<<< HEAD
            )
=======
        )
>>>>>>> 1cf3938 (Create working state for recovery)
    }

    private var isHighPriority: Bool {
        notification.type.contains("exceeded") || notification.type.contains("critical")
    }

    private func iconForType(_ type: String) -> String {
        if type.contains("budget") {
            "chart.pie.fill"
        } else if type.contains("subscription") {
            "arrow.clockwise.circle.fill"
        } else if type.contains("goal") {
            "target"
        } else {
            "bell.fill"
        }
    }

    private func colorForType(_ type: String) -> Color {
        if type.contains("budget") {
            if type.contains("exceeded") {
                .red
            } else {
                .orange
            }
        } else if type.contains("subscription") {
            .blue
        } else if type.contains("goal") {
            .green
        } else {
            .gray
        }
    }
}

#Preview {
    NotificationCenterView()
}
