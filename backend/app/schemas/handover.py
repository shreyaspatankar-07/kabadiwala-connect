"""Pydantic schemas for Verifiable Handover Record and QR Flow."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class HandoverInitiateRequest(BaseModel):
    lot_id: str = Field(..., description="Lot identifier to initiate handover for")
    weight_kg: float = Field(..., gt=0, description="Collector-measured final weight in kg")
    photo_hashes: list[str] = Field(default_factory=list, description="Fresh SHA-256 photo hashes")
    gps_lat: float = Field(..., ge=-90.0, le=90.0, description="Handover GPS latitude")
    gps_lng: float = Field(..., ge=-180.0, le=180.0, description="Handover GPS longitude")
    timestamp: datetime | None = Field(default=None, description="Handover creation timestamp")


class HandoverInitiateResponse(BaseModel):
    lot_id: str
    handover_ref_no: str
    qr_payload: str
    signature: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class HandoverConfirmRequest(BaseModel):
    handover_ref_no: str | None = Field(
        default=None, description="6-character alphanumeric reference code"
    )
    qr_payload: str | None = Field(
        default=None, description="Full scanned QR JSON payload with HMAC signature"
    )
    measured_weight_kg: float = Field(..., gt=0, description="Recycler scale weight in kg")
    final_price: float = Field(..., ge=0, description="Agreed final settlement price in INR")
    recycler_id: str | None = Field(
        default=None, description="Authorized recycler facility ID confirming handover"
    )


class HandoverConfirmResponse(BaseModel):
    lot_id: str
    handover_ref_no: str
    transaction_status: str
    is_disputed: bool
    dispute_reason: str | None = None
    measured_weight_kg: float
    original_weight_kg: float
    final_price: float
    record_hash: str
    confirmed_at: datetime

    model_config = ConfigDict(from_attributes=True)


class DownstreamStatusUpdate(BaseModel):
    status: str = Field(
        ...,
        pattern=r"^(received|dismantled|processed|certificate_issued)$",
        description="EPR downstream processing lifecycle stage",
    )


class DownstreamStatusResponse(BaseModel):
    lot_id: str
    downstream_status: str
    updated_at: datetime


class HandoverVerificationResponse(BaseModel):
    handover_ref_no: str
    is_valid: bool
    lot_id: str
    category: str
    collector_weight_kg: float
    measured_weight_kg: float | None = None
    final_price: float | None = None
    timestamp: datetime
    recycler_confirmed: bool
    confirmed_at: datetime | None = None
    confirmed_by: str | None = None
    downstream_status: str
    record_hash: str
    integrity_status: str
