"""Pytest suite for Recycler Discovery and Matching Engine core scoring."""

import json
from pathlib import Path

import pytest

from app.matching.reranker import LearnedReranker
from app.matching.schemas import LotMatchInput, RecyclerCandidate
from app.matching.scoring import (
    haversine_distance_km,
    rank_candidates_rule_based,
)

FIXTURE_PATH = Path(__file__).parent / "fixtures" / "matching_fixture.json"


def _make_candidate(
    cid: str = "rec-1",
    name: str = "Test Recycler",
    status: str = "verified",
    valid_till: str = "2030-01-01",
    materials: list[str] | None = None,
    lat: float = 19.0760,
    lng: float = 72.8777,
    rate: float = 400.0,
    category: str = "PCB",
    pickup: bool = True,
    pickup_radius_km: float = 20.0,
    service_area: dict | None = None,
    rating: float = 4.5,
    completion_rate: float = 0.90,
    confirmation_speed: float = 2.0,
) -> RecyclerCandidate:
    return RecyclerCandidate(
        id=cid,
        name=name,
        latitude=lat,
        longitude=lng,
        materials_accepted=materials or ["PCB", "Batteries"],
        authorization_status=status,
        authorization_valid_till=valid_till,
        phone="+919800000000",
        offered_rates={category: rate},
        pickup_available=pickup,
        pickup_radius_km=pickup_radius_km,
        service_area=service_area or {"districts": ["Mumbai"]},
        rating=rating,
        completion_rate=completion_rate,
        confirmation_speed_hours=confirmation_speed,
    )


def test_haversine_distance():
    # Distance between Mumbai (19.0760, 72.8777) and Pune (18.5204, 73.8567) is ~120 km
    d = haversine_distance_km(19.0760, 72.8777, 18.5204, 73.8567)
    assert 115.0 <= d <= 125.0

    # Distance to identical point is 0.0
    assert haversine_distance_km(19.0760, 72.8777, 19.0760, 72.8777) == 0.0


def test_no_verified_recyclers():
    lot = LotMatchInput(category="PCB", collection_lat=19.0760, collection_lng=72.8777)
    candidates = [
        _make_candidate(cid="rec-pending", status="pending"),
        _make_candidate(cid="rec-suspended", status="suspended"),
        _make_candidate(cid="rec-expired", status="expired"),
        _make_candidate(cid="rec-past-date", status="verified", valid_till="2020-01-01"),
    ]
    ranked = rank_candidates_rule_based(candidates, lot)
    assert len(ranked) == 0


def test_category_mismatch_excluded():
    lot = LotMatchInput(
        category="Lithium Batteries", collection_lat=19.0760, collection_lng=72.8777
    )
    candidates = [
        _make_candidate(cid="rec-cables", materials=["Copper Cables", "Mixed Plastics"]),
        _make_candidate(cid="rec-crt", materials=["CRT Glass", "LCD Panels"]),
    ]
    ranked = rank_candidates_rule_based(candidates, lot)
    assert len(ranked) == 0


def test_distance_and_service_area_filter():
    lot = LotMatchInput(
        category="PCB",
        collection_lat=19.0760,
        collection_lng=72.8777,
        district="Mumbai",
    )
    # 1. Beyond pickup radius and outside service area
    c_distant = _make_candidate(
        cid="rec-distant",
        lat=18.5204,
        lng=73.8567,  # ~120 km
        pickup_radius_km=25.0,
        service_area={"districts": ["Pune"]},
    )
    # 2. Within pickup radius (pickup_radius_km = 150 km)
    c_wide_radius = _make_candidate(
        cid="rec-wide",
        lat=18.5204,
        lng=73.8567,
        pickup_radius_km=150.0,
        service_area={},
    )
    # 3. Within service area
    c_service_area = _make_candidate(
        cid="rec-service",
        lat=19.1000,
        lng=72.9000,
        pickup_radius_km=0.0,
        service_area={"districts": ["Mumbai"]},
    )

    ranked = rank_candidates_rule_based([c_distant, c_wide_radius, c_service_area], lot)
    ids = [r.recycler_id for r in ranked]
    assert "rec-distant" not in ids
    assert "rec-wide" in ids
    assert "rec-service" in ids


