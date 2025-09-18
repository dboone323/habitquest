// PlannerApp/Views/Goals/GoalsView.swift (Updated)
import SwiftUI

struct GoalsView: View {
    // Access shared ThemeManager and data
    @EnvironmentObject var themeManager: ThemeManager
    @State private var goals: [Goal] = [] // Holds all goals
    @State private var showAddGoal = false // State to control presentation of AddGoal sheet

    // Read date/time settings if needed for display (e.g., formatter locale)
    @AppStorage(AppSettingKeys.use24HourTime) private var use24HourTime: Bool = false // Example, not used in formatter below

    // Formatter for displaying the target date
    private var targetDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // e.g., Apr 29, 2025
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        NavigationStack {
            // Use List to display goals
            List {
                // Display a message if no goals exist
                if self.goals.isEmpty {
                    Text("No goals set yet. Tap '+' to add one!")
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        .font(
                            self.themeManager.currentTheme.font(
                                forName: self.themeManager.currentTheme.secondaryFontName, size: 15
                            )
                        )
                        .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the text
                } else {
                    // Iterate over goals sorted by target date
                    ForEach(self.goals.sorted(by: { $0.targetDate < $1.targetDate })) { goal in
                        // Layout for each goal row
                        VStack(alignment: .leading, spacing: 4) { // Control spacing within the VStack
                            // Goal Title
                            Text(goal.title)
                                .font(
                                    self.themeManager.currentTheme.font(
                                        forName: self.themeManager.currentTheme.primaryFontName,
                                        size: 17, weight: .semibold
                                    )
                                )
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            // Goal Description
                            Text(goal.description)
                                .font(
                                    self.themeManager.currentTheme.font(
                                        forName: self.themeManager.currentTheme.secondaryFontName,
                                        size: 15
                                    )
                                )
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                .lineLimit(2) // Limit description to 2 lines
                            // Target Date
                            Text("Target: \(goal.targetDate, formatter: self.targetDateFormatter)") // Formatted date
                                .font(
                                    self.themeManager.currentTheme.font(
                                        forName: self.themeManager.currentTheme.secondaryFontName,
                                        size: 13
                                    )
                                )
                                .foregroundColor(
                                    self.themeManager.currentTheme.secondaryTextColor.opacity(0.8)
                                ) // Slightly dimmer
                        }
                        .padding(.vertical, 6) // Add vertical padding inside the row
                    }
                    .onDelete(perform: self.deleteGoal) // Enable swipe-to-delete
                    // Apply theme background to all rows in the list
                    .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
                }
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor) // Apply theme background to List
            .scrollContentBackground(.hidden) // Hide default List background style
            .navigationTitle("Goals")
            .toolbar {
                // Button to show the AddGoalView sheet
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        self.showAddGoal.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                // Custom Edit button for macOS
                ToolbarItem(placement: .navigation) {
                    Button("Edit") {
                        // Custom edit implementation for macOS
                    }
                    .accessibilityLabel("Button")
                }
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
            // Apply theme accent color to toolbar items
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
        } // End NavigationStack
        // Use stack navigation style
    }

    // --- Data Functions ---

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
struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            // Provide ThemeManager for the preview
            .environmentObject(ThemeManager())
    }
}
