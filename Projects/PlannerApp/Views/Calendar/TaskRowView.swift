// PlannerApp/Views/Calendar/TaskRowView.swift
import SwiftUI

public struct TaskRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let task: PlannerTask

    private var priorityColor: Color {
        switch self.task.priority {
        case .high:
            .red
        case .medium:
            .orange
        case .low:
            .green
        }
    }

    private var priorityText: String {
        switch self.task.priority {
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        }
    }

    private var isOverdue: Bool {
        guard let dueDate = task.dueDate else { return false }
        return !self.task.isCompleted && dueDate < Date()
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Priority and status indicator
            VStack(alignment: .center, spacing: 2) {
                if self.task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else if self.isOverdue {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                } else {
                    Circle()
                        .fill(self.priorityColor)
                        .frame(width: 8, height: 8)
                }

                Text(self.priorityText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(self.task.isCompleted ? .green : (self.isOverdue ? .red : self.priorityColor))
            }
            .frame(width: 50)

            // Task details
            VStack(alignment: .leading, spacing: 2) {
                Text(self.task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.task.isCompleted ?
                        self.themeManager.currentTheme.secondaryTextColor :
                        self.themeManager.currentTheme.primaryTextColor
                    )
                    .strikethrough(self.task.isCompleted)
                    .lineLimit(2)

                if !self.task.description.isEmpty {
                    Text(self.task.description)
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        .lineLimit(1)
                }

                // Due date indicator
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(self.isOverdue ? .red : self.themeManager.currentTheme.secondaryTextColor)

                        Text("Due: \(self.dueDateFormatter.string(from: dueDate))")
                            .font(.caption2)
                            .foregroundColor(self.isOverdue ? .red : self.themeManager.currentTheme.secondaryTextColor)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var dueDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    VStack {
        TaskRowView(task: PlannerTask(
            id: UUID(),
            title: "Review Pull Request",
            description: "Check the new feature implementation",
            isCompleted: false,
            priority: .high,
            dueDate: Date()
        ))

        TaskRowView(task: PlannerTask(
            id: UUID(),
            title: "Buy Groceries",
            description: "Get items for dinner party",
            isCompleted: false,
            priority: .medium,
            dueDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        ))

        TaskRowView(task: PlannerTask(
            id: UUID(),
            title: "Completed Task",
            description: "This task is done",
            isCompleted: true,
            priority: .low,
            dueDate: Date()
        ))
    }
    .environmentObject(ThemeManager())
    .padding()
}
