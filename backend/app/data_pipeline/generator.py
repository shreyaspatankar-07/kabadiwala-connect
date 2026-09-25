"""Synthetic seed generator and real database data ingestion engine.

Generates realistic e-waste price benchmarks across Maharashtra districts with
seasonal noise, macroeconomic commodity trends, and injected outliers for pipeline
testing and validation. Also ingests live app transactions and field submissions.
"""

import math
import random
import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

from geoalchemy2.shape import to_shape
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.data_pipeline.schemas import (
    CATEGORY_WEIGHT_SANITY,
    ProvenanceSource,
    RawPriceObservation,
)
from app.models.schema import Price, Transaction, TransactionStatus

# Maharashtra target districts with representative center coordinates
MAHARASHTRA_DISTRICTS: dict[str, dict[str, Any]] = {
    "Mumbai": {
        "city": "Mumbai",
        "lat": 19.0760,
        "lng": 72.8777,
        "price_modifier": 1.08,  # Port access, high aggregator density
    },
    "Thane": {
        "city": "Thane",
        "lat": 19.2183,
        "lng": 72.9781,
        "price_modifier": 1.05,
    },
    "Palghar": {
        "city": "Palghar",
        "lat": 19.6967,
        "lng": 72.7699,
        "price_modifier": 0.95,  # Higher logistics haul cost
    },
    "Pune": {
        "city": "Pune",
        "lat": 18.5204,
        "lng": 73.8567,
        "price_modifier": 1.04,  # IT hub, steady component supply
    },
    "Nashik": {
        "city": "Nashik",
        "lat": 19.9975,
        "lng": 73.7898,
        "price_modifier": 0.98,
    },
    "Nagpur": {
        "city": "Nagpur",
        "lat": 21.1458,
        "lng": 79.0882,
        "price_modifier": 1.00,  # Central India transit hub
    },
}

# Categories required by the PS specification
CATEGORY_SPECS: dict[str, dict[str, Any]] = {
    "CRT": {
        "sub_categories": ["CRT Monitor", "CRT Television Glass Casing"],
        "base_price_kg": 12.0,
        "std_kg": 2.5,
        "market_min_kg": 8.0,
        "market_max_kg": 18.0,
        "piece_probability": 0.35,  # 35% quoted per whole unit
        "piece_price_multiplier": 14.0,  # Avg 14 kg per unit
    },
    "LCD panel": {
        "sub_categories": ["Laptop Display Panel", "LCD TV Screen Assembly"],
        "base_price_kg": 42.0,
        "std_kg": 6.0,
        "market_min_kg": 25.0,
        "market_max_kg": 65.0,
        "piece_probability": 0.25,
        "piece_price_multiplier": 3.5,
    },
    "PCB (low grade)": {
        "sub_categories": ["Power Supply PCB", "Single-Layer Phenolic Board"],
        "base_price_kg": 48.0,
        "std_kg": 7.0,
        "market_min_kg": 30.0,
        "market_max_kg": 75.0,
        "piece_probability": 0.05,
        "piece_price_multiplier": 0.4,
    },
    "PCB (mid grade)": {
        "sub_categories": ["Desktop Motherboard (Green)", "Audio/Video Multi-Layer"],
        "base_price_kg": 185.0,
        "std_kg": 22.0,
        "market_min_kg": 120.0,
        "market_max_kg": 260.0,
        "piece_probability": 0.10,
        "piece_price_multiplier": 0.5,
    },
    "PCB (high grade)": {
        "sub_categories": ["Server Motherboard (Gold Pin)", "Telecom Switching PCB"],
        "base_price_kg": 750.0,
        "std_kg": 85.0,
        "market_min_kg": 450.0,
        "market_max_kg": 1150.0,
        "piece_probability": 0.05,
        "piece_price_multiplier": 0.3,
    },
    "cables (copper)": {
        "sub_categories": ["Heavy Insulated Industrial Cable", "Domestic Appliance Wiring"],
        "base_price_kg": 460.0,
        "std_kg": 45.0,
        "market_min_kg": 340.0,
        "market_max_kg": 620.0,
        "piece_probability": 0.0,
        "piece_price_multiplier": 1.0,
    },
    "batteries (Li-ion)": {
        "sub_categories": ["Smartphone Pouch Cell", "Laptop 18650 Battery Pack"],
        "base_price_kg": 125.0,
        "std_kg": 18.0,
        "market_min_kg": 75.0,
        "market_max_kg": 190.0,
        "piece_probability": 0.20,
        "piece_price_multiplier": 0.2,
    },
    "batteries (lead-acid)": {
        "sub_categories": ["Two-Wheeler Dry Battery", "UPS/Inverter Heavy Battery"],
        "base_price_kg": 88.0,
        "std_kg": 8.0,
        "market_min_kg": 68.0,
        "market_max_kg": 115.0,
        "piece_probability": 0.15,
        "piece_price_multiplier": 12.0,
    },
    "motors/magnet assemblies": {
        "sub_categories": ["Mixer/Fan Copper Wound Motor", "Hard Disk Neodymium Assembly"],
        "base_price_kg": 95.0,
        "std_kg": 12.0,
        "market_min_kg": 55.0,
        "market_max_kg": 145.0,
        "piece_probability": 0.10,
        "piece_price_multiplier": 2.5,
    },
    "mixed plastics": {
        "sub_categories": ["Hard ABS Monitor Enclosure", "Shredded Computer Polymers"],
        "base_price_kg": 20.0,
        "std_kg": 3.5,
        "market_min_kg": 12.0,
        "market_max_kg": 32.0,
        "piece_probability": 0.0,
        "piece_price_multiplier": 1.0,
    },
}


