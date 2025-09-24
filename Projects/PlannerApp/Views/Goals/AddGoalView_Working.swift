import Foundation
import SwiftUI

public struct AddGoalView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]

    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()
    @State private var priority: GoalPriority = .medium
    @State private var progress: Double = 0.0

    @FocusState private var isDescriptionFocused: Bool

    private var isFormValid: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !self.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Title", text: self.$title).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                        .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 16))
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.secondaryFontName, size: 14))
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        TextEditor(text: self.$description)
                            .frame(height: 100)
                            .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 16))
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            .focused(self.$isDescriptionFocused)
                    }

                    DatePicker("Target Date", selection: self.$targetDate, displayedComponents: .date)
                        .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.primaryFontName, size: 16))

                    Picker("Priority", selection: self.$priority) {
                        ForEach(GoalPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Progress: \(Int(self.progress * 100))%")
                            .font(self.themeManager.currentTheme.font(forName: self.themeManager.currentTheme.secondaryFontName, size: 14))
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        Slider(value: self.$progress, in: 0 ... 1)
                            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
                    }
                }
                .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.saveGoal()
                        self.dismiss()
                    }
                    .disabled(!self.isFormValid)
                    .foregroundColor(self.isFormValid ? self.themeManager.currentTheme.primaryAccentColor : self.themeManager.currentTheme
                        .secondaryTextColor
                    )
                }
            }
        }
    }

    private func saveGoal() {
        let newGoal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
            targetDate: self.targetDate,
            priority: self.priority,
            progress: self.progress
        )
        self.goals.append(newGoal)
        GoalDataManager.shared.save(goals: self.goals)
    }
}

public struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(goals: Binding.constant([]))
            .environmentObject(ThemeManager())
    }
}
