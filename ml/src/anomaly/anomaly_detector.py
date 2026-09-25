"""Anomaly Detection Engine: Isolation Forest + Domain Rule Checks.

Detects anomalous e-waste lots via:
1. Final price far outside IQR range for category (below Q1 - 2.5*IQR or above Q3 + 2.5*IQR).
2. Implausible weight for category (against PS bounds).
3. Repeated identical lots (same collector, category, weight within 1 hour).
4. GPS coordinate jump > 50 km between consecutive lots.
5. Multivariate Isolation Forest anomaly scoring on [weight, price, rate].

Produces actionable, plain-language reason strings (English / translatable).
"""

import math
from pathlib import Path
from typing import Any

import joblib
import numpy as np
from sklearn.ensemble import IsolationForest

# Weight bounds per category from data pipeline schemas
CATEGORY_WEIGHT_BOUNDS = {
    "CRT": (4.0, 50.0),
    "LCD": (0.5, 40.0),
    "PCB": (0.05, 50.0),
    "Cables": (0.1, 200.0),
    "Batteries": (0.1, 100.0),
    "Motors_Magnets": (0.5, 150.0),
    "Mixed_Plastics": (0.1, 500.0),
    "Other": (0.1, 500.0),
}

# Standard regional benchmark rates (IQR reference)
CATEGORY_RATE_RANGES = {
    "PCB": {"q1": 320.0, "q3": 520.0, "median": 420.0},
    "Cables": {"q1": 500.0, "q3": 780.0, "median": 680.0},
    "Batteries": {"q1": 80.0, "q3": 160.0, "median": 120.0},
    "CRT": {"q1": 30.0, "q3": 65.0, "median": 45.0},
    "LCD": {"q1": 180.0, "q3": 360.0, "median": 280.0},
    "Motors_Magnets": {"q1": 130.0, "q3": 240.0, "median": 190.0},
    "Mixed_Plastics": {"q1": 20.0, "q3": 50.0, "median": 35.0},
    "Other": {"q1": 40.0, "q3": 110.0, "median": 80.0},
}


