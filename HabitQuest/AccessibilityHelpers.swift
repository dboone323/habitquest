
import SwiftUI

// Enhancement #85: Accessibility Audit & Helpers
// Provides custom modifiers to ensure accessibility compliance

struct AccessibleHabitRow: View {
    let habitName: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(habitName)
                .font(.headline)
            Spacer()
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(habitName), \(isCompleted ? "completed" : "not completed")"))
        .accessibilityHint(Text("Double tap to toggle completion"))
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            action()
        }
    }
}
