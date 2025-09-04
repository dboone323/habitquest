# Git Merge Conflict Resolution Report

Generated: Wed Sep 3 20:00:18 CDT 2025

## Summary

- Location: /Users/danielstevens/Desktop/Quantum-workspace/Projects/MomentumFinance
- Strategy: Chose HEAD version for all conflicts
- Backup files created with .conflict_backup extension

## Files Resolved

Shared/MomentumFinanceApp.swift.conflict_backup
Shared/ContentView.swift.conflict_backup
Shared/Intelligence/FinancialIntelligenceService.swift.conflict_backup
Shared/Features/Features.swift.conflict_backup
Shared/Features/NotificationCenterView.swift.conflict_backup
Shared/Features/GoalsAndReports/EnhancedGoalsSectionViews.swift.conflict_backup
Shared/Features/GoalsAndReports/ReportsViews.swift.conflict_backup
Shared/Features/GoalsAndReports/GoalsAndReportsView.swift.conflict_backup
Shared/Features/GoalsAndReports/GoalUtilityViews.swift.conflict_backup
Shared/Features/GoalsAndReports/SavingsGoalViews.swift.conflict_backup
Shared/Features/GoalsAndReports/SavingsGoalManagementViews.swift.conflict_backup
Shared/Features/GoalsAndReports/GoalsAndReportsViewModel.swift.conflict_backup
Shared/Features/GoalsAndReports/EnhancedReportsSectionViews.swift.conflict_backup
Shared/Features/Subscriptions/SubscriptionsView.swift.conflict_backup
Shared/Features/Subscriptions/SubscriptionManagementViews.swift.conflict_backup
Shared/Features/Subscriptions/SubscriptionSummaryViews.swift.conflict_backup
Shared/Features/Subscriptions/SubscriptionDetailView.swift.conflict_backup
Shared/Features/Subscriptions/SubscriptionRowViews.swift.conflict_backup
Shared/Features/GlobalSearchView.swift.conflict_backup
Shared/Features/Dashboard/InsightsSummaryWidget.swift.conflict_backup
Shared/Features/Dashboard/DashboardViewModel.swift.conflict_backup
Shared/Features/Dashboard/DashboardView.swift.conflict_backup
Shared/Features/Dashboard/InsightsView.swift.conflict_backup
Shared/Features/Dashboard/InsightsWidget.swift.conflict_backup
Shared/Features/Dashboard/SimpleDashboardView.swift.conflict_backup
Shared/Features/Transactions/AccountsListView.swift.conflict_backup
Shared/Features/Transactions/TransactionsViewModel.swift.conflict_backup
Shared/Features/Transactions/AccountDetailView.swift.conflict_backup
Shared/Features/Transactions/CategoryTransactionsView.swift.conflict_backup
Shared/Features/Transactions/TransactionsView.swift.conflict_backup
Shared/Features/NotificationsView.swift.conflict_backup
Shared/Features/Budgets/BudgetsViewModel.swift.conflict_backup
Shared/Features/Budgets/BudgetsView.swift.conflict_backup
Shared/Navigation/NavigationCoordinator.swift.conflict_backup
Shared/Navigation/MacOSNavigationTypes.swift.conflict_backup
Shared/Utils/DataExporter.swift.conflict_backup
Shared/Utils/DataImporter.swift.conflict_backup
Shared/Utils/ExportTypes.swift.conflict_backup
Shared/Utils/HapticManager.swift.conflict_backup
Shared/Models/FinancialAccount.swift.conflict_backup
Shared/Models/ComplexDataGenerators.swift.conflict_backup
Shared/Models/Subscription.swift.conflict_backup
Shared/Models/SampleDataGenerators.swift.conflict_backup
Shared/Models/SavingsGoal.swift.conflict_backup
Shared/Utilities/Logger.swift.conflict_backup
Shared/Utilities/ErrorHandler.swift.conflict_backup
Shared/Utilities/NotificationManager.swift.conflict_backup
Shared/Theme/ThemeManager.swift.conflict_backup
Shared/Theme/ThemePersistence.swift.conflict_backup
Shared/Theme/ThemeDemoView.swift.conflict_backup
Shared/Theme/ColorTheme.swift.conflict_backup
Shared/Theme/ThemeSettingsView.swift.conflict_backup
Shared/Theme/ThemeComponents.swift.conflict_backup
Shared/Views/Settings/DataImportView.swift.conflict_backup
Shared/Views/Settings/DataExportView.swift.conflict_backup
Shared/Views/Settings/SettingsView.swift.conflict_backup
Shared/Animations/AnimationManager.swift.conflict_backup
Shared/Animations/AnimatedComponents.swift.conflict_backup

## Next Steps

1. Review the resolved files to ensure correct changes
2. Test your application functionality
3. Remove backup files when satisfied: `find . -name "*.conflict_backup" -delete`
4. Commit the resolved conflicts: `git add . && git commit -m "Resolve merge conflicts"`

## Quick Commands

- Check for remaining conflicts: `find . -name "*.swift" -exec grep -l "<<<<<<< HEAD" {} \;`
- Remove backups: `find . -name "*.conflict_backup" -delete`
- Test build: `swift build`
