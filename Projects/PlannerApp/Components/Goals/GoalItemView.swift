// PlannerApp/Components/Goals/GoalItemView.swift
import Foundation
import SwiftUI

public struct GoalItemView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let goal: Goal
    let onProgressUpdate: (UUID, Double) -> Void
    let onCompletionToggle: (UUID) -> Void

    @State private var showProgressSheet = false

    // Formatter for displaying the target date
    private var targetDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // e.g., Apr 29, 2025
        formatter.timeStyle = .none
        return formatter
    }

    // Progress bar component
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.3))
                    .frame(height: 8)

                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(min(goal.progress, 1.0)), height: 8)
            }
        }
        .frame(height: 8)
    }

    // Color for progress bar based on completion status
    private var progressColor: Color {
        if goal.isCompleted {
            themeManager.currentTheme.completedColor.opacity(0.8)
        } else if goal.progress >= 0.8 {
            Color.green.opacity(0.8)
        } else if goal.progress >= 0.5 {
            Color.yellow.opacity(0.8)
        } else {
            themeManager.currentTheme.primaryAccentColor.opacity(0.8)
        }
    }

    // Priority badge
    private var priorityBadge: some View {
        Text(goal.priority.displayName)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .clipShape(Capsule())
    }

    // Color for priority badge
    private var priorityColor: Color {
        switch goal.priority {
        case .high: .red
        case .medium: .orange
        case .low: .green
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with title and priority
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    // Goal Title with completion indicator
                    HStack(spacing: 8) {
                        if goal.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }
                        Text(goal.title)
                            .font(
                                themeManager.currentTheme.font(
                                    forName: themeManager.currentTheme.primaryFontName,
                                    size: 17, weight: goal.isCompleted ? .regular : .semibold
                                )
                            )
                            .foregroundColor(goal.isCompleted ?
                                themeManager.currentTheme.secondaryTextColor :
                                themeManager.currentTheme.primaryTextColor
                            )
                            .strikethrough(goal.isCompleted)
                    }

                    // Priority badge
                    priorityBadge
                }

                Spacer()

                // Progress percentage and controls
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)

                    // Quick action buttons
                    HStack(spacing: 8) {
                        // Progress update button
                        Button {
                            showProgressSheet = true
                        } label: {
                            Image(systemName: "gauge")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                        }
                        .buttonStyle(.plain)

                        // Completion toggle button
                        Button {
                            onCompletionToggle(goal.id)
                        } label: {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundColor(goal.isCompleted ? .green : themeManager.currentTheme.secondaryTextColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Progress bar (now tappable)
            progressBar
                .onTapGesture {
                    showProgressSheet = true
                }

            // Goal Description
            Text(goal.description)
                .font(
                    themeManager.currentTheme.font(
                        forName: themeManager.currentTheme.secondaryFontName,
                        size: 15
                    )
                )
                .foregroundColor(goal.isCompleted ?
                    themeManager.currentTheme.secondaryTextColor.opacity(0.7) :
                    themeManager.currentTheme.secondaryTextColor
                )
                .lineLimit(2)

            // Target Date and status
            HStack {
                Text("Target: \(goal.targetDate, formatter: targetDateFormatter)")
                    .font(
                        themeManager.currentTheme.font(
                            forName: themeManager.currentTheme.secondaryFontName,
                            size: 13
                        )
                    )
                    .foregroundColor(
                        themeManager.currentTheme.secondaryTextColor.opacity(0.8)
                    )

                Spacer()

                // Completion status
                if goal.isCompleted {
                    Text("Completed")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                } else if goal.targetDate < Date() {
                    Text("Overdue")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(goal.isCompleted ?
                    themeManager.currentTheme.secondaryBackgroundColor.opacity(0.5) :
                    themeManager.currentTheme.secondaryBackgroundColor
                )
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(goal.isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .sheet(isPresented: $showProgressSheet) {
            // Placeholder for progress update sheet
            Text("Progress Update Sheet - Coming Soon")
                .environmentObject(themeManager)
        }
    }
}
