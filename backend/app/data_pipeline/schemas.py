"""Pydantic schemas and data contracts for data generation, validation, cleaning, and export."""

from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class ProvenanceSource(StrEnum):
    SYNTHETIC = "synthetic"
    FIELD_SURVEY = "field_survey"
    RECYCLER_QUOTE = "recycler_quote"
    TRANSACTION = "transaction"
    COLLECTOR_REPORT = "collector_report"


class WeightSanityRule(BaseModel):
    min_kg: float
    max_kg: float
    default_kg_per_piece: float


# Category weight sanity rules (in kg)
CATEGORY_WEIGHT_SANITY: dict[str, WeightSanityRule] = {
    "CRT": WeightSanityRule(min_kg=5.0, max_kg=40.0, default_kg_per_piece=14.0),
    "LCD panel": WeightSanityRule(min_kg=0.5, max_kg=20.0, default_kg_per_piece=3.5),
    "PCB (low grade)": WeightSanityRule(min_kg=0.05, max_kg=10.0, default_kg_per_piece=0.4),
    "PCB (mid grade)": WeightSanityRule(min_kg=0.05, max_kg=10.0, default_kg_per_piece=0.5),
    "PCB (high grade)": WeightSanityRule(min_kg=0.05, max_kg=10.0, default_kg_per_piece=0.3),
    "cables (copper)": WeightSanityRule(min_kg=0.1, max_kg=100.0, default_kg_per_piece=1.0),
    "batteries (Li-ion)": WeightSanityRule(min_kg=0.02, max_kg=10.0, default_kg_per_piece=0.15),
    "batteries (lead-acid)": WeightSanityRule(min_kg=3.0, max_kg=50.0, default_kg_per_piece=14.0),
    "motors/magnet assemblies": WeightSanityRule(min_kg=0.2, max_kg=30.0, default_kg_per_piece=2.5),
    "mixed plastics": WeightSanityRule(min_kg=0.1, max_kg=100.0, default_kg_per_piece=1.2),
}


class RawPriceObservation(BaseModel):
    """Raw candidate observation ingested from synthetic generation or app activity."""

    observation_id: str = Field(..., description="Unique UUID or client ID")
    category: str = Field(..., min_length=2, max_length=100)
    sub_category: str = Field(..., min_length=2, max_length=100)
    district: str = Field(..., min_length=2, max_length=100)
    city: str | None = None
    latitude: float = Field(..., description="Geo latitude")
    longitude: float = Field(..., description="Geo longitude")
    price: float = Field(..., description="Observed buying price in INR")
    unit: str = Field(default="kg", pattern=r"^(kg|piece)$")
    weight_kg: float | None = Field(default=None, ge=0.0)
    market_min: float | None = Field(default=None, ge=0.0)
    market_max: float | None = Field(default=None, ge=0.0)
    recycler_id: str | None = None
    collector_id: str | None = None
    source: ProvenanceSource = Field(default=ProvenanceSource.SYNTHETIC)
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    metadata: dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(from_attributes=True)


class QuarantinedRecord(BaseModel):
    """Schema for records rejected during validation or cleaning."""

    quarantine_id: str
    original_id: str
    rejection_stage: str = Field(..., description="'validation' or 'cleaning'")
    rejection_reasons: list[str]
    raw_payload: dict[str, Any]
    rejected_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class CleanedPriceObservation(BaseModel):
    """Validated, normalized, cleaned observation ready for analytical board & ML."""

    observation_id: str
    category: str
    sub_category: str
    district: str
    city: str
    latitude: float
    longitude: float
    original_price: float
    original_unit: str
    normalized_price_per_kg: float
    market_min_per_kg: float
    market_max_per_kg: float
    weight_kg: float
    recycler_id: str | None = None
    collector_id: str | None = None
    source: str
    recorded_at: datetime
    is_outlier: bool = False
    cleaned_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class AnonymizedObservation(BaseModel):
    """Observation scrubbed of all PII and with coarsened GPS (~500m precision)."""

    observation_id: str
    category: str
    sub_category: str
    district: str
    city: str
    coarsened_latitude: float
    coarsened_longitude: float
    normalized_price_per_kg: float
    weight_kg: float
    anonymized_collector_id: str | None
    recycler_id: str | None
    source: str
    recorded_at: datetime


class RollingBoardRate(BaseModel):
    category: str
    sub_category: str
    district: str
    median_7d_per_kg: float
    median_30d_per_kg: float
    mean_7d_per_kg: float
    trend: str = Field(..., pattern=r"^(up|down|flat)$")
    pct_change_7d: float
    sample_size_7d: int
    sample_size_30d: int
    quality_score: float = Field(..., ge=0.0, le=100.0)
    last_updated: datetime = Field(default_factory=lambda: datetime.now(UTC))


class DatasetQualityMetrics(BaseModel):
    total_raw_ingested: int
    valid_count: int
    quarantined_validation_count: int
    quarantined_outlier_count: int
    clean_count: int
    completeness_score: float = Field(..., ge=0.0, le=100.0)
    freshness_score: float = Field(..., ge=0.0, le=100.0)
    validity_rate_pct: float = Field(..., ge=0.0, le=100.0)
    overall_quality_score: float = Field(..., ge=0.0, le=100.0)
    evaluation_time: datetime = Field(default_factory=lambda: datetime.now(UTC))
