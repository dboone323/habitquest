import JavaScriptKit
import SwiftWebAPI

@MainActor
struct PlannerAppWeb {
    private let document = JSObject.global.document
    private let console = JSObject.global.console

    private var currentView: String = "dashboard"
    private var tasks: [[String: String]] = []

    init() {
        setupUI()
        loadSampleData()
        render()
    }

    private func setupUI() {
        // Create main container
        let container = document.createElement("div")
        container.id = "planner-container"
        container.className = "planner-app"

        // Create header
        let header = document.createElement("header")
        header.className = "app-header"
        header.innerHTML = """
            <h1>📅 PlannerApp Web</h1>
            <nav>
                <button id="dashboard-btn" class="nav-btn active">Dashboard</button>
                <button id="tasks-btn" class="nav-btn">Tasks</button>
                <button id="calendar-btn" class="nav-btn">Calendar</button>
                <button id="settings-btn" class="nav-btn">Settings</button>
            </nav>
        """

        // Create main content area
        let main = document.createElement("main")
        main.id = "main-content"
        main.className = "main-content"

        // Create footer
        let footer = document.createElement("footer")
        footer.className = "app-footer"
        footer.innerHTML = """
            <p>PlannerApp Web - Powered by SwiftWasm</p>
        """

        container.appendChild(header)
        container.appendChild(main)
        container.appendChild(footer)

        document.body.appendChild(container)

        // Add event listeners
        setupEventListeners()
    }

