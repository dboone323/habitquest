// PlannerApp/Components/Goals/GoalsEmptyStateView.swift
import Foundation
import SwiftUI

public struct GoalsEmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager

    public var body: some View {
        Text("No goals set yet. Tap '+' to add one!")
            .foregroundColor(self.themeManager.currentTheme.secondaryTextColor)
            .font(
                self.themeManager.currentTheme.font(
                    forName: self.themeManager.currentTheme.secondaryFontName, size: 15
                )
            )
            .listRowBackground(self.themeManager.currentTheme.secondaryBackgroundColor)
            .frame(maxWidth: .infinity, alignment: .center) // Center the text
    }
}
