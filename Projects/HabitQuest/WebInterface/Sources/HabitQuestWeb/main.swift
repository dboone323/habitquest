import JavaScriptKit
import SwiftWebAPI

// MARK: - Data Models

struct Habit: Codable {
    let id: String
    var name: String
    var description: String
    var color: String
    var frequency: HabitFrequency
    var targetDays: Int
    var completedDates: [String]
    var createdDate: String

    enum HabitFrequency: String, Codable {
        case daily, weekly, custom
    }

    var currentStreak: Int {
        // Calculate current streak (simplified)
        let today = getCurrentDateString()
        var streak = 0
        var checkDate = today

        while completedDates.contains(checkDate) {
            streak += 1
            checkDate = getPreviousDateString(from: checkDate)
        }

        return streak
    }

    var completionRate: Double {
        let totalDays = daysSinceCreation()
        return totalDays > 0 ? Double(completedDates.count) / Double(totalDays) : 0
    }

    private func daysSinceCreation() -> Int {
        // Simplified calculation
        30 // Assume 30 days for demo
    }
}

struct HabitEntry: Codable {
    let habitId: String
    let date: String
    let completed: Bool
    let notes: String?
}

// MARK: - Habit Quest Web App

@MainActor
class HabitQuestWeb {
    private let document = JSObject.global.document
    private let console = JSObject.global.console
    private var habits: [Habit] = []
    private var habitEntries: [HabitEntry] = []

    // DOM Elements
    private var habitList: JSObject?
    private var habitForm: JSObject?
    private var statsContainer: JSObject?
    private var calendarView: JSObject?

    init() {
        console.log("🎯 HabitQuest Web App initializing...")
        setupUI()
        loadData()
        setupEventListeners()
        updateDashboard()
    }

    private func setupUI() {
        // Create main container
        let container = document.createElement("div")
        container.className = "habit-container"

        // Header
        let header = document.createElement("header")
        header.innerHTML = """
            <h1>🎯 HabitQuest</h1>
            <p>Build lasting habits through gamification</p>
        """
        container.appendChild(header)

        // Stats Dashboard
        let stats = document.createElement("div")
        stats.className = "stats-dashboard"
        stats.innerHTML = """
            <div class="stat-card">
                <h3>Active Habits</h3>
                <div id="active-habits" class="stat-value">0</div>
            </div>
            <div class="stat-card">
                <h3>Longest Streak</h3>
                <div id="longest-streak" class="stat-value">0</div>
            </div>
            <div class="stat-card">
                <h3>Completion Rate</h3>
                <div id="completion-rate" class="stat-value">0%</div>
            </div>
            <div class="stat-card">
                <h3>Habits Completed Today</h3>
                <div id="today-completed" class="stat-value">0</div>
            </div>
        """
        container.appendChild(stats)

        // Add Habit Form
        let form = document.createElement("div")
        form.className = "habit-form"
        form.innerHTML = """
            <h2>Create New Habit</h2>
            <form id="habit-form">
                <input type="text" id="habit-name" placeholder="Habit name" required>
                <textarea id="habit-description" placeholder="Description (optional)"></textarea>
                <select id="habit-frequency" required>
                    <option value="daily">Daily</option>
                    <option value="weekly">Weekly</option>
                    <option value="custom">Custom</option>
                </select>
                <input type="number" id="target-days" placeholder="Target days per week" min="1" max="7" value="7">
                <input type="color" id="habit-color" value="#4CAF50">
                <button type="submit">Create Habit</button>
            </form>
        """
        container.appendChild(form)

        // Habits List
        let habitsSection = document.createElement("div")
        habitsSection.className = "habits-section"
        habitsSection.innerHTML = """
            <h2>Your Habits</h2>
            <div id="habit-list" class="habit-list"></div>
        """
        container.appendChild(habitsSection)

        // Calendar View
        let calendarSection = document.createElement("div")
        calendarSection.className = "calendar-section"
        calendarSection.innerHTML = """
            <h2>Habit Calendar</h2>
            <div id="calendar-view" class="calendar-view"></div>
        """
        container.appendChild(calendarSection)

        // Replace body content
        let body = document.body
        body.innerHTML = ""
        body.appendChild(container)

        // Get references to key elements
        habitList = document.getElementById("habit-list")
        habitForm = document.getElementById("habit-form")
        statsContainer = document.querySelector(".stats-dashboard")
        calendarView = document.getElementById("calendar-view")
    }

