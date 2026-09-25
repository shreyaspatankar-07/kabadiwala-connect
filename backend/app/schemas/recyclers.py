"""Pydantic schemas for Recyclers directory and verification."""

from datetime import date, datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class RecyclerCreate(BaseModel):
    id: str = Field(..., max_length=36, description="e.g. REC-MH-042")
    name: str = Field(..., max_length=255)
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    materials_accepted: list[str] = Field(default_factory=list)
    authorization_number: str = Field(..., max_length=100)
    authorization_body: str = Field("CPCB", pattern=r"^(CPCB|SPCB|OTHER)$")
    authorization_valid_till: date
    phone: str = Field(..., max_length=20)
    offered_rates: dict[str, float] = Field(default_factory=dict)
    pickup_available: bool = False
    pickup_radius_km: float = 0.0
    service_area: dict[str, Any] = Field(default_factory=dict)


class RecyclerUpdate(BaseModel):
    name: str | None = None
    materials_accepted: list[str] | None = None
    phone: str | None = None
    offered_rates: dict[str, float] | None = None
    pickup_available: bool | None = None
    pickup_radius_km: float | None = None
    service_area: dict[str, Any] | None = None


class RecyclerStatusUpdate(BaseModel):
    status: str = Field(..., pattern=r"^(verified|pending|expired|suspended)$")
    reason: str | None = None


class RecyclerResponse(BaseModel):
    id: str
    name: str
    latitude: float
    longitude: float
    materials_accepted: list[str]
    authorization_number: str
    authorization_body: str
    authorization_status: str
    authorization_valid_till: date
    phone: str
    offered_rates: dict[str, Any]
    pickup_available: bool
    pickup_radius_km: float
    service_area: dict[str, Any]
    rating: float
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class RecyclerNearbyResponse(RecyclerResponse):
    distance_km: float
