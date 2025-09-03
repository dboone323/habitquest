## PR status report

Merged into main:

- #3, #6, #10, #11, #12, #15, #16, #20, #22, #25, #51, #53

Pending (remote refs exist):

- #1, #2, #4, #5, #7–#9, #13–#14, #17–#21, #23–#24, #26, #28, #30–#35, #37–#40, #42–#43, #45–#46, #48, #50

Conflict policy used so far:

- Keep main’s versions for repo and project workflow files (.github/workflows/\*\*) and for shared automation.
- Accept additions and non-conflicting updates from PRs.
- If a PR deletes a workflow that exists in main, keep the workflow (prefer main).

Next targets:

- Probe and merge clean PRs one-by-one (e.g., #20, #21), running Automation status after each.

Last updated: automated during merge session.