def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great circle distance in kilometers between two points."""
    radius_earth_km = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return radius_earth_km * c


class AnomalyDetector:
    """Combines Rule-Based heuristic filters and an Isolation Forest model."""

    def __init__(self, model_path: Path | str | None = None):
        if model_path:
            self.model_path = Path(model_path)
        else:
            self.model_path = (
                Path(__file__).resolve().parent.parent.parent / "models" / "anomaly_detector.joblib"
            )

        self.iso_forest: IsolationForest | None = None
        self._load_model()

    def _load_model(self) -> None:
        if self.model_path.exists():
            try:
                self.iso_forest = joblib.load(self.model_path)
            except Exception:
                self.iso_forest = None
        if self.iso_forest is None:
            self._fit_default_model()

    def _fit_default_model(self) -> None:
        """Fit baseline Isolation Forest on reference e-waste data."""
        rng = np.random.RandomState(42)
        # Synthetic baseline: [weight_kg, price_per_kg, total_price]
        weights = rng.exponential(scale=15.0, size=2000).clip(0.5, 200.0)
        rates = rng.normal(loc=250.0, scale=120.0, size=2000).clip(10.0, 900.0)
        totals = weights * rates

        X = np.column_stack([weights, rates, totals])
        clf = IsolationForest(
            n_estimators=100,
            contamination=0.03,
            random_state=42,
        )
        clf.fit(X)
        self.iso_forest = clf

    def check_lot(
        self,
        category: str,
        weight_kg: float,
        final_price: float,
        collector_id: str | None = None,
        latitude: float | None = None,
        longitude: float | None = None,
        previous_lot: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """Perform comprehensive anomaly checks on a submitted lot.

        Returns
        -------
        Dict with is_anomalous, anomaly_score, reasons (List[str]), flags (List[str]).
        """
        reasons: list[str] = []
        flags: list[str] = []
        is_anomalous = False

        price_per_kg = final_price / weight_kg if weight_kg > 0 else 0.0

        # Rule 1: Implausible weight for category
        min_w, max_w = CATEGORY_WEIGHT_BOUNDS.get(category, (0.1, 500.0))
        if weight_kg < min_w or weight_kg > max_w:
            is_anomalous = True
            flags.append("IMPLAUSIBLE_WEIGHT")
            reasons.append(
                f"Weight {weight_kg} kg is outside expected bounds ({min_w}-{max_w} kg) for category {category}."
            )

        # Rule 2: Price far outside IQR range for category
        iqr_info = CATEGORY_RATE_RANGES.get(category, CATEGORY_RATE_RANGES["Other"])
        q1 = iqr_info["q1"]
        q3 = iqr_info["q3"]
        iqr = q3 - q1
        lower_bound = max(5.0, q1 - 2.5 * iqr)
        upper_bound = q3 + 2.5 * iqr

        if price_per_kg < lower_bound or price_per_kg > upper_bound:
            is_anomalous = True
            flags.append("PRICE_OUTSIDE_IQR")
            reasons.append(
                f"Quoted rate ₹{price_per_kg:.2f}/kg deviates significantly from normal market range (₹{lower_bound:.0f} - ₹{upper_bound:.0f}/kg) for {category}."
            )

        # Rule 3: Repeated identical lots within 1 hour
        if previous_lot:
            prev_collector = previous_lot.get("collector_id")
            prev_cat = previous_lot.get("category")
            prev_weight = previous_lot.get("weight_kg", 0.0)
            prev_time = previous_lot.get("timestamp")  # epoch or datetime difference in seconds
            elapsed_seconds = previous_lot.get("elapsed_seconds", 99999)

            if (
                collector_id
                and prev_collector == collector_id
                and prev_cat == category
                and abs(prev_weight - weight_kg) < 0.05
                and elapsed_seconds < 3600
            ):
                is_anomalous = True
                flags.append("REPEATED_IDENTICAL_LOT")
                reasons.append(
                    f"Duplicate lot detected: identical category ({category}) and weight ({weight_kg} kg) submitted within {elapsed_seconds // 60} minutes."
                )

            # Rule 4: GPS jump > 50 km
            prev_lat = previous_lot.get("latitude")
            prev_lng = previous_lot.get("longitude")
            if (
                latitude is not None
                and longitude is not None
                and prev_lat is not None
                and prev_lng is not None
            ):
                dist_km = haversine_distance_km(prev_lat, prev_lng, latitude, longitude)
                if dist_km > 50.0 and elapsed_seconds < 7200:
                    is_anomalous = True
                    flags.append("GPS_JUMP_SUSPICIOUS")
                    reasons.append(
                        f"Unrealistic spatial jump of {dist_km:.1f} km detected within {elapsed_seconds // 60} minutes."
                    )

        # Rule 5: Isolation Forest Multivariate check
        features = np.array([[weight_kg, price_per_kg, final_price]])
        iso_score = 0.0
        if self.iso_forest is not None:
            raw_score = float(self.iso_forest.decision_function(features)[0])
            # Normalized anomaly score 0.0 (normal) to 1.0 (severe anomaly)
            iso_score = round(max(0.0, min(1.0, 0.5 - raw_score)), 3)
            if raw_score < -0.10:
                is_anomalous = True
                flags.append("MULTIVARIATE_ISOLATION_ANOMALY")
                if not any("deviates" in r for r in reasons):
                    reasons.append(
                        f"Multivariate pattern anomaly detected across weight ({weight_kg}kg) and price (₹{final_price})."
                    )

        return {
            "is_anomalous": is_anomalous,
            "anomaly_score": iso_score,
            "flags": flags,
            "reasons": reasons
            if reasons
            else ["No anomalies detected. Lot passes all validation checks."],
            "category": category,
            "weight_kg": weight_kg,
            "final_price": final_price,
            "price_per_kg": round(price_per_kg, 2),
        }
