"""Valuation Inference Service."""

from pathlib import Path
from typing import Any

import joblib


class ValuationService:
    """Predicts estimated price_per_kg and 90% prediction intervals."""

    def __init__(self, model_bundle_path: Path | str | None = None):
        if model_bundle_path:
            self.bundle_path = Path(model_bundle_path)
        else:
            self.bundle_path = (
                Path(__file__).resolve().parent.parent.parent / "models" / "valuation_bundle.joblib"
            )

        self._bundle: dict[str, Any] | None = None
        self._load_bundle()

    def _load_bundle(self) -> None:
        if self.bundle_path.exists():
            try:
                self._bundle = joblib.load(self.bundle_path)
            except Exception:
                self._bundle = None

    def is_ready(self) -> bool:
        return self._bundle is not None

    def predict(
        self,
        category: str,
        sub_category: str,
        weight_kg: float,
        condition: str,
        location_district: str,
        month: int,
        rolling_7d_median: float,
        rolling_30d_median: float,
    ) -> dict[str, Any]:
        """Predict price per kg and 90% prediction interval.

        Returns
        -------
        Dict with predicted_price_per_kg, low_price_per_kg, high_price_per_kg,
        total_estimated_value, total_low_value, total_high_value.
        """
        # Fallback heuristic if bundle not loaded
        if self._bundle is None:
            cond_factor = {"working": 1.15, "broken": 1.0, "damaged": 0.85, "burnt": 0.60}.get(
                condition, 1.0
            )
            median_rate = rolling_7d_median * 0.70 + rolling_30d_median * 0.30
            pred_rate = round(median_rate * cond_factor, 2)
            low_rate = round(pred_rate * 0.88, 2)
            high_rate = round(pred_rate * 1.12, 2)
            return {
                "predicted_price_per_kg": pred_rate,
                "low_price_per_kg": low_rate,
                "high_price_per_kg": high_rate,
                "total_estimated_value": round(pred_rate * weight_kg, 2),
                "total_low_value": round(low_rate * weight_kg, 2),
                "total_high_value": round(high_rate * weight_kg, 2),
                "confidence_level": "heuristic_fallback",
            }

        encoders = self._bundle["encoders"]
        models = self._bundle["models"]

        cat_enc = encoders["categories"].get(category, encoders["categories"].get("Other", 0))
        subcat_enc = encoders["sub_categories"].get(sub_category, 0)
        cond_enc = encoders["conditions"].get(condition, 1)
        dist_enc = encoders["districts"].get(location_district, 2)

        import pandas as pd

        feat_df = pd.DataFrame(
            [
                {
                    "category_enc": cat_enc,
                    "sub_category_enc": subcat_enc,
                    "weight_kg": float(weight_kg),
                    "condition_enc": cond_enc,
                    "district_enc": dist_enc,
                    "month": int(month),
                    "7d_median_price": float(rolling_7d_median),
                    "30d_median_price": float(rolling_30d_median),
                }
            ]
        )

        pred_median = float(models["median"].predict(feat_df)[0])
        pred_lower = float(models["lower"].predict(feat_df)[0])
        pred_upper = float(models["upper"].predict(feat_df)[0])

        # Enforce sanity ordering: lower <= median <= upper
        low_rate = max(1.0, round(min(pred_lower, pred_median), 2))
        med_rate = max(1.0, round(pred_median, 2))
        high_rate = max(med_rate, round(max(pred_upper, pred_median), 2))

        return {
            "predicted_price_per_kg": med_rate,
            "low_price_per_kg": low_rate,
            "high_price_per_kg": high_rate,
            "total_estimated_value": round(med_rate * weight_kg, 2),
            "total_low_value": round(low_rate * weight_kg, 2),
            "total_high_value": round(high_rate * weight_kg, 2),
            "prediction_interval": "90%",
            "confidence_level": "ml_quantile_model",
        }
