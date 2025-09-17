//
//  AccessibilityEnhancements.swift
//  PlannerApp
//
//  Enhanced accessibility features for better user experience
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
import Cocoa
#endif

// MARK: - Accessibility Manager

@MainActor
class AccessibilityManager: ObservableObject {
    @Published var isVoiceOverEnabled = false
    @Published var prefersDynamicType = false
    @Published var prefersReducedMotion = false
    @Published var prefersHighContrast = false

    init() {
        self.updateAccessibilitySettings()

        #if os(iOS)
        // Listen for accessibility changes on iOS
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.accessibilitySettingsChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.accessibilitySettingsChanged),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        #elseif os(macOS)
        // For macOS, we use different notification mechanisms
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.accessibilitySettingsChanged),
            name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil
        )
        #endif
    }

    @objc private func accessibilitySettingsChanged() {
        DispatchQueue.main.async {
            self.updateAccessibilitySettings()
        }
    }

    private func updateAccessibilitySettings() {
        #if os(iOS)
        self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        self.prefersDynamicType =
            UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        self.prefersReducedMotion = UIAccessibility.isReduceMotionEnabled
        self.prefersHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
        #elseif os(macOS)
        // Use macOS equivalents
        self.isVoiceOverEnabled = NSWorkspace.shared.isVoiceOverEnabled
        self.prefersReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        self.prefersHighContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
        self.prefersDynamicType = UserDefaults.standard.bool(
            forKey: "AppleAccessibilityDynamicTypeEnabled"
        )
        #endif
    }
}

// MARK: - Accessible Components

struct AccessibleButton: View {
    let title: String
    let action: () -> Void
    @EnvironmentObject var accessibilityManager: AccessibilityManager

    var role: ButtonRole?
    var hint: String?
    var isEnabled: Bool = true

    var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(.system(size: self.dynamicFontSize, weight: .medium))
                .foregroundColor(self.textColor)
                .frame(minHeight: self.minimumTouchTarget)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
        }
        .accessibilityLabel("Button")
        .background(self.backgroundColor)
        .cornerRadius(12)
        .disabled(!self.isEnabled)
        .opacity(self.isEnabled ? 1.0 : 0.6)
        .accessibilityLabel(self.title)
        .accessibilityHint(self.hint ?? "")
        .accessibilityAddTraits(self.isEnabled ? .isButton : .isButton)
    }

    private var dynamicFontSize: CGFloat {
        let baseSize: CGFloat = 16
        if self.accessibilityManager.prefersDynamicType {
            return min(baseSize * 1.5, 24) // Cap at reasonable maximum
        }
        return baseSize
    }

    private var minimumTouchTarget: CGFloat {
        44 // Apple's recommended minimum touch target
    }

    private var backgroundColor: Color {
        let baseColor = self.role == .destructive ? Color.red : Color.blue

        if self.accessibilityManager.prefersHighContrast {
            return baseColor.opacity(0.9)
        }
        return baseColor
    }

    private var textColor: Color {
        if self.accessibilityManager.prefersHighContrast {
            return Color.white
        }
        return self.role == .destructive ? Color.white : Color.white
    }
}

// MARK: - Accessible List Row

struct AccessibleListRow<Content: View>: View {
    let content: Content
    @EnvironmentObject var accessibilityManager: AccessibilityManager

    var accessibilityLabel: String?
    var accessibilityValue: String?
    var accessibilityHint: String?
    var accessibilityActions: [AccessibilityActionInfo] = []

    struct AccessibilityActionInfo {
        let name: String
        let action: () -> Void
    }

    init(
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        accessibilityHint: String? = nil,
        accessibilityActions: [AccessibilityActionInfo] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        self.accessibilityActions = accessibilityActions
        self.content = content()
    }

    var body: some View {
        self.content
            .frame(minHeight: self.minimumRowHeight)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(self.accessibilityLabel ?? "")
            .accessibilityValue(self.accessibilityValue ?? "")
            .accessibilityHint(self.accessibilityHint ?? "")
            .accessibilityActions {
                ForEach(self.accessibilityActions.indices, id: \.self) { index in
                    let actionInfo = self.accessibilityActions[index]
                    Button(actionInfo.name, action: actionInfo.action).accessibilityLabel("Button")
                }
            }
    }

    private var minimumRowHeight: CGFloat {
        if self.accessibilityManager.prefersDynamicType {
            return 60
        }
        return 44
    }
}

// MARK: - High Contrast Theme Modifier

struct HighContrastModifier: ViewModifier {
    @EnvironmentObject var accessibilityManager: AccessibilityManager

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, self.accessibilityManager.prefersHighContrast ? .dark : .light)
            .foregroundColor(
                self.accessibilityManager.prefersHighContrast ? Color.white : Color.primary
            )
    }
}

extension View {
    func highContrastAdaptive() -> some View {
        modifier(HighContrastModifier())
    }
}

// MARK: - Reduced Motion Modifier

struct ReducedMotionModifier: ViewModifier {
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    let animation: Animation

    func body(content: Content) -> some View {
        content
            .animation(
                self.accessibilityManager.prefersReducedMotion ? .none : self.animation,
                value: UUID()
            )
    }
}

extension View {
    func respectsReducedMotion(_ animation: Animation = .default) -> some View {
        modifier(ReducedMotionModifier(animation: animation))
    }
}

