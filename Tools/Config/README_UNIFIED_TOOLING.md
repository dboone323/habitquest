# Unified Tooling Proposal

This directory holds proposed root-level configurations awaiting promotion to the repository root:

Files:
- UNIFIED_SWIFTLINT_ROOT.yml -> .swiftlint.yml
- UNIFIED_SWIFTFORMAT_ROOT -> .swiftformat
- UNIFIED_EDITORCONFIG_ROOT -> .editorconfig

Promotion Steps:
1. Validate locally:
   swiftformat . --config Tools/Config/UNIFIED_SWIFTFORMAT_ROOT
   swiftlint --config Tools/Config/UNIFIED_SWIFTLINT_ROOT.yml
2. Address any critical violations (or extend disabled_rules temporarily).
3. Move each file to repo root (cannot from current workspace scope yet) and commit.
4. Delete per-project .swiftlint.yml / .swiftformat (except historical snapshots under Tools/Imported).
5. Update CI workflows to invoke root-level configs only.

Rationale:
- Single source of truth reduces drift and maintenance.
- Easier incremental tightening of rules.
- Simplifies developer onboarding.

Next Tightening Candidates (phase 2):
- Re-enable line_length with warning threshold (maybe 160).
- Re-enable sorted_imports after import cleanup pass.
- Enforce trailing_commas only in multiline collections.

