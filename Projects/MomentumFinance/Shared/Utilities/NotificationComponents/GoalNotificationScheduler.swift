//
//  GoalNotificationScheduler.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import Foundation
import OSLog
import UserNotifications

/// Schedules goal milestone and reminder notifications
public struct GoalNotificationScheduler {

    private let center = UNUserNotificationCenter.current()
    private let logger: OSLog

    init(logger: OSLog) {
        self.logger = logger
    }

    /// Checks and schedules milestone notifications for savings goals
    /// - Parameter goals: Array of savings goals to check for milestones
    func checkMilestones(for goals: [SavingsGoal]) {
        for goal in goals {
            let progressPercentage = goal.currentAmount / goal.targetAmount

            // 25%, 50%, 75%, 90% milestones
            let milestones = [0.25, 0.50, 0.75, 0.90]

            for milestone in milestones {
                if progressPercentage >= milestone {
                    scheduleMilestoneNotification(goal: goal, milestone: milestone)
                }
            }

            // Goal achieved
            if progressPercentage >= 1.0 {
                scheduleGoalAchievedNotification(goal: goal)
            }
        }
    }

    /// Schedules a milestone achievement notification
    /// - Parameters:
    ///   - goal: The savings goal that reached a milestone
    ///   - milestone: The milestone percentage (e.g., 0.25 for 25%)
    private func scheduleMilestoneNotification(goal: SavingsGoal, milestone: Double) {
        let identifier = "goal_milestone_\(goal.persistentModelID)_\(Int(milestone * 100))"

        let content = UNMutableNotificationContent()
        content.title = "Goal Milestone Reached! 🎉"

        let percentageInt = Int(milestone * 100)
        let currentFormatted = goal.currentAmount.formatted(.currency(code: "USD"))
        let targetFormatted = goal.targetAmount.formatted(.currency(code: "USD"))
        content.body = "You've saved \(percentageInt)% toward your \(goal.name) goal! \(currentFormatted) of \(targetFormatted)"

        content.sound = .default
        content.categoryIdentifier = "GOAL_MILESTONE"
        content.userInfo = [
            "type": "goal_milestone",
            "goalId": "\(goal.persistentModelID)",
            "milestone": milestone,
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule goal milestone notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
    }

    /// Schedules a goal achievement notification
    /// - Parameter goal: The savings goal that was achieved
    private func scheduleGoalAchievedNotification(goal: SavingsGoal) {
        let identifier = "goal_achieved_\(goal.persistentModelID)"

        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved! 🏆"
        content.body = "Congratulations! You've reached your \(goal.name) savings goal of \(goal.targetAmount.formatted(.currency(code: "USD")))!"
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = "GOAL_ACHIEVED"
        content.userInfo = [
            "type": "goal_achieved",
            "goalId": "\(goal.persistentModelID)",
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                os_log("Failed to schedule goal achieved notification: %@", log: self.logger, type: .error, error.localizedDescription)
            }
        }
    }
}
