// PlannerApp/Views/Calendar/CalendarView.swift (Updated with Calendar Widget)
import SwiftUI
import Foundation

struct CalendarView: View {
    // Access shared ThemeManager and data
    @EnvironmentObject var themeManager: ThemeManager
    @State private var events: [CalendarEvent] = [] // Holds all calendar events
    @State private var goals: [Goal] = [] // Holds all goals
    @State private var tasks: [TaskModel] = [] // Holds all tasks
    @State private var showAddEvent = false // State to control presentation of the AddEvent sheet
    @State private var selectedDate = Date() // Currently selected date
    @State private var showingDateDetails = false // Show details for selected date

    // Read date/time settings from UserDefaults
    @AppStorage(AppSettingKeys.firstDayOfWeek) private var firstDayOfWeekSetting: Int = Calendar.current.firstWeekday
    @AppStorage(AppSettingKeys.use24HourTime) private var use24HourTime: Bool = false

    // Computed property to group events by the start of their day
    private var groupedEvents: [Date: [CalendarEvent]] {
        // Create a Calendar instance configured with user's first day of week setting
        var calendar = Calendar.current
        calendar.firstWeekday = firstDayOfWeekSetting
        // Group the sorted events using the start of the day as the key
        return Dictionary(grouping: events.sorted(by: { $0.date < $1.date })) { event in
            calendar.startOfDay(for: event.date)
        }
    }
    
    // Computed property to get dates with goals
    private var goalDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = firstDayOfWeekSetting
        return Set(goals.map { calendar.startOfDay(for: $0.targetDate) })
    }
    
    // Computed property to get dates with tasks
    private var taskDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = firstDayOfWeekSetting
        return Set(tasks.compactMap { task in
            guard let dueDate = task.dueDate else { return nil }
            return calendar.startOfDay(for: dueDate)
        })
    }
    
    // Computed property to get dates with events
    private var eventDates: Set<Date> {
        var calendar = Calendar.current
        calendar.firstWeekday = firstDayOfWeekSetting
        return Set(events.map { calendar.startOfDay(for: $0.date) })
    }

    // Get items for selected date
    private var selectedDateItems: (events: [CalendarEvent], goals: [Goal], tasks: [TaskModel]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let dayEvents = events.filter { event in
            event.date >= startOfDay && event.date < endOfDay
        }
        
        let dayGoals = goals.filter { goal in
            calendar.startOfDay(for: goal.targetDate) == startOfDay
        }
        
        let dayTasks = tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.startOfDay(for: dueDate) == startOfDay
        }
        
        return (dayEvents, dayGoals, dayTasks)
    }

    // --- Date Formatters ---
    // Formatter for event times within rows (e.g., "1:47 PM" or "13:47")
    private var eventTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        // Set locale based on 24-hour setting
        formatter.locale = Locale(identifier: use24HourTime ? "en_GB" : "en_US")
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Widget
                VStack(spacing: 16) {
                    // Calendar Header
                    HStack {
                        Text(monthYearFormatter.string(from: selectedDate))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentTheme.primaryTextColor)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                            }
                            
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Calendar Grid
                    CalendarGrid(
                        selectedDate: $selectedDate,
                        eventDates: eventDates,
                        goalDates: goalDates,
                        taskDates: taskDates,
                        firstDayOfWeek: firstDayOfWeekSetting
                    )
                    .environmentObject(themeManager)
                }
                .padding(.vertical, 16)
                .background(themeManager.currentTheme.secondaryBackgroundColor)
                
                // Selected Date Details
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(selectedDateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryTextColor)
                        
                        Spacer()
                        
                        Button(action: { showAddEvent = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryAccentColor)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let items = selectedDateItems
                            
                            // Events Section
                            if !items.events.isEmpty {
                                DateSectionView(title: "Events", color: .blue) {
                                    ForEach(items.events) { event in
                                        EventRowView(event: event)
                                            .environmentObject(themeManager)
                                    }
                                }
                            }
                            
                            // Goals Section
                            if !items.goals.isEmpty {
                                DateSectionView(title: "Goals", color: .green) {
                                    ForEach(items.goals) { goal in
                                        GoalRowView(goal: goal)
                                            .environmentObject(themeManager)
                                    }
                                }
                            }
                            
                            // Tasks Section
                            if !items.tasks.isEmpty {
                                DateSectionView(title: "Tasks", color: .orange) {
                                    ForEach(items.tasks) { task in
                                        TaskRowView(task: task)
                                            .environmentObject(themeManager)
                                    }
                                }
                            }
                            
                            // Empty State
                            if items.events.isEmpty && items.goals.isEmpty && items.tasks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 40))
                                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                    
                                    Text("No items for this date")
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                    
                                    Text("Tap + to add an event")
                                        .font(.caption)
                                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(themeManager.currentTheme.primaryBackgroundColor)
            }
            .background(themeManager.currentTheme.primaryBackgroundColor)
            .navigationTitle("Calendar")
            .sheet(isPresented: $showAddEvent) {
                // Present AddCalendarEventView, passing the events binding and theme
                AddCalendarEventView(events: $events)
                    .environmentObject(themeManager)
                    // Save events when the sheet is dismissed
                    .onDisappear(perform: saveEvents)
            }
            // Load events when the view appears
            .onAppear(perform: loadAllData)
            // Apply theme accent color to toolbar items
            .accentColor(themeManager.currentTheme.primaryAccentColor)
        }
    }

    // MARK: - Calendar Navigation
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
    
    // MARK: - Date Formatters
    
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

    // MARK: - Data Functions

    // Loads all data from data managers
    private func loadAllData() {
        events = CalendarDataManager.shared.load()
        goals = GoalDataManager.shared.load()
        tasks = TaskDataManager.shared.load()
        print("Calendar data loaded. Events: \(events.count), Goals: \(goals.count), Tasks: \(tasks.count)")
    }
    
    // Saves the current state of the `events` array to the data manager
    private func saveEvents() {
        CalendarDataManager.shared.save(events: events)
        print("Calendar events saved.")
        loadAllData() // Reload to refresh display
    }
}

// MARK: - Supporting Calendar Components

// MARK: - Calendar Extension

extension Calendar {
    func generateDatesInMonth(for date: Date, firstDayOfWeek: Int) -> [Date] {
        guard let monthInterval = self.dateInterval(of: .month, for: date) else { return [] }
        
        let monthStart = monthInterval.start
        let _ = monthInterval.end // monthEnd not used in this implementation
        
        // Find the start of the week for the first day of the month
        let firstWeekday = self.component(.weekday, from: monthStart)
        let daysFromPreviousMonth = (firstWeekday - firstDayOfWeek + 7) % 7
        
        guard let calendarStart = self.date(byAdding: .day, value: -daysFromPreviousMonth, to: monthStart) else { return [] }
        
        // Generate 6 weeks worth of dates (42 days)
        var dates: [Date] = []
        var currentDate = calendarStart
        
        for _ in 0..<42 {
            dates.append(currentDate)
            guard let nextDate = self.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
}

// --- Preview Provider ---
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            // Provide ThemeManager for the preview
            .environmentObject(ThemeManager())
    }
}
