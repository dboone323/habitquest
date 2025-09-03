---
Specific notes about the Tools/Automation validate-only change — Quantum-workspace

Observed change:
- deploy_workflows_all_projects.sh: in validate-only mode the script now reports validation errors but returns success (exit 0).

Implications:
- Useful for non-blocking CI runs, but can hide real configuration problems if maintainers expect the validation step to fail the PR.
- If this script is the single source of truth for workflow validation, we should surface failures in a persistent way (annotations, PR comments, checks) even if the job exit code is 0.

Options to consider:
1) Keep script exiting non-zero on errors; configure GitHub Actions job as non-blocking when needed (use 'continue-on-error' or mark as check that doesn't block).
2) Keep script exit 0 but add strong visibility (create GitHub annotations, PR comments, or a failing "check" via API) so errors are obvious.
3) Add a CLI flag to explicitly control exit behavior (e.g., --non-fatal or --allow-failure) and document it.

Recommendation: prefer explicit control (flag) + visible reporting. If you want, I can prepare a patch that:
- Adds an explicit flag and documents it in Tools/Automation/README.md
- Adds a sample GitHub Actions workflow to run validation and annotate PRs
---