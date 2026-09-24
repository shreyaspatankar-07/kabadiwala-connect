"""Pydantic schemas for E-waste lots (Transactions)."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class LotCreate(BaseModel):
    client_lot_id: str = Field(
        ..., description="Client-generated unique UUID for offline idempotency"
    )
    category: str = Field(..., max_length=50)
    weight_kg: float = Field(..., gt=0)
    quoted_price: float = Field(..., ge=0)
    collection_lat: float = Field(..., ge=-90.0, le=90.0)
    collection_lng: float = Field(..., ge=-180.0, le=180.0)
    created_at_utc: datetime | None = None
    photo_hashes: list[str] = Field(default_factory=list)


class LotStatusUpdate(BaseModel):
    transaction_status: str = Field(
        ...,
        pattern=r"^(draft|listed|matched|handover_pending|handed_over|confirmed|disputed|cancelled)$",
    )
    final_price: float | None = None
    recycler_id: str | None = None
    handover_lat: float | None = None
    handover_lng: float | None = None
    anomaly_flag: bool | None = None
    anomaly_reason: str | None = None


class LotResponse(BaseModel):
    lot_id: str
    collector_id: str
    category: str
    weight_kg: float
    quoted_price: float
    final_price: float | None
    recycler_id: str | None
    collection_lat: float
    collection_lng: float
    handover_lat: float | None
    handover_lng: float | None
    created_at: datetime
    handover_at: datetime | None
    payment_status: str
    transaction_status: str
    anomaly_flag: bool
    anomaly_reason: str | None
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
