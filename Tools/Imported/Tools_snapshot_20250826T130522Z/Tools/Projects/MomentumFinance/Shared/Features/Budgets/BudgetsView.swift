//
//  BudgetsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftData
import SwiftUI

#if canImport(UIKit)
<<<<<<< HEAD
import UIKit
=======
    import UIKit
>>>>>>> 1cf3938 (Create working state for recovery)
#endif

extension Features.Budgets {
    struct BudgetsView: View {
        @Environment(\.modelContext)
        private var modelContext
        @State private var viewModel = BudgetsViewModel()
<<<<<<< HEAD
        @Query private var budgets: [Budget]
        @Query private var categories: [Category]
        @State private var showingAddBudget = false
        @State private var selectedTimeframe: TimeFrame = .thisMonth

        // Search functionality
        @State private var showingSearch = false
        @State private var navigationCoordinator = NavigationCoordinator.shared
=======
        #if canImport(SwiftData)
            #if canImport(SwiftData)
                private var budgets: [Budget] = []
                private var categories: [Category] = []
            #else
                private var budgets: [Budget] = []
                private var categories: [Category] = []
            #endif
        #else
            private var budgets: [Budget] = []
            private var categories: [Category] = []
        #endif
        @State private var showingAddBudget = false
        @State private var selectedTimeframe: TimeFrame = .thisMonth

    // Search functionality
    @State private var showingSearch = false
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
>>>>>>> 1cf3938 (Create working state for recovery)

        private enum TimeFrame: String, CaseIterable {
            case thisMonth = "This Month"
            case lastMonth = "Last Month"
            case thisYear = "This Year"
        }

        var body: some View {
            NavigationView {
                ZStack {
                    backgroundColorForPlatform()
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        if budgets.isEmpty {
                            emptyStateView
                        } else {
                            budgetContentView
                        }
                    }
                }
                .navigationTitle("Budgets")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 12) {
                            // Search Button
                            Button {
                                showingSearch = true
<<<<<<< HEAD
                                navigationCoordinator.activateSearch()
=======
                                NavigationCoordinator.shared.activateSearch()
>>>>>>> 1cf3938 (Create working state for recovery)
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }

                            // Add Budget Button
<<<<<<< HEAD
                            Button(action: { showingAddBudget = true }, label: {
                                Image(systemName: "plus")
                            })
=======
                            Button(
                                action: { showingAddBudget = true },
                                label: {
                                    Image(systemName: "plus")
                                })
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                    }
                }
                .sheet(isPresented: $showingAddBudget) {
                    AddBudgetView(categories: categories)
                }
                .sheet(isPresented: $showingSearch) {
                    Features.GlobalSearchView()
                }
            }
        }

        private var emptyStateView: some View {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "chart.pie")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary.opacity(0.6))

                VStack(spacing: 12) {
                    Text("No Budgets Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Create budgets to track your spending and stay on target")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

<<<<<<< HEAD
                Button(action: { showingAddBudget = true }, label: {
                    Label("Create Your First Budget", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                })
=======
                Button(
                    action: { showingAddBudget = true },
                    label: {
                        Label("Create Your First Budget", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                )
>>>>>>> 1cf3938 (Create working state for recovery)
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 20)
        }

        private var budgetContentView: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    summarySection
                    budgetListSection
                }
                .padding()
            }
        }

        private var summarySection: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("Budget Overview")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    timeframePicker
                }

                BudgetSummaryCard(budgets: filteredBudgets)
            }
        }

        private var timeframePicker: some View {
            Menu {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Button(timeframe.rawValue) {
                        selectedTimeframe = timeframe
                    }
                }
            } label: {
                HStack {
                    Text(selectedTimeframe.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }

        private var budgetListSection: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("All Budgets")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

<<<<<<< HEAD
                    Button(action: { showingAddBudget = true }, label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    })
=======
                    Button(
                        action: { showingAddBudget = true },
                        label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        })
