"""Tests for Collector Cash Ledger, Summary Totals, Cash Marking, Disputes, and Statements."""

from datetime import UTC, datetime, timedelta

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


@pytest.mark.asyncio
async def test_ledger_overview_and_pending_dues(async_client: AsyncClient, test_collector):
    _, collector_token = test_collector
    headers = {"Authorization": f"Bearer {collector_token}"}

    # 1. Create a lot
    lot_payload = {
        "client_lot_id": "lot-test-uuid-001",
        "category": "batteries",
        "weight_kg": 15.0,
        "quoted_price": 1800.0,
        "collection_lat": 19.0760,
        "collection_lng": 72.8777,
        "photo_hashes": ["hash_batt_1"],
    }
    lot_resp = await async_client.post("/api/v1/lots", headers=headers, json=lot_payload)
    assert lot_resp.status_code == 201
    lot_id = lot_resp.json()["lot_id"]

    # 2. Record a pending credit in ledger
    credit_payload = {
        "lot_id": lot_id,
        "entry_type": "credit",
        "amount": 1800.0,
        "payment_mode": "pending",
        "description": f"Credit for Lot {lot_id} pending payment",
    }
    entry_resp = await async_client.post(
        "/api/v1/ledger/entries", headers=headers, json=credit_payload
    )
    assert entry_resp.status_code == 201
    entry_id = entry_resp.json()["id"]

    # 3. Query GET /ledger
    overview_resp = await async_client.get("/ledger", headers=headers)
    assert overview_resp.status_code == 200
    data = overview_resp.json()

    assert data["collector_id"] == "KC-C-TEST01"
    assert data["today_total"] >= 1800.0
    assert data["week_total"] >= 1800.0
    assert data["month_total"] >= 1800.0
    assert data["all_time_total"] >= 1800.0
    assert data["pending_dues_count"] >= 1
    assert data["pending_dues_amount"] >= 1800.0
    assert len(data["transactions"]) >= 1

    # Check transaction item details
    tx_item = next((tx for tx in data["transactions"] if tx["entry_id"] == entry_id), None)
    assert tx_item is not None
    assert tx_item["lot_id"] == lot_id
    assert tx_item["category"].lower() == "batteries"
    assert tx_item["weight_kg"] == 15.0
    assert tx_item["final_price"] == 1800.0
    assert tx_item["payment_status"] == "pending"


@pytest.mark.asyncio
async def test_mark_cash_received_and_recycler_dispute(
    async_client: AsyncClient, test_collector, test_recycler_user
):
    _, collector_token = test_collector
    collector_headers = {"Authorization": f"Bearer {collector_token}"}
    _, recycler_token = test_recycler_user
    recycler_headers = {"Authorization": f"Bearer {recycler_token}"}

    # 1. Create a lot and pending ledger entry
    lot_resp = await async_client.post(
        "/api/v1/lots",
        headers=collector_headers,
        json={
            "client_lot_id": "lot-test-uuid-002",
            "category": "pcb",
            "weight_kg": 10.0,
            "quoted_price": 4000.0,
            "collection_lat": 19.0760,
            "collection_lng": 72.8777,
            "photo_hashes": ["hash_pcb_1"],
        },
    )
    assert lot_resp.status_code == 201
    lot_id = lot_resp.json()["lot_id"]

    entry_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=collector_headers,
        json={
            "lot_id": lot_id,
            "entry_type": "credit",
            "amount": 4000.0,
            "payment_mode": "pending",
            "description": f"Pending cash for Lot {lot_id}",
        },
    )
    assert entry_resp.status_code == 201
    entry_id = entry_resp.json()["id"]

    # 2. Collector marks cash as received
    mark_resp = await async_client.post(
        f"/ledger/{entry_id}/mark-cash-received",
        headers=collector_headers,
    )
    assert mark_resp.status_code == 200
    mark_data = mark_resp.json()
    assert mark_data["payment_status"] == "cash_received"
    assert mark_data["collector_confirmed"] is True
    assert mark_data["is_disputed"] is False

    # 3. Recycler confirms amount mismatch -> triggers dispute!
    dispute_resp = await async_client.post(
        f"/ledger/{entry_id}/recycler-confirm-cash",
        headers=recycler_headers,
        json={"recycler_confirmed_amount": 3200.0},  # Collector said 4000, recycler paid 3200
    )
    assert dispute_resp.status_code == 200
    dispute_data = dispute_resp.json()
    assert dispute_data["is_disputed"] is True
    assert dispute_data["payment_status"] == "disputed"
    assert "mismatch" in dispute_data["dispute_reason"].lower()


@pytest.mark.asyncio
async def test_earnings_statement_export(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    # Record some transactions
    await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "entry_type": "credit",
            "amount": 2500.0,
            "payment_mode": "cash_received",
            "description": "Sale of CRT monitor glass",
        },
    )

    now = datetime.now(UTC)
    start = (now - timedelta(days=1)).isoformat()
    end = (now + timedelta(days=1)).isoformat()

    # Query statement
    stmt_resp = await async_client.get(
        f"/ledger/statement?from={start}&to={end}",
        headers=headers,
    )
    assert stmt_resp.status_code == 200
    data = stmt_resp.json()

    assert data["collector_id"] == "KC-C-TEST01"
    assert data["statement_ref_no"].startswith("STMT-KC-")
    assert data["total_earned"] >= 2500.0
    assert data["cash_received"] >= 2500.0
    assert data["total_transactions"] >= 1
    assert len(data["items"]) >= 1


@pytest.mark.asyncio
async def test_optional_upi_intent(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    entry_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "entry_type": "credit",
            "amount": 1250.0,
            "payment_mode": "pending",
            "description": "Sale of 5kg copper cables",
        },
    )
    assert entry_resp.status_code == 201
    entry_id = entry_resp.json()["id"]

    upi_resp = await async_client.post(
        f"/ledger/{entry_id}/upi-intent",
        headers=headers,
    )
    assert upi_resp.status_code == 200
    upi_data = upi_resp.json()
    assert upi_data["entry_id"] == entry_id
    assert upi_data["amount"] == 1250.0
    assert upi_data["upi_uri"].startswith("upi://pay?")
    assert "am=1250.00" in upi_data["upi_uri"]
    assert "cu=INR" in upi_data["upi_uri"]
