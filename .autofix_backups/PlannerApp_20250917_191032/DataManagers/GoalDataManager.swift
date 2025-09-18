import Foundation

final class GoalDataManager {
    static let shared = GoalDataManager()
    private init() {}

    // Returns stored goals; stub returns empty array for now
    func load() -> [Goal] { [] }

    // Persists goals; stub is a no-op to satisfy callsites
    func save(goals: [Goal]) {}
}
