# HabitQuest Test Plan

## 1. Unit Testing Strategy
- **Models:** Test `Habit`, `HabitLog`, `PlayerProfile` logic.
- **Services:** Test `StreakService` (critical), `XPService`, `LevelingSystem`.
- **Managers:** Test `CategoryManager`, `ThemeManager`.

## 2. Integration Testing
- **Flows:**
    - Create Habit -> Complete -> Check Streak -> Check XP.
    - Level Up flow.
    - Backup/Restore flow.

## 3. UI Testing
- **Screens:**
    - Onboarding.
    - Dashboard.
    - Add Habit.
    - Stats.

## 4. Performance Testing
- **Metrics:**
    - App launch time.
    - List scrolling performance (with 100+ habits).
    - Chart rendering speed.

## 5. Security Testing
- **Data:** Verify local storage encryption (iOS default).
- **Privacy:** Verify no data leaks in logs.
