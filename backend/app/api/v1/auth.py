"""Authentication API router."""

from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.rate_limit import auth_rate_limiter
from app.models.schema import User
from app.schemas.auth import (
    EmailLoginRequest,
    OTPRequest,
    OTPRequestResponse,
    OTPVerifyRequest,
    PINLoginRequest,
    PINSetupRequest,
    TokenResponse,
    UserProfileResponse,
    UserRegisterRequest,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/otp/request",
    response_model=OTPRequestResponse,
    dependencies=[Depends(auth_rate_limiter)],
    summary="Request OTP for collector phone login",
)
async def request_otp(data: OTPRequest):
    return await AuthService.request_otp(data)


@router.post(
    "/otp/verify",
    response_model=TokenResponse,
    dependencies=[Depends(auth_rate_limiter)],
    summary="Verify OTP and obtain access token",
)
async def verify_otp(data: OTPVerifyRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    return await AuthService.verify_otp(data, db)


@router.post(
    "/pin/setup",
    status_code=status.HTTP_200_OK,
    summary="Setup 4-digit PIN for collector",
)
async def setup_pin(
    data: PINSetupRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    await AuthService.setup_pin(current_user, data, db)
    return {"status": "pin_set"}


@router.post(
    "/pin/login",
    response_model=TokenResponse,
    dependencies=[Depends(auth_rate_limiter)],
    summary="Login collector using 4-digit PIN",
)
async def login_with_pin(data: PINLoginRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    return await AuthService.login_with_pin(data, db)


@router.post(
    "/login",
    response_model=TokenResponse,
    dependencies=[Depends(auth_rate_limiter)],
    summary="Login recycler or admin using email and password",
)
async def login_email(data: EmailLoginRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    return await AuthService.login_email(data, db)


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register recycler or admin account",
)
async def register(data: UserRegisterRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    return await AuthService.register_user(data, db)


@router.get(
    "/me",
    response_model=UserProfileResponse,
    summary="Get current authenticated user profile",
)
async def get_me(current_user: Annotated[User, Depends(get_current_user)]):
    return UserProfileResponse(
        id=str(current_user.id),
        email=current_user.email,
        phone=current_user.phone,
        role=current_user.role.value,
        collector_id=current_user.collector_id,
        recycler_id=current_user.recycler_id,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
    )