>>>>>>> 1cf3938 (Create working state for recovery)
                }

                LazyVStack(spacing: 12) {
                    ForEach(filteredBudgets, id: \.name) { budget in
                        BudgetRowView(budget: budget)
                    }
                }
            }
        }

        private var filteredBudgets: [Budget] {
            // Simple filtering - in a real app you'd filter by the selected timeframe
            budgets
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
<<<<<<< HEAD
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
=======
                return Color(uiColor: .systemGroupedBackground)
            #else
                return Color(nsColor: .controlBackgroundColor)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

    // MARK: - Supporting Views

    struct BudgetSummaryCard: View {
        let budgets: [Budget]

        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Budget")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalBudget, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalSpent, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(spentColor)
                    }
                }

                ProgressView(value: spentPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: spentColor))

                HStack {
                    Text("\(Int(spentPercentage * 100))% spent")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\(remaining, specifier: "%.2f") remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColorForPlatform())
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        private var totalBudget: Double {
            budgets.reduce(0) { $0 + $1.limitAmount }
        }

        private var totalSpent: Double {
            budgets.reduce(0) { $0 + $1.spentAmount }
        }

        private var remaining: Double {
            totalBudget - totalSpent
        }

        private var spentPercentage: Double {
            guard totalBudget > 0 else { return 0 }
            return min(totalSpent / totalBudget, 1.0)
        }

        private var spentColor: Color {
            switch spentPercentage {
<<<<<<< HEAD
            case 0 ..< 0.5:
                .green
            case 0.5 ..< 0.8:
=======
            case 0..<0.5:
                .green
            case 0.5..<0.8:
>>>>>>> 1cf3938 (Create working state for recovery)
                .orange
            default:
                .red
            }
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
<<<<<<< HEAD
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
=======
                return Color(uiColor: .systemGroupedBackground)
            #else
                return Color(nsColor: .controlBackgroundColor)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

    struct BudgetRowView: View {
        let budget: Budget

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.name)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("Budget: $\(budget.limitAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(budget.spentAmount, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(spentColor)

                        Text("\(spentPercentage, specifier: "%.0f")% spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                ProgressView(value: spentPercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: spentColor))
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColorForPlatform())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
        }

        private var spentPercentage: Double {
            guard budget.limitAmount > 0 else { return 0 }
            return min((budget.spentAmount / budget.limitAmount) * 100, 100)
        }

        private var spentColor: Color {
            switch spentPercentage {
<<<<<<< HEAD
            case 0 ..< 50:
                .green
            case 50 ..< 80:
=======
            case 0..<50:
                .green
            case 50..<80:
>>>>>>> 1cf3938 (Create working state for recovery)
                .orange
            default:
                .red
            }
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
<<<<<<< HEAD
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
=======
                return Color(uiColor: .systemGroupedBackground)
            #else
                return Color(nsColor: .controlBackgroundColor)
>>>>>>> 1cf3938 (Create working state for recovery)
            #endif
        }
    }

    struct AddBudgetView: View {
        let categories: [Category]
        @Environment(\.dismiss)
        private var dismiss
        @State private var name = ""
        @State private var limitAmount = ""
        @State private var selectedCategory: Category?

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Budget Details")) {
                        TextField("Budget Name", text: $name)
                        TextField("Budget Amount", text: $limitAmount)
                            #if os(iOS)
<<<<<<< HEAD
                            .keyboardType(.decimalPad)
                        #endif
=======
                                .keyboardType(.decimalPad)
                            #endif
>>>>>>> 1cf3938 (Create working state for recovery)
                    }

                    if !categories.isEmpty {
                        Section(header: Text("Category")) {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select Category").tag(nil as Category?)
                                ForEach(categories, id: \.name) { category in
                                    Text(category.name).tag(category as Category?)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("New Budget")
                #if os(iOS)
<<<<<<< HEAD
                .navigationBarTitleDisplayMode(.inline)
=======
                    .navigationBarTitleDisplayMode(.inline)
>>>>>>> 1cf3938 (Create working state for recovery)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            // Save budget logic would go here
                            dismiss()
                        }
                        .disabled(name.isEmpty || limitAmount.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    Features.Budgets.BudgetsView()
}
