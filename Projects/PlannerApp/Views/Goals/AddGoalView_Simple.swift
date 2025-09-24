import PlannerApp
import SwiftUI

public struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [Goal]

    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()

    private var isFormValid: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !self.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal Title", text: self.$title).accessibilityLabel("Text Field").accessibilityLabel("Text Field")

                    TextField("Description", text: self.$description, axis: .vertical).accessibilityLabel("Text Field")
                        .accessibilityLabel("Text Field")
                        .lineLimit(3 ... 6)

                    DatePicker("Target Date", selection: self.$targetDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save").accessibilityLabel("Button").accessibilityLabel("Button") {
                        self.saveGoal()
                        self.dismiss()
                    }
                    .disabled(!self.isFormValid)
                }
            }
        }
    }

    private func saveGoal() {
        let newGoal = Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
            targetDate: self.targetDate
        )
        self.goals.append(newGoal)
        GoalDataManager.shared.save(goals: self.goals)
    }
}

public struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView(goals: Binding.constant([]))
    }
}
