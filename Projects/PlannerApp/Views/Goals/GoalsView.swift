// PlannerApp/Views/Goals/GoalsView.swift (Updated)
import SwiftUI

public struct GoalsView: View {
    // Access shared ThemeManager and data
    @EnvironmentObject var themeManager: ThemeManager
    @State private var goals: [Goal] = [] // Holds all goals
    @State private var showAddGoal = false // State to control presentation of AddGoal sheet

    // Avoid @AppStorage during testing to prevent UserDefaults access crashes
    private var use24HourTime: Bool {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        return isTesting ? false : UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GoalsHeaderView(showAddGoal: self.$showAddGoal)
                    .environmentObject(self.themeManager)

                GoalsListView(
                    goals: self.goals,
                    onDelete: self.deleteGoal,
                    onProgressUpdate: self.updateGoalProgress,
                    onCompletionToggle: self.toggleGoalCompletion
                )
                .environmentObject(self.themeManager)
            }
            .sheet(isPresented: self.$showAddGoal) {
                // Present AddGoalView, passing binding and theme
                AddGoalView(goals: self.$goals)
                    .environmentObject(self.themeManager)
                    // Save goals when the sheet is dismissed
                    .onDisappear(perform: self.saveGoals)
            }
            // Load goals when the view appears
            .onAppear(perform: self.loadGoals)
        } // End NavigationStack
        // Use stack navigation style
    }

    // --- Data Functions ---

    // Updates the progress of a specific goal
    private func updateGoalProgress(goalId: UUID, progress: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            self.goals[index].progress = progress
            self.goals[index].modifiedAt = Date()
            self.saveGoals()
        }
    }

    // Toggles the completion status of a specific goal
    private func toggleGoalCompletion(goalId: UUID) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            let wasCompleted = self.goals[index].isCompleted
            self.goals[index].isCompleted = !wasCompleted

            // If marking as completed, set progress to 100%
            if !wasCompleted {
                self.goals[index].progress = 1.0
            }
            // If unmarking as completed, set progress to 95% (allowing room for adjustment)
            else {
                self.goals[index].progress = 0.95
            }

            self.goals[index].modifiedAt = Date()
            self.saveGoals()
        }
    }

    // Deletes goals based on offsets from the sorted list displayed
    private func deleteGoal(at offsets: IndexSet) {
        // Get the sorted list as it's displayed in the ForEach loop
        let sortedGoals = self.goals.sorted(by: { $0.targetDate < $1.targetDate })
        // Map the offsets to the actual IDs of the goals to be deleted
        let idsToDelete = offsets.map { sortedGoals[$0].id }
        // Remove goals with matching IDs from the main `goals` array
        self.goals.removeAll { idsToDelete.contains($0.id) }
        self.saveGoals() // Persist changes
    }

    // Loads goals from the data manager
    private func loadGoals() {
        self.goals = GoalDataManager.shared.load()
        print("Goals loaded. Count: \(self.goals.count)")
    }

    // Saves the current state of the `goals` array to the data manager
    private func saveGoals() {
        GoalDataManager.shared.save(goals: self.goals)
        print("Goals saved.")
    }
}

// --- Preview Provider ---
public struct GoalsView_Previews: PreviewProvider {
    public static var previews: some View {
        GoalsView()
            // Provide ThemeManager for the preview
            .environmentObject(ThemeManager())
    }
}
