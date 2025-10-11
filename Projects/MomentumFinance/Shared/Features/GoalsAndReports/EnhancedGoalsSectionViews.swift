import AppKit
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

extension Features.GoalsAndReports {
    struct EnhancedSavingsGoalsSection: View {
        let goals: [SavingsGoal]
        @Binding var showingAddGoal: Bool
        @Binding var selectedGoal: SavingsGoal?

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

        private var activeGoals: [SavingsGoal] {
            self.goals.filter { !$0.isCompleted }
        }

        private var completedGoals: [SavingsGoal] {
            self.goals.filter(\.isCompleted)
        }

        private var totalSaved: Double {
            self.goals.reduce(0) { $0 + $1.currentAmount }
        }

        private var totalTarget: Double {
            self.goals.reduce(0) { $0 + $1.targetAmount }
        }

        var body: some View {
            VStack(spacing: 20) {
                if self.goals.isEmpty {
                    self.emptyGoalsView
                } else {
                    self.goalsContentView
                }
            }
        }

        private var emptyGoalsView: some View {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                VStack(spacing: 8) {
                    Text("No Savings Goals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Create your first savings goal to start building your financial future")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(
                    action: { self.showingAddGoal = true },
                    label: {
                        Label("Create Your First Goal", systemImage: "target")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing,
                                ),
                            )
                            .cornerRadius(12)
                    },
                )

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.backgroundColor)
        }

        private var goalsContentView: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    self.summarySection
                    self.activeGoalsSection
                    self.completedGoalsSection
                }
                .padding()
            }
            .background(self.backgroundColor)
        }

        private var summarySection: some View {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(
                            "\(self.activeGoals.count) active • \(self.completedGoals.count) completed"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalSaved.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Target")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(self.totalTarget.formatted(.currency(code: "USD")))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }

                if self.totalTarget > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(Int((self.totalSaved / self.totalTarget) * 100))%")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        ProgressView(value: self.totalSaved / self.totalTarget)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.05), Color.blue.opacity(0.1),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing,
                        ),
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1),
                    ),
            )
        }

        @ViewBuilder private var activeGoalsSection: some View {
            if !self.activeGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    ForEach(self.activeGoals, id: \.name) { goal in
                        EnhancedSavingsGoalCard(goal: goal)
                            .onTapGesture {
                                self.selectedGoal = goal
                            }
                    }
                }
            }
        }

        @ViewBuilder private var completedGoalsSection: some View {
            if !self.completedGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completed Goals")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    ForEach(self.completedGoals, id: \.name) { goal in
                        EnhancedSavingsGoalCard(goal: goal)
                            .onTapGesture {
                                self.selectedGoal = goal
                            }
                    }
                }
            }
        }
    }

    struct EnhancedSavingsGoalCard: View {
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

        var body: some View {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(self.goal.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if let targetDate = goal.targetDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text(
                                    "Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))"
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    if self.goal.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)

                            Text("Completed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("\(Int(self.goal.progressPercentage * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1),
                                    ),
                            )
                    }
                }

                // Progress Section
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(self.goal.formattedCurrentAmount)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }

                        Spacer()

                        VStack(alignment: .center, spacing: 2) {
                            Text(self.goal.isCompleted ? "Achieved!" : "Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(self.goal.isCompleted ? "🎉" : self.goal.formattedRemainingAmount)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(self.goal.isCompleted ? .green : .orange)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Target")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(self.goal.formattedTargetAmount)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }

                    // Progress Bar with Gradient
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: self.goal.isCompleted
                                                ? [.green, .green.opacity(0.8)]
                                                : [.blue, .blue.opacity(0.7)]
                                        ),
                                        startPoint: .leading,
                                        endPoint: .trailing,
                                    ),
                                )
                                .frame(
                                    width: geometry.size.width
                                        * min(self.goal.progressPercentage, 1.0),
                                    height: 12
                                )
                                .animation(
                                    .easeInOut(duration: 0.5), value: self.goal.progressPercentage
                                )
                        }
                    }
                    .frame(height: 12)
                }

                // Details Row
                if !self.goal.isCompleted {
                    HStack {
                        if let daysRemaining = goal.daysRemaining {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                    .foregroundColor(daysRemaining <= 30 ? .red : .secondary)

                                Text("\(daysRemaining) days left")
                                    .font(.caption)
                                    .foregroundColor(daysRemaining <= 30 ? .red : .secondary)
                            }
                        }

                        Spacer()

                        if let notes = goal.notes, !notes.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "note.text")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text("Has notes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(self.backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1),
            )
        }
    }
}
