import UIKit
import SwiftData
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

public struct SavingsGoalsSection: View {
    let goals: [SavingsGoal]
    @Binding var showingAddGoal: Bool
    @Binding var selectedGoal: SavingsGoal?

    public var body: some View {
        if self.goals.isEmpty {
            ContentUnavailableView(
                "No Savings Goals",
                systemImage: "target",
                description: Text("Create your first savings goal to start building your future"),
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(self.goals, id: \.name) { goal in
                        SavingsGoalCard(goal: goal)
                            .onTapGesture {
                                self.selectedGoal = goal
                            }
                    }
                }
                .padding()
            }
        }
    }
}

public struct SavingsGoalCard: View {
    let goal: SavingsGoal

    // Cross-platform color support
    private var backgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.white
        #endif
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.goal.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if let targetDate = goal.targetDate {
                        Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if self.goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            // Progress Section
            VStack(spacing: 8) {
                HStack {
                    Text(self.goal.formattedCurrentAmount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("of \(self.goal.formattedTargetAmount)")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(self.goal.progressPercentage * 100))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }

                ProgressView(value: self.goal.progressPercentage)
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: self.goal.isCompleted ? .green : .blue)
                    )
            }

            // Details Row
            HStack {
                if !self.goal.isCompleted {
                    Text("Remaining: \(self.goal.formattedRemainingAmount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Goal Completed! 🎉")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }

                Spacer()

                if let daysRemaining = goal.daysRemaining {
                    Text("\(daysRemaining) days left")
                        .font(.caption)
                        .foregroundColor(daysRemaining <= 30 ? .red : .secondary)
                }
            }
        }
        .padding()
        .background(self.backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
