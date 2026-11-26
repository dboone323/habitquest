import SwiftUI

/// Reusable weekday selector (1 = Sunday ... 7 = Saturday) for habit scheduling.
struct WeekdaySchedulePicker: View {
    @Binding var selectedDays: Set<Int>

    private let days: [(id: Int, label: String)] = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scheduled Days")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                ForEach(days, id: \.id) { day in
                    let isSelected = selectedDays.contains(day.id)
                    Button {
                        if isSelected {
                            selectedDays.remove(day.id)
                        } else {
                            selectedDays.insert(day.id)
                        }
                    } label: {
                        Text(day.label)
                            .font(.caption.weight(.semibold))
                            .frame(width: 32, height: 32)
                            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
                            .foregroundColor(isSelected ? .white : .primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Weekday \(day.id)")
                    .accessibilityValue(isSelected ? "Selected" : "Unselected")
                }
            }
        }
        .padding(.vertical, 4)
    }
}
