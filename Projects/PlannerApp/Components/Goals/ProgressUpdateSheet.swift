// PlannerApp/Components/Goals/ProgressUpdateSheet.swift
import SwiftUI

public struct ProgressUpdateSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    let goal: Goal
    let onProgressUpdate: (Double) -> Void
    let onCompletionToggle: () -> Void

    @State private var progress: Double
    @State private var showCompletionAlert = false
    @Environment(\.dismiss) private var dismiss

    init(goal: Goal, onProgressUpdate: @escaping (Double) -> Void, onCompletionToggle: @escaping () -> Void) {
        self.goal = goal
        self.onProgressUpdate = onProgressUpdate
        self.onCompletionToggle = onCompletionToggle
        _progress = State(initialValue: goal.progress)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    self.goalInfoHeader
                    self.currentProgressSection
                    self.progressSliderSection
                    self.quickProgressButtonsSection

                    Spacer()

                    self.actionButtonsSection
                }
                .padding(.vertical)
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Update Goal")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        self.cancelButton
                    }
                }
                .alert("Complete Goal?", isPresented: self.$showCompletionAlert) {
                    Button("Just Update Progress", role: .cancel) {
                        self.onProgressUpdate(self.progress)
                        self.dismiss()
                    }
                    Button("Complete Goal") {
                        self.onProgressUpdate(1.0)
                        self.onCompletionToggle()
                        self.dismiss()
                    }
                } message: {
                    Text("You've set the progress to 100%. Would you like to mark this goal as completed?")
                }
        }
    }

    private var goalInfoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.goal.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Text(self.goal.description)
                .font(.body)
                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                .lineLimit(3)

            HStack {
                Text("Target: \(self.goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                Spacer()
                Text(self.goal.priority.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(self.priorityColor.opacity(0.2))
                    .foregroundColor(self.priorityColor)
                    .clipShape(Capsule())
            }
            .font(.subheadline)
            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal)
    }

    private var currentProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Progress")
                    .font(.headline)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                Spacer()
                Text("\(Int(self.progress * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(self.progressColor)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(self.themeManager.currentTheme.secondaryBackgroundColor.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(self.progressColor)
                        .frame(width: geometry.size.width * self.progress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal)
    }

    private var progressSliderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Update Progress")
                .font(.headline)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Slider(value: self.$progress, in: 0 ... 1, step: 0.05)
                .tint(self.progressColor)

            HStack {
                Text("0%")
                Spacer()
                Text("50%")
                Spacer()
                Text("100%")
            }
            .font(.caption)
            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal)
    }

    private var quickProgressButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Updates")
                .font(.headline)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            HStack(spacing: 12) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                    Button {
                        self.progress = value
                    } label: {
                        Text("\(Int(value * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(self.progress >= value ?
                                        self.themeManager.currentTheme.primaryAccentColor.opacity(0.2) :
                                        self.themeManager.currentTheme.secondaryBackgroundColor
                                    )
                            )
                            .foregroundColor(self.progress >= value ?
                                self.themeManager.currentTheme.primaryAccentColor :
                                self.themeManager.currentTheme.primaryTextColor
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        self.progress >= value ?
                                            self.themeManager.currentTheme.primaryAccentColor.opacity(0.5) :
                                            Color.clear,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button {
                if self.progress >= 1.0, !self.goal.isCompleted {
                    self.showCompletionAlert = true
                } else {
                    self.onProgressUpdate(self.progress)
                    self.dismiss()
                }
            } label: {
                Text("Update Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(self.themeManager.currentTheme.primaryAccentColor)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            if !self.goal.isCompleted {
                Button {
                    self.onCompletionToggle()
                } label: {
                    Text("Mark as Completed")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(self.themeManager.currentTheme.primaryAccentColor, lineWidth: 2)
                        )
                        .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            self.dismiss()
        }
        .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
    }

    private var progressColor: Color {
        if self.progress >= 1.0 {
            .green
        } else if self.progress >= 0.8 {
            Color.green.opacity(0.8)
        } else if self.progress >= 0.5 {
            .yellow
        } else {
            self.themeManager.currentTheme.primaryAccentColor
        }
    }

    private var priorityColor: Color {
        switch self.goal.priority {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }
}
