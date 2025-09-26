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
                    goalInfoHeader
                    currentProgressSection
                    progressSliderSection
                    quickProgressButtonsSection

                    Spacer()

                    actionButtonsSection
                }
                .padding(.vertical)
            }
            .background(themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Update Goal")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        cancelButton
                    }
                }
                .alert("Complete Goal?", isPresented: $showCompletionAlert) {
                    Button("Just Update Progress", role: .cancel) {
                        onProgressUpdate(progress)
                        dismiss()
                    }
                    Button("Complete Goal") {
                        onProgressUpdate(1.0)
                        onCompletionToggle()
                        dismiss()
                    }
                } message: {
                    Text("You've set the progress to 100%. Would you like to mark this goal as completed?")
                }
        }
    }

    private var goalInfoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(goal.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryTextColor)

            Text(goal.description)
                .font(.body)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                .lineLimit(3)

            HStack {
                Text("Target: \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                Spacer()
                Text(goal.priority.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.2))
                    .foregroundColor(priorityColor)
                    .clipShape(Capsule())
            }
            .font(.subheadline)
            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal)
    }

    private var currentProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Progress")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryTextColor)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 12)
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
                .foregroundColor(themeManager.currentTheme.primaryTextColor)

            Slider(value: $progress, in: 0 ... 1, step: 0.05)
                .tint(progressColor)

            HStack {
                Text("0%")
                Spacer()
                Text("50%")
                Spacer()
                Text("100%")
            }
            .font(.caption)
            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal)
    }

    private var quickProgressButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Updates")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryTextColor)

            HStack(spacing: 12) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                    Button {
                        progress = value
                    } label: {
                        Text("\(Int(value * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(progress >= value ?
                                        themeManager.currentTheme.primaryAccentColor.opacity(0.2) :
                                        themeManager.currentTheme.secondaryBackgroundColor
                                    )
                            )
                            .foregroundColor(progress >= value ?
                                themeManager.currentTheme.primaryAccentColor :
                                themeManager.currentTheme.primaryTextColor
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        progress >= value ?
                                            themeManager.currentTheme.primaryAccentColor.opacity(0.5) :
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
                if progress >= 1.0, !goal.isCompleted {
                    showCompletionAlert = true
                } else {
                    onProgressUpdate(progress)
                    dismiss()
                }
            } label: {
                Text("Update Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentTheme.primaryAccentColor)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            if !goal.isCompleted {
                Button {
                    onCompletionToggle()
                } label: {
                    Text("Mark as Completed")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.currentTheme.primaryAccentColor, lineWidth: 2)
                        )
                        .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundColor(themeManager.currentTheme.primaryAccentColor)
    }

    private var progressColor: Color {
        if progress >= 1.0 {
            .green
        } else if progress >= 0.8 {
            Color.green.opacity(0.8)
        } else if progress >= 0.5 {
            .yellow
        } else {
            themeManager.currentTheme.primaryAccentColor
        }
    }

    private var priorityColor: Color {
        switch goal.priority {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }
}
