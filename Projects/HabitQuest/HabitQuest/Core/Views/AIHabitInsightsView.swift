import Foundation // For AI types access
import SwiftData
import SwiftUI

// Import AI types from AITypes.swift

// MARK: - AI Habit Insights UI Components

/// Main view for displaying AI-powered habit insights and predictions
@available(iOS 13.0, macOS 10.15, *)
public struct AIHabitInsightsView: View {
    @StateObject private var smartManager: SmartHabitManager
    @State private var selectedTab: AIInsightsTab = .overview

    public init(smartManager: SmartHabitManager) {
        _smartManager = StateObject(wrappedValue: smartManager)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // AI Status Header
                AIStatusHeaderView(status: smartManager.state.aiProcessingStatus)

                // Tab Selection
                AIInsightsTabView(selectedTab: $selectedTab)

                // Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch selectedTab {
                        case .overview:
                            AIOverviewContent(smartManager: smartManager)
                        case .predictions:
                            HabitPredictionsContent(smartManager: smartManager)
                        case .insights:
                            HabitInsightsContent(smartManager: smartManager)
                        case .suggestions:
                            HabitSuggestionsContent(smartManager: smartManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Habit Insights")
            #if os(iOS)
            .navigationBarItems(trailing: Button("Refresh") {
                smartManager.handle(.updatePredictions)
            })
            #endif
        }
    }
}

// MARK: - AI Status Header

private struct AIStatusHeaderView: View {
    let status: AIProcessingStatus

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Analysis Status")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(statusDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusIndicatorView(status: status)
            }

            // Quick Actions
            HStack(spacing: 12) {
                ActionButton(
                    title: "Analyze All",
                    icon: "brain.head.profile",
                    color: .blue
                ) {
                    // Trigger comprehensive analysis
                }

                ActionButton(
                    title: "Get Tips",
                    icon: "lightbulb",
                    color: .yellow
                ) {
                    // Generate personalized tips
                }

                ActionButton(
                    title: "Predictions",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                ) {
                    // Update predictions
                }
            }
        }
        .padding()
        .background(systemBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var systemBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.controlBackgroundColor)
        #endif
    }

    private var statusDescription: String {
        switch status {
        case .idle:
            "Ready for analysis"
        case .processing:
            "Analyzing your habits..."
        case .completed:
            "Analysis complete"
        case .failed:
            "Analysis error occurred"
        }
    }
}

private struct StatusIndicatorView: View {
    let status: AIProcessingStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .scaleEffect(status == .processing ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: status)

            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
    }

    private var statusColor: Color {
        switch status {
        case .idle:
            .green
        case .processing:
            .blue
        case .completed:
            .green
        case .failed:
            .red
        }
    }

    private var statusText: String {
        switch status {
        case .idle:
            "Idle"
        case .processing:
            "Processing"
        case .completed:
            "Completed"
        case .failed:
            "Failed"
        }
    }
}

private struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab View

private enum AIInsightsTab: String, CaseIterable {
    case overview = "Overview"
    case predictions = "Predictions"
    case insights = "Insights"
    case suggestions = "Suggestions"

    var icon: String {
        switch self {
        case .overview:
            "square.grid.2x2"
        case .predictions:
            "chart.line.uptrend.xyaxis"
        case .insights:
            "lightbulb"
        case .suggestions:
            "star"
        }
    }
}

private struct AIInsightsTabView: View {
    @Binding var selectedTab: AIInsightsTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AIInsightsTab.allCases, id: \.self) { tab in
                    AIInsightsTabButton(
                        tab: tab,
                        isSelected: tab == selectedTab
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(tabBackgroundColor)
    }

    private var tabBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

private struct AIInsightsTabButton: View {
    let tab: AIInsightsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))

                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Content Views

private struct AIOverviewContent: View {
    @ObservedObject var smartManager: SmartHabitManager

    var body: some View {
        VStack(spacing: 16) {
            // Quick Stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Habits Analyzed",
                    value: "\(smartManager.state.habits.count)",
                    icon: "list.bullet",
                    color: .blue
                )

                StatCard(
                    title: "AI Insights",
                    value: "\(smartManager.state.aiInsights.count)",
                    icon: "brain.head.profile",
                    color: .purple
                )

                StatCard(
                    title: "Predictions",
                    value: "\(smartManager.state.habitPredictions.count)",
                    icon: "chart.bar.fill",
                    color: .green
                )

                StatCard(
                    title: "Suggestions",
                    value: "\(smartManager.state.habitSuggestions.count)",
                    icon: "star.fill",
                    color: .orange
                )
            }

