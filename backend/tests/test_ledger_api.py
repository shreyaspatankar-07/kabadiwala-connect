"""Tests for Collector Cash Ledger and Balance Summary."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_ledger_entries_and_summary(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Record credit entry (earned from scrap sale)
    credit_payload = {
        "client_entry_id": "tx-entry-001",
        "entry_type": "credit",
        "amount": 3500.0,
        "payment_mode": "cash_received",
        "description": "Cash received for 20kg PCB scrap",
    }
    c_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json=credit_payload,
    )
    assert c_resp.status_code == 201
    c_data = c_resp.json()
    assert c_data["amount"] == 3500.0
    assert c_data["balance_after"] == 3500.0

    # 2. Record debit entry
    debit_payload = {
        "client_entry_id": "tx-entry-002",
        "entry_type": "debit",
        "amount": 500.0,
        "payment_mode": "cash_received",
        "description": "Cart transport fuel expense",
    }
    d_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json=debit_payload,
    )
    assert d_resp.status_code == 201
    assert d_resp.json()["balance_after"] == 3000.0

    # 3. List ledger entries
    list_resp = await async_client.get("/api/v1/ledger/entries", headers=headers)
    assert list_resp.status_code == 200
    entries = list_resp.json()
    assert len(entries) == 2

    # 4. Get ledger summary
    sum_resp = await async_client.get("/api/v1/ledger/summary", headers=headers)
    assert sum_resp.status_code == 200
    summary = sum_resp.json()
    assert summary["collector_id"] == "KC-C-TEST01"
    assert summary["total_earned_inr"] == 3500.0
    assert summary["cash_received_inr"] == 3500.0
    assert summary["current_balance_inr"] == 3000.0
    assert summary["total_transactions"] == 2
