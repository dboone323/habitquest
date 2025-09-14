import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]

    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Goal Title", text: $title).accessibilityLabel("Text Field")
                TextField("Description", text: $description).accessibilityLabel("Text Field")
                DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
            }
            .navigationTitle("New Goal")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .accessibilityLabel("Button")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let newGoal = Goal(
                        title: title, description: description, targetDate: targetDate)
                    goals.append(newGoal)
                    GoalDataManager.shared.save(goals: goals)
                    dismiss()
                }
                .accessibilityLabel("Button")
                .disabled(title.isEmpty || description.isEmpty)
            }
        }
    }
}
