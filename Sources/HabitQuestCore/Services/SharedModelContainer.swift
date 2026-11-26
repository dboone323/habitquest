import Foundation
import SwiftData

/// App Group identifier shared between the main HabitQuest app and its Widget Extension.
public enum HabitQuestAppGroup {
    public static let identifier = "group.com.habitquest.app"
}

/// Simplified, read-only habit representation for WidgetKit timelines.
public struct HabitWidgetItem: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let emoji: String
    public let isCompleted: Bool
    public let streak: Int

    public init(id: UUID, name: String, emoji: String, isCompleted: Bool, streak: Int) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isCompleted = isCompleted
        self.streak = streak
    }
}

/// Factory for the shared SwiftData ModelContainer backed by the App Group container.
public enum SharedModelContainer {
    public static var schema: Schema {
        Schema([
            Habit.self,
            HabitLog.self,
            PlayerProfile.self,
            Achievement.self,
        ])
    }

    /// Creates the shared ModelContainer, using the App Group store when available.
    public static func createContainer(inMemoryOnly: Bool = false) throws -> ModelContainer {
        if inMemoryOnly {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [config])
        }

        if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: HabitQuestAppGroup.identifier) != nil {
            let groupConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(HabitQuestAppGroup.identifier)
            )
            if let container = try? ModelContainer(for: schema, configurations: [groupConfig]) {
                return container
            }
        }

        let defaultConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [defaultConfig])
    }
}

/// Read-only loader that reads today's active habits from SwiftData for WidgetKit.
@MainActor
public enum HabitWidgetDataLoader {
    /// Reads active habits due today from the provided ModelContext.
    public static func loadTodaysHabits(
        from context: ModelContext,
        date: Date = Date(),
        calendar: Calendar = .current
    ) -> [HabitWidgetItem] {
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\Habit.creationDate)]
        )
        guard let habits = try? context.fetch(descriptor) else {
            return []
        }

        let gamificationService = GamificationService()
        return habits
            .filter { gamificationService.isHabitDueToday($0, on: date, calendar: calendar) }
            .map { habit in
                HabitWidgetItem(
                    id: habit.id,
                    name: habit.name,
                    emoji: habit.category.emoji,
                    isCompleted: habit.isCompletedToday,
                    streak: habit.streak
                )
            }
    }

    /// Reads active habits due today from the shared App Group ModelContainer.
    public static func loadTodaysHabitsFromSharedContainer() -> [HabitWidgetItem] {
        guard let container = try? SharedModelContainer.createContainer() else {
            return []
        }
        return loadTodaysHabits(from: ModelContext(container))
    }
}
