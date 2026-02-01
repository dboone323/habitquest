#!/usr/bin/env python3
"""
Integration-style tests for AIWorkflowRecovery autonomous loop.
These tests run the recovery loop end-to-end in a temporary repository
and mock external systems (git, flake8, CI push) to avoid side effects.
"""
import time

import pytest

from scripts.ai_workflow_recovery import AIWorkflowRecovery


@pytest.mark.integration
def test_autonomous_recovery_loop_creates_missing_file_and_succeeds(
    tmp_path, monkeypatch
):
    """Simulate a missing-file failure and ensure the loop creates the file and succeeds."""
    repo = tmp_path

    # Initialize the recovery object
    recovery = AIWorkflowRecovery(repo_path=str(repo))
    recovery.max_retries = 3
    recovery.retry_delay = 0  # speed up test

    # Prepare run_quality_check to first fail with missing file, then succeed
    seq = iter(
        [
            (
                False,
                "Traceback\nFile \"./missing.py\", line 1\nFileNotFoundError: No such file or directory: 'missing.py'",
            ),
            (True, "All good"),
        ]
    )

    monkeypatch.setattr(recovery, "run_quality_check", lambda: next(seq))

    # Avoid sleeping delays
    monkeypatch.setattr(time, "sleep", lambda s: None)

    # Patch commit_and_push_fixes to simulate successful git operations (no real git calls)
    monkeypatch.setattr(recovery, "commit_and_push_fixes", lambda failure: True)

    # Run the autonomous recovery loop
    result = recovery.autonomous_recovery_loop()

    # After running, the missing file should exist and loop should report success
    assert result is True
    assert (repo / "missing.py").exists()


@pytest.mark.integration
def test_autonomous_recovery_loop_returns_false_when_not_analyzable(
    tmp_path, monkeypatch
):
    """If the failure cannot be analyzed (no matching pattern), the loop should stop and return False."""
    repo = tmp_path
    recovery = AIWorkflowRecovery(repo_path=str(repo))
    recovery.max_retries = 2
    recovery.retry_delay = 0

    # run_quality_check returns a failure that doesn't match known patterns
    monkeypatch.setattr(
        recovery,
        "run_quality_check",
        lambda: (False, "Unknown error: something weird happened"),
    )

    # Patch analyze_workflow_failure to explicitly return None (unalalyzable)
    monkeypatch.setattr(recovery, "analyze_workflow_failure", lambda output: None)

    # Avoid sleeping
    monkeypatch.setattr(time, "sleep", lambda s: None)

    result = recovery.autonomous_recovery_loop()

    assert result is False
