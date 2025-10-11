// PlannerApp/Views/AIView.swift
import SwiftUI

public struct AIView: View {
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("AI Assistant")
                    .font(.title)
                    .foregroundColor(themeManager.currentTheme.primaryTextColor)

                Text("AI features coming soon...")
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            .background(themeManager.currentTheme.primaryBackgroundColor.ignoresSafeArea())
            .navigationTitle("AI Assistant")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    AIView()
        .environmentObject(ThemeManager())
}
