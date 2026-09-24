"""Pydantic schemas for authentication and authorization."""

from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class OTPRequest(BaseModel):
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$", description="E.164 phone number")
    language: str = Field("mr", pattern=r"^(mr|hi|en)$", description="Preferred language")


class OTPRequestResponse(BaseModel):
    status: str = "otp_sent"
    retry_after_seconds: int = 60
    mock_otp: str | None = None


class OTPVerifyRequest(BaseModel):
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$")
    otp: str = Field(..., min_length=4, max_length=8)
    operating_area: str = Field("Mumbai Suburban", description="Operating district")


class PINSetupRequest(BaseModel):
    pin: str = Field(..., pattern=r"^\d{4}$", description="4-digit numeric PIN")


class PINLoginRequest(BaseModel):
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{9,14}$")
    pin: str = Field(..., pattern=r"^\d{4}$")


class EmailLoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)


class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    role: str = Field("recycler", pattern=r"^(recycler|admin)$")
    recycler_id: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    collector_id: str | None = None
    has_pin: bool = False


class UserProfileResponse(BaseModel):
    id: str
    email: str | None = None
    phone: str | None = None
    role: str
    collector_id: str | None = None
    recycler_id: str | None = None
    is_active: bool
    created_at: datetime
