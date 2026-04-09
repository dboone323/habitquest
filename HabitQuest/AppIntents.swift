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
#endif
