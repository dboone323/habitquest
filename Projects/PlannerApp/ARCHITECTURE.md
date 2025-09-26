# PlannerApp Architecture Documentation

## Overview

PlannerApp is a comprehensive productivity and planning application built with SwiftUI and CloudKit integration. The application provides task management, goal tracking, calendar events, and journal entries in a unified dashboard experience with cross-device synchronization capabilities.

## System Architecture

### Core Components

```
PlannerApp/
├── PlannerApp/                         # Main app bundle
│   ├── ContentView.swift              # Primary app interface
│   ├── Assets.xcassets/               # App assets and icons
│   └── PlannerApp.entitlements        # App capabilities and permissions
├── Models/                            # Data models and entities
│   ├── Task.swift                     # Task management model
│   ├── Goal.swift                     # Goal tracking model
│   ├── CalendarEvent.swift            # Calendar event model
│   ├── JournalEntry.swift             # Journal entry model
│   └── DataManagers.swift             # Data persistence layer
├── ViewModels/                        # Business logic layer
│   └── DashboardViewModel.swift       # Dashboard orchestration
├── Views/                             # UI components and screens
│   ├── Tasks/                         # Task management views
│   ├── Goals/                         # Goal tracking views
│   ├── Calendar/                      # Calendar and event views
│   ├── Journal/                       # Journal entry views
│   └── Settings/                      # App configuration
├── Components/                        # Reusable UI components
├── DataManagers/                      # Data persistence services
├── ViewModels/                        # MVVM business logic
├── CloudKit/                          # Cloud synchronization
├── Accessibility/                     # Accessibility implementations
├── Platform/                          # Platform-specific code
├── Styling/                           # Design system and themes
└── Utilities/                         # Helper utilities and extensions
```

## Architecture Patterns

### MVVM Implementation

```swift
// ViewModel: Business logic and data orchestration
@MainActor
class DashboardViewModel: ObservableObject {
    // Published properties for reactive UI updates
    @Published var todaysEvents: [CalendarEvent] = []
    @Published var incompleteTasks: [Task] = []
    @Published var upcomingGoals: [Goal] = []
    @Published var recentActivities: [DashboardActivity] = []

    // User preferences integration
    @AppStorage(AppSettingKeys.dashboardItemLimit)
    private var dashboardItemLimit: Int = 3

    // Data fetching and filtering
    func fetchDashboardData() {
        let allEvents = CalendarDataManager.shared.load()
        let allTasks = TaskDataManager.shared.load()
        let allGoals = GoalDataManager.shared.load()

        // Apply intelligent filtering and sorting
        applyDataFiltering(events: allEvents, tasks: allTasks, goals: allGoals)
    }

    // Async data refresh for modern UI patterns
    @MainActor
    func refreshData() async {
        fetchDashboardData()
        updateQuickStats()
        generateRecentActivities()
        generateUpcomingItems()
    }
}
```

### Data Models with CloudKit Integration

#### Task Model

```swift
struct Task: Identifiable, Codable, Transferable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var createdAt: Date
    var modifiedAt: Date? // CloudKit sync support

    // CloudKit conversion methods
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Task", recordID: CKRecord.ID(recordName: id.uuidString))
        record["title"] = title
        record["description"] = description
        record["isCompleted"] = isCompleted
        record["priority"] = priority.rawValue
        record["dueDate"] = dueDate
        record["createdAt"] = createdAt
        record["modifiedAt"] = modifiedAt
        return record
    }

    static func from(ckRecord: CKRecord) throws -> Task {
        // CloudKit record conversion logic
        // Handles data validation and type conversion
    }

    // Transferable protocol for drag & drop
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}
```

#### Goal Model with Progress Tracking

```swift
struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetDate: Date
    var createdAt: Date
    var modifiedAt: Date?
    var isCompleted: Bool
    var priority: GoalPriority
    var progress: Double // 0.0 to 1.0 progress tracking

    // CloudKit synchronization
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Goal", recordID: CKRecord.ID(recordName: id.uuidString))
        record["title"] = title
        record["description"] = description
        record["targetDate"] = targetDate
        record["isCompleted"] = isCompleted
        record["priority"] = priority.rawValue
        record["progress"] = progress
        return record
    }
}
```

### Priority System

```swift
enum TaskPriority: String, CaseIterable, Codable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: 3
        case .medium: 2
        case .low: 1
        }
    }
}
```