    private func setupEventListeners() {
        let form = document.getElementById("habit-form")
        form?.addEventListener("submit", JSClosure { [weak self] event in
            event.preventDefault()
            self?.createHabit()
            return .undefined
        })
    }

    private func createHabit() {
        guard let nameInput = document.getElementById("habit-name"),
              let descriptionInput = document.getElementById("habit-description"),
              let frequencySelect = document.getElementById("habit-frequency"),
              let targetInput = document.getElementById("target-days"),
              let colorInput = document.getElementById("habit-color")
        else {
            return
        }

        let name = nameInput.value.string ?? ""
        let description = descriptionInput.value.string ?? ""
        let frequencyString = frequencySelect.value.string ?? "daily"
        let targetDays = Int(targetInput.value.string ?? "7") ?? 7
        let color = colorInput.value.string ?? "#4CAF50"

        guard !name.isEmpty else {
            console.log("Habit name is required")
            return
        }

        let frequency = Habit.HabitFrequency(rawValue: frequencyString) ?? .daily

        let habit = Habit(
            id: UUID().uuidString,
            name: name,
            description: description,
            color: color,
            frequency: frequency,
            targetDays: targetDays,
            completedDates: [],
            createdDate: getCurrentDateString()
        )

        habits.append(habit)
        saveData()
        updateDashboard()
        clearForm()

        console.log("Habit created:", habit.name)
    }

    private func clearForm() {
        document.getElementById("habit-name")?.value = ""
        document.getElementById("habit-description")?.value = ""
        document.getElementById("habit-frequency")?.value = "daily"
        document.getElementById("target-days")?.value = "7"
        document.getElementById("habit-color")?.value = "#4CAF50"
    }

    private func toggleHabitCompletion(_ habitId: String, date: String) {
        if let index = habitEntries.firstIndex(where: { $0.habitId == habitId && $0.date == date }) {
            habitEntries[index].completed.toggle()
        } else {
            let entry = HabitEntry(habitId: habitId, date: date, completed: true, notes: nil)
            habitEntries.append(entry)
        }

        // Update habit's completed dates
        if let habitIndex = habits.firstIndex(where: { $0.id == habitId }) {
            if let entryIndex = habitEntries.firstIndex(where: { $0.habitId == habitId && $0.date == date && $0.completed }) {
                if !habits[habitIndex].completedDates.contains(date) {
                    habits[habitIndex].completedDates.append(date)
                }
            } else {
                habits[habitIndex].completedDates.removeAll { $0 == date }
            }
        }

        saveData()
        updateDashboard()
    }

    private func updateDashboard() {
        updateStats()
        updateHabitList()
        updateCalendar()
    }

    private func updateStats() {
        let activeHabits = habits.count
        let longestStreak = habits.map(\.currentStreak).max() ?? 0
        let totalCompletions = habitEntries.filter(\.completed).count
        let totalPossible = habits.count * 30 // Simplified
        let completionRate = totalPossible > 0 ? Int(Double(totalCompletions) / Double(totalPossible) * 100) : 0
        let todayCompleted = habitEntries.filter { $0.date == getCurrentDateString() && $0.completed }.count

        document.getElementById("active-habits")?.innerHTML = .string("\(activeHabits)")
        document.getElementById("longest-streak")?.innerHTML = .string("\(longestStreak)")
        document.getElementById("completion-rate")?.innerHTML = .string("\(completionRate)%")
        document.getElementById("today-completed")?.innerHTML = .string("\(todayCompleted)")
    }

