---
Repo health checklist — Quantum-workspace

Checklist (items to verify or add):
- [ ] Root README describing workspace layout (/projects, /packages, build/test commands).
- [ ] LICENSE file present and correct.
- [ ] ISSUE_TEMPLATE and PULL_REQUEST_TEMPLATE for contributor consistency.
- [ ] CODEOWNERS mapping owners to critical paths.
- [ ] CI workflow(s) in .github/workflows to run validations on PRs.
- [ ] Change-aware CI (only run builds/tests for affected projects).
- [ ] Dependabot or Renovate configured for dependency updates.
- [ ] Code scanning (CodeQL) and secret scanning enabled.
- [ ] Minimal unit tests and linters run in CI for each project.

Suggested priority: add README, CI workflow to run Tools/Automation validations, and CODEOWNERS first.
---