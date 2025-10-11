//
//  CloudKitDeviceExtensions.swift
//  PlannerApp
//
//  CloudKit device management extensions
//

import CloudKit
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import SystemConfiguration
#endif

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
