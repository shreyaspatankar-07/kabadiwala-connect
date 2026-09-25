"""Unit and integration tests for the dataset lifecycle pipeline.

Tests:
1. Generation (Synthetic generator & DB ingestion)
2. Validation (Pydantic, domain rules, quarantine routing)
3. Cleaning (IQR + MAD robust Z-score, unit normalization, deduplication)
4. Anonymization (Salted HMAC collector hashing, ~500m GPS coarsening)
5. Rolling Board & Data Quality Scoring
6. Dataset Card generation
"""

import tempfile
from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest
from geoalchemy2.elements import WKTElement
from sqlalchemy.ext.asyncio import AsyncSession

from app.data_pipeline.anonymizer import DataAnonymizer
from app.data_pipeline.cleaner import DataCleaner
from app.data_pipeline.dataset_card import DatasetCardGenerator
from app.data_pipeline.generator import DatasetGenerator
from app.data_pipeline.schemas import (
    CleanedPriceObservation,
    DatasetQualityMetrics,
    ProvenanceSource,
    RawPriceObservation,
    RollingBoardRate,
)
from app.data_pipeline.updater import RollingBoardUpdater
from app.data_pipeline.validator import DataValidator
from app.models.schema import (
    Collector,
    PaymentStatus,
    PreferredLanguage,
    Price,
    PriceSource,
    PriceUnit,
    Transaction,
    TransactionStatus,
)

# ============================================================================
# 1. Generator Tests
# ============================================================================


def test_synthetic_stream_generation():
    count = 100
    records = DatasetGenerator.generate_synthetic_stream(
        count=count, days_history=30, seed=123, inject_outliers=True
    )
    assert len(records) == count

    categories = {r.category for r in records}
    districts = {r.district for r in records}

    # All required categories and districts should appear
    assert "CRT" in categories
    assert "PCB (high grade)" in categories
    assert "cables (copper)" in categories
    assert "batteries (lead-acid)" in categories
    assert "Mumbai" in districts
    assert "Pune" in districts
    assert "Nagpur" in districts

    # Check timestamps are chronologically bounded
    now = datetime.now(UTC)
    for r in records:
        assert r.source == ProvenanceSource.SYNTHETIC
        assert r.recorded_at <= now + timedelta(days=31)


@pytest.mark.asyncio
async def test_database_ingestion(db_session: AsyncSession):
    # Insert a sample price quote
    pt = WKTElement("POINT(72.8777 19.0760)", srid=4326)
    p = Price(
        category="PCB (high grade)",
        sub_category="Server Motherboard",
        district="Mumbai",
        city="Mumbai",
        location=pt,
        buying_price=800.0,
        selling_quoted_price=850.0,
        unit=PriceUnit.KG,
        market_min=700.0,
        market_max=950.0,
        source=PriceSource.FIELD_SURVEY,
    )
    db_session.add(p)

    # Insert a completed transaction
    col = Collector(
        collector_id="KC-C-INGEST01",
        phone="+919876543200",
        preferred_language=PreferredLanguage.MR,
        operating_area="Mumbai",
    )
    db_session.add(col)
    await db_session.flush()

    tx = Transaction(
        lot_id="KC-MH-2609-INGEST01",
        collector_id="KC-C-INGEST01",
        category="cables (copper)",
        weight_kg=10.0,
        quoted_price=4500.0,
        final_price=4400.0,
        collection_location=pt,
        transaction_status=TransactionStatus.CONFIRMED,
        payment_status=PaymentStatus.CASH_RECEIVED,
    )
    db_session.add(tx)
    await db_session.commit()

    ingested = await DatasetGenerator.ingest_from_database(db_session)
    assert len(ingested) >= 2
    obs_ids = [obs.observation_id for obs in ingested]
    assert any("INGEST01" in oid for oid in obs_ids)


# ============================================================================
# 2. Validator Tests
# ============================================================================


