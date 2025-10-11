import AppKit
import SwiftUI

#if canImport(AppKit)
#endif

// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

public struct AddSavingsGoalView: View {
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
        !self.name.isEmpty && !self.targetAmountString.isEmpty
            && Double(self.targetAmountString) != nil
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Name", text: self.$name).accessibilityLabel("Text Field").accessibilityLabel("Text Field")

                    TextField("Target Amount", text: self.$targetAmountString).accessibilityLabel("Text Field").accessibilityLabel(
                        "Text Field"
                    )
                    #if canImport(UIKit)
                    .keyboardType(.decimalPad)
                    #endif

                    Toggle("Set Target Date", isOn: self.$hasTargetDate)

                    if self.hasTargetDate {
                        DatePicker(
                            "Target Date",
                            selection: Binding(
                                get: { self.targetDate ?? Date() },
                                set: { self.targetDate = $0 },
                            ),
                            displayedComponents: .date,
                        )
                    }
                }

                Section(header: Text("Notes (Optional)")) {
                    TextField("Add notes about this goal...", text: self.$notes, axis: .vertical).accessibilityLabel("Text Field")
                        .accessibilityLabel("Text Field")
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("Add Savings Goal")
            #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar(content: {
                    ToolbarItem(
                        placement: {
                            #if canImport(UIKit)
                            return .navigationBarLeading
                            #else
                            return .cancellationAction
                            #endif
                        }()
                    ) {
                        Button("Cancel") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Cancel")
                    }

                    ToolbarItem(
                        placement: {
                            #if canImport(UIKit)
                            return .navigationBarTrailing
                            #else
                            return .primaryAction
                            #endif
                        }()
                    ) {
                        Button("Save") {
                            self.saveSavingsGoal()
                        }
                        .disabled(!self.isFormValid)
                        .accessibilityLabel("Save")
                    }
                })
        }
    }

    private func saveSavingsGoal() {
        guard let targetAmount = Double(targetAmountString) else { return }

        let goal = SavingsGoal(
            name: name,
            targetAmount: targetAmount,
            targetDate: hasTargetDate ? self.targetDate : nil,
            notes: self.notes.isEmpty ? nil : self.notes,
        )

        self.modelContext.insert(goal)

        try? self.modelContext.save()
        self.dismiss()
    }
}

public struct SavingsGoalDetailView: View {
    let goal: SavingsGoal
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var showingAddFunds = false
    @State private var amountToAdd = ""

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Goal Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(
                                systemName: self.goal.isCompleted
                                    ? "checkmark.circle.fill" : "target"
                            )
                            .font(.largeTitle)
                            .foregroundColor(self.goal.isCompleted ? .green : .blue)
                        }

                    Text(self.goal.name)
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
                        .trim(from: 0, to: self.goal.progressPercentage)
                        .stroke(
                            self.goal.isCompleted ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round),
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: self.goal.progressPercentage)

                    VStack {
                        Text("\(Int(self.goal.progressPercentage * 100))%")
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
                        Text(self.goal.formattedCurrentAmount)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Target Amount")
                        Spacer()
                        Text(self.goal.formattedTargetAmount)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Remaining")
                        Spacer()
                        Text(self.goal.formattedRemainingAmount)
                            .fontWeight(.semibold)
                            .foregroundColor(self.goal.isCompleted ? .green : .blue)
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
                if !self.goal.isCompleted {
                    VStack(spacing: 12) {
                        Button(
                            action: {
                                self.showingAddFunds = true
                            },
                            label: {
                                Text("Add Funds")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        )

                        HStack(spacing: 12) {
                            Button(
                                action: {
                                    self.goal.addFunds(25)
                                    try? self.modelContext.save()
                                },
                                label: {
                                    Text("+$25")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            )

                            Button(
                                action: {
                                    self.goal.addFunds(50)
                                    try? self.modelContext.save()
                                },
                                label: {
                                    Text("+$50")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            )

                            Button(
                                action: {
                                    self.goal.addFunds(100)
                                    try? self.modelContext.save()
                                },
                                label: {
                                    Text("+$100")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            )
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Savings Goal")
            #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar(content: {
                    ToolbarItem(
                        placement: {
                            #if canImport(UIKit)
                            return .navigationBarTrailing
                            #else
                            return .primaryAction
                            #endif
                        }()
                    ) {
                        Button("Done") {
                            self.dismiss()
                        }
                        .accessibilityLabel("Done")
                    }
                })
                .alert("Add Funds", isPresented: self.$showingAddFunds) {
                    TextField("Amount", text: self.$amountToAdd)
                        .accessibilityLabel("Amount")
                    #if canImport(UIKit)
                        .keyboardType(.decimalPad)
                    #endif
                    Button("Cancel", role: .cancel) {
                        self.amountToAdd = ""
                    }
                    .accessibilityLabel("Cancel")
                    Button("Add") {
                        if let amount = Double(amountToAdd) {
                            self.goal.addFunds(amount)
                            try? self.modelContext.save()
                        }
                        self.amountToAdd = ""
                    }
                    .accessibilityLabel("Add Funds")
                } message: {
                    Text("Enter the amount you want to add to this savings goal.")
                }
        }
    }
}
