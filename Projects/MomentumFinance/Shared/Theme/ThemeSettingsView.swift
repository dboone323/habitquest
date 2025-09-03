//
//  ThemeSettingsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

struct ThemeSettingsView: View {
    @State private var theme = ColorTheme.shared
    @State private var selectedMode: ThemeMode = .system
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                themeModeSection
                colorPalettePreview
            }
            .navigationTitle("Appearance")
            .toolbar {
                #if os(iOS)
<<<<<<< HEAD
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
=======
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                #else
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
>>>>>>> 1cf3938 (Create working state for recovery)
                #endif
            }
            .onAppear {
                selectedMode = theme.currentThemeMode
            }
        }
    }

    // Section for selecting theme mode
    private var themeModeSection: some View {
        Section {
<<<<<<< HEAD
            ForEach(ThemeMode.allCases) { mode in
=======
            ForEach(Array(ThemeMode.allCases), id: \.self) { mode in
>>>>>>> 1cf3938 (Create working state for recovery)
                Button {
                    selectedMode = mode
                    theme.setThemeMode(mode)
                } label: {
                    HStack {
                        Label {
                            Text(mode.displayName)
                        } icon: {
                            Image(systemName: mode.icon)
                                .foregroundStyle(theme.accentPrimary)
                        }

                        Spacer()

                        if selectedMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(theme.accentPrimary)
                        }
                    }
                }
                .foregroundStyle(theme.primaryText)
            }
        } header: {
            Text("Theme Mode")
        } footer: {
            Text("Change how Momentum Finance appears on your device.")
        }
    }

    // Section showing color palette preview
    private var colorPalettePreview: some View {
        Section {
            VStack(spacing: 16) {
                // Background colors preview
                HStack {
                    colorBlock(theme.background, name: "Background")
                    colorBlock(theme.secondaryBackground, name: "Secondary")
                    colorBlock(theme.cardBackground, name: "Card")
                }

                // Text colors preview
                HStack {
                    colorBlock(theme.primaryText, name: "Primary")
                    colorBlock(theme.secondaryText, name: "Secondary")
                    colorBlock(theme.tertiaryText, name: "Tertiary")
                }

                // Financial colors preview
                HStack {
                    colorBlock(theme.income, name: "Income")
                    colorBlock(theme.expense, name: "Expense")
                    colorBlock(theme.savings, name: "Savings")
                }

                // Budget status colors preview
                HStack {
                    colorBlock(theme.budgetUnder, name: "Under")
                    colorBlock(theme.budgetNear, name: "Near")
                    colorBlock(theme.budgetOver, name: "Over")
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Color Palette")
        } footer: {
            Text("Preview of the current color scheme.")
        }
    }

    // Helper to create color preview blocks
    private func colorBlock(_ color: Color, name: String) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1),
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)

            Text(name)
                .font(.caption)
                .foregroundStyle(theme.primaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Views

/// A view that shows a single theme mode option
struct ThemeModeOption: View {
    let mode: ThemeMode
    let isSelected: Bool
    let theme: ColorTheme

    var body: some View {
        HStack {
            Label {
                Text(mode.displayName)
            } icon: {
                Image(systemName: mode.icon)
                    .foregroundStyle(theme.accentPrimary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(theme.accentPrimary)
            }
        }
    }
}

#Preview {
    ThemeSettingsView()
}
