// PlannerApp/Views/Calendar/EventRowView.swift
import SwiftUI

public struct EventRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let event: CalendarEvent

    // Read time format setting from UserDefaults - avoid during testing
    private var use24HourTime: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: self.use24HourTime ? "en_GB" : "en_US")
        return formatter
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(alignment: .center, spacing: 2) {
                Text(self.timeFormatter.string(from: self.event.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)

                Circle()
                    .fill(.blue)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 50)

            // Event details
            VStack(alignment: .leading, spacing: 2) {
                Text(self.event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        EventRowView(event: CalendarEvent(
            title: "Team Meeting",
            date: Date()
        ))

        EventRowView(event: CalendarEvent(
            title: "Conference",
            date: Date()
        ))
    }
    .environmentObject(ThemeManager())
    .padding()
}
