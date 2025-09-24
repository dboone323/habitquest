import SwiftUI

public struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]

    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()

    public var body: some View {
        NavigationView {
            Form {
                TextField("Goal Title", text: self.$title).accessibilityLabel("Text Field")
                TextField("Description", text: self.$description).accessibilityLabel("Text Field")
                DatePicker("Target Date", selection: self.$targetDate, displayedComponents: .date)
            }
            .navigationTitle("New Goal")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: {
                    self.dismiss()
                })
                .accessibilityLabel("Button")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: {
                    let newGoal = Goal(
                        title: title, description: description, targetDate: targetDate
                    )
                    self.goals.append(newGoal)
                    GoalDataManager.shared.save(goals: self.goals)
                    self.dismiss()
                })
                .accessibilityLabel("Button")
                .disabled(self.title.isEmpty || self.description.isEmpty)
            }
        }
    }
}
