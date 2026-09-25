"""Optional Learned Re-Ranker utilizing LightGBM with Rule-Based Fallback."""

import logging
from typing import Any

import numpy as np

from app.matching.schemas import LotMatchInput, RankedRecycler, RecyclerCandidate
from app.matching.scoring import (
    estimate_pickup_time,
    haversine_distance_km,
    load_scoring_config,
    passes_hard_filters,
    rank_candidates_rule_based,
)

logger = logging.getLogger("kabadiwala.matching.reranker")


class LearnedReranker:
    """LightGBM-based learned re-ranker for e-waste lot recycler matching.

    Falls back to deterministic rule-based multi-criteria scoring when
    training data contains fewer than the threshold (default: 50 records).
    """

    def __init__(self, min_training_records: int = 50):
        self.min_training_records = min_training_records
        self._model: Any = None

    def _extract_candidate_features(
        self,
        candidate: RecyclerCandidate,
        lot: LotMatchInput,
        dist_km: float,
        rate: float,
        min_rate: float,
        max_rate: float,
        dist_decay: float,
        speed_max: float,
        def_comp: float,
        def_speed: float,
    ) -> list[float]:
        """Extracts normalized feature vector for a candidate."""
        norm_rate = (rate - min_rate) / (max_rate - min_rate) if max_rate > min_rate else (1.0 if rate > 0 else 0.0)
        norm_dist = 1.0 / (1.0 + (dist_km / dist_decay))
        norm_pickup = 1.0 if candidate.pickup_available else 0.0
        comp_rate = candidate.completion_rate if candidate.completion_rate is not None else def_comp
        norm_comp = max(0.0, min(1.0, float(comp_rate)))
        speed_hours = (
            candidate.confirmation_speed_hours
            if candidate.confirmation_speed_hours is not None
            else def_speed
        )
        norm_speed = max(0.0, 1.0 - (float(speed_hours) / speed_max))
        norm_rating = max(0.0, min(1.0, float(candidate.rating) / 5.0))

        return [norm_rate, norm_dist, norm_pickup, norm_comp, norm_speed, norm_rating]

    def rank_recyclers(
        self,
        candidates: list[RecyclerCandidate],
        lot: LotMatchInput,
        training_records: list[dict[str, Any]] | None = None,
    ) -> tuple[list[RankedRecycler], str]:
        """Ranks candidates using LightGBM if sufficient data exists, else falls back to rule-based."""
        records = training_records or []
        _, params = load_scoring_config()
        min_req = int(params.get("min_records_for_learned_ranker", self.min_training_records))

        # Check threshold
        if len(records) < min_req:
            logger.info(
                "Historical match training records (%d) < threshold (%d). Falling back to rule-based matching.",
                len(records),
                min_req,
            )
            return rank_candidates_rule_based(candidates, lot), "rule_based"

        # Attempt to train LightGBM re-ranker on past match interactions
        try:
            import lightgbm as lgb

            X_train = np.array([r["features"] for r in records], dtype=np.float32)
            y_train = np.array([r["label"] for r in records], dtype=np.int32)

            train_ds = lgb.Dataset(X_train, label=y_train, free_raw_data=False)
            train_params = {
                "objective": "binary",
                "learning_rate": 0.08,
                "num_leaves": 7,
                "min_child_samples": 5,
                "seed": 42,
                "verbose": -1,
            }
            bst = lgb.train(train_params, train_ds, num_boost_round=30)

            # Filter candidates first using hard filters
            passing: list[tuple[RecyclerCandidate, float, float]] = []
            for c in candidates:
                d_km = haversine_distance_km(
                    lot.collection_lat, lot.collection_lng, c.latitude, c.longitude
                )
                if passes_hard_filters(c, lot, d_km):
                    r_val = float(c.offered_rates.get(lot.category, 0.0))
                    passing.append((c, d_km, r_val))

            if not passing:
                return [], "lightgbm"

            # Compute features for candidates
            all_rates = [p[2] for p in passing]
            min_r = min(all_rates)
            max_r = max(all_rates)
            dist_decay = float(params.get("distance_decay_km", 10.0))
            speed_max = float(params.get("speed_max_hours", 48.0))
            def_comp = float(params.get("default_completion_rate", 0.85))
            def_speed = float(params.get("default_confirmation_hours", 4.0))

            cand_features = []
            for c, d_km, r_val in passing:
                feat = self._extract_candidate_features(
                    c, lot, d_km, r_val, min_r, max_r, dist_decay, speed_max, def_comp, def_speed
                )
                cand_features.append(feat)

            # Predict probabilities of acceptance using native booster
            probs = bst.predict(np.array(cand_features, dtype=np.float32))

            # Get rule-based baseline to attach score breakdowns
            rule_based_results = {
                r.recycler_id: r for r in rank_candidates_rule_based(candidates, lot)
            }

            ranked_items = []
            for idx, (c, d_km, r_val) in enumerate(passing):
                predicted_score = float(probs[idx])
                rule_match = rule_based_results.get(c.id)
                breakdown = rule_match.score_breakdown if rule_match else None
                ranked_items.append((predicted_score, r_val, d_km, c.rating, c.id, c, breakdown))

            # Deterministic sorting
            ranked_items.sort(
                key=lambda item: (-item[0], -item[1], item[2], -item[3], item[4])
            )

            results: list[RankedRecycler] = []
            for r_idx, (p_score, r_val, d_km, _rating, _cid, candidate, breakdown) in enumerate(
                ranked_items[:3], start=1
            ):
                from app.matching.schemas import ScoreBreakdown

                b_down = breakdown or ScoreBreakdown(
                    offered_rate=round(r_val, 4),
                    distance=round(d_km, 4),
                    pickup_available=round(1.0 if candidate.pickup_available else 0.0, 4),
                    completion_rate=round(candidate.completion_rate or 0.85, 4),
                    confirmation_speed=round(candidate.confirmation_speed_hours or 4.0, 4),
                    rating=round(candidate.rating / 5.0, 4),
                )
                results.append(
                    RankedRecycler(
                        recycler_id=candidate.id,
                        name=candidate.name,
                        phone=candidate.phone,
                        rank=r_idx,
                        score=round(p_score, 4),
                        score_breakdown=b_down,
                        distance_km=d_km,
                        offered_rate=r_val,
                        pickup_available=candidate.pickup_available,
                        estimated_pickup_time=estimate_pickup_time(candidate.pickup_available, d_km),
                        authorization_number=candidate.authorization_number,
                        rating=candidate.rating,
                    )
                )

            return results, "lightgbm"

        except Exception as e:
            logger.warning("Error running LightGBM re-ranker (%s). Falling back to rule-based.", e)
            return rank_candidates_rule_based(candidates, lot), "rule_based"
