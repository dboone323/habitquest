import SwiftUI

// MARK: - Dashboard Support Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.mint)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

struct AccountRow: View {
    let account: FinancialAccount

    var body: some View {
        HStack {
            Image(systemName: account.iconName)
                .foregroundStyle(.mint)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(account.accountType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("$\(account.balance, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.mint.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: "repeat.circle")
                    .font(.caption)
                    .foregroundStyle(.mint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text("Next: \(subscription.nextDueDate, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("$\(subscription.amount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

struct BudgetRow: View {
    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("$\(budget.spentAmount, specifier: "%.0f") / $\(budget.limitAmount, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor(for: budget))
                        .frame(width: progressWidth(for: budget, in: geometry.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }

    private func progressColor(for budget: Budget) -> Color {
        let percentage = budget.progressPercentage
        if percentage > 0.9 { return .red }
        if percentage > 0.7 { return .orange }
        return .mint
    }

    private func progressWidth(for budget: Budget, in totalWidth: CGFloat) -> CGFloat {
        let percentage = min(budget.progressPercentage, 1.0)
        return totalWidth * percentage
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
