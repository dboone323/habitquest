//
//  ReusableListItemView.swift
//  MomentumFinance
//
//  Created by Quantum Workspace
//  Copyright © 2024 Quantum Workspace. All rights reserved.
//

import SwiftUI

/// A reusable view component for displaying financial entities in lists with consistent NavigationLink behavior
struct ReusableListItemView<Entity: Identifiable & Hashable>: View {
    let entity: Entity
    let title: String
    let subtitle: String?
    let amount: Double?
    let date: Date?
    let iconName: String
    let iconColor: Color
    let listableType: ListableItem.ItemType
    let additionalContent: (() -> AnyView)?

    init(
        entity: Entity,
        title: String,
        subtitle: String? = nil,
        amount: Double? = nil,
        date: Date? = nil,
        iconName: String,
        iconColor: Color,
        listableType: ListableItem.ItemType,
        additionalContent: (() -> AnyView)? = nil
    ) {
        self.entity = entity
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.date = date
        self.iconName = iconName
        self.iconColor = iconColor
        self.listableType = listableType
        self.additionalContent = additionalContent
    }

    var body: some View {
        NavigationLink(value: ListableItem(id: entity.id, name: title, type: listableType)) {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let additionalContent = additionalContent {
                    additionalContent()
                } else {
                    // Default layout for amount and date
                    VStack(alignment: .trailing) {
                        if let amount = amount {
                            Text(amount.formatted(.currency(code: "USD")))
                                .font(.subheadline)
                                .foregroundStyle(amount < 0 ? .red : .green)
                        }

                        if let date = date {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .tag(ListableItem(id: entity.id, name: title, type: listableType))
    }
}

// MARK: - Convenience Extensions for Financial Entities

extension ReusableListItemView where Entity == FinancialAccount {
    init(account: FinancialAccount) {
        self.init(
            entity: account,
            title: account.name,
            subtitle: account.accountType.rawValue,
            amount: account.balance,
            date: nil,
            iconName: account.iconName.isEmpty ? (account.accountType == .checking ? "banknote" : "creditcard") : account.iconName,
            iconColor: account.accountType == .checking ? .green : (account.accountType == .savings ? .blue : (account.accountType == .credit ? .red : .purple)),
            listableType: .account
        )
    }
}

extension ReusableListItemView where Entity == FinancialTransaction {
    init(transaction: FinancialTransaction) {
        self.init(
            entity: transaction,
            title: transaction.title,
            subtitle: transaction.category?.name,
            amount: transaction.amount,
            date: transaction.date,
            iconName: transaction.amount < 0 ? "arrow.down" : "arrow.up",
            iconColor: transaction.amount < 0 ? .red : .green,
            listableType: .transaction
        )
    }
}

extension ReusableListItemView where Entity == Subscription {
    init(subscription: Subscription) {
        self.init(
            entity: subscription,
            title: subscription.name,
            subtitle: subscription.provider,
            amount: subscription.amount,
            date: subscription.nextPaymentDate,
            iconName: "calendar.badge.clock",
            iconColor: .purple,
            listableType: .subscription,
            additionalContent: {
                AnyView(
                    VStack(alignment: .trailing) {
                        Text(subscription.amount.formatted(.currency(code: subscription.currencyCode)))
                            .font(.subheadline)

                        Text(subscription.billingCycle.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                )
            }
        )
    }
}

extension ReusableListItemView where Entity == Budget {
    init(budget: Budget) {
        self.init(
            entity: budget,
            title: budget.name,
            subtitle: nil,
            amount: nil,
            date: nil,
            iconName: "chart.pie",
            iconColor: .orange,
            listableType: .budget,
            additionalContent: {
                AnyView(
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Spacer()
                            Text(
                                "\(budget.spent.formatted(.currency(code: "USD"))) of \(budget.amount.formatted(.currency(code: "USD")))"
                            )
                            .font(.subheadline)
                        }

                        ProgressView(value: budget.spent, total: budget.amount)
                            .tint(Self.getBudgetColor(spent: budget.spent, total: budget.amount))
                    }
                )
            }
        )
    }

    private static func getBudgetColor(spent: Double, total: Double) -> Color {
        let percentage = spent / total
        if percentage < 0.7 {
            return .green
        } else if percentage < 0.9 {
            return .yellow
        } else {
            return .red
        }
    }
}

extension ReusableListItemView where Entity == SavingsGoal {
    init(goal: SavingsGoal) {
        self.init(
            entity: goal,
            title: goal.name,
            subtitle: nil,
            amount: nil,
            date: goal.targetDate,
            iconName: "target",
            iconColor: .blue,
            listableType: .goal,
            additionalContent: {
                AnyView(
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Spacer()
                            Text(
                                "\(goal.currentAmount.formatted(.currency(code: "USD"))) of \(goal.targetAmount.formatted(.currency(code: "USD")))"
                            )
                            .font(.subheadline)
                        }

                        ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                            .tint(.blue)

                        HStack {
                            if let targetDate = goal.targetDate {
                                Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            let percentage = Int((goal.currentAmount / goal.targetAmount) * 100)
                            Text("\(percentage)%")
                                .font(.caption)
                                .bold()
                        }
                    }
                )
            }
        )
    }
}

// MARK: - Report Item View

struct ReportListItemView: View {
    let reportId: String
    let title: String
    let iconName: String
    let iconColor: Color

    init(reportId: String, title: String, iconName: String, iconColor: Color) {
        self.reportId = reportId
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
    }

    var body: some View {
        NavigationLink(value: ListableItem(id: reportId, name: title, type: .report)) {
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                Text(title)
            }
            .padding(.vertical, 8)
        }
        .tag(ListableItem(id: reportId, name: title, type: .report))
    }
}
