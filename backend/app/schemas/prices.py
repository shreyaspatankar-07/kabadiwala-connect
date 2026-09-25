"""Pydantic schemas for Prices, Price Board, History, and Field Price Reports."""

import uuid
from datetime import UTC, datetime

from pydantic import BaseModel, ConfigDict, Field


class PriceCreate(BaseModel):
    category: str = Field(..., max_length=50)
    sub_category: str | None = None
    district: str = Field(..., max_length=100)
    city: str | None = None
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    buying_price: float = Field(..., ge=0)
    selling_quoted_price: float = Field(..., ge=0)
    unit: str = Field("kg", pattern=r"^(kg|piece)$")
    market_min: float = Field(..., ge=0)
    market_max: float = Field(..., ge=0)
    recycler_id: str | None = None
    source: str = Field(
        "synthetic", pattern=r"^(recycler_quote|field_survey|synthetic|collector_report)$"
    )


class PriceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    category: str
    sub_category: str | None
    district: str
    city: str | None
    latitude: float
    longitude: float
    recorded_at: datetime
    buying_price: float
    selling_quoted_price: float
    unit: str
    market_min: float
    market_max: float
    recycler_id: str | None
    source: str
    is_flagged_for_review: bool = False
    review_reason: str | None = None
    created_at: datetime


class PriceBoardCategory(BaseModel):
    category: str
    sub_category: str | None = None
    unit: str = "kg"
    # Legacy fields for backward compatibility
    min_rate_inr: float
    max_rate_inr: float
    avg_buying_price: float

    # Prompt specific metrics
    current_buying_price: float
    market_min: float
    market_max: float
    recycler_offered_price: float
    trend_7d: str = "flat"  # "up" | "down" | "flat"
    pct_change_7d: float = 0.0
    confidence_level: str = "high"  # "high" | "medium" | "low"
    quality_score: float = 85.0
    last_updated: datetime = Field(default_factory=lambda: datetime.now(UTC))


class PriceBoardResponse(BaseModel):
    district: str
    category: str | None = None
    valid_until: datetime
    rates: list[PriceBoardCategory]

    # Quick access fields when queried for a specific category
    current_buying_price: float | None = None
    market_min: float | None = None
    market_max: float | None = None
    recycler_offered_price: float | None = None
    trend_7d: str | None = None
    pct_change_7d: float | None = None
    confidence_level: str | None = None
    last_updated: datetime | None = None


class PriceHistoryPoint(BaseModel):
    date: str  # YYYY-MM-DD
    median_price: float
    min_price: float
    max_price: float
    sample_count: int


class PriceHistoryResponse(BaseModel):
    district: str
    category: str
    days: int
    history: list[PriceHistoryPoint]


class PriceReportCreate(BaseModel):
    category: str = Field(..., min_length=2, max_length=50)
    sub_category: str | None = None
    district: str = Field(..., min_length=2, max_length=100)
    city: str | None = None
    latitude: float | None = 19.0760
    longitude: float | None = 72.8777
    offered_price: float = Field(..., gt=0, description="Price offered to collector")
    unit: str = Field("kg", pattern=r"^(kg|piece)$")
    recycler_id: str | None = None
    collector_id: str | None = None
    notes: str | None = None


class PriceReportResponse(BaseModel):
    id: uuid.UUID
    category: str
    sub_category: str | None
    district: str
    offered_price: float
    unit: str
    source: str = "collector_report"
    validation_status: str  # "passed" | "quarantined"
    is_flagged_for_review: bool
    review_reason: str | None
    created_at: datetime
