import SwiftUI

/// View for managing CloudKit sync settings and status
struct CloudKitSyncView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var cloudKit = CloudKitManager.shared
    @State private var showingDeviceList = false
    @State private var showingResetAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "icloud")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        Text("iCloud Sync")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Keep your data synchronized across all your devices")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // iCloud Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.headline)

                        if cloudKit.isSignedInToiCloud {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Signed in to iCloud")
                                    .foregroundColor(.green)
                                Spacer()
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text("Not signed in to iCloud")
                                        .foregroundColor(.orange)
                                    Text("Sign in to iCloud to enable sync")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)

                    // Sync Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sync Status")
                            .font(.headline)

                        EnhancedSyncStatusView(showLabel: true)
                            .padding(.vertical, 8)

                        if let lastSync = cloudKit.lastSyncDate {
                            HStack {
                                Text("Last sync:")
                                Text(lastSync, style: .relative)
                                    .foregroundColor(.secondary)
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)

                    // Manual Sync
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manual Sync")
                            .font(.headline)

                        Button(action: {
                            Task {
                                await cloudKit.performFullSync()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sync Now")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(!cloudKit.isSignedInToiCloud || cloudKit.syncStatus.isActive)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)

                    // Device Management
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Device Management")
                            .font(.headline)

                        Button(action: {
                            showingDeviceList = true
                        }) {
                            HStack {
                                Image(systemName: "iphone")
                                Text("Manage Synced Devices")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)

                    // Advanced Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Advanced")
                            .font(.headline)

                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Reset CloudKit Data")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2)

                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDeviceList) {
                DeviceManagementView()
                    .environmentObject(themeManager)
            }
            .alert("Reset CloudKit Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task {
                        await cloudKit.resetCloudKitData()
                    }
                }
            } message: {
                Text("This will remove all data from iCloud and cannot be undone. Your local data will remain intact.")
            }
        }
    }
}

/// View for managing synced devices
struct DeviceManagementView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var cloudKit = CloudKitManager.shared
    @State private var devices: [CloudKitManager.SyncedDevice] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading devices...")
                } else if devices.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "iphone.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No devices found")
                            .font(.headline)
                        Text("Make sure you're signed in to iCloud on your other devices")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(devices) { device in
                            HStack {
                                Image(systemName: device.isCurrentDevice ? "iphone" : "laptopcomputer")
                                    .foregroundColor(device.isCurrentDevice ? .blue : .secondary)
                                VStack(alignment: .leading) {
                                    Text(device.name)
                                        .fontWeight(device.isCurrentDevice ? .semibold : .regular)
                                    if let lastSync = device.lastSync {
                                        Text("Last sync: \(lastSync, style: .relative)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Never synced")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if device.isCurrentDevice {
                                    Text("This device")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    let device = devices[index]
                                    if !device.isCurrentDevice {
                                        do {
                                            try await cloudKit.removeDevice(device.id.uuidString)
                                            devices.remove(at: index)
                                        } catch {
                                            print("Error removing device: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Synced Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadDevices()
            }
            .refreshable {
                await loadDevices()
            }
        }
    }

    private func loadDevices() async {
        isLoading = true
        devices = await cloudKit.getSyncedDevices()
        isLoading = false
    }
}

#Preview {
    CloudKitSyncView()
        .environmentObject(ThemeManager())
}
