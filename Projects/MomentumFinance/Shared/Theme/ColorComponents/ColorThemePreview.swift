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
                        Picker("Theme Mode", selection: $selectedMode) {
                            ForEach(ThemeMode.allCases) { mode in
                                Label(mode.displayName, systemImage: mode.icon)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedMode) { _, newValue in
                            theme.setThemeMode(newValue)
                        }
                    }

                    Section("Background Colors") {
                        colorRow("Background", color: theme.background)
                        colorRow("Secondary Background", color: theme.secondaryBackground)
                        colorRow("Grouped Background", color: theme.groupedBackground)
                        colorRow("Card Background", color: theme.cardBackground)
                    }

                    Section("Text Colors") {
                        colorRow("Primary Text", color: theme.primaryText)
                        colorRow("Secondary Text", color: theme.secondaryText)
                        colorRow("Tertiary Text", color: theme.tertiaryText)
                    }

                    Section("Accent Colors") {
                        colorRow("Primary Accent", color: theme.accentPrimary)
                        colorRow("Secondary Accent", color: theme.accentSecondary)
                    }

                    Section("Financial Colors") {
                        colorRow("Income", color: theme.income)
                        colorRow("Expense", color: theme.expense)
                        colorRow("Savings", color: theme.savings)
                        colorRow("Warning", color: theme.warning)
                        colorRow("Critical", color: theme.critical)
                    }

                    Section("Budget Colors") {
                        colorRow("Under Budget", color: theme.budgetUnder)
                        colorRow("Near Budget", color: theme.budgetNear)
                        colorRow("Over Budget", color: theme.budgetOver)
                    }

                    Section("Category Colors") {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(0 ..< theme.categoryColors.count, id: \.self) { index in
                                    Circle()
                                        .fill(theme.categoryColors[index])
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
