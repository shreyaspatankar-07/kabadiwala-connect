"""Deterministic Recycler Ranking and Multi-Criteria Scoring Engine."""

from datetime import UTC, date, datetime
import math
from pathlib import Path
from typing import Any

import yaml

from app.matching.schemas import (
    LotMatchInput,
    RankedRecycler,
    RecyclerCandidate,
    ScoreBreakdown,
)

CONFIG_PATH = Path(__file__).parent / "weights.yaml"

DEFAULT_WEIGHTS = {
    "offered_rate": 0.30,
    "distance": 0.25,
    "pickup_available": 0.15,
    "completion_rate": 0.15,
    "confirmation_speed": 0.10,
    "rating": 0.05,
}

DEFAULT_PARAMETERS = {
    "distance_decay_km": 10.0,
    "speed_max_hours": 48.0,
    "default_completion_rate": 0.85,
    "default_confirmation_hours": 4.0,
    "min_records_for_learned_ranker": 50,
}


def load_scoring_config() -> tuple[dict[str, float], dict[str, float]]:
    """Loads weights and scoring parameters from YAML, with safe fallbacks."""
    if CONFIG_PATH.exists():
        try:
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                data = yaml.safe_load(f) or {}
                weights = data.get("weights", DEFAULT_WEIGHTS)
                parameters = data.get("parameters", DEFAULT_PARAMETERS)
                return weights, parameters
        except Exception:
            pass
    return DEFAULT_WEIGHTS, DEFAULT_PARAMETERS


