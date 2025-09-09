# Tooling Consolidation Notes

Date: 2025-09-09
Status: Phase 1 (Centralization + CI Alignment In Progress)

## Objective
Unify formatting, linting, and editor conventions across all Swift projects to:
- Remove drift between per-project configs
- Simplify onboarding & CI maintenance
- Enable staged tightening of code quality rules

## Canonical Config Locations (Interim)
Unified configs currently live in: `Tools/Config/`
Planned promotion: rename & move to repository root once allowed.

| Purpose        | Current File                                      | Future Root Name      |
|----------------|---------------------------------------------------|------------------------|
| SwiftLint      | Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml           | .swiftlint.yml         |
| SwiftFormat    | Tools/Config/UNIFIED_SWIFTFORMAT_ROOT             | .swiftformat           |
| Editor Config  | Tools/Config/UNIFIED_EDITORCONFIG_ROOT           | .editorconfig          |

VS Code workspace settings reference these unified files.

## Wrapper Script
`Tools/format_lint_all.sh` orchestrates both tools with explicit `--config` flags. Preferred in CI to avoid duplication.

## Migration Phases
1. Phase 1 (Now): Centralize + neutralize noisy rules. Ensure CI green.
2. Phase 2: Incrementally re-enable style & complexity rules (sorted_imports, trailing_comma, line_length, etc.). Each re-enable gated by auto-fix PR or clear violation budget.
3. Phase 3: Introduce analyzer / AST-based deeper rules, add Trunk gating if desired.
4. Phase 4: Enforce on pre-commit hooks (optional) + documentation refresh.

## Temporarily Disabled Rules Rationale
High current violation counts would block progress. Each disabled rule will be:
- Baseline measured (counts captured in future appendix)
- Auto-fixed where feasible (swiftformat for imports/commas)
- Re-enabled with PR referencing remediation commit.

## CI Adaptation Strategy
Replace per-project references (e.g., `swiftlint lint` expecting local `.swiftlint.yml`) with either:
- Direct invocation: `swiftlint lint --config Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml`
- Or wrapper: `bash Tools/format_lint_all.sh --lint-only` (future enhancement flag)

SwiftFormat: use `--config Tools/Config/UNIFIED_SWIFTFORMAT_ROOT`.

Remove any logic that auto-creates missing `.swiftformat` / `.swiftlint.yml` files.

## Reference Commands (Local)
```bash
# Format & lint
bash Tools/format_lint_all.sh

# Just lint (temporary until script flag added)
swiftlint lint --config Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml

# Just format
swiftformat . --config Tools/Config/UNIFIED_SWIFTFORMAT_ROOT
```

## Pre-commit Hooks (Interim Setup)
Location (temporary): `Projects/.pre-commit-config.yaml`

Planned final location: repository root (`/.pre-commit-config.yaml`) once root write permitted.

### Install
1. Ensure Python 3.11+ available.
2. `pip install pre-commit`
3. From repository root (or `Projects/` while interim): `pre-commit install`

### Manual Run
`pre-commit run --all-files`

### Included Hooks
- Prettier (js/ts/tsx/json/md)
- Black (python formatting)
- Flake8 (python lint)
- SwiftFormat (local, unified config)
- SwiftLint (local, unified config)

### Moving to Root
When permissions allow: `git mv Projects/.pre-commit-config.yaml .pre-commit-config.yaml`
Then run: `pre-commit clean && pre-commit install`

### Adding Dependencies
System binaries required: `swiftformat`, `swiftlint` (install via Homebrew: `brew install swiftformat swiftlint`).

### Skipping
Emergency bypass (avoid routine use): `git commit -m "msg" --no-verify`

### Troubleshooting
- Path issues: run from repository root so Tools/Config resolves.
- Performance: first run creates virtualenv caches under `~/.cache/pre-commit`.
- Updating versions: `pre-commit autoupdate` then commit resulting changes.

### Future Enhancements (Hooks)
- Add SwiftLint JSON report upload in CI mirroring hook output.
- Introduce `--lint-only` / `--format-only` flags in wrapper and call those from local hooks for consistency.
- Cache Swift tooling in CI between runs.

## Future Enhancements
- Add script flag: `--lint-only`, `--format-only`.
- Generate violation delta report (JSON) and attach to PR comments.
- Introduce baseline suppression file if certain rules re-enabled gradually.
- Consolidate GitHub Actions into a composite action `tools/unified-lint-action`.

## Open Items
- Workflow patching pending.
- Optional creation of root stub `.swiftlint.yml` + `.swiftformat` that simply point to `Tools/Config` (symlink or include) once permissible.
- Evaluate adding `swift-format` (official) if it stabilizes vs SwiftFormat.
 - Verify marketplace IDs for extensions that failed install (placeholders to confirm):
	 - SwiftFormat extension (likely `nicklockwood.vscode-swiftformat` or alternative)
	 - Commitizen extension (evaluate `KnisterPeter.vscode-commitizen` viability)
	 - Ollama extension (monitor for official marketplace release; settings-only for now)

## Contact / Ownership
Temporary Maintainer: (Add engineer/team name)
Ownership to transition to: Platform / Tooling Guild (proposed)

---
These notes should be updated as phases advance.