// MARK: - Focus Management

struct FocusableView<Content: View>: View {
    let content: Content
    @FocusState private var isFocused: Bool

    var accessibilityLabel: String
    var onFocusChange: ((Bool) -> Void)?

    init(
        accessibilityLabel: String,
        onFocusChange: ((Bool) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.onFocusChange = onFocusChange
        self.content = content()
    }

    var body: some View {
        self.content
            .focused(self.$isFocused)
            .accessibilityLabel(self.accessibilityLabel)
            .modifier(FocusChangeModifier(onFocusChange: self.onFocusChange))
    }
}

// MARK: - Focus Change Modifier

struct FocusChangeModifier: ViewModifier {
    let onFocusChange: ((Bool) -> Void)?

    func body(content: Content) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            content
        } else {
            content
        }
    }
}

// MARK: - Screen Reader Announcements

enum ScreenReaderAnnouncement {
    static func announce(_ message: String) {
        DispatchQueue.main.async {
            #if os(iOS)
            UIAccessibility.post(notification: .announcement, argument: message)
            #elseif os(macOS)
            // Using the correct method without an argument parameter
            let userInfo: [NSAccessibility.NotificationUserInfoKey: Any] = [
                NSAccessibility.NotificationUserInfoKey.announcement: message
            ]
            NSAccessibility.post(
                element: NSApp as Any, notification: .announcementRequested, userInfo: userInfo
            )
            #endif
        }
    }

    static func announcePageChange(_ pageName: String) {
        DispatchQueue.main.async {
            #if os(iOS)
            UIAccessibility.post(notification: .screenChanged, argument: pageName)
            #elseif os(macOS)
            // Using a simpler approach for macOS - remove the extra argument parameter
            NSAccessibility.post(element: NSApp as Any, notification: .selectedTextChanged)
            #endif
        }
    }

    static func announceLayoutChange() {
        DispatchQueue.main.async {
            #if os(iOS)
            UIAccessibility.post(notification: .layoutChanged, argument: "")
            #elseif os(macOS)
            // Make sure we're using the correct API without an argument parameter
            NSAccessibility.post(
                element: NSApp as Any, notification: .layoutChanged, userInfo: nil
            )
            #endif
        }
    }
}

// MARK: - Dynamic Type Support

struct DynamicTypeText: View {
    let text: String
    let style: Font.TextStyle
    @EnvironmentObject var accessibilityManager: AccessibilityManager

    var maxFontSize: CGFloat = 28

    var body: some View {
        Text(self.text)
            .font(.system(self.style, design: .default))
            .lineLimit(self.accessibilityManager.prefersDynamicType ? nil : 2)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
    }
}

// MARK: - Accessible Progress Indicator

struct AccessibleProgressView: View {
    let progress: Double // 0.0 to 1.0
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DynamicTypeText(text: self.label, style: .body)
                Spacer()
                DynamicTypeText(text: "\(Int(self.progress * 100))%", style: .caption)
            }

            ProgressView(value: self.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .accessibilityLabel("\(self.label) progress")
                .accessibilityValue("\(Int(self.progress * 100)) percent complete")
        }
    }
}

// MARK: - Example Usage View

struct AccessibilityDemoView: View {
    @StateObject private var accessibilityManager = AccessibilityManager()
    @State private var progress: Double = 0.7

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DynamicTypeText(text: "Accessibility Demo", style: .title)

                AccessibleListRow(
                    accessibilityLabel: "Sample task",
                    accessibilityValue: "Completed",
                    accessibilityHint: "Double tap to edit",
                    accessibilityActions: [
                        .init(name: "Edit") {
                            ScreenReaderAnnouncement.announce("Edit mode activated")
                        },
                        .init(name: "Delete") {
                            ScreenReaderAnnouncement.announce("Task deleted")
                        },
                    ]
                ) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        DynamicTypeText(text: "Sample Task", style: .body)
                        Spacer()
                    }
                }

                AccessibleButton(
                    title: "Add New Task",
                    action: {
                        ScreenReaderAnnouncement.announce("Add task button pressed")
                    },
                    hint: "Opens the add task screen"
                )

                AccessibleProgressView(progress: self.progress, label: "Goal Progress")

                Group {
                    HStack {
                        DynamicTypeText(text: "VoiceOver:", style: .caption)
                        Spacer()
                        DynamicTypeText(
                            text: self.accessibilityManager.isVoiceOverEnabled ? "On" : "Off",
                            style: .caption
                        )
                    }

                    HStack {
                        DynamicTypeText(text: "Dynamic Type:", style: .caption)
                        Spacer()
                        DynamicTypeText(
                            text: self.accessibilityManager.prefersDynamicType ? "Large" : "Standard",
                            style: .caption
                        )
                    }

                    HStack {
                        DynamicTypeText(text: "Reduced Motion:", style: .caption)
                        Spacer()
                        DynamicTypeText(
                            text: self.accessibilityManager.prefersReducedMotion ? "On" : "Off",
                            style: .caption
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .highContrastAdaptive()
        .respectsReducedMotion(.easeInOut(duration: 0.3))
        .environmentObject(self.accessibilityManager)
        .onAppear {
            ScreenReaderAnnouncement.announcePageChange("Accessibility Demo")
        }
    }
}

#Preview {
    AccessibilityDemoView()
}