def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates great-circle distance between two GPS coordinates in kilometers."""
    radius_earth_km = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(radius_earth_km * c, 2)


def passes_hard_filters(
    candidate: RecyclerCandidate,
    lot: LotMatchInput,
    distance_km: float,
    current_date: date | None = None,
) -> bool:
    """Evaluates all 3 hard constraints:

    1. Authorization status == 'verified' AND not expired (valid_till > today).
    2. Accepts the specific material category of the lot.
    3. Lot location is within recycler service area OR within pickup_radius_km.
    """
    today = current_date or datetime.now(UTC).date()

    # 1. Authorization status and expiry
    if candidate.authorization_status.lower() != "verified":
        return False

    valid_till = candidate.authorization_valid_till
    if isinstance(valid_till, str):
        try:
            valid_till = date.fromisoformat(valid_till)
        except ValueError:
            return False
    elif isinstance(valid_till, datetime):
        valid_till = valid_till.date()

    if valid_till <= today:
        return False

    # 2. Material category accepted
    accepted_lower = [m.strip().lower() for m in candidate.materials_accepted]
    if lot.category.strip().lower() not in accepted_lower:
        return False

    # 3. Location check: within pickup radius OR within service area
    if candidate.pickup_radius_km > 0 and distance_km <= candidate.pickup_radius_km:
        return True

    service_area = candidate.service_area or {}
    if service_area.get("all") is True or service_area.get("state") == "Maharashtra":
        return True

    # District matching
    lot_dist = (lot.district or "").strip().lower()
    if lot_dist:
        districts = [str(d).strip().lower() for d in service_area.get("districts", [])]
        single_district = str(service_area.get("district", "")).strip().lower()
        if lot_dist in districts or (single_district and lot_dist == single_district):
            return True

    # Service area max distance
    max_dist = service_area.get("max_distance_km")
    if max_dist is not None and distance_km <= float(max_dist):
        return True

    return False


def estimate_pickup_time(pickup_available: bool, distance_km: float) -> str:
    """Generates human-friendly vernacular-compatible pickup time string."""
    if not pickup_available:
        return "Drop-off only (No pickup)"
    if distance_km <= 15.0:
        return "Within 2-4 hours"
    if distance_km <= 50.0:
        return "Same-day pickup (by 6 PM)"
    return "Next business day pickup"


def rank_candidates_rule_based(
    candidates: list[RecyclerCandidate],
    lot: LotMatchInput,
    current_date: date | None = None,
) -> list[RankedRecycler]:
    """Applies hard filters and multi-criteria scoring to rank recyclers deterministically."""
    weights, params = load_scoring_config()

    dist_decay = float(params.get("distance_decay_km", 10.0))
    speed_max = float(params.get("speed_max_hours", 48.0))
    def_comp = float(params.get("default_completion_rate", 0.85))
    def_speed = float(params.get("default_confirmation_hours", 4.0))

    # Evaluate candidates against hard filters
    passing: list[tuple[RecyclerCandidate, float, float]] = []
    for c in candidates:
        dist_km = haversine_distance_km(
            lot.collection_lat, lot.collection_lng, c.latitude, c.longitude
        )
        if passes_hard_filters(c, lot, dist_km, current_date):
            offered_rate = float(c.offered_rates.get(lot.category, 0.0))
            passing.append((c, dist_km, offered_rate))

    if not passing:
        return []

    # Offered rate normalization min/max
    all_rates = [p[2] for p in passing]
    min_rate = min(all_rates)
    max_rate = max(all_rates)

    scored_records: list[tuple[float, float, float, float, str, RecyclerCandidate, ScoreBreakdown]] = []

    for c, dist_km, rate in passing:
        # 1. Normalized offered rate (0.0 to 1.0)
        if max_rate > min_rate:
            norm_rate = (rate - min_rate) / (max_rate - min_rate)
        else:
            norm_rate = 1.0 if rate > 0 else 0.0

        # 2. Normalized inverse distance (closer = higher)
        norm_dist = 1.0 / (1.0 + (dist_km / dist_decay))

        # 3. Pickup availability bonus
        norm_pickup = 1.0 if c.pickup_available else 0.0

        # 4. Completion rate (0.0 to 1.0)
        comp_rate = c.completion_rate if c.completion_rate is not None else def_comp
        norm_comp = max(0.0, min(1.0, float(comp_rate)))

        # 5. Confirmation speed (faster = higher)
        speed_hours = c.confirmation_speed_hours if c.confirmation_speed_hours is not None else def_speed
        norm_speed = max(0.0, 1.0 - (float(speed_hours) / speed_max))

        # 6. Recycler rating (0.0 to 5.0 -> 0.0 to 1.0)
        norm_rating = max(0.0, min(1.0, float(c.rating) / 5.0))

        # Weighted score calculation
        w_rate = float(weights.get("offered_rate", 0.30))
        w_dist = float(weights.get("distance", 0.25))
        w_pickup = float(weights.get("pickup_available", 0.15))
        w_comp = float(weights.get("completion_rate", 0.15))
        w_speed = float(weights.get("confirmation_speed", 0.10))
        w_rating = float(weights.get("rating", 0.05))

        score = (
            w_rate * norm_rate
            + w_dist * norm_dist
            + w_pickup * norm_pickup
            + w_comp * norm_comp
            + w_speed * norm_speed
            + w_rating * norm_rating
        )

        breakdown = ScoreBreakdown(
            offered_rate=round(w_rate * norm_rate, 4),
            distance=round(w_dist * norm_dist, 4),
            pickup_available=round(w_pickup * norm_pickup, 4),
            completion_rate=round(w_comp * norm_comp, 4),
            confirmation_speed=round(w_speed * norm_speed, 4),
            rating=round(w_rating * norm_rating, 4),
        )

        # Stored for tie-breaking:
        # (-score, -rate, dist_km, -rating, candidate.id)
        scored_records.append((round(score, 4), rate, dist_km, float(c.rating), c.id, c, breakdown))

    # Deterministic sorting with tie-breaking
    scored_records.sort(
        key=lambda item: (-item[0], -item[1], item[2], -item[3], item[4])
    )

    ranked_results: list[RankedRecycler] = []
    for rank_idx, (final_score, rate, dist_km, _rating, _cid, candidate, breakdown) in enumerate(
        scored_records[:3], start=1
    ):
        ranked_results.append(
            RankedRecycler(
                recycler_id=candidate.id,
                name=candidate.name,
                phone=candidate.phone,
                rank=rank_idx,
                score=final_score,
                score_breakdown=breakdown,
                distance_km=dist_km,
                offered_rate=rate,
                pickup_available=candidate.pickup_available,
                estimated_pickup_time=estimate_pickup_time(candidate.pickup_available, dist_km),
                authorization_number=candidate.authorization_number,
                rating=candidate.rating,
            )
        )

    return ranked_results
