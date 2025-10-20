// PlannerApp/Components/Tasks/TaskListView.swift
import Foundation
import SwiftUI

#if os(iOS)
    import UIKit
#endif

public struct TaskListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState.Binding var isInputFieldFocused: Bool
    let incompleteTasks: [PlannerTask]
    let completedTasks: [PlannerTask]
    @Binding var tasks: [PlannerTask]
    let onDeleteIncomplete: (IndexSet) -> Void
    let onDeleteCompleted: (IndexSet) -> Void

    public var body: some View {
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
                    .onDelete(perform: self.onDeleteIncomplete) // Enable swipe-to-delete
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
                    .onDelete(perform: self.onDeleteCompleted) // Enable swipe-to-delete
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
    }
}
