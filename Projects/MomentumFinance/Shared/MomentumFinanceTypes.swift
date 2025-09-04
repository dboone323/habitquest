//
//  MomentumFinanceTypes.swift
//  MomentumFinance
//
//  Comprehensive type definitions for MomentumFinance app
//  This file consolidates types that were scattered across subdirectories
//  to resolve build target inclusion issues.
//

import Foundation
import OSLog
import SwiftUI
import UserNotifications

// NOTE: Notification types and schedulers were intentionally removed from this aggregated
// types file. The canonical implementations live under
// `Shared/Utilities/NotificationComponents/` and `Shared/Utilities/NotificationTypes.swift`.
// Keeping duplicate implementations here caused invalid redeclarations. Use the
// canonical types (e.g. `NotificationPermissionManager`, `BudgetNotificationScheduler`,
// `SubscriptionNotificationScheduler`, `GoalNotificationScheduler`, `NotificationUrgency`,
// and `ScheduledNotification`) from the NotificationComponents module.

// Navigation types have been moved to Shared/Navigation/NavigationTypes.swift
// to avoid duplicate type definitions and compilation conflicts.

// Search types are provided by the GlobalSearch feature under
// `Shared/Features/GlobalSearch/Components`. Do not duplicate them here.

// Data import types have been moved to Shared/Models/DataImportModels.swift
// to avoid duplicate type definitions and compilation conflicts.

// MARK: - Intelligence Types

// Canonical intelligence implementations live under:
// - Shared/Intelligence/Components/FinancialMLModels.swift
// - Shared/Intelligence/Components/TransactionPatternAnalyzer.swift
// Remove duplicate stubs to avoid invalid redeclaration errors; use the
// concrete implementations above when performing analysis or ML operations.

// Animation components have been moved to Shared/Animations/AnimationTypes.swift
// to avoid duplicate type definitions and compilation conflicts.
