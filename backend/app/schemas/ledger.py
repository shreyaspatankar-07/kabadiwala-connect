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


class LedgerTransactionItem(BaseModel):
    entry_id: str
    lot_id: str | None
    category: str
    weight_kg: float
    final_price: float
    payment_status: str  # cash_received | pending | digital_paid | disputed
    recycler_name: str
    date: datetime


class CollectorLedgerOverview(BaseModel):
    collector_id: str
    today_total: float
    week_total: float
    month_total: float
    all_time_total: float
    pending_dues_count: int
    pending_dues_amount: float
    transactions: list[LedgerTransactionItem]


class MarkCashReceivedResponse(BaseModel):
    entry_id: str
    lot_id: str | None
    payment_status: str
    collector_confirmed: bool
    recycler_confirmed: bool
    is_disputed: bool
    message: str


class RecyclerConfirmCashRequest(BaseModel):
    recycler_confirmed_amount: float = Field(..., ge=0)


class RecyclerConfirmCashResponse(BaseModel):
    entry_id: str
    lot_id: str | None
    payment_status: str
    is_disputed: bool
    dispute_reason: str | None = None


class EarningsStatementItem(BaseModel):
    lot_id: str | None
    category: str
    weight_kg: float
    amount: float
    payment_status: str
    recycler_name: str
    date: datetime


class EarningsStatementResponse(BaseModel):
    statement_ref_no: str
    collector_id: str
    from_date: datetime
    to_date: datetime
    total_earned: float
    cash_received: float
    pending_amount: float
    total_transactions: int
    total_weight_kg: float
    items: list[EarningsStatementItem]
    generated_at: datetime


class UPIIntentResponse(BaseModel):
    entry_id: str
    amount: float
    upi_uri: str
    payee_name: str
    payee_vpa: str
