// PlannerApp/Views/Calendar/GoalRowView.swift
import SwiftUI

public struct GoalRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let goal: Goal

    private var priorityColor: Color {
        switch self.goal.priority {
        case .high:
            .red
        case .medium:
            .orange
        case .low:
            .green
        }
    }

    private var priorityText: String {
        switch self.goal.priority {
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        }
    }

    private var progressPercentage: Double {
        self.goal.progress
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            VStack(alignment: .center, spacing: 2) {
                Circle()
                    .fill(self.priorityColor)
                    .frame(width: 8, height: 8)

                Text(self.priorityText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(self.priorityColor)
            }
            .frame(width: 50)

            // Goal details
            VStack(alignment: .leading, spacing: 4) {
                Text(self.goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .lineLimit(2)

                if !self.goal.description.isEmpty {
                    Text(self.goal.description)
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        .lineLimit(1)
                }

                // Progress bar
                if self.progressPercentage > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("Progress")
                                .font(.caption2)
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                            Spacer()
                            Text("\(Int(self.progressPercentage * 100))%")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }

                        ProgressView(value: self.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(y: 0.8)
                    }
                }
            }

            Spacer()

            // Completion status
            if self.goal.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Image(systemName: "target")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        GoalRowView(goal: Goal(
            id: UUID(),
            title: "Learn SwiftUI",
            description: "Complete advanced SwiftUI course",
            targetDate: Date(),
            isCompleted: false,
            priority: .high,
            progress: 0.75
        ))

        GoalRowView(goal: Goal(
            id: UUID(),
            title: "Read 50 Books",
            description: "Annual reading challenge",
            targetDate: Date(),
            isCompleted: true,
            priority: .medium,
            progress: 1.0
        ))
    }
    .environmentObject(ThemeManager())
    .padding()
}
