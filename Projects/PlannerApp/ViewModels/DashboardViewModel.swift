// PlannerApp/ViewModels/DashboardViewModel.swift (Updated)
import Combine
import Foundation
import SwiftUI // Needed for @AppStorage

// MARK: - Shared View Model Protocol

/// Protocol for standardized MVVM pattern across all projects
/// Supports both ObservableObject and @Observable patterns for maximum compatibility
@MainActor
public protocol BaseViewModel: AnyObject {
    associatedtype State
    associatedtype Action

    var state: State { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    func handle(_ action: Action) async
    func resetError()
    func validateState() -> Bool
}

extension BaseViewModel {
    public func resetError() {
        errorMessage = nil
    }

    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }

    public func setError(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    public func setError(_ message: String) {
        errorMessage = message
    }

    public func validateState() -> Bool {
        // Default implementation - override in subclasses for specific validation
        true
    }

    /// Convenience method for synchronous actions
    func handle(_ action: Action) {
        Task {
            await handle(action)
        }
    }
}

// MARK: - AI Dashboard Types

public struct AISuggestion: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String
    let reasoning: String
    let priority: Int
    let urgency: String
    let suggestedTime: String?
    let icon: String
    let color: Color
}

public struct DashboardActivity: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let timestamp: Date
}

public struct UpcomingItem: Identifiable {
    public let id = UUID()
    let title: String
    let subtitle: String?
    let date: Date
    let icon: String
    let color: Color
}

// ObservableObject makes this class publish changes to its @Published properties.
@MainActor
public class DashboardViewModel: BaseViewModel, ObservableObject {
    // MARK: - State and Action Types for BaseViewModel

    public struct State {
        var todaysEvents: [CalendarEvent] = []
        var incompleteTasks: [PlannerTask] = []
        var upcomingGoals: [Goal] = []
        var totalTodaysEventsCount: Int = 0
        var totalIncompleteTasksCount: Int = 0
        var totalUpcomingGoalsCount: Int = 0
        var recentActivities: [DashboardActivity] = []
        var upcomingItems: [UpcomingItem] = []
        var aiSuggestions: [AISuggestion] = []
        var productivityInsights: [ProductivityInsight] = []
        var allGoals: [Goal] = []
        var allEvents: [CalendarEvent] = []
        var allJournalEntries: [JournalEntry] = []
        var totalTasks: Int = 0
        var completedTasks: Int = 0
        var totalGoals: Int = 0
        var completedGoals: Int = 0
        var todayEvents: Int = 0
    }

    public enum Action {
        case fetchDashboardData
        case refreshData
        case updateQuickStats
        case generateRecentActivities
        case generateUpcomingItems
        case resetData
    }

    public var state = State()
    public var isLoading = false
    public var errorMessage: String?

    // MARK: - BaseViewModel Protocol Implementation

    public func handle(_ action: Action) async {
        switch action {
        case .fetchDashboardData:
            fetchDashboardData()
        case .refreshData:
            await refreshData()
        case .updateQuickStats:
            updateQuickStats()
        case .generateRecentActivities:
            generateRecentActivities()
        case .generateUpcomingItems:
            generateUpcomingItems()
        case .resetData:
            resetData()
        }
    }

    // --- Published Properties for View Updates ---
    // These arrays hold the data to be displayed on the dashboard, limited by user settings.
    @Published public var todaysEvents: [CalendarEvent] = []
    @Published public var incompleteTasks: [PlannerTask] = []
    @Published public var upcomingGoals: [Goal] = []

    // These hold the *total* counts before the limit is applied.
    // Useful for displaying accurate "...and X more" messages.
    @Published public var totalTodaysEventsCount: Int = 0
    @Published public var totalIncompleteTasksCount: Int = 0
    @Published public var totalUpcomingGoalsCount: Int = 0

    // Modern Dashboard Properties
    @Published public var recentActivities: [DashboardActivity] = []
    @Published public var upcomingItems: [UpcomingItem] = []
    @Published public var aiSuggestions: [AISuggestion] = []
    @Published public var productivityInsights: [ProductivityInsight] = []

    // Full data arrays for Add* views to bind to
    @Published public var allGoals: [Goal] = []
    @Published public var allEvents: [CalendarEvent] = []
    @Published public var allJournalEntries: [JournalEntry] = []

    // Quick Stats Properties
    @Published public var totalTasks: Int = 0
    @Published public var completedTasks: Int = 0
    @Published public var totalGoals: Int = 0
    @Published public var completedGoals: Int = 0
    @Published public var todayEvents: Int = 0

    // AI Service
    private let aiService = AITaskPrioritizationService.shared

