"""ML API Endpoints: Anomaly Detection, Valuation, Model Registry Manifest, and Drift Monitoring."""

from fastapi import APIRouter, HTTPException, status
from app.schemas.ml import (
    AnomalyCheckRequest,
    AnomalyCheckResponse,
    ValuationPredictRequest,
    ValuationPredictResponse,
    ModelManifestResponse,
    DriftCheckRequest,
    DriftCheckResponse,
)
from app.services.ml_service import ml_service

router = APIRouter(prefix="/ml", tags=["Machine Learning & MLOps"])


@router.post(
    "/anomaly/check",
    response_model=AnomalyCheckResponse,
    status_code=status.HTTP_200_OK,
    summary="Check e-waste lot for price, weight, or spatial anomalies",
)
def check_anomaly(req: AnomalyCheckRequest) -> AnomalyCheckResponse:
    """Evaluate a scrap e-waste lot against Isolation Forest and domain rules:

    - Weight sanity bounds per category
    - Rate IQR deviation
    - Repeated identical submissions within 1h
    - GPS spatial jumps > 50km
    """
    try:
        prev_lot_dict = req.previous_lot.model_dump() if req.previous_lot else None
        res = ml_service.check_anomaly(
            category=req.category,
            weight_kg=req.weight_kg,
            final_price=req.final_price,
            collector_id=req.collector_id,
            latitude=req.latitude,
            longitude=req.longitude,
            previous_lot=prev_lot_dict,
        )
        return AnomalyCheckResponse(**res)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error evaluating anomaly checks: {str(e)}",
        )


@router.get(
    "/models/manifest",
    response_model=ModelManifestResponse,
    status_code=status.HTTP_200_OK,
    summary="Get MLOps Model Registry Version Manifest",
)
def get_model_manifest() -> ModelManifestResponse:
    """Returns current active model versions, SHA256 checksums, metrics, and download endpoints."""
    try:
        manifest = ml_service.get_manifest()
        return ModelManifestResponse(**manifest)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error loading model manifest: {str(e)}",
        )


@router.post(
    "/valuation/predict",
    response_model=ValuationPredictResponse,
    status_code=status.HTTP_200_OK,
    summary="Predict price per kg and 90% prediction interval",
)
def predict_valuation(req: ValuationPredictRequest) -> ValuationPredictResponse:
    """Predict scrap valuation using LightGBM quantile regression models."""
    try:
        res = ml_service.predict_valuation(
            category=req.category,
            sub_category=req.sub_category,
            weight_kg=req.weight_kg,
            condition=req.condition,
            location_district=req.location_district,
            month=req.month,
            rolling_7d_median=req.rolling_7d_median,
            rolling_30d_median=req.rolling_30d_median,
        )
        return ValuationPredictResponse(**res)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error predicting valuation: {str(e)}",
        )


@router.post(
    "/drift/check",
    response_model=DriftCheckResponse,
    status_code=status.HTTP_200_OK,
    summary="Calculate Population Stability Index (PSI) drift monitoring",
)
def check_drift(req: DriftCheckRequest) -> DriftCheckResponse:
    """Computes PSI between baseline and production feature distributions."""
    try:
        res = ml_service.check_distribution_drift(
            feature_name=req.feature_name,
            expected=req.expected_baseline,
            actual=req.actual_batch,
            num_buckets=req.num_buckets,
        )
        return DriftCheckResponse(**res)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating drift metrics: {str(e)}",
        )