## Data Architecture

### Data Management Layer

#### Centralized Data Managers

```swift
// Abstract base for all data managers
protocol DataManagerProtocol {
    associatedtype DataType: Identifiable & Codable

    func load() -> [DataType]
    func save(_ items: [DataType])
    func add(_ item: DataType)
    func update(_ item: DataType)
    func delete(_ item: DataType)
}

// Task-specific data management
class TaskDataManager: DataManagerProtocol, ObservableObject {
    static let shared = TaskDataManager()

    @Published private var tasks: [Task] = []
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "SavedTasks"

    func load() -> [Task] {
        if let data = userDefaults.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
        return tasks
    }

    func save(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
            self.tasks = tasks
        }
    }

    // CRUD operations with automatic persistence
    func add(_ task: Task) {
        var currentTasks = load()
        currentTasks.append(task)
        save(currentTasks)
    }

    func update(_ updatedTask: Task) {
        var currentTasks = load()
        if let index = currentTasks.firstIndex(where: { $0.id == updatedTask.id }) {
            currentTasks[index] = updatedTask
            save(currentTasks)
        }
    }

    func delete(_ taskToDelete: Task) {
        var currentTasks = load()
        currentTasks.removeAll { $0.id == taskToDelete.id }
        save(currentTasks)
    }
}
```

### CloudKit Integration Architecture

#### Synchronization Strategy

```swift
class CloudKitSyncManager: ObservableObject {
    private let container = CKContainer.default()
    private let database: CKDatabase

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?

    init() {
        self.database = container.privateCloudDatabase
    }

    // Bidirectional sync with conflict resolution
    func performSync() async {
        await MainActor.run { syncStatus = .syncing }

        do {
            // Upload local changes
            try await uploadLocalChanges()

            // Download remote changes
            try await downloadRemoteChanges()

            // Resolve conflicts
            try await resolveConflicts()

            await MainActor.run {
                syncStatus = .success
                lastSyncDate = Date()
            }
        } catch {
            await MainActor.run {
                syncStatus = .failed(error)
            }
        }
    }

    private func uploadLocalChanges() async throws {
        // Get locally modified records
        let modifiedTasks = getLocallyModifiedTasks()
        let modifiedGoals = getLocallyModifiedGoals()

        // Convert to CloudKit records
        let taskRecords = modifiedTasks.map { $0.toCKRecord() }
        let goalRecords = modifiedGoals.map { $0.toCKRecord() }

        // Batch upload
        let allRecords = taskRecords + goalRecords
        try await uploadRecords(allRecords)
    }

    private func downloadRemoteChanges() async throws {
        // Fetch changes since last sync
        let changeToken = getLastChangeToken()
        let changes = try await fetchRecordZoneChanges(since: changeToken)

        // Process downloaded records
        for record in changes.changedRecords {
            try await processDownloadedRecord(record)
        }

        // Handle deleted records
        for deletedRecordID in changes.deletedRecordIDs {
            handleDeletedRecord(deletedRecordID)
        }
    }
}

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case failed(Error)

    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.success, .success):
            return true
        case (.failed, .failed):
            return true // Simplified equality for errors
        default:
            return false
        }
    }
}
```

## User Interface Architecture

### Dashboard System

#### Modern Dashboard Implementation

```swift
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAddTask = false
    @State private var showingAddGoal = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Quick Stats Section
                    QuickStatsSection(viewModel: viewModel)

                    // Recent Activities
                    RecentActivitiesSection(activities: viewModel.recentActivities)

                    // Today's Focus
                    TodaysFocusSection(
                        events: viewModel.todaysEvents,
                        tasks: viewModel.incompleteTasks
                    )

                    // Upcoming Items
                    UpcomingSection(items: viewModel.upcomingItems)

                    // Goals Progress
                    GoalsProgressSection(goals: viewModel.upcomingGoals)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refreshData()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu("Add") {
                        Button("Task", systemImage: "plus.circle") {
                            showingAddTask = true
                        }
                        Button("Goal", systemImage: "target") {
                            showingAddGoal = true
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchDashboardData()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView()
        }
    }
}
```

#### Quick Stats Component

