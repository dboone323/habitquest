import Foundation

final class CalendarDataManager {
    static let shared = CalendarDataManager()
    private init() {}

    func load() -> [CalendarEvent] { [] }
    func save(events: [CalendarEvent]) {}
}
