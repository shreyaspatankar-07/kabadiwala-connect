"""Unit Tests for ML Pipelines: Classifier, Valuation, Anomaly Detector, Registry, and Drift Monitoring."""

import numpy as np
from ml.src.anomaly.anomaly_detector import (
    AnomalyDetector,
    haversine_distance_km,
)
from ml.src.material_classifier.train_classifier import (
    CATEGORIES,
    MaterialAugmentationPipeline,
    generate_synthetic_image_features,
    train_and_evaluate_classifier,
)
from ml.src.mlops.drift_monitor import calculate_psi, evaluate_drift_status
from ml.src.mlops.registry import ModelRegistry, compute_file_sha256
from ml.src.valuation.train_valuation import (
    generate_synthetic_valuation_dataset,
    train_valuation_model,
)
from ml.src.valuation.valuation_service import ValuationService


def test_material_augmentation_and_features():
    aug = MaterialAugmentationPipeline(random_state=42)
    sample = np.ones(128, dtype=np.float32) * 0.5
    augmented = aug.augment(sample)
    assert augmented.shape == (128,)
    assert not np.array_equal(sample, augmented)

    X, y = generate_synthetic_image_features(samples_per_class=20, feature_dim=64, random_state=42)
    assert len(X) == 20 * len(CATEGORIES)
    assert len(y) == len(X)
    assert set(np.unique(y)) == set(range(len(CATEGORIES)))


def test_classifier_training_metrics(tmp_path):
    metrics = train_and_evaluate_classifier(output_dir=tmp_path, random_state=42)
    assert metrics["top1_accuracy_percent"] >= 70.0
    assert metrics["top3_accuracy_percent"] >= 90.0
    assert len(metrics["categories"]) == len(CATEGORIES)
    assert len(metrics["confusion_matrix"]) == len(CATEGORIES)
    for cat in CATEGORIES:
        assert cat in metrics["per_class_f1"]

    tflite_file = tmp_path / "material_classifier_int8.tflite"
    assert tflite_file.exists()
    assert tflite_file.stat().st_size > 1000  # valid binary artifact


def test_valuation_training_and_service(tmp_path):
    df = generate_synthetic_valuation_dataset(n_samples=500, random_seed=42)
    meta = train_valuation_model(df, output_dir=tmp_path, random_seed=42)

    assert meta["metrics"]["rmse"] > 0
    assert meta["metrics"]["rmse_improvement_percent"] > 0
    assert meta["metrics"]["prediction_interval_90_coverage_percent"] >= 70.0

    service = ValuationService(model_bundle_path=tmp_path / "valuation_bundle.joblib")
    assert service.is_ready()

    res = service.predict(
        category="PCB",
        sub_category="Motherboard",
        weight_kg=5.0,
        condition="working",
        location_district="Mumbai",
        month=8,
        rolling_7d_median=430.0,
        rolling_30d_median=420.0,
    )
    assert res["low_price_per_kg"] <= res["predicted_price_per_kg"]
    assert res["high_price_per_kg"] >= res["predicted_price_per_kg"]
    assert res["total_estimated_value"] == round(res["predicted_price_per_kg"] * 5.0, 2)


def test_haversine_distance():
    # Mumbai (19.0760, 72.8777) to Pune (18.5204, 73.8567) is ~120 km
    dist = haversine_distance_km(19.0760, 72.8777, 18.5204, 73.8567)
    assert 110.0 <= dist <= 130.0


def test_anomaly_detector_rules(tmp_path):
    detector = AnomalyDetector(model_path=tmp_path / "anomaly_test.joblib")

    # 1. Implausible weight (CRT 0.2 kg)
    res_w = detector.check_lot(category="CRT", weight_kg=0.2, final_price=20.0)
    assert res_w["is_anomalous"] is True
    assert "IMPLAUSIBLE_WEIGHT" in res_w["flags"]

    # 2. Rate IQR violation (Batteries ₹2000/kg)
    res_p = detector.check_lot(category="Batteries", weight_kg=10.0, final_price=20000.0)
    assert res_p["is_anomalous"] is True
    assert "PRICE_OUTSIDE_IQR" in res_p["flags"]

    # 3. Duplicate lot within 1 hour
    prev_lot = {
        "collector_id": "COL-123",
        "category": "PCB",
        "weight_kg": 5.0,
        "elapsed_seconds": 300,
    }
    res_d = detector.check_lot(
        category="PCB",
        weight_kg=5.0,
        final_price=2100.0,
        collector_id="COL-123",
        previous_lot=prev_lot,
    )
    assert res_d["is_anomalous"] is True
    assert "REPEATED_IDENTICAL_LOT" in res_d["flags"]


def test_psi_and_drift_monitoring():
    # Stable test
    base = [100.0 + i for i in range(50)]
    current_stable = [100.2 + i for i in range(50)]
    psi_stable, breakdown = calculate_psi(base, current_stable, num_buckets=5)
    eval_stable = evaluate_drift_status(psi_stable)
    assert eval_stable["is_drift_detected"] is False
    assert eval_stable["status"] == "STABLE"

    # Shifted test
    current_shifted = [300.0 + i for i in range(50)]
    psi_shifted, _ = calculate_psi(base, current_shifted, num_buckets=5)
    eval_shifted = evaluate_drift_status(psi_shifted)
    assert eval_shifted["is_drift_detected"] is True
    assert eval_shifted["status"] == "CRITICAL_DRIFT"


def test_model_registry(tmp_path):
    registry = ModelRegistry(registry_dir=tmp_path)
    dummy_file = tmp_path / "dummy_model.bin"
    dummy_file.write_bytes(b"dummy binary weights content")

    sha = compute_file_sha256(dummy_file)
    assert len(sha) == 64

    entry = registry.register_model(
        model_id="test-model",
        version="0.1.0",
        filename="dummy_model.bin",
        framework="custom",
        task="testing",
        metrics={"accuracy": 0.99},
        description="A test model",
    )
    assert entry["model_id"] == "test-model"
    assert entry["sha256"] == sha

    manifest = registry.get_manifest()
    assert "test-model" in manifest["models"]
