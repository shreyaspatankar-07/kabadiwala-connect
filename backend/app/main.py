"""FastAPI main application entrypoint for Kabadiwala Connect.

Integrates:
- On-device and server ML model serving with lifespan memory caching:
  - valuation_lightgbm.txt (LightGBM fair market pricing regressor)
  - anomaly_detector.joblib (Isolation Forest transaction fraud detector)
- Valuation endpoint: POST /api/v1/valuate
- Fraud endpoint: POST /api/v1/fraud-check
- Core platform routers (collectors, recyclers, matching, handover, ledger, safety, verification, WebSocket)
- CORS and structured JSON logging middleware
"""

import logging
import os
import sys
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

# Ensure repository root is on sys.path for monorepo ml imports
repo_root = Path(__file__).resolve().parent.parent.parent
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

import joblib
import lightgbm as lgb
import numpy as np
import pandas as pd
from fastapi import FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.models.system_config import SystemConfig
from ml.src.anomaly.anomaly_detector import FraudAnomalyDetector

from app.api.v1.collectors import router as collectors_router
from app.api.v1.handover import router as handover_router
from app.api.v1.ledger import router as ledger_router
from app.api.v1.matching import router as matching_router
from app.api.v1.ml import router as ml_router
from app.api.v1.recyclers import router as recyclers_router
from app.api.v1.router import api_v1_router
from app.api.v1.safety import router as safety_router
from app.api.v1.verify import router as verify_router
from app.api.v1.ws import router as ws_router
from app.core.config import settings
from app.core.errors import AppError, app_error_handler, generic_http_error_handler
from app.core.logging import StructuredLoggingMiddleware

logger = logging.getLogger("kabadiwala.ml")


# ==============================================================================
# Pydantic Schemas for Valuation & Fraud Detection
# ==============================================================================


class ValuationRequest(BaseModel):
    """Payload for e-waste scrap fair market valuation."""

    category: str | None = Field(
        default=None,
        description="E-waste category, e.g., PCB, Battery, Cables, CRT, LCD, Mobile",
        examples=["PCB"],
    )
    weight_kg: float = Field(
        ...,
        gt=0.0,
        description="Lot weight in kilograms (must be positive)",
        examples=[10.5],
    )
    condition_score: float = Field(
        ...,
        ge=0.0,
        description="Condition multiplier / score (e.g., 1.0 for working, 0.8 for broken)",
        examples=[0.9],
    )
    region_index: float = Field(
        ...,
        ge=0.0,
        description="Regional market baseline index or base rate in INR per kg",
        examples=[420.0],
    )
    market_demand_index: float = Field(
        default=1.0,
        ge=0.0,
        description="Local market demand factor (1.0 = standard benchmark)",
        examples=[1.0],
    )


class ValuationResponse(BaseModel):
    """Predicted fair market price output from LightGBM."""

    predicted_price: float = Field(..., description="Estimated total fair market price in INR")
    unit_price_per_kg: float = Field(..., description="Predicted price rate per kilogram in INR")
    currency: str = Field(default="INR", description="Currency identifier")
    status: str = Field(default="success", description="Prediction status")


class TransactionRequest(BaseModel):
    """Payload for transaction anomaly and fraud detection."""

    user_history_score: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Historical reliability score of the collector (0.0 to 1.0)",
        examples=[0.85],
    )
    transaction_frequency: float = Field(
        ...,
        ge=0.0,
        description="Collector transaction velocity / frequency count per time window",
        examples=[12.0],
    )
    weight_anomaly_score: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Weight anomaly score vs category norms (0.0 = typical, 1.0 = outlier)",
        examples=[0.05],
    )
    price_variance: float = Field(
        ...,
        ge=0.0,
        le=1.0,
        description="Price variance score against regional benchmark (0.0 = exact, 1.0 = large deviation)",
        examples=[0.08],
    )


class FraudCheckResponse(BaseModel):
    """Fraud / Anomaly evaluation output from Isolation Forest."""

    prediction: int = Field(
        ...,
        description="Inference prediction: 1 for Normal, -1 for Fraudulent/Anomaly",
        examples=[1],
    )
    classification: str = Field(
        ...,
        description="Human-readable classification: 'Normal' or 'Fraudulent/Anomaly'",
        examples=["Normal"],
    )
    is_fraud: bool = Field(
        ...,
        description="True if an anomaly or fraudulent transaction is flagged, False otherwise",
        examples=[False],
    )
    anomaly_score: float | None = Field(
        default=None,
        description="Raw decision function score from Isolation Forest",
        examples=[0.1425],
    )
    status: str = Field(default="success", description="Evaluation status")