    private func updateHabitList() {
        guard let habitList else { return }

        var html = ""
        for habit in habits {
            let today = getCurrentDateString()
            let isCompletedToday = habit.completedDates.contains(today)
            let streakText = habit.currentStreak > 0 ? "🔥 \(habit.currentStreak) day streak" : "Start your streak!"

            html += """
                <div class="habit-card" style="border-left-color: \(habit.color)">
                    <div class="habit-header">
                        <h3>\(habit.name)</h3>
                        <button class="complete-btn \(isCompletedToday ? "completed" : "")"
                                onclick="window.toggleHabit('\(habit.id)', '\(today)')">
                            \(isCompletedToday ? "✓" : "○")
                        </button>
                    </div>
                    <p class="habit-description">\(habit.description)</p>
                    <div class="habit-stats">
                        <span class="streak">\(streakText)</span>
                        <span class="completion-rate">\(Int(habit.completionRate * 100))% success rate</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: \(min(habit.completionRate * 100, 100))%; background-color: \(habit.color)"></div>
                    </div>
                </div>
            """
        }

        habitList.innerHTML = .string(html)
    }

    private func updateCalendar() {
        guard let calendarView else { return }

        // Simple 7-day calendar view
        let today = getCurrentDateString()
        var dates = [String]()

        for i in 0 ..< 7 {
            dates.append(getDateString(daysFromToday: -i))
        }

        var html = "<div class=\"calendar-grid\">"

        for date in dates.reversed() {
            let dateObj = getDateFromString(date)
            let dayName = getDayName(from: date)
            let isToday = date == today

            var habitStatuses = ""
            for habit in habits {
                let isCompleted = habit.completedDates.contains(date)
                let bgColor = isCompleted ? habit.color : "#e0e0e0"
                habitStatuses += "<div class=\"habit-dot\" style=\"background-color: \(bgColor)\" title=\"\(habit.name)\"></div>"
            }

            html += """
                <div class="calendar-day \(isToday ? "today" : "")">
                    <div class="day-name">\(dayName)</div>
                    <div class="day-number">\(dateObj.day)</div>
                    <div class="habit-indicators">\(habitStatuses)</div>
                </div>
            """
        }

        html += "</div>"
        calendarView.innerHTML = .string(html)
    }

    private func getCurrentDateString() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: now)
    }

    private func getDateString(daysFromToday: Int) -> String {
        let now = Date()
        let date = Calendar.current.date(byAdding: .day, value: daysFromToday, to: now)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func getPreviousDateString(from dateString: String) -> String {
        let date = getDateFromString(dateString)
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: previousDate)
    }

    private func getDateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }

    private func getDayName(from dateString: String) -> String {
        let date = getDateFromString(dateString)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func loadData() {
        // Load from localStorage
        if let storedHabits = JSObject.global.localStorage.getItem("habitquest_habits").string,
           let data = storedHabits.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data)
        {
            habits = decoded
        }

        if let storedEntries = JSObject.global.localStorage.getItem("habitquest_entries").string,
           let data = storedEntries.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([HabitEntry].self, from: data)
        {
            habitEntries = decoded
        }
    }

    private func saveData() {
        if let habitData = try? JSONEncoder().encode(habits),
           let habitJson = String(data: habitData, encoding: .utf8)
        {
            JSObject.global.localStorage.setItem("habitquest_habits", habitJson)
        }

        if let entryData = try? JSONEncoder().encode(habitEntries),
           let entryJson = String(data: entryData, encoding: .utf8)
        {
            JSObject.global.localStorage.setItem("habitquest_entries", entryJson)
        }
    }
}

// MARK: - Global Functions for Event Handlers

func toggleHabit(_ habitId: String, _ date: String) {
    // This would be called from JavaScript event handlers
    // In a real implementation, we'd have access to the app instance
    print("Toggling habit \(habitId) for date \(date)")
}

// MARK: - Web App Entry Point

@main
struct HabitQuestWebApp {
    static func main() {
        let app = HabitQuestWeb()
        // Make toggleHabit available globally
        JSObject.global.toggleHabit = JSClosure { args in
            if args.count >= 2,
               let habitId = args[0].string,
               let date = args[1].string
            {
                toggleHabit(habitId, date)
            }
            return .undefined
        }
        // Keep app alive
        _ = app
    }
}
