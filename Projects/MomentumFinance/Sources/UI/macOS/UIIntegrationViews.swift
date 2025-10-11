// MARK: - Main macOS Content View with Integration

/// Main macOS content view with integrated navigation
struct IntegratedMacOSContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var searchText = ""
    @State private var isSearching = false

    // Binding to sidebar selection that updates the NavigationCoordinator
    private var selectedSidebarItemBinding: Binding<SidebarItem?> {
        Binding(
            get: { self.navigationCoordinator.selectedSidebarItem },
            set: {
                self.navigationCoordinator.selectedSidebarItem = $0
                // Clear detail selection when changing main navigation
                self.navigationCoordinator.clearDetailSelection()
            },
        )
    }

    // Binding to list item selection that updates the NavigationCoordinator
    private var selectedListItemBinding: Binding<ListableItem?> {
        Binding(
            get: { self.navigationCoordinator.selectedListItem },
            set: { self.navigationCoordinator.navigateToDetail(item: $0) },
        )
    }

    // Binding to column visibility that updates the NavigationCoordinator
    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { self.navigationCoordinator.columnVisibility },
            set: { self.navigationCoordinator.columnVisibility = $0 },
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: self.columnVisibilityBinding) {
            // Sidebar column with main navigation
            self.sidebar
                .frame(minWidth: 220)
        } content: {
            // Content column - list of items for the selected category
            self.contentList
                .frame(minWidth: 300)
        } detail: {
            // Detail view for the selected item
            self.detailView
                .frame(minWidth: 450)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 700)
        .macOSOptimizations()
        .withMacOSKeyboardShortcuts()
        .onAppear {
            macOSSpecificViews.configureWindow()
            // Register keyboard shortcuts
            KeyboardShortcutManager.shared.registerGlobalShortcuts()
            // Setup notification handlers
            self.setupNotificationHandlers()
        }
    }

    // MARK: - Sidebar View

    private var sidebar: some View {
        List(selection: self.selectedSidebarItemBinding) {
            Section("Main") {
                self.sidebarItem(title: "Dashboard", icon: "house", item: .dashboard)
                self.sidebarItem(title: "Transactions", icon: "creditcard", item: .transactions)
                self.sidebarItem(title: "Budgets", icon: "chart.pie", item: .budgets)
            }

            Section("Planning") {
                self.sidebarItem(title: "Subscriptions", icon: "calendar.badge.clock", item: .subscriptions)
                self.sidebarItem(title: "Goals & Reports", icon: "chart.bar", item: .goalsAndReports)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: self.toggleSidebar).accessibilityLabel("Button").accessibilityLabel("Button") {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }

    private func sidebarItem(title: String, icon: String, item: SidebarItem) -> some View {
        Label(title, systemImage: self.navigationCoordinator.selectedSidebarItem == item ? "\(icon).fill" : icon)
            .tag(item)
    }

    private func toggleSidebar() {
        self.navigationCoordinator.toggleSidebar()
    }

    // MARK: - Content List View

    private var contentList: some View {
        Group {
            switch self.navigationCoordinator.selectedSidebarItem {
            case .dashboard:
                DashboardListView()
                    .environmentObject(self.navigationCoordinator)
            case .transactions:
                TransactionsListView()
                    .environmentObject(self.navigationCoordinator)
            case .budgets:
                BudgetListView()
                    .environmentObject(self.navigationCoordinator)
            case .subscriptions:
                SubscriptionListView()
                    .environmentObject(self.navigationCoordinator)
            case .goalsAndReports:
                GoalsListView()
                    .environmentObject(self.navigationCoordinator)
            case .none:
                EmptyView()
            }
        }
        .searchable(text: self.$searchText, placement: .toolbar, prompt: "Search")
        .onSubmit(of: .search) {
            self.performSearch()
        }
    }

    private func performSearch() {
        guard !self.searchText.isEmpty else { return }
        self.navigationCoordinator.searchQuery = self.searchText
        self.navigationCoordinator.isSearchActive = true
        self.isSearching = true
    }

    // MARK: - Detail View

    private var detailView: some View {
        Group {
            if let listItem = navigationCoordinator.selectedListItem {
                switch listItem.type {
                case .account:
                    if let id = listItem.id {
                        EnhancedAccountDetailView(accountId: id)
                            .id(listItem.id)
                    }
                case .transaction:
                    if let id = listItem.id {
                        Features.Transactions.EnhancedTransactionDetailView(transactionId: id)
                            .id(listItem.id)
                    }
                case .budget:
                    if let id = listItem.id {
                        Features.Budgets.EnhancedBudgetDetailView(budgetId: id)
                            .id(listItem.id)
                    }
                case .subscription:
                    if let id = listItem.id {
                        Features.Subscriptions.EnhancedSubscriptionDetailView(subscriptionId: id)
                            .id(listItem.id)
                    }
                case .goal:
                    if let id = listItem.id {
                        EnhancedGoalDetailView(goalId: id)
                            .id(listItem.id)
                    }
                case .report:
                    if let id = listItem.id {
                        EnhancedReportDetailView(reportType: id)
                            .id(listItem.id)
                    }
                }
            } else {
                // Default view when no item is selected
                switch self.navigationCoordinator.selectedSidebarItem {
                case .dashboard:
                    Features.FinancialDashboard.DashboardView()
                case .transactions:
                    TransactionsOverviewView()
                case .budgets:
                    BudgetsOverviewView()
                case .subscriptions:
                    SubscriptionsOverviewView()
                case .goalsAndReports:
                    GoalsAndReportsOverviewView()
                case .none:
                    WelcomeView()
                }
            }
        }
    }

    // MARK: - Notification Handlers

    private func setupNotificationHandlers() {
        // Setup notification handlers for keyboard shortcut actions
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowDashboard"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .dashboard
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowTransactions"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .transactions
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowBudgets"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .budgets
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowSubscriptions"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .subscriptions
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowGoalsAndReports"), object: nil, queue: .main) { _ in
            self.navigationCoordinator.selectedSidebarItem = .goalsAndReports
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("ToggleSidebar"), object: nil, queue: .main) { _ in
            self.toggleSidebar()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("PerformGlobalSearch"), object: nil, queue: .main) { _ in
            self.isSearching = true
        }
    }
}
