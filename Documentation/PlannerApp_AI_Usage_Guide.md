# PlannerApp AI Features Usage Guide

## Overview

PlannerApp includes advanced AI-powered features that help users optimize their productivity through intelligent task suggestions, natural language processing, and productivity insights. This guide explains how to use these features effectively.

## AI-Powered Task Creation

### Natural Language Task Parsing

The AI service can understand natural language input to create tasks with appropriate priorities, due dates, and times.

#### Basic Task Creation
```swift
let aiService = AITaskPrioritizationService.shared

// Simple task
let task1 = try await aiService.parseNaturalLanguageTask("Buy groceries tomorrow")

// Task with priority
let task2 = try await aiService.parseNaturalLanguageTask("Urgent: Finish project report by Friday")

// Task with specific time
let task3 = try await aiService.parseNaturalLanguageTask("Call dentist at 2pm tomorrow")
```

#### Supported Patterns
- **Priority indicators**: "urgent", "important", "asap", "high priority", "low priority"
- **Time expressions**: "today", "tomorrow", "next week", "at 2pm", "by 3pm"
- **Date references**: "Monday", "this Friday", "end of week"

## AI Task Suggestions

### Getting Intelligent Suggestions

The AI analyzes your task patterns, activity history, and goals to provide personalized suggestions.

```swift
// Get current data
let tasks = TaskDataManager.shared.load()
let goals = GoalDataManager.shared.load()
let activities = getRecentActivities() // Your activity tracking

// Generate suggestions
let suggestions = aiService.generateTaskSuggestions(
    currentTasks: tasks,
    recentActivity: activities,
    userGoals: goals
)

// Display top suggestions
for suggestion in suggestions.prefix(3) {
    print("\(suggestion.title): \(suggestion.reasoning)")
}
```

### Suggestion Categories

- **Productivity**: Suggestions based on your peak productivity times
- **Balance**: Recommendations to balance high vs low priority tasks
- **Goals**: Focus suggestions for goals that need attention
- **Urgent**: Actions needed for overdue tasks
- **Efficiency**: Batching suggestions for similar tasks

## Productivity Insights

### Analyzing Your Productivity

The AI service provides deep insights into your work patterns and productivity trends.

```swift
// Generate insights
let insights = aiService.generateProductivityInsights(
    activityData: activities,
    taskData: tasks,
    goalData: goals
)

// Display insights
for insight in insights {
    print("📊 \(insight.title)")
    print("   \(insight.description)")
    if insight.actionable {
        print("   💡 Action recommended")
    }
}
```

### Insight Categories

- **Performance**: Productivity scores and completion rates
- **Trends**: Weekly/monthly progress analysis
- **Optimization**: Peak productivity time identification
- **Efficiency**: Task completion speed analysis
- **Issues**: Overdue tasks and bottlenecks
- **Balance**: Priority distribution analysis
- **Goals**: Goal progress tracking
- **Motivation**: Encouragement for good progress

## Dashboard Integration

### Using AI Features in DashboardViewModel

The dashboard automatically integrates AI features for a smart, personalized experience.

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    private let aiService = AITaskPrioritizationService.shared

    // AI features are automatically updated
    @Published var aiSuggestions: [AISuggestion] = []
    @Published var productivityInsights: [ProductivityInsight] = []

    // Refresh includes AI updates
    func refreshData() async {
        // ... existing data loading ...

        // AI features update automatically with caching
        await updateAISuggestions()
        await updateProductivityInsights()
    }
}
```

### Caching Behavior

AI features use intelligent caching to balance responsiveness with freshness:

- **Data Cache**: 60 seconds TTL for task/goal/event data
- **AI Cache**: 5 minutes TTL for suggestions and insights
- **Debouncing**: 300ms delay for user input to prevent excessive API calls

## Best Practices

### Performance Optimization

1. **Cache Management**: AI results are cached to minimize processing overhead
2. **Background Processing**: Heavy AI analysis runs on background threads
3. **Debounced Updates**: User input is debounced to prevent excessive calculations

### Data Quality

1. **Activity Tracking**: More activity data improves AI accuracy
2. **Goal Relationships**: Linking tasks to goals provides better suggestions
3. **Regular Updates**: Keep data current for optimal AI performance

### User Experience

1. **Progressive Disclosure**: AI features enhance but don't replace manual control
2. **Actionable Insights**: All suggestions include clear reasoning and next steps
3. **Privacy First**: All AI processing happens locally on device

## Troubleshooting

### Common Issues

**AI suggestions not updating:**
- Check that activity data is being recorded
- Verify cache timeouts (default 5 minutes)
- Ensure background processing isn't blocked

**Poor suggestion quality:**
- More historical data improves accuracy
- Check goal-task relationships
- Review activity tracking completeness

**Performance issues:**
- AI processing is debounced and cached
- Heavy analysis runs in background
- Consider data cleanup for large datasets

## Integration Examples

### TaskInputView Integration

```swift
struct TaskInputView: View {
    @State private var inputText = ""
    private let aiService = AITaskPrioritizationService.shared

    func createTask() async {
        if let aiTask = try? await aiService.parseNaturalLanguageTask(inputText) {
            // Use AI-parsed task
            saveTask(aiTask)
        } else {
            // Fallback to manual parsing
            let manualTask = PlannerTask(title: inputText)
            saveTask(manualTask)
        }
    }
}
```

### Dashboard Enhancement

```swift
struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            // ... existing content ...

            // AI Suggestions Section
            if !viewModel.aiSuggestions.isEmpty {
                AISuggestionsSection(suggestions: viewModel.aiSuggestions)
            }

            // Productivity Insights Section
            if !viewModel.productivityInsights.isEmpty {
                ProductivityInsightsSection(insights: viewModel.productivityInsights)
            }
        }
        .task {
            await viewModel.refreshData()
        }
    }
}
```

## API Reference

For detailed API documentation, see `PlannerApp_API.md` in the Documentation/API directory.

## Future Enhancements

- **Machine Learning Models**: Integration with Core ML for improved predictions
- **Cloud Sync**: Server-side AI processing for enhanced insights
- **Personalization**: Learning user preferences over time
- **Collaboration**: AI-powered team productivity features</content>
<parameter name="filePath">/Users/danielstevens/Desktop/Quantum-workspace/Documentation/PlannerApp_AI_Usage_Guide.md