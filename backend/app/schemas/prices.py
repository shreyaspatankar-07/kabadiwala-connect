"""Pydantic schemas for Prices and Price Board."""

import uuid
from datetime import datetime

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
    source: str = Field("synthetic", pattern=r"^(recycler_quote|field_survey|synthetic)$")


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
    created_at: datetime


class PriceBoardCategory(BaseModel):
    category: str
    sub_category: str | None
    unit: str
    min_rate_inr: float
    max_rate_inr: float
    avg_buying_price: float


class PriceBoardResponse(BaseModel):
    district: str
    valid_until: datetime
    rates: list[PriceBoardCategory]
