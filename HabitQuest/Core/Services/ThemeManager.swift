//
// ThemeManager.swift
// HabitQuest
//
// Manages app themes and appearance
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = "System"
    
    let themes = ["System", "Light", "Dark", "Ocean", "Forest"]
    
    func applyTheme() {
        // In a real app, this would set window overrides or inject colors
        print("Applying theme: \(selectedTheme)")
    }
    
    func color(for name: String) -> Color {
        // Return theme-specific colors
        return .blue
    }
}
