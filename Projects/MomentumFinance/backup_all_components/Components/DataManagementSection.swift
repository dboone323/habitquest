//
//  DataManagementSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Data management settings section with retention and deletion options
struct DataManagementSection: View {
    @Binding var dataRetentionDays: Double
    @Binding var showingDeleteConfirmation: Bool
    @Binding var hapticFeedbackEnabled: Bool

    var body: some View {
        Section {
            HStack {
                Label("Data Retention", systemImage: "clock.arrow.circlepath")

                Spacer()

                Picker("Retention Period", selection: $dataRetentionDays) {
                    Text("3 months").tag(90.0)
                    Text("6 months").tag(180.0)
                    Text("1 year").tag(365.0)
                    Text("2 years").tag(730.0)
                    Text("Forever").tag(0.0)
                }
                .pickerStyle(.menu)
            }

            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete All Data", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Delete All Financial Data")
            .accessibilityHint("Permanently removes all your financial data")
        } header: {
            Text("Data Management")
        } footer: {
            if dataRetentionDays > 0 {
                Text("Data older than \(Int(dataRetentionDays)) days will be automatically deleted.")
            } else {
                Text("Your data will be kept indefinitely.")
            }
        }
    }

    func deleteAllData() async {
        // This would integrate with the data manager to delete all data
        // Implementation would depend on the specific data architecture
        if hapticFeedbackEnabled {
            HapticManager.shared.success()
        }
    }
}
