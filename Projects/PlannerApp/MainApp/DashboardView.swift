import _Concurrency // Explicitly import _Concurrency
import Foundation
import SwiftUI

public struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    // Binding to control which tab is selected in the parent view
    @Binding var selectedTabTag: String
    @StateObject private var viewModel = DashboardViewModel()
    @AppStorage(AppSettingKeys.userName) private var userName: String = ""
    @AppStorage(AppSettingKeys.use24HourTime) private var use24HourTime: Bool = false

    // This is a placeholder to keep one instance of these methods
    // The actual implementations are further down in the file

    @AppStorage(AppSettingKeys.dashboardItemLimit) private var dashboardItemLimit: Int = 3

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

    public var body: some View {
        NavigationStack {
            ScrollView {
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

                    // Upcoming Items
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

                    // Bottom spacing
                    Color.clear.frame(height: 40)
                }
            }
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
    DashboardView(selectedTabTag: .constant("Dashboard"))
        .environmentObject(ThemeManager())
}
