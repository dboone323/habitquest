import Foundation
import Combine

/// AI-powered task prioritization service for PlannerApp
/// Provides intelligent task suggestions and productivity insights
/// Integrates with the shared AI framework for consistent behavior

@available(iOS 13.0, macOS 10.15, *)
@MainActor
public class AITaskPrioritizationService: ObservableObject {
    public static var shared: AITaskPrioritizationService {
        return _shared
    }

    private static let _shared = AITaskPrioritizationService()

    @Published public var isProcessing = false
    @Published public var lastUpdate: Date?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.setupSubscriptions()
    }

    private func setupSubscriptions() {
        // Setup any subscriptions if needed
    }

    // MARK: - Task Prioritization

    /// Parse natural language input into a structured task
    public func parseNaturalLanguageTask(_ input: String) async throws -> PlannerTask? {
        // Simple natural language parsing - could be enhanced with ML models
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Extract title (everything before time/date indicators)
        let title = input.trimmingCharacters(in: .whitespacesAndNewlines)
        var priority: TaskPriority = .medium
        var dueDate: Date?

        // Look for priority indicators
        if trimmedInput.contains("urgent") || trimmedInput.contains("asap") || trimmedInput.contains("important") {
            priority = .high
        } else if trimmedInput.contains("low") || trimmedInput.contains("someday") || trimmedInput.contains("eventually") {
            priority = .low
        }

        // Look for time/date indicators
        let datePatterns = [
            "today": Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            "tomorrow": Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            "next week": Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            "this week": Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        ]

        for (pattern, date) in datePatterns {
            if trimmedInput.contains(pattern) {
                dueDate = date
                break
            }
        }

        // Look for specific times (e.g., "at 2pm", "by 3pm")
        if let timeRange = input.range(of: #"(?i)(at|by)\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?"#, options: .regularExpression) {
            let timeString = String(input[timeRange])
            // Simple time parsing - could be enhanced
            if let hour = Int(timeString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate ?? Date())
                components.hour = hour
                components.minute = 0
                if let parsedTime = Calendar.current.date(from: components) {
                    dueDate = parsedTime
                }
            }
        }

        return PlannerTask(
            title: title,
            priority: priority,
            dueDate: dueDate
        )
    }

    /// Generate AI-powered task suggestions based on user activity and goals
    public func generateTaskSuggestions(
        currentTasks: [PlannerTask],
        recentActivity: [ActivityRecord],
        userGoals: [Goal]
    ) -> [TaskSuggestion] {
        isProcessing = true
        defer {
            isProcessing = false
            lastUpdate = Date()
        }

        var suggestions: [TaskSuggestion] = []

        // Generate suggestions using multiple AI approaches
        let patternBasedSuggestions = generatePatternBasedSuggestions(
            currentTasks: currentTasks,
            recentActivity: recentActivity
        )

        let goalBasedSuggestions = generateGoalBasedSuggestions(
            tasks: currentTasks,
            goals: userGoals
        )

        let timeBasedSuggestions = generateTimeBasedSuggestions(
            tasks: currentTasks
        )

        suggestions.append(contentsOf: patternBasedSuggestions)
        suggestions.append(contentsOf: goalBasedSuggestions)
        suggestions.append(contentsOf: timeBasedSuggestions)

        // Remove duplicates and sort by priority
        let uniqueSuggestions = deduplicateSuggestions(suggestions)
        let prioritizedSuggestions = prioritizeSuggestions(uniqueSuggestions)

        return prioritizedSuggestions
    }

    @MainActor
    private func generatePatternBasedSuggestions(
        currentTasks: [PlannerTask],
        recentActivity: [ActivityRecord]
    ) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []

        // Analyze completion patterns
        let completedTasks = recentActivity.filter { $0.type == .taskCompleted }
        let completionTimes = completedTasks.compactMap { $0.timestamp }

        if !completionTimes.isEmpty {
            // Suggest tasks during peak productivity times
            let peakHour = self.calculatePeakProductivityHour(completionTimes)

            let peakTimeSuggestion = TaskSuggestion(
                id: UUID().uuidString,
                title: "Schedule Important Tasks",
                subtitle: "Peak Productivity Window",
                reasoning: "Based on your activity patterns, you're most productive around \(self.formatHour(peakHour))",
                priority: .high,
                urgency: .medium,
                suggestedTime: self.createTimeSlot(hour: peakHour),
                category: .productivity,
                confidence: 0.8
            )
            suggestions.append(peakTimeSuggestion)
        }

        // Analyze task categories and suggest balance
        let tasksByPriority = Dictionary(grouping: currentTasks, by: { $0.priority })
        if let highPriorityCount = tasksByPriority[.high]?.count, highPriorityCount > currentTasks.count / 2 {
            let balanceSuggestion = TaskSuggestion(
                id: UUID().uuidString,
                title: "Balance Your Priorities",
                subtitle: "Many high-priority tasks",
                reasoning: "You've been focusing heavily on high-priority tasks. Consider adding some lower-priority tasks for balance.",
                priority: .medium,
                urgency: .low,
                suggestedTime: nil,
                category: .balance,
                confidence: 0.7
            )
            suggestions.append(balanceSuggestion)
        }

        return suggestions
    }

    @MainActor
    private func generateGoalBasedSuggestions(
        tasks: [PlannerTask],
        goals: [Goal]
    ) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []

        // Find goals that need attention
        let activeGoals = goals.filter { !$0.isCompleted }
        _ = Dictionary(grouping: tasks, by: { $0.id }) // Assuming tasks have goalId

        for goal in activeGoals {
            let relatedTasks = tasks.filter { task in
                // For now, we'll assume tasks are related to goals by title similarity
                // This could be improved with a proper relationship
                task.title.lowercased().contains(goal.title.lowercased().components(separatedBy: " ").first ?? "")
            }
            let completedTasks = relatedTasks.filter { $0.isCompleted }.count
            let progress = Double(completedTasks) / Double(max(relatedTasks.count, 1))

            if progress < 0.3 && relatedTasks.count > 2 {
                let goalSuggestion = TaskSuggestion(
                    id: UUID().uuidString,
                    title: "Focus on '\(goal.title)'",
                    subtitle: "Goal Progress: \(Int(progress * 100))%",
                    reasoning: "This goal needs more attention. Breaking it into smaller tasks might help.",
                    priority: .high,
                    urgency: .high,
                    suggestedTime: self.suggestTimeForGoal(goal),
                    category: .goals,
                    confidence: 0.9
                )
                suggestions.append(goalSuggestion)
            }
        }

        return suggestions
    }

    @MainActor
    private func generateTimeBasedSuggestions(tasks: [PlannerTask]) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []

        // Find overdue tasks
        let overdueTasks = tasks.filter { task in
            if let dueDate = task.dueDate {
                return dueDate < Date() && !task.isCompleted
            }
            return false
        }

        if !overdueTasks.isEmpty {
            let overdueSuggestion = TaskSuggestion(
                id: UUID().uuidString,
                title: "Address Overdue Tasks",
                subtitle: "\(overdueTasks.count) tasks need attention",
                reasoning: "Overdue tasks can create stress. Consider rescheduling or breaking them down.",
                priority: .high,
                urgency: .high,
                suggestedTime: Date().addingTimeInterval(3600), // 1 hour from now
                category: .urgent,
                confidence: 0.95
            )
            suggestions.append(overdueSuggestion)
        }

        // Suggest task batching for similar priorities
        let tasksByPriority = Dictionary(grouping: tasks.filter { !$0.isCompleted }, by: { $0.priority })
        for (priority, priorityTasks) in tasksByPriority where priorityTasks.count >= 3 {
            let batchSuggestion = TaskSuggestion(
                id: UUID().uuidString,
                title: "Batch \(priority.displayName) Priority Tasks",
                subtitle: "\(priorityTasks.count) similar tasks",
                reasoning: "Grouping similar priority tasks can improve efficiency and reduce context switching.",
                priority: .medium,
                urgency: .low,
                suggestedTime: self.suggestBatchTime(priority),
                category: .efficiency,
                confidence: 0.75
            )
            suggestions.append(batchSuggestion)
        }

        return suggestions
    }

    // MARK: - Productivity Insights

    /// Generate AI-powered productivity insights based on user activity
    public func generateProductivityInsights(
        activityData: [ActivityRecord],
        taskData: [PlannerTask],
        goalData: [Goal]
    ) -> [ProductivityInsight] {
        isProcessing = true
        defer {
            isProcessing = false
            lastUpdate = Date()
        }

        var insights: [ProductivityInsight] = []

        // Analyze productivity patterns
        let productivityInsights = analyzeProductivityPatterns(activityData)
        let taskInsights = analyzeTaskPatterns(taskData)
        let goalInsights = analyzeGoalProgress(goalData, taskData)

        insights.append(contentsOf: productivityInsights)
        insights.append(contentsOf: taskInsights)
        insights.append(contentsOf: goalInsights)

        // Sort by relevance and limit to top insights
        let sortedInsights = insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
        let topInsights = Array(sortedInsights.prefix(5))

        return topInsights
    }

    @MainActor
    private func analyzeProductivityPatterns(_ activities: [ActivityRecord]) -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []

        // Calculate productivity metrics
        let todayActivities = activities.filter {
            Calendar.current.isDateInToday($0.timestamp)
        }

        let weekActivities = activities.filter {
            Calendar.current.isDate($0.timestamp, equalTo: Date(), toGranularity: .weekOfYear)
        }

        let completionRate = self.calculateCompletionRate(todayActivities)
        let focusTime = self.calculateFocusTime(todayActivities)

        // Productivity score insight
        let productivityScore = (completionRate * 0.6) + (min(focusTime / 480, 1.0) * 0.4) // 8 hours max

        let scoreInsight = ProductivityInsight(
            id: UUID().uuidString,
            title: "Today's Productivity Score",
            description: String(format: "%.1f/10 - Based on task completion (%.0f%%) and focus time (%.1f hours)",
                              productivityScore * 10,
                              completionRate * 100,
                              focusTime / 60),
            icon: productivityScore > 0.7 ? "star.fill" : productivityScore > 0.4 ? "star.leadinghalf.filled" : "star",
            priority: .high,
            category: .performance,
            actionable: productivityScore < 0.6
        )
        insights.append(scoreInsight)

        // Weekly comparison
        if !weekActivities.isEmpty {
            let weekCompletionRate = self.calculateCompletionRate(weekActivities)
            let trend = weekCompletionRate > completionRate ? "improving" : "declining"

            let trendInsight = ProductivityInsight(
                id: UUID().uuidString,
                title: "Weekly Trend",
                description: "Your completion rate this week is \(trend) compared to today",
                icon: weekCompletionRate > completionRate ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                priority: .medium,
                category: .trends,
                actionable: false
            )
            insights.append(trendInsight)
        }

        // Peak productivity time
        let peakHour = self.calculatePeakProductivityHour(activities.map { $0.timestamp })

        let peakInsight = ProductivityInsight(
            id: UUID().uuidString,
            title: "Peak Productivity Time",
            description: "You're most productive around \(self.formatHour(peakHour)). Consider scheduling important tasks then.",
            icon: "clock.fill",
            priority: .medium,
            category: .optimization,
            actionable: true
        )
        insights.append(peakInsight)

        return insights
    }

    @MainActor
    private func analyzeTaskPatterns(_ tasks: [PlannerTask]) -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []

        let completedTasks = tasks.filter { $0.isCompleted }
        let pendingTasks = tasks.filter { !$0.isCompleted }

        // Task completion patterns
        if !completedTasks.isEmpty {
            let averageCompletionTime = self.calculateAverageCompletionTime(completedTasks)

            let completionInsight = ProductivityInsight(
                id: UUID().uuidString,
                title: "Task Completion Speed",
                description: String(format: "Average time to complete tasks: %.1f hours", averageCompletionTime),
                icon: "speedometer",
                priority: .medium,
                category: .efficiency,
                actionable: averageCompletionTime > 4.0 // More than 4 hours
            )
            insights.append(completionInsight)
        }

        // Overdue tasks analysis
        let overdueTasks = pendingTasks.filter { $0.dueDate != nil && $0.dueDate! < Date() }
        if !overdueTasks.isEmpty {
            let overdueInsight = ProductivityInsight(
                id: UUID().uuidString,
                title: "Overdue Tasks",
                description: "You have \(overdueTasks.count) overdue tasks. Consider rescheduling or breaking them down.",
                icon: "exclamationmark.triangle.fill",
                priority: .high,
                category: .issues,
                actionable: true
            )
            insights.append(overdueInsight)
        }

        // Task distribution
        let tasksByPriority = Dictionary(grouping: pendingTasks, by: { $0.priority })
        if let highPriorityCount = tasksByPriority[.high]?.count, highPriorityCount > pendingTasks.count / 2 {
            let balanceInsight = ProductivityInsight(
                id: UUID().uuidString,
                title: "Priority Balance",
                description: "Most of your tasks are high priority. Consider adding some lower-priority tasks for balance.",
                icon: "scale.3d",
                priority: .medium,
                category: .balance,
                actionable: true
            )
            insights.append(balanceInsight)
        }

        return insights
    }

    @MainActor
    private func analyzeGoalProgress(_ goals: [Goal], _ tasks: [PlannerTask]) -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []

        let activeGoals = goals.filter { !$0.isCompleted }

        // Goal progress analysis
        for goal in activeGoals {
            // For now, we'll estimate progress based on task completion related to the goal
            // This could be improved with a proper goal-task relationship
            let relatedTasks = tasks.filter { task in
                task.title.lowercased().contains(goal.title.lowercased().components(separatedBy: " ").first ?? "")
            }
            let completedTasks = relatedTasks.filter { $0.isCompleted }.count
            let totalTasks = relatedTasks.count

            if totalTasks > 0 {
                let progress = Double(completedTasks) / Double(totalTasks)

                if progress < 0.25 {
                    let goalInsight = ProductivityInsight(
                        id: UUID().uuidString,
                        title: "Goal Progress: \(goal.title)",
                        description: String(format: "Only %.0f%% complete. Consider breaking this goal into smaller, actionable steps.", progress * 100),
                        icon: "target",
                        priority: .high,
                        category: .goals,
                        actionable: true
                    )
                    insights.append(goalInsight)
                } else if progress > 0.75 {
                    let momentumInsight = ProductivityInsight(
                        id: UUID().uuidString,
                        title: "Goal Momentum",
                        description: "\(goal.title) is \(Int(progress * 100))% complete. Keep up the great work!",
                        icon: "flame.fill",
                        priority: .medium,
                        category: .motivation,
                        actionable: false
                    )
                    insights.append(momentumInsight)
                }
            }
        }

        return insights
    }

    // MARK: - Helper Methods

    private func calculateCompletionRate(_ activities: [ActivityRecord]) -> Double {
        let taskActivities = activities.filter { $0.type == .taskCompleted || $0.type == .taskCreated }
        guard !taskActivities.isEmpty else { return 0.0 }

        let completedCount = taskActivities.filter { $0.type == .taskCompleted }.count
        return Double(completedCount) / Double(taskActivities.count)
    }

    private func calculateFocusTime(_ activities: [ActivityRecord]) -> Double {
        // Estimate focus time based on activity density
        let timeIntervals = activities.map { $0.timestamp }.sorted()
        guard timeIntervals.count >= 2 else { return 0.0 }

        var totalFocusTime: Double = 0
        var currentSessionStart: Date?

        for (index, timestamp) in timeIntervals.enumerated() {
            if index == 0 {
                currentSessionStart = timestamp
                continue
            }

            let timeGap = timestamp.timeIntervalSince(timeIntervals[index - 1])
            if timeGap > 1800 { // 30 minutes gap ends session
                if let start = currentSessionStart {
                    totalFocusTime += timeIntervals[index - 1].timeIntervalSince(start)
                }
                currentSessionStart = timestamp
            }
        }

        // Add final session
        if let start = currentSessionStart, let end = timeIntervals.last {
            totalFocusTime += end.timeIntervalSince(start)
        }

        return totalFocusTime / 3600 // Convert to hours
    }

    private func calculatePeakProductivityHour(_ timestamps: [Date]) -> Int {
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]

        for timestamp in timestamps {
            let hour = calendar.component(.hour, from: timestamp)
            hourCounts[hour, default: 0] += 1
        }

        return hourCounts.max { $0.value < $1.value }?.key ?? 9 // Default to 9 AM
    }

    private func calculateAverageCompletionTime(_ tasks: [PlannerTask]) -> Double {
        let tasksWithTimes = tasks.compactMap { task -> Double? in
            // For now, we'll use createdAt to completedAt time difference
            // In a real implementation, you'd track when tasks were actually completed
            if task.isCompleted, let completedAt = task.modifiedAt {
                return completedAt.timeIntervalSince(task.createdAt) / 3600 // Hours
            }
            return nil
        }

        guard !tasksWithTimes.isEmpty else { return 0.0 }
        return tasksWithTimes.reduce(0, +) / Double(tasksWithTimes.count)
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }

    private func createTimeSlot(hour: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = 0
        components.second = 0

        // If the time has passed today, schedule for tomorrow
        if let suggestedTime = calendar.date(from: components),
           suggestedTime < now {
            return calendar.date(byAdding: .day, value: 1, to: suggestedTime) ?? now
        }

        return calendar.date(from: components) ?? now
    }

    private func suggestTimeForGoal(_ goal: Goal) -> Date {
        // Suggest time based on goal priority and user's typical schedule
        let calendar = Calendar.current
        let now = Date()

        switch goal.priority {
        case .high:
            // High priority goals: schedule soon
            return now.addingTimeInterval(3600) // 1 hour
        case .medium:
            // Medium priority: next day
            return calendar.date(byAdding: .day, value: 1, to: now) ?? now
        case .low:
            // Low priority: weekend or next week
            let weekday = calendar.component(.weekday, from: now)
            if weekday == 1 || weekday == 7 { // Sunday or Saturday
                return calendar.date(byAdding: .day, value: 3, to: now) ?? now
            } else {
                return calendar.date(byAdding: .day, value: 7, to: now) ?? now
            }
        }
    }

    private func suggestBatchTime(_ priority: TaskPriority) -> Date {
        _ = Calendar.current
        _ = Date()

        // Suggest batch times based on priority
        switch priority {
        case .high:
            return createTimeSlot(hour: 9) // 9 AM
        case .medium:
            return createTimeSlot(hour: 14) // 2 PM
        case .low:
            return createTimeSlot(hour: 16) // 4 PM
        }
    }

    private nonisolated func deduplicateSuggestions(_ suggestions: [TaskSuggestion]) -> [TaskSuggestion] {
        var seen = Set<String>()
        return suggestions.filter { suggestion in
            let key = "\(suggestion.title)-\(suggestion.category.rawValue)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    private nonisolated func prioritizeSuggestions(_ suggestions: [TaskSuggestion]) -> [TaskSuggestion] {
        return suggestions.sorted { lhs, rhs in
            // Sort by priority first, then by urgency, then by confidence
            if lhs.priority != rhs.priority {
                return lhs.priority.rawValue > rhs.priority.rawValue
            }
            if lhs.urgency != rhs.urgency {
                return lhs.urgency.rawValue > rhs.urgency.rawValue
            }
            return lhs.confidence > rhs.confidence
        }
    }
}

// MARK: - Data Models

public struct TaskSuggestion: Identifiable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let reasoning: String
    public let priority: TaskPriority
    public let urgency: TaskUrgency
    public let suggestedTime: Date?
    public let category: SuggestionCategory
    public let confidence: Double

    public enum TaskPriority: String, Codable, CaseIterable {
        case low, medium, high
    }

    public enum TaskUrgency: String, Codable, CaseIterable {
        case low, medium, high
    }

    public enum SuggestionCategory: String, Codable, CaseIterable {
        case productivity, balance, goals, urgent, efficiency
    }
}

public struct ProductivityInsight: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public let priority: InsightPriority
    public let category: InsightCategory
    public let actionable: Bool

    public enum InsightPriority: String, Codable, CaseIterable {
        case low, medium, high
    }

    public enum InsightCategory: String, Codable, CaseIterable {
        case performance, trends, optimization, efficiency, issues, balance, goals, motivation
    }
}

// MARK: - Supporting Types

public enum ActivityType: String, Codable {
    case taskCreated, taskCompleted, goalCreated, goalCompleted
}

public struct ActivityRecord: Codable {
    public let id: String
    public let type: ActivityType
    public let timestamp: Date
}
