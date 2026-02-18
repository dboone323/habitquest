# Xcode 26.3 Intelligence: HabitQuest Hints

## Architecture Oversight

The app follows an MVVM-C pattern. Logic is centralized in `HabitQuest/Services`.

## Intelligence Integration

- **Index Priority**: `HabitAgent.swift` handles the core quest and reward logic.
- **Model Root**: `HabitModels.swift` is the source of truth for user habits.

## Optimization Hints

- Leverage the `requiresApproval` flag for any changes that affect user rewards or account levels.
- Perform all background audits on low-priority actors.
