"""Data Cleaning, Outlier Detection (IQR + Robust Z-Score), and Unit Normalization Engine."""

import uuid
from datetime import UTC, datetime
from pathlib import Path

import numpy as np

from app.data_pipeline.schemas import (
    CATEGORY_WEIGHT_SANITY,
    CleanedPriceObservation,
    QuarantinedRecord,
    RawPriceObservation,
)


class DataCleaner:
    """Cleans valid raw observations:
    - Normalizes units to standardized per-kg INR rates
    - Detects and quarantines statistical outliers using IQR and Median Absolute Deviation (MAD)
    - Applies missing-value imputation policies
    - Deduplicates identical records
    """

    def __init__(self, quarantine_dir: Path | None = None) -> None:
        self.quarantine_dir = (
            quarantine_dir
            or Path(__file__).resolve().parent.parent.parent.parent / "data" / "quarantine"
        )
        self.quarantine_dir.mkdir(parents=True, exist_ok=True)

    @staticmethod
    def normalize_unit(obs: RawPriceObservation) -> tuple[float, float]:
        """Converts observation price to normalized INR per kg and resolves effective weight.
        Returns: (normalized_price_per_kg, effective_weight_kg)
        """
        sanity = CATEGORY_WEIGHT_SANITY.get(obs.category)
        default_piece_weight = sanity.default_kg_per_piece if sanity else 1.0

        if obs.unit == "piece":
            effective_weight = (
                obs.weight_kg if (obs.weight_kg and obs.weight_kg > 0) else default_piece_weight
            )
            price_per_kg = round(obs.price / max(effective_weight, 0.001), 2)
            return price_per_kg, effective_weight
        else:
            effective_weight = obs.weight_kg if (obs.weight_kg and obs.weight_kg > 0) else 1.0
            return round(obs.price, 2), effective_weight

    @staticmethod
    def calculate_outlier_bounds(prices: list[float]) -> dict[str, float]:
        """Computes statistical thresholds using both IQR and Robust Z-score (MAD)."""
        if len(prices) < 4:
            arr = np.array(prices)
            med = float(np.median(arr)) if len(arr) > 0 else 0.0
            return {
                "iqr_lower": max(med * 0.4, 0.0),
                "iqr_upper": med * 2.5,
                "median": med,
                "mad": 1.0,
            }

        arr = np.array(prices, dtype=np.float64)
        q25, q75 = np.percentile(arr, [25, 75])
        iqr = q75 - q25
        iqr_lower = max(float(q25 - 1.5 * iqr), 0.0)
        iqr_upper = float(q75 + 1.5 * iqr)

        med = float(np.median(arr))
        mad = float(np.median(np.abs(arr - med)))
        if mad == 0.0:
            mad = 1.0  # Avoid zero division in identical clusters

        return {
            "iqr_lower": iqr_lower,
            "iqr_upper": iqr_upper,
            "median": med,
            "mad": mad,
        }

    def clean_batch(
        self,
        records: list[RawPriceObservation],
    ) -> tuple[list[CleanedPriceObservation], list[QuarantinedRecord]]:
        """Processes a list of raw observations through normalization, outlier filtering,
        imputation, and deduplication.
        """
        cleaned_records: list[CleanedPriceObservation] = []
        quarantined: list[QuarantinedRecord] = []
        now = datetime.now(UTC)

        # 1. Deduplication pass
        seen_keys: set[str] = set()
        deduped_raw: list[RawPriceObservation] = []
        for r in records:
            dedup_key = (
                f"{r.district}|{r.category}|{r.sub_category}|"
                f"{round(r.price, 2)}|{r.unit}|{r.recorded_at.isoformat()}"
            )
            if dedup_key in seen_keys:
                continue
            seen_keys.add(dedup_key)
            deduped_raw.append(r)

        # 2. Partition by category for robust statistical baseline calculation
        partitions: dict[str, list[tuple[RawPriceObservation, float, float]]] = {}
        for r in deduped_raw:
            norm_price, eff_weight = self.normalize_unit(r)
            partitions.setdefault(r.category, []).append((r, norm_price, eff_weight))

        # 3. Outlier evaluation per partition
        for _category, items in partitions.items():
            norm_prices = [norm_p for _, norm_p, _ in items]
            bounds = self.calculate_outlier_bounds(norm_prices)

            for obs, norm_price, eff_weight in items:
                # Robust Z-score formula: 0.6745 * |x - median| / MAD
                mad = bounds["mad"]
                median = bounds["median"]
                robust_z = 0.6745 * abs(norm_price - median) / mad

                is_iqr_outlier = (
                    norm_price < bounds["iqr_lower"] or norm_price > bounds["iqr_upper"]
                )
                is_extreme_z = robust_z > 4.5

                if is_iqr_outlier and is_extreme_z:
                    # Unrecoverable extreme outlier -> Quarantine
                    reason = (
                        f"Extreme price outlier: {norm_price} INR/kg "
                        f"(Z={robust_z:.2f}, Range=[{bounds['iqr_lower']:.1f}, "
                        f"{bounds['iqr_upper']:.1f}], Median={median:.1f})"
                    )
                    quarantined.append(
                        QuarantinedRecord(
                            quarantine_id=f"Q-CLN-{uuid.uuid4().hex[:8].upper()}",
                            original_id=obs.observation_id,
                            rejection_stage="cleaning",
                            rejection_reasons=[reason],
                            raw_payload=obs.model_dump(mode="json"),
                            rejected_at=now,
                        )
                    )
                    continue

                # Missing value imputation policy
                city = obs.city or obs.district
                market_min_kg = obs.market_min or bounds["iqr_lower"]
                market_max_kg = obs.market_max or bounds["iqr_upper"]

                cleaned = CleanedPriceObservation(
                    observation_id=obs.observation_id,
                    category=obs.category,
                    sub_category=obs.sub_category,
                    district=obs.district,
                    city=city,
                    latitude=obs.latitude,
                    longitude=obs.longitude,
                    original_price=obs.price,
                    original_unit=obs.unit,
                    normalized_price_per_kg=norm_price,
                    market_min_per_kg=market_min_kg,
                    market_max_per_kg=market_max_kg,
                    weight_kg=eff_weight,
                    recycler_id=obs.recycler_id,
                    collector_id=obs.collector_id,
                    source=obs.source.value if hasattr(obs.source, "value") else str(obs.source),
                    recorded_at=obs.recorded_at,
                    is_outlier=is_iqr_outlier,  # Mild outlier retained for robust estimators
                    cleaned_at=now,
                )
                cleaned_records.append(cleaned)

        return cleaned_records, quarantined
