//
//  AppearanceSettingsSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// Appearance and theme settings section
struct AppearanceSettingsSection: View {
    @Binding var darkModePreference: DarkModePreference

    var body: some View {
        Section {
            HStack {
                Label("Appearance", systemImage: "paintbrush")

                Spacer()

                Picker("Dark Mode", selection: $darkModePreference) {
                    ForEach(DarkModePreference.allCases, id: \.self) { preference in
                        Text(preference.displayName)
                            .tag(preference)
                    }
                }
                .pickerStyle(.menu)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Appearance Setting")
            .accessibilityValue(darkModePreference.displayName)
        } header: {
            Text("Appearance")
        }
    }
}
