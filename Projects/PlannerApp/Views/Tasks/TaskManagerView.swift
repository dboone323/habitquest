// PlannerApp/Views/Tasks/TaskManagerView.swift (Updated with iOS enhancements)
import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

// Type alias to resolve conflict between Swift's built-in Task and our custom Task model
typealias TaskModel = Task

struct TaskManagerView: View {
    // Access shared ThemeManager and data arrays
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss // Add dismiss capability
    @State private var tasks: [TaskModel] = [] // Holds all tasks loaded from storage
    @State private var newTaskTitle = "" // State for the input field text
    @FocusState private var isInputFieldFocused: Bool // Tracks focus state of the input field

    // Computed properties to filter tasks into incomplete and completed lists
    private var incompleteTasks: [TaskModel] {
        self.tasks.filter { !$0.isCompleted }.sortedById() // Use helper extension for sorting
    }

    private var completedTasks: [TaskModel] {
        self.tasks.filter(\.isCompleted).sortedById() // Use helper extension for sorting
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with buttons for better macOS compatibility
            HStack {
                Button("Done") {
                    #if os(iOS)
                    HapticManager.lightImpact()
                    #endif
                    self.dismiss()
                }
                .accessibilityLabel("Button")
                #if os(iOS)
                    .buttonStyle(.iOSSecondary)
                #endif
                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)

                Spacer()

                Text("Task Manager")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()

                // Invisible button for balance
                Button(action: {}) {
                    Text("")
                }
                .accessibilityLabel("Button")
                .disabled(true)
                .opacity(0)
                #if os(iOS)
                    .frame(minWidth: 60, minHeight: 44)
                #endif
            }
            .padding()
            .background(self.themeManager.currentTheme.secondaryBackgroundColor)

