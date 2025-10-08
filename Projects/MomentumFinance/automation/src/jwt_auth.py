#!/usr/bin/env python3
"""
Working JWT Auth for Phase 3 Testing
"""

import hashlib
import os
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Optional

import jwt


class JWTAuthManager:
    def __init__(self, jwt_secret: str = None):
        # Use provided key, environment variable, or load from secure config
        if jwt_secret:
            self.jwt_secret = jwt_secret
        elif os.getenv("JWT_SECRET"):
            self.jwt_secret = os.getenv("JWT_SECRET")
        else:
            # Try to load from secure config
            try:
                import subprocess

                result = subprocess.run(
                    [
                        "/Users/danielstevens/Desktop/Quantum-workspace/Tools/secure_config.sh",
                        "get",
                        "JWT_SECRET",
                    ],
                    capture_output=True,
                    text=True,
                    cwd="/Users/danielstevens/Desktop/Quantum-workspace/Tools",
                )
                if result.returncode == 0 and result.stdout.strip():
                    self.jwt_secret = result.stdout.strip()
                else:
                    # Fallback to secure random key
                    import secrets

                    self.jwt_secret = secrets.token_hex(32)
            except:
                # Final fallback
                import secrets

                self.jwt_secret = secrets.token_hex(32)

        self.algorithm = "HS256"
        self.token_expiry = timedelta(hours=24)

        # Simple user store for testing - use environment variables for security
        self.users = {}
        self._load_test_users()

    def _load_test_users(self):
        """Load test users from environment variables for security"""
        # Only create test users if explicitly configured via environment
        admin_password = os.getenv("TEST_ADMIN_PASSWORD")
        user_password = os.getenv("TEST_USER_PASSWORD")

        if admin_password:
            self.users["admin"] = {
                "password_hash": self._hash_password(admin_password),
                "role": "admin",
                "permissions": ["read", "write", "admin"],
            }

        if user_password:
            self.users["user"] = {
                "password_hash": self._hash_password(user_password),
                "role": "user",
                "permissions": ["read"],
            }

        # In development/test environments, create secure test users if none configured
        if not self.users and os.getenv("DEVELOPMENT") == "true":
            import secrets
            # Create test users with random passwords for security
            admin_pass = secrets.token_hex(8)
            user_pass = secrets.token_hex(8)

            self.users = {
                "admin": {
                    "password_hash": self._hash_password(admin_pass),
                    "role": "admin",
                    "permissions": ["read", "write", "admin"],
                },
                "user": {
                    "password_hash": self._hash_password(user_pass),
                    "role": "user",
                    "permissions": ["read"],
                },
            }

            # Log secure passwords (only in development)
            print(f"Development test admin password: {admin_pass}")
            print(f"Development test user password: {user_pass}")

    def _hash_password(self, password: str) -> str:
        return hashlib.sha256(password.encode()).hexdigest()

    def authenticate_user(self, username: str, password: str) -> Optional[Dict]:
        user = self.users.get(username)
        if user and user["password_hash"] == self._hash_password(password):
            return {
                "username": username,
                "role": user["role"],
                "permissions": user["permissions"],
            }
        return None

    def generate_token(self, username: str, role: str, permissions: List[str]) -> str:
        payload = {
            "username": username,
            "role": role,
            "permissions": permissions,
            "exp": datetime.now(timezone.utc) + self.token_expiry,
            "iat": datetime.now(timezone.utc),
        }
        return jwt.encode(payload, self.jwt_secret, algorithm=self.algorithm)

    def verify_token(self, token: str) -> Optional[Dict]:
        try:
            payload = jwt.decode(token, self.jwt_secret, algorithms=[self.algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None

    def login(self, username: str, password: str) -> Optional[str]:
        user = self.authenticate_user(username, password)
        if user:
            return self.generate_token(
                user["username"], user["role"], user["permissions"]
            )
        return None

    def get_status(self):
        return {
            "total_users": len(self.users),
            "algorithm": self.algorithm,
            "token_expiry_hours": self.token_expiry.total_seconds() / 3600,
        }


# Global instance
_auth_manager = None


def get_auth_manager():
    global _auth_manager
    if _auth_manager is None:
        _auth_manager = JWTAuthManager()
    return _auth_manager


def main():
    auth = get_auth_manager()

    # Test login using environment variables or generated credentials
    test_username = os.getenv("TEST_USERNAME", "admin")
    test_credential = os.getenv("TEST_PASSWORD", os.getenv("TEST_ADMIN_PASSWORD", "secure_test_credential"))

    token = auth.login(test_username, test_credential)
    if token:
        print("Login successful! Token generated")

        # Test verification
        payload = auth.verify_token(token)
        if payload:
            print(f"Token valid for user: {payload['username']}")
        else:
            print("Token verification failed")
    else:
        print("Login failed")

    print("Auth status:", auth.get_status())


if __name__ == "__main__":
    main()
