import _Concurrency // Explicitly import _Concurrency
import Foundation
import SwiftUI

public struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    // Binding to control which tab is selected in the parent view
    @Binding var selectedTabTag: String
    @StateObject private var viewModel = DashboardViewModel()

    // Avoid @AppStorage during testing to prevent UserDefaults access crashes
    #if DEBUG
    private var userName: String {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? "" :
        UserDefaults.standard.string(forKey: AppSettingKeys.userName) ?? ""
    }
    private var use24HourTime: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? false :
        UserDefaults.standard.bool(forKey: AppSettingKeys.use24HourTime)
    }
    private var dashboardItemLimit: Int {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ? 3 :
        UserDefaults.standard.integer(forKey: AppSettingKeys.dashboardItemLimit)
    }
    #else
    @AppStorage(AppSettingKeys.userName) private var userName: String = ""
    @AppStorage(AppSettingKeys.use24HourTime) private var use24HourTime: Bool = false
    @AppStorage(AppSettingKeys.dashboardItemLimit) private var dashboardItemLimit: Int = 3
    #endif

    // Loading and refresh state
    @State private var isRefreshing = false
    @State private var showLoadingOverlay = false

    // Navigation state for quick actions
    @State private var showAddTask = false
    @State private var showAddGoal = false
    @State private var showAddEvent = false
    @State private var showAddJournal = false
    @State private var showDemoDelay: Bool = true // Added state variable

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

    private var loadingOverlay: some View {
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
    }

    private var welcomeHeaderSection: some View {
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
                            .foregroundColor(
                                self.themeManager.currentTheme.primaryAccentColor
                            )
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

    private var quickStatsSection: some View {
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
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                Spacer()
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                spacing: 16
            ) {
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
    }

    private var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Suggestions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
            }

            if self.viewModel.aiSuggestions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "brain")
                        .font(.system(size: 40))
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.5))

                    Text("AI suggestions will appear here")
                        .font(.subheadline)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                    Text("Complete more tasks to get personalized insights")
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.7))
                }
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(self.viewModel.aiSuggestions.prefix(2), id: \.id) { suggestion in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: suggestion.icon)
                                    .foregroundColor(suggestion.color)
                                Text(suggestion.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                                Spacer()
                                Text(suggestion.urgency)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        suggestion.urgency == "High" ? Color.red.opacity(0.2) :
                                        suggestion.urgency == "Medium" ? Color.orange.opacity(0.2) :
                                        Color.green.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        suggestion.urgency == "High" ? .red :
                                        suggestion.urgency == "Medium" ? .orange :
                                        .green
                                    )
                                    .cornerRadius(8)
                            }

                            Text(suggestion.subtitle)
                                .font(.caption)
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                            Text(suggestion.reasoning)
                                .font(.caption)
                                .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.8))
                                .lineLimit(2)

                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("Suggested: \(suggestion.suggestedTime ?? "Now")")
                                    .font(.caption)
                                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.7))
                            }
                        }
                        .padding(16)
                        .background(self.themeManager.currentTheme.secondaryBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var productivityInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Productivity Insights")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                Spacer()
                Image(systemName: "chart.bar")
                    .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
            }

            if self.viewModel.productivityInsights.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.5))

                    Text("Insights will appear here")
                        .font(.subheadline)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)

                    Text("Complete tasks to see your productivity patterns")
                        .font(.caption)
                        .foregroundColor(self.themeManager.currentTheme.secondaryTextColor.opacity(0.7))
                }
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(self.viewModel.productivityInsights.prefix(2)), id: \.id) { (insight: ProductivityInsight) in
                        HStack(spacing: 12) {
                            Image(systemName: insight.icon)
                                .font(.system(size: 24))
                                .foregroundColor(self.colorForPriority(insight.priority))
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(insight.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                                Text(insight.description)
                                    .font(.caption)
                                    .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
                                    .lineLimit(2)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(self.themeManager.currentTheme.secondaryBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var upcomingItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()

                Button {
                    // Navigate to calendar tab
                    self.selectedTabTag = "Calendar"
                } label: {
                    Text("View Calendar")
                        .accessibilityLabel("Button")
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
                            .foregroundColor(
                                self.themeManager.currentTheme.secondaryTextColor
                            )

                        Text("Nothing upcoming")
                            .font(.subheadline)
                            .foregroundColor(
                                self.themeManager.currentTheme.secondaryTextColor
                            )

                        Text("Schedule some events to see them here")
                            .font(.caption)
                            .foregroundColor(
                                self.themeManager.currentTheme.secondaryTextColor
                            )
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    welcomeHeaderSection
                    quickStatsSection
                    quickActionsSection
                    aiSuggestionsSection
                    productivityInsightsSection
                    upcomingItemsSection

                    // Bottom spacing
                    Color.clear.frame(height: 40)
                }
            }
            .background(self.themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("Dashboard")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .overlay(loadingOverlay)
        }
        .onAppear {
            _Concurrency.Task { @MainActor in // Changed to _Concurrency.Task
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
        self.isRefreshing = true
        self.showLoadingOverlay = true

        // Small delay to ensure UI updates are visible
        try? await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Perform data refresh asynchronously
        await self.viewModel.refreshData()

        // Small delay to ensure UI has time to update with new data
        try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        self.isRefreshing = false
        self.showLoadingOverlay = false
    }

    @MainActor
    private func refreshDataWithDelay() async {
        self.isRefreshing = true
        self.showLoadingOverlay = true

        // Simulate a longer network call or processing
        try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Perform data refresh asynchronously
        await self.viewModel.refreshData()

        // Simulate further processing
        if self.showDemoDelay {
            // This demonstrates a longer, user-configurable delay
            print("Starting demo delay...")
            try? await _Concurrency.Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for demonstration
            print("Demo delay finished.")
        }

        self.isRefreshing = false
        self.showLoadingOverlay = false
    }

    private func colorForPriority(_ priority: ProductivityInsight.InsightPriority) -> Color {
        switch priority {
        case .high:
            return self.themeManager.currentTheme.primaryAccentColor
        case .medium:
            return self.themeManager.currentTheme.secondaryAccentColor
        case .low:
            return self.themeManager.currentTheme.secondaryTextColor
        }
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

#Preview {
    DashboardView(selectedTabTag: Binding.constant("Dashboard"))
        .environmentObject(ThemeManager())
}
