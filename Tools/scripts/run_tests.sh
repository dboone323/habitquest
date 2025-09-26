#!/usr/bin/env bash
set -euo pipefail

# Unified test runner placeholder
# Adapts per project. Extend with actual commands.

PROJECTS=(AvoidObstaclesGame HabitQuest MomentumFinance PlannerApp CodingReviewer)
ROOT=$(pwd)

log() { echo "[tests] $*"; }

for proj in "${PROJECTS[@]}"; do
  if [[ -d "Projects/${proj}" ]]; then
    log "Project: ${proj}"
    # Swift tests: if a SwiftPM Package.swift exists
    if [[ -f "Projects/${proj}/Package.swift" ]]; then
      (cd "Projects/${proj}" && swift test --parallel)
    else
      log "No Package.swift in ${proj} (likely Xcode project). Skipping swift test placeholder."
    fi
  fi
done

log "Done."
