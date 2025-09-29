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
import UIKit
#endif

extension Features.Budgets {
    struct BudgetsView: View {
        @Environment(\.modelContext)
        private var modelContext
        @State private var viewModel = BudgetsViewModel()
        #if canImport(SwiftData)
        #if canImport(SwiftData)
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #else
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #endif
        #else
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #endif
        @State private var showingAddBudget = false
        @State private var selectedTimeframe: TimeFrame = .thisMonth

        // Search functionality
        @State private var showingSearch = false
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        private enum TimeFrame: String, CaseIterable {
            case thisMonth = "This Month"
            case lastMonth = "Last Month"
            case thisYear = "This Year"
        }

        var body: some View {
            NavigationView {
                ZStack {
                    self.backgroundColorForPlatform()
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        if self.budgets.isEmpty {
                            self.emptyStateView
                        } else {
                            self.budgetContentView
                        }
                    }
                }
                .navigationTitle("Budgets")
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 12) {
                            Button {
                                self.showingSearch = true
                                NavigationCoordinator.shared.activateSearch()
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            .accessibilityLabel("Search Budgets")

                            Button(action: { self.showingAddBudget = true }) {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Add Budget")
                        }
                    }
                })
                .sheet(isPresented: self.$showingAddBudget) {
                    AddBudgetView(categories: self.categories)
                }
                .sheet(isPresented: self.$showingSearch) {
                    BudgetSearchView(budgets: self.budgets)
                }
                .onAppear {
                    // Schedule budget notifications when view appears
                    self.viewModel.scheduleBudgetNotifications(for: self.budgets)
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

                Button(
                    action: { self.showingAddBudget = true },
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
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 20)
        }

        private var budgetContentView: some View {
            ScrollView {
                LazyVStack(spacing: 16) {
                    self.summarySection
                    self.budgetListSection
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

                    self.timeframePicker
                }

                BudgetSummaryCard(budgets: self.filteredBudgets)
            }
        }

