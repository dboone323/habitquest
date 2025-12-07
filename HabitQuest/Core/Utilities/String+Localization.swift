//
//  String+Localization.swift
//  HabitQuest
//
//  Localization helper extension
//

import Foundation

extension String {
    /// Returns a localized version of the string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

/// Centralized localization keys for type-safe access
enum L10n {
    enum App {
        static let name = "app.name".localized
        static let tagline = "app.tagline".localized
    }
    
    enum Tab {
        static let home = "tab.home".localized
        static let habits = "tab.habits".localized
        static let quests = "tab.quests".localized
        static let profile = "tab.profile".localized
        static let analytics = "tab.analytics".localized
        static let settings = "tab.settings".localized
    }
    
    enum Habit {
        static let create = "habit.create".localized
        static let edit = "habit.edit".localized
        static let delete = "habit.delete".localized
        static let complete = "habit.complete".localized
        static let name = "habit.name".localized
        static let description = "habit.description".localized
        static let frequency = "habit.frequency".localized
        static let category = "habit.category".localized
        static let difficulty = "habit.difficulty".localized
        static let streak = "habit.streak".localized
        
        static func streakDays(_ days: Int) -> String {
            "habit.streakDays".localized(with: days)
        }
    }
    
    enum Profile {
        static let title = "profile.title".localized
        static let achievements = "profile.achievements".localized
        static let statistics = "profile.statistics".localized
        static let totalHabits = "profile.totalHabits".localized
        static let completedToday = "profile.completedToday".localized
        static let longestStreak = "profile.longestStreak".localized
        
        static func level(_ level: Int) -> String {
            "profile.level".localized(with: level)
        }
        
        static func xp(_ xp: Int) -> String {
            "profile.xp".localized(with: xp)
        }
    }
    
    enum Analytics {
        static let title = "analytics.title".localized
        static let overview = "analytics.overview".localized
        static let trends = "analytics.trends".localized
        static let patterns = "analytics.patterns".localized
        static let insights = "analytics.insights".localized
        static let completionRate = "analytics.completionRate".localized
    }
    
    enum Action {
        static let save = "action.save".localized
        static let cancel = "action.cancel".localized
        static let delete = "action.delete".localized
        static let edit = "action.edit".localized
        static let done = "action.done".localized
        static let ok = "action.ok".localized
        static let retry = "action.retry".localized
        static let close = "action.close".localized
    }
    
    enum Error {
        static let generic = "error.generic".localized
        static let network = "error.network".localized
        static let loadFailed = "error.loadFailed".localized
        static let saveFailed = "error.saveFailed".localized
    }
}
