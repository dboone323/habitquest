//
//  GoalsAndReportsView.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/2/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

extension Features.GoalsAndReports {
    /// Main view for goals and financial reports
    struct GoalsAndReportsView: View {
        @State private var viewModel = GoalsAndReportsViewModel()
        @Environment(\.modelContext)
        private var modelContext
        #if canImport(SwiftData)
        #if canImport(SwiftData)
        private var savingsGoals: [SavingsGoal] = []
        private var transactions: [FinancialTransaction] = []
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #else
        private var savingsGoals: [SavingsGoal] = []
        private var transactions: [FinancialTransaction] = []
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #endif
        #else
        private var savingsGoals: [SavingsGoal] = []
        private var transactions: [FinancialTransaction] = []
        private var budgets: [Budget] = []
        private var categories: [ExpenseCategory] = []
        #endif

        @State private var selectedTab = 0
        @State private var showingAddGoal = false
        @State private var selectedGoal: SavingsGoal?

        // Search functionality
        @State private var showingSearch = false
        @EnvironmentObject private var navigationCoordinator: NavigationCoordinator

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Enhanced Header Section
                    HeaderSection(
                        selectedTab: self.$selectedTab,
                        showingAddGoal: self.$showingAddGoal,
                    )

                    // Content with Animation
                    TabView(selection: self.$selectedTab) {
                        SavingsGoalsTab(
                            goals: self.savingsGoals,
                            showingAddGoal: self.$showingAddGoal,
                            selectedGoal: self.$selectedGoal,
                        )
                        .tag(0)

                        ReportsTab(
                            transactions: self.transactions,
                            budgets: self.budgets,
                            categories: self.categories,
                        )
                        .tag(1)
                    }
                    #if canImport(UIKit)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    #endif
                }
                .navigationTitle("Goals & Reports")
                #if canImport(UIKit)
                    .navigationBarHidden(true)
                #endif
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            HStack(spacing: 12) {
                                // Search Button
                                Button {
                                    self.showingSearch = true
                                    NavigationCoordinator.shared.activateSearch()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18, weight: .semibold))
                                }

                                // Add Goal Button
                                Button {
                                    self.showingAddGoal = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                        }
                    }
                    .sheet(isPresented: self.$showingAddGoal) {
                        AddSavingsGoalView()
                    }
                    .sheet(isPresented: self.$showingSearch) {
                        Features.GlobalSearch.GlobalSearchView()
                    }
                    .sheet(item: self.$selectedGoal) { goal in
                        SavingsGoalDetailView(goal: goal)
                    }
                    .onAppear {
                        self.viewModel.setModelContext(self.modelContext)
                    }
            }
        }

        // MARK: - Header Section

        private struct HeaderSection: View {
            @Binding var selectedTab: Int
            @Binding var showingAddGoal: Bool

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

            private var secondaryBackgroundColor: Color {
                #if canImport(UIKit)
                return Color(UIColor.systemGroupedBackground)
                #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
                #else
                return Color.gray.opacity(0.1)
                #endif
            }

            var body: some View {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Goals & Reports")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("Track progress and analyze finances")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if self.selectedTab == 0 {
                            Button(
                                action: { self.showingAddGoal = true },
                                label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                },
                            )
                        }
                    }

                    // Enhanced Tab Picker
                    HStack(spacing: 0) {
                        ForEach(["Goals", "Reports"], id: \.self) { tab in
                            let index = tab == "Goals" ? 0 : 1
                            let isSelected = self.selectedTab == index

                            Button(
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.selectedTab = index
                                    }
                                },
                                label: {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
                                            Image(
                                                systemName: index == 0 ? "target" : "chart.bar.fill"
                                            )
                                            .font(.title3)

                                            Text(tab)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(isSelected ? .white : .primary)

                                        Rectangle()
                                            .frame(height: 3)
                                            .foregroundColor(isSelected ? .clear : .clear)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                isSelected
                                                    ? LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            .blue, .blue.opacity(0.8),
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing,
                                                    )
                                                    : LinearGradient(
                                                        gradient: Gradient(colors: [Color.clear]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing,
                                                    ),
                                            ),
                                    )
                                },
                            )
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(self.secondaryBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1),
                        )
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            self.backgroundColor, self.secondaryBackgroundColor,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom,
                    ),
                )
            }
        }

        // MARK: - Tab Views

        private struct SavingsGoalsTab: View {
            let goals: [SavingsGoal]
            @Binding var showingAddGoal: Bool
            @Binding var selectedGoal: SavingsGoal?

            var body: some View {
                // MARK: - Savings Goals Section (Enhanced version to be implemented)

                VStack {
                    Text("Savings Goals")
                        .font(.headline)
                    if self.goals.isEmpty {
                        Text("No savings goals yet")
                            .foregroundColor(.secondary)
                        Button("Add Goal") {
                            self.showingAddGoal = true
                        }
                        .accessibilityLabel("Add Goal Button")
                        .padding()
                    } else {
                        ForEach(self.goals, id: \.id) { goal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(goal.name)
                                        .font(.headline)
                                    Text(
                                        "$\(goal.currentAmount, specifier: "%.2f") / $\(goal.targetAmount, specifier: "%.2f")"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                self.selectedGoal = goal
                            }
                        }
                    }
                }
                .padding()
            }
        }

        private struct ReportsTab: View {
            let transactions: [FinancialTransaction]
            let budgets: [Budget]
            let categories: [ExpenseCategory]

            var body: some View {
                Features.GoalsAndReports.EnhancedReportsSection(
                    transactions: self.transactions,
                    budgets: self.budgets,
                    categories: self.categories,
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Features.GoalsAndReports.GoalsAndReportsView()
        .modelContainer(for: [
            SavingsGoal.self, FinancialTransaction.self, Budget.self, ExpenseCategory.self,
        ])
}