            // Main container using VStack with no spacing for tight layout control
            VStack(spacing: 0) {
                // --- Input Area ---
                HStack {
                    // Text field for adding new tasks
                    TextField("New Task", text: self.$newTaskTitle, onCommit: self.addTask)
                        .accessibilityLabel("Text Field") // Add task on Return key
                        .textFieldStyle(.plain) // Use plain style for custom background/padding
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)) // Custom padding
                        .background(self.themeManager.currentTheme.secondaryBackgroundColor) // Themed background
                        .cornerRadius(8) // Rounded corners
                        .focused(self.$isInputFieldFocused) // Link focus state
                        .font(
                            self.themeManager.currentTheme.font(
                                forName: self.themeManager.currentTheme.primaryFontName, size: 16
                            )
                        )
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    #if os(iOS)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .onSubmit {
                            self.addTask()
                        }
                    #endif

                    // Add Task Button
                    Button(action: {
                        #if os(iOS)
                        HapticManager.notificationSuccess()
                        #endif
                        self.addTask()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            // Color changes based on theme and whether input is empty
                            .foregroundColor(
                                self.newTaskTitle.isEmpty
                                    ? self.themeManager.currentTheme.secondaryTextColor
                                    : self.themeManager.currentTheme.primaryAccentColor
                            )
                    }
                    #if os(iOS)
                    .buttonStyle(.iOSPrimary)
                    #endif
                    .disabled(self.newTaskTitle.isEmpty) // Disable button if input is empty
                }
                .padding() // Padding around the input HStack
                // Apply primary theme background to the input section container
                .background(self.themeManager.currentTheme.primaryBackgroundColor)

                // --- Task List ---
                List {
                    // --- Incomplete Tasks Section ---
                    Section("To Do (\(self.incompleteTasks.count))") {
                        if self.incompleteTasks.isEmpty {
                            // Message shown when no incomplete tasks exist
                            Text("No tasks yet!")
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                .font(
                                    self.themeManager.currentTheme.font(
                                        forName: self.themeManager.currentTheme.secondaryFontName,
                                        size: 15
                                    )
                                )
                        } else {
                            // Iterate over incomplete tasks and display using TaskRow
                            ForEach(self.incompleteTasks) { task in
                                TaskRow(taskItem: task, tasks: self.$tasks) // Pass task and binding to tasks array
                                    .environmentObject(self.themeManager) // Ensure TaskRow can access theme
                            }
                            .onDelete(perform: self.deleteTaskIncomplete) // Enable swipe-to-delete
                        }
                    }
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor) // Theme row background
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor) // Theme row text color
                    .headerProminence(.increased) // Style section header

                    // --- Completed Tasks Section ---
                    Section("Completed (\(self.completedTasks.count))") {
                        if self.completedTasks.isEmpty {
                            // Message shown when no completed tasks exist
                            Text("No completed tasks.")
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                .font(
                                    self.themeManager.currentTheme.font(
                                        forName: self.themeManager.currentTheme.secondaryFontName,
                                        size: 15
                                    )
                                )
                        } else {
                            // Iterate over completed tasks
                            ForEach(self.completedTasks) { task in
                                TaskRow(taskItem: task, tasks: self.$tasks)
                                    .environmentObject(self.themeManager)
                            }
                            .onDelete(perform: self.deleteTaskCompleted) // Enable swipe-to-delete
                        }
                    }
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .headerProminence(.increased)
                }
                // Apply theme background color to the List view itself
                .background(self.themeManager.currentTheme.primaryBackgroundColor)
                // Hide the default List background style (e.g., plain/grouped)
                .scrollContentBackground(.hidden)
                // Add tap gesture to the List to dismiss keyboard when tapping outside the text field
                .onTapGesture {
                    self.isInputFieldFocused = false
                    #if os(iOS)
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                        for: nil
                    )
                    #endif
                }
                #if os(iOS)
                .iOSKeyboardDismiss()
                #endif
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
                    Button("Edit") {
                        // Custom edit implementation for macOS
                    }
                    .accessibilityLabel("Button")
                }
                // Add a "Done" button to the keyboard toolbar
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer() // Push button to the right
                        Button("Done") { self.isInputFieldFocused = false } // Dismiss keyboard on tap
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

        // Create new Task instance. Ensure Task model has necessary initializers.
        // If Task needs `completionDate`, initialize it as nil here.
        let newTask = TaskModel(title: trimmedTitle /* , completionDate: nil */ )
        self.tasks.append(newTask) // Add to the local state array
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
    private func deleteTask(from sourceArray: [TaskModel], at offsets: IndexSet) {
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
        // Read settings directly using AppStorage within this function scope
        @AppStorage(AppSettingKeys.autoDeleteCompleted) var autoDeleteEnabled = false
        @AppStorage(AppSettingKeys.autoDeleteDays) var autoDeleteDays = 30

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

// --- TaskRow Subview ---
// Displays a single task item in the list
struct TaskRow: View {
    // Access shared ThemeManager
    @EnvironmentObject var themeManager: ThemeManager
    // The specific task to display
    let taskItem: TaskModel
    // Binding to the main tasks array to allow modification (toggling completion)
    @Binding var tasks: [TaskModel]

    var body: some View {
        HStack {
            // Checkmark icon (filled if completed, empty circle otherwise)
            Image(systemName: self.taskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                // Apply theme colors based on completion status
                .foregroundColor(
                    self.taskItem.isCompleted
                        ? self.themeManager.currentTheme.completedColor
                        : self.themeManager.currentTheme.secondaryTextColor
                )
                .font(.title3) // Make icon slightly larger
                .onTapGesture { self.toggleCompletion() } // Toggle completion on icon tap

            // Task title text
            Text(self.taskItem.title)
                .font(
                    self.themeManager.currentTheme.font(
                        forName: self.themeManager.currentTheme.primaryFontName, size: 16
                    )
                )
                // Apply strikethrough effect if completed
                .strikethrough(
                    self.taskItem.isCompleted, color: self.themeManager.currentTheme.secondaryTextColor
                )
                // Apply theme text color based on completion status
                .foregroundColor(
                    self.taskItem.isCompleted
                        ? self.themeManager.currentTheme.secondaryTextColor
                        : self.themeManager.currentTheme.primaryTextColor
                )

            Spacer() // Push content to the left
        }
        .contentShape(Rectangle()) // Make the entire HStack tappable
        .onTapGesture { self.toggleCompletion() } // Toggle completion on row tap
        // Row background color is applied by the parent List section modifier
    }

    // Toggles the completion status of the task and saves changes
    private func toggleCompletion() {
        // Find the index of this task in the main array
        if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
            #if os(iOS)
            // Add haptic feedback for task completion
            if self.tasks[index].isCompleted {
                HapticManager.lightImpact()
            } else {
                HapticManager.notificationSuccess()
            }
            #endif

            // Toggle the boolean state
            self.tasks[index].isCompleted.toggle()
            // ** IMPORTANT: Update completionDate if Task model supports it **
            // tasks[index].completionDate = tasks[index].isCompleted ? Date() : nil
            // Persist the change immediately
            TaskDataManager.shared.save(tasks: self.tasks)
            print("Toggled task '\(self.tasks[index].title)' to \(self.tasks[index].isCompleted)")
        }
    }
}

// --- Helper extension for sorting Task array ---
extension [TaskModel] {
    // Sorts tasks stably based on their UUID string representation
    func sortedById() -> [TaskModel] {
        self.sorted(by: { $0.id.uuidString < $1.id.uuidString })
    }
}

// --- Preview Provider ---
struct TaskManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskManagerView()
            // Provide ThemeManager for the preview
            .environmentObject(ThemeManager())
    }
}
