"""Master ML Training & Model Registry Builder.

Executes:
1. Material Classifier (MobileNetV3-Small INT8 TFLite)
2. Valuation Model (LightGBM Quantile Regressors)
3. Anomaly Detector (Isolation Forest + Rules)
4. MLOps Registry (models.json generation)
"""

from pathlib import Path
import json
import joblib

from ml.src.material_classifier.train_classifier import train_and_evaluate_classifier
from ml.src.valuation.train_valuation import generate_synthetic_valuation_dataset, train_valuation_model
from ml.src.anomaly.anomaly_detector import AnomalyDetector
from ml.src.mlops.registry import ModelRegistry


def run_pipeline() -> None:
    root_dir = Path(__file__).resolve().parent
    models_dir = root_dir / "models"
    models_dir.mkdir(parents=True, exist_ok=True)
    registry = ModelRegistry(models_dir)

    print("=== 1. Training Material Classifier (MobileNetV3-Small INT8) ===")
    classifier_metrics = train_and_evaluate_classifier(models_dir)
    registry.register_model(
        model_id="ewaste-mobilenetv3-small-int8",
        version="1.0.0",
        filename="material_classifier_int8.tflite",
        framework="TensorFlow Lite / INT8",
        task="e-waste material classification",
        metrics={
            "top1_accuracy": classifier_metrics["top1_accuracy_percent"],
            "top3_accuracy": classifier_metrics["top3_accuracy_percent"],
            "categories_count": len(classifier_metrics["categories"]),
        },
        description="MobileNetV3-Small INT8 quantized model for on-device e-waste scrap image classification (< 2.5 MB).",
    )

    print("=== 2. Training Valuation Model (LightGBM Quantile Regressors) ===")
    df_valuation = generate_synthetic_valuation_dataset(5000)
    valuation_meta = train_valuation_model(df_valuation, models_dir)
    registry.register_model(
        model_id="ewaste-valuation-lgbm",
        version="1.0.0",
        filename="valuation_model.lgb",
        framework="LightGBM",
        task="e-waste scrap valuation with 90% prediction interval",
        metrics=valuation_meta["metrics"],
        parameters={"features": valuation_meta["features"]},
        description="LightGBM quantile regressors predicting price per kg with lower (5%), median (50%), and upper (95%) bounds.",
    )

    print("=== 3. Fitting Anomaly Detector (Isolation Forest) ===")
    detector = AnomalyDetector(models_dir / "anomaly_detector.joblib")
    joblib.dump(detector.iso_forest, models_dir / "anomaly_detector.joblib")
    registry.register_model(
        model_id="ewaste-anomaly-isolation-forest",
        version="1.0.0",
        filename="anomaly_detector.joblib",
        framework="scikit-learn",
        task="e-waste transaction anomaly detection",
        metrics={"contamination": 0.03, "n_estimators": 100},
        description="Isolation Forest + rule checks flagging price IQR outliers, weight sanity violations, and rapid GPS jumps.",
    )

    manifest = registry.get_manifest()
    print("=== 4. Model Registry Manifest Created ===")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    run_pipeline()
