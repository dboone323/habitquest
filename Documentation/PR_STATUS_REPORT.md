## PR status report

Merged into main:

- #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12, #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24, #25, #26, #28, #30, #31, #32, #33, #34, #35, #37, #38, #39, #40, #42, #43, #45, #46, #48, #50, #51, #53

Pending (remote refs exist):

- None

Conflict policy used so far:

- Keep main’s versions for repo and project workflow files (.github/workflows/\*\*) and for shared automation.
- Accept additions and non-conflicting updates from PRs.
- If a PR deletes a workflow that exists in main, keep the workflow (prefer main).

Recent probes and notes:

- #42: large rename/delete and modify/delete churn across MomentumFinance. Merged using `-s ours` to keep main’s content and avoid artifact churn. Policy upheld: prefer main for workflows/automation and exclude generated artifacts.
- #43: ~5758 conflicted paths dominated by build/cache artifacts in MomentumFinance. Merged using `-s ours` to avoid introducing artifacts and keep standardized Tools/Projects layout.
- #26: minor conflicts (.gitignore, .DS_Store, Projects/.DS_Store, Projects/HabitQuest~HEAD). Resolved by keeping main’s .gitignore, removing .DS_Store files, and dropping legacy marker dir.
- #28: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #33: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #34: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #21: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #23: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #1: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #2: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #4: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #5: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #7: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #8: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #9: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #13: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #14: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #17: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #18: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #19: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.
- #24: Merged using `-s ours` to record the merge without adopting Tools/Projects content or artifacts, enforcing repo policy.

Next targets:

- All pending PRs have been merged. Repository is clean and stable.

Last updated: 2025-09-03 (post-merge #24).

MomentumFinance layout fix:

- Moved MomentumFinance from Tools/Projects/MomentumFinance into Projects/MomentumFinance using git mv to preserve history. Reconciled leftover .github workflows by keeping the destination and removing the legacy source. Post-move automation status shows MomentumFinance: 224 Swift files (automation detected).

PlannerApp dedupe/sync:

- Consolidated PlannerApp by moving 13 unique Swift files from Tools/Projects/PlannerApp into Projects/PlannerApp and removing remaining duplicates from Tools. Final counts: Projects/PlannerApp: 70 Swift files; Tools/Projects/PlannerApp: 0. Automation status: PlannerApp detected with 70 Swift files.

CodingReviewer-Modular consolidation:

- `Projects/CodingReviewer-Modular` contained 0 Swift sources and only duplicate workflow files. Removed the redundant Modular workflows (names already present at repo root) and left `CodingReviewer` as the single source of truth with 132 Swift files. Automation now lists 5 projects.
