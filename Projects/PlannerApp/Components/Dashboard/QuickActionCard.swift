import SwiftUI

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
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickActionCard(
        title: "Add Task",
        icon: "plus.circle.fill",
        color: Color.blue.opacity(0.8)
    ) {
        print("Action tapped")
    }
    .environmentObject(ThemeManager())
}
