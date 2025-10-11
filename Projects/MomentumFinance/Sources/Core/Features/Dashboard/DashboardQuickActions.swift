import SwiftUI

// MARK: - Dashboard Quick Actions

public struct DashboardQuickActions: View {
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
                    action: self.onAddTransaction
                )

                QuickActionButton(
                    title: "Pay Bills",
                    icon: "creditcard.fill",
                    color: .blue,
                    action: self.onPayBills
                )

                QuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .orange,
                    action: self.onViewReports
                )

                QuickActionButton(
                    title: "Set Goals",
                    icon: "target",
                    color: .purple,
                    action: self.onSetGoals
                )
            }
        }
    }
}

public struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: self.action).accessibilityLabel("Button").accessibilityLabel("Button") {
            VStack(spacing: 8) {
                Image(systemName: self.icon)
                    .font(.title2)
                    .foregroundStyle(self.color)

                Text(self.title)
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
