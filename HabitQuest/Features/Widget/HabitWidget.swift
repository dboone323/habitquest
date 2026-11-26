import HabitQuestCore
import SwiftData
import SwiftUI
import WidgetKit

/// Entry for the habit widget timeline.
public struct HabitWidgetEntry: TimelineEntry {
    public let date: Date
    public let habits: [HabitWidgetItem]

    public init(date: Date, habits: [HabitWidgetItem]) {
        self.date = date
        self.habits = habits
    }
}

/// Provider for the habit widget timeline (read-only view of on-device SwiftData habits).
public struct HabitWidgetProvider: TimelineProvider, Sendable {
    private let loader: @MainActor @Sendable () -> [HabitWidgetItem]

    public init(loader: (@MainActor @Sendable () -> [HabitWidgetItem])? = nil) {
        self.loader = loader ?? { HabitWidgetDataLoader.loadTodaysHabitsFromSharedContainer() }
    }

    public func placeholder(in _: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habits: [
                HabitWidgetItem(id: UUID(), name: "Exercise", emoji: "🏃", isCompleted: false, streak: 5),
                HabitWidgetItem(id: UUID(), name: "Read", emoji: "📚", isCompleted: true, streak: 12),
                HabitWidgetItem(id: UUID(), name: "Meditate", emoji: "🧘", isCompleted: false, streak: 3),
            ]
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }
        let loadHabits = loader
        nonisolated(unsafe) let sendCompletion = completion
        Task { @MainActor in
            let habits = loadHabits()
            sendCompletion(HabitWidgetEntry(date: Date(), habits: habits))
        }
    }

    public func getTimeline(in _: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let loadHabits = loader
        nonisolated(unsafe) let sendCompletion = completion
        Task { @MainActor in
            let habits = loadHabits()
            let entry = HabitWidgetEntry(date: Date(), habits: habits)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
            sendCompletion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}

/// Small widget view showing today's habits (read-only).
public struct HabitWidgetSmallView: View {
    public let entry: HabitWidgetEntry

    public init(entry: HabitWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Today's Quests")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(entry.habits.count(where: \.isCompleted))/\(entry.habits.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if entry.habits.isEmpty {
                Spacer()
                Text("No quests due today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
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
                Spacer(minLength: 0)
            }
        }
        .padding(4)
    }
}

/// Medium widget view showing up to 4 habits and streaks (read-only).
public struct HabitWidgetMediumView: View {
    public let entry: HabitWidgetEntry

    public init(entry: HabitWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today's Quests")
                    .font(.headline)

                Spacer()

                Text("\(entry.habits.count(where: \.isCompleted))/\(entry.habits.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if entry.habits.isEmpty {
                Spacer()
                Text("Open HabitQuest to add your daily habits.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                HStack(spacing: 10) {
                    ForEach(entry.habits.prefix(4)) { habit in
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
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(4)
    }
}

/// Lock Screen circular widget view showing today's completion progress.
public struct HabitWidgetAccessoryCircularView: View {
    public let entry: HabitWidgetEntry

    public init(entry: HabitWidgetEntry) {
        self.entry = entry
    }

    private var completedCount: Int {
        entry.habits.count(where: \.isCompleted)
    }

    private var totalCount: Int {
        entry.habits.count
    }

    public var body: some View {
        Gauge(
            value: totalCount > 0 ? Double(completedCount) : 0,
            in: 0...Double(max(totalCount, 1))
        ) {
            Text("Quests")
        } currentValueLabel: {
            Text("\(completedCount)/\(totalCount)")
                .font(.caption2.weight(.semibold))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

/// Main widget entry point view.
public struct HabitWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    public let entry: HabitWidgetEntry

    public init(entry: HabitWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        switch family {
        case .systemSmall:
            HabitWidgetSmallView(entry: entry)
        case .systemMedium:
            HabitWidgetMediumView(entry: entry)
        case .accessoryCircular:
            HabitWidgetAccessoryCircularView(entry: entry)
        default:
            HabitWidgetMediumView(entry: entry)
        }
    }
}

/// Widget configuration for HabitQuest.
public struct HabitQuestWidget: Widget {
    public let kind: String = "HabitQuestWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits from the Home Screen and Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}
