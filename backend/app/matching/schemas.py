"""Pydantic schemas for Recycler Discovery and Matching Engine."""

from datetime import date, datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class LotMatchInput(BaseModel):
    category: str = Field(..., description="E-waste category (e.g. PCB, CRT, Batteries, Cables)")
    weight_kg: float = Field(default=1.0, gt=0, description="Approximate weight in kg")
    collection_lat: float = Field(..., ge=-90.0, le=90.0, description="Collector latitude")
    collection_lng: float = Field(..., ge=-180.0, le=180.0, description="Collector longitude")
    district: str | None = Field(default=None, description="Collector district/city")
    lot_id: str | None = Field(default=None, description="Optional local or server lot identifier")


class RecyclerCandidate(BaseModel):
    id: str
    name: str
    latitude: float
    longitude: float
    materials_accepted: list[str]
    authorization_number: str = "REG-MINT-DEFAULT"
    authorization_status: str
    authorization_valid_till: date | str
    phone: str
    offered_rates: dict[str, float] = Field(default_factory=dict)
    pickup_available: bool = False
    pickup_radius_km: float = 0.0
    service_area: dict[str, Any] = Field(default_factory=dict)
    rating: float = 0.0
    completion_rate: float | None = None
    confirmation_speed_hours: float | None = None


class ScoreBreakdown(BaseModel):
    offered_rate: float = Field(..., description="Weighted score contribution from offered rate")
    distance: float = Field(..., description="Weighted score contribution from proximity")
    pickup_available: float = Field(..., description="Weighted score contribution from pickup")
    completion_rate: float = Field(
        ..., description="Weighted score contribution from completion rate"
    )
    confirmation_speed: float = Field(
        ..., description="Weighted score contribution from confirmation speed"
    )
    rating: float = Field(..., description="Weighted score contribution from rating")


class RankedRecycler(BaseModel):
    recycler_id: str
    name: str
    phone: str
    rank: int
    score: float
    score_breakdown: ScoreBreakdown
    distance_km: float
    offered_rate: float
    pickup_available: bool
    estimated_pickup_time: str
    authorization_number: str | None = None
    rating: float = 0.0

    model_config = ConfigDict(from_attributes=True)


class MatchRankingResponse(BaseModel):
    lot_id: str | None = None
    category: str
    total_candidates_evaluated: int
    candidates: list[RankedRecycler]
    algorithm: str = "rule_based"
    matched_at: datetime
