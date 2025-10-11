//
//  NotificationsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI
import UserNotifications

/// Notification center for managing smart alerts and system notifications
@MainActor
public struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var notificationManager = NotificationManager.shared
    @State private var pendingNotifications: [ScheduledNotification] = []
    @State private var selectedFilter: NotificationFilter = .all
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Header
                self.filterHeaderView

                // Notifications List
                if self.isLoading {
                    ProgressView("Loading notifications...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if self.filteredNotifications.isEmpty {
                    self.emptyStateView
                } else {
                    self.notificationsList
                }
            }
            .navigationTitle("Notifications")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(
                            "Clear All",
                            action: {
                                self.clearAllNotifications()
                            }
                        )
                        .accessibilityLabel("Button")
                        .foregroundColor(.red)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            "Done",
                            action: {
                                self.dismiss()
                            }
                        )
                        .accessibilityLabel("Button")
                    }
                    #else
                    ToolbarItem {
                        Button(
                            "Clear All",
                            action: {
                                self.clearAllNotifications()
                            }
                        )
                        .accessibilityLabel("Button")
                        .foregroundColor(.red)
                    }

                    ToolbarItem {
                        Button(
                            "Done",
                            action: {
                                self.dismiss()
                            }
                        )
                        .accessibilityLabel("Button")
                    }
                    #endif
                }
                .task {
                    await self.loadNotifications()
                }
        }
    }

    // MARK: - Filter Header

    private var filterHeaderView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: self.selectedFilter == filter,
                        count: self.getNotificationCount(for: filter),
                    ) {
                        self.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }

    // MARK: - Notifications List

    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(self.filteredNotifications, id: \.id) { notification in
                    NotificationRow(
                        notification: notification,
                        onTap: {
                            self.handleNotificationTap(notification)
                        },
                        onDismiss: {
                            self.dismissNotification(notification)
                        },
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Notifications")
                .font(.title2.weight(.medium))
                .foregroundColor(.primary)

            Text(
                "You're all caught up! Notifications will appear here when you have budget alerts, upcoming payments, or goal milestones."
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var filteredNotifications: [ScheduledNotification] {
        switch self.selectedFilter {
        case .all:
            self.pendingNotifications
        case .budgets:
            self.pendingNotifications.filter { $0.type.contains("budget") }
        case .subscriptions:
            self.pendingNotifications.filter { $0.type.contains("subscription") }
        case .goals:
            self.pendingNotifications.filter { $0.type.contains("goal") }
        }
    }

    // MARK: - Helper Methods

    private func getNotificationCount(for filter: NotificationFilter) -> Int {
        switch filter {
        case .all:
            self.pendingNotifications.count
        case .budgets:
            self.pendingNotifications.count(where: { $0.type.contains("budget") })
        case .subscriptions:
            self.pendingNotifications.count(where: { $0.type.contains("subscription") })
        case .goals:
            self.pendingNotifications.count(where: { $0.type.contains("goal") })
        }
    }

    private func loadNotifications() async {
        self.isLoading = true
        self.pendingNotifications = await self.notificationManager.getPendingNotifications()
        self.isLoading = false
    }

    private func handleNotificationTap(_ notification: ScheduledNotification) {
        Task { @MainActor in
            // Navigate based on notification type
            let coordinator = NavigationCoordinator.shared

            switch notification.type {
            case let type where type.contains("budget"):
                coordinator.navigateToBudgets()
            case let type where type.contains("subscription"):
                coordinator.navigateToSubscriptions()
            case let type where type.contains("goal"):
                coordinator.navigateToGoals()
            default:
                break
            }

            self.dismiss()
        }
    }

    private func dismissNotification(_ notification: ScheduledNotification) {
        // Remove from local list
        self.pendingNotifications.removeAll { $0.id == notification.id }

        // Remove from system
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            notification.id,
        ])
    }

    private func clearAllNotifications() {
        self.notificationManager.clearAllNotifications()
        self.pendingNotifications.removeAll()
    }
}

// MARK: - Filter Types

public enum NotificationFilter: String, CaseIterable {
    case all = "All"
    case budgets = "Budgets"
    case subscriptions = "Subscriptions"
    case goals = "Goals"

    var icon: String {
        switch self {
        case .all: "bell"
        case .budgets: "chart.pie"
        case .subscriptions: "arrow.clockwise.circle"
        case .goals: "target"
        }
    }
}

// MARK: - Filter Button

public struct FilterButton: View {
    let filter: NotificationFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    private var isEmpty: Bool {
        isEmpty
    }

    var body: some View {
        Button(action: self.action).accessibilityLabel("Button") {
            HStack(spacing: 8) {
                Image(systemName: self.filter.icon)
                    .font(.caption)

                Text(self.filter.rawValue)
                    .font(.caption.weight(.medium))

                if !self.isEmpty {
                    Text("\(self.count)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(.red, in: Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                self.isSelected ? Color.blue : Color.gray.opacity(0.2),
            )
            .foregroundColor(
                self.isSelected ? .white : .primary,
            )
            .cornerRadius(20)
        }
        .accessibilityLabel("Button")
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Notification Row

public struct NotificationRow: View {
    let notification: ScheduledNotification
    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Type Icon
            Circle()
                .fill(self.notificationTypeColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: self.notificationTypeIcon)
                        .font(.title3)
                        .foregroundColor(self.notificationTypeColor)
                }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(self.notification.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(self.notification.body)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if let date = notification.scheduledDate {
                    Text("Scheduled for \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Actions
            VStack(spacing: 8) {
                Button(
                    "View",
                    action: {
                        self.onTap()
                    }
                )
                .font(.caption.weight(.medium))
                .foregroundColor(.blue)
                .accessibilityLabel("Button")

                Button(
                    "Dismiss",
                    action: {
                        self.onDismiss()
                    }
                )
                .font(.caption.weight(.medium))
                .foregroundColor(.red)
                .accessibilityLabel("Button")
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(
                "Dismiss",
                action: {
                    self.onDismiss()
                }
            )
            .tint(.red)
            .accessibilityLabel("Button")
        }
    }

    private var notificationTypeColor: Color {
        switch self.notification.type {
        case let type where type.contains("budget"):
            .orange
        case let type where type.contains("subscription"):
            .blue
        case let type where type.contains("goal"):
            .purple
        default:
            .gray
        }
    }

    private var notificationTypeIcon: String {
        switch self.notification.type {
        case let type where type.contains("budget"):
            "chart.pie.fill"
        case let type where type.contains("subscription"):
            "arrow.clockwise.circle.fill"
        case let type where type.contains("goal"):
            "target"
        default:
            "bell.fill"
        }
    }
}

#Preview {
    NotificationsView()
}
