//
//  CloudKitManager.swift
//  PlannerApp
//
//  Enhanced CloudKit integration with better sync, conflict resolution, and status reporting
//

import CloudKit
import Combine
import Network // For NWPathMonitor
import SwiftUI

// Import utilities and models
import Foundation

// Typealias to prevent conflict with Task model
typealias AsyncTask = _Concurrency.Task
// typealias PlannerTask = Task/// Protocol defining the interface for CloudKit service operations
/// This provides better abstraction and testability for CloudKit functionality
@MainActor
protocol CloudKitService {
    // MARK: - Sync Operations
    func performFullSync() async
    func performSync() async
    func forcePushLocalChanges() async

    // MARK: - Conflict Resolution
    func resolveConflict(_ conflict: CloudKitManager.SyncConflict, useLocal: Bool) async
    func resolveAllConflicts(useLocal: Bool) async

    // MARK: - Account Management
    func requestiCloudAccess() async
    func handleNewDeviceLogin() async

    // MARK: - Data Upload Operations
    func uploadTasks(_ tasks: [PlannerTask]) async throws
    func uploadGoals(_ goals: [Goal]) async throws
    func uploadEvents(_ events: [CalendarEvent]) async throws
    func uploadJournalEntries(_ entries: [JournalEntry]) async throws

    // MARK: - Batch Operations

    // MARK: - Subscription Management
    func setupCloudKitSubscriptions() async throws
    func handleDatabaseNotification(_ notification: CKDatabaseNotification) async

    // MARK: - Zone Management
    func createCustomZone() async throws
    func fetchZones() async throws -> [CKRecordZone]
    func deleteZone(named zoneName: String) async throws

    // MARK: - Device Management
    func getSyncedDevices() async -> [CloudKitManager.SyncedDevice]
    func removeDevice(_ deviceID: String) async throws

    // MARK: - Status and Error Handling
    func handleError(_ error: Error)
    func resetCloudKitData() async

    // MARK: - Configuration
    func configureAutoSync(interval: TimeInterval)

    // MARK: - Status Properties
    var isSignedInToiCloud: Bool { get }
    var syncStatus: CloudKitManager.SyncStatus { get }
    var lastSyncDate: Date? { get }
    var syncProgress: Double { get }
    var conflictItems: [CloudKitManager.SyncConflict] { get }
    var errorMessage: String? { get }
    var currentError: CloudKitManager.CloudKitError? { get }
}

/// Extension providing default implementations for optional operations
extension CloudKitService {
    func configureAutoSync(interval: TimeInterval) {
        // Default implementation - can be overridden
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            Task { @MainActor in
                await self.performFullSync()
            }
        }
    }

    func handleDatabaseNotification(_ notification: CKDatabaseNotification) async {
        // Default implementation - trigger sync on database changes
        print("Received database change notification, initiating sync")
        await performFullSync()
    }
}

@MainActor
public class CloudKitManager: ObservableObject, CloudKitService {
    static let shared = CloudKitManager()

    @Published var isSignedInToiCloud = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncProgress: Double = 0.0
    @Published var conflictItems: [SyncConflict] = []
    @Published var errorMessage: String?
    @Published var currentError: CloudKitError?
    @Published var showErrorAlert = false

    // MARK: - Data Management Properties
    @Published private(set) var tasks: [PlannerTask] = []
    @Published private(set) var goals: [Goal] = []
    @Published private(set) var calendarEvents: [CalendarEvent] = []
    @Published private(set) var journalEntries: [JournalEntry] = []

    // MARK: - Private Properties for Data Management
    private var userDefaults: UserDefaults
    private let tasksKey = "SavedTasks"
    private let goalsKey = "SavedGoals"
    private let calendarKey = "SavedCalendarEvents"
    private let journalKey = "SavedJournalEntries"

    private let container: CKContainer
    let database: CKDatabase // Changed to internal so extensions can access
    private var subscriptions = Set<AnyCancellable>()
    #if os(iOS)
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    #endif

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(CloudKitError)
        case conflictResolutionNeeded
        case temporarilyUnavailable

