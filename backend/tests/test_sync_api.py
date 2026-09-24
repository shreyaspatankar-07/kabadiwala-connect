"""Tests for Offline-first Sync Push and Pull APIs."""

from datetime import UTC, datetime

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_offline_sync_push_and_pull(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    client_time = datetime.now(UTC).isoformat()
    push_payload = {
        "operations": [
            {
                "client_tx_id": "op-batch-lot-001",
                "action": "create_lot",
                "payload": {
                    "client_lot_id": "op-batch-lot-001",
                    "category": "battery",
                    "weight_kg": 12.0,
                    "quoted_price": 2400.0,
                    "collection_lat": 19.0760,
                    "collection_lng": 72.8777,
                },
                "client_timestamp": client_time,
            },
            {
                "client_tx_id": "op-batch-pay-002",
                "action": "record_cash_payment",
                "payload": {
                    "client_entry_id": "op-batch-pay-002",
                    "entry_type": "credit",
                    "amount": 2400.0,
                    "payment_mode": "cash_received",
                    "description": "Cash payment for offline batch lot",
                },
                "client_timestamp": client_time,
            },
        ]
    }

    # 1. First Push
    push_resp = await async_client.post(
        "/api/v1/sync/push",
        headers=headers,
        json=push_payload,
    )
    assert push_resp.status_code == 200
    push_data = push_resp.json()
    assert "op-batch-lot-001" in push_data["processed"]
    assert "op-batch-pay-002" in push_data["processed"]

    # 2. Replay same batch (Idempotency test!)
    replay_resp = await async_client.post(
        "/api/v1/sync/push",
        headers=headers,
        json=push_payload,
    )
    assert replay_resp.status_code == 200
    replay_data = replay_resp.json()
    assert "op-batch-lot-001" in replay_data["processed"]
    assert "op-batch-pay-002" in replay_data["processed"]
    assert len(replay_data["conflicts"]) == 0

    # 3. Pull delta
    pull_resp = await async_client.get("/api/v1/sync/pull", headers=headers)
    assert pull_resp.status_code == 200
    pull_data = pull_resp.json()
    assert "cursor" in pull_data
    assert len(pull_data["my_lots"]) >= 1
    assert len(pull_data["my_ledger"]) >= 1
