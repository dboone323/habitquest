import SwiftUI

public struct DashboardQuickStatsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let totalTasks: Int
    let completedTasks: Int
    let totalGoals: Int
    let completedGoals: Int
    let todayEvents: Int

    public var body: some View {
        HStack(spacing: 16) {
            QuickStatCard(
                title: "Tasks",
                value: "\(self.totalTasks)",
                subtitle: "\(self.completedTasks) completed",
                icon: "checkmark.circle.fill",
                color: self.themeManager.currentTheme.primaryAccentColor
            )

            QuickStatCard(
                title: "Goals",
                value: "\(self.totalGoals)",
                subtitle: "\(self.completedGoals) achieved",
                icon: "target",
                color: .green
            )

            QuickStatCard(
                title: "Events",
                value: "\(self.todayEvents)",
                subtitle: "today",
                icon: "calendar",
                color: .orange
            )
        }
        .padding(.horizontal, 24)
    }
}

public struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: self.icon)
                    .foregroundColor(self.color)
                    .font(.title3)

                Spacer()
            }

            Text(self.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Text(self.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Text(self.subtitle)
                .font(.caption2)
                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
