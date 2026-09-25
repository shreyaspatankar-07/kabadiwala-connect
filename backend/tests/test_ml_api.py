"""Automated Tests for ML Endpoints: Anomaly Detection, Valuation, Manifest, and Drift Monitoring."""

import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app


@pytest.mark.asyncio
async def test_anomaly_check_normal_lot():
    """Normal realistic lot passes with no flags."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "PCB",
            "weight_kg": 5.0,
            "final_price": 2100.0,  # ~420/kg
            "collector_id": "KC-C-TEST01",
            "latitude": 19.0760,
            "longitude": 72.8777,
        }
        res = await client.post("/ml/anomaly/check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["is_anomalous"] is False
        assert len(data["flags"]) == 0
        assert data["price_per_kg"] == 420.0
        assert "No anomalies detected" in data["reasons"][0]


@pytest.mark.asyncio
async def test_anomaly_check_implausible_weight():
    """Lot with weight outside category bounds triggers IMPLAUSIBLE_WEIGHT flag."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "CRT",
            "weight_kg": 0.5,  # CRT minimum is 4.0 kg
            "final_price": 25.0,
            "collector_id": "KC-C-TEST01",
        }
        res = await client.post("/ml/anomaly/check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["is_anomalous"] is True
        assert "IMPLAUSIBLE_WEIGHT" in data["flags"]
        assert any("Weight 0.5 kg is outside expected bounds" in r for r in data["reasons"])


@pytest.mark.asyncio
async def test_anomaly_check_price_outside_iqr():
    """Lot with extreme rate triggers PRICE_OUTSIDE_IQR flag."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "Batteries",
            "weight_kg": 10.0,
            "final_price": 25000.0,  # ₹2500/kg (normal IQR is ~80-160/kg)
            "collector_id": "KC-C-TEST01",
        }
        res = await client.post("/ml/anomaly/check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["is_anomalous"] is True
        assert "PRICE_OUTSIDE_IQR" in data["flags"]


@pytest.mark.asyncio
async def test_anomaly_check_repeated_lot_and_gps_jump():
    """Duplicate identical lot and rapid GPS jump trigger appropriate flags."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "Cables",
            "weight_kg": 15.0,
            "final_price": 10200.0,
            "collector_id": "KC-C-DUPLICATE",
            "latitude": 18.5204,  # Pune
            "longitude": 73.8567,
            "previous_lot": {
                "collector_id": "KC-C-DUPLICATE",
                "category": "Cables",
                "weight_kg": 15.0,
                "latitude": 19.0760,  # Mumbai (~120 km away)
                "longitude": 72.8777,
                "elapsed_seconds": 600,  # 10 minutes ago
            },
        }
        res = await client.post("/ml/anomaly/check", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["is_anomalous"] is True
        assert "REPEATED_IDENTICAL_LOT" in data["flags"]
        assert "GPS_JUMP_SUSPICIOUS" in data["flags"]


@pytest.mark.asyncio
async def test_model_manifest_endpoint():
    """GET /ml/models/manifest returns registry version and registered models."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        res = await client.get("/ml/models/manifest")
        assert res.status_code == 200
        data = res.json()
        assert "registry_version" in data
        assert "models" in data
        assert "ewaste-mobilenetv3-small-int8" in data["models"]
        assert "ewaste-valuation-lgbm" in data["models"]
        assert "ewaste-anomaly-isolation-forest" in data["models"]


@pytest.mark.asyncio
async def test_valuation_predict_endpoint():
    """POST /ml/valuation/predict returns point estimate and 90% quantile prediction interval."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        payload = {
            "category": "PCB",
            "sub_category": "Motherboard",
            "weight_kg": 10.0,
            "condition": "working",
            "location_district": "Pune",
            "month": 9,
            "rolling_7d_median": 430.0,
            "rolling_30d_median": 420.0,
        }
        res = await client.post("/ml/valuation/predict", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert data["predicted_price_per_kg"] > 0
        assert data["low_price_per_kg"] <= data["predicted_price_per_kg"]
        assert data["high_price_per_kg"] >= data["predicted_price_per_kg"]
        assert data["total_estimated_value"] == round(data["predicted_price_per_kg"] * 10.0, 2)
        assert data["prediction_interval"] == "90%"


@pytest.mark.asyncio
async def test_drift_monitoring_endpoint():
    """POST /ml/drift/check calculates PSI between baseline and monitoring batch."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as client:
        # Case A: Stable distributions (draw from same normal distribution)
        base = [420.0 + i * 2.0 for i in range(30)]
        curr = [420.5 + i * 2.0 for i in range(30)]
        payload_stable = {
            "feature_name": "price_per_kg",
            "expected_baseline": base,
            "actual_batch": curr,
            "num_buckets": 5,
        }
        res = await client.post("/ml/drift/check", json=payload_stable)
        assert res.status_code == 200
        data = res.json()
        assert data["is_drift_detected"] is False
        assert data["status"] == "STABLE"

        # Case B: Significant shift (prices dropped drastically)
        payload_shifted = {
            "feature_name": "price_per_kg",
            "expected_baseline": base,
            "actual_batch": [100.0 + i * 1.5 for i in range(30)],
            "num_buckets": 5,
        }
        res_shifted = await client.post("/ml/drift/check", json=payload_shifted)
        assert res_shifted.status_code == 200
        data_shifted = res_shifted.json()
        assert data_shifted["is_drift_detected"] is True
        assert data_shifted["status"] == "CRITICAL_DRIFT"
        assert "WARNING: Population Stability Index" in data_shifted["message"]
