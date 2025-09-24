// PlannerApp/Views/Calendar/CalendarGrid.swift
import SwiftUI

public struct CalendarGrid: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedDate: Date
    let eventDates: Set<Date>
    let goalDates: Set<Date>
    let taskDates: Set<Date>
    let firstDayOfWeek: Int

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = self.firstDayOfWeek
        return cal
    }

    private var monthDates: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }

        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end

        // Get the first day of the week that contains the first day of the month
        let firstWeekday = self.calendar.dateInterval(of: .weekOfYear, for: monthStart)?.start ?? monthStart

        // Get all dates from the first weekday to the end of the month's week
        var dates: [Date] = []
        var currentDate = firstWeekday

        while currentDate < monthEnd {
            dates.append(currentDate)
            currentDate = self.calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        // Add extra days to fill the last week if needed
        while dates.count % 7 != 0 {
            dates.append(self.calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)
            currentDate = self.calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return dates
    }

    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        var symbols = formatter.shortWeekdaySymbols!

        // Adjust for first day of week setting
        if self.firstDayOfWeek != 1 { // If not Sunday
            let sundayIndex = self.firstDayOfWeek - 1
            symbols = Array(symbols[sundayIndex...]) + Array(symbols[..<sundayIndex])
        }

        return symbols
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(self.weekdayHeaders, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(self.monthDates, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        selectedDate: self.$selectedDate,
                        isCurrentMonth: self.calendar.isDate(date, equalTo: self.selectedDate, toGranularity: .month),
                        hasEvent: self.eventDates.contains(self.calendar.startOfDay(for: date)),
                        hasGoal: self.goalDates.contains(self.calendar.startOfDay(for: date)),
                        hasTask: self.taskDates.contains(self.calendar.startOfDay(for: date))
                    )
                    .environmentObject(self.themeManager)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

public struct CalendarDayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let date: Date
    @Binding var selectedDate: Date
    let isCurrentMonth: Bool
    let hasEvent: Bool
    let hasGoal: Bool
    let hasTask: Bool

    private var calendar: Calendar { Calendar.current }

    private var isSelected: Bool {
        self.calendar.isDate(self.date, inSameDayAs: self.selectedDate)
    }

    private var isToday: Bool {
        self.calendar.isDateInToday(self.date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self.date)
    }

    public var body: some View {
        VStack(spacing: 2) {
            // Day number
            Text(self.dayNumber)
                .font(.system(size: 16, weight: self.isToday ? .bold : .medium))
                .foregroundColor(self.dayTextColor)
                .frame(width: 32, height: 32)
                .background(self.dayBackgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(self.isSelected ? self.themeManager.currentTheme.primaryAccentColor : Color.clear, lineWidth: 2)
                )

            // Indicator dots
            HStack(spacing: 2) {
                if self.hasEvent {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                }
                if self.hasGoal {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 4, height: 4)
                }
                if self.hasTask {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectedDate = self.date
        }
    }

    private var dayTextColor: Color {
        if self.isSelected {
            self.themeManager.currentTheme.primaryBackgroundColor
        } else if self.isToday {
            self.themeManager.currentTheme.primaryAccentColor
        } else if self.isCurrentMonth {
            self.themeManager.currentTheme.primaryTextColor
        } else {
            self.themeManager.currentTheme.secondaryTextColor.opacity(0.5)
        }
    }

    private var dayBackgroundColor: Color {
        if self.isSelected {
            self.themeManager.currentTheme.primaryAccentColor
        } else if self.isToday {
            self.themeManager.currentTheme.primaryAccentColor.opacity(0.1)
        } else {
            Color.clear
        }
    }
}

#Preview {
    CalendarGrid(
        selectedDate: .constant(Date()),
        eventDates: Set([Date()]),
        goalDates: Set([Calendar.current.date(byAdding: .day, value: 1, to: Date())!]),
        taskDates: Set([Calendar.current.date(byAdding: .day, value: 2, to: Date())!]),
        firstDayOfWeek: 1
    )
    .environmentObject(ThemeManager())
    .padding()
}
