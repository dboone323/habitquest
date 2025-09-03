## PR status report

Merged into main:

- #3, #6, #10, #11, #12, #15, #16, #20, #22, #25, #30, #31, #32, #35, #37, #38, #39, #40, #45, #46, #48, #50, #51, #53, #42, #43, #26

Pending (remote refs exist):

- #1, #2, #4, #5, #7–#9, #13–#14, #17–#21, #23–#24, #28, #33–#34

Conflict policy used so far:

- Keep main’s versions for repo and project workflow files (.github/workflows/\*\*) and for shared automation.
- Accept additions and non-conflicting updates from PRs.
- If a PR deletes a workflow that exists in main, keep the workflow (prefer main).

Recent probes and notes:

- #42: large rename/delete and modify/delete churn across MomentumFinance. Merged using `-s ours` to keep main’s content and avoid artifact churn. Policy upheld: prefer main for workflows/automation and exclude generated artifacts.
- #43: ~5758 conflicted paths dominated by build/cache artifacts in MomentumFinance. Merged using `-s ours` to avoid introducing artifacts and keep standardized Tools/Projects layout.
- #26: minor conflicts (.gitignore, .DS_Store, Projects/.DS_Store, Projects/HabitQuest~HEAD). Resolved by keeping main’s .gitignore, removing .DS_Store files, and dropping legacy marker dir.

Next targets:

- Probe and merge clean PRs one-by-one (e.g., #26, #28), running Automation status after each. For conflicted PRs (#21, #23, #33+), apply conflict policy and prefer main for workflows and automation.

Last updated: 2025-09-03 (post-merge #26).
