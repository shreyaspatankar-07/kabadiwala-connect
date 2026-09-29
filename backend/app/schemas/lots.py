"""Pydantic schemas for E-waste lots (Transactions)."""

from datetime import datetime

from pydantic import AliasChoices, BaseModel, ConfigDict, Field


class LotCreate(BaseModel):
    client_lot_id: str = Field(
        ...,
        validation_alias=AliasChoices("client_lot_id", "client_tx_id", "clientLotUuid"),
        description="Client-generated unique UUID for offline idempotency",
    )
    category: str = Field(..., max_length=50)
    weight_kg: float = Field(
        ...,
        validation_alias=AliasChoices("weight_kg", "weightKg"),
        gt=0,
    )
    quoted_price: float = Field(
        ...,
        validation_alias=AliasChoices("quoted_price", "quotedPrice", "estimated_value", "estimatedValue"),
        ge=0,
    )
    collection_lat: float = Field(
        default=19.2183,
        validation_alias=AliasChoices("collection_lat", "latitude", "collectionLat", "lat"),
        ge=-90.0,
        le=90.0,
    )
    collection_lng: float = Field(
        default=72.9781,
        validation_alias=AliasChoices("collection_lng", "longitude", "collectionLng", "lng"),
        ge=-180.0,
        le=180.0,
    )
    created_at_utc: datetime | None = Field(
        default=None,
        validation_alias=AliasChoices("created_at_utc", "created_at", "createdAt"),
    )
    photo_hashes: list[str] = Field(
        default_factory=list,
        validation_alias=AliasChoices("photo_hashes", "photoHashes"),
    )


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
    collector_confirmed: bool = True
    recycler_confirmed: bool = False
    anomaly_flag: bool
    anomaly_reason: str | None
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
