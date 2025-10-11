import SwiftUI

// filepath: /Users/danielstevens/Desktop/PlannerApp/Views/Calendar/CalendarView.swift
// PlannerApp/Views/Calendar/CalendarView.swift

import Foundation

public struct CalendarView: View {
    // Access shared ThemeManager and data
    @EnvironmentObject var themeManager: ThemeManager
    @State private var events: [CalendarEvent] = []
    @State private var goals: [Goal] = []
    @State private var tasks: [Task] = []
    @State private var showAddEvent = false
    @State private var selectedDate = Date()
    @State private var showingDateDetails = false

    // Avoid @AppStorage during testing to prevent UserDefaults access crashes
    private var firstDayOfWeekSetting: Int {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let value = isTesting ? Calendar.current.firstWeekday : UserDefaults.standard.integer(forKey: AppSettingKeys.firstDayOfWeek)
        return value == 0 ? Calendar.current.firstWeekday : value
    }

    private var use24HourTime: Bool {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        return isTesting ? false : UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    }

    // Computed property to group events by the start of their day
    private var groupedEvents: [Date: [CalendarEvent]] {
        var calendar = Calendar.current
        calendar.firstWeekday = self.firstDayOfWeekSetting
        return Dictionary(grouping: self.events.sorted(by: { $0.date < $1.date })) { event in
            calendar.startOfDay(for: event.date)
        }
    }

    // Computed property to get dates with goals
    private var goalDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = self.firstDayOfWeekSetting
        return Set(self.goals.map { calendar.startOfDay(for: $0.targetDate) })
    }

    // Computed property to get dates with tasks
    private var taskDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = self.firstDayOfWeekSetting
        return Set(self.tasks.compactMap { task in
            guard let dueDate = task.dueDate else { return nil }
            return calendar.startOfDay(for: dueDate)
        })
    }

    // Computed property to get dates with events
    private var eventDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = self.firstDayOfWeekSetting
        return Set(self.events.map { calendar.startOfDay(for: $0.date) })
    }

    // Get items for selected date
    private var selectedDateItems: (events: [CalendarEvent], goals: [Goal], tasks: [Task]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self.selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let dayEvents = self.events.filter { event in
            event.date >= startOfDay && event.date < endOfDay
        }

        let dayGoals = self.goals.filter { goal in
            calendar.startOfDay(for: goal.targetDate) == startOfDay
        }

        let dayTasks = self.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.startOfDay(for: dueDate) == startOfDay
        }

        return (dayEvents, dayGoals, dayTasks)
    }

    // Date Formatters
    private var eventTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: self.use24HourTime ? "en_GB" : "en_US")
        return formatter
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var selectedDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Widget
                VStack(spacing: 16) {
                    // Calendar Header
                    HStack {
                        Text(self.monthYearFormatter.string(from: self.selectedDate))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                        Spacer()

                        HStack(spacing: 12) {
                            Button {
                                self.previousMonth()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                            }
                            .accessibilityLabel("Button")
                            .accessibilityLabel("Button")

                            Button {
                                self.nextMonth()
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                            }
                            .accessibilityLabel("Button")
                            .accessibilityLabel("Button")
                        }
                    }
                    .padding(.horizontal, 20)

                    // Calendar Grid
                    CalendarGrid(
                        selectedDate: self.$selectedDate,
                        eventDates: self.eventDates,
                        goalDates: self.goalDates,
                        taskDates: self.taskDates,
                        firstDayOfWeek: self.firstDayOfWeekSetting
                    )
                    .environmentObject(self.themeManager)
                }
                .padding(.vertical, 16)
                .background(self.themeManager.currentTheme.secondaryBackgroundColor)

                // Selected Date Details
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(self.selectedDateFormatter.string(from: self.selectedDate))
                            .font(.headline)
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                        Spacer()

                        Button {
                            self.showAddEvent = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                                .font(.title2)
                        }
                        .accessibilityLabel("Button")
                        .accessibilityLabel("Button")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let items = self.selectedDateItems

                            // Events Section
                            if !items.events.isEmpty {
                                DateSectionView(title: "Events", color: .blue) {
                                    ForEach(items.events) { event in
                                        EventRowView(event: event)
                                            .environmentObject(self.themeManager)
                                    }
                                }
                            }

                            // Goals Section
                            if !items.goals.isEmpty {
                                DateSectionView(title: "Goals", color: .green) {
                                    ForEach(items.goals) { goal in
                                        GoalRowView(goal: goal)
                                            .environmentObject(self.themeManager)
                                    }
                                }
                            }

                            // Tasks Section
                            if !items.tasks.isEmpty {
                                DateSectionView(title: "Tasks", color: .orange) {
                                    ForEach(items.tasks) { task in
                                        TaskRowView(task: task)
                                            .environmentObject(self.themeManager)
                                    }
                                }
                            }

                            // Empty State
                            if items.events.isEmpty, items.goals.isEmpty, items.tasks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 40))
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("No items for this date")
                                        .font(.subheadline)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("Tap + to add an event")
                                        .font(.caption)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(self.themeManager.currentTheme.primaryBackgroundColor)
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor)
            .navigationTitle("Calendar")
            .sheet(isPresented: self.$showAddEvent) {
                AddCalendarEventView(events: self.$events)
                    .environmentObject(self.themeManager)
                    .onDisappear(perform: self.saveEvents)
            }
            .onAppear(perform: self.loadAllData)
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
        }
    }

    // MARK: - Calendar Navigation

    private func previousMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: self.selectedDate) ?? self.selectedDate
    }

    private func nextMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: self.selectedDate) ?? self.selectedDate
    }

    // MARK: - Data Functions

    private func loadAllData() {
        self.events = CalendarDataManager.shared.load()
        self.goals = GoalDataManager.shared.load()
        self.tasks = TaskDataManager.shared.load()
        print("Calendar data loaded. Events: \(self.events.count), Goals: \(self.goals.count), Tasks: \(self.tasks.count)")
    }

    private func saveEvents() {
        CalendarDataManager.shared.save(events: self.events)
        print("Calendar events saved.")
        self.loadAllData()
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func generateDatesInMonth(for date: Date, firstDayOfWeek: Int) -> [Date] {
        guard let monthInterval = dateInterval(of: .month, for: date) else { return [] }

        let monthStart = monthInterval.start
        let firstWeekday = component(.weekday, from: monthStart)
        let daysFromPreviousMonth = (firstWeekday - firstDayOfWeek + 7) % 7

        guard let calendarStart = self.date(byAdding: .day, value: -daysFromPreviousMonth, to: monthStart) else { return [] }

        var dates: [Date] = []
        var currentDate = calendarStart

        for _ in 0 ..< 42 {
            dates.append(currentDate)
            guard let nextDate = self.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }
}

// MARK: - Preview Provider

public struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(ThemeManager())
    }
}
