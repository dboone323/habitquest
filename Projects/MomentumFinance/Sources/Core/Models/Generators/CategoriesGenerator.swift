import Foundation
import SwiftData

/// Protocol for data generators
@MainActor
protocol DataGenerator {
    var modelContext: ModelContext { get }
    func generate()
}

/// Categories data generator
@MainActor
final class CategoriesGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generates default expense categories for the app
    func generate() {
        let categories = [
            (name: "Housing", icon: "house.fill"),
            (name: "Transportation", icon: "car.fill"),
            (name: "Food & Dining", icon: "fork.knife"),
            (name: "Utilities", icon: "bolt.fill"),
            (name: "Entertainment", icon: "tv.fill"),
            (name: "Shopping", icon: "bag.fill"),
            (name: "Health & Fitness", icon: "heart.fill"),
            (name: "Travel", icon: "airplane"),
            (name: "Education", icon: "book.fill"),
            (name: "Income", icon: "dollarsign.circle.fill"),
        ]

        for category in categories {
            let newCategory = ExpenseCategory(
                name: category.name,
                iconName: category.icon
            )
            self.modelContext.insert(newCategory)
        }

        try? self.modelContext.save()
    }
}
