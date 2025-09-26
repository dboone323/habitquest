# MomentumFinance Changelog

## [Unreleased]

- Add additional domain-specific test coverage (forecasting, insights) (planned)

## [2025-09-21] Core Framework Extraction & Access Control Refinements

### Added

- Introduced `MomentumFinanceCore` framework target housing non-UI domain models & import/export logic.
- New tests:
  - `CSVParserEdgeCasesTests` covering malformed rows, embedded quotes, delimiter edge cases.
  - `DataExporterContentTests` validating exported CSV content integrity (headers, row counts, date filtering).
- Public `Logger` utility (moved to Core) with performance/context logging support.

### Changed

- Pruned app target of duplicated model/logic sources; now imports via `@_exported import MomentumFinanceCore` for simplified downstream usage.
- Made key model properties & APIs public across modules:
  - `FinancialAccount` (name, balance, iconName, accountType, currencyCode, creditLimit, transactions, subscriptions, updateBalance).
  - `FinancialTransaction` (title, amount, date, transactionType, notes, category, account, formatted helpers).
  - `Budget` (name, limitAmount, month, category, computed financial metrics & formatters).
  - `ExpenseCategory` already public; ensured relationships exposed.
  - `Subscription` (billingCycle helpers, amount formatting, lifecycle/payment APIs, active state, due date, monthly equivalent, icon).
  - `SavingsGoal` (targetAmount, currentAmount, notes, createdDate, removeFunds + existing formatted helpers).
  - Export-related enums (`ExportFormat`, `DateRange` displayName/icon) made public.
  - `FinancialInsightType.icon` exposed for dashboard usage.
- Replaced placeholder `Category` usage in budget creation flow with concrete `ExpenseCategory` model.

### Fixed

- Series of build failures due to internal access after modularization (public exposure resolved UI compilation & test execution).
- Invalid type mismatches in `BudgetsView` arising from placeholder `Category` type.

### Notes

- All test suites now pass on iOS Simulator (iPhone 16 Pro, iOS 18.0).
- Next candidates for Core migration/documentation: advanced insight engines & predictive analytics once stabilized.

## [2025-09-20] Modularization & Test Introduction

### Added

- New test target `MomentumFinanceTests` with initial suites:
  - `CSVParserTests` covering CSV row parsing, header mapping, date & amount parsing.
  - `DataExporterDateRangeTests` validating date range filtering during export.
  - `DataImporterErrorTests` exercising empty file, invalid amount, and partial success scenarios.
- `BreadcrumbNavigation.swift` introducing dedicated navigation types (`BreadcrumbItem`, `DeepLink`).
- `FinancialInsightModels.swift` defining `FinancialInsight` and `FinancialInsightType`.

### Changed

- Extracted dashboard, transaction, and data import SwiftUI components into:
  - `DashboardComponents.swift`
  - `TransactionComponents.swift`
  - `DataImportComponents.swift`
- Refactored monolithic `MissingTypes.swift` by removing duplicated & UI content; file fully removed after migration.
- `ImportExport.swift` includes date-range aware export via `ExportSettings(startDate:endDate:)`.

### Removed

- Legacy `MissingTypes.swift` stub (replaced by modular files above).

### Notes

- Test data uses in-memory SwiftData `ModelContainer` for isolation.
- Further tests recommended for: JSON/PDF export branches when implemented, entity manager integration, and ML/insight generation flows.
