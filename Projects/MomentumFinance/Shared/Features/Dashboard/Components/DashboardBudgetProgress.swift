//
// DashboardBudgetProgress.swift
// MomentumFinance
//
// Created by Dashboard Refactoring on 8/19/25.
//

import SwiftData
import SwiftUI

struct DashboardBudgetProgress: View {
    let budgets: [Budget]
    let onBudgetTapped: (Budget) -> Void
    let onViewAllTapped: () -> Void
    let onCreateTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budget Progress")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                if !budgets.isEmpty {
                    ForEach(budgets.prefix(3).indices, id: \.self) { index in
                        let budget = budgets[index]
                        BudgetProgressRow(budget: budget) {
                            onBudgetTapped(budget)
                        }

                        if index < min(2, budgets.count - 1) {
                            Divider()
                                .background(Color.secondary.opacity(0.3))
                        }
                    }

                    // View all budgets button
                    if budgets.count > 3 {
                        Button(action: onViewAllTapped) {
                            Text("View All \(budgets.count) Budgets")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No budgets set")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Button(action: onCreateTapped) {
                            Text("Create Budget")
                                .padding(.vertical, 4)
                                .frame(maxWidth: 180)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
            .padding()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct BudgetProgressRow: View {
    let budget: Budget
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(categoryColor)
                        .frame(width: 32, height: 32)

                    Image(systemName: categoryIcon)
                        .font(.caption)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text("\(budget.formattedSpentAmount) / \(budget.formattedLimitAmount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(budget.progressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(progressColor(for: budget.progressPercentage * 100))
            }

            // Progress bar
            ProgressView(value: min(budget.progressPercentage, 1.0))
                .progressViewStyle(LinearProgressViewStyle())
                .tint(progressColor(for: budget.progressPercentage * 100))
                .scaleEffect(x: 1, y: 0.8)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var categoryColor: Color {
        // Use a color based on the budget name for consistency
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        let index = abs(budget.name.hashValue) % colors.count
        return colors[index]
    }

    private var categoryIcon: String {
        // Use a default icon or derive from category
        budget.category?.iconName ?? "chart.bar.fill"
    }

    private func progressColor(for percentage: Double) -> Color {
        switch percentage {
        case 0 ..< 70:
            .green
        case 70 ..< 90:
            .orange
        default:
            .red
        }
    }
}

#Preview {
    // Note: Budget is a SwiftData model, so we'll create simple mock budgets for preview
    // In a real app, these would come from the SwiftData context
    let mockBudget1 = Budget(name: "Groceries", limitAmount: 500, month: Date())
    let mockBudget2 = Budget(name: "Entertainment", limitAmount: 200, month: Date())
    let mockBudget3 = Budget(name: "Transport", limitAmount: 300, month: Date())

    // Simulate some spending for preview purposes
    // Note: In real usage, spentAmount is calculated from the category's transactions

    DashboardBudgetProgress(
        budgets: [mockBudget1, mockBudget2, mockBudget3],
        onBudgetTapped: { _ in },
        onViewAllTapped: {},
        onCreateTapped: {}
    )
    .padding()
}
