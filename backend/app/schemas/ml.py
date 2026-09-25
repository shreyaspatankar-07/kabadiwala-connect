"""Pydantic schemas for ML endpoints: Anomaly Detection, Valuation, MLOps Manifest, and Drift Monitoring."""

from typing import Any

from pydantic import BaseModel, Field


class PreviousLotContext(BaseModel):
    collector_id: str | None = None
    category: str | None = None
    weight_kg: float = 0.0
    latitude: float | None = None
    longitude: float | None = None
    elapsed_seconds: int = 99999


class AnomalyCheckRequest(BaseModel):
    category: str = Field(
        ...,
        description="E-waste category: PCB, Cables, Batteries, CRT, LCD, Motors_Magnets, Mixed_Plastics, Other",
    )
    weight_kg: float = Field(..., gt=0.0, description="Measured lot weight in kilograms")
    final_price: float = Field(..., ge=0.0, description="Total price quoted or paid in INR")
    collector_id: str | None = Field(None, description="Collector reference ID")
    latitude: float | None = Field(None, description="Current GPS latitude")
    longitude: float | None = Field(None, description="Current GPS longitude")
    previous_lot: PreviousLotContext | None = Field(
        None, description="Context of collector's previous lot for rapid sequence checks"
    )


class AnomalyCheckResponse(BaseModel):
    is_anomalous: bool
    anomaly_score: float = Field(
        ..., description="Normalized anomaly score from 0.0 (normal) to 1.0 (severe)"
    )
    flags: list[str]
    reasons: list[str]
    category: str
    weight_kg: float
    final_price: float
    price_per_kg: float


class ValuationPredictRequest(BaseModel):
    category: str
    sub_category: str | None = "Standard"
    weight_kg: float = Field(..., gt=0.0)
    condition: str = Field("broken", description="working | broken | damaged | burnt")
    location_district: str = Field("Mumbai", description="Maharashtra district")
    month: int | None = Field(
        None, ge=1, le=12, description="Month 1..12 (defaults to current month)"
    )
    rolling_7d_median: float | None = Field(None, gt=0.0)
    rolling_30d_median: float | None = Field(None, gt=0.0)


class ValuationPredictResponse(BaseModel):
    predicted_price_per_kg: float
    low_price_per_kg: float
    high_price_per_kg: float
    total_estimated_value: float
    total_low_value: float
    total_high_value: float
    prediction_interval: str = "90%"
    confidence_level: str


class ModelEntrySchema(BaseModel):
    model_id: str
    version: str
    filename: str
    framework: str
    task: str
    description: str
    sha256: str
    size_bytes: int
    size_mb: float
    updated_at: str
    metrics: dict[str, Any]
    parameters: dict[str, Any] | None = None
    download_url: str


class ModelManifestResponse(BaseModel):
    registry_version: str
    last_updated: str
    models: dict[str, ModelEntrySchema]


class DriftCheckRequest(BaseModel):
    feature_name: str = "price_per_kg"
    expected_baseline: list[float] = Field(
        ..., min_length=5, description="Reference baseline feature distribution"
    )
    actual_batch: list[float] = Field(
        ..., min_length=5, description="Recent production monitoring distribution"
    )
    num_buckets: int = Field(10, ge=2, le=50)


class DriftCheckResponse(BaseModel):
    feature_name: str
    psi: float
    status: str
    is_drift_detected: bool
    action_required: str
    message: str
    bucket_breakdown: list[dict[str, float]]
