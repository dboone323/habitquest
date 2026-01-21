//
// CategoryManager.swift
// HabitQuest
//
// Manages habit categories and tags
//

import Foundation
import SwiftUI

class CategoryManager {
    static let shared = CategoryManager()

    struct CategoryInfo: Identifiable {
        let id: String
        let name: String
        let icon: String
        let color: Color
        let description: String
    }

    func getAllCategories() -> [CategoryInfo] {
        HabitCategory.allCases.map { category in
            CategoryInfo(
                id: category.rawValue,
                name: category.rawValue.capitalized,
                icon: category.emoji,
                color: Color(category.color),
                description: "Habits related to \(category.rawValue)"
            )
        }
    }

    func getCategory(by id: String) -> HabitCategory? {
        HabitCategory(rawValue: id)
    }

    func getSuggestedTags(for category: HabitCategory) -> [String] {
        switch category {
        case .health: ["hydration", "nutrition", "sleep", "medication"]
        case .fitness: ["cardio", "strength", "flexibility", "sports"]
        case .learning: ["reading", "coding", "language", "course"]
        case .productivity: ["work", "focus", "planning", "organization"]
        case .social: ["family", "friends", "networking", "community"]
        case .creativity: ["writing", "art", "music", "craft"]
        case .mindfulness: ["meditation", "journaling", "gratitude", "breathing"]
        case .other: ["misc", "personal", "household"]
        }
    }
}
