//
//  ImportExportSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Import and export settings section for data management
struct ImportExportSection: View {
    @Binding var showingDataExport: Bool
    @Binding var showingDataImport: Bool
    @Binding var hapticFeedbackEnabled: Bool

    var body: some View {
        Section {
            Button(action: {
                showingDataExport = true
                if hapticFeedbackEnabled {
                    #if os(iOS)
                        HapticManager.shared.impact(.medium)
                    #endif
                }
            }) {
                Label("Export Data", systemImage: "square.and.arrow.up")
            }
            .accessibilityLabel("Export Financial Data")
            .accessibilityHint("Export your data to CSV or PDF format")

            Button(action: {
                showingDataImport = true
                if hapticFeedbackEnabled {
                    #if os(iOS)
                        HapticManager.shared.impact(.medium)
                    #endif
                }
            }) {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
            .accessibilityLabel("Import Financial Data")
            .accessibilityHint("Import data from CSV files")
        } header: {
            Text("Data Import & Export")
        } footer: {
            Text("Backup your data or import from other financial apps.")
        }
    }
}
