//
//  ThemeDemoView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// A demonstration view showing the dark mode optimizations and theme system
struct ThemeDemoView: View {
    @State private var theme = ColorTheme.shared
    @State private var themeManager = ThemeManager.shared
    @State private var selectedThemeMode: ThemeMode = .system
    @State private var showSheet = false
    @State private var sliderValue: Double = 0.75

    // Sample financial data for demo
    private let accounts = [
<<<<<<< HEAD
        ("Checking", "banknote", 1_250.50),
        ("Savings", "dollarsign.circle", 4_320.75),
        ("Investment", "chart.line.uptrend.xyaxis", 8_640.25)
=======
        ("Checking", "banknote", 1250.50),
        ("Savings", "dollarsign.circle", 4320.75),
        ("Investment", "chart.line.uptrend.xyaxis", 8640.25),
>>>>>>> 1cf3938 (Create working state for recovery)
    ]

    private let budgets = [
        ("Groceries", 420.0, 500.0),
        ("Dining Out", 280.0, 300.0),
<<<<<<< HEAD
        ("Entertainment", 150.0, 100.0)
=======
        ("Entertainment", 150.0, 100.0),
>>>>>>> 1cf3938 (Create working state for recovery)
    ]

    private let subscriptions = [
        ("Netflix", "play.tv", "2025-06-15", 15.99),
        ("Spotify", "music.note", "2025-06-22", 9.99),
<<<<<<< HEAD
        ("iCloud+", "cloud", "2025-07-01", 2.99)
=======
        ("iCloud+", "cloud", "2025-07-01", 2.99),
>>>>>>> 1cf3938 (Create working state for recovery)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme selector at top
<<<<<<< HEAD
                    themeSelector

                    // Financial summary card
                    financialSummary

                    // Account cards
                    accountsList

                    // Budget progress section
                    budgetProgress

                    // Subscriptions section
                    subscriptionsList

                    // Typography showcase
                    typographyShowcase

                    // Button styles showcase
                    buttonStylesShowcase
=======
                    ThemeSelectorCard(
                        selectedThemeMode: $selectedThemeMode,
                        theme: theme
                    )

                    // Financial summary card
                    ThemeFinancialSummaryCard(theme: theme)

                    // Account cards
                    ThemeAccountsList(
                        accounts: accounts,
                        theme: theme
                    )

                    // Budget progress section
                    ThemeBudgetProgress(
                        budgets: budgets,
                        theme: theme
                    )

                    // Subscriptions section
                    ThemeSubscriptionsList(
                        subscriptions: subscriptions,
                        theme: theme
                    )

                    // Typography showcase
                    ThemeTypographyShowcase(theme: theme)

                    // Button styles showcase
                    ThemeButtonStylesShowcase(theme: theme)
>>>>>>> 1cf3938 (Create working state for recovery)
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("Theme Showcase")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showSheet = true }) {
                        Image(systemName: "gear")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(theme.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
<<<<<<< HEAD
                themeSettingsSheet
=======
                ThemeSettingsSheet(
                    selectedThemeMode: $selectedThemeMode,
                    sliderValue: $sliderValue,
                    showSheet: $showSheet,
                    theme: theme
                )
>>>>>>> 1cf3938 (Create working state for recovery)
            }
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
        }
        .onAppear {
            // Initialize the selected mode from current theme
            selectedThemeMode = theme.currentThemeMode
        }
    }
