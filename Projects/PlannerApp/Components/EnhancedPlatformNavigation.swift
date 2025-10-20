//
//  EnhancedPlatformNavigation.swift
//  PlannerApp
//
//  Enhanced platform-specific navigation patterns for iOS, iPadOS, and macOS
//

import SwiftUI

// MARK: - Enhanced Platform Navigation

struct EnhancedPlatformNavigation<Content: View>: View {
    let content: Content
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        #if os(macOS)
            self.macOSNavigation
        #elseif os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.iPadNavigation
            } else {
                self.iPhoneNavigation
            }
        #endif
    }

    // MARK: - macOS Navigation

    private var macOSNavigation: some View {
        NavigationSplitView {
            MacOSSidebarView()
                .frame(minWidth: 200, idealWidth: 250)
        } detail: {
            self.content
                .frame(minWidth: 600, maxWidth: .infinity)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        MacOSToolbarButtons()
                    }
                }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - iPad Navigation

    private var iPadNavigation: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            IPadSidebarView()
                .frame(minWidth: 280, idealWidth: 320)
        } detail: {
            self.content
                .toolbar {
                    #if os(iOS)
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            IPadToolbarButtons()
                        }
                    #else
                        ToolbarItemGroup {
                            IPadToolbarButtons()
                        }
                    #endif
                }
        }
    }

    // MARK: - iPhone Navigation

    private var iPhoneNavigation: some View {
        NavigationStack {
            self.content
                .toolbar {
                    #if os(iOS)
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            IPhoneToolbarButtons()
                        }
                    #else
                        ToolbarItemGroup {
                            IPhoneToolbarButtons()
                        }
                    #endif
                }
        }
    }
}

// MARK: - macOS Sidebar

public struct MacOSSidebarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case tasks = "Tasks"
        case goals = "Goals"
        case calendar = "Calendar"
        case journal = "Journal"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: "square.grid.2x2"
            case .tasks: "checkmark.circle"
            case .goals: "target"
            case .calendar: "calendar"
            case .journal: "book"
            case .settings: "gear"
            }
        }

        var keyboardShortcut: KeyEquivalent? {
            switch self {
            case .dashboard: "1"
            case .tasks: "2"
            case .goals: "3"
            case .calendar: "4"
            case .journal: "5"
            case .settings: ","
            }
        }
    }

    public var body: some View {
        List(Tab.allCases, id: \.self) { tab in
            NavigationLink(value: tab) {
                Label(tab.rawValue, systemImage: tab.icon)
                    .foregroundColor(
                        self.selectedTab == tab
                            ? self.themeManager.currentTheme.primaryAccentColor
                            : self.themeManager.currentTheme.primaryTextColor
                    )
            }
            .keyboardShortcut(tab.keyboardShortcut ?? KeyEquivalent(" "), modifiers: .command)
        }
        .listStyle(SidebarListStyle())
        .background(self.themeManager.currentTheme.secondaryBackgroundColor)
    }
}

// MARK: - iPad Sidebar

public struct IPadSidebarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab: String = "Dashboard"

    let tabs = [
        ("Dashboard", "square.grid.2x2"),
        ("Tasks", "checkmark.circle"),
        ("Goals", "target"),
        ("Calendar", "calendar"),
        ("Journal", "book"),
        ("Settings", "gear"),
    ]

    public var body: some View {
        List {
            Section("PlannerApp") {
                ForEach(self.tabs, id: \.0) { tab in
                    HStack {
                        Image(systemName: tab.1)
                            .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)
                            .frame(width: 24)

                        Text(tab.0)
                            .font(.body)
                            .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .background(
                        self.selectedTab == tab.0
                            ? self.themeManager.currentTheme.primaryAccentColor.opacity(0.1)
                            : Color.clear
                    )
                    .cornerRadius(8)
                    .onTapGesture {
                        self.selectedTab = tab.0
                        // Add haptic feedback
                        #if os(iOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        #endif
                    }
                }
            }

            Spacer(minLength: 100)

            Section("Quick Actions") {
                QuickActionButton(
                    title: "Add Task", icon: "plus.circle", color: .blue,
                    action: {
                        // Handle add task
                    }
                )
                .accessibilityLabel("Add Task Button")

                QuickActionButton(
                    title: "Add Goal", icon: "target", color: .green,
                    action: {
                        // Handle add goal
                    }
                )
                .accessibilityLabel("Add Goal Button")

                QuickActionButton(
                    title: "Add Event", icon: "calendar.badge.plus", color: .orange,
                    action: {
                        // Handle add event
                    }
                )
                .accessibilityLabel("Add Event Button")
            }
        }
        .listStyle(SidebarListStyle())
        .background(self.themeManager.currentTheme.primaryBackgroundColor)
    }
}

