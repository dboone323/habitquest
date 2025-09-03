## PR status report

Merged into main:

- #3, #6, #10, #11, #12, #15, #16, #20, #22, #25, #30, #31, #32, #35, #37, #38, #39, #40, #45, #46, #48, #50, #51, #53

Pending (remote refs exist):

- #1, #2, #4, #5, #7–#9, #13–#14, #17–#21, #23–#24, #26, #28, #33–#34, #42–#43

Conflict policy used so far:

- Keep main’s versions for repo and project workflow files (.github/workflows/\*\*) and for shared automation.
- Accept additions and non-conflicting updates from PRs.
- If a PR deletes a workflow that exists in main, keep the workflow (prefer main).

Recent probes and notes:

- #42: test-merge shows 4 conflicted paths (.DS_Store, .gitignore, Projects/.DS_Store, Projects/HabitQuest~HEAD). These are generated/artifact files and legacy dir marker; resolution strategy: ignore/remove generated files, keep main's .gitignore, do not restore legacy Projects/HabitQuest~HEAD.
- #43: test-merge enumerated 5758 conflicted paths, overwhelmingly build artifacts and cache/module files under Tools/Projects/MomentumFinance (BuildData_macOS, ModuleCache.noindex, SDKStatCaches.noindex), plus assorted backups. Strategy: exclude all generated/cached content, keep standardized Tools/Projects layout, and prefer main for workflows/automation. Consider closing or replacing with a cleaned PR that omits artifacts.

Next targets:

- Probe and merge clean PRs one-by-one (e.g., #26, #28), running Automation status after each. For conflicted PRs (#21, #23, #33+), apply conflict policy and prefer main for workflows and automation.

Last updated: 2025-09-03.
