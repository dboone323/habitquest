#!/usr/bin/env python3
"""
Tests for performance_optimizer
Auto-generated on 2025-12-05
"""
import sys
import os
import pytest
from unittest.mock import patch, MagicMock

# Ensure root is in path
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "../.."))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)

try:
    from HabitQuest.automation.src.performance_optimizer import (
        PerformanceOptimizer, 
        PerformanceMetrics, 
        get_optimizer, 
        main
    )
except ImportError:
    # Fallback/Debug
    print("Could not import absolute package, trying relative workaround...")
    sys.path.append(os.path.abspath(os.path.join(current_dir, "../automation/src")))
    from performance_optimizer import (
        PerformanceOptimizer, 
        PerformanceMetrics, 
        get_optimizer, 
        main
    )

@pytest.fixture(autouse=True)
def reset_optimizer():
    try:
        import HabitQuest.automation.src.performance_optimizer as po
        po._optimizer = None
        yield
        po._optimizer = None
    except ImportError:
        import performance_optimizer as po
        po._optimizer = None
        yield
        po._optimizer = None

class TestPerformanceMetrics:
    """Tests for PerformanceMetrics class."""

    def test_initialization(self):
        """Test PerformanceMetrics can be initialized."""
        import time
        metrics = PerformanceMetrics(
            cpu_percent=10.0,
            memory_percent=20.0,
            disk_usage=30.0,
            timestamp=time.time()
        )
        assert metrics.cpu_percent == 10.0


class TestPerformanceOptimizer:
    """Tests for PerformanceOptimizer class."""

    def test_initialization(self):
        """Test PerformanceOptimizer can be initialized."""
        optimizer = PerformanceOptimizer()
        assert optimizer.optimization_enabled is True
        assert isinstance(optimizer.metrics_history, list)

    def test_collect_metrics(self):
        optimizer = PerformanceOptimizer()
        metrics = optimizer.collect_metrics()
        assert isinstance(metrics, PerformanceMetrics)
        assert len(optimizer.metrics_history) == 1

    def test_cache_operations(self):
        optimizer = PerformanceOptimizer()
        optimizer.optimize_cache("test", "value", 60)
        assert optimizer.get_cached("test") == "value"


def test_get_optimizer():
    """Test get_optimizer function."""
    optimizer = get_optimizer()
    assert isinstance(optimizer, PerformanceOptimizer)
    assert get_optimizer() is optimizer


def test_main():
    """Test main function."""
    # Mock psutil to strictly avoid system calls if needed, but here simple run is fine
    with patch('builtins.print'):
        main()
