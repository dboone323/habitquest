//
//  CloudKitSubscriptionExtensions.swift
//  PlannerApp
//
//  CloudKit subscription management extensions
//

import CloudKit

// MARK: - CloudKit Subscriptions Extensions

extension CloudKitManager {
    /// Set up CloudKit subscriptions for silent push notifications when data changes
    func setupCloudKitSubscriptions() async {
        do {
            // Subscription for tasks
            let taskSubscription = CKQuerySubscription(
                recordType: "Task",
                predicate: NSPredicate(value: true),
                subscriptionID: "TaskSubscription",
                options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
            )

            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true // Silent push
            taskSubscription.notificationInfo = notificationInfo

            try await self.database.save(taskSubscription)

            // Similar subscriptions for Goals, JournalEntries, and CalendarEvents
            let goalSubscription = CKQuerySubscription(
                recordType: "Goal",
                predicate: NSPredicate(value: true),
                subscriptionID: "GoalSubscription",
                options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
            )
            goalSubscription.notificationInfo = notificationInfo

            try await self.database.save(goalSubscription)

            print("CloudKit subscriptions set up successfully")
        } catch {
            print("Error setting up CloudKit subscriptions: \(error.localizedDescription)")
        }
    }

    /// Handle incoming silent push notification
    func handleDatabaseNotification(_: CKDatabaseNotification) async {
        print("Received database change notification, initiating sync")
        await self.performFullSync()
    }
}
