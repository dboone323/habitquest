import SwiftUI

// MARK: - Dashboard Quick Actions

struct DashboardQuickActions: View {
    let onAddTransaction: () -> Void
    let onPayBills: () -> Void
    let onViewReports: () -> Void
    let onSetGoals: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Actions", icon: "bolt")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "Add Transaction",
                    icon: "plus.circle.fill",
                    color: .mint,
                    action: onAddTransaction
                )

                QuickActionButton(
                    title: "Pay Bills",
                    icon: "creditcard.fill",
                    color: .blue,
                    action: onPayBills
                )

                QuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .orange,
                    action: onViewReports
                )

                QuickActionButton(
                    title: "Set Goals",
                    icon: "target",
                    color: .purple,
                    action: onSetGoals
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
