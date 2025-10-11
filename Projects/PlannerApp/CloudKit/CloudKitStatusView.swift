//
//  CloudKitStatusView.swift
//  PlannerApp
//
//  UI components for CloudKit sync status display
//

import SwiftUI

// MARK: - Enhanced Sync Status View

public struct EnhancedSyncStatusView: View {
    @ObservedObject var cloudKit = CloudKitManager.shared
    @EnvironmentObject var themeManager: ThemeManager

    let showLabel: Bool
    let compact: Bool

    public init(showLabel: Bool = false, compact: Bool = false) {
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