// MARK: - Toolbar Buttons

public struct MacOSToolbarButtons: View {
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        HStack {
            Button {}
                label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .accessibilityLabel("Search Button")
                .keyboardShortcut("f", modifiers: .command)

            Button {}
                label: {
                    Label("Add Item", systemImage: "plus")
                }
                .accessibilityLabel("Add Item Button")
                .keyboardShortcut("n", modifiers: .command)

            Menu {
                Button("Export Data", action: {}).accessibilityLabel("Export Data Button")
                Button("Import Data", action: {}).accessibilityLabel("Import Data Button")
                Divider()
                Button("Preferences", action: {}).accessibilityLabel("Preferences Button")
                    .keyboardShortcut(",", modifiers: .command)
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
}

public struct IPadToolbarButtons: View {
    public var body: some View {
        HStack {
            Button {}
                label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search Button")

            Button {}
                label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Button")

            Menu {
                Button("Search", action: {}).accessibilityLabel("Search Menu Button")
                Button("Filter", action: {}).accessibilityLabel("Filter Button")
                Button("Sort", action: {}).accessibilityLabel("Sort Button")
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

public struct IPhoneToolbarButtons: View {
    public var body: some View {
        HStack {
            Button {}
                label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Button")

            Menu {
                Button("Search", action: {}).accessibilityLabel("Search Menu Button")
                Button("Filter", action: {}).accessibilityLabel("Filter Button")
                Button("Settings", action: {}).accessibilityLabel("Settings Button")
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

// MARK: - Quick Action Button

public struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        Button(action: self.action, label: {
            HStack {
                Image(systemName: self.icon)
                    .foregroundColor(self.color)
                    .frame(width: 20)

                Text(self.title)
                    .font(.body)
                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(self.color.opacity(0.1))
            .cornerRadius(8)
        })
        .accessibilityLabel("\(self.title) Button")
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Keyboard Shortcuts Support

public struct KeyboardShortcutsView: View {
    public var body: some View {
        VStack {
            Text("Keyboard Shortcuts")
                .font(.title2.bold())
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                ShortcutRow(key: "⌘1", description: "Dashboard")
                ShortcutRow(key: "⌘2", description: "Tasks")
                ShortcutRow(key: "⌘3", description: "Goals")
                ShortcutRow(key: "⌘4", description: "Calendar")
                ShortcutRow(key: "⌘5", description: "Journal")
                ShortcutRow(key: "⌘,", description: "Settings")
                Divider()
                ShortcutRow(key: "⌘N", description: "New Item")
                ShortcutRow(key: "⌘F", description: "Search")
                ShortcutRow(key: "⌘R", description: "Refresh")
            }
            .padding()
        }
    }
}

public struct ShortcutRow: View {
    let key: String
    let description: String

    public var body: some View {
        HStack {
            Text(self.key)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Text(self.description)
                .font(.body)

            Spacer()
        }
    }
}

#Preview {
    EnhancedPlatformNavigation {
        VStack {
            Text("Sample Content")
                .font(.title)
            Text("This shows enhanced platform navigation")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    .environmentObject(ThemeManager())
}
