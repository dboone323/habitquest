# HabitQuest - Master Plan & Implementation Roadmap

This document serves as the **Single Source of Truth** for the development, security, and quality roadmap of the HabitQuest project. It consolidates information from previous triages, implementation plans, and automated security audits.

---

## 🚀 1. Feature Roadmap

### Streak Visualization & Celebrations

_Based on `STREAK_IMPLEMENTATION_PLAN.md`_

- [ ] **Phase 2: Visual Components**
    - Animated streak counters with fire/flame effects.
    - Streak progress bars and milestone indicators.
    - Streak calendar heat map view.
    - Streak intensity visual feedback.
- [ ] **Phase 3: Celebration System**
    - Milestone achievement detection logic.
    - Celebration animations and confetti effects.
    - Special badges for streak milestones (3, 7, 30, 100, 365 days).
    - Achievement notification system.
- [ ] **Phase 4: Integration**
    - Integrate visualizations into `TodaysQuestsView`.
    - Update `ProfileView` with advanced streak analytics.

---

## 🛠 2. Code Quality & Refactoring

### Architecture & File Splitting

_Based on `HABITQUEST_TRIAGE.md` and `NEXT_STEPS.md`_

- [/] **Large File Decomposition**
    - [x] Splitted `ContentView.swift` (Consolidated into extensions for stability).
    - [x] Splitted `AchievementService.swift` (Consolidated into extensions for stability).
    - [ ] Split `ProfileView.swift` into modular subviews (`ProfileView+Sections.swift`).
    - [ ] Extract `AnalyticsService` helper handlers into separate files.
    - [ ] Refactor `AdvancedAnalyticsEngine` internals into private helper types.
- [ ] **Function Optimization**
    - [ ] Refactor `DataExportService.swift`: Break long functions into named helpers to reduce nesting and `function_body_length`.
    - [ ] Refactor `AnalyticsTestView.swift` helpers.

### Linting & Style (SwiftLint)

- [x] Resolve all serious violations (current status: 0 violations in core files).
- [ ] **Continuous Polish**
    - Short identifier renames (e.g., `up` -> `upDirection`).
    - Fix remaining `line_length` violations (> 120 chars) incrementally.

---

## 🛡 3. Security & Compliance

_Source: `HabitQuest_security_report.md` (Oct 2025)_

### 🔴 Critical Actions (Immediate)

- [ ] **Remove Hardcoded Secrets**: Audit and move secrets to secure storage/environment variables in:
    - `SecurityFramework.swift`, `OllamaClient.swift`, `HuggingFaceClient.swift`, `ContentGenerationService.swift`, `NotificationSchedulerService.swift`, `OllamaIntegrationManager.swift`.
- [ ] **Data Encryption**: Implement encryption for sensitive data stored in `DataManagementViewModel.swift`.

### 🟡 Medium Priority (Short-term)

- [ ] **Input Validation**: Add robust input validation for:
    - `SmartHabitManager.swift`, `OllamaTypes.swift`, `AIServiceProtocols.swift`, `NotificationSchedulerService.swift`, `CategoryInsightsService.swift`, `AnalyticsAggregatorService.swift`.
- [ ] **Network Security**: Implement Certificate Pinning for all outbound network requests.
- [ ] **GDPR Compliance**: Add data deletion and minimization mechanisms to comply with privacy regulations.
- [ ] **Insecure Protocols**: Replace insecure HTTP URLs in `OllamaTypes.swift` with HTTPS.

---

## 🧪 4. Testing & Verification

_Source: `Documentation/TestPlan.md`_

- [ ] **Unit Tests Expansion**
    - [ ] Models: `Habit`, `HabitLog`, `PlayerProfile`.
    - [ ] Services: `StreakService` (verify calculations), `XPService`.
- [ ] **Integration Tests**
    - [ ] Verification of "Create -> Complete -> Streak Up -> XP Gain" loop.
    - [ ] Level progression logic verification.
- [ ] **UI/UX Testing**
    - [ ] Onboarding flow stability.
    - [ ] Dashboard responsiveness with 100+ habits.

---

## 📈 5. Maintenance & CI/CD

- [x] Consolidate AI self-healing and CI/CD workflows (Completed Aug 2025).
- [ ] Maintain `QUIET_MODE` for automated agents to prevent notification fatigue.
- [ ] Ensure all PRs target small, deterministic changes to maintain reviewability.

---

**Last Consolidated:** 2026-02-08
**Review Frequency:** Weekly
**Owner:** Antigravity / dboone323
