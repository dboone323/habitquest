import Foundation

final class JournalDataManager {
    static let shared = JournalDataManager()
    private init() {}

    func load() -> [JournalEntry] { [] }
    func save(entries: [JournalEntry]) {}
}