    // Performance Optimization: Data Caching
    private struct CachedData<T> {
        let data: T
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    private var cachedTasks: CachedData<[PlannerTask]>?
    private var cachedGoals: CachedData<[Goal]>?
    private var cachedEvents: CachedData<[CalendarEvent]>?
    private var cachedJournalEntries: CachedData<[JournalEntry]>?

    private let dataCacheTTL: TimeInterval = 60 // 1 minute for data cache

    // AI Caching
    private var lastAISuggestionsUpdate: Date?
    private var lastProductivityInsightsUpdate: Date?
    private let aiCacheTimeout: TimeInterval = 300 // 5 minutes

    // Performance Optimization: Debouncing
    private var refreshWorkItem: DispatchWorkItem?
    private let debounceDelay: TimeInterval = 0.3 // 300ms debounce

    // Performance Optimization: Background Processing
    private let dataProcessingQueue = DispatchQueue(label: "com.plannerapp.dashboard.data", qos: .userInitiated)

    // --- AppStorage Links ---
    // Read settings directly from UserDefaults using @AppStorage.
    // The view model automatically uses the latest setting value.
    @AppStorage(AppSettingKeys.dashboardItemLimit) private var dashboardItemLimit: Int = 3 // Default limit
    @AppStorage(AppSettingKeys.firstDayOfWeek) private var firstDayOfWeekSetting: Int = Calendar.current.firstWeekday

    // --- Data Fetching and Filtering ---
    // This function loads data from managers, filters it based on dates/status,
    // applies the user's limit, and updates the @Published properties.
    @MainActor
    func fetchDashboardData() {
        print("Fetching dashboard data...") // Debugging log

        // Load all data from the respective data managers.
        let allEvents = CalendarDataManager.shared.load()
        let allTasks = TaskDataManager.shared.load()
        let allGoals = GoalDataManager.shared.load()

        // Get the current calendar and configure it with the user's setting for the first day of the week.
        var calendar = Calendar.current
        calendar.firstWeekday = self.firstDayOfWeekSetting

        // Calculate date ranges needed for filtering (today, next week).
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        // Use guard to safely unwrap optional dates. If calculation fails, reset data.
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfToday)
        else {
            print("Error calculating date ranges for dashboard.")
            self.resetData() // Clear displayed data if dates are invalid
            return
        }

        // --- Filter Data ---
        // Filter events happening today.
        let todaysEventsFiltered = allEvents.filter { event in
            event.date >= startOfToday && event.date < endOfToday
        }
        let filteredTodaysEvents = todaysEventsFiltered.sorted(by: { $0.date < $1.date }) // Sort today's events by time

        // Filter tasks that are not completed.
        let filteredIncompleteTasks = allTasks.filter { !$0.isCompleted }
        // .sorted(...) // Optional: Add sorting if needed

        // Filter goals due between today and the end of the next 7 days.
        let upcomingGoalsFiltered = allGoals.filter { goal in
            // Compare using the start of the day for the goal's target date for consistency.
            let goalTargetStartOfDay = calendar.startOfDay(for: goal.targetDate)
            return goalTargetStartOfDay >= startOfToday && goalTargetStartOfDay < endOfWeek
        }
        let filteredUpcomingGoals = upcomingGoalsFiltered
            .sorted(by: { $0.targetDate < $1.targetDate }) // Sort upcoming goals by target date

        // --- Update State ---
        // Store the counts *before* applying the display limit.
        self.state.totalTodaysEventsCount = filteredTodaysEvents.count
        self.state.totalIncompleteTasksCount = filteredIncompleteTasks.count
        self.state.totalUpcomingGoalsCount = filteredUpcomingGoals.count

        // Store complete arrays for Add* views to bind to
        self.state.allEvents = allEvents
        self.state.allGoals = allGoals
        // Load journal entries
        self.state.allJournalEntries = JournalDataManager.shared.load()

        // --- Apply Limit and Update Published Arrays ---
        // Get the current limit value from @AppStorage.
        let limit = self.dashboardItemLimit
        // Take only the first `limit` items from each filtered array.
        self.state.todaysEvents = Array(filteredTodaysEvents.prefix(limit))
        self.state.incompleteTasks = Array(filteredIncompleteTasks.prefix(limit))
        self.state.upcomingGoals = Array(filteredUpcomingGoals.prefix(limit))

        // Update @Published properties for backward compatibility
        self.todaysEvents = self.state.todaysEvents
        self.incompleteTasks = self.state.incompleteTasks
        self.upcomingGoals = self.state.upcomingGoals
        self.totalTodaysEventsCount = self.state.totalTodaysEventsCount
        self.totalIncompleteTasksCount = self.state.totalIncompleteTasksCount
        self.totalUpcomingGoalsCount = self.state.totalUpcomingGoalsCount
        self.allEvents = self.state.allEvents
        self.allGoals = self.state.allGoals
        self.allJournalEntries = self.state.allJournalEntries