# ==============================================================================
# Model Directory Discovery & Lifespan Management
# ==============================================================================


def _resolve_ml_models_dir() -> Path:
    """Finds the ml_models directory across different execution working directories."""
    candidates = [
        Path(__file__).resolve().parent.parent / "ml_models",
        Path("ml_models").resolve(),
        Path(__file__).resolve().parent.parent.parent / "ml_models",
        Path(__file__).resolve().parent.parent.parent / "ml" / "models",
    ]
    for candidate in candidates:
        if candidate.exists() and candidate.is_dir():
            return candidate
    return Path(__file__).resolve().parent.parent / "ml_models"


def load_ml_models(target_state: Any) -> None:
    """Load both LightGBM and Isolation Forest models into target_state with graceful error handling."""
    models_dir = _resolve_ml_models_dir()
    logger.info("Initializing ML models from directory: %s", models_dir)

    # 1. Load LightGBM Valuation Regressor
    lgb_path = models_dir / "valuation_lightgbm.txt"
    target_state.valuation_model = None
    try:
        if lgb_path.exists():
            target_state.valuation_model = lgb.Booster(model_file=str(lgb_path))
            logger.info("Loaded LightGBM valuation model from %s", lgb_path)
        else:
            logger.warning("Valuation model file not found at %s", lgb_path)
    except Exception as e:
        logger.error("Failed to load LightGBM valuation model from %s: %s", lgb_path, e)

    # 2. Load Isolation Forest Fraud Detector
    fraud_path = models_dir / "anomaly_detector.joblib"
    target_state.fraud_model = None
    try:
        if fraud_path.exists():
            target_state.fraud_model = joblib.load(str(fraud_path))
            logger.info("Loaded Isolation Forest fraud model from %s", fraud_path)
        else:
            logger.warning("Fraud detector model file not found at %s", fraud_path)
    except Exception as e:
        logger.error("Failed to load fraud detector model from %s: %s", fraud_path, e)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager: loads ML models and dynamic fraud thresholds from database.

    Stores model handles on app.state to avoid reloading on each request.
    Handles missing binaries and connection fallbacks gracefully with informative logging.
    """
    load_ml_models(app.state)

    # Dynamic ML Engine Configuration: Fetch fraud_thresholds from system_configs
    fraud_config: dict[str, Any] = {}
    try:
        async with AsyncSessionLocal() as session:
            stmt = select(SystemConfig).where(SystemConfig.key == "fraud_thresholds")
            result = await session.execute(stmt)
            config_entry = result.scalar_one_or_none()
            if config_entry and config_entry.value:
                fraud_config = config_entry.value
                logger.info("Loaded dynamic fraud thresholds from system_configs: %s", fraud_config)
            else:
                logger.info("No system_configs record for 'fraud_thresholds'; using default thresholds.")
    except Exception as exc:
        logger.warning(
            "Could not load dynamic fraud thresholds from system_configs (%s); falling back to defaults.",
            exc,
        )

    # Initialize global FraudAnomalyDetector instance with live thresholds
    models_dir = _resolve_ml_models_dir()
    fraud_detector = FraudAnomalyDetector(
        model_path=models_dir / "anomaly_detector.joblib",
        config=fraud_config,
    )
    app.state.fraud_detector = fraud_detector

    # Connect to MLService singleton for live application requests
    try:
        from app.services.ml_service import ml_service

        ml_service.anomaly_detector = fraud_detector
    except Exception as exc:
        logger.debug("Could not attach dynamic detector to ml_service: %s", exc)

    yield

    # Teardown logic
    app.state.valuation_model = None
    app.state.fraud_model = None
    app.state.fraud_detector = None
    logger.info("ML model resources released.")


# ==============================================================================
# FastAPI Application Factory
# ==============================================================================

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "Vernacular, low-literacy offline-tolerant platform connecting informal "
        "e-waste collectors with authorized recyclers under India's E-Waste Rules 2022."
    ),
    lifespan=lifespan,
)

# Eagerly initialize models on app.state for test harnesses and direct ASGI transports
load_ml_models(app.state)

# Structured JSON logging middleware
app.add_middleware(StructuredLoggingMiddleware)

# CORS configuration: allows localhost, 127.0.0.1, and any Vercel production/preview deployment domain
cors_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:3001",
    "http://127.0.0.1:3001",
]
if os.getenv("ADDITIONAL_CORS_ORIGINS"):
    cors_origins.extend(
        [o.strip() for o in os.getenv("ADDITIONAL_CORS_ORIGINS", "").split(",") if o.strip()]
    )

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_origin_regex=r"https://.*\.vercel\.app",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Custom exception handlers for consistent error envelope
app.add_exception_handler(AppError, app_error_handler)
app.add_exception_handler(HTTPException, generic_http_error_handler)


# ==============================================================================
# Model Serving Endpoints (Valuation & Fraud Detection)
# ==============================================================================


@app.post(
    "/api/v1/valuate",
    response_model=ValuationResponse,
    status_code=status.HTTP_200_OK,
    tags=["Machine Learning & Valuation"],
    summary="Estimate fair market scrap valuation using LightGBM",
)
async def valuate_scrap(req: ValuationRequest, request: Request) -> ValuationResponse:
    """Accept ValuationRequest, format as Pandas DataFrame / 2D array (4 features),

    run LightGBM inference, and return the predicted fair market price.
    """
    model: lgb.Booster | None = getattr(request.app.state, "valuation_model", None)
    if model is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=(
                "Valuation model binary (valuation_lightgbm.txt) is not available or "
                "failed to initialize during startup."
            ),
        )

    try:
        # Construct 4-feature tabular DataFrame matching model schema:
        # ['weight_kg', 'regional_base_rate', 'condition_multiplier', 'market_demand_index']
        features_df = pd.DataFrame(
            [
                {
                    "weight_kg": float(req.weight_kg),
                    "regional_base_rate": float(req.region_index),
                    "condition_multiplier": float(req.condition_score),
                    "market_demand_index": float(req.market_demand_index),
                }
            ]
        )

        preds = model.predict(features_df)
        predicted_total = float(preds[0])
        unit_price = predicted_total / req.weight_kg if req.weight_kg > 0 else predicted_total

        return ValuationResponse(
            predicted_price=round(predicted_total, 2),
            unit_price_per_kg=round(unit_price, 2),
            currency="INR",
            status="success",
        )
    except Exception as exc:
        logger.error("Valuation inference exception: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference error during fair-market valuation: {str(exc)}",
        ) from exc


@app.post(
    "/api/v1/fraud-check",
    response_model=FraudCheckResponse,
    status_code=status.HTTP_200_OK,
    tags=["Machine Learning & Fraud"],
    summary="Evaluate transaction for anomalies using Isolation Forest",
)
async def fraud_check(req: TransactionRequest, request: Request) -> FraudCheckResponse:
    """Accept TransactionRequest, format as 2D NumPy array, run Isolation Forest inference,

    and return whether the transaction is Normal (1) or Fraudulent/Anomaly (-1).
    """
    model: Any = getattr(request.app.state, "fraud_model", None)
    if model is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=(
                "Fraud detector model binary (anomaly_detector.joblib) is not available or "
                "failed to initialize during startup."
            ),
        )

    try:
        # Format as 2D array of 4 features
        features = np.array(
            [
                [
                    float(req.user_history_score),
                    float(req.transaction_frequency),
                    float(req.weight_anomaly_score),
                    float(req.price_variance),
                ]
            ],
            dtype=np.float64,
        )

        # Accommodate models expecting padded feature dimensions defensively
        expected_features = getattr(model, "n_features_in_", 4)
        if features.shape[1] < expected_features:
            padding = np.zeros((1, expected_features - features.shape[1]), dtype=np.float64)
            features = np.hstack([features, padding])

        prediction = int(model.predict(features)[0])
        decision_score: float | None = None
        if hasattr(model, "decision_function"):
            decision_score = float(model.decision_function(features)[0])

        is_fraud = prediction == -1
        classification = "Fraudulent/Anomaly" if is_fraud else "Normal"

        return FraudCheckResponse(
            prediction=prediction,
            classification=classification,
            is_fraud=is_fraud,
            anomaly_score=round(decision_score, 4) if decision_score is not None else None,
            status="success",
        )
    except Exception as exc:
        logger.error("Fraud detection inference exception: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference error during fraud check: {str(exc)}",
        ) from exc


# ==============================================================================
# Platform Routers & Endpoints
# ==============================================================================

# Master API v1 router
app.include_router(api_v1_router)

# Mount core routers
app.include_router(matching_router)
app.include_router(recyclers_router)
app.include_router(handover_router)
app.include_router(verify_router)
app.include_router(ledger_router)
app.include_router(ml_router)
app.include_router(safety_router)
app.include_router(collectors_router)

# WebSocket router (mounted at root scope for proxy upgrade compatibility)
app.include_router(ws_router)


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    """Health check endpoint for container probes and load balancers."""
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/api/v1/ping", tags=["Health"])
async def ping() -> dict[str, str]:
    """Basic ping endpoint for network latency and connectivity checks."""
    return {"message": "pong"}
