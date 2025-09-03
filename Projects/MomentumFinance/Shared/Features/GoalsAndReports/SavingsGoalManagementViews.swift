<<<<<<< HEAD
import UIKit
import SwiftData
import SwiftUI
import UIKit

=======
import SwiftUI
import UIKit

#if canImport(AppKit)
    import AppKit
#endif

>>>>>>> 1cf3938 (Create working state for recovery)
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

#if canImport(UIKit)
#elseif canImport(AppKit)
#endif

struct AddSavingsGoalView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var name = ""
    @State private var targetAmountString = ""
    @State private var targetDate: Date?
    @State private var hasTargetDate = false
    @State private var notes = ""

    private var isFormValid: Bool {
        !name.isEmpty && !targetAmountString.isEmpty && Double(targetAmountString) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Name", text: $name)

                    TextField("Target Amount", text: $targetAmountString)
                        #if canImport(UIKit)
<<<<<<< HEAD
                        .keyboardType(.decimalPad)
                    #endif
=======
                            .keyboardType(.decimalPad)
                        #endif
>>>>>>> 1cf3938 (Create working state for recovery)

                    Toggle("Set Target Date", isOn: $hasTargetDate)

                    if hasTargetDate {
                        DatePicker(
                            "Target Date",
                            selection: Binding(
                                get: { targetDate ?? Date() },
                                set: { targetDate = $0 },
<<<<<<< HEAD
                                ),
                            displayedComponents: .date,
                            )
=======
                            ),
                            displayedComponents: .date,
                        )
>>>>>>> 1cf3938 (Create working state for recovery)
                    }
                }

                Section(header: Text("Notes (Optional)")) {
                    TextField("Add notes about this goal...", text: $notes, axis: .vertical)
<<<<<<< HEAD
                        .lineLimit(3 ... 6)
=======
                        .lineLimit(3...6)
>>>>>>> 1cf3938 (Create working state for recovery)
                }
            }
            .navigationTitle("Add Savings Goal")
            #if canImport(UIKit)
<<<<<<< HEAD
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: {
                    #if canImport(UIKit)
                    return .navigationBarLeading
                    #else
                    return .cancellationAction
                    #endif
                }()) {
=======
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(
                    placement: {
                        #if canImport(UIKit)
                            return .navigationBarLeading
                        #else
                            return .cancellationAction
                        #endif
                    }()
                ) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    Button("Cancel") {
                        dismiss()
                    }
                }

<<<<<<< HEAD
                ToolbarItem(placement: {
                    #if canImport(UIKit)
                    return .navigationBarTrailing
                    #else
                    return .primaryAction
                    #endif
                }()) {
=======
                ToolbarItem(
                    placement: {
                        #if canImport(UIKit)
                            return .navigationBarTrailing
                        #else
                            return .primaryAction
                        #endif
                    }()
                ) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    Button("Save") {
                        saveSavingsGoal()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private func saveSavingsGoal() {
        guard let targetAmount = Double(targetAmountString) else { return }

        let goal = SavingsGoal(
            name: name,
            targetAmount: targetAmount,
            targetDate: hasTargetDate ? targetDate : nil,
            notes: notes.isEmpty ? nil : notes,
<<<<<<< HEAD
            )
=======
        )
>>>>>>> 1cf3938 (Create working state for recovery)

        modelContext.insert(goal)

        try? modelContext.save()
        dismiss()
    }
}

struct SavingsGoalDetailView: View {
    let goal: SavingsGoal
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var showingAddFunds = false
    @State private var amountToAdd = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Goal Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "target")
                                .font(.largeTitle)
                                .foregroundColor(goal.isCompleted ? .green : .blue)
                        }

                    Text(goal.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }

                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: goal.progressPercentage)
                        .stroke(
                            goal.isCompleted ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round),
<<<<<<< HEAD
                            )
=======
                        )
>>>>>>> 1cf3938 (Create working state for recovery)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: goal.progressPercentage)

                    VStack {
                        Text("\(Int(goal.progressPercentage * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Goal Details
                VStack(spacing: 16) {
                    HStack {
                        Text("Current Amount")
                        Spacer()
                        Text(goal.formattedCurrentAmount)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Target Amount")
                        Spacer()
                        Text(goal.formattedTargetAmount)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text(goal.formattedRemainingAmount)
                            .fontWeight(.semibold)
                            .foregroundColor(goal.isCompleted ? .green : .blue)
                    }

                    if let targetDate = goal.targetDate {
                        HStack {
                            Text("Target Date")
                            Spacer()
                            Text(targetDate.formatted(date: .long, time: .omitted))
                                .foregroundColor(.secondary)
                        }

                        if let daysRemaining = goal.daysRemaining {
                            HStack {
                                Text("Days Remaining")
                                Spacer()
                                Text("\(daysRemaining)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(daysRemaining <= 30 ? .red : .secondary)
                            }
                        }
                    }

                    if let notes = goal.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                    }
                }
                .padding()

                // Action Buttons
                if !goal.isCompleted {
                    VStack(spacing: 12) {
<<<<<<< HEAD
                        Button(action: {
                            showingAddFunds = true
                        }, label: {
                            Text("Add Funds")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        })

                        HStack(spacing: 12) {
                            Button(action: {
                                goal.addFunds(25)
                                try? modelContext.save()
                            }, label: {
                                Text("+$25")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            })

                            Button(action: {
                                goal.addFunds(50)
                                try? modelContext.save()
                            }, label: {
                                Text("+$50")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            })

                            Button(action: {
                                goal.addFunds(100)
                                try? modelContext.save()
                            }, label: {
                                Text("+$100")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            })
=======
                        Button(
                            action: {
                                showingAddFunds = true
                            },
                            label: {
                                Text("Add Funds")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            })

                        HStack(spacing: 12) {
                            Button(
                                action: {
                                    goal.addFunds(25)
                                    try? modelContext.save()
                                },
                                label: {
                                    Text("+$25")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                })

                            Button(
                                action: {
                                    goal.addFunds(50)
                                    try? modelContext.save()
                                },
                                label: {
                                    Text("+$50")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                })

                            Button(
                                action: {
                                    goal.addFunds(100)
                                    try? modelContext.save()
                                },
                                label: {
                                    Text("+$100")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                })
>>>>>>> 1cf3938 (Create working state for recovery)
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Savings Goal")
            #if canImport(UIKit)
<<<<<<< HEAD
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: {
                    #if canImport(UIKit)
                    return .navigationBarTrailing
                    #else
                    return .primaryAction
                    #endif
                }()) {
=======
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(
                    placement: {
                        #if canImport(UIKit)
                            return .navigationBarTrailing
                        #else
                            return .primaryAction
                        #endif
                    }()
                ) {
>>>>>>> 1cf3938 (Create working state for recovery)
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Add Funds", isPresented: $showingAddFunds) {
                TextField("Amount", text: $amountToAdd)
                    #if canImport(UIKit)
<<<<<<< HEAD
                    .keyboardType(.decimalPad)
                #endif
=======
                        .keyboardType(.decimalPad)
                    #endif
>>>>>>> 1cf3938 (Create working state for recovery)
                Button("Cancel", role: .cancel) {
                    amountToAdd = ""
                }
                Button("Add") {
                    if let amount = Double(amountToAdd) {
                        goal.addFunds(amount)
                        try? modelContext.save()
                    }
                    amountToAdd = ""
                }
            } message: {
                Text("Enter the amount you want to add to this savings goal.")
            }
        }
    }
}