def test_validator_rules_and_quarantine():
    with tempfile.TemporaryDirectory() as tmpdir:
        validator = DataValidator(quarantine_dir=Path(tmpdir))
        now = datetime.now(UTC)

        valid_obs = RawPriceObservation(
            observation_id="VALID-001",
            category="CRT",
            sub_category="CRT Monitor",
            district="Pune",
            city="Pune",
            latitude=18.5204,
            longitude=73.8567,
            price=12.0,
            unit="kg",
            weight_kg=15.0,
            market_min=8.0,
            market_max=18.0,
            recorded_at=now,
        )

        invalid_negative_price = valid_obs.model_copy(
            update={"observation_id": "INV-001", "price": -10.0}
        )
        invalid_geo = valid_obs.model_copy(
            update={"observation_id": "INV-002", "latitude": 51.5074, "longitude": -0.1278}
        )
        invalid_future = valid_obs.model_copy(
            update={"observation_id": "INV-003", "recorded_at": now + timedelta(days=5)}
        )
        invalid_weight = valid_obs.model_copy(
            update={"observation_id": "INV-004", "weight_kg": 5000.0}
        )

        batch = [
            valid_obs,
            invalid_negative_price,
            invalid_geo,
            invalid_future,
            invalid_weight,
        ]

        passed, quarantined = validator.validate_batch(batch, persist_quarantine=True)
        assert len(passed) == 1
        assert passed[0].observation_id == "VALID-001"
        assert len(quarantined) == 4

        reasons = [q.rejection_reasons[0] for q in quarantined]
        assert any("strictly positive" in r for r in reasons)
        assert any("outside India" in r for r in reasons)
        assert any("future" in r for r in reasons)
        assert any("exceeds 1000kg limit" in r for r in reasons)


# ============================================================================
# 3. Cleaner Tests
# ============================================================================


def test_cleaner_unit_normalization_and_outliers():
    with tempfile.TemporaryDirectory() as tmpdir:
        cleaner = DataCleaner(quarantine_dir=Path(tmpdir))
        now = datetime.now(UTC)

        # Baseline records for CRT (~12 INR/kg)
        records = [
            RawPriceObservation(
                observation_id=f"CRT-NORM-{i}",
                category="CRT",
                sub_category="CRT Monitor",
                district="Mumbai",
                city="Mumbai",
                latitude=19.0760,
                longitude=72.8777,
                price=11.0 + (i % 3),
                unit="kg",
                weight_kg=12.0,
                recorded_at=now - timedelta(days=i),
            )
            for i in range(15)
        ]

        # Add a piece-quoted observation (e.g. Rs 140 for a 14kg CRT -> 10 INR/kg)
        piece_obs = RawPriceObservation(
            observation_id="CRT-PIECE-01",
            category="CRT",
            sub_category="CRT Monitor",
            district="Mumbai",
            city="Mumbai",
            latitude=19.0760,
            longitude=72.8777,
            price=140.0,
            unit="piece",
            weight_kg=14.0,
            recorded_at=now,
        )
        records.append(piece_obs)

        # Add an extreme outlier (Rs 500/kg for CRT)
        extreme_obs = RawPriceObservation(
            observation_id="CRT-OUTLIER-01",
            category="CRT",
            sub_category="CRT Monitor",
            district="Mumbai",
            city="Mumbai",
            latitude=19.0760,
            longitude=72.8777,
            price=500.0,
            unit="kg",
            weight_kg=12.0,
            recorded_at=now,
        )
        records.append(extreme_obs)

        cleaned, quarantined = cleaner.clean_batch(records)

        # Extreme outlier should be quarantined
        assert any(q.original_id == "CRT-OUTLIER-01" for q in quarantined)

        # Piece should be normalized to ~10 INR/kg
        piece_cleaned = next(c for c in cleaned if c.observation_id == "CRT-PIECE-01")
        assert piece_cleaned.normalized_price_per_kg == 10.0
        assert piece_cleaned.original_unit == "piece"


# ============================================================================
# 4. Anonymizer Tests
# ============================================================================


def test_data_anonymizer():
    anonymizer = DataAnonymizer()
    now = datetime.now(UTC)

    cleaned = CleanedPriceObservation(
        observation_id="OBS-CLEAN-01",
        category="PCB (high grade)",
        sub_category="Server Motherboard",
        district="Pune",
        city="Pune",
        latitude=18.520412,
        longitude=73.856743,
        original_price=750.0,
        original_unit="kg",
        normalized_price_per_kg=750.0,
        market_min_per_kg=600.0,
        market_max_per_kg=900.0,
        weight_kg=5.0,
        recycler_id="REC-MH-01",
        collector_id="KC-C-SECRET99",
        source="field_survey",
        recorded_at=now,
    )

    anon = anonymizer.anonymize_single(cleaned)

    # Collector ID is hashed
    assert anon.anonymized_collector_id is not None
    assert anon.anonymized_collector_id.startswith("ANON-C-")
    assert "SECRET99" not in anon.anonymized_collector_id

    # Coordinates are coarsened to ~500m
    assert anon.coarsened_latitude != cleaned.latitude
    # Verify grid snap step
    assert round(anon.coarsened_latitude % 0.005, 5) in (0.0, 0.005)


