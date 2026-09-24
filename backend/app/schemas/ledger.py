"""Pydantic schemas for Collector Cash & Credit Ledger."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class LedgerEntryCreate(BaseModel):
    client_entry_id: str | None = Field(None, description="Offline client UUID for idempotency")
    lot_id: str | None = None
    entry_type: str = Field(..., pattern=r"^(credit|debit)$")
    amount: float = Field(..., ge=0)
    payment_mode: str = Field("cash_received", pattern=r"^(cash_received|pending|digital_paid)$")
    description: str = Field(..., max_length=255)
    recorded_at: datetime | None = None


class LedgerEntryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    collector_id: str
    lot_id: str | None
    entry_type: str
    amount: float
    payment_mode: str
    description: str
    balance_after: float
    recorded_at: datetime
    created_at: datetime


class LedgerSummary(BaseModel):
    collector_id: str
    total_earned_inr: float
    cash_received_inr: float
    pending_inr: float
    current_balance_inr: float
    total_transactions: int
