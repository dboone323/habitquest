import HabitQuestCore
import SwiftUI

/// Shared mutable draft state for creating or editing a `Habit` in quest forms.
struct QuestFormDraft {
    var name: String
    var description: String
    var frequency: HabitFrequency
    var xpValue: Int
    var scheduledDays: Set<Int>
    var customIntervalDays: Int
    var hasReminderTime: Bool
    var reminderTime: Date
    var syncWithHealth: Bool
    var healthMetric: HealthMetricType
    var targetValue: Double

    init(habit: Habit? = nil) {
        name = habit?.name ?? ""
        description = habit?.habitDescription ?? ""
        frequency = habit?.frequency ?? .daily
        xpValue = habit?.xpValue ?? 10
        scheduledDays = Set(habit?.scheduledDays ?? [])
        customIntervalDays = habit?.customIntervalDays ?? 2
        hasReminderTime = habit?.reminderTime != nil
        reminderTime = habit?.reminderTime
            ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
            ?? Date()
        syncWithHealth = habit?.healthMetric != nil
        let metric = habit?.healthMetric ?? .steps
        healthMetric = metric
        targetValue = habit?.targetValue ?? metric.defaultTarget
    }

    var resolvedScheduledDays: [Int]? {
        (frequency == .custom || frequency == .weekly) && !scheduledDays.isEmpty
            ? scheduledDays.sorted()
            : nil
    }

    var resolvedCustomIntervalDays: Int? {
        frequency == .custom && scheduledDays.isEmpty ? customIntervalDays : nil
    }

    var resolvedReminderTime: Date? {
        hasReminderTime ? reminderTime : nil
    }

    var resolvedHealthMetric: HealthMetricType? {
        syncWithHealth ? healthMetric : nil
    }

    var resolvedTargetValue: Double? {
        syncWithHealth ? targetValue : nil
    }

    func makeHabit() -> Habit {
        Habit(
            name: name,
            habitDescription: description,
            frequency: frequency,
            xpValue: xpValue,
            healthMetric: resolvedHealthMetric,
            targetValue: resolvedTargetValue,
            scheduledDays: resolvedScheduledDays,
            customIntervalDays: resolvedCustomIntervalDays,
            reminderTime: resolvedReminderTime
        )
    }

    func apply(to habit: Habit) {
        habit.name = name
        habit.habitDescription = description
        habit.frequency = frequency
        habit.xpValue = xpValue
        habit.healthMetric = resolvedHealthMetric
        habit.targetValue = resolvedTargetValue
        habit.scheduledDays = resolvedScheduledDays
        habit.customIntervalDays = resolvedCustomIntervalDays
        habit.reminderTime = resolvedReminderTime
    }
}

/// Shared form sections for quest details, scheduling, reminders, and Apple Health auto-fill.
struct QuestFormSections: View {
    @Binding var draft: QuestFormDraft
    let settingsTitle: String
    let xpLabelPrefix: String
    let maxXP: Int

    var body: some View {
        Section("Quest Details") {
            TextField("Quest Name", text: $draft.name)
                .accessibilityLabel("Text Field")
            TextField("Description", text: $draft.description, axis: .vertical)
                .accessibilityLabel("Text Field")
                .lineLimit(3...6)
        }

        Section(settingsTitle) {
            Picker("Frequency", selection: $draft.frequency) {
                ForEach(HabitFrequency.allCases, id: \.self) { freq in
                    Text(freq.displayName).tag(freq)
                }
            }

            if draft.frequency == .custom || draft.frequency == .weekly {
                WeekdaySchedulePicker(selectedDays: $draft.scheduledDays)
            }

            if draft.frequency == .custom && draft.scheduledDays.isEmpty {
                Stepper("Every \(draft.customIntervalDays) days", value: $draft.customIntervalDays, in: 2...30)
            }

            Stepper("\(xpLabelPrefix): \(draft.xpValue)", value: $draft.xpValue, in: 5...maxXP, step: 5)
        }

        Section("Reminder") {
            Toggle("Daily Reminder", isOn: $draft.hasReminderTime)
                .accessibilityLabel("Daily Reminder")

            if draft.hasReminderTime {
                DatePicker("Reminder Time", selection: $draft.reminderTime, displayedComponents: .hourAndMinute)
            }
        }

        Section("Apple Health Auto-Fill") {
            Toggle("Sync with Apple Health", isOn: $draft.syncWithHealth)
                .accessibilityLabel("Sync with Apple Health")

            if draft.syncWithHealth {
                Picker("Health Metric", selection: $draft.healthMetric) {
                    ForEach(HealthMetricType.allCases) { metric in
                        Text(metric.displayName).tag(metric)
                    }
                }
                .onChange(of: draft.healthMetric) { _, newMetric in
                    draft.targetValue = newMetric.defaultTarget
                }

                HStack {
                    Text("Daily Target (\(draft.healthMetric.unitLabel))")
                    Spacer()
                    TextField("Target", value: $draft.targetValue, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                }
            }
        }
    }
}
