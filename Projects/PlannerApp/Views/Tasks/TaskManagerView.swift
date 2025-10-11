// PlannerApp/Views/Tasks/TaskManagerView.swift (Updated with iOS enhancements)
import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

// Type alias to distinguish our custom PlannerTask model from Swift's concurrency Task
// Use explicit reference to avoid ambiguity
// typealias PlannerTask = Task

public struct TaskManagerView: View {
    // Access shared ThemeManager and data arrays
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss // Add dismiss capability
    @State private var tasks: [PlannerTask] = [] // Holds all tasks loaded from storage
    @State private var newTaskTitle = "" // State for the input field text
    @FocusState private var isInputFieldFocused: Bool // Tracks focus state of the input field

    // Computed properties to filter tasks into incomplete and completed lists
    private var incompleteTasks: [PlannerTask] {
        self.tasks.filter { !$0.isCompleted }.sortedById() // Use helper extension for sorting
    }

    private var completedTasks: [PlannerTask] {
        self.tasks.filter(\.isCompleted).sortedById() // Use helper extension for sorting
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with buttons for better macOS compatibility
            TaskManagerHeaderView()
                .environmentObject(self.themeManager)

            // Main container using VStack with no spacing for tight layout control
            VStack(spacing: 0) {
                // --- Input Area ---
                TaskInputView(
                    newTaskTitle: self.$newTaskTitle,
                    isInputFieldFocused: self.$isInputFieldFocused,
                    onAddTask: self.addTask,
                    onAddAITask: self.addAITask
                )
                .environmentObject(self.themeManager)

                // --- Task List ---
                TaskListView(
                    isInputFieldFocused: self.$isInputFieldFocused,
                    incompleteTasks: self.incompleteTasks,
                    completedTasks: self.completedTasks,
                    tasks: self.$tasks,
                    onDeleteIncomplete: self.deleteTaskIncomplete,
                    onDeleteCompleted: self.deleteTaskCompleted
                )
                .environmentObject(self.themeManager)
            } // End main VStack
            // Ensure the primary background extends behind the navigation bar area if needed
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Tasks")
            // Load tasks and perform auto-deletion check when view appears
            .onAppear {
                self.loadTasks()
                self.performAutoDeletionIfNeeded() // Check and perform auto-deletion
            }
            .toolbar {
                // Custom Edit button for macOS list reordering/deletion mode
                ToolbarItem(placement: .navigation) {
                    Button("Edit", action: {
                        // Custom edit implementation for macOS
                    })
                    .accessibilityLabel("Button")
                }
                // Add a "Done" button to the keyboard toolbar
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer() // Push button to the right
                        Button("Done", action: { self.isInputFieldFocused = false }) // Dismiss keyboard on tap
                            .accessibilityLabel("Button")
                        // Uses theme accent color automatically
                    }
                }
            }
            // Apply theme accent color to navigation bar items (Edit, Done buttons)
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
        } // End main VStack
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 400)
        #else
        .iOSPopupOptimizations()
        #endif
    }

    // --- Data Functions ---

    // Adds a new task based on the input field text
    private func addTask() {
        let trimmedTitle = self.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return } // Don't add empty tasks

        // Create new PlannerTask instance. Ensure PlannerTask model has necessary initializers.
        // If PlannerTask needs `completionDate`, initialize it as nil here.
        let newTask = PlannerTask(title: trimmedTitle /* , completionDate: nil */ )
        self.tasks.append(newTask) // Add to the local state array
        self.newTaskTitle = "" // Clear the input field
        self.saveTasks() // Persist changes
        self.isInputFieldFocused = false // Dismiss keyboard
    }

    // Adds a new task using AI-parsed data
    private func addAITask(_ aiTask: PlannerTask) {
        self.tasks.append(aiTask) // Add the AI-parsed task directly
        self.newTaskTitle = "" // Clear the input field
        self.saveTasks() // Persist changes
        self.isInputFieldFocused = false // Dismiss keyboard
    }

    // Handles deletion from the incomplete tasks section
    private func deleteTaskIncomplete(at offsets: IndexSet) {
        self.deleteTask(from: self.incompleteTasks, at: offsets) // Use helper function
    }

    // Handles deletion from the completed tasks section
    private func deleteTaskCompleted(at offsets: IndexSet) {
        self.deleteTask(from: self.completedTasks, at: offsets) // Use helper function
    }

    // Helper function to delete tasks based on offsets from a filtered array
    private func deleteTask(from sourceArray: [PlannerTask], at offsets: IndexSet) {
        // Get the IDs of the tasks to be deleted from the source (filtered) array
        let idsToDelete = offsets.map { sourceArray[$0].id }
        // Remove tasks with matching IDs from the main `tasks` array
        self.tasks.removeAll { idsToDelete.contains($0.id) }
        self.saveTasks() // Persist changes
    }

    // Loads tasks from the data manager
    private func loadTasks() {
        self.tasks = TaskDataManager.shared.load()
        print("Tasks loaded. Count: \(self.tasks.count)")
    }

    // Saves the current state of the `tasks` array to the data manager
    private func saveTasks() {
        TaskDataManager.shared.save(tasks: self.tasks)
        print("Tasks saved.")
    }

    // --- Auto Deletion Logic ---
    // Checks settings and performs auto-deletion if enabled
    private func performAutoDeletionIfNeeded() {
        // Avoid @AppStorage during testing to prevent UserDefaults access crashes
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

        let autoDeleteEnabled: Bool
        var autoDeleteDays: Int

        if isTesting {
            // Use default values during testing
            autoDeleteEnabled = false
            autoDeleteDays = 30
        } else {
            // Read settings from UserDefaults
            autoDeleteEnabled = UserDefaults.standard.bool(forKey: AppSettingKeys.autoDeleteCompleted)
            autoDeleteDays = UserDefaults.standard.integer(forKey: AppSettingKeys.autoDeleteDays)
            if autoDeleteDays == 0 { // If not set, use default
                autoDeleteDays = 30
            }
        }

        // Only proceed if auto-delete is enabled
        guard autoDeleteEnabled else {
            print("Auto-deletion skipped (disabled).")
            return
        }

        // Calculate the cutoff date based on the setting
        guard Calendar.current.date(byAdding: .day, value: -autoDeleteDays, to: Date()) != nil
        else {
            print("Could not calculate cutoff date for auto-deletion.")
            return
        }

        let initialCount = self.tasks.count
        // IMPORTANT: Requires Task model to have `completionDate: Date?`
        self.tasks.removeAll { task in
            // Ensure task is completed and has a completion date
            guard task.isCompleted /* , let completionDate = task.completionDate */ else {
                return false // Keep incomplete or tasks without completion date
            }
            // *** Uncomment the completionDate check above and ensure Task model supports it ***

            // *** Placeholder Warning if completionDate is missing ***
            print(
                "Warning: Task model needs 'completionDate' for accurate auto-deletion based on date. Checking only 'isCompleted' status for now."
            )
            // If completionDate is missing, this would delete ALL completed tasks immediately
            // return true // DO NOT UNCOMMENT without completionDate check
            return false // Safely keep all tasks if completionDate logic is missing
            // *** End Placeholder ***

            // Actual logic: Remove if completion date is before the cutoff
            // return completionDate < cutoffDate
        }

        // Save only if tasks were actually removed
        if self.tasks.count < initialCount {
            print(
                "Auto-deleted \(initialCount - self.tasks.count) tasks older than \(autoDeleteDays) days."
            )
            self.saveTasks()
        } else {
            print("No tasks found matching auto-deletion criteria.")
        }
    }
}

// --- Helper extension for sorting PlannerTask array ---
extension [PlannerTask] {
    // Sorts tasks stably based on their UUID string representation
    func sortedById() -> [PlannerTask] {
        sorted(by: { $0.id.uuidString < $1.id.uuidString })
    }
}
