//
//  PlatformAdaptiveNavigation.swift
//  PlannerApp
//
//  Platform-specific navigation that adapts to iOS, iPadOS, and macOS
//

import SwiftUI

struct PlatformAdaptiveNavigation<Content: View>: View {
    let content: Content
    @EnvironmentObject var themeManager: ThemeManager

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        #if os(macOS)
            NavigationSplitView {
                SidebarView()
            } detail: {
                self.content
            }
            .navigationSplitViewStyle(.balanced)
        #elseif os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad layout
                NavigationSplitView {
                    SidebarView()
                } detail: {
                    self.content
                }
            } else {
                // iPhone layout
                NavigationStack {
                    self.content
                }
            }
        #endif
    }
}

public struct SidebarView: View {
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
            case .dashboard: "house.fill"
            case .tasks: "checkmark.circle.fill"
            case .goals: "target"
            case .calendar: "calendar"
            case .journal: "book.fill"
            case .settings: "gearshape.fill"
            }
        }
    }

    public var body: some View {
        #if os(macOS)
            List(Tab.allCases, id: \.self, selection: self.$selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
            }
            .navigationTitle("PlannerApp")
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
        #else
            // iOS/iPadOS: Use regular List without selection binding
            List(Tab.allCases, id: \.self) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
            }
            .navigationTitle("PlannerApp")
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
        #endif
    }
}

// MARK: - Platform-Specific Toolbar

public struct PlatformToolbar: ViewModifier {
    let title: String
    let primaryActions: [ToolbarAction]
    let secondaryActions: [ToolbarAction]

    struct ToolbarAction {
        let title: String
        let icon: String
        let action: () -> Void
        let isDestructive: Bool

        init(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
            self.title = title
            self.icon = icon
            self.isDestructive = isDestructive
            self.action = action
        }
    }

    public func body(content: Content) -> some View {
        content
            .navigationTitle(self.title)
            .toolbar {
                #if os(macOS)
                    ToolbarItemGroup(placement: .primaryAction) {
                        ForEach(self.primaryActions, id: \.title) { action in
                            Button(action: action.action) {
                                Label(action.title, systemImage: action.icon)
                            }
                            .accessibilityLabel("Button")
                            .help(action.title)
                        }
                    }

                    ToolbarItemGroup(placement: .secondaryAction) {
                        Menu("More") {
                            ForEach(self.secondaryActions, id: \.title) { action in
                                Button(action.title, action: action.action)
                                    .accessibilityLabel("Button")
                            }
                        }
                    }
                #else
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        ForEach(self.primaryActions, id: \.title) { action in
                            Button(action: action.action) {
                                Image(systemName: action.icon)
                            }
                            .accessibilityLabel("Button")
                        }

                        if !self.secondaryActions.isEmpty {
                            Menu {
                                ForEach(self.secondaryActions, id: \.title) { action in
                                    Button(action.title, action: action.action)
                                        .accessibilityLabel("Button")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                #endif
            }
    }
}

extension View {
    func platformToolbar(
        title: String,
        primaryActions: [PlatformToolbar.ToolbarAction] = [],
        secondaryActions: [PlatformToolbar.ToolbarAction] = []
    ) -> some View {
        modifier(
            PlatformToolbar(
                title: title,
                primaryActions: primaryActions,
                secondaryActions: secondaryActions
            )
        )
    }
}

// MARK: - Platform-Specific Context Menu

struct PlatformContextMenu<MenuContent: View>: ViewModifier {
    let menuContent: MenuContent

    init(@ViewBuilder menuContent: () -> MenuContent) {
        self.menuContent = menuContent()
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .contextMenu {
                    self.menuContent
                }
        #else
            content
                .contextMenu {
                    self.menuContent
                }
        #endif
    }
}

extension View {
    func platformContextMenu(
        @ViewBuilder menuContent: () -> some View
    ) -> some View {
        modifier(PlatformContextMenu(menuContent: menuContent))
    }
}

// MARK: - Adaptive Grid Layout

struct AdaptiveGrid<Content: View>: View {
    let content: Content
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private var columns: [GridItem] {
        #if os(macOS)
            return Array(repeating: .init(.flexible()), count: 3)
        #else
            if self.horizontalSizeClass == .regular {
                // iPad or iPhone landscape
                return Array(repeating: .init(.flexible()), count: 2)
            } else {
                // iPhone portrait
                return [.init(.flexible())]
            }
        #endif
    }

    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 16) {
            self.content
        }
    }
}

// MARK: - Platform-Specific Sheet Presentation

struct PlatformSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: SheetContent

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> SheetContent) {
        _isPresented = isPresented
        self.sheetContent = content()
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .sheet(isPresented: self.$isPresented) {
                    self.sheetContent
                        .frame(minWidth: 400, minHeight: 300)
                }
        #else
            content
                .sheet(isPresented: self.$isPresented) {
                    NavigationStack {
                        self.sheetContent
                    }
                }
        #endif
    }
}

extension View {
    func platformSheet(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> some View
    ) -> some View {
        modifier(PlatformSheet(isPresented: isPresented, content: content))
    }
}

// MARK: - Example Usage

public struct ExamplePlatformView: View {
    @State private var showingAddItem = false
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        PlatformAdaptiveNavigation {
            ScrollView {
                AdaptiveGrid {
                    ForEach(0 ..< 6, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(self.themeManager.currentTheme.secondaryBackgroundColor)
                            .frame(height: 120)
                            .overlay(
                                Text("Item \(index + 1)")
                                    .foregroundColor(self.themeManager.currentTheme.primaryTextColor)
                            )
                            .platformContextMenu {
                                Button("Edit", action: {}).accessibilityLabel("Button")
                                Button("Delete", role: .destructive, action: {}).accessibilityLabel("Button")
                            }
                    }
                }
                .padding()
            }
            .platformToolbar(
                title: "Example View",
                primaryActions: [
                    .init(title: "Add Item", icon: "plus") {
                        self.showingAddItem = true
                    },
                ],
                secondaryActions: [
                    .init(title: "Sort", icon: "arrow.up.arrow.down") {},
                    .init(title: "Filter", icon: "line.3.horizontal.decrease.circle") {},
                ]
            )
            .platformSheet(isPresented: self.$showingAddItem) {
                Text("Add Item Sheet")
                    .navigationTitle("Add Item")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: {
                                self.showingAddItem = false
                            })
                            .accessibilityLabel("Button")
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save", action: {
                                self.showingAddItem = false
                            })
                            .accessibilityLabel("Button")
                        }
                    }
            }
        }
    }
}

#Preview {
    ExamplePlatformView()
        .environmentObject(ThemeManager())
}
