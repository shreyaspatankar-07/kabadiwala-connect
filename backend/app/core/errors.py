"""Standardized error responses and application exceptions."""

from typing import Any

from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse


class AppError(HTTPException):
    """Base application exception with error code and structured details."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: Any = None,
    ):
        super().__init__(status_code=status_code, detail=message)
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details


class AuthenticationError(AppError):
    def __init__(self, message: str = "Invalid credentials", details: Any = None):
        super().__init__(
            code="AUTH_INVALID_CREDENTIALS",
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
            details=details,
        )


class PermissionDeniedError(AppError):
    def __init__(self, message: str = "Permission denied", details: Any = None):
        super().__init__(
            code="AUTH_FORBIDDEN",
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
            details=details,
        )


class NotFoundError(AppError):
    def __init__(self, resource: str, resource_id: Any):
        super().__init__(
            code="RESOURCE_NOT_FOUND",
            message=f"{resource} with ID '{resource_id}' was not found.",
            status_code=status.HTTP_404_NOT_FOUND,
        )


class RateLimitExceededError(AppError):
    def __init__(self, retry_after: int = 60):
        super().__init__(
            code="RATE_LIMIT_EXCEEDED",
            message=f"Rate limit exceeded. Please retry after {retry_after} seconds.",
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            details={"retry_after_seconds": retry_after},
        )


class DuplicateRequestError(AppError):
    def __init__(self, key: str):
        super().__init__(
            code="DUPLICATE_IDEMPOTENCY_KEY",
            message=f"Request with idempotency key '{key}' has already been processed.",
            status_code=status.HTTP_409_CONFLICT,
        )


class ConflictError(AppError):
    def __init__(self, message: str, code: str = "CONFLICT"):
        super().__init__(
            code=code,
            message=message,
            status_code=status.HTTP_409_CONFLICT,
        )


class BadRequestError(AppError):
    def __init__(self, message: str, code: str = "BAD_REQUEST", details: Any = None):
        super().__init__(
            code=code,
            message=message,
            status_code=status.HTTP_400_BAD_REQUEST,
            details=details,
        )


async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    """Consistent JSON response format for AppError exceptions."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": exc.details,
            }
        },
    )


async def generic_http_error_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Handler for standard FastAPI HTTPExceptions."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": f"HTTP_{exc.status_code}",
                "message": str(exc.detail),
                "details": None,
            }
        },
    )
