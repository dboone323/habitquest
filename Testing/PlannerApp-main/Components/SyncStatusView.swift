// PlannerApp/Components/SyncStatusView.swift
import SwiftUI
import CloudKit

struct SyncStatusView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var showSyncDetails = false
    
    var size: CGFloat = 24
    var showLabel: Bool = false
    var compact: Bool = false
    
    var body: some View {
        Button {
            showSyncDetails = true
        } label: {
            HStack(spacing: 4) {
                syncIcon
                
                if showLabel {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showSyncDetails) {
            CloudKitSyncView()
        }
    }
    
    private var syncIcon: some View {
        Group {
            switch cloudKit.syncStatus {
            case .idle:
                if cloudKit.isSignedInToiCloud {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "cloud.slash")
                        .foregroundColor(.red)
                }
            case .syncing:
                Image(systemName: "arrow.clockwise.icloud")
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 2) * 180))
            case .success:
                Image(systemName: "cloud.fill")
                    .foregroundColor(.green)
            case .error:
                Image(systemName: "cloud.slash")
                    .foregroundColor(.red)
            case .temporarilyUnavailable:
                Image(systemName: "cloud.slash")
                    .foregroundColor(.orange)
            }
        }
        .font(.system(size: size))
    }
    
    private var statusText: String {
        if !cloudKit.isSignedInToiCloud {
            return "Not connected"
        }
        
        switch cloudKit.syncStatus {
        case .idle:
            return "iCloud Sync"
        case .syncing:
            return compact ? "Syncing" : "Syncing..."
        case .success:
            return "Synced"
        case .error:
            return "Sync error"
        case .temporarilyUnavailable:
            return "Unavailable"
        }
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
        case .temporarilyUnavailable:
            return .orange
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SyncStatusView(showLabel: true)
        SyncStatusView(showLabel: true, compact: true)
        SyncStatusView()
    }
}