        private var timeframePicker: some View {
            Menu {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Button(timeframe.rawValue) { self.selectedTimeframe = timeframe }
                        .accessibilityLabel(timeframe.rawValue)
                }
            } label: {
                HStack {
                    Text(self.selectedTimeframe.rawValue)
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

                    Button(
                        action: { self.showingAddBudget = true },
                        label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    )
                }

                LazyVStack(spacing: 12) {
                    ForEach(self.filteredBudgets, id: \.name) { budget in
                        BudgetRowView(budget: budget)
                    }
                }
            }
        }

        private var filteredBudgets: [Budget] {
            // Simple filtering - in a real app you'd filter by the selected timeframe
            self.budgets
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
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
                        Text("$\(self.totalBudget, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(self.totalSpent, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(self.spentColor)
                    }
                }

                ProgressView(value: self.spentPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: self.spentColor))

                HStack {
                    Text("\(Int(self.spentPercentage * 100))% spent")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\(self.remaining, specifier: "%.2f") remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(self.backgroundColorForPlatform())
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2),
            )
        }

        private var totalBudget: Double {
            self.budgets.reduce(0) { $0 + $1.limitAmount }
        }

        private var totalSpent: Double {
            self.budgets.reduce(0) { $0 + $1.spentAmount }
        }

        private var remaining: Double {
            self.totalBudget - self.totalSpent
        }

        private var spentPercentage: Double {
            guard self.totalBudget > 0 else { return 0 }
            return min(self.totalSpent / self.totalBudget, 1.0)
        }

        private var spentColor: Color {
            switch self.spentPercentage {
            case 0 ..< 0.5:
                .green
            case 0.5 ..< 0.8:
                .orange
            default:
                .red
            }
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
            #endif
        }
    }

    struct BudgetRowView: View {
        let budget: Budget

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(self.budget.name)
                                .font(.headline)
                                .fontWeight(.semibold)

                            if self.budget.rolloverEnabled {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .accessibilityLabel("Rollover Enabled")
                            }
                        }

                        Text("Budget: $\(self.budget.effectiveLimit, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if self.budget.rolledOverAmount > 0 {
                            Text("Rolled over: $\(self.budget.rolledOverAmount, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(self.budget.spentAmount, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(self.spentColor)

                        Text("\(self.spentPercentage, specifier: "%.0f")% spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                ProgressView(value: self.spentPercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: self.spentColor))
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(self.backgroundColorForPlatform())
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1),
            )
        }

        private var spentPercentage: Double {
            guard self.budget.limitAmount > 0 else { return 0 }
            return min((self.budget.spentAmount / self.budget.limitAmount) * 100, 100)
        }

        private var spentColor: Color {
            switch self.spentPercentage {
            case 0 ..< 50:
                .green
            case 50 ..< 80:
                .orange
            default:
                .red
            }
        }

        private func backgroundColorForPlatform() -> Color {
            #if os(iOS)
            return Color(uiColor: .systemGroupedBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
            #endif
        }
    }

    struct AddBudgetView: View {
        let categories: [ExpenseCategory]
        @Environment(\.dismiss)
        private var dismiss
        @State private var name = ""
        @State private var limitAmount = ""
        @State private var selectedCategory: ExpenseCategory?
        @State private var rolloverEnabled = false
        @State private var maxRolloverPercentage = 1.0

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Budget Details")) {
                        TextField("Budget Name", text: self.$name).accessibilityLabel("Text Field")
                            .accessibilityLabel("Text Field")
                        TextField("Budget Amount", text: self.$limitAmount).accessibilityLabel(
                            "Text Field"
                        ).accessibilityLabel(
                            "Text Field"
                        )
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    }

                    if !self.categories.isEmpty {
                        Section(header: Text("Category")) {
                            Picker("Category", selection: self.$selectedCategory) {
                                Text("Select Category").tag(nil as ExpenseCategory?)
                                ForEach(self.categories, id: \.name) { category in
                                    Text(category.name).tag(category as ExpenseCategory?)
                                }
                            }
                        }
                    }

                    Section(header: Text("Rollover Settings")) {
                        Toggle("Enable Rollover", isOn: self.$rolloverEnabled)
                            .accessibilityLabel("Enable Rollover")

                        if self.rolloverEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Max Rollover Percentage: \(Int(self.maxRolloverPercentage * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Slider(value: self.$maxRolloverPercentage, in: 0.1 ... 1.0, step: 0.1)
                                    .accessibilityLabel("Max Rollover Percentage")

                                Text(
                                    "Allows carrying over up to \(Int(self.maxRolloverPercentage * 100))% of unused budget to the next period."
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .navigationTitle("New Budget")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .toolbar(content: {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { self.dismiss() }
                                .accessibilityLabel("Cancel")
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                self.saveBudget()
                                self.dismiss()
                            }
                            .accessibilityLabel("Save Budget")
                            .disabled(self.name.isEmpty || self.limitAmount.isEmpty || self.selectedCategory == nil)
                        }
                    })
            }
        }

        private func saveBudget() {
            guard let category = selectedCategory,
                  let limit = Double(limitAmount) else { return }

            let calendar = Calendar.current
            let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!

            let budget = Budget(name: name, limitAmount: limit, month: currentMonth)
            budget.category = category
            budget.rolloverEnabled = self.rolloverEnabled
            budget.maxRolloverPercentage = self.maxRolloverPercentage

            // Note: In a real implementation, you'd inject the modelContext
            // For now, this is just the UI structure
        }
    }
}

public struct BudgetSearchView: View {
    let budgets: [Budget]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredBudgets: [Budget] {
        if self.searchText.isEmpty {
            self.budgets
        } else {
            self.budgets.filter { budget in
                budget.name.localizedCaseInsensitiveContains(self.searchText)
                    || budget.category?.name.localizedCaseInsensitiveContains(self.searchText)
                    ?? false
            }
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                if self.filteredBudgets.isEmpty {
                    Text("No budgets found")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(self.filteredBudgets, id: \.name) { budget in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(budget.name)
                                .font(.headline)
                            if let categoryName = budget.category?.name {
                                Text("Category: \(categoryName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text(
                                "Budget: $\(budget.limitAmount, specifier: "%.2f") • Spent: $\(budget.spentAmount, specifier: "%.2f")"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Search Budgets")
            #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .searchable(text: self.$searchText, prompt: "Search budgets...")
                .toolbar(content: {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { self.dismiss() }
                            .accessibilityLabel("Done")
                    }
                })
        }
    }
}
