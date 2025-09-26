# Workspace Consolidation Plan

This plan centralizes configs and automation, quarantines snapshot duplicates, and adds scripts to keep the repo tidy without breaking builds. All cleanup actions default to dry-run; explicit execution is required.

## Goals

- Single source of truth for shared configs and automation
- Quarantine imported snapshots/backups to avoid build confusion
- Keep discoverability high: generate inventory and status docs

## Canonical Locations

- Automation: `Tools/Automation/` (authoritative)
- Shared code: `Shared/` (authoritative)
- Spell-check config: canonical file: `Shared/cspell.json` (others will be removed or referenced)
- Project apps: `Projects/*` only (ignore mirrored copies in snapshots/backups)

## High-level Phases

1. Inventory (read-only)
2. Quarantine snapshots/backups
3. Config unification (cspell.json first)
4. Per-project wrappers → call centralized automation
5. Validate: lint/build/tests

## New Scripts

- Projects/scripts/gen_docs.sh
  - Produces `Documentation/WORKSPACE_CONSOLIDATION_STATUS.md` with current counts and snapshot lists.
- Tools/Automation/workspace_inventory.sh
  - Creates timestamped inventory under `Tools/Automation/reports/`.
- Tools/Automation/workspace_consolidator.sh
  - Dry-run by default. With `--execute`, quarantines snapshot dirs and de-duplicates cspell.json copies (moves to Archive).

## Safe Execution Order

1. From `Projects/`: `bash scripts/gen_docs.sh` (status only)
2. From repo root: `Tools/Automation/workspace_inventory.sh` (inventory report)
3. Review the reports, then optionally run: `Tools/Automation/workspace_consolidator.sh --execute`

## Rollback

- All moved files are archived under `Tools/Automation/Archive/<timestamp>/...` for easy restore.

## Notes

- Desktop folders outside this workspace can’t be scanned by automation here. If needed, provide a manifest or run local commands to compare and we’ll incorporate results.
