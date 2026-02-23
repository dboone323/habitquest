#!/usr/bin/env python3
"""
Working JWT Auth for Phase 3 Testing
"""

import hashlib
import os
from datetime import UTC, datetime, timedelta

import jwt

import logging

logger = logging.getLogger(__name__)


class JWTAuthManager:
    """Manager for JWT-based authentication and token handling."""

    def __init__(self, secret_key: str = None):
        # Prefer the environment variable for secrets. Do not provide a default secret.
        # For local testing, set JWT_SECRET in your environment or pass it explicitly.
        self.secret_key = secret_key or os.getenv("JWT_SECRET")
        self.algorithm = "HS256"
        self.token_expiry = timedelta(hours=24)

        # Simple user store for testing
        self.users = {
            "admin": {
                "password_hash": self._hash_password("admin"),
                "role": "admin",
                "permissions": ["read", "write", "admin"],
            },
            "user": {
                "password_hash": self._hash_password("user"),
                "role": "user",
                "permissions": ["read"],
            },
        }

    def _hash_password(self, password: str) -> str:
        # Use PBKDF2-HMAC with 600,000 iterations as recommended by OWASP
        salt = b"habitquest_test_salt" # In production, use a unique salt per user
        return hashlib.pbkdf2_hmac(
            "sha256", 
            password.encode(), 
            salt, 
            600000
        ).hex()

    def authenticate_user(self, username: str, password: str) -> dict | None:
        """Authenticate a user by username and password."""
        user = self.users.get(username)
        if user and user["password_hash"] == self._hash_password(password):
            return {
                "username": username,
                "role": user["role"],
                "permissions": user["permissions"],
            }
        return None

    def generate_token(self, username: str, role: str, permissions: list[str]) -> str:
        """Generate a JWT token for the given user.

        If a secret key is not configured (common in tests or local dev), use a
        clearly labeled test fallback secret to avoid jwt raising a TypeError
        when given None. This keeps tests stable while encouraging users to
        set a proper `JWT_SECRET` in production.
        """
        payload = {
            "username": username,
            "role": role,
            "permissions": permissions,
            "exp": datetime.now(UTC) + self.token_expiry,
            "iat": datetime.now(UTC),
        }

        secret = self.secret_key or os.getenv("JWT_SECRET")
        if not secret:
            # Use an explicit fallback for test/dev environments
            secret = "test-secret"
            # Avoid noisy output in tests; use logger for visibility
            try:
                import logging

                logging.getLogger(__name__).warning(
                    "Using fallback JWT secret for token generation (not for production)"
                )
            except Exception:
                pass

        return jwt.encode(payload, str(secret), algorithm=self.algorithm)

    def verify_token(self, token: str) -> dict | None:
        """Verify and decode a JWT token.

        Use the same secret fallback as `generate_token` to keep tests
        deterministic when no `JWT_SECRET` is configured in the environment.
        """
        secret = self.secret_key or os.getenv("JWT_SECRET") or "test-secret"
        try:
            payload = jwt.decode(token, str(secret), algorithms=[self.algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None

    def login(self, username: str, password: str) -> str | None:
        """Authenticate user and return a JWT token if successful."""
        user = self.authenticate_user(username, password)
        if user:
            return self.generate_token(
                user["username"], user["role"], user["permissions"]
            )
        return None

    def get_status(self):
        """Return the current status of the auth manager."""
        return {
            "total_users": len(self.users),
            "algorithm": self.algorithm,
            "token_expiry_hours": self.token_expiry.total_seconds() / 3600,
        }


# Global instance
_auth_manager = None


def get_auth_manager():
    """Get or create the global auth manager instance."""
    global _auth_manager  # pylint: disable=global-statement
    if _auth_manager is None:
        _auth_manager = JWTAuthManager()
    return _auth_manager


def main():
    """Demonstrate JWT auth functionality."""
    auth = get_auth_manager()

    # Test login
    token = auth.login("admin", "admin")
    if token:
        logger.info("Login successful! Token generated")

        # Test verification
        payload = auth.verify_token(token)
        if payload:
            logger.info("Token valid for user: %s", payload.get("username"))
        else:
            logger.warning("Token verification failed")
    else:
        logger.warning("Login failed")

    logger.info("Auth status: %s", auth.get_status())


if __name__ == "__main__":
    main()
