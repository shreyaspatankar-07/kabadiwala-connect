"""Tests for SystemConfig model and Dynamic FraudAnomalyDetector thresholds."""

import pytest
from sqlalchemy import select

from app.models.schema import Base
from app.models.system_config import SystemConfig
from ml.src.anomaly.anomaly_detector import FraudAnomalyDetector, AnomalyDetector


def test_system_config_table_registered():
    """Verify system_configs table is registered in Base metadata."""
    assert "system_configs" in Base.metadata.tables
    table = Base.metadata.tables["system_configs"]
    assert "key" in table.c
    assert table.c["key"].primary_key
    assert "value" in table.c
    assert "description" in table.c


@pytest.mark.asyncio
async def test_system_config_persistence(db_session):
    """Verify persisting and querying dynamic system config entries."""
    payload = {
        "velocity_burst_seconds": 90,
        "max_gps_jump_km": 30.0,
        "weight_tolerance_percent": 8.5,
    }
    config_entry = SystemConfig(
        key="test_fraud_thresholds",
        value=payload,
        description="Test fraud thresholds",
    )
    db_session.add(config_entry)
    await db_session.flush()

    stmt = select(SystemConfig).where(SystemConfig.key == "test_fraud_thresholds")
    res = await db_session.execute(stmt)
    saved = res.scalar_one_or_none()
    assert saved is not None
    assert saved.key == "test_fraud_thresholds"
    assert saved.value["velocity_burst_seconds"] == 90
    assert saved.value["max_gps_jump_km"] == 30.0
    assert saved.value["weight_tolerance_percent"] == 8.5


def test_fraud_anomaly_detector_defaults():
    """Verify detector falls back to safe defaults when config is missing or empty."""
    detector = FraudAnomalyDetector(config=None)
    assert detector.velocity_burst_seconds == 120
    assert detector.max_gps_jump_km == 50.0
    assert detector.weight_tolerance_percent == 10.0

    # Also verify AnomalyDetector alias
    alias_detector = AnomalyDetector(config={})
    assert alias_detector.velocity_burst_seconds == 120
    assert alias_detector.max_gps_jump_km == 50.0
    assert alias_detector.weight_tolerance_percent == 10.0


def test_fraud_anomaly_detector_custom_thresholds():
    """Verify detector applies custom thresholds supplied from system_configs."""
    custom_cfg = {
        "velocity_burst_seconds": 60,
        "max_gps_jump_km": 25.0,
        "weight_tolerance_percent": 5.0,
    }
    detector = FraudAnomalyDetector(config=custom_cfg)
    assert detector.velocity_burst_seconds == 60
    assert detector.max_gps_jump_km == 25.0
    assert detector.weight_tolerance_percent == 5.0

    # 1. Test velocity burst (submission within 45s vs 60s threshold)
    prev_burst = {
        "collector_id": "COL-BURST-1",
        "category": "PCB",
        "weight_kg": 10.0,
        "elapsed_seconds": 45,
    }
    res_burst = detector.check_lot(
        category="PCB",
        weight_kg=10.0,
        final_price=4200.0,
        collector_id="COL-BURST-1",
        previous_lot=prev_burst,
    )
    assert res_burst["is_anomalous"] is True
    assert "VELOCITY_BURST" in res_burst["flags"]

    # 2. Test GPS jump exceeding custom 25km limit (Mumbai CST to Thane is ~32 km)
    prev_gps = {
        "collector_id": "COL-GPS-1",
        "category": "PCB",
        "weight_kg": 10.0,
        "elapsed_seconds": 600,
        "latitude": 18.9400,
        "longitude": 72.8350,
    }
    res_gps = detector.check_lot(
        category="PCB",
        weight_kg=10.0,
        final_price=4200.0,
        collector_id="COL-GPS-1",
        latitude=19.2183,
        longitude=72.9781,
        previous_lot=prev_gps,
    )
    assert res_gps["is_anomalous"] is True
    assert "GPS_JUMP_SUSPICIOUS" in res_gps["flags"]

    # 3. Test weight tolerance exceeded (collector claims 10kg, expected is 9.0kg -> 11.1% > 5%)
    prev_weight = {
        "expected_weight_kg": 9.0,
    }
    res_w = detector.check_lot(
        category="PCB",
        weight_kg=10.0,
        final_price=4200.0,
        previous_lot=prev_weight,
    )
    assert res_w["is_anomalous"] is True
    assert "WEIGHT_TOLERANCE_EXCEEDED" in res_w["flags"]
