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
                    .accessibilityLabel("Done")
                }

                if !notificationManager.pendingNotifications.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button("Clear All") {
                            notificationManager.clearAllNotifications()
                        }
                        .accessibilityLabel("Clear All")
                    }
                }
            }
        }
        .task {
            await loadNotifications()
        }
    }

    private func loadNotifications() async {
        notificationManager.pendingNotifications =
            await notificationManager.getPendingNotifications()
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
                    )
            }
        }
        .listStyle(PlainListStyle())
    }

    private func dismissNotification(_ notification: ScheduledNotification) {
        notificationManager.pendingNotifications.removeAll { $0.id == notification.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            notification.id
        ])
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
                    )

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
            .accessibilityLabel("Dismiss notification")
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighPriority ? Color.red.opacity(0.05) : Color.clear),
            )
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
