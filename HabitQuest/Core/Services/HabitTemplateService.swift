//
// HabitTemplateService.swift
// HabitQuest
//
// Service for habit templates and presets
//

import Foundation

struct HabitTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: HabitCategory
    let frequency: HabitFrequency
    let difficulty: HabitDifficulty
    let xpValue: Int
}

class HabitTemplateService {
    static let shared = HabitTemplateService()

    func getTemplates() -> [HabitTemplate] {
        [
            HabitTemplate(
                name: "Drink Water",
                description: "Drink 8 glasses of water daily",
                category: .health,
                frequency: .daily,
                difficulty: .easy,
                xpValue: 10
            ),
            HabitTemplate(
                name: "Read 30 Minutes",
                description: "Read a book for 30 minutes",
                category: .learning,
                frequency: .daily,
                difficulty: .medium,
                xpValue: 20
            ),
            HabitTemplate(
                name: "Exercise",
                description: "30 minutes of physical activity",
                category: .fitness,
                frequency: .daily,
                difficulty: .hard,
                xpValue: 30
            ),
            HabitTemplate(
                name: "Weekly Planning",
                description: "Plan the week ahead",
                category: .productivity,
                frequency: .weekly,
                difficulty: .medium,
                xpValue: 50
            ),
            HabitTemplate(
                name: "Call Family",
                description: "Call a family member",
                category: .social,
                frequency: .weekly,
                difficulty: .easy,
                xpValue: 25
            ),
        ]
    }

    func getTemplates(for category: HabitCategory) -> [HabitTemplate] {
        getTemplates().filter { $0.category == category }
    }
}
