// PlannerApp/Components/Goals/GoalsListView.swift
import Foundation
import SwiftUI

public struct GoalsListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let goals: [Goal]
    let onDelete: (IndexSet) -> Void
    let onProgressUpdate: (UUID, Double) -> Void
    let onCompletionToggle: (UUID) -> Void

    public var body: some View {
        List {
            if self.goals.isEmpty {
                GoalsEmptyStateView()
                    .environmentObject(self.themeManager)
            } else {
                // Iterate over goals sorted by target date
                ForEach(self.goals.sorted(by: { $0.targetDate < $1.targetDate })) { goal in
                    GoalItemView(
                        goal: goal,
                        onProgressUpdate: self.onProgressUpdate,
                        onCompletionToggle: self.onCompletionToggle
                    )
                    .environmentObject(self.themeManager)
                }
                .onDelete(perform: self.onDelete) // Enable swipe-to-delete
                // Apply theme background to all rows in the list
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
        }
        .background(self.themeManager.currentTheme.primaryBackgroundColor) // Apply theme background to List
        .scrollContentBackground(.hidden) // Hide default List background style
    }
}
