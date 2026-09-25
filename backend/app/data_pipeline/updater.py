"""Nightly Rolling Price Board Aggregator & Data Quality Metric Engine."""

import math
from datetime import UTC, datetime, timedelta

import numpy as np

from app.data_pipeline.schemas import (
    CleanedPriceObservation,
    DatasetQualityMetrics,
    RollingBoardRate,
)


class RollingBoardUpdater:
    """Computes:
    1. Rolling 7-day and 30-day median and mean price boards per category x district.
    2. Recency-weighted recycler quotes.
    3. Trend signals (up/down/flat with percentage change).
    4. Data quality scoring.
    """

    @staticmethod
    def _compute_recency_weighted_median(
        prices: list[float], dates: list[datetime], now: datetime, half_life_days: float = 7.0
    ) -> float:
        """Computes exponential recency-weighted average of prices."""
        if not prices:
            return 0.0
        weights: list[float] = []
        for d in dates:
            age_days = max((now - d).total_seconds() / 86400.0, 0.0)
            weight = math.exp(-math.log(2) * age_days / half_life_days)
            weights.append(weight)

        total_w = sum(weights)
        if total_w <= 0:
            return float(np.median(prices))

        weighted_sum = sum(p * w for p, w in zip(prices, weights, strict=False))
        return round(weighted_sum / total_w, 2)

    @classmethod
    def compute_rolling_board(
        cls,
        records: list[CleanedPriceObservation],
        now_dt: datetime | None = None,
    ) -> list[RollingBoardRate]:
        """Aggregates cleaned observations into district-level rolling boards
        with trend analysis.
        """
        now = now_dt or datetime.now(UTC)
        seven_days_ago = now - timedelta(days=7)
        fourteen_days_ago = now - timedelta(days=14)
        thirty_days_ago = now - timedelta(days=30)

        # Group by (category, sub_category, district)
        groups: dict[tuple[str, str, str], list[CleanedPriceObservation]] = {}
        for r in records:
            # Ensure timezone-aware
            r_dt = r.recorded_at if r.recorded_at.tzinfo else r.recorded_at.replace(tzinfo=UTC)
            if r_dt >= thirty_days_ago:
                key = (r.category, r.sub_category, r.district)
                groups.setdefault(key, []).append(r)

        results: list[RollingBoardRate] = []

        for (category, sub_category, district), group_records in groups.items():
            records_7d = [
                r
                for r in group_records
                if (r.recorded_at if r.recorded_at.tzinfo else r.recorded_at.replace(tzinfo=UTC))
                >= seven_days_ago
            ]
            records_prior_7d = [
                r
                for r in group_records
                if fourteen_days_ago
                <= (r.recorded_at if r.recorded_at.tzinfo else r.recorded_at.replace(tzinfo=UTC))
                < seven_days_ago
            ]
            records_30d = group_records

            prices_7d = [r.normalized_price_per_kg for r in records_7d]
            prices_prior = [r.normalized_price_per_kg for r in records_prior_7d]
            prices_30d = [r.normalized_price_per_kg for r in records_30d]

            if not prices_7d and not prices_30d:
                continue

            # 7-day stats
            if prices_7d:
                median_7d = float(np.median(prices_7d))
                dates_7d = [
                    (r.recorded_at if r.recorded_at.tzinfo else r.recorded_at.replace(tzinfo=UTC))
                    for r in records_7d
                ]
                mean_7d = cls._compute_recency_weighted_median(prices_7d, dates_7d, now)
            else:
                median_7d = float(np.median(prices_30d))
                mean_7d = median_7d

            # 30-day stats
            median_30d = float(np.median(prices_30d))

            # Trend calculation (comparing 7d vs prior 7d)
            if prices_prior and median_7d > 0:
                med_prior = float(np.median(prices_prior))
                pct_change = round(((median_7d - med_prior) / max(med_prior, 0.01)) * 100, 2)
            else:
                pct_change = 0.0

            if pct_change >= 2.0:
                trend = "up"
            elif pct_change <= -2.0:
                trend = "down"
            else:
                trend = "flat"

            # Quality score (0 to 100) based on sample depth and recency
            sample_score = (
                min(len(prices_7d) / 5.0, 1.0) * 50.0 + min(len(prices_30d) / 15.0, 1.0) * 30.0
            )
            freshness_bonus = 20.0 if len(prices_7d) > 0 else 0.0
            quality_score = round(min(sample_score + freshness_bonus, 100.0), 1)

            results.append(
                RollingBoardRate(
                    category=category,
                    sub_category=sub_category,
                    district=district,
                    median_7d_per_kg=round(median_7d, 2),
                    median_30d_per_kg=round(median_30d, 2),
                    mean_7d_per_kg=round(mean_7d, 2),
                    trend=trend,
                    pct_change_7d=pct_change,
                    sample_size_7d=len(prices_7d),
                    sample_size_30d=len(prices_30d),
                    quality_score=quality_score,
                    last_updated=now,
                )
            )

        results.sort(key=lambda x: (x.district, x.category, x.sub_category))
        return results

    @staticmethod
    def evaluate_quality_metrics(
        total_raw: int,
        quarantined_val: int,
        quarantined_clean: int,
        cleaned_records: list[CleanedPriceObservation],
        now_dt: datetime | None = None,
    ) -> DatasetQualityMetrics:
        """Computes comprehensive health, freshness, and completeness metrics for the dataset."""
        now = now_dt or datetime.now(UTC)
        clean_count = len(cleaned_records)

        # Validity rate
        validity_rate = (clean_count / max(total_raw, 1)) * 100.0

        # Completeness: percentage of non-null optional values
        filled_fields = 0
        total_fields = max(clean_count * 3, 1)  # city, recycler_id, collector_id
        for r in cleaned_records:
            if r.city:
                filled_fields += 1
            if r.recycler_id:
                filled_fields += 1
            if r.collector_id:
                filled_fields += 1
        completeness = (filled_fields / total_fields) * 100.0

        # Freshness: age of newest record
        if cleaned_records:
            newest_dt = max(
                (r.recorded_at if r.recorded_at.tzinfo else r.recorded_at.replace(tzinfo=UTC))
                for r in cleaned_records
            )
            age_hours = max((now - newest_dt).total_seconds() / 3600.0, 0.0)
            if age_hours <= 12.0:
                freshness = 100.0
            elif age_hours <= 48.0:
                freshness = 85.0
            elif age_hours <= 168.0:
                freshness = 65.0
            else:
                freshness = 40.0
        else:
            freshness = 0.0

        overall = round(
            0.40 * validity_rate + 0.35 * freshness + 0.25 * completeness,
            1,
        )

        return DatasetQualityMetrics(
            total_raw_ingested=total_raw,
            valid_count=total_raw - quarantined_val,
            quarantined_validation_count=quarantined_val,
            quarantined_outlier_count=quarantined_clean,
            clean_count=clean_count,
            completeness_score=round(completeness, 1),
            freshness_score=round(freshness, 1),
            validity_rate_pct=round(validity_rate, 1),
            overall_quality_score=min(overall, 100.0),
            evaluation_time=now,
        )
