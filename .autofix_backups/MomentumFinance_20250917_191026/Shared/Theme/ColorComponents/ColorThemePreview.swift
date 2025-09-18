//
//  ColorThemePreview.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

#if DEBUG

/// Preview component for testing and visualizing color theme variations
struct ColorThemePreview: View {
    @State private var theme = ColorTheme.shared
    @State private var selectedMode: ThemeMode = .system

    var body: some View {
        NavigationStack {
            List {
                Section("Theme Mode") {
                    Picker("Theme Mode", selection: self.$selectedMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Label(mode.displayName, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: self.selectedMode) { _, newValue in
                        self.theme.setThemeMode(newValue)
                    }
                }

                Section("Background Colors") {
                    self.colorRow("Background", color: self.theme.background)
                    self.colorRow("Secondary Background", color: self.theme.secondaryBackground)
                    self.colorRow("Grouped Background", color: self.theme.groupedBackground)
                    self.colorRow("Card Background", color: self.theme.cardBackground)
                }

                Section("Text Colors") {
                    self.colorRow("Primary Text", color: self.theme.primaryText)
                    self.colorRow("Secondary Text", color: self.theme.secondaryText)
                    self.colorRow("Tertiary Text", color: self.theme.tertiaryText)
                }

                Section("Accent Colors") {
                    self.colorRow("Primary Accent", color: self.theme.accentPrimary)
                    self.colorRow("Secondary Accent", color: self.theme.accentSecondary)
                }

                Section("Financial Colors") {
                    self.colorRow("Income", color: self.theme.income)
                    self.colorRow("Expense", color: self.theme.expense)
                    self.colorRow("Savings", color: self.theme.savings)
                    self.colorRow("Warning", color: self.theme.warning)
                    self.colorRow("Critical", color: self.theme.critical)
                }

                Section("Budget Colors") {
                    self.colorRow("Under Budget", color: self.theme.budgetUnder)
                    self.colorRow("Near Budget", color: self.theme.budgetNear)
                    self.colorRow("Over Budget", color: self.theme.budgetOver)
                }

                Section("Category Colors") {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0 ..< self.theme.categoryColors.count, id: \.self) { index in
                                Circle()
                                    .fill(self.theme.categoryColors[index])
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 60)
                }
            }
            .navigationTitle("Color Theme")
        }
    }

    private func colorRow(_ name: String, color: Color) -> some View {
        HStack {
            Text(name)
            Spacer()
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
        }
    }
}

/// Preview extensions for ColorTheme
extension ColorTheme {
    static var preview: ColorTheme {
        let theme = ColorTheme()
        return theme
    }

    static var previewDark: ColorTheme {
        let theme = ColorTheme()
        theme.setThemeMode(.dark)
        return theme
    }
}

#Preview {
    ColorThemePreview()
}

#endif
