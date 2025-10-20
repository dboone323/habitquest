// PlannerApp/Views/Settings/SettingsView.swift

import Foundation
import LocalAuthentication
import SwiftUI
import UserNotifications

#if os(macOS)
    import AppKit
#endif

public struct SettingsViewBackup: View {
    public init() {}

    public var body: some View {
        Text("Settings Backup")
            .font(.title)
            .padding()
    }
}

#Preview {
    SettingsViewBackup()
}
