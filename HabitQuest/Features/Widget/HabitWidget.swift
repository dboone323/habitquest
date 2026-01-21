//
// HabitWidget.swift
// HabitQuest
//
// Interactive widget for checking off habits from the home screen.
// Provides quick access to daily habit completion without opening the app.
//

import SwiftUI
import WidgetKit

/// Entry for the habit widget timeline.
struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habits: [HabitWidgetItem]
}

/// Simplified habit representation for the widget.
struct HabitWidgetItem: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let isCompleted: Bool
    let streak: Int
}

/// Provider for the habit widget timeline.
struct HabitWidgetProvider: TimelineProvider {
    func placeholder(in _: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
                HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
                HabitWidgetItem(id: UUID(), name: "Meditate", emoji: "🧘", isCompleted: false, streak: 3)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        // In production, fetch actual habits from shared container
        let habits = loadHabitsFromSharedContainer()

        let entry = HabitWidgetEntry(date: Date(), habits: habits)

        // Refresh timeline every hour or when app updates
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    /// Loads habits from the shared app group container.
    private func loadHabitsFromSharedContainer() -> [HabitWidgetItem] {
        // In production, use App Groups to share data between app and widget
        // For now, return sample data
        [
            HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
            HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
            HabitWidgetItem(id: UUID(), name: "Meditate", emoji: "🧘", isCompleted: false, streak: 3)
        ]
    }
}

/// Small widget view showing habit completion status.
struct HabitWidgetSmallView: View {
    let entry: HabitWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Habits")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(entry.habits.prefix(3)) { habit in
                HStack(spacing: 6) {
                    Text(habit.emoji)
                        .font(.caption)

                    Text(habit.name)
                        .font(.caption2)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(habit.isCompleted ? .green : .gray)
                        .font(.caption)
                }
            }
        }
        .padding()
    }
}

/// Medium widget view with interactive toggle buttons.
struct HabitWidgetMediumView: View {
    let entry: HabitWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Habits")
                    .font(.headline)

                Spacer()

                Text("\(entry.habits.count(where: { $0.isCompleted }))/\(entry.habits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                ForEach(entry.habits.prefix(4)) { habit in
                    // Interactive button using App Intents
                    Link(destination: URL(string: "habitquest://toggle/\(habit.id)")!) {
                        VStack(spacing: 4) {
                            Text(habit.emoji)
                                .font(.title2)

                            Text(habit.name)
                                .font(.caption2)
                                .lineLimit(1)

                            Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompleted ? .green : .gray)
                                .font(.caption)

                            if habit.streak > 0 {
                                Text("🔥\(habit.streak)")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
}

/// Main widget entry point view.
struct HabitWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: HabitWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            HabitWidgetSmallView(entry: entry)
        case .systemMedium:
            HabitWidgetMediumView(entry: entry)
        default:
            HabitWidgetMediumView(entry: entry)
        }
    }
}

// Widget configuration for HabitQuest.
// Note: This would be in a separate Widget Extension target
/*
 @main
 struct HabitQuestWidget: Widget {
     let kind: String = "HabitQuestWidget"

     var body: some WidgetConfiguration {
         StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
             HabitWidgetEntryView(entry: entry)
         }
         .configurationDisplayName("Habit Tracker")
         .description("Track your daily habits from the home screen.")
         .supportedFamilies([.systemSmall, .systemMedium])
     }
 }
 */

// MARK: - Preview

// Widget previews require a WidgetExtension target
// Use Xcode's canvas preview when widget extension is created