```swift
struct QuickStatsSection: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.primary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Tasks",
                    value: "\\(viewModel.completedTasks)/\\(viewModel.totalTasks)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Goals",
                    value: "\\(viewModel.completedGoals)/\\(viewModel.totalGoals)",
                    icon: "target",
                    color: .blue
                )

                StatCard(
                    title: "Today's Events",
                    value: "\\(viewModel.todayEvents)",
                    icon: "calendar",
                    color: .orange
                )

                StatCard(
                    title: "Completion Rate",
                    value: completionPercentage,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var completionPercentage: String {
        guard viewModel.totalTasks > 0 else { return "0%" }
        let percentage = (Double(viewModel.completedTasks) / Double(viewModel.totalTasks)) * 100
        return "\\(Int(percentage))%"
    }
}
```

### Task Management Interface

#### Task List with Advanced Features

```swift
struct TaskListView: View {
    @StateObject private var taskManager = TaskDataManager.shared
    @State private var tasks: [Task] = []
    @State private var showingCompletedTasks = false
    @State private var searchText = ""
    @State private var selectedPriority: TaskPriority?

    var filteredTasks: [Task] {
        tasks
            .filter { task in
                if !showingCompletedTasks && task.isCompleted {
                    return false
                }

                if !searchText.isEmpty && !task.title.localizedCaseInsensitiveContains(searchText) {
                    return false
                }

                if let priority = selectedPriority, task.priority != priority {
                    return false
                }

                return true
            }
            .sorted { lhs, rhs in
                // Sort by priority first, then by due date
                if lhs.priority.sortOrder != rhs.priority.sortOrder {
                    return lhs.priority.sortOrder > rhs.priority.sortOrder
                }

                switch (lhs.dueDate, rhs.dueDate) {
                case (.none, .none): return lhs.createdAt > rhs.createdAt
                case (.none, .some): return false
                case (.some, .none): return true
                case (.some(let lhsDate), .some(let rhsDate)): return lhsDate < rhsDate
                }
            }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search and filter controls
                VStack {
                    SearchBar(text: $searchText)

                    FilterControls(
                        showingCompleted: $showingCompletedTasks,
                        selectedPriority: $selectedPriority
                    )
                }
                .padding()

                // Task list
                List {
                    ForEach(filteredTasks) { task in
                        TaskRowView(
                            task: task,
                            onToggleCompletion: { toggleTaskCompletion(task) },
                            onEdit: { editTask(task) }
                        )
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteTask(task)
                            }

                            Button("Edit", systemImage: "pencil") {
                                editTask(task)
                            }
                        }
                    }
                    .onMove(perform: moveTask)
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                    Button("Add", systemImage: "plus") {
                        addNewTask()
                    }
                }
            }
        }
        .onAppear {
            loadTasks()
        }
    }

    // Task management functions
    private func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.modifiedAt = Date()
        taskManager.update(updatedTask)
        loadTasks()
    }

    private func deleteTask(_ task: Task) {
        taskManager.delete(task)
        loadTasks()
    }
}
```

## Settings and Configuration

### User Preferences Architecture

```swift
struct AppSettingKeys {
    static let dashboardItemLimit = "dashboardItemLimit"
    static let firstDayOfWeek = "firstDayOfWeek"
    static let enableNotifications = "enableNotifications"
    static let cloudSyncEnabled = "cloudSyncEnabled"
    static let themePreference = "themePreference"
    static let taskSortOrder = "taskSortOrder"
}

class SettingsManager: ObservableObject {
    @AppStorage(AppSettingKeys.dashboardItemLimit) var dashboardItemLimit: Int = 3
    @AppStorage(AppSettingKeys.firstDayOfWeek) var firstDayOfWeek: Int = 1
    @AppStorage(AppSettingKeys.enableNotifications) var notificationsEnabled: Bool = true
    @AppStorage(AppSettingKeys.cloudSyncEnabled) var cloudSyncEnabled: Bool = false
    @AppStorage(AppSettingKeys.themePreference) var themePreference: String = "system"

    // Validation and business logic for settings
    func validateDashboardLimit(_ newValue: Int) -> Int {
        return max(1, min(10, newValue)) // Limit between 1-10 items
    }

    func updateDashboardLimit(_ newValue: Int) {
        dashboardItemLimit = validateDashboardLimit(newValue)
        NotificationCenter.default.post(name: .settingsChanged, object: nil)
    }
}

struct SettingsView: View {
    @StateObject private var settings = SettingsManager()
    @StateObject private var cloudSyncManager = CloudKitSyncManager()

    var body: some View {
        NavigationView {
            Form {
                Section("Dashboard") {
                    Stepper("Items to show: \\(settings.dashboardItemLimit)",
                           value: $settings.dashboardItemLimit,
                           in: 1...10)

                    Picker("First day of week", selection: $settings.firstDayOfWeek) {
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                    }
                }

                Section("Sync & Data") {
                    Toggle("Enable CloudKit Sync", isOn: $settings.cloudSyncEnabled)

                    if settings.cloudSyncEnabled {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            if let lastSync = cloudSyncManager.lastSyncDate {
                                Text(lastSync, style: .relative)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Never")
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button("Sync Now") {
                            Task {
                                await cloudSyncManager.performSync()
                            }
                        }
                        .disabled(cloudSyncManager.syncStatus == .syncing)
                    }
                }

                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)
                }

                Section("Appearance") {
                    Picker("Theme", selection: $settings.themePreference) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

## Performance and Optimization

### Data Loading Optimization

#### Lazy Loading Strategy

```swift
class OptimizedDataManager {
    private var cachedData: [String: Any] = [:]
    private let cacheQueue = DispatchQueue(label: "data.cache", qos: .utility)

