"""FastAPI dependencies for authentication, role enforcement, and database sessions."""

from typing import Annotated

from fastapi import Depends, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import AuthenticationError, PermissionDeniedError
from app.core.security import decode_access_token
from app.models.schema import User

security_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """Validate JWT bearer token and return the authenticated User."""
    if not credentials:
        raise AuthenticationError("Authorization header with Bearer token is required.")

    payload = decode_access_token(credentials.credentials)
    if not payload:
        raise AuthenticationError("Invalid or expired access token.")

    user_id = payload.get("sub")
    if not user_id:
        raise AuthenticationError("Malformed token: missing subject claim.")

    import uuid

    try:
        user_uuid = uuid.UUID(str(user_id))
    except ValueError:
        raise AuthenticationError("Malformed token: invalid subject UUID.") from None

    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise AuthenticationError("User account not found or has been deactivated.")

    return user


async def get_optional_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User | None:
    """Validate JWT bearer token if present, or return None for public/demo access."""
    if not credentials:
        return None

    payload = decode_access_token(credentials.credentials)
    if not payload:
        return None

    user_id = payload.get("sub")
    if not user_id:
        return None

    import uuid

    try:
        user_uuid = uuid.UUID(str(user_id))
    except ValueError:
        return None

    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        return None

    return user


def require_role(allowed_roles: list[str]):
    """Factory creating dependency that restricts access to specified roles."""

    async def role_checker(current_user: Annotated[User, Depends(get_current_user)]) -> User:
        if current_user.role.value not in allowed_roles:
            msg = (
                f"Role '{current_user.role.value}' does not have permission. "
                f"Allowed: {allowed_roles}"
            )
            raise PermissionDeniedError(msg)
        return current_user

    return role_checker


async def get_optional_idempotency_key(
    x_idempotency_key: Annotated[str | None, Header(alias="X-Idempotency-Key")] = None,
) -> str | None:
    return x_idempotency_key

