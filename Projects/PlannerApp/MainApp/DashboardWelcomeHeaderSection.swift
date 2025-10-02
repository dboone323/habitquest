import SwiftUI

public struct DashboardWelcomeHeaderSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let userName: String
    let use24HourTime: Bool

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: self.use24HourTime ? "en_GB" : "en_US")
        return formatter
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12:
            return "Good Morning"
        case 12 ..< 17:
            return "Good Afternoon"
        case 17 ..< 22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.greetingText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                    if !self.userName.isEmpty {
                        Text(self.userName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                    }

                    Text(self.dateFormatter.string(from: Date()))
                        .font(.subheadline)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(self.timeFormatter.string(from: Date()))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                    Text("Today")
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}
