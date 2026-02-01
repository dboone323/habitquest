#!/usr/bin/env python3
"""
Tests for automation_engine
Auto-generated on 2025-12-05
"""
import sys
import os
import pytest
from unittest.mock import patch

# Add source to path
current_dir = os.path.dirname(os.path.abspath(__file__))
src_path = os.path.abspath(os.path.join(current_dir, "../automation/src"))
if src_path not in sys.path:
    sys.path.insert(0, src_path)

try:
    from automation_engine import AutomationEngine, AutomationScript, get_engine, main
except ImportError:
    # Fallback
    sys.path.append(os.path.abspath(os.path.join(current_dir, "../../automation/src")))
    from automation_engine import AutomationEngine, AutomationScript, get_engine, main


@pytest.fixture(autouse=True)
def reset_engine():
    import automation_engine

    automation_engine._engine = None
    yield
    automation_engine._engine = None


class TestAutomationScript:
    """Tests for AutomationScript class."""

    def test_initialization(self):
        """Test AutomationScript can be initialized."""
        script = AutomationScript(
            name="test_script", path="/tmp/test.sh", category="test"
        )
        assert script.name == "test_script"
        assert script.category == "test"


class TestAutomationEngine:
    """Tests for AutomationEngine class."""

    def test_initialization(self):
        """Test AutomationEngine can be initialized."""
        engine = AutomationEngine()
        assert isinstance(engine.scripts, dict)
        # Should discover scripts in current workspace, count might be > 0

    def test_get_status(self):
        engine = AutomationEngine()
        status = engine.get_status()
        assert "total_scripts" in status
        assert "workspace" in status


def test_get_engine():
    """Test get_engine function."""
    engine = get_engine()
    assert isinstance(engine, AutomationEngine)
    assert get_engine() is engine  # Singleton check


def test_main():
    """Test main function."""
    with patch("builtins.print"):
        main()
