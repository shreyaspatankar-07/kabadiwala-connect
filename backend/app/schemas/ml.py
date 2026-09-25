"""Pydantic schemas for ML endpoints: Anomaly Detection, Valuation, MLOps Manifest, and Drift Monitoring."""

from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class PreviousLotContext(BaseModel):
    collector_id: Optional[str] = None
    category: Optional[str] = None
    weight_kg: float = 0.0
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    elapsed_seconds: int = 99999


class AnomalyCheckRequest(BaseModel):
    category: str = Field(..., description="E-waste category: PCB, Cables, Batteries, CRT, LCD, Motors_Magnets, Mixed_Plastics, Other")
    weight_kg: float = Field(..., gt=0.0, description="Measured lot weight in kilograms")
    final_price: float = Field(..., ge=0.0, description="Total price quoted or paid in INR")
    collector_id: Optional[str] = Field(None, description="Collector reference ID")
    latitude: Optional[float] = Field(None, description="Current GPS latitude")
    longitude: Optional[float] = Field(None, description="Current GPS longitude")
    previous_lot: Optional[PreviousLotContext] = Field(None, description="Context of collector's previous lot for rapid sequence checks")


class AnomalyCheckResponse(BaseModel):
    is_anomalous: bool
    anomaly_score: float = Field(..., description="Normalized anomaly score from 0.0 (normal) to 1.0 (severe)")
    flags: List[str]
    reasons: List[str]
    category: str
    weight_kg: float
    final_price: float
    price_per_kg: float


class ValuationPredictRequest(BaseModel):
    category: str
    sub_category: Optional[str] = "Standard"
    weight_kg: float = Field(..., gt=0.0)
    condition: str = Field("broken", description="working | broken | damaged | burnt")
    location_district: str = Field("Mumbai", description="Maharashtra district")
    month: Optional[int] = Field(None, ge=1, le=12, description="Month 1..12 (defaults to current month)")
    rolling_7d_median: Optional[float] = Field(None, gt=0.0)
    rolling_30d_median: Optional[float] = Field(None, gt=0.0)


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
    metrics: Dict[str, Any]
    parameters: Optional[Dict[str, Any]] = None
    download_url: str


class ModelManifestResponse(BaseModel):
    registry_version: str
    last_updated: str
    models: Dict[str, ModelEntrySchema]


class DriftCheckRequest(BaseModel):
    feature_name: str = "price_per_kg"
    expected_baseline: List[float] = Field(..., min_length=5, description="Reference baseline feature distribution")
    actual_batch: List[float] = Field(..., min_length=5, description="Recent production monitoring distribution")
    num_buckets: int = Field(10, ge=2, le=50)


class DriftCheckResponse(BaseModel):
    feature_name: str
    psi: float
    status: str
    is_drift_detected: bool
    action_required: str
    message: str
    bucket_breakdown: List[Dict[str, float]]