# ============================================================================
# 5. Rolling Board & Data Quality Metrics Tests
# ============================================================================


def test_rolling_board_and_quality_metrics():
    now = datetime.now(UTC)
    records = []

    # 7-day recent prices (averaging 500)
    for i in range(5):
        records.append(
            CleanedPriceObservation(
                observation_id=f"ROLL-7D-{i}",
                category="cables (copper)",
                sub_category="Heavy Insulated",
                district="Thane",
                city="Thane",
                latitude=19.2183,
                longitude=72.9781,
                original_price=500.0 + i * 2,
                original_unit="kg",
                normalized_price_per_kg=500.0 + i * 2,
                market_min_per_kg=400.0,
                market_max_per_kg=600.0,
                weight_kg=10.0,
                source="recycler_quote",
                recorded_at=now - timedelta(days=i),
            )
        )

    # Prior 7-day prices (averaging 470, indicating upward trend)
    for i in range(5):
        records.append(
            CleanedPriceObservation(
                observation_id=f"ROLL-PRIOR-{i}",
                category="cables (copper)",
                sub_category="Heavy Insulated",
                district="Thane",
                city="Thane",
                latitude=19.2183,
                longitude=72.9781,
                original_price=470.0,
                original_unit="kg",
                normalized_price_per_kg=470.0,
                market_min_per_kg=400.0,
                market_max_per_kg=600.0,
                weight_kg=10.0,
                source="recycler_quote",
                recorded_at=now - timedelta(days=8 + i),
            )
        )

    rates = RollingBoardUpdater.compute_rolling_board(records, now_dt=now)
    assert len(rates) == 1
    board = rates[0]
    assert board.category == "cables (copper)"
    assert board.district == "Thane"
    assert board.median_7d_per_kg >= 500.0
    assert board.trend == "up"  # Upward price movement
    assert board.pct_change_7d > 2.0

    metrics = RollingBoardUpdater.evaluate_quality_metrics(
        total_raw=12,
        quarantined_val=1,
        quarantined_clean=1,
        cleaned_records=records,
        now_dt=now,
    )
    assert metrics.overall_quality_score > 70.0
    assert metrics.validity_rate_pct > 80.0
    assert metrics.freshness_score == 100.0


# ============================================================================
# 6. Dataset Card Generator Tests
# ============================================================================


def test_dataset_card_generator():
    now = datetime.now(UTC)
    records = [
        CleanedPriceObservation(
            observation_id="CARD-OBS-01",
            category="CRT",
            sub_category="CRT Monitor",
            district="Mumbai",
            city="Mumbai",
            latitude=19.0760,
            longitude=72.8777,
            original_price=12.5,
            original_unit="kg",
            normalized_price_per_kg=12.5,
            market_min_per_kg=8.0,
            market_max_per_kg=18.0,
            weight_kg=15.0,
            source="synthetic",
            recorded_at=now,
        )
    ]
    board = [
        RollingBoardRate(
            category="CRT",
            sub_category="CRT Monitor",
            district="Mumbai",
            median_7d_per_kg=12.5,
            median_30d_per_kg=12.5,
            mean_7d_per_kg=12.5,
            trend="flat",
            pct_change_7d=0.0,
            sample_size_7d=1,
            sample_size_30d=1,
            quality_score=85.0,
            last_updated=now,
        )
    ]
    metrics = DatasetQualityMetrics(
        total_raw_ingested=1,
        valid_count=1,
        quarantined_validation_count=0,
        quarantined_outlier_count=0,
        clean_count=1,
        completeness_score=100.0,
        freshness_score=100.0,
        validity_rate_pct=100.0,
        overall_quality_score=95.0,
        evaluation_time=now,
    )

    with tempfile.TemporaryDirectory() as tmpdir:
        out_card = Path(tmpdir) / "DATASET_CARD.md"
        generated_path = DatasetCardGenerator.generate_card(
            records, board, metrics, output_path=out_card
        )
        assert Path(generated_path).exists()
        content = out_card.read_text(encoding="utf-8")
        assert "Kabadiwala Connect E-Waste Pricing Benchmark" in content
        assert "CRT" in content
        assert "Mumbai" in content
        assert "Overall Data Quality Score" in content