def test_score_ordering():
    lot = LotMatchInput(
        category="PCB", collection_lat=19.0760, collection_lng=72.8777, district="Mumbai"
    )
    # c_premium has higher rate, closer distance, pickup, higher rating, speed
    c_premium = _make_candidate(
        cid="rec-top",
        lat=19.0800,
        lng=72.8800,
        rate=500.0,
        pickup=True,
        rating=4.9,
        completion_rate=0.98,
        confirmation_speed=1.0,
    )
    c_mediocre = _make_candidate(
        cid="rec-low",
        lat=19.1500,
        lng=72.9500,
        rate=350.0,
        pickup=False,
        rating=3.2,
        completion_rate=0.70,
        confirmation_speed=12.0,
    )

    ranked = rank_candidates_rule_based([c_mediocre, c_premium], lot)
    assert len(ranked) == 2
    assert ranked[0].recycler_id == "rec-top"
    assert ranked[0].rank == 1
    assert ranked[0].score > ranked[1].score


def test_deterministic_tie_breaking():
    lot = LotMatchInput(
        category="PCB", collection_lat=19.0760, collection_lng=72.8777, district="Mumbai"
    )
    # Two candidates with identical scores and properties except ID
    c1 = _make_candidate(cid="rec-A", rate=400.0, lat=19.0800, lng=72.8800, rating=4.5)
    c2 = _make_candidate(cid="rec-B", rate=400.0, lat=19.0800, lng=72.8800, rating=4.5)

    ranked = rank_candidates_rule_based([c2, c1], lot)
    assert len(ranked) == 2
    assert ranked[0].score == ranked[1].score
    # Tie-break sorts lexicographically on ID -> rec-A first
    assert ranked[0].recycler_id == "rec-A"
    assert ranked[1].recycler_id == "rec-B"


def test_shared_fixture_reproducibility():
    assert FIXTURE_PATH.exists(), f"Shared test fixture not found at {FIXTURE_PATH}"
    with open(FIXTURE_PATH, encoding="utf-8") as f:
        fixture_data = json.load(f)

    lot = LotMatchInput(**fixture_data["lot"])
    candidates = [RecyclerCandidate(**c) for c in fixture_data["candidates"]]
    expected_rankings = fixture_data["expected_rankings"]

    ranked = rank_candidates_rule_based(candidates, lot)
    assert len(ranked) == len(expected_rankings)

    for actual, expected in zip(ranked, expected_rankings, strict=False):
        assert actual.rank == expected["rank"]
        assert actual.recycler_id == expected["recycler_id"]
        assert pytest.approx(actual.score, rel=1e-3) == expected["score"]
        assert pytest.approx(actual.offered_rate, rel=1e-3) == expected["offered_rate"]
        assert actual.pickup_available == expected["pickup_available"]
        assert actual.estimated_pickup_time == expected["estimated_pickup_time"]

        # Check score breakdown
        actual_bd = actual.score_breakdown.model_dump()
        expected_bd = expected["score_breakdown"]
        for key in expected_bd:
            assert pytest.approx(actual_bd[key], rel=1e-3) == expected_bd[key]


def test_learned_reranker_fallback_under_50():
    lot = LotMatchInput(
        category="PCB", collection_lat=19.0760, collection_lng=72.8777, district="Mumbai"
    )
    candidates = [_make_candidate(cid="rec-1"), _make_candidate(cid="rec-2")]
    reranker = LearnedReranker(min_training_records=50)

    # 30 records < 50 threshold -> must fallback to rule_based
    history_30 = [{"features": [0.5] * 6, "label": 1} for _ in range(30)]
    ranked, algo = reranker.rank_recyclers(candidates, lot, history_30)

    assert algo == "rule_based"
    assert len(ranked) == 2


def test_learned_reranker_trains_at_50_records():
    lot = LotMatchInput(
        category="PCB", collection_lat=19.0760, collection_lng=72.8777, district="Mumbai"
    )
    candidates = [
        _make_candidate(cid="rec-1", rate=450.0),
        _make_candidate(cid="rec-2", rate=480.0),
    ]
    reranker = LearnedReranker(min_training_records=50)

    # 55 records >= 50 -> trains LightGBM
    history_55 = [{"features": [0.8, 0.9, 1.0, 0.95, 0.9, 0.9], "label": 1} for _ in range(35)] + [
        {"features": [0.2, 0.1, 0.0, 0.4, 0.2, 0.3], "label": 0} for _ in range(20)
    ]

    ranked, algo = reranker.rank_recyclers(candidates, lot, history_55)
    assert algo == "lightgbm"
    assert len(ranked) == 2