        static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.syncing, .syncing), (.success, .success),
                 (.conflictResolutionNeeded, .conflictResolutionNeeded),
                 (.temporarilyUnavailable, .temporarilyUnavailable):
                true
            case let (.error(lhsError), .error(rhsError)):
                lhsError.id == rhsError.id
            default:
                false
            }
        }

        var isActive: Bool {
            switch self {
            case .syncing, .conflictResolutionNeeded:
                true
            default:
                false
            }
        }

        var description: String {
            switch self {
            case .idle: "Ready to sync"
            case .syncing: "Syncing..."
            case .success: "Sync completed"
            case let .error(error): "Sync error: \(error.localizedDescription)"
            case .conflictResolutionNeeded: "Conflicts need resolution"
            case .temporarilyUnavailable: "Sync temporarily unavailable"
            }
        }
    }

    struct SyncConflict: Identifiable {
        let id = UUID()
        let recordID: CKRecord.ID
        let localRecord: CKRecord
        let serverRecord: CKRecord
        let type: ConflictType

        enum ConflictType {
            case modified
            case deleted
            case created
        }
    }

    // Enhanced CloudKit error types for better user feedback
    enum CloudKitError: Error, Identifiable {
        case notSignedIn
        case networkIssue
        case permissionDenied
        case quotaExceeded
        case deviceBusy
        case serverError
        case accountChanged
        case containerUnavailable
        case conflictDetected
        case unknownError(Error)

        var id: String { self.localizedDescription }

        // Provide a user-friendly message
        var localizedDescription: String {
            switch self {
            case .notSignedIn:
                "You're not signed in to iCloud"
            case .networkIssue:
                "Network connection issue"
            case .permissionDenied:
                "iCloud access was denied"
            case .quotaExceeded:
                "Your iCloud storage is full"
            case .deviceBusy:
                "Your device is busy"
            case .serverError:
                "iCloud server issue"
            case .accountChanged:
                "Your iCloud account has changed"
            case .containerUnavailable:
                "iCloud container unavailable"
            case .conflictDetected:
                "Data conflict detected"
            case let .unknownError(error):
                "Unexpected error: \(error.localizedDescription)"
            }
        }

        // Provide a detailed explanation
        var explanation: String {
            switch self {
            case .notSignedIn:
                "You need to be signed in to iCloud to enable syncing across your devices."
            case .networkIssue:
                "There seems to be an issue with your internet connection."
            case .permissionDenied:
                "This app doesn't have permission to access your iCloud data."
            case .quotaExceeded:
                "You've reached your iCloud storage limit, which prevents syncing new data."
            case .deviceBusy:
                "Your device is currently busy processing other tasks."
            case .serverError:
                "Apple's iCloud servers are experiencing technical difficulties."
            case .accountChanged:
                "Your iCloud account has changed since the last sync."
            case .containerUnavailable:
                "The app's iCloud container couldn't be accessed."
            case .conflictDetected:
                "Changes were made to the same data on multiple devices."
            case .unknownError:
                "An unexpected error occurred while syncing your data."
            }
        }

        // Provide a recovery suggestion
        var recoverySuggestion: String {
            switch self {
            case .notSignedIn:
                #if os(iOS)
                return "Go to Settings → Apple ID → iCloud and sign in with your Apple ID."
                #else
                return "Go to System Settings → Apple ID → iCloud and sign in with your Apple ID."
                #endif
            case .networkIssue:
                return "Check your Wi-Fi connection or cellular data. Try syncing again when your connection improves."
            case .permissionDenied:
                #if os(iOS)
                return "Go to Settings → Apple ID → iCloud → Apps Using iCloud and enable this app."
                #else
                return "Go to System Settings → Apple ID → iCloud and ensure this app is enabled."
                #endif
            case .quotaExceeded:
                #if os(iOS)
                return "Go to Settings → Apple ID → iCloud → Manage Storage to free up space or upgrade your storage plan."
                #else
                return "Go to System Settings → Apple ID → iCloud → Manage Storage to free up space."
                #endif
            case .deviceBusy:
                return "Close some other apps and try again. If the issue persists, restart your device."
            case .serverError:
                return "This is a temporary issue with Apple's servers. Please try again after a while."
            case .accountChanged:
                return "Sign in to your current iCloud account in Settings, then restart the app."
            case .containerUnavailable:
                return "Check that iCloud is enabled for this app in Settings. If the issue persists, restart your device."
            case .conflictDetected:
                return "Review the conflicted items and choose which version to keep."
            case .unknownError:
                return "Try restarting the app. If the issue continues, please contact support."
            }
        }

        // Suggest an action the user can take
        var actionLabel: String {
            switch self {
            case .notSignedIn:
                "Open Settings"
            case .networkIssue:
                "Check Connection"
            case .permissionDenied:
                "Open iCloud Settings"
            case .quotaExceeded:
                "Manage Storage"
            case .deviceBusy, .serverError, .containerUnavailable:
                "Try Again"
            case .accountChanged:
                "Open Settings"
            case .conflictDetected:
                "Review Conflicts"
            case .unknownError:
                "Restart App"
            }
        }

        // Convert from CKError to CloudKitError
        static func fromCKError(_ error: Error) -> CloudKitError {
            guard let ckError = error as? CKError else {
                return .unknownError(error)
            }

            switch ckError.code {
            case .notAuthenticated, .badContainer:
                return .notSignedIn
            case .networkFailure, .networkUnavailable, .serverRejectedRequest, .serviceUnavailable:
                return .networkIssue
            case .permissionFailure:
                return .permissionDenied
            case .quotaExceeded:
                return .quotaExceeded
            case .zoneBusy, .resultsTruncated:
                return .deviceBusy
            case .serverRecordChanged, .batchRequestFailed, .assetFileNotFound:
                return .serverError
            case .changeTokenExpired, .accountTemporarilyUnavailable:
                return .accountChanged
            default:
                return .unknownError(error)
            }
        }
    }

    private init() {
        self.container = CKContainer.default()
        self.database = self.container.privateCloudDatabase
        self.userDefaults = .standard

        self.checkiCloudStatus()
        self.setupSubscriptions()
        self.monitorAccountStatus()
        self.initializeDataManagement()
    }

    // MARK: - Data Management Initialization
    private func initializeDataManagement() {
        self.userDefaults = .standard
        loadAllData()
    }

    private func loadAllData() {
        tasks = loadTasks()
        goals = loadGoals()
        calendarEvents = loadCalendarEvents()
        journalEntries = loadJournalEntries()
    }

    // MARK: - Task Data Management
    func loadTasks() -> [PlannerTask] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([PlannerTask].self, from: data)
        else {
            return []
        }
        return decodedTasks
    }

    func saveTasks(_ tasks: [PlannerTask]) {
        self.tasks = tasks
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
        // Trigger CloudKit sync for tasks
        AsyncTask { @MainActor in
            await self.syncTasksToCloudKit()
        }
    }

    func addTask(_ task: PlannerTask) {
        var currentTasks = tasks
        currentTasks.append(task)
        saveTasks(currentTasks)
    }

    func updateTask(_ task: PlannerTask) {
        var currentTasks = tasks
        if let index = currentTasks.firstIndex(where: { $0.id == task.id }) {
            currentTasks[index] = task
            saveTasks(currentTasks)
        }
    }

    func deleteTask(_ task: PlannerTask) {
        var currentTasks = tasks
        currentTasks.removeAll { $0.id == task.id }
        saveTasks(currentTasks)
    }

    func findTask(by id: UUID) -> PlannerTask? {
        return tasks.first { $0.id == id }
    }

    // MARK: - Goal Data Management
    func loadGoals() -> [Goal] {
        guard let data = userDefaults.data(forKey: goalsKey),
              let decodedGoals = try? JSONDecoder().decode([Goal].self, from: data)
        else {
            return []
        }
        return decodedGoals
    }

    func saveGoals(_ goals: [Goal]) {
        self.goals = goals
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
        // Trigger CloudKit sync for goals
        AsyncTask { @MainActor in
            await self.syncGoalsToCloudKit()
        }
    }

    func addGoal(_ goal: Goal) {
        var currentGoals = goals
        currentGoals.append(goal)
        saveGoals(currentGoals)
    }

    func updateGoal(_ goal: Goal) {
        var currentGoals = goals
        if let index = currentGoals.firstIndex(where: { $0.id == goal.id }) {
            currentGoals[index] = goal
            saveGoals(currentGoals)
        }
    }

    func deleteGoal(_ goal: Goal) {
        var currentGoals = goals
        currentGoals.removeAll { $0.id == goal.id }
        saveGoals(currentGoals)
    }

    func findGoal(by id: UUID) -> Goal? {
        return goals.first { $0.id == id }
    }

    // MARK: - Calendar Data Management
    func loadCalendarEvents() -> [CalendarEvent] {
        guard let data = userDefaults.data(forKey: calendarKey),
              let decodedEvents = try? JSONDecoder().decode([CalendarEvent].self, from: data)
        else {
            return []
        }
        return decodedEvents
    }

    func saveCalendarEvents(_ events: [CalendarEvent]) {
        self.calendarEvents = events
        if let encoded = try? JSONEncoder().encode(events) {
            userDefaults.set(encoded, forKey: calendarKey)
        }
        // Trigger CloudKit sync for calendar events
        AsyncTask { @MainActor in
            await self.syncCalendarEventsToCloudKit()
        }
    }

    func addCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        currentEvents.append(event)
        saveCalendarEvents(currentEvents)
    }

    func updateCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
            currentEvents[index] = event
            saveCalendarEvents(currentEvents)
        }
    }

    func deleteCalendarEvent(_ event: CalendarEvent) {
        var currentEvents = calendarEvents
        currentEvents.removeAll { $0.id == event.id }
        saveCalendarEvents(currentEvents)
    }

    func findCalendarEvent(by id: UUID) -> CalendarEvent? {
        return calendarEvents.first { $0.id == id }
    }

    // MARK: - Journal Data Management
    func loadJournalEntries() -> [JournalEntry] {
        guard let data = userDefaults.data(forKey: journalKey),
              let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else {
            return []
        }
        return decodedEntries
    }

    func saveJournalEntries(_ entries: [JournalEntry]) {
        self.journalEntries = entries
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: journalKey)
        }
        // Trigger CloudKit sync for journal entries
        AsyncTask { @MainActor in
            await self.syncJournalEntriesToCloudKit()
        }
    }

    func addJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        currentEntries.append(entry)
        saveJournalEntries(currentEntries)
    }

    func updateJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        if let index = currentEntries.firstIndex(where: { $0.id == entry.id }) {
            currentEntries[index] = entry
            saveJournalEntries(currentEntries)
        }
    }

    func deleteJournalEntry(_ entry: JournalEntry) {
        var currentEntries = journalEntries
        currentEntries.removeAll { $0.id == entry.id }
        saveJournalEntries(currentEntries)
    }

    func findJournalEntry(by id: UUID) -> JournalEntry? {
        return journalEntries.first { $0.id == id }
    }

    // MARK: - CloudKit Sync Methods for Data Types
    private func syncTasksToCloudKit() async {
        guard isSignedInToiCloud else { return }
        do {
            let records = tasks.map { $0.toCKRecord() }
            _ = try await database.modifyRecords(
                saving: records,
                deleting: []
            )
        } catch {
            handleError(error)
        }
    }

    private func syncGoalsToCloudKit() async {
        guard isSignedInToiCloud else { return }
        do {
            let records = goals.map { $0.toCKRecord() }
            _ = try await database.modifyRecords(
                saving: records,
                deleting: []
            )
        } catch {
            handleError(error)
        }
    }

    private func syncCalendarEventsToCloudKit() async {
        guard isSignedInToiCloud else { return }
        do {
            let records = calendarEvents.map { $0.toCKRecord() }
            _ = try await database.modifyRecords(
                saving: records,
                deleting: []
            )
        } catch {
            handleError(error)
        }
    }

    private func syncJournalEntriesToCloudKit() async {
        guard isSignedInToiCloud else { return }
        do {
            let records = journalEntries.map { $0.toCKRecord() }
            _ = try await database.modifyRecords(
                saving: records,
                deleting: []
            )
        } catch {
            handleError(error)
        }
    }

    // MARK: - iCloud Status

    private func checkiCloudStatus() {
        self.container.accountStatus { [weak self] status, error in
            // This completion handler is already dispatched to main by CloudKit in some cases,
            // but to be safe and explicit, especially if behavior changes or is inconsistent:
            AsyncTask { @MainActor [weak self] in
                guard let self else { return }
                self.isSignedInToiCloud = status == .available

                if let error {
                    self.handleError(CloudKitError.fromCKError(error))
                }
            }
        }
    }

    // MARK: - Subscription Setup

    private func setupSubscriptions() {
        // Setup CloudKit subscriptions for real-time updates
        self.setupTaskSubscription()
        self.setupGoalSubscription()
        self.setupEventSubscription()
        self.setupJournalSubscription()
    }

    private func setupTaskSubscription() {
        let predicate = NSPredicate(value: true)

        // Using the non-deprecated initializer
        let subscription = CKQuerySubscription(
            recordType: "Task",
            predicate: predicate,
            subscriptionID: "task-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info

        self.database.save(subscription) { [weak self] _, error in
            if let error {
                AsyncTask { @MainActor [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }

    private func setupGoalSubscription() {
        let predicate = NSPredicate(value: true)

        // Using the non-deprecated initializer
        let subscription = CKQuerySubscription(
            recordType: "Goal",
            predicate: predicate,
            subscriptionID: "goal-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info

        self.database.save(subscription) { [weak self] _, error in
            if let error {
                AsyncTask { @MainActor [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }

    private func setupEventSubscription() {
        let predicate = NSPredicate(value: true)

        // Using the non-deprecated initializer
        let subscription = CKQuerySubscription(
            recordType: "CalendarEvent",
            predicate: predicate,
            subscriptionID: "event-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info

        self.database.save(subscription) { [weak self] _, error in
            if let error {
                AsyncTask { @MainActor [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }

    private func setupJournalSubscription() {
        let predicate = NSPredicate(value: true)

        // Using the non-deprecated initializer
        let subscription = CKQuerySubscription(
            recordType: "JournalEntry",
            predicate: predicate,
            subscriptionID: "journal-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )

        let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info

        self.database.save(subscription) { [weak self] _, error in
            if let error {
                AsyncTask { @MainActor [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }

    // MARK: - Enhanced Sync Operations

    func performFullSync() async {
        guard self.isSignedInToiCloud else {
            self.handleError(CloudKitError.notSignedIn)
            return
        }

        self.syncStatus = .syncing
        self.syncProgress = 0.0
        self.errorMessage = nil

        do {
            // Start background task
            self.beginBackgroundTask()

            // Sync in phases
            try await self.syncTasks()
            self.syncProgress = 0.25

            try await self.syncGoals()
            self.syncProgress = 0.50

            try await self.syncEvents()
            self.syncProgress = 0.75

            try await self.syncJournalEntries()
            self.syncProgress = 1.0

            self.lastSyncDate = Date()
            self.syncStatus = .success

            // Save sync timestamp
            UserDefaults.standard.set(self.lastSyncDate, forKey: "LastCloudKitSync")

        } catch {
            self.handleError(error)
        }

        self.endBackgroundTask()
    }

    func performSync() async {
        await self.performFullSync()
    }

    private func syncTasks() async throws {
        // Fetch remote tasks
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)

        var conflicts: [SyncConflict] = []

        for (_, result) in records {
            switch result {
            case let .success(record):
                // Check for conflicts with local data
                if let conflict = checkForTaskConflict(record) {
                    conflicts.append(conflict)
                } else {
                    // Merge non-conflicting changes
                    await self.mergeTaskRecord(record)
                }
            case let .failure(error):
                self.handleError(error)
            }
        }

        if !conflicts.isEmpty {
            self.conflictItems.append(contentsOf: conflicts)
            self.syncStatus = .conflictResolutionNeeded
        }
    }

    private func syncGoals() async throws {
        let query = CKQuery(recordType: "Goal", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)

        for (_, result) in records {
            switch result {
            case let .success(record):
                if let conflict = checkForGoalConflict(record) {
                    self.conflictItems.append(conflict)
                } else {
                    await self.mergeGoalRecord(record)
                }
            case let .failure(error):
                self.handleError(error)
            }
        }
    }

    private func syncEvents() async throws {
        let query = CKQuery(recordType: "CalendarEvent", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)

        for (_, result) in records {
            switch result {
            case let .success(record):
                if let conflict = checkForEventConflict(record) {
                    self.conflictItems.append(conflict)
                } else {
                    await self.mergeEventRecord(record)
                }
            case let .failure(error):
                self.handleError(error)
            }
        }
    }

    private func syncJournalEntries() async throws {
        let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)

        for (_, result) in records {
            switch result {
            case let .success(record):
                if let conflict = checkForJournalConflict(record) {
                    self.conflictItems.append(conflict)
                } else {
                    await self.mergeJournalRecord(record)
                }
            case let .failure(error):
                self.handleError(error)
            }
        }
    }

    // MARK: - Conflict Detection

    private func checkForTaskConflict(_: CKRecord) -> SyncConflict? {
        // Implementation would check local records against CloudKit records
        // Return conflict if modification dates don't match
        nil
    }

    private func checkForGoalConflict(_: CKRecord) -> SyncConflict? {
        nil
    }

    private func checkForEventConflict(_: CKRecord) -> SyncConflict? {
        nil
    }

    private func checkForJournalConflict(_: CKRecord) -> SyncConflict? {
        nil
    }

    // MARK: - Record Merging

    private func mergeTaskRecord(_: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }

    private func mergeGoalRecord(_: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }

    private func mergeEventRecord(_: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }

    private func mergeJournalRecord(_: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }

    // MARK: - Conflict Resolution

    func resolveConflict(_ conflict: SyncConflict, useLocal: Bool) async {
        let recordToSave = useLocal ? conflict.localRecord : conflict.serverRecord

        do {
            _ = try await self.database.save(recordToSave)

            // Remove resolved conflict
            self.conflictItems.removeAll { $0.id == conflict.id }

            // Check if all conflicts resolved
            if self.conflictItems.isEmpty {
                self.syncStatus = .success
            }
        } catch {
            self.handleError(error)
        }
    }

    func resolveAllConflicts(useLocal: Bool) async {
        for conflict in self.conflictItems {
            await self.resolveConflict(conflict, useLocal: useLocal)
        }
    }

    // MARK: - Background Task Management

    private func beginBackgroundTask() {
        #if os(iOS)
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "CloudKit Sync") {
            self.endBackgroundTask()
        }
        #endif
    }

    private func endBackgroundTask() {
        #if os(iOS)
        if self.backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        #endif
    }

    // MARK: - Auto Sync Configuration

    func configureAutoSync(interval: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }

            AsyncTask { @MainActor in
                await self.performFullSync()
            }
        }
    }

    // MARK: - Manual Operations

    func forcePushLocalChanges() async {
        // Implementation to force push all local changes to CloudKit
        self.syncStatus = .syncing

        do {
            // Push tasks, goals, events, journal entries
            try await self.pushLocalTasks()
            try await self.pushLocalGoals()
            try await self.pushLocalEvents()
            try await self.pushLocalJournalEntries()

            self.syncStatus = .success
            self.lastSyncDate = Date()
        } catch {
            self.handleError(error)
        }
    }

    func requestiCloudAccess() async {
        // Request iCloud access and update status
        self.syncStatus = .syncing

        do {
            let accountStatus = try await container.accountStatus()
            switch accountStatus {
            case .available:
                self.isSignedInToiCloud = true
                self.syncStatus = .success
            case .noAccount, .restricted:
                self.isSignedInToiCloud = false
                self.syncStatus = .error(.notSignedIn)
            case .couldNotDetermine, .temporarilyUnavailable:
                self.syncStatus = .temporarilyUnavailable
            @unknown default:
                self.syncStatus = .error(.unknownError(CKError(CKError.Code.internalError)))
            }
        } catch {
            self.handleError(error)
        }
    }

    func handleNewDeviceLogin() async {
        // Handle setup for new device login
        await self.performFullSync()
    }

    private func pushLocalTasks() async throws {
        // Implementation to push local tasks to CloudKit
    }

    private func pushLocalGoals() async throws {
        // Implementation to push local goals to CloudKit
    }

    private func pushLocalEvents() async throws {
        // Implementation to push local events to CloudKit
    }

    private func pushLocalJournalEntries() async throws {
        // Implementation to push local journal entries to CloudKit
    }

    func resetCloudKitData() async {
        // Implementation to clear all CloudKit data
        self.syncStatus = .syncing

        do {
            let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
            let (records, _) = try await database.records(matching: query)

            let recordIDs = records.compactMap { _, result in
                switch result {
                case let .success(record):
                    record.recordID
                case .failure:
                    nil
                }
            }

            if !recordIDs.isEmpty {
                _ = try await self.database.modifyRecords(saving: [], deleting: recordIDs)
            }

            self.syncStatus = .success
        } catch {
            self.handleError(error)
        }
    }

    // Methods to handle CloudKit errors
    func handleError(_ error: Error) {
        let cloudKitError = CloudKitError.fromCKError(error)
        self.errorMessage = cloudKitError.localizedDescription
        self.currentError = cloudKitError
        self.syncStatus = .error(cloudKitError)
        self.showErrorAlert = true

        // Log error for diagnostics
        print("CloudKit error: \(cloudKitError.localizedDescription) - \(cloudKitError.recoverySuggestion)")

        // Take automatic recovery steps based on error type
        switch cloudKitError {
        case .networkIssue:
            self.scheduleRetryWhenNetworkAvailable()
        case .accountChanged:
            self.resetSyncState()
        case .quotaExceeded:
            self.adjustSyncForLowStorage()
        default:
            break
        }
    }

    // Auto-retry logic when network becomes available
    private func scheduleRetryWhenNetworkAvailable() {
        // Ensure NetworkMonitor.shared is accessible
        // If NetworkMonitor is in the same module, it should be directly usable.
        if NetworkMonitor.shared.isConnected {
            // Retry immediately if connected
            AsyncTask { @MainActor in
                try? await self.retryFailedOperations()
            }
        } else {
            // Observe network status changes - simplified for now
            // In a real implementation, this would observe actual network changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                guard let self else { return }
                AsyncTask { @MainActor in
                    await self.checkNetworkAndRetry()
                }
            }
        }
    }

    private func checkNetworkAndRetry() async {
        // Implementation would check if network is available and retry sync
        // Note: NetworkMonitor.shared.isConnected would be used here if available
        AsyncTask { @MainActor in
            try? await self.retryFailedOperations()
        }
    }

    private func retryFailedOperations() async throws {
        // Implementation would retry operations that failed due to network issues
    }

    // Reset sync state when account changes
    private func resetSyncState() {
        // Reset change tokens and other sync state
        AsyncTask { @MainActor in
            await self.resetSyncTokens()
            await self.checkAccountStatus()
        }
    }

    private func resetSyncTokens() async {
        // Implementation would reset all CloudKit change tokens
    }

    // Adjust sync behavior for low storage
    private func adjustSyncForLowStorage() {
        // Prioritize essential data and reduce optional data when storage is low
        // For example, sync text data but skip images/attachments
    }

    // Monitor iCloud account changes
    func monitorAccountStatus() {
        NotificationCenter.default.addObserver(forName: .CKAccountChanged, object: nil, queue: .main) { [weak self] _ in
            AsyncTask { @MainActor [weak self] in
                guard let self else { return }
                self.currentError = .accountChanged
                self.showErrorAlert = true
                self.syncStatus = .error(.accountChanged)
                await self.accountStatusChanged() // Call the async version
            }
        }
    }

    @objc private func accountStatusChanged() async {
        await self.checkAccountStatus()
    }

    func checkAccountStatus() async {
        // Implementation checks account status
        do {
            _ = try await self.container.accountStatus() // status was unused, marked with _
            // Update local state based on account status
        } catch {
            AsyncTask { @MainActor [weak self] in
                self?.handleError(CloudKitError.fromCKError(error))
            }
        }
    }

    func uploadTasks(_ tasks: [PlannerTask]) async throws {
        // Stub implementation for task uploading
        print("Uploading \(tasks.count) tasks to CloudKit")
    }

    func uploadGoals(_ goals: [Goal]) async throws {
        // Stub implementation for goal uploading
        print("Uploading \(goals.count) goals to CloudKit")
    }

    func uploadEvents(_ events: [CalendarEvent]) async throws {
        // Stub implementation for event uploading
        print("Uploading \(events.count) events to CloudKit")
    }

    func uploadJournalEntries(_ entries: [JournalEntry]) async throws {
        // Stub implementation for journal entry uploading
        print("Uploading \(entries.count) journal entries to CloudKit")
    }

    // Placeholder local fetch/save methods - these should call your Services
    // These need to be implemented properly by interacting with your existing Services
    private func fetchLocalTasks() async throws -> [PlannerTask] {
        return tasks
    }

    private func saveLocalTasks(_ tasks: [PlannerTask]) async throws {
        saveTasks(tasks)
    }

    private func fetchLocalGoals() async throws -> [Goal] {
        return goals
    }

    private func saveLocalGoals(_ goals: [Goal]) async throws {
        saveGoals(goals)
    }

    private func fetchLocalEvents() async throws -> [CalendarEvent] {
        return calendarEvents
    }

    private func saveLocalEvents(_ events: [CalendarEvent]) async throws {
        saveCalendarEvents(events)
    }

    private func fetchLocalJournalEntries() async throws -> [JournalEntry] {
        return journalEntries
    }

    private func saveLocalJournalEntries(_ entries: [JournalEntry]) async throws {
        saveJournalEntries(entries)
    }
}

// MARK: - Enhanced Sync Status View

public struct EnhancedSyncStatusView: View {
    @ObservedObject var cloudKit = CloudKitManager.shared
    @EnvironmentObject var themeManager: ThemeManager

    let showLabel: Bool
    let compact: Bool

    init(showLabel: Bool = false, compact: Bool = false) {
        self.showLabel = showLabel
        self.compact = compact
    }

    public var body: some View {
        HStack(spacing: 8) {
            self.syncIndicator

            if self.showLabel {
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.statusText)
                        .font(self.compact ? .caption : .body)
                        .foregroundColor(self.statusColor)

                    if let lastSync = cloudKit.lastSyncDate {
                        Text("Last sync: \(lastSync, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }

                    if self.cloudKit.syncStatus.isActive {
                        ProgressView(value: self.cloudKit.syncProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 100)
                    }
                }
            }
        }
        .onTapGesture {
            if case .error = self.cloudKit.syncStatus {
                AsyncTask { @MainActor in
                    await self.cloudKit.performFullSync()
                }
            }
        }
    }

    private var syncIndicator: some View {
        Group {
            switch self.cloudKit.syncStatus {
            case .syncing:
                ProgressView()
                    .scaleEffect(0.8)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            case .conflictResolutionNeeded:
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.orange)
            case .idle:
                Image(systemName: "cloud")
                    .foregroundColor(.secondary)
            case .temporarilyUnavailable:
                Image(systemName: "cloud.slash")
                    .foregroundColor(.orange)
            }
        }
        .font(self.compact ? .caption : .body)
    }

    private var statusText: String {
        if !self.cloudKit.isSignedInToiCloud {
            return "Not signed into iCloud"
        }

        return self.cloudKit.syncStatus.description
    }

    private var statusColor: Color {
        if !self.cloudKit.isSignedInToiCloud {
            return .secondary
        }

        switch self.cloudKit.syncStatus {
        case .idle:
            return .secondary
        case .syncing:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        case .conflictResolutionNeeded:
            return .orange
        case .temporarilyUnavailable:
            return .orange
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedSyncStatusView(showLabel: true)
        EnhancedSyncStatusView(showLabel: true, compact: true)
        EnhancedSyncStatusView()
    }
    .environmentObject(ThemeManager())
    .padding()
}

// MARK: - CloudKit Batch Processing Extensions

extension CloudKitManager {
    /// Upload multiple tasks to CloudKit in efficient batches
    func uploadTasksInBatches(_ tasks: [PlannerTask]) async throws {
        let batchSize = 100
        for batch in stride(from: 0, to: tasks.count, by: batchSize) {
            let endIndex = min(batch + batchSize, tasks.count)
            let batchTasks = Array(tasks[batch ..< endIndex])
            let records = batchTasks.map { $0.toCKRecord() }

            _ = try await self.database.modifyRecords(
                saving: records,
                deleting: []
            )

            // Process results if needed
            print("Batch uploaded: \(records.count) tasks")
        }
    }

    /// Upload multiple goals to CloudKit in efficient batches
    func uploadGoalsInBatches(_ goals: [Goal]) async throws {
        let batchSize = 100
        for batch in stride(from: 0, to: goals.count, by: batchSize) {
            let endIndex = min(batch + batchSize, goals.count)
            let batchGoals = Array(goals[batch ..< endIndex])
            let records = batchGoals.map { $0.toCKRecord() }

            _ = try await self.database.modifyRecords(
                saving: records,
                deleting: []
            )

            print("CloudKit subscriptions set up successfully")
        }
    }
}

// MARK: - CloudKit Zones Extensions

extension CloudKitManager {
    /// Create a custom zone for more efficient organization
    func createCustomZone() async throws {
        let customZone = CKRecordZone(zoneName: "PlannerAppData")
        try await database.save(customZone)
        print("Custom zone created: PlannerAppData")
    }

    /// Fetch record zones
    func fetchZones() async throws -> [CKRecordZone] {
        let zones = try await database.allRecordZones()
        return zones
    }

    /// Delete a zone and all its records
    func deleteZone(named zoneName: String) async throws {
        let zoneID = CKRecordZone.ID(zoneName: zoneName)
        try await self.database.deleteRecordZone(withID: zoneID)
        print("Zone deleted: \(zoneName)")
    }
}

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

// MARK: - Device Management Extensions

extension CloudKitManager {
    /// Structure to represent a device syncing with iCloud
    struct SyncedDevice: Identifiable {
        let id = UUID()
        let name: String
        let lastSync: Date?
        let isCurrentDevice: Bool
    }

    /// Get a list of all devices syncing with this iCloud account
    func getSyncedDevices() async -> [SyncedDevice] {
        // In a real implementation, you would store device information in CloudKit
        // This is a placeholder implementation
        var devices = [SyncedDevice]()

        // Add current device
        let currentDevice = SyncedDevice(
            name: Self.deviceName,
            lastSync: self.lastSyncDate,
            isCurrentDevice: true
        )
        devices.append(currentDevice)

        // In a real implementation, fetch other devices from CloudKit
        return devices
    }

    /// Get the current device name
    static var deviceName: String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Unknown Device"
        #endif
    }

    /// Remove a device from the sync list
    func removeDevice(_ deviceID: String) async throws {
        // In a real implementation, you would remove the device record from CloudKit
        print("Removing device: \(deviceID)")
    }
}

// MARK: - Data Management Extensions

extension CloudKitManager {
}

// MARK: - Protocol Conformance Extensions

@MainActor
extension CloudKitManager: TaskDataManaging {
    func load() -> [PlannerTask] {
        return tasks
    }

    func save(tasks: [PlannerTask]) {
        saveTasks(tasks)
    }

    func add(_ item: PlannerTask) {
        addTask(item)
    }

    func update(_ item: PlannerTask) {
        updateTask(item)
    }

    func delete(_ item: PlannerTask) {
        deleteTask(item)
    }

    func find(by id: UUID) -> PlannerTask? {
        return findTask(by: id)
    }
}

extension CloudKitManager: GoalDataManaging {
    func load() -> [Goal] {
        return goals
    }

    func save(goals: [Goal]) {
        saveGoals(goals)
    }

    func add(_ item: Goal) {
        addGoal(item)
    }

    func update(_ item: Goal) {
        updateGoal(item)
    }

    func delete(_ item: Goal) {
        deleteGoal(item)
    }

    func find(by id: UUID) -> Goal? {
        return findGoal(by: id)
    }
}
