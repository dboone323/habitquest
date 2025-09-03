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
<<<<<<< HEAD
        @Query private var savingsGoals: [SavingsGoal]
        @Query private var transactions: [FinancialTransaction]
        @Query private var budgets: [Budget]
        @Query private var categories: [ExpenseCategory]
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)

        @State private var selectedTab = 0
        @State private var showingAddGoal = false
        @State private var selectedGoal: SavingsGoal?

        // Search functionality
        @State private var showingSearch = false
<<<<<<< HEAD
        @State private var navigationCoordinator = NavigationCoordinator.shared
=======
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
>>>>>>> 1cf3938 (Create working state for recovery)

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Enhanced Header Section
                    HeaderSection(
                        selectedTab: $selectedTab,
                        showingAddGoal: $showingAddGoal,
<<<<<<< HEAD
                        )
=======
                    )
>>>>>>> 1cf3938 (Create working state for recovery)

                    // Content with Animation
                    TabView(selection: $selectedTab) {
                        SavingsGoalsTab(
                            goals: savingsGoals,
                            showingAddGoal: $showingAddGoal,
                            selectedGoal: $selectedGoal,
<<<<<<< HEAD
                            )
=======
                        )
>>>>>>> 1cf3938 (Create working state for recovery)
                        .tag(0)

                        ReportsTab(
                            transactions: transactions,
                            budgets: budgets,
                            categories: categories,
<<<<<<< HEAD
                            )
                        .tag(1)
                    }
                    #if canImport(UIKit)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
=======
                        )
                        .tag(1)
                    }
                    #if canImport(UIKit)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
>>>>>>> 1cf3938 (Create working state for recovery)
                    #endif
                }
                .navigationTitle("Goals & Reports")
                #if canImport(UIKit)
<<<<<<< HEAD
                .navigationBarHidden(true)
=======
                    .navigationBarHidden(true)
>>>>>>> 1cf3938 (Create working state for recovery)
                #endif
                .toolbar {
                    ToolbarItem(placement: .automatic) {
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
                                    .font(.system(size: 18, weight: .semibold))
                            }

                            // Add Goal Button
                            Button {
                                showingAddGoal = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddGoal) {
                    AddSavingsGoalView()
                }
                .sheet(isPresented: $showingSearch) {
                    Features.GlobalSearchView()
                }
                .sheet(item: $selectedGoal) { goal in
                    SavingsGoalDetailView(goal: goal)
                }
                .onAppear {
                    viewModel.setModelContext(modelContext)
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

            private var secondaryBackgroundColor: Color {
                #if canImport(UIKit)
<<<<<<< HEAD
                return Color(UIColor.systemGroupedBackground)
                #elseif canImport(AppKit)
                return Color(NSColor.controlBackgroundColor)
                #else
                return Color.gray.opacity(0.1)
=======
                    return Color(UIColor.systemGroupedBackground)
                #elseif canImport(AppKit)
                    return Color(NSColor.controlBackgroundColor)
                #else
                    return Color.gray.opacity(0.1)
>>>>>>> 1cf3938 (Create working state for recovery)
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

                        if selectedTab == 0 {
                            Button(
                                action: { showingAddGoal = true },
                                label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                },
<<<<<<< HEAD
                                )
=======
                            )
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                    }

                    // Enhanced Tab Picker
                    HStack(spacing: 0) {
                        ForEach(["Goals", "Reports"], id: \.self) { tab in
                            let index = tab == "Goals" ? 0 : 1
                            let isSelected = selectedTab == index

                            Button(
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedTab = index
                                    }
                                },
                                label: {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
<<<<<<< HEAD
                                            Image(systemName: index == 0 ? "target" : "chart.bar.fill")
                                                .font(.title3)
=======
                                            Image(
                                                systemName: index == 0 ? "target" : "chart.bar.fill"
                                            )
                                            .font(.title3)
>>>>>>> 1cf3938 (Create working state for recovery)

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
<<<<<<< HEAD
                                                isSelected ?
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing,
                                                        ) :
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.clear]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing,
                                                        ),
                                                ),
                                        )
                                },
                                )
=======
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
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(secondaryBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1),
<<<<<<< HEAD
                            )
=======
                        )
>>>>>>> 1cf3938 (Create working state for recovery)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor, secondaryBackgroundColor]),
                        startPoint: .top,
                        endPoint: .bottom,
<<<<<<< HEAD
                        ),
                    )
=======
                    ),
                )
>>>>>>> 1cf3938 (Create working state for recovery)
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
                    if goals.isEmpty {
                        Text("No savings goals yet")
                            .foregroundColor(.secondary)
                        Button("Add Goal") {
                            showingAddGoal = true
                        }
                        .padding()
                    } else {
                        ForEach(goals, id: \.id) { goal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(goal.name)
                                        .font(.headline)
<<<<<<< HEAD
                                    Text("$\(goal.currentAmount, specifier: "%.2f") / $\(goal.targetAmount, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
=======
                                    Text(
                                        "$\(goal.currentAmount, specifier: "%.2f") / $\(goal.targetAmount, specifier: "%.2f")"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
>>>>>>> 1cf3938 (Create working state for recovery)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedGoal = goal
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
                    transactions: transactions,
                    budgets: budgets,
                    categories: categories,
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Features.GoalsAndReports.GoalsAndReportsView()
<<<<<<< HEAD
        .modelContainer(for: [SavingsGoal.self, FinancialTransaction.self, Budget.self, ExpenseCategory.self])
=======
        .modelContainer(for: [
            SavingsGoal.self, FinancialTransaction.self, Budget.self, ExpenseCategory.self,
        ])
>>>>>>> 1cf3938 (Create working state for recovery)
}
