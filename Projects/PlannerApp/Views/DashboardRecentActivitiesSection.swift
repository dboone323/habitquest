import Foundation
import SwiftUI

public struct DashboardRecentActivitiesSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let activities: [DashboardActivity]
    let itemLimit: Int

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activities")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()

                Button("View All").accessibilityLabel("Button") {
                    /// - Pending: Navigate to activities view
                    print("View All tapped")
                }
                .font(.caption)
                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
            }

            LazyVStack(spacing: 12) {
                ForEach(self.activities.prefix(self.itemLimit), id: \.id) { activity in
                    ActivityRowView(activity: activity)
                }

                if self.activities.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        Text("No recent activities")
                            .font(.subheadline)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        Text("Start by creating a task or goal!")
                            .font(.caption)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

public struct ActivityRowView: View {
    let activity: DashboardActivity
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: self.activity.icon)
                .foregroundColor(self.activity.color)
                .font(.title3)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(self.activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Text(self.activity.subtitle)
                    .font(.caption)
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
            }

            Spacer()

            Text(self.timeAgoString(from: self.activity.timestamp))
                .font(.caption2)
                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
