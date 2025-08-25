#!/usr/bin/env bash
set -euo pipefail

# quantum_agent_entrypoint.sh
# Safe wrapper to run policy checks and invoke AI recovery for a given project.

PROJECT_PATH="${1:-}"
DRY_RUN="${2:-true}"
ENABLE_AUTO_FIX="${3:-false}"
LOGFILE="quantum_agent_${PROJECT_PATH//\//_}.log"
AUTO_FIX_MODE="${4:-auto}" # 'auto' or 'prompt' (prompt not implemented here)

if [[ -z "${PROJECT_PATH}" ]]; then
  echo "Usage: $0 <project_path> [dry_run:true|false] [enable_auto_fix:true|false]"
  exit 2
fi

echo "Quantum Agent entrypoint: project=${PROJECT_PATH} dry_run=${DRY_RUN} enable_auto_fix=${ENABLE_AUTO_FIX}" | tee "${LOGFILE}"

# 1) Run policy checker (warn or fail depending on policy)
if command -v python3 >/dev/null 2>&1; then
  python3 "$(dirname "$0")/check_architecture.py" --project "${PROJECT_PATH}" --warn-only | tee -a "${LOGFILE}" || true
  # default: warn-only. When auto-fix requested, run checker to collect fixes and optionally apply them.
  if [[ "${ENABLE_AUTO_FIX}" == "true" ]]; then
    echo "Running checker with auto-fix analysis" | tee -a "${LOGFILE}"
    # run checker to collect issues and fixes (warn-only to get list)
    python3 "$(dirname "$0")/check_architecture.py" --project "${PROJECT_PATH}" --warn-only | tee -a "${LOGFILE}" || true
  fi
else
  echo "python3 not available; skipping policy check" | tee -a "${LOGFILE}"
fi

# 2) Invoke AI recovery script (safe defaults)
ARGS=(--project "${PROJECT_PATH}")
if [[ "${DRY_RUN}" == "true" ]]; then
  ARGS+=(--dry-run)
fi
if [[ "${ENABLE_AUTO_FIX}" == "true" ]]; then
  ARGS+=(--enable-auto-fix)
fi

echo "Invoking ai_workflow_recovery.py ${ARGS[*]}" | tee -a "${LOGFILE}"
python3 "$(dirname "$0")/ai_workflow_recovery.py" "${ARGS[@]}" 2>&1 | tee -a "${LOGFILE}" || true

echo "Entrypoint finished" | tee -a "${LOGFILE}"
exit 0
