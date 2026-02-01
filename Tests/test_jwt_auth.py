#!/usr/bin/env python3
"""
Tests for jwt_auth
Auto-generated on 2025-12-05
"""
import sys
import os
import pytest
from unittest.mock import patch

# Add source to path for testing
current_dir = os.path.dirname(os.path.abspath(__file__))
src_path = os.path.abspath(os.path.join(current_dir, "../automation/src"))
if src_path not in sys.path:
    sys.path.insert(0, src_path)

try:
    from jwt_auth import JWTAuthManager, get_auth_manager, main
except ImportError:
    # Fallback if path is different in CI
    sys.path.append(os.path.abspath(os.path.join(current_dir, "../../automation/src")))
    from jwt_auth import JWTAuthManager, get_auth_manager, main


class TestJWTAuthManager:
    """Tests for JWTAuthManager class."""

    def test_initialization(self):
        """Test JWTAuthManager can be initialized."""
        manager = JWTAuthManager(secret_key="test_secret")
        assert manager.algorithm == "HS256"
        assert "admin" in manager.users
        assert manager.users["admin"]["role"] == "admin"

    def test_authenticate_user(self):
        """Test user authentication."""
        manager = JWTAuthManager(secret_key="test_secret")
        user = manager.authenticate_user("admin", "admin")
        assert user is not None
        assert user["username"] == "admin"

        failed = manager.authenticate_user("admin", "wrong")
        assert failed is None


def test_get_auth_manager():
    """Test get_auth_manager function."""
    manager = get_auth_manager()
    assert isinstance(manager, JWTAuthManager)


@pytest.fixture(autouse=True)
def setup_env():
    # Set env var for all tests
    with patch.dict(os.environ, {"JWT_SECRET": "test_secret_env"}):
        # Reset global instance
        import jwt_auth

        jwt_auth._auth_manager = None
        yield
        jwt_auth._auth_manager = None


def test_main():
    """Test main function."""
    # Capture stdout to prevent clutter
    with patch("builtins.print"):
        main()