        print(
            "Dashboard data fetched. Limit: \(limit). Today: \(self.state.totalTodaysEventsCount), Tasks: \(self.state.totalIncompleteTasksCount), Goals: \(self.state.totalUpcomingGoalsCount)"
        ) // Debugging log
    }

    // New method for modern dashboard
    @MainActor
    func refreshData() async {
        // Call existing method
        self.fetchDashboardData()

        // Update quick stats
        self.updateQuickStats()

        // Generate recent activities
        self.generateRecentActivities()

        // Generate upcoming items
        self.generateUpcomingItems()

        print("Dashboard refresh completed") // Debugging log
    }

    @MainActor
    private func updateQuickStats() {
        let allTasks = TaskDataManager.shared.load()
        let allGoals = GoalDataManager.shared.load()

        self.state.totalTasks = allTasks.count
        self.state.completedTasks = allTasks.count(where: { $0.isCompleted })
        self.state.totalGoals = allGoals.count
        self.state.completedGoals = 0 // Goal completion not yet implemented
        self.state.todayEvents = self.state.totalTodaysEventsCount

        // Update @Published properties for backward compatibility
        self.totalTasks = self.state.totalTasks
        self.completedTasks = self.state.completedTasks
        self.totalGoals = self.state.totalGoals
        self.completedGoals = self.state.completedGoals
        self.todayEvents = self.state.todayEvents
    }

    @MainActor
    private func generateRecentActivities() {
        var activities: [DashboardActivity] = []

        // Add completed tasks from last few days
        let allTasks = TaskDataManager.shared.load()
        let completedTasksFilter = allTasks.filter { task in
            // Only include tasks that are actually completed AND were created or completed recently
            task.isCompleted &&
                (Calendar.current.isDateInYesterday(task.createdAt) ||
                    Calendar.current.isDateInToday(task.createdAt)
                )
        }
        let recentCompletedTasks = completedTasksFilter.prefix(3)

        for task in recentCompletedTasks {
            activities.append(DashboardActivity(
                title: "Completed Task",
                subtitle: task.title,
                icon: "checkmark.circle.fill",
                color: .green,
                timestamp: task.createdAt
            ))
        }

        // Add recent events
        let allEvents = CalendarDataManager.shared.load()
        let recentEventsFilter = allEvents.filter { event in
            Calendar.current.isDateInYesterday(event.date) || Calendar.current.isDateInToday(event.date)
        }
        let recentEvents = recentEventsFilter.prefix(2)

        for event in recentEvents {
            activities.append(DashboardActivity(
                title: "Event",
                subtitle: event.title,
                icon: "calendar",
                color: .orange,
                timestamp: event.date
            ))
        }

        self.state.recentActivities = activities.sorted { $0.timestamp > $1.timestamp }

        // Update @Published property for backward compatibility
        self.recentActivities = self.state.recentActivities
    }

    @MainActor
    private func generateUpcomingItems() {
        var items: [UpcomingItem] = []

        // Add upcoming events
        let allEvents = CalendarDataManager.shared.load()
        let futureEventsFilter = allEvents.filter { $0.date > Date() }
        let futureEvents = futureEventsFilter.prefix(3)

        for event in futureEvents {
            items.append(UpcomingItem(
                title: event.title,
                subtitle: "Event",
                date: event.date,
                icon: "calendar",
                color: .orange
            ))
        }

        // Add upcoming goals
        let allGoals = GoalDataManager.shared.load()
        let futureGoals = allGoals.filter { $0.targetDate > Date() }.prefix(2)

        for goal in futureGoals {
            items.append(UpcomingItem(
                title: goal.title,
                subtitle: "Goal deadline",
                date: goal.targetDate,
                icon: "target",
                color: .green
            ))
        }

        self.state.upcomingItems = items.sorted { $0.date < $1.date }

        // Update @Published property for backward compatibility
        self.upcomingItems = self.state.upcomingItems
    }

    // Helper function to clear all published data, typically used on error.
    private func resetData() {
        // Reset state
        self.state = State()

        // Reset @Published properties for backward compatibility
        self.todaysEvents = []
        self.incompleteTasks = []
        self.upcomingGoals = []
        self.totalTodaysEventsCount = 0
        self.totalIncompleteTasksCount = 0
        self.totalUpcomingGoalsCount = 0

        // Reset modern dashboard data
        self.recentActivities = []
        self.upcomingItems = []

        // Reset full data arrays
        self.allGoals = []
        self.allEvents = []
        self.allJournalEntries = []

        self.totalTasks = 0
        self.completedTasks = 0
        self.totalGoals = 0
        self.completedGoals = 0
        self.todayEvents = 0

        print("Dashboard data reset.") // Debugging log
    }
}