<<<<<<< HEAD

    // MARK: - Theme Selector

    private var themeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Theme Mode")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            HStack(spacing: 12) {
                ForEach(ThemeMode.allCases) { mode in
                    themeModeButton(mode)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func themeModeButton(_ mode: ThemeMode) -> some View {
        Button(action: {
            selectedThemeMode = mode
            theme.setThemeMode(mode)
            // If we had access to ThemePersistence, we would save here
            // ThemePersistence.saveThemePreference(mode)
        }) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(selectedThemeMode == mode ? theme.accentPrimary : theme.secondaryText)

                Text(mode.displayName)
                    .font(.caption)
                    .foregroundStyle(selectedThemeMode == mode ? theme.primaryText : theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedThemeMode == mode ?
                            theme.accentPrimary.opacity(0.1) :
                            theme.secondaryBackground),
                )
        }
    }

    // MARK: - Financial Summary

    private var financialSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Summary")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            HStack(spacing: 16) {
                summaryItem(
                    title: "Income",
                    value: "$5,840.00",
                    icon: "arrow.down.circle.fill",
                    color: theme.income,
                    )

                summaryItem(
                    title: "Expenses",
                    value: "$3,250.75",
                    icon: "arrow.up.circle.fill",
                    color: theme.expense,
                    )

                summaryItem(
                    title: "Saved",
                    value: "$2,589.25",
                    icon: "dollarsign.circle.fill",
                    color: theme.savings,
                    )
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Savings Goal Progress")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)

                HStack {
                    Text("$2,589.25")
                        .font(.caption)
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    Text("$5,000.00")
                        .font(.caption)
                        .foregroundStyle(theme.primaryText)
                }

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(theme.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(theme.savings)
                        .frame(width: CGFloat(320) * 0.85 * 0.52, height: 8)
                        .cornerRadius(4)
                }

                Text("52% of goal reached")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func summaryItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(theme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Accounts List

    private var accountsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accounts")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(accounts.enumerated()), id: \.offset) { index, account in
                HStack {
                    Image(systemName: account.1)
                        .font(.subheadline)
                        .foregroundStyle(theme.accentPrimary)
                        .frame(width: 24, height: 24)

                    Text(account.0)
                        .font(.subheadline)
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    Text(formatCurrency(account.2))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.primaryText)
                }

                if index < accounts.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
                        .padding(.leading, 32)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Budget Progress

    private var budgetProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Progress")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(budgets.enumerated()), id: \.offset) { index, budget in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(budget.0)
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Spacer()

                        Text(formatCurrency(budget.1))
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Text("/")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)

                        Text(formatCurrency(budget.2))
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }

                    // Progress bar
                    progressBar(spent: budget.1, total: budget.2)
                }

                if index < budgets.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    private func progressBar(spent: Double, total: Double) -> some View {
        let progress = min(1.0, spent / total)
        let color: Color = switch progress {
        case 0 ..< 0.8:
            theme.budgetUnder
        case 0.8 ..< 1.0:
            theme.budgetNear
        default:
            theme.budgetOver
        }

        return VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(theme.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)

                Spacer()
            }
        }
    }

    // MARK: - Subscriptions List

    private var subscriptionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Subscriptions")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            ForEach(Array(subscriptions.enumerated()), id: \.offset) { index, subscription in
                HStack {
                    // Icon with colorful background
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.categoryColors[index % theme.categoryColors.count])
                            .frame(width: 36, height: 36)

                        Image(systemName: subscription.1)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(subscription.0)
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryText)

                        Text(subscription.2)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                    }

                    Spacer()

                    Text(formatCurrency(subscription.3))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.expense)
                }

                if index < subscriptions.count - 1 {
                    Divider()
                        .background(theme.secondaryText.opacity(0.3))
                }
            }
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Typography Showcase

    private var typographyShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            Group {
                Text("Large Title")
                    .font(.largeTitle)

                Text("Title")
                    .font(.title)

                Text("Title 2")
                    .font(.title2)

                Text("Title 3")
                    .font(.title3)

                Text("Headline")
                    .font(.headline)

                Text("Body")
                    .font(.body)

                Text("Callout")
                    .font(.callout)

                Text("Subheadline")
                    .font(.subheadline)

                Text("Footnote")
                    .font(.footnote)

                Text("Caption")
                    .font(.caption)
            }
            .foregroundStyle(theme.primaryText)

            Text("This typography supports dynamic type and respects user accessibility settings")
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .padding(.top, 8)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Button Styles Showcase

    private var buttonStylesShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Button Styles")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            // Primary Button
            Button(action: {}) {
                Text("Primary Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.accentPrimary)
            .foregroundStyle(.white)
            .cornerRadius(8)

            // Secondary Button
            Button(action: {}) {
                Text("Secondary Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.secondaryBackground)
            .foregroundStyle(theme.accentPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(theme.accentPrimary, lineWidth: 1),
                )
            .cornerRadius(8)

            // Destructive Button
            Button(action: {}) {
                Text("Destructive Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.critical)
            .foregroundStyle(.white)
            .cornerRadius(8)

            // Text Button
            Button(action: {}) {
                Text("Text Button")
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(theme.accentPrimary)
            .padding(.top, 8)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Theme Settings Sheet

    private var themeSettingsSheet: some View {
        NavigationStack {
            List {
                // Theme mode options
                Section(header: Text("Theme Mode"), footer: Text("Your preference will be saved automatically.")) {
                    ForEach(ThemeMode.allCases) { mode in
                        Button {
                            selectedThemeMode = mode
                            theme.setThemeMode(mode)
                        } label: {
                            HStack {
                                Label(mode.displayName, systemImage: mode.icon)
                                    .foregroundStyle(theme.primaryText)

                                Spacer()

                                if selectedThemeMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(theme.accentPrimary)
                                }
                            }
                        }
                    }
                }

                // Color palette preview
                Section(header: Text("Color Palette")) {
                    colorPaletteGrid
                }

                // Interactive element
                Section(header: Text("Demo Controls")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Value: \(Int(sliderValue * 100))%")
                            .foregroundStyle(theme.primaryText)

                        // Custom progress circle
                        ZStack {
                            Circle()
                                .stroke(
                                    theme.secondaryBackground,
                                    lineWidth: 10,
                                    )
                                .frame(width: 100, height: 100)

                            Circle()
                                .trim(from: 0, to: sliderValue)
                                .stroke(
                                    theme.savings,
                                    style: StrokeStyle(
                                        lineWidth: 10,
                                        lineCap: .round,
                                        ),
                                    )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 100, height: 100)
                                .animation(.easeInOut, value: sliderValue)

                            Text("\(Int(sliderValue * 100))%")
                                .font(.headline)
                                .foregroundStyle(theme.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)

                        Slider(value: $sliderValue)
                            .tint(theme.accentPrimary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Theme Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showSheet = false
                    }
                }
            }
        }
    }

    private var colorPaletteGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            colorBlock(theme.background, name: "Background")
            colorBlock(theme.cardBackground, name: "Card")
            colorBlock(theme.accentPrimary, name: "Accent")
            colorBlock(theme.income, name: "Income")
            colorBlock(theme.expense, name: "Expense")
            colorBlock(theme.savings, name: "Savings")
        }
        .padding(.vertical, 8)
    }

    private func colorBlock(_ color: Color, name: String) -> some View {
        VStack {
            Circle()
                .fill(color)
                .frame(height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1),
                    )

            Text(name)
                .font(.caption2)
                .foregroundStyle(theme.secondaryText)
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
=======
>>>>>>> 1cf3938 (Create working state for recovery)
}

#Preview {
    ThemeDemoView()
}
