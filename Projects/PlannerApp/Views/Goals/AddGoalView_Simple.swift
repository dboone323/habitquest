import PlannerApp
import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]

    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Title", text: $title).accessibilityLabel("Text Field")

                    TextField("Description", text: $description, axis: .vertical).accessibilityLabel("Text Field")
                        .lineLimit(3 ... 6)

                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel").accessibilityLabel("Button") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save").accessibilityLabel("Button") {
                        saveGoal()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private func saveGoal() {
        let newGoal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            targetDate: targetDate
        )
        goals.append(newGoal)
        GoalDataManager.shared.save(goals: goals)
    }
}

struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(goals: Binding.constant([]))
    }
}
