//
//  ThemePreviewView.swift
//  PlannerApp
//
//  Interactive theme preview and selection
//

import SwiftUI

public struct ThemePreviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTheme: Theme = .defaultTheme

    let sampleTasks = [
        "Complete project proposal",
        "Review quarterly reports",
        "Schedule team meeting",
        "Update documentation",
    ]

    let sampleGoals = [
        "Read 12 books this year",
        "Exercise 3x per week",
        "Learn Swift programming",
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    self.themeSelectionGrid
                    Divider().padding(.horizontal)
                    self.livePreviewSection
                }
                .padding(.vertical)
            }
            .background(self.selectedTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Theme Preview")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                                .accessibilityLabel("Button")
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            self.themeManager.setTheme(self.selectedTheme)
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Apply")
                                .fontWeight(.semibold)
                                .accessibilityLabel("Button")
                        }
                    }
                }
        }
        .onAppear {
            self.selectedTheme = self.themeManager.currentTheme
        }
    }

    private var themeSelectionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(Theme.availableThemes, id: \.name) { theme in
                ThemePreviewCard(
                    theme: theme,
                    isSelected: self.selectedTheme.name == theme.name
                ) {
                    self.selectedTheme = theme
                    // Apply haptic feedback if enabled
                    #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    #endif
                }
            }
        }
        .padding(.horizontal)
    }

    private var livePreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.title2.bold())
                .foregroundColor(self.selectedTheme.primaryTextColor)
                .padding(.horizontal)

            self.sampleDashboardCard
            self.sampleButtonsSection
            self.sampleGoalsSection
        }
    }

    private var sampleDashboardCard: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Tasks")
                        .font(.headline)
                        .foregroundColor(self.selectedTheme.primaryTextColor)
                    Spacer()
                    Text("4")
                        .font(.title2.bold())
                        .foregroundColor(self.selectedTheme.primaryAccentColor)
                }

                ForEach(self.sampleTasks.prefix(3), id: \.self) { task in
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(self.selectedTheme.secondaryAccentColor)
                        Text(task)
                            .font(.body)
                            .foregroundColor(self.selectedTheme.primaryTextColor)
                        Spacer()
                    }
                }

                ProgressBar(progress: 0.6, showPercentage: true)
                    .environmentObject(self.createThemeManager(for: self.selectedTheme))
            }
        }
        .environmentObject(self.createThemeManager(for: self.selectedTheme))
        .padding(.horizontal)
    }

    private var sampleButtonsSection: some View {
        VStack(spacing: 12) {
            ModernButton(title: "Primary Action", action: {})
                .environmentObject(self.createThemeManager(for: self.selectedTheme))

            HStack(spacing: 12) {
                ModernButton(title: "Secondary", action: {})
                    .environmentObject(self.createThemeManager(for: self.selectedTheme))

                ModernButton(title: "Destructive", action: {})
                    .environmentObject(self.createThemeManager(for: self.selectedTheme))
            }
        }
        .padding(.horizontal)
    }

    private var sampleGoalsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Goals Progress")
                    .font(.headline)
                    .foregroundColor(self.selectedTheme.primaryTextColor)

                ForEach(Array(self.sampleGoals.enumerated()), id: \.offset) { index, goal in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal)
                            .font(.body)
                            .foregroundColor(self.selectedTheme.primaryTextColor)
                        ProgressBar(progress: Double(index + 1) * 0.3)
                            .environmentObject(self.createThemeManager(for: self.selectedTheme))
                    }
                }
            }
        }
        .environmentObject(self.createThemeManager(for: self.selectedTheme))
        .padding(.horizontal)
    }

    private func createThemeManager(for theme: Theme) -> ThemeManager {
        let manager = ThemeManager()
        manager.setTheme(theme)
        return manager
    }
}

public struct ThemePreviewCard: View {
    let theme: Theme
    let isSelected: Bool
    let onTap: () -> Void

    public var body: some View {
        Button(action: self.onTap) {
            VStack(spacing: 12) {
                // Theme color swatches
                HStack(spacing: 8) {
                    Circle()
                        .fill(self.theme.primaryAccentColor)
                        .frame(width: 24, height: 24)
                    Circle()
                        .fill(self.theme.secondaryAccentColor)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(self.theme.completedColor)
                        .frame(width: 16, height: 16)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(self.theme.name)
                        .font(.headline)
                        .foregroundColor(self.theme.primaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Sample text")
                        .font(.caption)
                        .foregroundColor(self.theme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .frame(height: 100)
            .background(self.theme.secondaryBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        self.isSelected ? self.theme.primaryAccentColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(12)
        }
        .accessibilityLabel("Button")
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemePreviewView()
        .environmentObject(ThemeManager())
}
