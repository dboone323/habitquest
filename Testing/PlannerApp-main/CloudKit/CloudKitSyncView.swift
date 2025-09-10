// PlannerApp/CloudKit/CloudKitSyncView.swift

import SwiftUI
import CloudKit
import PlannerApp

// Alias for async Task to avoid conflict with PlannerApp.Task model
// AsyncTask typealias is now defined in EnhancedCloudKitManager.swift

struct CloudKitSyncView: View {
    @StateObject private var cloudKit = EnhancedCloudKitManager.shared // Changed to EnhancedCloudKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingMergeAlert = false
    @State private var isNewDevice = false
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var iCloudStatusSection: some View {
        Section("iCloud Status") {
            HStack {
                Image(systemName: cloudKit.isSignedInToiCloud ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(cloudKit.isSignedInToiCloud ? .green : .red)
                Text(cloudKit.isSignedInToiCloud ? "Signed in to iCloud" : "Not signed in to iCloud")
            }
            
            if !cloudKit.isSignedInToiCloud {
                Button("Sign in to iCloud") {
                    cloudKit.requestiCloudAccess()
                }
            }
        }
    }
    
    @ViewBuilder
    private var syncStatusSection: some View {
        Section("Sync Status") {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                Text(statusText)
                Spacer()
                if cloudKit.syncStatus == .syncing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        Section("Actions") {
            Button(action: {
                AsyncTask {
                    await cloudKit.performSync()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Now")
                }
            }
            .disabled(!cloudKit.isSignedInToiCloud || cloudKit.syncStatus == .syncing)
            
            Button(action: {
                AsyncTask {
                    await cloudKit.checkAccountStatus()
                }
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.check")
                    Text("Check iCloud Account")
                }
            }
            
            if !UserDefaults.standard.bool(forKey: "HasCompletedInitialSync") {
                Button(action: {
                    isNewDevice = true
                    showingMergeAlert = true
                }) {
                    HStack {
                        Image(systemName: "iphone.and.arrow.forward")
                        Text("This is a new device")
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    @ViewBuilder
    private var lastSyncSection: some View {
        Section("Last Sync") {
            if let lastSync = cloudKit.lastSyncDate {
                Text(lastSync, style: .relative)
            } else {
                Text("Never")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if cloudKit.syncStatus == .error {
            Section {
                Text("Sync failed. Please check your internet connection and iCloud settings.")
                    .foregroundColor(.red)
                
                Button("Try Again") {
                    AsyncTask {
                        await cloudKit.performSync()
                    }
                }
                .foregroundColor(.blue)
            } header: {
                Text("Error Details")
            }
        }
    }
    
    @ViewBuilder
    private var aboutSection: some View {
        Section("About iCloud Sync") {
            Text("Syncing with iCloud allows your tasks, goals, events, and journal entries to be available on all your Apple devices.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if #available(iOS 17.0, macOS 14.0, *) {
                Text("Your data is encrypted and secure.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .privacySensitive()
            } else {
                Text("Your data is encrypted and secure.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - View Body
    
    var body: some View {
        NavigationStack {
            Form {
                iCloudStatusSection
                syncStatusSection
                actionsSection
                lastSyncSection
                errorSection
                aboutSection
            }
            .refreshable {
                await cloudKit.checkAccountStatus()
            }
            .navigationTitle("CloudKit Sync")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
            .alert("New Device Setup", isPresented: $showingMergeAlert) {
                Button("Merge from iCloud", role: .none) {
                    AsyncTask {
                        await handleNewDeviceMerge()
                    }
                }
                Button("Start Fresh", role: .destructive) {
                    UserDefaults.standard.set(true, forKey: "HasCompletedInitialSync")
                }
                Button("Cancel", role: .cancel) {
                    isNewDevice = false
                }
            } message: {
                Text("Do you want to merge your existing iCloud data with this device, or start fresh with the data on this device?")
            }
        }
        .onAppear {
            checkIfNewDevice()
        }
    }
    
    // MARK: - Helper Functions
    
    private func handleNewDeviceMerge() async {
        UserDefaults.standard.set(true, forKey: "HasCompletedInitialSync")
        await cloudKit.handleNewDeviceLogin()
    }
    
    private func checkIfNewDevice() {
        if !UserDefaults.standard.bool(forKey: "HasCompletedInitialSync") && cloudKit.isSignedInToiCloud {
            isNewDevice = true
            showingMergeAlert = true
        }
    }
    
    // MARK: - Status Computed Properties
    
    private var statusIcon: String {
        switch cloudKit.syncStatus {
        case .idle: return "checkmark.circle"
        case .syncing: return "arrow.clockwise"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle"
        case .temporarilyUnavailable: return "cloud.slash"
        }
    }
    
    private var statusColor: Color {
        switch cloudKit.syncStatus {
        case .idle: return .secondary
        case .syncing: return .blue
        case .success: return .green
        case .error: return .red
        case .temporarilyUnavailable: return .orange
        }
    }
    
    private var statusText: String {
        switch cloudKit.syncStatus {
        case .idle: return "Ready to sync"
        case .syncing: return "Syncing..."
        case .success: return "Sync completed"
        case .error: return "Sync failed"
        case .temporarilyUnavailable: return "Temporarily unavailable"
        }
    }
}
