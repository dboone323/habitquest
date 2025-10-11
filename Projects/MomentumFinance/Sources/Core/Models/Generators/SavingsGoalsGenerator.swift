import Foundation
import SwiftData

/// Savings goals data generator
@MainActor
final class SavingsGoalsGenerator: DataGenerator {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generates sample savings goals with various targets and timelines
    func generate() {
        let calendar = Calendar.current
        let savingsGoals = [
            (
                name: "Emergency Fund",
                target: 10000.0,
                current: 3500.0,
                targetDate: calendar.date(byAdding: .month, value: 12, to: Date()),
                notes: "6 months of expenses for financial security"
            ),
            (
                name: "Vacation Fund",
                target: 5000.0,
                current: 1200.0,
                targetDate: calendar.date(byAdding: .month, value: 8, to: Date()),
                notes: "Summer vacation to Europe"
            ),
            (
                name: "New Car",
                target: 25000.0,
                current: 8500.0,
                targetDate: calendar.date(byAdding: .month, value: 24, to: Date()),
                notes: "Down payment for electric vehicle"
            ),
            (
                name: "Home Down Payment",
                target: 50000.0,
                current: 15000.0,
                targetDate: calendar.date(byAdding: .month, value: 36, to: Date()),
                notes: "20% down payment for first home"
            ),
            (
                name: "Retirement Boost",
                target: 15000.0,
                current: 2000.0,
                targetDate: calendar.date(byAdding: .year, value: 2, to: Date()),
                notes: "Extra contribution to retirement account"
            ),
        ]

        for goal in savingsGoals {
            let newGoal = SavingsGoal(
                name: goal.name,
                targetAmount: goal.target,
                currentAmount: goal.current,
                targetDate: goal.targetDate,
                notes: goal.notes
            )

            self.modelContext.insert(newGoal)
        }

        try? self.modelContext.save()
    }
}
