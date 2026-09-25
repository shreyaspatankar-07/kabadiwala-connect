"""Valuation Model Pipeline with LightGBM Quantile Regressors.

Predicts price_per_kg for scrap e-waste lots with 90% prediction intervals
using features:
- category (encoded)
- sub_category (encoded)
- weight_kg (continuous)
- condition (encoded: working, broken, damaged, burnt)
- location_district (encoded: Palghar, Thane, Mumbai, Pune, Nashik, Nagpur)
- month (seasonality 1..12)
- 7d_median_price (regional trend)
- 30d_median_price (regional anchor)

Computes honest improvements (RMSE, MAE, MAPE) over simple median baseline.
"""

import json
import math
from pathlib import Path
from typing import Any

import joblib
import lightgbm as lgb
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

DISTRICTS = ["Palghar", "Thane", "Mumbai", "Pune", "Nashik", "Nagpur"]
CATEGORIES = [
    "CRT",
    "LCD",
    "PCB",
    "Cables",
    "Batteries",
    "Motors_Magnets",
    "Mixed_Plastics",
    "Other",
]
CONDITIONS = ["working", "broken", "damaged", "burnt"]

SUB_CATEGORIES = {
    "PCB": ["Motherboard", "Mobile_Board", "Server_Board", "Power_Board"],
    "Cables": ["Copper_Insulated", "Aluminum_Cables", "Mixed_Wiring"],
    "Batteries": ["Li_ion_Pouch", "Li_ion_Cylindrical", "Lead_Acid_SLA"],
    "CRT": ["Color_CRT_Glass", "Monochrome_CRT"],
    "LCD": ["LED_Backlit_Panel", "CCFL_Panel", "Laptop_Matrix"],
    "Motors_Magnets": ["Copper_Stator", "Compressor_Motor", "Neodymium_Magnet"],
    "Mixed_Plastics": ["ABS_Flame_Retardant", "High_Impact_Polystyrene", "Polycarbonate"],
    "Other": ["General_Ewaste", "Mixed_Appliance"],
}

BASE_PRICES = {
    "PCB": 420.0,
    "Cables": 680.0,
    "Batteries": 120.0,
    "CRT": 45.0,
    "LCD": 280.0,
    "Motors_Magnets": 190.0,
    "Mixed_Plastics": 35.0,
    "Other": 80.0,
}

CONDITION_MULTIPLIERS = {
    "working": 1.15,
    "broken": 1.00,
    "damaged": 0.85,
    "burnt": 0.60,
}


def generate_synthetic_valuation_dataset(
    n_samples: int = 5000, random_seed: int = 42
) -> pd.DataFrame:
    """Generate realistic valuation training dataset with seasonal variations, condition adjustments, and realistic market noise."""
    rng = np.random.RandomState(random_seed)
    records = []

    for _ in range(n_samples):
        cat = rng.choice(CATEGORIES)
        sub_cat = rng.choice(SUB_CATEGORIES[cat])
        cond = rng.choice(CONDITIONS, p=[0.20, 0.45, 0.25, 0.10])
        dist = rng.choice(DISTRICTS)
        month = int(rng.randint(1, 13))

        # Weight per category
        if cat in ["CRT", "Motors_Magnets"]:
            weight_kg = round(float(rng.uniform(5.0, 45.0)), 2)
        elif cat in ["Batteries", "LCD"]:
            weight_kg = round(float(rng.uniform(1.0, 25.0)), 2)
        elif cat == "PCB":
            weight_kg = round(float(rng.uniform(0.5, 15.0)), 2)
        else:
            weight_kg = round(float(rng.uniform(1.0, 30.0)), 2)

        base = BASE_PRICES[cat]
        # District adjustment (+/- 8%)
        dist_adj = 1.0 + (DISTRICTS.index(dist) - 2.5) * 0.02
        # Seasonality (+/- 5% wave over months)
        season_adj = 1.0 + 0.05 * math.sin(2 * math.pi * month / 12)
        # Condition factor
        cond_mult = CONDITION_MULTIPLIERS[cond]

        # Rolling 30d median
        rolling_30d = round(base * dist_adj * season_adj * (1.0 + rng.normal(0, 0.03)), 2)
        # Rolling 7d median
        rolling_7d = round(rolling_30d * (1.0 + rng.normal(0, 0.04)), 2)

        # True realized price per kg with slight scale discount for large bulk or condition impact
        bulk_bonus = 1.0 + min(0.08, weight_kg * 0.002)
        true_price = (
            (rolling_7d * 0.70 + rolling_30d * 0.30)
            * cond_mult
            * bulk_bonus
            * (1.0 + rng.normal(0, 0.05))
        )

        true_price = max(5.0, round(float(true_price), 2))

        records.append(
            {
                "category": cat,
                "sub_category": sub_cat,
                "weight_kg": weight_kg,
                "condition": cond,
                "location_district": dist,
                "month": month,
                "7d_median_price": rolling_7d,
                "30d_median_price": rolling_30d,
                "price_per_kg": true_price,
            }
        )

    return pd.DataFrame(records)


