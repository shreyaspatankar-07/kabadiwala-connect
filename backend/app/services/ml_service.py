import datetime
from pathlib import Path
import sys
from typing import Any, Dict, List, Optional

repo_root = Path(__file__).resolve().parent.parent.parent.parent
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

from ml.src.anomaly.anomaly_detector import AnomalyDetector
from ml.src.valuation.valuation_service import ValuationService
from ml.src.mlops.registry import ModelRegistry
from ml.src.mlops.drift_monitor import calculate_psi, evaluate_drift_status


class MLService:
    def __init__(self, models_dir: Optional[Path | str] = None):
        if models_dir:
            self.models_dir = Path(models_dir)
        else:
            self.models_dir = Path(__file__).resolve().parent.parent.parent.parent / "ml" / "models"
        self.models_dir.mkdir(parents=True, exist_ok=True)

        self.anomaly_detector = AnomalyDetector(self.models_dir / "anomaly_detector.joblib")
        self.valuation_service = ValuationService(self.models_dir / "valuation_bundle.joblib")
        self.registry = ModelRegistry(self.models_dir)

    def check_anomaly(
        self,
        category: str,
        weight_kg: float,
        final_price: float,
        collector_id: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        previous_lot: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        return self.anomaly_detector.check_lot(
            category=category,
            weight_kg=weight_kg,
            final_price=final_price,
            collector_id=collector_id,
            latitude=latitude,
            longitude=longitude,
            previous_lot=previous_lot,
        )

    def predict_valuation(
        self,
        category: str,
        sub_category: Optional[str],
        weight_kg: float,
        condition: str,
        location_district: str,
        month: Optional[int] = None,
        rolling_7d_median: Optional[float] = None,
        rolling_30d_median: Optional[float] = None,
    ) -> Dict[str, Any]:
        cur_month = month or datetime.datetime.now().month
        r7d = rolling_7d_median or 250.0
        r30d = rolling_30d_median or 240.0
        sub_cat = sub_category or "Standard"

        return self.valuation_service.predict(
            category=category,
            sub_category=sub_cat,
            weight_kg=weight_kg,
            condition=condition,
            location_district=location_district,
            month=cur_month,
            rolling_7d_median=r7d,
            rolling_30d_median=r30d,
        )

    def get_manifest(self) -> Dict[str, Any]:
        return self.registry.get_manifest()

    def check_distribution_drift(
        self,
        feature_name: str,
        expected: List[float],
        actual: List[float],
        num_buckets: int = 10,
    ) -> Dict[str, Any]:
        psi_score, breakdown = calculate_psi(expected, actual, num_buckets=num_buckets)
        eval_result = evaluate_drift_status(psi_score)
        return {
            "feature_name": feature_name,
            "psi": psi_score,
            "status": eval_result["status"],
            "is_drift_detected": eval_result["is_drift_detected"],
            "action_required": eval_result["action_required"],
            "message": eval_result["message"],
            "bucket_breakdown": breakdown,
        }


ml_service = MLService()
