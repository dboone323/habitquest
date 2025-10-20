//
//  MainTabView_Enhanced.swift
//  PlannerApp
//
//  Enhanced cross-platform tab view with better iOS/macOS UX
//

import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

public struct MainTabViewEnhanced: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTabTag: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Define constants for tab tags
    enum TabTags {
        static let dashboard = "Dashboard"
        static let tasks = "Tasks"
        static let calendar = "Calendar"
        static let goals = "Goals"
        static let journal = "Journal"
        static let settings = "Settings"
    }

    // Tab configuration
    struct TabConfiguration {
        let tag: String
        let title: String
        let icon: String
        let keyboardShortcut: KeyEquivalent?

        static let allTabs = [
            TabConfiguration(
                tag: TabTags.dashboard, title: "Dashboard", icon: "house", keyboardShortcut: "1"
            ),
            TabConfiguration(
                tag: TabTags.tasks, title: "Tasks", icon: "checkmark.square", keyboardShortcut: "2"
            ),
            TabConfiguration(
                tag: TabTags.calendar, title: "Calendar", icon: "calendar", keyboardShortcut: "3"
            ),
            TabConfiguration(
                tag: TabTags.goals, title: "Goals", icon: "target", keyboardShortcut: "4"
            ),
            TabConfiguration(
                tag: TabTags.journal, title: "Journal", icon: "book", keyboardShortcut: "5"
            ),
            TabConfiguration(
                tag: TabTags.settings, title: "Settings", icon: "gear", keyboardShortcut: ","
            ),
        ]
    }

    public var body: some View {
        #if os(macOS)
            self.macOSLayout
        #elseif os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad, self.horizontalSizeClass == .regular {
                self.iPadLayout
            } else {
                self.iPhoneLayout
            }
        #endif
    }

    // MARK: - macOS Layout

    #if os(macOS)
        private var macOSLayout: some View {
            NavigationSplitView {
                self.macSidebar
            } detail: {
                self.macDetail
            }
            .navigationSplitViewStyle(.balanced)
            .background(self.themeManager.currentTheme.primaryBackgroundColor)
        }

        private var macSidebar: some View {
            List(TabConfiguration.allTabs, id: \.tag, selection: self.$selectedTabTag) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .foregroundColor(
                        self.selectedTabTag == tab.tag
                            ? self.themeManager.currentTheme.primaryAccentColor
                            : self.themeManager.currentTheme.primaryTextColor
                    )
                    .tag(tab.tag)
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200, idealWidth: 250)
            .background(self.themeManager.currentTheme.secondaryBackgroundColor)
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: self.toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                    .accessibilityLabel("Toggle Sidebar")
                    .help("Toggle Sidebar")
                }
            })
        }

        private var macDetail: some View {
            self.contentForSelectedTab
                .frame(minWidth: 600)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .primaryAction) {
                        self.macOSToolbarButtons
                    }
                })
        }
    #endif

    // MARK: - iPad Layout

    #if os(iOS)
        private var iPadLayout: some View {
            NavigationSplitView {
                List {
                    ForEach(TabConfiguration.allTabs, id: \.tag) { tab in
                        HStack {
                            Image(systemName: tab.icon)
                                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                                .frame(width: 24)

                            Text(tab.title)
                                .font(.body)
                                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .background(
                            self.selectedTabTag == tab.tag
                                ? self.themeManager.currentTheme.primaryAccentColor.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(8)
                        .onTapGesture {
                            self.selectedTabTag = tab.tag
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 280, idealWidth: 320)
                .background(self.themeManager.currentTheme.primaryBackgroundColor)
            } detail: {
                NavigationStack {
                    self.contentForSelectedTab
                }
            }
        }
    #endif

    // MARK: - iPhone Layout (Traditional TabView)

    #if os(iOS)
        private var iPhoneLayout: some View {
            TabView(selection: self.$selectedTabTag) {
                ForEach(TabConfiguration.allTabs, id: \.tag) { tab in
                    self.contentForTab(tab.tag)
                        .tabItem {
                            Label(tab.title, systemImage: tab.icon)
                        }
                        .tag(tab.tag)
                }
            }
            .accentColor(self.themeManager.currentTheme.primaryAccentColor)
            .environment(
                \.colorScheme,
                self.themeManager.currentTheme.primaryBackgroundColor.isDark() ? .dark : .light
            )
        }
    #endif

    // MARK: - Content Views

    @ViewBuilder
    private var contentForSelectedTab: some View {
        self.contentForTab(self.selectedTabTag)
    }

    @ViewBuilder
    private func contentForTab(_ tag: String) -> some View {
        switch tag {
        case TabTags.dashboard:
            DashboardView(selectedTabTag: self.$selectedTabTag)
        case TabTags.tasks:
            TaskManagerView()
        case TabTags.calendar:
            CalendarView()
        case TabTags.goals:
            GoalsView()
        case TabTags.journal:
            JournalView()
        case TabTags.settings:
            SettingsView()
        default:
            DashboardView(selectedTabTag: self.$selectedTabTag)
        }
    }

    // MARK: - Toolbar Buttons

    #if os(macOS)
        @ViewBuilder
        private var macOSToolbarButtons: some View {
            Button(action: self.addNewItem) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add New Item")
            .help("Add New Item")

            Button(action: self.searchAction) {
                Image(systemName: "magnifyingglass")
            }
            .accessibilityLabel("Search")
            .help("Search")
            .keyboardShortcut("f", modifiers: .command)

            Button(action: self.syncAction) {
                Image(systemName: "arrow.clockwise")
            }
            .accessibilityLabel("Sync")
            .help("Sync")
            .keyboardShortcut("r", modifiers: .command)
        }
    #endif

    #if os(iOS)
        @ViewBuilder
        private var iPadToolbarButtons: some View {
            Button(action: self.addNewItem) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add New Item")

            Button(action: self.searchAction) {
                Image(systemName: "magnifyingglass")
            }
            .accessibilityLabel("Search")

            Button(action: self.syncAction) {
                Image(systemName: "arrow.clockwise")
            }
            .accessibilityLabel("Sync")
        }
    #endif

    // MARK: - Actions

    private func addNewItem() {
        // Add new item based on current tab
        print("Add new item for tab: \(self.selectedTabTag)")
    }

    private func searchAction() {
        // Open search
        print("Search action")
    }

    private func syncAction() {
        // Sync data
        print("Sync action")
    }

    #if os(macOS)
        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?.tryToPerform(
                #selector(NSSplitViewController.toggleSidebar(_:)), with: nil
            )
        }
    #endif
}

#Preview {
    MainTabViewEnhanced(selectedTabTag: .constant("Dashboard"))
        .environmentObject(ThemeManager())
}
