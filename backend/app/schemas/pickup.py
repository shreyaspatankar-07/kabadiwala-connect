"""Pydantic v2 schemas for Doorstep Citizen Pickup Requests."""

import uuid
from datetime import datetime
from typing import Any

from pydantic import AliasChoices, BaseModel, ConfigDict, Field


class PickupCreateSchema(BaseModel):
    """Payload to create a citizen doorstep pickup request."""

    lat: float = Field(
        ...,
        validation_alias=AliasChoices("lat", "latitude"),
        ge=-90.0,
        le=90.0,
        description="Citizen latitude coordinate",
    )
    lng: float = Field(
        ...,
        validation_alias=AliasChoices("lng", "longitude"),
        ge=-180.0,
        le=180.0,
        description="Citizen longitude coordinate",
    )
    address: str | None = Field(
        default=None,
        validation_alias=AliasChoices("address", "address_text", "addressText"),
        description="Optional textual street/locality address",
    )
    categories: list[str] = Field(
        default_factory=lambda: ["CABLES"],
        description="Selected e-waste categories (e.g. ['CABLES', 'BATTERIES', 'CRT', 'PCB'])",
    )
    photos: list[str] = Field(
        default_factory=list,
        validation_alias=AliasChoices("photos", "photo_urls", "photoUrls"),
        description="Base64 or image URLs of scrap items",
    )
    phone: str = Field(
        ...,
        validation_alias=AliasChoices("phone", "citizen_phone", "citizenPhone"),
        min_length=10,
        max_length=20,
        description="Citizen mobile number",
    )
    otp: str = Field(
        default="123456",
        description="Single-use SMS OTP verification code",
    )
    preferred_time_slot: str | None = Field(
        default=None,
        validation_alias=AliasChoices("preferred_time_slot", "time_slot", "timeSlot"),
        description="Preferred pickup time window (e.g. 'Morning 9 AM - 12 PM')",
    )

    model_config = ConfigDict(populate_by_name=True)


class PickupResponseSchema(BaseModel):
    """Detailed response for a pickup request."""

    id: uuid.UUID
    public_code: str
    status: str
    categories: list[str]
    photo_urls: list[str]
    address_text: str | None = None
    latitude: float
    longitude: float
    estimated_distance_km: float | None = None
    assigned_collector_id: str | None = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PickupStatusSchema(BaseModel):
    """Citizen live-tracking status payload."""

    public_code: str
    status: str
    collector_assigned: bool
    collector_id: str | None = None
    arrival_eta: str | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class PickupNearbyRequest(BaseModel):
    """Query parameters for nearby collector pickup discovery."""

    lat: float = Field(ge=-90.0, le=90.0)
    lng: float = Field(ge=-180.0, le=180.0)
    radius_meters: float = Field(default=2500.0, gt=0, le=50000.0)


class PickupCompleteSchema(BaseModel):
    """Completion payload linking lot ID."""

    lot_id: str | None = Field(default=None, description="Optional offline or online lot ID")
