# PlannerApp API Reference

**Generated:** Sun Oct 12 09:52:58 CDT 2025
**Type:** Manual Documentation

## Public API Overview

### Public Classes

- `public class DashboardViewModel: BaseViewModel, ObservableObject `
- `public class OllamaClient: ObservableObject `
- `public class OllamaIntegrationManager: AITextGenerationService, AICodeAnalysisService, AICodeGenerationService, AICachingService, AIPerformanceMonitoring, @unchecked Sendable `
- `public class CloudKitManager: ObservableObject, CloudKitService `
- `public class ContentViewTests: XCTestCase `
- `public class ThemeManager: ObservableObject `
- `public class AccessibilityManager: ObservableObject `
- `public class AITaskPrioritizationService: ObservableObject `

### Public Structs

- `public struct AISuggestion: Identifiable `
- `public struct DashboardActivity: Identifiable `
- `public struct UpcomingItem: Identifiable `
- `public struct State `
- `public struct PlannerTask: Identifiable, Codable `
- `public struct Goal: Identifiable, Codable `
- `public struct JournalEntry: Identifiable, Codable `
- `public struct OllamaConfig `
- `public struct OllamaMessage: Codable `
- `public struct OllamaGenerateResponse: Codable `
- `public struct OllamaServerStatus `
- `public struct ServiceHealth `
- `public struct CodeGenerationResult `
- `public struct CodeAnalysisResult `
- `public struct CodeIssue `
- `public struct DocumentationResult `
- `public struct TestGenerationResult `
- `public struct AutomationTask `
- `public struct TaskResult `
- `public struct HealthStats `
- `public struct CurrentHealth `
- `public struct ServiceHealth: Codable, Sendable `
- `public struct CodeAnalysisResult: Codable, Sendable `
- `public struct CodeIssue: Codable, Sendable `
- `public struct CodeGenerationResult: Codable, Sendable `
- `public struct CacheStats: Codable, Sendable `
- `public struct PerformanceMetrics: Codable, Sendable `
- `public struct AIServiceInfo: Codable, Sendable `
- `public struct AIOperation: Codable, Sendable `
- `public struct AIOperationResult: Codable, Sendable `
- `public struct ServiceHealthOverview: Codable, Sendable `
- `public struct AIServiceConfiguration: Codable, Sendable `
- `public struct RateLimit: Codable, Sendable `
- `public struct AnyCodable: Codable, Sendable `
- `public struct CloudKitOnboardingView: View `
- `public struct EnhancedSyncStatusView: View `
- `public struct EnhancedSyncStatusView: View `
- `public struct SyncConflict: Identifiable `
- `public struct ContentView: View `
- `public struct CalendarEvent: Identifiable, Codable `
- `public struct Goal: Identifiable, Codable `
- `public struct JournalEntry: Identifiable, Codable `
- `public struct PlannerTask: Identifiable, Codable, Transferable `
- `public struct JournalRow: View `
- `public struct JournalRow_Previews: PreviewProvider `
- `public struct JournalEmptyStateView: View `
- `public struct JournalEmptyStateView_Previews: PreviewProvider `
- `public struct JournalHeaderView: View `
- `public struct JournalHeaderView_Previews: PreviewProvider `
- `public struct JournalListView: View `
- `public struct JournalListView_Previews: PreviewProvider `
- `public struct TaskListView: View `
- `public struct TaskManagerHeaderView: View `
- `public struct TaskInputView: View `
- `public struct TaskRow: View `
- `public struct GoalItemView: View `
- `public struct ProgressUpdateSheet: View `
- `public struct GoalsEmptyStateView: View `
- `public struct GoalsListView: View `
- `public struct GoalsHeaderView: View `
- `public struct MacOSSidebarView: View `
- `public struct IPadSidebarView: View `
- `public struct MacOSToolbarButtons: View `
- `public struct IPadToolbarButtons: View `
- `public struct IPhoneToolbarButtons: View `
- `public struct QuickActionButton: View `
- `public struct KeyboardShortcutsView: View `
- `public struct ShortcutRow: View `
- `public struct ModernButton: View `
- `public struct ProgressBar: View `
- `public struct ModernTextField: View `
- `public struct QuickActionCard: View `
- `public struct QuickStatCard: View `
- `public struct UpcomingItemView: View `
- `public struct SidebarView: View `
- `public struct PlatformToolbar: ViewModifier `
- `public struct ExamplePlatformView: View `
- `public struct AnimatedProgressRing: View `
- `public struct ProgressChangeModifier: ViewModifier `
- `public struct FloatingActionButton: View `
- `public struct ParticleSystem: View `
- `public struct ShimmerView: View `
- `public struct VisualEnhancementsPreview: View `
- `public struct Theme: Identifiable, Equatable, Sendable `
- `public struct AccessibleButton: View `
- `public struct HighContrastModifier: ViewModifier `
- `public struct ReducedMotionModifier: ViewModifier `
- `public struct FocusChangeModifier: ViewModifier `
- `public struct DynamicTypeText: View `
- `public struct AccessibleProgressView: View `
- `public struct AccessibilityDemoView: View `
- `public struct JournalDetailView: View `
- `public struct JournalDetailView_Previews: PreviewProvider `
- `public struct JournalView: View `
- `public struct JournalView_Previews: PreviewProvider `
- `public struct AddJournalEntryView: View `
- `public struct DashboardView: View `
- `public struct DashboardView: View `
- `public struct QuickStatCard: View `
- `public struct QuickActionCard: View `
- `public struct ActivityRowView: View `
- `public struct UpcomingItemView: View `
- `public struct MainTabView: View `
- `public struct MainTabView_Previews: PreviewProvider `
- `public struct SettingsView: View `
- `public struct ThemePreviewSheet: View `
- `public struct ThemeCard: View `
- `public struct SettingsView_Previews: PreviewProvider `
- `public struct SettingsView: View `
- `public struct ThemePreviewSheet: View `
- `public struct ThemeCard: View `
- `public struct SettingsView_Previews: PreviewProvider `
- `public struct NotificationToggleModifier: ViewModifier `
- `public struct SettingsViewBackup: View `
- `public struct SettingsView: View `
- `public struct SettingsView_Previews: PreviewProvider `
- `public struct SettingsView: View `
- `public struct CloudKitSettingsView: View `
- `public struct ThemePreviewSheet: View `
- `public struct ThemeCard: View `
- `public struct SettingsView_Previews: PreviewProvider `
- `public struct ThemePreviewView: View `
- `public struct ThemePreviewCard: View `
- `public struct SettingsView: View `
- `public struct DashboardUpcomingItemsSection: View `
- `public struct TaskInputView: View `
- `public struct TaskManagerView: View `
- `public struct GoalRowView: View `
- `public struct CalendarGrid: View `
- `public struct CalendarDayView: View `
- `public struct CalendarView: View `
- `public struct CalendarView_Previews: PreviewProvider `
- `public struct AddCalendarEventView: View `
- `public struct TaskRowView: View `
- `public struct EventRowView: View `
- `public struct CalendarView: View `
- `public struct CalendarView_Previews: PreviewProvider `
- `public struct AddGoalView: View `
- `public struct AddGoalView: View `
- `public struct AddGoalView_Previews: PreviewProvider `
- `public struct GoalsView: View `
- `public struct GoalsView_Previews: PreviewProvider `
- `public struct AddGoalView: View `
- `public struct AddGoalView_Previews: PreviewProvider `
- `public struct AddGoalView: View `
- `public struct AddGoalView: View `
- `public struct AddGoalView: View `
- `public struct AddGoalView_Previews: PreviewProvider `
- `public struct PlannerApp: App `
- `public struct MainTabViewEnhanced: View `
- `public struct AIView: View `
- `public struct DashboardQuickStatsSection: View `
- `public struct QuickStatCard: View `
- `public struct DashboardQuickActionsSection: View `
- `public struct QuickActionCard: View `
- `public struct DashboardWelcomeHeaderSection: View `
- `public struct DashboardRecentActivitiesSection: View `
- `public struct ActivityRowView: View `
- `public struct Dependencies `
- `public struct TaskSuggestion: Identifiable, Codable `
- `public struct ProductivityInsight: Identifiable, Codable `
- `public struct ActivityRecord: Codable `

