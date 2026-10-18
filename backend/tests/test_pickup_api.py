"""Tests for Citizen Doorstep Pickup & Spatial Dispatching API."""

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.pickup import PickupStatus
from app.models.schema import User


@pytest.mark.asyncio
async def test_pickup_full_lifecycle(
    async_client: AsyncClient,
    db_session: AsyncSession,
    test_collector: tuple[User, str],
):
    _, collector_token = test_collector
    collector_headers = {"Authorization": f"Bearer {collector_token}"}

    # Amravati coordinates
    citizen_lat = 20.9320
    citizen_lng = 77.7523

    # 1. Citizen creates pickup request (Zero-registration)
    create_payload = {
        "lat": citizen_lat,
        "lng": citizen_lng,
        "address": "Camp Road, Amravati, Maharashtra",
        "categories": ["CABLES", "BATTERIES", "PCB"],
        "photos": ["https://images.unsplash.com/photo-cables.jpg"],
        "phone": "+919876543210",
        "otp": "123456",
        "preferred_time_slot": "Morning 9 AM - 12 PM",
    }
    create_resp = await async_client.post("/api/v1/pickup/create", json=create_payload)
    assert create_resp.status_code == 201, create_resp.text
    created_data = create_resp.json()

    assert created_data["status"] == "CREATED"
    public_code = created_data["public_code"]
    request_id = created_data["id"]
    assert public_code.startswith("PR-MH-")
    assert "CABLES" in created_data["categories"]

    # 2. Citizen tracks their request
    track_resp = await async_client.get(f"/api/v1/pickup/track/{public_code}")
    assert track_resp.status_code == 200
    track_data = track_resp.json()
    assert track_data["status"] == "CREATED"
    assert track_data["collector_assigned"] is False

    # 3. Collector searches nearby (within 2.5 km: ~500m away at 20.9350, 77.7530)
    nearby_resp = await async_client.get(
        "/api/v1/pickup/nearby",
        params={"lat": 20.9350, "lng": 77.7530, "radius_meters": 2500},
        headers=collector_headers,
    )
    assert nearby_resp.status_code == 200, nearby_resp.text
    nearby_data = nearby_resp.json()
    assert len(nearby_data) >= 1
    found = next((item for item in nearby_data if item["public_code"] == public_code), None)
    assert found is not None
    assert found["estimated_distance_km"] is not None
    assert found["estimated_distance_km"] < 2.5

    # 4. Collector far away (>10 km: at 21.0500, 77.8500) does NOT see it
    far_resp = await async_client.get(
        "/api/v1/pickup/nearby",
        params={"lat": 21.0500, "lng": 77.8500, "radius_meters": 2500},
        headers=collector_headers,
    )
    assert far_resp.status_code == 200
    far_found = [item for item in far_resp.json() if item["public_code"] == public_code]
    assert len(far_found) == 0

    # 5. Collector accepts the pickup
    accept_resp = await async_client.post(
        f"/api/v1/pickup/{request_id}/accept",
        headers=collector_headers,
    )
    assert accept_resp.status_code == 200, accept_resp.text
    accepted_data = accept_resp.json()
    assert accepted_data["status"] == "ACCEPTED"

    # 6. Citizen tracker shows Collector Assigned & ETA
    track_resp_2 = await async_client.get(f"/api/v1/pickup/track/{public_code}")
    assert track_resp_2.status_code == 200
    track_data_2 = track_resp_2.json()
    assert track_data_2["status"] == "ACCEPTED"
    assert track_data_2["collector_assigned"] is True
    assert "ETA" in track_data_2["arrival_eta"] or "5–10" in track_data_2["arrival_eta"]

    # 7. Collector marks Arrived
    arrived_resp = await async_client.post(
        f"/api/v1/pickup/{request_id}/arrived",
        headers=collector_headers,
    )
    assert arrived_resp.status_code == 200
    assert arrived_resp.json()["status"] == "ARRIVED"

    # 8. Collector marks Completed with offline lot id
    complete_resp = await async_client.post(
        f"/api/v1/pickup/{request_id}/complete",
        json={"lot_id": "KC-MH-2610-TEST01"},
        headers=collector_headers,
    )
    assert complete_resp.status_code == 200
    assert complete_resp.json()["status"] == "COMPLETED"

    # Final track check
    final_track = await async_client.get(f"/api/v1/pickup/track/{public_code}")
    assert final_track.json()["status"] == "COMPLETED"


@pytest.mark.asyncio
async def test_pickup_not_found_and_conflict(
    async_client: AsyncClient,
    test_collector: tuple[User, str],
):
    _, collector_token = test_collector
    collector_headers = {"Authorization": f"Bearer {collector_token}"}

    # 404 on invalid public code
    resp = await async_client.get("/api/v1/pickup/track/PR-INVALID-999")
    assert resp.status_code == 404

    # 400 on invalid OTP
    bad_create = await async_client.post(
        "/api/v1/pickup/create",
        json={
            "lat": 20.9320,
            "lng": 77.7523,
            "phone": "+919876543210",
            "otp": "1",  # Too short
        },
    )
    assert bad_create.status_code == 400