            // Recent Activity
            if !smartManager.state.aiInsights.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent AI Activity")
                        .font(.headline)

                    LazyVStack(spacing: 8) {
                        ForEach(smartManager.state.aiInsights.prefix(3)) { insight in
                            AIActivityItem(insight: insight)
                        }
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
            }
        }
    }

    private var cardBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.controlBackgroundColor)
        #endif
    }
}

private struct HabitPredictionsContent: View {
    @ObservedObject var smartManager: SmartHabitManager

    var body: some View {
        VStack(spacing: 16) {
            if smartManager.state.habitPredictions.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Predictions Yet",
                    message: "Generate predictions to see your habit success probabilities."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(smartManager.state.habits) { habit in
                        if let prediction = smartManager.state.habitPredictions[habit.id] {
                            HabitPredictionCard(habit: habit, prediction: prediction)
                        }
                    }
                }
            }

            // Generate Predictions Button
            Button("Generate New Predictions") {
                smartManager.handle(.generateSuccessPredictions)
            }
            .buttonStyle(.borderedProminent)
            .disabled(smartManager.state.aiProcessingStatus == .processing)
        }
    }
}

private struct HabitInsightsContent: View {
    @ObservedObject var smartManager: SmartHabitManager

    var body: some View {
        VStack(spacing: 16) {
            if smartManager.state.aiInsights.isEmpty {
                EmptyStateView(
                    icon: "lightbulb",
                    title: "No Insights Yet",
                    message: "Add journal entries to your habits to generate AI insights."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(smartManager.state.aiInsights) { insight in
                        HabitInsightCard(insight: insight)
                    }
                }
            }
        }
    }
}

private struct HabitSuggestionsContent: View {
    @ObservedObject var smartManager: SmartHabitManager

    var body: some View {
        VStack(spacing: 16) {
            if smartManager.state.habitSuggestions.isEmpty {
                EmptyStateView(
                    icon: "star",
                    title: "No Suggestions Yet",
                    message: "Generate personalized habit suggestions based on your patterns."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(smartManager.state.habitSuggestions) { suggestion in
                        HabitSuggestionCard(suggestion: suggestion)
                    }
                }
            }

            // Generate Suggestions Button
            Button("Generate New Suggestions") {
                smartManager.handle(.generateHabitSuggestions)
            }
            .buttonStyle(.borderedProminent)
            .disabled(smartManager.state.aiProcessingStatus == .processing)
        }
    }
}

// MARK: - Card Components

private struct AIActivityItem: View {
    let insight: AIHabitInsight

    var body: some View {
        HStack {
            Image(systemName: iconForInsightType(insight.type))
                .foregroundColor(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(titleForInsightType(insight.type))
                    .font(.system(size: 14, weight: .medium))

                Text(insight.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(motivationText(insight.motivationLevel))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(colorForMotivation(insight.motivationLevel))
        }
        .padding(.vertical, 4)
    }

    private func iconForInsightType(_ type: AIHabitInsight.AIInsightCategory) -> String {
        switch type {
        case .journalAnalysis:
            "text.bubble"
        case .success:
            "checkmark.circle.fill"
        case .warning:
            "exclamationmark.triangle.fill"
        case .opportunity:
            "star.fill"
        case .trend:
            "chart.line.uptrend.xyaxis"
        }
    }

    private func titleForInsightType(_ type: AIHabitInsight.AIInsightCategory) -> String {
        switch type {
        case .journalAnalysis:
            "Journal Analysis"
        case .success:
            "Success Insight"
        case .warning:
            "Warning"
        case .opportunity:
            "Opportunity"
        case .trend:
            "Trend Analysis"
        }
    }

    private func motivationText(_ level: AIMotivationLevel) -> String {
        switch level {
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        }
    }

    private func colorForMotivation(_ level: AIMotivationLevel) -> Color {
        switch level {
        case .high:
            .green
        case .medium:
            .blue
        case .low:
            .red
        }
    }
}

private struct HabitPredictionCard: View {
    let habit: AIHabit
    let prediction: AIHabitPrediction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.name)
                    .font(.headline)

                Spacer()

                Text("\(Int(prediction.successProbability * 100))%")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(successColor(prediction.successProbability))
            }

