//
//  EnhancedCloudKitManager.swift
//  PlannerApp
//
//  Enhanced CloudKit integration with better sync, conflict resolution, and status reporting
//

import SwiftUI
import CloudKit
import Combine
import Network // For NWPathMonitor

// Typealias to prevent conflict with Task model
typealias AsyncTask = _Concurrency.Task

@MainActor
class EnhancedCloudKitManager: ObservableObject {
    static let shared = EnhancedCloudKitManager()
    
    @Published var isSignedInToiCloud = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncProgress: Double = 0.0
    @Published var conflictItems: [SyncConflict] = []
    @Published var errorMessage: String?
    @Published var currentError: CloudKitError?
    @Published var showErrorAlert = false
    
    private let container: CKContainer
    private let database: CKDatabase
    private var subscriptions = Set<AnyCancellable>()
    #if os(iOS)
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    #endif
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(CloudKitError)
        case conflictResolutionNeeded
        case temporarilyUnavailable
        
        var isActive: Bool {
            switch self {
            case .syncing, .conflictResolutionNeeded:
                return true
            default:
                return false
            }
        }
        
        var description: String {
            switch self {
            case .idle: return "Ready to sync"
            case .syncing: return "Syncing..."
            case .success: return "Sync completed"
            case .error(let error): return "Sync error: \(error.localizedDescription)"
            case .conflictResolutionNeeded: return "Conflicts need resolution"
            case .temporarilyUnavailable: return "Sync temporarily unavailable"
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
        
        var id: String { localizedDescription }
        
        // Provide a user-friendly message
        var localizedDescription: String {
            switch self {
            case .notSignedIn:
                return "You're not signed in to iCloud"
            case .networkIssue:
                return "Network connection issue"
            case .permissionDenied:
                return "iCloud access was denied"
            case .quotaExceeded:
                return "Your iCloud storage is full"
            case .deviceBusy:
                return "Your device is busy"
            case .serverError:
                return "iCloud server issue"
            case .accountChanged:
                return "Your iCloud account has changed"
            case .containerUnavailable:
                return "iCloud container unavailable"
            case .conflictDetected:
                return "Data conflict detected"
            case .unknownError(let error):
                return "Unexpected error: \(error.localizedDescription)"
            }
        }
        
        // Provide a detailed explanation
        var explanation: String {
            switch self {
            case .notSignedIn:
                return "You need to be signed in to iCloud to enable syncing across your devices."
            case .networkIssue:
                return "There seems to be an issue with your internet connection."
            case .permissionDenied:
                return "This app doesn't have permission to access your iCloud data."
            case .quotaExceeded:
                return "You've reached your iCloud storage limit, which prevents syncing new data."
            case .deviceBusy:
                return "Your device is currently busy processing other tasks."
            case .serverError:
                return "Apple's iCloud servers are experiencing technical difficulties."
            case .accountChanged:
                return "Your iCloud account has changed since the last sync."
            case .containerUnavailable:
                return "The app's iCloud container couldn't be accessed."
            case .conflictDetected:
                return "Changes were made to the same data on multiple devices."
            case .unknownError:
                return "An unexpected error occurred while syncing your data."
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
                return "Open Settings"
            case .networkIssue:
                return "Check Connection"
            case .permissionDenied:
                return "Open iCloud Settings"
            case .quotaExceeded:
                return "Manage Storage"
            case .deviceBusy, .serverError, .containerUnavailable:
                return "Try Again"
            case .accountChanged:
                return "Open Settings"
            case .conflictDetected:
                return "Review Conflicts"
            case .unknownError:
                return "Restart App"
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
        container = CKContainer.default()
        database = container.privateCloudDatabase
        
        checkiCloudStatus()
        setupSubscriptions()
        monitorAccountStatus()
    }
    
    // MARK: - iCloud Status
    private func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            // This completion handler is already dispatched to main by CloudKit in some cases,
            // but to be safe and explicit, especially if behavior changes or is inconsistent:
            AsyncTask { @MainActor [weak self] in
                guard let self = self else { return }
                self.isSignedInToiCloud = status == .available
                
                if let error = error {
                    self.handleError(CloudKitError.fromCKError(error))
                }
            }
        }
    }
    
    // MARK: - Subscription Setup
    private func setupSubscriptions() {
        // Setup CloudKit subscriptions for real-time updates
        setupTaskSubscription()
        setupGoalSubscription()
        setupEventSubscription()
        setupJournalSubscription()
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
        
        database.save(subscription) { [weak self] _, error in
            if let error = error {
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
        
        database.save(subscription) { [weak self] _, error in
            if let error = error {
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
        
        database.save(subscription) { [weak self] _, error in
            if let error = error {
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
        
        database.save(subscription) { [weak self] _, error in
            if let error = error {
                AsyncTask { @MainActor [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Enhanced Sync Operations
    func performFullSync() async {
        guard isSignedInToiCloud else {
            handleError(CloudKitError.notSignedIn)
            return
        }
        
        syncStatus = .syncing
        syncProgress = 0.0
        errorMessage = nil
        
        do {
            // Start background task
            beginBackgroundTask()
            
            // Sync in phases
            try await syncTasks()
            syncProgress = 0.25
            
            try await syncGoals()
            syncProgress = 0.50
            
            try await syncEvents()
            syncProgress = 0.75
            
            try await syncJournalEntries()
            syncProgress = 1.0
            
            lastSyncDate = Date()
            syncStatus = .success
            
            // Save sync timestamp
            UserDefaults.standard.set(lastSyncDate, forKey: "LastCloudKitSync")
            
        } catch {
            handleError(error)
        }
        
        endBackgroundTask()
    }
    
    private func syncTasks() async throws {
        // Fetch remote tasks
        let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)
        
        var conflicts: [SyncConflict] = []
        
        for (_, result) in records {
            switch result {
            case .success(let record):
                // Check for conflicts with local data
                if let conflict = checkForTaskConflict(record) {
                    conflicts.append(conflict)
                } else {
                    // Merge non-conflicting changes
                    await mergeTaskRecord(record)
                }
            case .failure(let error):
                handleError(error)
            }
        }
        
        if !conflicts.isEmpty {
            conflictItems.append(contentsOf: conflicts)
            syncStatus = .conflictResolutionNeeded
        }
    }
    
    private func syncGoals() async throws {
        let query = CKQuery(recordType: "Goal", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)
        
        for (_, result) in records {
            switch result {
            case .success(let record):
                if let conflict = checkForGoalConflict(record) {
                    conflictItems.append(conflict)
                } else {
                    await mergeGoalRecord(record)
                }
            case .failure(let error):
                handleError(error)
            }
        }
    }
    
    private func syncEvents() async throws {
        let query = CKQuery(recordType: "CalendarEvent", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)
        
        for (_, result) in records {
            switch result {
            case .success(let record):
                if let conflict = checkForEventConflict(record) {
                    conflictItems.append(conflict)
                } else {
                    await mergeEventRecord(record)
                }
            case .failure(let error):
                handleError(error)
            }
        }
    }
    
    private func syncJournalEntries() async throws {
        let query = CKQuery(recordType: "JournalEntry", predicate: NSPredicate(value: true))
        let (records, _) = try await database.records(matching: query)
        
        for (_, result) in records {
            switch result {
            case .success(let record):
                if let conflict = checkForJournalConflict(record) {
                    conflictItems.append(conflict)
                } else {
                    await mergeJournalRecord(record)
                }
            case .failure(let error):
                handleError(error)
            }
        }
    }
    
    // MARK: - Conflict Detection
    private func checkForTaskConflict(_ record: CKRecord) -> SyncConflict? {
        // Implementation would check local records against CloudKit records
        // Return conflict if modification dates don't match
        return nil
    }
    
    private func checkForGoalConflict(_ record: CKRecord) -> SyncConflict? {
        return nil
    }
    
    private func checkForEventConflict(_ record: CKRecord) -> SyncConflict? {
        return nil
    }
    
    private func checkForJournalConflict(_ record: CKRecord) -> SyncConflict? {
        return nil
    }
    
    // MARK: - Record Merging
    private func mergeTaskRecord(_ record: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }
    
    private func mergeGoalRecord(_ record: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }
    
    private func mergeEventRecord(_ record: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }
    
    private func mergeJournalRecord(_ record: CKRecord) async {
        // Implementation would merge CloudKit record with local data
    }
    
    // MARK: - Conflict Resolution
    func resolveConflict(_ conflict: SyncConflict, useLocal: Bool) async {
        let recordToSave = useLocal ? conflict.localRecord : conflict.serverRecord
        
        do {
            _ = try await database.save(recordToSave)
            
            // Remove resolved conflict
            conflictItems.removeAll { $0.id == conflict.id }
            
            // Check if all conflicts resolved
            if conflictItems.isEmpty {
                syncStatus = .success
            }
        } catch {
            handleError(error)
        }
    }
    
    func resolveAllConflicts(useLocal: Bool) async {
        for conflict in conflictItems {
            await resolveConflict(conflict, useLocal: useLocal)
        }
    }
    
    // MARK: - Background Task Management
    private func beginBackgroundTask() {
        #if os(iOS)
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "CloudKit Sync") {
            self.endBackgroundTask()
        }
        #endif
    }
    
    private func endBackgroundTask() {
        #if os(iOS)
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        #endif
    }
    
    // MARK: - Auto Sync Configuration
    func configureAutoSync(interval: TimeInterval) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            AsyncTask { @MainActor in
                await self.performFullSync()
            }
        }
    }
    
    // MARK: - Manual Operations
    func forcePushLocalChanges() async {
        // Implementation to force push all local changes to CloudKit
        syncStatus = .syncing
        
        do {
            // Push tasks, goals, events, journal entries
            try await pushLocalTasks()
            try await pushLocalGoals()
            try await pushLocalEvents()
            try await pushLocalJournalEntries()
            
            syncStatus = .success
            lastSyncDate = Date()
        } catch {
            handleError(error)
        }
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
        syncStatus = .syncing
        
        do {
            let query = CKQuery(recordType: "Task", predicate: NSPredicate(value: true))
            let (records, _) = try await database.records(matching: query)
            
            let recordIDs = records.compactMap { _, result in
                switch result {
                case .success(let record):
                    return record.recordID
                case .failure:
                    return nil
                }
            }
            
            if !recordIDs.isEmpty {
                _ = try await database.modifyRecords(saving: [], deleting: recordIDs)
            }
            
            syncStatus = .success
        } catch {
            handleError(error)
        }
    }
    
    // Methods to handle CloudKit errors
    func handleError(_ error: Error) {
        let cloudKitError = CloudKitError.fromCKError(error)
        errorMessage = cloudKitError.localizedDescription
        currentError = cloudKitError
        syncStatus = .error(cloudKitError)
        showErrorAlert = true
        
        // Log error for diagnostics
        print("CloudKit error: \(cloudKitError.localizedDescription) - \(cloudKitError.recoverySuggestion)")
        
        // Take automatic recovery steps based on error type
        switch cloudKitError {
        case .networkIssue:
            scheduleRetryWhenNetworkAvailable()
        case .accountChanged:
            resetSyncState()
        case .quotaExceeded:
            adjustSyncForLowStorage()
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
            // Observe network status changes
            NotificationCenter.default.addObserver(forName: .networkStatusChanged, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.checkNetworkAndRetry()
            }
        }
    }
    
    private func checkNetworkAndRetry() {
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
            await resetSyncTokens()
            await checkAccountStatus()
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
                guard let self = self else { return }
                self.currentError = .accountChanged
                self.showErrorAlert = true
                self.syncStatus = .error(.accountChanged)
                await self.accountStatusChanged() // Call the async version
            }
        }
    }
    
    @objc private func accountStatusChanged() async {
        await checkAccountStatus()
    }
    
    func checkAccountStatus() async {
        // Implementation checks account status
        do {
            _ = try await container.accountStatus() // status was unused, marked with _
            // Update local state based on account status
        } catch {
            AsyncTask { @MainActor [weak self] in
                self?.handleError(CloudKitError.fromCKError(error))
            }
        }
    }
}

// MARK: - Enhanced Sync Status View
struct EnhancedSyncStatusView: View {
    @ObservedObject var cloudKit = EnhancedCloudKitManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    var showLabel: Bool = false
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            syncIndicator
            
            if showLabel {
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText)
                        .font(compact ? .caption : .body)
                        .foregroundColor(statusColor)
                    
                    if let lastSync = cloudKit.lastSyncDate {
                        Text("Last sync: \(lastSync, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    }
                    
                    if cloudKit.syncStatus.isActive {
                        ProgressView(value: cloudKit.syncProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 100)
                    }
                }
            }
        }
        .onTapGesture {
            if case .error = cloudKit.syncStatus {
                AsyncTask { @MainActor in
                    await cloudKit.performFullSync()
                }
            }
        }
    }
    
    private var syncIndicator: some View {
        Group {
            switch cloudKit.syncStatus {
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
        .font(compact ? .caption : .body)
    }
    
    private var statusText: String {
        if !cloudKit.isSignedInToiCloud {
            return "Not signed into iCloud"
        }
        
        return cloudKit.syncStatus.description
    }
    
    private var statusColor: Color {
        if !cloudKit.isSignedInToiCloud {
            return .secondary
        }
        
        switch cloudKit.syncStatus {
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
