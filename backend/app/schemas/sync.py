"""Pydantic schemas for Offline-First Synchronization (Push & Pull)."""

from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.schemas.ledger import LedgerEntryResponse
from app.schemas.lots import LotResponse
from app.schemas.materials import MaterialResponse
from app.schemas.prices import PriceResponse
from app.schemas.recyclers import RecyclerResponse


class SyncOperation(BaseModel):
    client_tx_id: str = Field(..., description="Unique client transaction UUID for idempotency")
    action: str = Field(..., pattern=r"^(create_lot|update_lot|record_cash_payment)$")
    payload: dict[str, Any]
    client_timestamp: datetime


class SyncPushRequest(BaseModel):
    operations: list[SyncOperation] = Field(..., max_length=50)


class SyncPushResponse(BaseModel):
    processed: list[str] = Field(description="List of processed client_tx_ids")
    conflicts: list[dict[str, Any]] = Field(default_factory=list)
    server_time: datetime


class SafetyContentItem(BaseModel):
    id: str
    category: str
    hazard_level: str
    pictogram_url: str
    audio_prompt_urls: dict[str, str]
    title_vernacular: dict[str, str]
    instructions_vernacular: dict[str, str]
    dos: list[str]
    donts: list[str]


class SyncPullResponse(BaseModel):
    cursor: str
    server_time: datetime
    materials: list[MaterialResponse]
    prices: list[PriceResponse]
    recyclers: list[RecyclerResponse]
    safety_content: list[SafetyContentItem]
    my_lots: list[LotResponse]
    my_ledger: list[LedgerEntryResponse]
