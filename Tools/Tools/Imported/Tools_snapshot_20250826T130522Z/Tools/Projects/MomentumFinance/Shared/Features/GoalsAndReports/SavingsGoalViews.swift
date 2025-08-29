<<<<<<< HEAD
import UIKit
=======
>>>>>>> 1cf3938 (Create working state for recovery)
import SwiftData
import SwiftUI
import UIKit

<<<<<<< HEAD
=======
#if canImport(AppKit)
    import AppKit
#endif

>>>>>>> 1cf3938 (Create working state for recovery)
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

struct SavingsGoalsSection: View {
    let goals: [SavingsGoal]
    @Binding var showingAddGoal: Bool
    @Binding var selectedGoal: SavingsGoal?

    var body: some View {
        if goals.isEmpty {
            ContentUnavailableView(
                "No Savings Goals",
                systemImage: "target",
                description: Text("Create your first savings goal to start building your future"),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(goals, id: \.name) { goal in
                        SavingsGoalCard(goal: goal)
                            .onTapGesture {
                                selectedGoal = goal
                            }
                    }
                }
                .padding()
            }
        }
    }
}

struct SavingsGoalCard: View {
    let goal: SavingsGoal

    // Cross-platform color support
    private var backgroundColor: Color {
        #if canImport(UIKit)
<<<<<<< HEAD
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.white
=======
            return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
            return Color(NSColor.controlBackgroundColor)
        #else
            return Color.white
>>>>>>> 1cf3938 (Create working state for recovery)
        #endif
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if let targetDate = goal.targetDate {
                        Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            // Progress Section
            VStack(spacing: 8) {
                HStack {
                    Text(goal.formattedCurrentAmount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("of \(goal.formattedTargetAmount)")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(goal.progressPercentage * 100))%")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }

                ProgressView(value: goal.progressPercentage)
<<<<<<< HEAD
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.isCompleted ? .green : .blue))
=======
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: goal.isCompleted ? .green : .blue))
>>>>>>> 1cf3938 (Create working state for recovery)
            }

            // Details Row
            HStack {
                if !goal.isCompleted {
                    Text("Remaining: \(goal.formattedRemainingAmount)")
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
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
