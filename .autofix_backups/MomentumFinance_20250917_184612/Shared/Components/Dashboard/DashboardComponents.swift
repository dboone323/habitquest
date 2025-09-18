//
//  DashboardComponents.swift
//  MomentumFinance
//
//  Created by GitHub Copilot on 2025-09-05.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftData
import SwiftUI

// Import the models
// Note: FinancialAccount should be available from the Models folder

// MARK: - Dashboard Welcome Header

public struct DashboardWelcomeHeader: View {
    public let userName: String

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back, \(self.userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Here's your financial overview")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    public init(userName: String) {
        self.userName = userName
    }
}

// MARK: - Dashboard Accounts Summary

public struct DashboardAccountsSummary: View {
    public let accounts: [FinancialAccount]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accounts")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(self.accounts) { account in
                        AccountSummaryCard(account: account)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    public init(accounts: [FinancialAccount]) {
        self.accounts = accounts
    }
}

// MARK: - Account Summary Card

public struct AccountSummaryCard: View {
    public let account: FinancialAccount

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(self.account.name)
                    .font(.headline)
                Spacer()
                Image(systemName: self.iconName)
                    .foregroundColor(.blue)
            }

            Text(formatCurrency(self.account.balance))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(self.account.balance >= 0 ? .green : .red)

            Text(self.account.type.rawValue.capitalized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .frame(width: 160)
    }

    private var iconName: String {
        switch self.account.type {
        case .checking:
            "creditcard"
        case .savings:
            "banknote"
        case .credit:
            "creditcard.fill"
        case .cash:
            "dollarsign.circle"
        }
    }

    public init(account: FinancialAccount) {
        self.account = account
    }
}

// MARK: - Dashboard Metrics Cards

public struct DashboardMetricsCards: View {
    public let totalBalance: Double
    public let monthlyIncome: Double
    public let monthlyExpenses: Double

    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(
                    title: "Total Balance",
                    value: formatCurrency(self.totalBalance),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                MetricCard(
                    title: "Monthly Income",
                    value: formatCurrency(self.monthlyIncome),
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
            }

            MetricCard(
                title: "Monthly Expenses",
                value: formatCurrency(self.monthlyExpenses),
                icon: "arrow.down.circle.fill",
                color: .red
            )
        }
        .padding(.horizontal)
    }

    public init(totalBalance: Double, monthlyIncome: Double, monthlyExpenses: Double) {
        self.totalBalance = totalBalance
        self.monthlyIncome = monthlyIncome
        self.monthlyExpenses = monthlyExpenses
    }
}

// MARK: - Metric Card

public struct MetricCard: View {
    public let title: String
    public let value: String
    public let icon: String
    public let color: Color

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(self.value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Spacer()

            Image(systemName: self.icon)
                .font(.title2)
                .foregroundColor(self.color)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
}

// MARK: - Helper Functions

private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
}
