import SwiftUI

public struct DashboardQuickActionsSection: View {
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                QuickActionCard(
                    title: "Add Task",
                    icon: "plus.circle.fill",
                    color: self.themeManager.currentTheme.primaryAccentColor,
                    action: {
                        // Handle add task
                    }
                )

                QuickActionCard(
                    title: "New Goal",
                    icon: "target",
                    color: .green,
                    action: {
                        // Handle add goal
                    }
                )

                QuickActionCard(
                    title: "Schedule Event",
                    icon: "calendar.badge.plus",
                    color: .orange,
                    action: {
                        // Handle add event
                    }
                )

                QuickActionCard(
                    title: "Journal Entry",
                    icon: "book.fill",
                    color: .purple,
                    action: {
                        // Handle add journal
                    }
                )
            }
        }
        .padding(.horizontal, 24)
    }
}

public struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        Button(action: self.action) {
            VStack(spacing: 12) {
                Image(systemName: self.icon)
                    .font(.title2)
                    .foregroundColor(self.color)

                Text(self.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .accessibilityLabel(self.title)
        .buttonStyle(PlainButtonStyle())
    }
}
