// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import SwiftData
import SwiftUI

extension Features.GoalsAndReports {
    // Helper views extracted from GoalsAndReportsView for better code organization and reduced type body length
    struct GoalHeaderView: View {
        let title: String
        let subtitle: String
        @Binding var selectedTab: Int
        @Binding var showingAddGoal: Bool

        var body: some View {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(subtitle)
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
        }
    }

    struct EmptyGoalsView: View {
        @Binding var showingAddGoal: Bool

        var body: some View {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "star.circle")
                    .font(.system(size: 64))
                    .foregroundColor(.blue.opacity(0.6))

                VStack(spacing: 8) {
                    Text("No Savings Goals Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Create savings goals to track your progress toward financial milestones")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button(
                    action: { showingAddGoal = true },
                    label: {
                        Label("Create Your First Goal", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                    },
<<<<<<< HEAD
                    )
=======
                )
>>>>>>> 1cf3938 (Create working state for recovery)

                Spacer()
            }
        }
    }

    struct EmptyReportsView: View {
        var body: some View {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 64))
                    .foregroundColor(.blue.opacity(0.6))

                VStack(spacing: 8) {
                    Text("No Reports Available")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Reports will appear here once you have more transaction data")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()
            }
        }
    }

    struct TabSelectionView: View {
        @Binding var selectedTab: Int

        var body: some View {
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
                                    Image(systemName: index == 0 ? "star.fill" : "chart.pie.fill")
                                        .font(.system(size: 16))

                                    Text(tab)
                                        .font(.headline)
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
                                        isSelected ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                startPoint: .leading,
                                                endPoint: .trailing,
<<<<<<< HEAD
                                                ) :
=======
                                            ) :
>>>>>>> 1cf3938 (Create working state for recovery)
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.clear]),
                                                startPoint: .leading,
                                                endPoint: .trailing,
<<<<<<< HEAD
                                                ),
                                        ),
                                )
                        },
                        )
=======
                                            ),
                                    ),
                            )
                        },
                    )
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemFill)),
<<<<<<< HEAD
                )
=======
            )
>>>>>>> 1cf3938 (Create working state for recovery)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
