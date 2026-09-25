"""Data Validation Engine with domain rules and quarantine routing."""

import json
import uuid
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any

from app.data_pipeline.schemas import (
    CATEGORY_WEIGHT_SANITY,
    QuarantinedRecord,
    RawPriceObservation,
)

# Geographic boundaries of India (inclusive buffer)
INDIA_GEO_BOUNDS = {
    "min_lat": 8.0,
    "max_lat": 37.5,
    "min_lng": 68.0,
    "max_lng": 97.5,
}

# Maharashtra focused bounding box
MAHARASHTRA_GEO_BOUNDS = {
    "min_lat": 15.5,
    "max_lat": 22.5,
    "min_lng": 72.5,
    "max_lng": 81.0,
}


class DataValidator:
    """Validates candidate e-waste price records against domain, geographic,
    and statistical plausibility rules. Routes failures to quarantine.
    """

    def __init__(self, quarantine_dir: Path | None = None) -> None:
        self.quarantine_dir = (
            quarantine_dir
            or Path(__file__).resolve().parent.parent.parent.parent / "data" / "quarantine"
        )
        self.quarantine_dir.mkdir(parents=True, exist_ok=True)

    def validate_single(
        self,
        obs: RawPriceObservation,
        seen_signatures: set[str] | None = None,
        now_dt: datetime | None = None,
    ) -> list[str]:
        """Runs validation rules against an observation and returns failure reasons."""
        errors: list[str] = []
        now = now_dt or datetime.now(UTC)

        # 1. Price positivity rule
        if obs.price <= 0:
            errors.append(f"Price must be strictly positive (> 0), got: {obs.price}")

        # 2. Unit validity
        if obs.unit not in ("kg", "piece"):
            errors.append(f"Invalid unit '{obs.unit}', must be 'kg' or 'piece'")

        # 3. Market bounds check (if market bounds provided)
        if obs.market_min is not None and obs.market_max is not None:
            if obs.market_min > obs.market_max:
                errors.append(
                    f"Inconsistent market bounds: min ({obs.market_min}) > max ({obs.market_max})"
                )
            # Flag if price diverges drastically outside 0.5x min or 2.0x max
            if obs.price < obs.market_min * 0.4:
                errors.append(
                    f"Price ({obs.price}) is severely below market floor ({obs.market_min})"
                )
            elif obs.price > obs.market_max * 2.5:
                errors.append(
                    f"Price ({obs.price}) is severely above market ceiling ({obs.market_max})"
                )

        # 4. Geographic sanity (India & Maharashtra checks)
        min_lat, max_lat = INDIA_GEO_BOUNDS["min_lat"], INDIA_GEO_BOUNDS["max_lat"]
        if not (min_lat <= obs.latitude <= max_lat):
            errors.append(
                f"Latitude {obs.latitude} is outside India boundaries ({min_lat} to {max_lat})"
            )
        min_lng, max_lng = INDIA_GEO_BOUNDS["min_lng"], INDIA_GEO_BOUNDS["max_lng"]
        if not (min_lng <= obs.longitude <= max_lng):
            errors.append(
                f"Longitude {obs.longitude} is outside India boundaries ({min_lng} to {max_lng})"
            )

        # 5. Weight sanity per category (if weight provided)
        if obs.weight_kg is not None:
            if obs.weight_kg <= 0:
                errors.append(f"Weight must be positive, got: {obs.weight_kg}")
            sanity_rule = CATEGORY_WEIGHT_SANITY.get(obs.category)
            if sanity_rule:
                if obs.unit == "piece":
                    p_min, p_max = sanity_rule.min_kg * 0.2, sanity_rule.max_kg * 1.5
                    if not (p_min <= obs.weight_kg <= p_max):
                        errors.append(
                            f"Piece weight {obs.weight_kg}kg violates {obs.category} sanity range"
                        )
                else:
                    if obs.weight_kg > 1000.0:  # Single lot weight upper bound for kabadiwala
                        errors.append(
                            f"Excessive lot weight {obs.weight_kg}kg exceeds 1000kg limit"
                        )

        # 6. Future timestamp check (with 5-minute clock drift tolerance)
        max_allowed_time = now + timedelta(minutes=5)
        # Ensure timezone-aware comparison
        obs_time = (
            obs.recorded_at if obs.recorded_at.tzinfo else obs.recorded_at.replace(tzinfo=UTC)
        )
        if obs_time > max_allowed_time:
            errors.append(f"Timestamp {obs.recorded_at} is in the future (server time: {now})")

        # 7. Duplicate detection
        if seen_signatures is not None:
            t_win = obs.recorded_at.strftime("%Y%m%d%H%M")
            sig = (
                f"{obs.district}|{obs.category}|{obs.sub_category}|"
                f"{round(obs.price, 2)}|{obs.unit}|{t_win}"
            )
            if sig in seen_signatures:
                errors.append(f"Duplicate observation detected for signature: {sig}")
            else:
                seen_signatures.add(sig)

        return errors

    def validate_batch(
        self,
        records: list[RawPriceObservation],
        persist_quarantine: bool = True,
    ) -> tuple[list[RawPriceObservation], list[QuarantinedRecord]]:
        """Validates a batch of observations, separating valid from quarantined records."""
        valid_records: list[RawPriceObservation] = []
        quarantined: list[QuarantinedRecord] = []
        seen_signatures: set[str] = set()
        now = datetime.now(UTC)

        for obs in records:
            errors = self.validate_single(obs, seen_signatures=seen_signatures, now_dt=now)
            if not errors:
                valid_records.append(obs)
            else:
                q_rec = QuarantinedRecord(
                    quarantine_id=f"Q-VAL-{uuid.uuid4().hex[:8].upper()}",
                    original_id=obs.observation_id,
                    rejection_stage="validation",
                    rejection_reasons=errors,
                    raw_payload=obs.model_dump(mode="json"),
                    rejected_at=now,
                )
                quarantined.append(q_rec)

        if persist_quarantine and quarantined:
            self._save_quarantined(quarantined)

        return valid_records, quarantined

    def _save_quarantined(self, quarantined_records: list[QuarantinedRecord]) -> None:
        """Appends quarantined records to a date-partitioned JSON file."""
        today_str = datetime.now(UTC).strftime("%Y%m%d")
        filepath = self.quarantine_dir / f"quarantine_{today_str}.json"

        existing: list[dict[str, Any]] = []
        if filepath.exists():
            try:
                with open(filepath, encoding="utf-8") as f:
                    existing = json.load(f)
            except Exception:
                existing = []

        existing.extend([q.model_dump(mode="json") for q in quarantined_records])
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(existing, f, indent=2, ensure_ascii=False)
