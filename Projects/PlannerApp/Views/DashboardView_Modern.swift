import _Concurrency
import Foundation

// PlannerApp/MainApp/DashboardView.swift (Modern Enhanced Version)
import SwiftUI

public struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = DashboardViewModel()
    // Avoid @AppStorage during testing to prevent UserDefaults access crashes
    private var userName: String {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        return isTesting ? "" : UserDefaults.standard.string(forKey: AppSettingKeys.userName) ?? ""
    }

    private var use24HourTime: Bool {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        return isTesting ? false : UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    }

    private var dashboardItemLimit: Int {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let value = isTesting ? 3 : UserDefaults.standard.integer(forKey: AppSettingKeys.dashboardItemLimit)
        return value == 0 ? 3 : value
    }

    // Loading and refresh state
    @State private var isRefreshing = false
    @State private var showLoadingOverlay = false

    // Navigation state for quick actions
    @State private var showAddTask = false
    @State private var showAddGoal = false
    @State private var showAddEvent = false
    @State private var showAddJournal = false

    // Date formatters
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

    var body: some View {
        NavigationStack {
            ScrollView {
                #if os(iOS)
                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                    await self.refreshDataWithDelay()
                }
                #endif

                LazyVStack(spacing: 20) {
                    // Welcome Header
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

                    // Quick Stats Row
                    HStack(spacing: 16) {
                        QuickStatCard(
                            title: "Tasks",
                            value: "\(self.viewModel.totalTasks)",
                            subtitle: "\(self.viewModel.completedTasks) completed",
                            icon: "checkmark.circle.fill",
                            color: self.themeManager.currentTheme.primaryAccentColor
                        )

                        QuickStatCard(
                            title: "Goals",
                            value: "\(self.viewModel.totalGoals)",
                            subtitle: "\(self.viewModel.completedGoals) achieved",
                            icon: "target",
                            color: .green
                        )

                        QuickStatCard(
                            title: "Events",
                            value: "\(self.viewModel.todayEvents)",
                            subtitle: "today",
                            icon: "calendar",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 24)

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Quick Actions")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            Spacer()
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            QuickActionCard(
                                title: "Add Task",
                                icon: "plus.circle.fill",
                                color: self.themeManager.currentTheme.primaryAccentColor
                            ) {
                                self.handleQuickAction(.addTask)
                            }

                            QuickActionCard(
                                title: "New Goal",
                                icon: "target",
                                color: .green
                            ) {
                                self.handleQuickAction(.addGoal)
                            }

                            QuickActionCard(
                                title: "Schedule Event",
                                icon: "calendar.badge.plus",
                                color: .orange
                            ) {
                                self.handleQuickAction(.addEvent)
                            }

                            QuickActionCard(
                                title: "Journal Entry",
                                icon: "book.fill",
                                color: .purple
                            ) {
                                self.handleQuickAction(.addJournal)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Recent Activities
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Activities")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                            Spacer()

                            Button("View All").accessibilityLabel("Button").accessibilityLabel("Button") {
                                /// - Pending: Navigate to activities view
                                print("View All tapped")
                            }
                            .font(.caption)
                            .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(self.viewModel.recentActivities.prefix(self.dashboardItemLimit), id: \.id) { activity in
                                ActivityRowView(activity: activity)
                            }

                            if self.viewModel.recentActivities.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 40))
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("No recent activities")
                                        .font(.subheadline)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("Start by creating a task or goal!")
                                        .font(.caption)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Upcoming Items
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Upcoming")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                            Spacer()

                            Button("View Calendar").accessibilityLabel("Button").accessibilityLabel("Button") {
                                /// - Pending: Navigate to calendar
                                print("View Calendar tapped")
                            }
                            .font(.caption)
                            .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(self.viewModel.upcomingItems.prefix(self.dashboardItemLimit), id: \.id) { item in
                                UpcomingItemView(item: item)
                            }

                            if self.viewModel.upcomingItems.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 40))
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("Nothing upcoming")
                                        .font(.subheadline)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                                    Text("Schedule some events to see them here")
                                        .font(.caption)
                                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Bottom spacing
                    Color.clear.frame(height: 40)
                }
            }
            #if os(iOS)
            .coordinateSpace(name: "pullToRefresh")
            #endif
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Dashboard")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .overlay(
                    Group {
                        if self.showLoadingOverlay {
                            ZStack {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()

                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .tint(self.themeManager.currentTheme.primaryAccentColor)

                                    Text("Refreshing...")
                                        .font(.subheadline)
                                        .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                                }
                                .padding(32)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                    }
                )
        }
        .onAppear {
            _Concurrency.Task { @MainActor in
                await self.refreshData()
            }
        }
        .sheet(isPresented: self.$showAddTask) {
            TaskManagerView()
                .environmentObject(self.themeManager)
        }
        .sheet(isPresented: self.$showAddGoal) {
            AddGoalView(goals: self.$viewModel.allGoals)
                .environmentObject(self.themeManager)
        }
        .sheet(isPresented: self.$showAddEvent) {
            AddCalendarEventView(events: self.$viewModel.allEvents)
                .environmentObject(self.themeManager)
        }
        .sheet(isPresented: self.$showAddJournal) {
            AddJournalEntryView(journalEntries: self.$viewModel.allJournalEntries)
                .environmentObject(self.themeManager)
        }
    }

    // MARK: - Private Methods

    enum QuickAction {
        case addTask, addGoal, addEvent, addJournal
    }

    private func handleQuickAction(_ action: QuickAction) {
        // Add haptic feedback for better UX
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif

        switch action {
        case .addTask:
            self.showAddTask = true

        case .addGoal:
            self.showAddGoal = true

        case .addEvent:
            self.showAddEvent = true

        case .addJournal:
            self.showAddJournal = true
        }
    }

    @MainActor
    private func refreshData() async {
        guard !self.isRefreshing else { return } // Prevent multiple concurrent refreshes

        self.isRefreshing = true
        self.showLoadingOverlay = true

        // Small delay to ensure UI updates are visible
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Perform data refresh asynchronously
        await self.viewModel.refreshData()

        // Small delay to ensure UI has time to update with new data
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        self.isRefreshing = false
        self.showLoadingOverlay = false
    }

    @MainActor
    private func refreshDataWithDelay() async {
        guard !self.isRefreshing else { return } // Prevent multiple concurrent refreshes

        self.showLoadingOverlay = true
        await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for demonstration
        await self.viewModel.refreshData()
        self.showLoadingOverlay = false
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
}

// MARK: - Supporting Views

public struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: self.icon)
                    .foregroundColor(self.color)
                    .font(.title3)

                Spacer()
            }

            Text(self.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Text(self.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Text(self.subtitle)
                .font(.caption2)
                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

public struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: self.action).accessibilityLabel("Button").accessibilityLabel("Button") {
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

public struct ActivityRowView: View {
    let activity: DashboardActivity
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: self.activity.icon)
                .foregroundColor(self.activity.color)
                .font(.title3)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(self.activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Text(self.activity.subtitle)
                    .font(.caption)
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
            }

            Spacer()

            Text(self.timeAgoString(from: self.activity.timestamp))
                .font(.caption2)
                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

public struct UpcomingItemView: View {
    let item: UpcomingItem
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(self.dayFormatter.string(from: self.item.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                Text(self.dayNumberFormatter.string(from: self.item.date))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
            }
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(self.item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                }

                Text(self.timeFormatter.string(from: self.item.date))
                    .font(.caption2)
                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
            }

            Spacer()

            Image(systemName: self.item.icon)
                .foregroundColor(self.item.color)
                .font(.title3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }

    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    DashboardView(selectedTabTag: .constant("Dashboard"))
        .environmentObject(ThemeManager())
}
