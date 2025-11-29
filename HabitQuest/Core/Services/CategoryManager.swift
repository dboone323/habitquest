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
        return HabitCategory.allCases.map { category in
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
        return HabitCategory(rawValue: id)
    }
    
    func getSuggestedTags(for category: HabitCategory) -> [String] {
        switch category {
        case .health: return ["hydration", "nutrition", "sleep", "medication"]
        case .fitness: return ["cardio", "strength", "flexibility", "sports"]
        case .learning: return ["reading", "coding", "language", "course"]
        case .productivity: return ["work", "focus", "planning", "organization"]
        case .social: return ["family", "friends", "networking", "community"]
        case .creativity: return ["writing", "art", "music", "craft"]
        case .mindfulness: return ["meditation", "journaling", "gratitude", "breathing"]
        case .other: return ["misc", "personal", "household"]
        }
    }
}