    private func setupEventListeners() {
        // Navigation buttons
        if let dashboardBtn = document.getElementById("dashboard-btn").object {
            _ = dashboardBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.switchView("dashboard")
                return .undefined
            })
        }

        if let tasksBtn = document.getElementById("tasks-btn").object {
            _ = tasksBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.switchView("tasks")
                return .undefined
            })
        }

        if let calendarBtn = document.getElementById("calendar-btn").object {
            _ = calendarBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.switchView("calendar")
                return .undefined
            })
        }

        if let settingsBtn = document.getElementById("settings-btn").object {
            _ = settingsBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.switchView("settings")
                return .undefined
            })
        }
    }

    private func switchView(_ view: String) {
        currentView = view

        // Update navigation active state
        let buttons = ["dashboard-btn", "tasks-btn", "calendar-btn", "settings-btn"]
        for buttonId in buttons {
            if let btn = document.getElementById(buttonId).object {
                if buttonId == "\(view)-btn" {
                    _ = btn.classList.add("active")
                } else {
                    _ = btn.classList.remove("active")
                }
            }
        }

        render()
    }

    private func loadSampleData() {
        tasks = [
            ["id": "1", "title": "Complete project proposal", "priority": "high", "status": "in-progress", "dueDate": "2025-11-05"],
            ["id": "2", "title": "Review code changes", "priority": "medium", "status": "pending", "dueDate": "2025-11-07"],
            ["id": "3", "title": "Update documentation", "priority": "low", "status": "completed", "dueDate": "2025-11-03"],
            ["id": "4", "title": "Team meeting preparation", "priority": "high", "status": "pending", "dueDate": "2025-11-06"],
        ]
    }

    private func render() {
        guard let mainContent = document.getElementById("main-content").object else { return }

        // Clear existing content
        mainContent.innerHTML = ""

        switch currentView {
        case "dashboard":
            renderDashboard(mainContent)
        case "tasks":
            renderTasks(mainContent)
        case "calendar":
            renderCalendar(mainContent)
        case "settings":
            renderSettings(mainContent)
        default:
            renderDashboard(mainContent)
        }
    }

    private func renderDashboard(_ container: JSObject) {
        let dashboard = document.createElement("div")
        dashboard.className = "dashboard"

        let stats = document.createElement("div")
        stats.className = "stats-grid"
        stats.innerHTML = """
            <div class="stat-card">
                <h3>Total Tasks</h3>
                <div class="stat-number">\(tasks.count)</div>
            </div>
            <div class="stat-card">
                <h3>Completed</h3>
                <div class="stat-number">\(tasks.filter { $0["status"] == "completed" }.count)</div>
            </div>
            <div class="stat-card">
                <h3>In Progress</h3>
                <div class="stat-number">\(tasks.filter { $0["status"] == "in-progress" }.count)</div>
            </div>
            <div class="stat-card">
                <h3>High Priority</h3>
                <div class="stat-number">\(tasks.filter { $0["priority"] == "high" }.count)</div>
            </div>
        """

        let recentTasks = document.createElement("div")
        recentTasks.className = "recent-tasks"
        recentTasks.innerHTML = """
            <h2>Recent Tasks</h2>
            <div class="task-list">
                \(renderTaskList(limit: 3))
            </div>
        """

        dashboard.appendChild(stats)
        dashboard.appendChild(recentTasks)
        container.appendChild(dashboard)
    }

    private func renderTasks(_ container: JSObject) {
        let tasksView = document.createElement("div")
        tasksView.className = "tasks-view"

        let header = document.createElement("div")
        header.className = "tasks-header"
        header.innerHTML = """
            <h2>All Tasks</h2>
            <button id="add-task-btn" class="btn-primary">+ Add Task</button>
        """

        let taskList = document.createElement("div")
        taskList.className = "task-list full-list"
        taskList.innerHTML = renderTaskList(limit: nil)

        tasksView.appendChild(header)
        tasksView.appendChild(taskList)
        container.appendChild(tasksView)

        // Add task button listener
        if let addBtn = document.getElementById("add-task-btn").object {
            _ = addBtn.addEventListener("click", JSClosure { [weak self] _ in
                self?.showAddTaskDialog()
                return .undefined
            })
        }
    }

    private func renderCalendar(_ container: JSObject) {
        let calendar = document.createElement("div")
        calendar.className = "calendar-view"
        calendar.innerHTML = """
            <h2>Calendar View</h2>
            <div class="calendar-placeholder">
                <p>📅 Calendar integration coming soon!</p>
                <p>Upcoming deadlines:</p>
                <ul>
                    \(tasks.filter { $0["status"] != "completed" }.map { task in
                        "<li>\(task["title"] ?? "") - Due: \(task["dueDate"] ?? "")</li>"
                    }.joined(separator: ""))
                </ul>
            </div>
        """
        container.appendChild(calendar)
    }

    private func renderSettings(_ container: JSObject) {
        let settings = document.createElement("div")
        settings.className = "settings-view"
        settings.innerHTML = """
            <h2>Settings</h2>
            <div class="settings-section">
                <h3>App Preferences</h3>
                <div class="setting-item">
                    <label>Theme:</label>
                    <select id="theme-select">
                        <option value="light">Light</option>
                        <option value="dark">Dark</option>
                        <option value="auto">Auto</option>
                    </select>
                </div>
                <div class="setting-item">
                    <label>Notifications:</label>
                    <input type="checkbox" id="notifications-toggle" checked>
                </div>
            </div>
            <div class="settings-section">
                <h3>About</h3>
                <p>PlannerApp Web v1.0.0</p>
                <p>Built with SwiftWasm</p>
            </div>
        """
        container.appendChild(settings)
    }

    private func renderTaskList(limit: Int?) -> String {
        let displayTasks = limit.map { tasks.prefix($0) } ?? tasks

        return displayTasks.map { task in
            let priorityClass = "priority-\(task["priority"] ?? "medium")"
            let statusClass = "status-\(task["status"] ?? "pending")"

            return """
            <div class="task-item \(priorityClass) \(statusClass)">
                <div class="task-info">
                    <h4>\(task["title"] ?? "")</h4>
                    <div class="task-meta">
                        <span class="priority">\(task["priority"]?.capitalized ?? "")</span>
                        <span class="due-date">Due: \(task["dueDate"] ?? "")</span>
                    </div>
                </div>
                <div class="task-status">
                    <span class="status-badge">\(task["status"]?.replacingOccurrences(of: "-", with: " ").capitalized ?? "")</span>
                </div>
            </div>
            """
        }.joined(separator: "")
    }

    private func showAddTaskDialog() {
        console.log("Add task dialog - feature coming soon!")
    }
}

// Initialize the app when DOM is loaded
_ = JSObject.global.addEventListener("DOMContentLoaded", JSClosure { _ in
    let _ = PlannerAppWeb()
    return .undefined
})
