import Foundation

// PlannerApp/Views/Goals/AddGoalView.swift
import SwiftUI

public struct AddGoalView: View {
    // Access shared ThemeManager and dismiss action
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    // Binding to the goals array in the parent view (GoalsView)
    @Binding var goals: [Goal]

    // State variables for the form fields
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()
    // Focus state to manage keyboard for the TextEditor
    @FocusState private var isDescriptionFocused: Bool

    // Computed property to check if the form is valid for saving
    private var isFormValid: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !self.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with buttons for better macOS compatibility
            HStack {
                Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                    self.dismiss()
                }
                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)

                Spacer()

                Text("Add Goal")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()

                Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                    // Create the new goal
                    let newGoal = Goal(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
                        targetDate: self.targetDate
                    )

                    // Append the new goal to the array
                    self.goals.append(newGoal)

                    // Save goals to the data manager
                    GoalDataManager.shared.save(goals: self.goals)

                    // Dismiss the sheet
                    self.dismiss()
                }
                .disabled(!self.isFormValid)
                .foregroundColor(self.isFormValid ? self.themeManager.currentTheme.primaryAccentColor : self.themeManager.currentTheme
                    .secondaryTextColor
                )
            }
            .padding()
            .background(self.themeManager.currentTheme.secondaryBackgroundColor)

            // Use Form for standard iOS settings/input layout
            Form {
                // Section for the main goal details
                Section("Goal Details") {
                    // TextField for the goal title
                    TextField("Goal Title", text: self.$title).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                        .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 16))
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                    // TextEditor for the goal description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        TextEditor(text: self.$description)
                            .frame(minHeight: 80)
                            .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.secondaryFontName, size: 15))
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            .focused(self.$isDescriptionFocused)
                    }

                    // DatePicker for the target date
                    DatePicker("Target Date", selection: self.$targetDate, displayedComponents: .date)
                        .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 16))
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor)
            .scrollContentBackground(.hidden)
        }
        .background(self.themeManager.currentTheme.primaryBackgroundColor)
    }
}

// --- Preview Provider ---
public struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(goals: Binding.constant([]))
            .environmentObject(ThemeManager())
    }
}
