// PlannerApp/Components/Tasks/TaskManagerHeaderView.swift
import Foundation
import SwiftUI

#if os(iOS)
    import UIKit
#endif

public struct TaskManagerHeaderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        HStack {
            Button("Done") {
                #if os(iOS)
                    HapticManager.lightImpact()
                #endif
                self.dismiss()
            }
            .accessibilityLabel("Button")
            #if os(iOS)
                .buttonStyle(.iOSSecondary)
            #endif
                .foregroundColor(self.themeManager.currentTheme.primaryAccentColor)

            Spacer()

            Text("Task Manager")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(self.themeManager.currentTheme.primaryTextColor)

            Spacer()

            // Invisible button for balance
            Button {}
                label: {
                    Text("")
                }
                .accessibilityLabel("Button")
                .disabled(true)
                .opacity(0)
            #if os(iOS)
                .frame(minWidth: 60, minHeight: 44)
            #endif
        }
        .padding()
        .background(self.themeManager.currentTheme.secondaryBackgroundColor)
    }
}