    func loadDataWithCaching<T: Codable>(
        key: String,
        type: T.Type,
        loader: () -> [T]
    ) -> [T] {
        return cacheQueue.sync {
            if let cachedData = cachedData[key] as? [T] {
                return cachedData
            }

            let freshData = loader()
            cachedData[key] = freshData
            return freshData
        }
    }

    func invalidateCache(for key: String) {
        cacheQueue.async {
            self.cachedData.removeValue(forKey: key)
        }
    }
}
```

#### Pagination Implementation

```swift
struct PaginatedListView<T: Identifiable>: View {
    let items: [T]
    let loadMore: () -> Void
    let itemView: (T) -> AnyView

    @State private var displayedItems: [T] = []
    @State private var currentPage = 0
    private let itemsPerPage = 20

    var body: some View {
        List {
            ForEach(displayedItems, id: \\.id) { item in
                itemView(item)
                    .onAppear {
                        if item.id == displayedItems.last?.id {
                            loadNextPage()
                        }
                    }
            }

            if displayedItems.count < items.count {
                ProgressView("Loading more...")
                    .onAppear {
                        loadNextPage()
                    }
            }
        }
        .onAppear {
            loadInitialItems()
        }
    }

    private func loadInitialItems() {
        displayedItems = Array(items.prefix(itemsPerPage))
        currentPage = 1
    }

    private func loadNextPage() {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, items.count)

        if startIndex < items.count {
            let newItems = Array(items[startIndex..<endIndex])
            displayedItems.append(contentsOf: newItems)
            currentPage += 1
        }
    }
}
```

## Accessibility Implementation

### VoiceOver Support

```swift
struct AccessibleTaskRow: View {
    let task: Task
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .accessibilityLabel(task.isCompleted ? "Completed" : "Not completed")
            .accessibilityHint("Double tap to toggle completion status")

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)

                if let dueDate = task.dueDate {
                    Text("Due \\(dueDate, formatter: DateFormatter.shortDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            PriorityIndicator(priority: task.priority)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\\(task.title), priority \\(task.priority.displayName)")
        .accessibilityValue(task.isCompleted ? "Completed" : "Incomplete")
        .accessibilityHint("Task item, double tap to toggle completion")
    }
}
```

## Future Architecture Plans

### Roadmap

1. **AI Integration**
   - Smart task prioritization based on user behavior
   - Automatic goal progress tracking
   - Predictive deadline suggestions

2. **Advanced Collaboration**
   - Shared goals and projects
   - Team task assignments
   - Real-time collaboration features

3. **Analytics and Insights**
   - Productivity analytics dashboard
   - Goal achievement patterns
   - Time tracking integration

4. **Extended Platform Support**
   - Apple Watch complications
   - macOS menu bar integration
   - Siri Shortcuts expansion

### Scalability Considerations

- **Modular Architecture**: Feature-based module organization
- **Plugin System**: Third-party integration capabilities
- **API-First Design**: RESTful APIs for external service integration
- **Microservices Ready**: Cloud-based service decomposition support

---

_Architecture Documentation Last Updated: September 12, 2025_
_PlannerApp Version: 1.0_
_Platforms: iOS 17.0+, macOS 14.0+, watchOS 10.0+_
