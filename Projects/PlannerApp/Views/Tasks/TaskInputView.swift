// PlannerApp/Views/Tasks/TaskInputView.swift
import SwiftUI

public struct TaskInputView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var aiService = AITaskPrioritizationService.shared

    @Binding var newTaskTitle: String
    var isInputFieldFocused: FocusState<Bool>.Binding
    var onAddTask: () -> Void
    var onAddAITask: ((PlannerTask) -> Void)? // New callback for AI-parsed tasks

    @State private var isAISuggestionsVisible = false
    @State private var aiParsedTask: PlannerTask?
    @State private var isProcessingAI = false

    public var body: some View {
        VStack(spacing: 16) {
            // Smart Task Input Header
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Task Creation")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryTextColor)

                    Text("Describe your task in natural language")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }

                Spacer()
            }
            .padding(.horizontal, 20)

            // AI-Powered Input Field
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .trailing) {
                    TextField("e.g., 'Call dentist tomorrow at 2pm for checkup'", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.currentTheme.secondaryBackgroundColor)
                        .cornerRadius(8)
                        .focused(isInputFieldFocused)
                        .onChange(of: newTaskTitle) { oldValue, newValue in
                            // Auto-parse when user types complete sentences
                            if newValue.contains(".") || newValue.contains("!") || newValue.contains("?") {
                                processNaturalLanguageInput(newValue)
                            }
                        }

                    if isProcessingAI {
                        ProgressView()
                            .padding(.trailing, 12)
                    }
                }

                // AI Suggestions Button
                Button(action: {
                    processNaturalLanguageInput(newTaskTitle)
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Parse with AI")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(themeManager.currentTheme.primaryAccentColor)
                    .cornerRadius(6)
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessingAI)
            }
            .padding(.horizontal, 20)

            // AI Parsed Task Preview
            if let parsedTask = aiParsedTask {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Parsed Task")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentTheme.primaryTextColor)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Title:")
                                .fontWeight(.medium)
                            Text(parsedTask.title)
                        }
                        .foregroundColor(themeManager.currentTheme.primaryTextColor)

                        if let dueDate = parsedTask.dueDate {
                            HStack {
                                Text("Due:")
                                    .fontWeight(.medium)
                                Text(dueDate, style: .date)
                            }
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }

                        HStack {
                            Text("Priority:")
                                .fontWeight(.medium)
                            Text(parsedTask.priority.rawValue)
                                .foregroundColor(priorityColor(for: parsedTask.priority))
                        }
                    }
                    .padding(12)
                    .background(themeManager.currentTheme.secondaryBackgroundColor)
                    .cornerRadius(8)

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            if let aiTask = aiParsedTask {
                                // Use AI-parsed task with full details
                                if let onAddAITask = onAddAITask {
                                    onAddAITask(aiTask)
                                } else {
                                    // Fallback to regular task creation
                                    newTaskTitle = aiTask.title
                                    aiParsedTask = nil
                                    onAddTask()
                                }
                            }
                        }) {
                            Text("Use AI Task")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(themeManager.currentTheme.primaryAccentColor)
                                .cornerRadius(6)
                        }

                        Button(action: {
                            aiParsedTask = nil
                        }) {
                            Text("Edit Manually")
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .transition(.opacity)
            }

            // Regular Add Task Button
            Button(action: onAddTask) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Task")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(themeManager.currentTheme.primaryAccentColor)
                .cornerRadius(8)
                .padding(.horizontal, 20)
            }
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.vertical, 16)
        .background(themeManager.currentTheme.primaryBackgroundColor)
    }

    private func processNaturalLanguageInput(_ input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isProcessingAI = true

        Task {
            do {
                if let parsedTask = try await aiService.parseNaturalLanguageTask(input) {
                    // Convert ParsedTask to PlannerTask for preview
                    let plannerTask = PlannerTask(
                        title: parsedTask.title,
                        priority: parsedTask.priority,
                        dueDate: parsedTask.dueDate
                    )
                    aiParsedTask = plannerTask
                }
            } catch {
                // Handle parsing error - could show user feedback
                print("AI parsing failed: \(error)")
            }
            isProcessingAI = false
        }
    }

    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
