import HabitQuestCore
#if canImport(AppIntents)
    import AppIntents

    @available(iOS 16.0, macOS 13.0, *)
    struct OpenTodaysQuestsIntent: AppIntent {
        static let title: LocalizedStringResource = "Open Today's Quests"
        static let description = IntentDescription("Open HabitQuest and jump directly into today's quests.")

        func perform() async throws -> some IntentResult {
            .result()
        }
    }

    @available(iOS 16.0, macOS 13.0, *)
    struct CompleteHabitIntent: AppIntent {
        static let title: LocalizedStringResource = "Complete Habit"
        static let description = IntentDescription("Mark a habit as completed.")

        @Parameter(title: "Habit ID")
        var habitId: String

        func perform() async throws -> some IntentResult {
            .result()
        }
    }

    @available(iOS 16.0, macOS 13.0, *)
    struct OpenHabitDetailIntent: AppIntent {
        static let title: LocalizedStringResource = "View Habit Details"
        static let description = IntentDescription("Open the details view for a specific habit.")

        @Parameter(title: "Habit ID")
        var habitId: String

        func perform() async throws -> some IntentResult {
            .result()
        }
    }
#endif