### Public Enums

- `public enum Action `
- `public enum TaskPriority: String, CaseIterable, Codable `
- `public enum GoalPriority: String, CaseIterable, Codable `
- `public enum OllamaIntegration `
- `public enum OllamaError: LocalizedError `
- `public enum CodeComplexity `
- `public enum AnalysisType `
- `public enum IssueSeverity `
- `public enum TaskType `
- `public enum IntegrationError: Error `
- `public enum IssueSeverity: String, Codable, Sendable `
- `public enum AnalysisType: String, Codable, Sendable `
- `public enum CodeComplexity: String, Codable, Sendable `
- `public enum AIServiceType: String, Codable, Sendable `
- `public enum AICapability: String, Codable, Sendable `
- `public enum AIOperationType: String, Codable, Sendable `
- `public enum OperationPriority: String, Codable, Sendable `
- `public enum AIError: Error, LocalizedError `
- `public enum SyncStatus: Equatable `
- `public enum ConflictType `
- `public enum CloudKitError: Error, Identifiable `
- `public enum GoalPriority: String, CaseIterable, Codable `
- `public enum TaskPriority: String, CaseIterable, Codable, Sendable `
- `public enum LogLevel: String `
- `public enum TaskPriority: String, Codable, CaseIterable `
- `public enum TaskUrgency: String, Codable, CaseIterable `
- `public enum SuggestionCategory: String, Codable, CaseIterable `
- `public enum InsightPriority: String, Codable, CaseIterable `
- `public enum InsightCategory: String, Codable, CaseIterable `
- `public enum ActivityType: String, Codable `
- `public enum DataManagerError: Error `

### Public Protocols

- `public protocol BaseViewModel: AnyObject `
- `public protocol BaseViewModel: AnyObject `
- `public protocol AITextGenerationService `
- `public protocol AICodeAnalysisService `
- `public protocol AICodeGenerationService `
- `public protocol AICachingService `
- `public protocol AIPerformanceMonitoring `
- `public protocol AIServiceCoordinator `
- `public protocol AIConfigurationService `


## Usage

For detailed usage examples, see the source files in:
`/Users/danielstevens/Desktop/Quantum-workspace/Projects/PlannerApp/`

## Architecture Notes

This project follows the Quantum Workspace architecture patterns. See [ARCHITECTURE.md](../../ARCHITECTURE.md) for details.

---

*For full HTML documentation, run:*
```bash
jazzy --module PlannerApp --output Documentation/API/PlannerApp
```
