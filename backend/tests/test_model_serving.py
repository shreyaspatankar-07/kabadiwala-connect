"""Automated Tests for LightGBM Valuation and Isolation Forest Fraud Detection Serving Endpoints."""

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_valuation_endpoint_success():
    """Test POST /api/v1/valuate predicts fair market price using LightGBM."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "PCB",
            "weight_kg": 10.0,
            "condition_score": 0.9,
            "region_index": 420.0,
            "market_demand_index": 1.0,
        }
        res = await client.post("/api/v1/valuate", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert "predicted_price" in data
        assert "unit_price_per_kg" in data
        assert data["currency"] == "INR"
        assert data["status"] == "success"
        assert data["predicted_price"] > 0
        assert data["unit_price_per_kg"] > 0


@pytest.mark.asyncio
async def test_valuation_endpoint_invalid_weight():
    """Test POST /api/v1/valuate with weight <= 0 triggers 422 Unprocessable Entity."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "Battery",
            "weight_kg": -2.0,
            "condition_score": 1.0,
            "region_index": 120.0,
        }
        res = await client.post("/api/v1/valuate", json=payload)
        assert res.status_code == 422


@pytest.mark.asyncio
async def test_fraud_check_normal_transaction():
    """Test POST /api/v1/fraud-check returns Normal (1) for reliable transaction."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "user_history_score": 0.95,
            "transaction_frequency": 12.0,
            "weight_anomaly_score": 0.05,
            "price_variance": 0.02,
        }
        res = await client.post("/api/v1/fraud-check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["prediction"] == 1
        assert data["classification"] == "Normal"
        assert data["is_fraud"] is False
        assert data["status"] == "success"


@pytest.mark.asyncio
async def test_fraud_check_anomalous_transaction():
    """Test POST /api/v1/fraud-check returns Fraudulent/Anomaly (-1) for severe outlier transaction."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "user_history_score": 0.05,
            "transaction_frequency": 95.0,
            "weight_anomaly_score": 0.95,
            "price_variance": 0.90,
        }
        res = await client.post("/api/v1/fraud-check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["prediction"] == -1
        assert data["classification"] == "Fraudulent/Anomaly"
        assert data["is_fraud"] is True
        assert data["status"] == "success"


@pytest.mark.asyncio
async def test_error_handling_when_model_missing():
    """Test that endpoints return HTTP 500 when model binary is uninitialized."""
    # Temporarily set model to None
    orig_val_model = getattr(app.state, "valuation_model", None)
    app.state.valuation_model = None

    try:
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://testserver") as client:
            payload = {
                "category": "CRT",
                "weight_kg": 5.0,
                "condition_score": 0.8,
                "region_index": 45.0,
            }
            res = await client.post("/api/v1/valuate", json=payload)
            assert res.status_code == 500
            err_body = res.json()
            err_msg = err_body.get("detail") or err_body.get("error", {}).get("message", "")
            assert "Valuation model binary" in err_msg
    finally:
        app.state.valuation_model = orig_val_model
