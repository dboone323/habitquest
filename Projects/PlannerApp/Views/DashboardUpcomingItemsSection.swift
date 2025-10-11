import Foundation
import SwiftUI

public struct DashboardUpcomingItemsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let upcomingItems: [UpcomingItem]
    let itemLimit: Int

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()

                Button("View Calendar").accessibilityLabel("Button") {
                    /// - Pending: Navigate to calendar
                    print("View Calendar tapped")
                }
                .font(.caption)
                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
            }

            LazyVStack(spacing: 12) {
                ForEach(self.upcomingItems.prefix(self.itemLimit), id: \.id) { item in
                    UpcomingItemView(item: item)
                }

                if self.upcomingItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        Text("Nothing upcoming")
                            .font(.subheadline)
                            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                        Text("Schedule some events to see them here")
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
