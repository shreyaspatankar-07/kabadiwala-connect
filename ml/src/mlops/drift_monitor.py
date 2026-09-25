"""Drift Monitoring & Population Stability Index (PSI) Engine.

Computes Population Stability Index (PSI) between a baseline (training)
distribution and a production/monitoring batch distribution.
Alerts when PSI > 0.2 (significant shift) or 0.1 <= PSI <= 0.2 (moderate shift).
"""

from typing import Dict, List, Tuple
import numpy as np


def calculate_psi(
    expected: List[float] | np.ndarray,
    actual: List[float] | np.ndarray,
    num_buckets: int = 10,
    epsilon: float = 1e-4,
) -> Tuple[float, List[Dict[str, float]]]:
    """Calculate Population Stability Index (PSI) between expected and actual distributions.

    Parameters
    ----------
    expected : array-like
        Baseline / Training feature values.
    actual : array-like
        Current / Monitoring batch feature values.
    num_buckets : int
        Number of quantile bins (default 10).
    epsilon : float
        Small offset to prevent division by zero or log(0).

    Returns
    -------
    Tuple[float, List[Dict[str, float]]]
        Total PSI score and breakdown per bucket.
    """
    exp_arr = np.asarray(expected, dtype=float)
    act_arr = np.asarray(actual, dtype=float)

    if len(exp_arr) == 0 or len(act_arr) == 0:
        return 0.0, []

    # Create quantile break points from expected baseline
    quantiles = np.linspace(0, 100, num_buckets + 1)
    percentiles = np.percentile(exp_arr, quantiles)
    # Ensure strictly increasing bins
    bins = np.unique(percentiles)
    if len(bins) < 2:
        bins = np.array([exp_arr.min() - epsilon, exp_arr.max() + epsilon])

    bins[0] = -np.inf
    bins[-1] = np.inf

    exp_counts, _ = np.histogram(exp_arr, bins=bins)
    act_counts, _ = np.histogram(act_arr, bins=bins)

    exp_pct = np.maximum(exp_counts / len(exp_arr), epsilon)
    act_pct = np.maximum(act_counts / len(act_arr), epsilon)

    # PSI formula: sum((Actual% - Expected%) * ln(Actual% / Expected%))
    bucket_psis = (act_pct - exp_pct) * np.log(act_pct / exp_pct)
    total_psi = float(np.sum(bucket_psis))

    breakdown = []
    for i in range(len(bins) - 1):
        breakdown.append({
            "bin_lower": float(bins[i]) if bins[i] != -np.inf else float("-inf"),
            "bin_upper": float(bins[i + 1]) if bins[i + 1] != np.inf else float("inf"),
            "expected_pct": round(float(exp_pct[i]), 4),
            "actual_pct": round(float(act_pct[i]), 4),
            "psi": round(float(bucket_psis[i]), 6),
        })

    return round(total_psi, 4), breakdown


def evaluate_drift_status(psi_score: float) -> Dict[str, str | float | bool]:
    """Evaluate drift severity based on standard PSI thresholds:

    PSI < 0.1: No significant change / stable.
    0.1 <= PSI <= 0.2: Moderate shift / monitor closely.
    PSI > 0.2: Significant drift / trigger retraining warning.
    """
    if psi_score > 0.20:
        return {
            "psi": psi_score,
            "status": "CRITICAL_DRIFT",
            "is_drift_detected": True,
            "action_required": "Retrain model and update regional baseline distribution.",
            "message": f"WARNING: Population Stability Index (PSI={psi_score:.4f}) exceeds threshold 0.20. Significant distribution drift detected.",
        }
    elif psi_score >= 0.10:
        return {
            "psi": psi_score,
            "status": "MODERATE_DRIFT",
            "is_drift_detected": False,
            "action_required": "Monitor next batch of weekly price submissions.",
            "message": f"INFO: Moderate distribution shift (PSI={psi_score:.4f}). Within acceptable operating bounds.",
        }
    else:
        return {
            "psi": psi_score,
            "status": "STABLE",
            "is_drift_detected": False,
            "action_required": "None",
            "message": f"OK: Distribution is stable (PSI={psi_score:.4f} < 0.10).",
        }
