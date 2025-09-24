import SwiftUI

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

#Preview {
    QuickStatCard(
        title: "Tasks",
        value: "5",
        subtitle: "3 completed",
        icon: "checkmark.circle.fill",
        color: .blue
    )
    .environmentObject(ThemeManager())
}