def _calculate_seasonal_factor(dt: datetime) -> float:
    """Calculate seasonal price factor:
    - Monsoon (June-August): collection dip, transport dampening (~ -10%)
    - Post-Diwali / Q4 (October-November): commercial asset turnover, price peak (+8% to +12%)
    - March financial year-end disposal (+5%)
    """
    day_of_year = dt.timetuple().tm_yday
    # Annual wave peaking around day 305 (early Nov)
    annual_wave = 0.08 * math.sin(2 * math.pi * (day_of_year - 200) / 365)

    # Specific monsoon penalty (approx days 165 to 240)
    monsoon_penalty = 0.0
    if 165 <= day_of_year <= 240:
        monsoon_penalty = -0.06

    return 1.0 + annual_wave + monsoon_penalty


class DatasetGenerator:
    """Produces synthetic price history and ingests real transactional data."""

    @staticmethod
    def generate_synthetic_stream(
        count: int = 500,
        days_history: int = 60,
        seed: int = 42,
        inject_outliers: bool = True,
    ) -> list[RawPriceObservation]:
        """Generate time-series price stream across all required categories and districts."""
        rng = random.Random(seed)
        records: list[RawPriceObservation] = []
        now = datetime.now(UTC)

        categories = list(CATEGORY_SPECS.keys())
        districts = list(MAHARASHTRA_DISTRICTS.keys())

        for _idx in range(count):
            obs_id = f"SYNTH-OBS-{uuid.uuid4().hex[:8].upper()}"
            category = rng.choice(categories)
            spec = CATEGORY_SPECS[category]
            sub_category = rng.choice(spec["sub_categories"])
            district = rng.choice(districts)
            dist_info = MAHARASHTRA_DISTRICTS[district]

            # Timestamps distributed over history
            delta_seconds = rng.uniform(0, days_history * 86400)
            recorded_at = now - timedelta(seconds=delta_seconds)

            # Location with local jitter (~2-5 km around district center)
            lat_jitter = rng.gauss(0, 0.02)
            lng_jitter = rng.gauss(0, 0.02)
            lat = round(dist_info["lat"] + lat_jitter, 6)
            lng = round(dist_info["lng"] + lng_jitter, 6)

            # Seasonal & macroeconomic trend factors
            seasonal_factor = _calculate_seasonal_factor(recorded_at)
            # Upward 2% annual commodity trend
            time_fraction = (days_history * 86400 - delta_seconds) / (365 * 86400)
            trend_factor = 1.0 + 0.02 * time_fraction

            base_kg = spec["base_price_kg"]
            district_mod = dist_info["price_modifier"]
            noise = rng.gauss(0, spec["std_kg"] * 0.4)

            calc_price_kg = max(
                (base_kg * district_mod * seasonal_factor * trend_factor) + noise,
                spec["market_min_kg"] * 0.85,
            )

            # Determine unit (kg or piece)
            is_piece = rng.random() < spec["piece_probability"]
            if is_piece:
                unit = "piece"
                unit_weight = rng.uniform(
                    CATEGORY_WEIGHT_SANITY[category].default_kg_per_piece * 0.8,
                    CATEGORY_WEIGHT_SANITY[category].default_kg_per_piece * 1.2,
                )
                price = round(calc_price_kg * unit_weight, 2)
                weight_kg = round(unit_weight, 2)
                m_min = round(spec["market_min_kg"] * unit_weight, 2)
                m_max = round(spec["market_max_kg"] * unit_weight, 2)
            else:
                unit = "kg"
                price = round(calc_price_kg, 2)
                weight_kg = round(rng.uniform(1.0, 35.0), 2)
                m_min = spec["market_min_kg"]
                m_max = spec["market_max_kg"]

            # Provenance & optional associations
            collector_id = f"KC-C-{rng.randint(100, 999)}" if rng.random() > 0.4 else None
            recycler_id = f"REC-MH-0{rng.randint(1, 9)}" if rng.random() > 0.5 else None

            # Outlier / dirty data injection (~2.5% rate) for validation and cleaning pipelines
            is_injected_outlier = False
            outlier_type = None

            if inject_outliers and rng.random() < 0.025:
                is_injected_outlier = True
                anomaly_choice = rng.choice(
                    ["extreme_high", "negative_zero", "geo_outside", "future_dt", "weight_insane"]
                )
                if anomaly_choice == "extreme_high":
                    price = round(price * rng.uniform(5.0, 15.0), 2)  # Typo extra zeros
                    outlier_type = "extreme_price_spike"
                elif anomaly_choice == "negative_zero":
                    price = rng.choice([0.0, -25.0])
                    outlier_type = "invalid_price_zero_or_negative"
                elif anomaly_choice == "geo_outside":
                    lat = 51.5074  # London
                    lng = -0.1278
                    outlier_type = "geo_outside_india"
                elif anomaly_choice == "future_dt":
                    recorded_at = now + timedelta(days=rng.randint(3, 30))
                    outlier_type = "future_timestamp"
                elif anomaly_choice == "weight_insane":
                    weight_kg = 5000.0  # Absurd 5-ton PCB
                    outlier_type = "weight_sanity_exceeded"

            record = RawPriceObservation(
                observation_id=obs_id,
                category=category,
                sub_category=sub_category,
                district=district,
                city=dist_info["city"],
                latitude=lat,
                longitude=lng,
                price=price,
                unit=unit,
                weight_kg=weight_kg,
                market_min=m_min,
                market_max=m_max,
                recycler_id=recycler_id,
                collector_id=collector_id,
                source=ProvenanceSource.SYNTHETIC,
                recorded_at=recorded_at,
                metadata={
                    "provenance": "synthetic",
                    "generator_version": "1.0.0",
                    "injected_outlier": is_injected_outlier,
                    "anomaly_type": outlier_type,
                },
            )
            records.append(record)

        # Sort chronologically
        records.sort(key=lambda r: r.recorded_at)
        return records

    @staticmethod
    async def ingest_from_database(db: AsyncSession) -> list[RawPriceObservation]:
        """Ingest live submissions from the `prices` and `transactions` tables."""
        observations: list[RawPriceObservation] = []

        # 1. Ingest price submissions
        res_prices = await db.execute(select(Price))
        db_prices = res_prices.scalars().all()
        for p in db_prices:
            try:
                pt = to_shape(p.location)
                lat, lng = pt.y, pt.x
            except Exception:
                lat, lng = 19.0760, 72.8777

            observations.append(
                RawPriceObservation(
                    observation_id=str(p.id),
                    category=p.category,
                    sub_category=p.sub_category,
                    district=p.district,
                    city=p.city,
                    latitude=lat,
                    longitude=lng,
                    price=float(p.buying_price),
                    unit=p.unit.value,
                    weight_kg=None,
                    market_min=float(p.market_min) if p.market_min else None,
                    market_max=float(p.market_max) if p.market_max else None,
                    recycler_id=p.recycler_id,
                    source=(
                        ProvenanceSource.RECYCLER_QUOTE
                        if p.source.value == "recycler_quote"
                        else ProvenanceSource.FIELD_SURVEY
                    ),
                    recorded_at=p.recorded_at,
                    metadata={"source_table": "prices"},
                )
            )

        # 2. Ingest completed lots / transactions
        res_tx = await db.execute(
            select(Transaction).where(
                Transaction.transaction_status.in_(
                    [TransactionStatus.CONFIRMED, TransactionStatus.HANDED_OVER]
                )
            )
        )
        db_txs = res_tx.scalars().all()
        for t in db_txs:
            try:
                pt = to_shape(t.collection_location)
                lat, lng = pt.y, pt.x
            except Exception:
                lat, lng = 19.0760, 72.8777

            effective_price = (
                float(t.final_price) if t.final_price is not None else float(t.quoted_price)
            )
            weight = float(t.weight_kg)
            price_per_kg = round(effective_price / max(weight, 0.01), 2)

            observations.append(
                RawPriceObservation(
                    observation_id=f"TX-{t.lot_id}",
                    category=t.category,
                    sub_category=t.category,
                    district="Mumbai",  # Default or resolved from lat/lng
                    city="Mumbai",
                    latitude=lat,
                    longitude=lng,
                    price=price_per_kg,
                    unit="kg",
                    weight_kg=weight,
                    market_min=None,
                    market_max=None,
                    recycler_id=t.recycler_id,
                    collector_id=t.collector_id,
                    source=ProvenanceSource.TRANSACTION,
                    recorded_at=t.handover_at or t.created_at,
                    metadata={
                        "source_table": "transactions",
                        "lot_id": t.lot_id,
                        "final_amount": effective_price,
                    },
                )
            )

        return observations
