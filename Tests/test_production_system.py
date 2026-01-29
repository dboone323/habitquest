#!/usr/bin/env python3
"""
Tests for production_system
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
    from HabitQuest.automation.src.production_system import (
        ProductionSystem, 
        ProductionConfig, 
        ProductionMetrics, 
        create_production_system, 
        main
    )
except ImportError:
    # Fallback/Debug
    print("Could not import absolute package, trying relative workaround...")
    sys.path.append(os.path.abspath(os.path.join(current_dir, "../automation/src")))
    # This might still fail with relative import error in source, unless we mock parent
    from production_system import (
        ProductionSystem, 
        ProductionConfig, 
        ProductionMetrics, 
        create_production_system, 
        main
    )

class TestProductionConfig:
    """Tests for ProductionConfig class."""

    def test_initialization(self):
        """Test ProductionConfig can be initialized."""
        config = ProductionConfig(environment="test")
        assert config.environment == "test"
        assert config.max_workers == 8


class TestProductionMetrics:
    """Tests for ProductionMetrics class."""

    def test_initialization(self):
        """Test ProductionMetrics can be initialized."""
        import time
        metrics = ProductionMetrics(
            timestamp=time.time(),
            total_requests=0,
            successful_requests=0,
            failed_requests=0,
            avg_response_time=0.0,
            active_services=0,
            uptime=0.0
        )
        assert metrics.total_requests == 0


class TestProductionSystem:
    """Tests for ProductionSystem class."""

    @pytest.mark.asyncio
    async def test_initialization(self):
        """Test ProductionSystem can be initialized."""
        config = ProductionConfig(environment="test")
        system = ProductionSystem(config)
        assert system.config.environment == "test"
        assert not system.is_running
        
    @pytest.mark.asyncio
    async def test_health_check(self):
        config = ProductionConfig(environment="production")
        system = ProductionSystem(config)
        # Mock dependencies
        system.automation_engine = MagicMock()
        system.auth_manager = MagicMock()
        system.performance_optimizer = MagicMock()
        
        healthy = await system._health_check()
        assert healthy is True


def test_create_production_system():
    """Test create_production_system function."""
    system = create_production_system()
    assert isinstance(system, ProductionSystem)
    assert system.config.environment == "production"
