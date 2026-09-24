"""Tests for Lots (Transactions) API and offline idempotency."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_lot_creation_and_idempotency(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    lot_payload = {
        "client_lot_id": "c1f7a83b-9a81-4b13-98fe-08201b16e492",
        "category": "pcb",
        "weight_kg": 18.5,
        "quoted_price": 2775.0,
        "collection_lat": 19.0760,
        "collection_lng": 72.8777,
        "photo_hashes": ["e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"],
    }

    # 1. Create lot initially
    first_resp = await async_client.post(
        "/api/v1/lots",
        headers=headers,
        json=lot_payload,
    )
    assert first_resp.status_code == 201
    first_data = first_resp.json()
    lot_id = first_data["lot_id"]
    assert first_data["collector_id"] == "KC-C-TEST01"
    assert first_data["quoted_price"] == 2775.0

    # 2. Replay request with exact same client_lot_id (Idempotency test!)
    second_resp = await async_client.post(
        "/api/v1/lots",
        headers=headers,
        json=lot_payload,
    )
    assert second_resp.status_code in (200, 201)
    second_data = second_resp.json()
    # Must return identical lot ID without creating a duplicate!
    assert second_data["lot_id"] == lot_id

    # 3. List lots for collector
    list_resp = await async_client.get("/api/v1/lots", headers=headers)
    assert list_resp.status_code == 200
    lots = list_resp.json()
    # Assert only 1 lot exists, not duplicated!
    assert len(lots) == 1
    assert lots[0]["lot_id"] == lot_id

    # 4. Update lot status to matched
    update_resp = await async_client.patch(
        f"/api/v1/lots/{lot_id}/status",
        headers=headers,
        json={"transaction_status": "matched", "final_price": 2800.0},
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["transaction_status"] == "matched"
    assert update_resp.json()["final_price"] == 2800.0