            // Success Probability Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(successColor(prediction.successProbability))
                        .frame(width: geometry.size.width * prediction.successProbability, height: 8)
                }
            }
            .frame(height: 8)

            // Confidence and Recommendations
            HStack {
                VStack(alignment: .leading) {
                    Text("Confidence: \(Int(prediction.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !prediction.factors.isEmpty {
                        Text(prediction.factors[0])
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: successIcon(prediction.successProbability))
                    .foregroundColor(successColor(prediction.successProbability))
                    .font(.title2)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private var cardBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.controlBackgroundColor)
        #endif
    }

    private func successColor(_ probability: Double) -> Color {
        switch probability {
        case 0.7...:
            .green
        case 0.4..<0.7:
            .yellow
        default:
            .red
        }
    }

    private func successIcon(_ probability: Double) -> String {
        switch probability {
        case 0.7...:
            "checkmark.circle.fill"
        case 0.4..<0.7:
            "exclamationmark.triangle.fill"
        default:
            "xmark.circle.fill"
        }
    }
}

private struct HabitInsightCard: View {
    let insight: AIHabitInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insightTypeText(insight.type))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(insight.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Motivation Level
            HStack {
                VStack(alignment: .leading) {
                    Text("Motivation: \(motivationText(insight.motivationLevel))")
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(Int(insight.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Description
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private var cardBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.controlBackgroundColor)
        #endif
    }

    private func insightTypeText(_ type: AIHabitInsight.AIInsightCategory) -> String {
        switch type {
        case .journalAnalysis:
            "Journal Analysis"
        case .success:
            "Success Insight"
        case .warning:
            "Warning"
        case .opportunity:
            "Opportunity"
        case .trend:
            "Trend Analysis"
        }
    }

    private func motivationText(_ level: AIMotivationLevel) -> String {
        switch level {
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        }
    }
}

private struct HabitSuggestionCard: View {
    let suggestion: AnalyticsHabitSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(suggestion.name)
                    .font(.headline)

                Spacer()

                Text("\(Int(suggestion.expectedSuccess * 100))%")
                    .font(.subheadline)
                    .foregroundColor(successColor(suggestion.expectedSuccess))
            }

            Text(suggestion.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(categoryEmoji(suggestion.category))
                Text(suggestion.category.rawValue.capitalized)
                    .font(.caption)

                Spacer()

                Text(suggestion.difficulty.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }

            Text(suggestion.reasoning)
                .font(.caption)
                .foregroundColor(.blue)
                .italic()
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    private var cardBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(.controlBackgroundColor)
        #endif
    }

    private func successColor(_ rate: Double) -> Color {
        switch rate {
        case 0.7...:
            .green
        case 0.4..<0.7:
            .yellow
        default:
            .red
        }
    }

    private func categoryEmoji(_ category: AnalyticsHabitCategory) -> String {
        switch category {
        case .health: "❤️"
        case .fitness: "💪"
        case .learning: "📚"
        case .productivity: "⚡"
        case .social: "👥"
        case .creativity: "🎨"
        case .mindfulness: "🧘"
        case .other: "📌"
        }
    }
}

private struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Journal Analysis Input View

/// View for entering journal entries and triggering AI analysis
@available(iOS 13.0, macOS 10.15, *)
public struct JournalAnalysisView: View {
    @ObservedObject var smartManager: SmartHabitManager
    let habit: Habit

    @State private var journalEntry = ""
    @State private var isAnalyzing = false

    public var body: some View {
        VStack(spacing: 16) {
            Text("Habit Journal")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Write about your experience with '\(habit.name)' today:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextEditor(text: $journalEntry)
                .frame(minHeight: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            HStack {
                Spacer()

                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                }

                Button("Analyze with AI") {
                    analyzeJournal()
                }
                .buttonStyle(.borderedProminent)
                .disabled(journalEntry.isEmpty || isAnalyzing)
            }

            // Show latest insight for this habit
            if let latestInsight = smartManager.state.aiInsights
                .filter({ $0.habitId == habit.id })
                .sorted(by: { $0.timestamp > $1.timestamp })
                .first {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Latest AI Insight")
                        .font(.headline)

                    Text("Motivation Level: \(motivationText(latestInsight.motivationLevel))")
                        .font(.subheadline)

                    Text(latestInsight.description)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    private func analyzeJournal() {
        isAnalyzing = true
        smartManager.handle(.analyzeJournalEntry(journalEntry, habitId: habit.id))

        // Reset after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isAnalyzing = false
            journalEntry = ""
        }
    }

    private func motivationText(_ level: AIMotivationLevel) -> String {
        switch level {
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        }
    }
}
