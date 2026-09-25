"""API tests for Recycler Discovery and Matching endpoints."""

from datetime import date, timedelta

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_matching_rank_api_flow(async_client: AsyncClient, test_admin):
    _, admin_token = test_admin
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    valid_till = (date.today() + timedelta(days=365)).isoformat()

    # 1. Seed two verified recyclers in DB
    rec1_payload = {
        "id": "REC-MATCH-01",
        "name": "Mumbai Alpha Recyclers",
        "latitude": 19.0800,
        "longitude": 72.8800,
        "materials_accepted": ["PCB", "Batteries"],
        "authorization_number": "CPCB/AUTH/MATCH/01",
        "authorization_body": "CPCB",
        "authorization_valid_till": valid_till,
        "phone": "+919820000001",
        "offered_rates": {"PCB": 450.0},
        "pickup_available": True,
        "pickup_radius_km": 20.0,
        "service_area": {"districts": ["Mumbai"]},
        "rating": 4.8,
    }
    rec2_payload = {
        "id": "REC-MATCH-02",
        "name": "Mumbai Beta Scrap Hub",
        "latitude": 19.1200,
        "longitude": 72.9000,
        "materials_accepted": ["PCB"],
        "authorization_number": "SPCB/AUTH/MATCH/02",
        "authorization_body": "SPCB",
        "authorization_valid_till": valid_till,
        "phone": "+919820000002",
        "offered_rates": {"PCB": 420.0},
        "pickup_available": False,
        "pickup_radius_km": 0.0,
        "service_area": {"districts": ["Mumbai"]},
        "rating": 4.0,
    }

    c1 = await async_client.post("/api/v1/recyclers", headers=admin_headers, json=rec1_payload)
    assert c1.status_code == 201
    await async_client.post("/api/v1/recyclers/REC-MATCH-01/verify", headers=admin_headers)

    c2 = await async_client.post("/api/v1/recyclers", headers=admin_headers, json=rec2_payload)
    assert c2.status_code == 201
    await async_client.post("/api/v1/recyclers/REC-MATCH-02/verify", headers=admin_headers)

    # 2. Test POST /matching/rank (and /api/v1/matching/rank)
    lot_req = {
        "category": "PCB",
        "weight_kg": 15.0,
        "collection_lat": 19.0760,
        "collection_lng": 72.8777,
        "district": "Mumbai",
        "lot_id": "LOT-API-TEST-01",
    }

    rank_resp = await async_client.post("/matching/rank", json=lot_req)
    assert rank_resp.status_code == 200
    data = rank_resp.json()
    assert data["category"] == "PCB"
    assert len(data["candidates"]) >= 2
    # REC-MATCH-01 should rank #1 due to higher price, closer distance, pickup available, higher rating
    top = data["candidates"][0]
    assert top["rank"] == 1
    assert top["recycler_id"] == "REC-MATCH-01"
    assert top["offered_rate"] == 450.0
    assert top["pickup_available"] is True
    assert "score_breakdown" in top

    # Also test via /api/v1 prefix
    v1_resp = await async_client.post("/api/v1/matching/rank", json=lot_req)
    assert v1_resp.status_code == 200
    assert len(v1_resp.json()["candidates"]) == len(data["candidates"])


@pytest.mark.asyncio
async def test_recyclers_nearby_api(async_client: AsyncClient, test_admin):
    _, admin_token = test_admin
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    valid_till = (date.today() + timedelta(days=365)).isoformat()

    rec_payload = {
        "id": "REC-NEARBY-01",
        "name": "Mumbai Alpha Recyclers",
        "latitude": 19.0800,
        "longitude": 72.8800,
        "materials_accepted": ["PCB", "Batteries"],
        "authorization_number": "CPCB/AUTH/NEARBY/01",
        "authorization_body": "CPCB",
        "authorization_valid_till": valid_till,
        "phone": "+919820000001",
        "offered_rates": {"PCB": 450.0},
        "pickup_available": True,
        "pickup_radius_km": 20.0,
        "service_area": {"districts": ["Mumbai"]},
        "rating": 4.8,
    }
    c = await async_client.post("/api/v1/recyclers", headers=admin_headers, json=rec_payload)
    assert c.status_code == 201
    await async_client.post("/api/v1/recyclers/REC-NEARBY-01/verify", headers=admin_headers)

    # Test GET /recyclers/nearby and /api/v1/recyclers/nearby
    nearby_resp = await async_client.get(
        "/recyclers/nearby?lat=19.0760&lng=72.8777&radius_km=25.0&category=PCB"
    )
    assert nearby_resp.status_code == 200
    results = nearby_resp.json()
    assert isinstance(results, list)
    assert len(results) >= 1
    for r in results:
        assert "distance_km" in r
        assert r["distance_km"] <= 25.0
        assert "PCB" in r["materials_accepted"]
        assert r["authorization_status"] == "verified"

    # Also test via /api/v1/recyclers/nearby
    v1_nearby = await async_client.get(
        "/api/v1/recyclers/nearby?lat=19.0760&lng=72.8777&radius_km=5.0"
    )
    assert v1_nearby.status_code == 200
    assert isinstance(v1_nearby.json(), list)
