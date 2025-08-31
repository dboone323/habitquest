import Foundation

final class TaskDataManager {
    static let shared = TaskDataManager()
    private init() {}

    func load() -> [Task] { [] }
    func save(tasks: [Task]) {}
}
