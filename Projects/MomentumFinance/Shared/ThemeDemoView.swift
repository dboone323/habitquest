//
//  ThemeDemoView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// A demonstration view showing the dark mode optimizations and theme system
public struct ThemeDemoView: View {
    @State private var theme = ColorTheme.shared
    @State private var themeManager = ThemeManager.shared
    @State private var selectedThemeMode: ThemeMode = .system
    @State private var showSheet = false
    @State private var sliderValue: Double = 0.75

    // Sample financial data for demo
    private let accounts = [
        ("Checking", "banknote", 1250.50),
        ("Savings", "dollarsign.circle", 4320.75),
        ("Investment", "chart.line.uptrend.xyaxis", 8640.25),
    ]

    private let budgets = [
        ("Groceries", 420.0, 500.0),
        ("Dining Out", 280.0, 300.0),
        ("Entertainment", 150.0, 100.0),
    ]

    private let subscriptions = [
        ("Netflix", "play.tv", "2025-06-15", 15.99),
        ("Spotify", "music.note", "2025-06-22", 9.99),
        ("iCloud+", "cloud", "2025-07-01", 2.99),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme selector at top
                    ThemeSelectorCard(
                        selectedThemeMode: self.$selectedThemeMode,
                        theme: self.theme
                    )

                    // Financial summary card
                    ThemeFinancialSummaryCard(theme: self.theme)

                    // Account cards
                    ThemeAccountsList()

                    // Budget progress section
                    ThemeBudgetProgress()

                    // Subscriptions section
                    ThemeSubscriptionsList()

                    // Typography showcase
                    ThemeTypographyShowcase(theme: self.theme)

                    // Button styles showcase
                    ThemeButtonStylesShowcase(theme: self.theme)
                }
                .padding()
            }
            .background(self.theme.background)
            .navigationTitle("Theme Showcase")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { self.showSheet = true }).accessibilityLabel("Button") {
                        Image(systemName: "gear")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(self.theme.accentPrimary)
                    }
                    .accessibilityLabel("Button")
                }
            }
            .sheet(isPresented: self.$showSheet) {
                ThemeSettingsSheet(
                    selectedThemeMode: self.$selectedThemeMode,
                    sliderValue: self.$sliderValue,
                    showSheet: self.$showSheet,
                    theme: self.theme
                )
            }
            .preferredColorScheme(self.theme.isDarkMode ? .dark : .light)
        }
        .onAppear {
            // Initialize the selected mode from current theme
            self.selectedThemeMode = self.theme.currentThemeMode
        }
    }
}

#Preview {
    ThemeDemoView()
}