def train_valuation_model(
    df: pd.DataFrame,
    output_dir: Path | str,
    random_seed: int = 42,
) -> dict[str, Any]:
    """Train LightGBM Quantile Regressors for alpha=0.05 (lower), 0.50 (median), 0.95 (upper)."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Feature Encoders
    cat_mapping = {c: i for i, c in enumerate(CATEGORIES)}
    all_subcats = sorted(list(set(sc for subs in SUB_CATEGORIES.values() for sc in subs)))
    subcat_mapping = {sc: i for i, sc in enumerate(all_subcats)}
    cond_mapping = {c: i for i, c in enumerate(CONDITIONS)}
    dist_mapping = {d: i for i, d in enumerate(DISTRICTS)}

    encoders = {
        "categories": cat_mapping,
        "sub_categories": subcat_mapping,
        "conditions": cond_mapping,
        "districts": dist_mapping,
    }

    # Transform dataset
    df_feat = df.copy()
    df_feat["category_enc"] = df_feat["category"].map(cat_mapping)
    df_feat["sub_category_enc"] = df_feat["sub_category"].map(subcat_mapping)
    df_feat["condition_enc"] = df_feat["condition"].map(cond_mapping)
    df_feat["district_enc"] = df_feat["location_district"].map(dist_mapping)

    feature_cols = [
        "category_enc",
        "sub_category_enc",
        "weight_kg",
        "condition_enc",
        "district_enc",
        "month",
        "7d_median_price",
        "30d_median_price",
    ]

    X = df_feat[feature_cols]
    y = df_feat["price_per_kg"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.15, random_state=random_seed
    )

    models: dict[str, lgb.LGBMRegressor] = {}
    quantiles = {"lower": 0.05, "median": 0.50, "upper": 0.95}

    for name, q in quantiles.items():
        reg = lgb.LGBMRegressor(
            objective="quantile",
            alpha=q,
            n_estimators=150,
            learning_rate=0.05,
            num_leaves=31,
            random_state=random_seed,
            verbose=-1,
        )
        reg.fit(X_train, y_train)
        models[name] = reg

    # Baseline comparison: simple category 30-day median
    median_baseline_preds = X_test["30d_median_price"].values
    y_true = y_test.values
    y_pred_lgb = models["median"].predict(X_test)
    y_pred_lower = models["lower"].predict(X_test)
    y_pred_upper = models["upper"].predict(X_test)

    # Metrics
    rmse_baseline = float(np.sqrt(np.mean((y_true - median_baseline_preds) ** 2)))
    mae_baseline = float(np.mean(np.abs(y_true - median_baseline_preds)))
    mape_baseline = float(np.mean(np.abs((y_true - median_baseline_preds) / y_true)) * 100)

    rmse_lgb = float(np.sqrt(np.mean((y_true - y_pred_lgb) ** 2)))
    mae_lgb = float(np.mean(np.abs(y_true - y_pred_lgb)))
    mape_lgb = float(np.mean(np.abs((y_true - y_pred_lgb) / y_true)) * 100)

    # 90% Prediction Interval Coverage
    in_interval = np.logical_and(y_true >= y_pred_lower, y_true <= y_pred_upper)
    interval_coverage = float(np.mean(in_interval) * 100)

    metrics = {
        "rmse": round(rmse_lgb, 3),
        "mae": round(mae_lgb, 3),
        "mape_percent": round(mape_lgb, 2),
        "baseline_rmse": round(rmse_baseline, 3),
        "baseline_mae": round(mae_baseline, 3),
        "baseline_mape_percent": round(mape_baseline, 2),
        "rmse_improvement_percent": round((rmse_baseline - rmse_lgb) / rmse_baseline * 100, 2),
        "mae_improvement_percent": round((mae_baseline - mae_lgb) / mae_baseline * 100, 2),
        "prediction_interval_90_coverage_percent": round(interval_coverage, 2),
        "test_sample_count": len(y_test),
    }

    # Save LightGBM booster models and pipeline bundle
    median_booster = models["median"].booster_
    lgb_model_file = out_path / "valuation_model.lgb"
    median_booster.save_model(str(lgb_model_file))

    bundle = {
        "models": models,
        "encoders": encoders,
        "feature_cols": feature_cols,
        "metrics": metrics,
    }
    joblib.dump(bundle, out_path / "valuation_bundle.joblib")

    metadata = {
        "model_id": "ewaste-valuation-lgbm-v1",
        "framework": "LightGBM",
        "task": "e-waste scrap valuation with 90% prediction interval",
        "features": feature_cols,
        "metrics": metrics,
    }
    with open(out_path / "valuation_metadata.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    return metadata


if __name__ == "__main__":
    df_data = generate_synthetic_valuation_dataset(5000)
    models_dir = Path(__file__).resolve().parent.parent.parent / "models"
    result = train_valuation_model(df_data, models_dir)
    print("Valuation Model Training Completed:")
    print(json.dumps(result, indent=2))
