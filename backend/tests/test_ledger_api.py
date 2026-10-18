"""Tests for Collector Cash Ledger, Summary Totals, Cash Marking, Disputes, and Statements."""

from datetime import UTC, datetime, timedelta
from zoneinfo import ZoneInfo

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


# ---------------------------------------------------------------------------
# Regression: ledger balance bugs (expected to FAIL on current code)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_balance_with_identical_timestamps(async_client: AsyncClient, test_collector):
    """BUG REPRODUCTION: credit and debit posted with the *same* recorded_at.

    Current code orders the balance snapshot by (recorded_at DESC, created_at DESC).
    When both entries share the same recorded_at, the tie-break falls to created_at,
    which may or may not be the credit depending on DB insert order.  More importantly,
    get_summary also uses that ordering to pick current_balance_inr, so if the debit
    row happens to sort first the balance will be returned as 0.0 instead of 3000.0.

    Expected to FAIL with: AssertionError: assert <wrong_value> == 3000.0
    """
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    # Use a single explicit timestamp for both entries
    shared_ts = datetime(2026, 1, 15, 10, 0, 0, tzinfo=UTC).isoformat()

    credit_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "client_entry_id": "dup-ts-credit-001",
            "entry_type": "credit",
            "amount": 3500.0,
            "payment_mode": "cash_received",
            "description": "Credit with shared timestamp",
            "recorded_at": shared_ts,
        },
    )
    assert credit_resp.status_code == 201, credit_resp.text

    debit_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "client_entry_id": "dup-ts-debit-001",
            "entry_type": "debit",
            "amount": 500.0,
            "payment_mode": "cash_received",
            "description": "Debit with shared timestamp",
            "recorded_at": shared_ts,
        },
    )
    assert debit_resp.status_code == 201, debit_resp.text

    sum_resp = await async_client.get("/api/v1/ledger/summary", headers=headers)
    assert sum_resp.status_code == 200
    summary = sum_resp.json()
    # This assertion is expected to FAIL on the current implementation
    assert summary["current_balance_inr"] == 3000.0, (
        f"Balance wrong with identical timestamps: got {summary['current_balance_inr']}"
    )


@pytest.mark.asyncio
async def test_balance_with_late_offline_entry(async_client: AsyncClient, test_collector):
    """BUG REPRODUCTION: debit arrives from an offline phone with an earlier recorded_at.

    Scenario:
      - Credit of 3500 at 10:00 posted first (server receives at t1).
      - Debit of 500 arrives later from an offline phone but carries recorded_at=09:00.

    Because create_entry reads the running balance ordered by recorded_at DESC, when the
    debit (09:00) is inserted it finds the credit (10:00) as the latest — correct so far.
    But get_summary then calls the same query to derive current_balance_inr, and the debit
    at 09:00 sorts *earlier* than the credit at 10:00, so it returns the credit's
    balance_after (3500) instead of the debit's (3000).

    Additionally the entries list must reflect server receive order (credit first, debit
    second) rather than recorded_at order.

    Expected to FAIL with: AssertionError: assert 3500.0 == 3000.0
    """
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    credit_ts = datetime(2026, 1, 15, 10, 0, 0, tzinfo=UTC).isoformat()  # 10:00
    debit_ts = datetime(2026, 1, 15, 9, 0, 0, tzinfo=UTC).isoformat()   # 09:00  (earlier!)

    # Step 1: post credit at 10:00
    credit_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "client_entry_id": "late-credit-001",
            "entry_type": "credit",
            "amount": 3500.0,
            "payment_mode": "cash_received",
            "description": "Online credit at 10:00",
            "recorded_at": credit_ts,
        },
    )
    assert credit_resp.status_code == 201, credit_resp.text
    assert credit_resp.json()["balance_after"] == 3500.0

    # Step 2: post debit at 09:00 (late offline sync, earlier client timestamp)
    debit_resp = await async_client.post(
        "/api/v1/ledger/entries",
        headers=headers,
        json={
            "client_entry_id": "late-debit-001",
            "entry_type": "debit",
            "amount": 500.0,
            "payment_mode": "cash_received",
            "description": "Offline debit synced late, recorded_at=09:00",
            "recorded_at": debit_ts,
        },
    )
    assert debit_resp.status_code == 201, debit_resp.text

    # The summary balance must be 3000 (credit 3500 − debit 500)
    sum_resp = await async_client.get("/api/v1/ledger/summary", headers=headers)
    assert sum_resp.status_code == 200
    summary = sum_resp.json()
    # Expected to FAIL: current code returns 3500.0 because it picks the credit row
    # (recorded_at 10:00 > 09:00) as the "latest" balance snapshot
    assert summary["current_balance_inr"] == 3000.0, (
        f"Balance wrong after late offline entry: got {summary['current_balance_inr']}"
    )

    # Entries list must be in server-receive order: credit first, debit second
    list_resp = await async_client.get("/api/v1/ledger/entries", headers=headers)
    assert list_resp.status_code == 200
    entries = list_resp.json()
    assert len(entries) == 2
    # Current code orders by recorded_at DESC, so it would put debit (09:00) last
    # and credit (10:00) first — this part may pass, but the balance is still wrong.
    entry_types = [e["entry_type"] for e in entries]
    assert entry_types == ["credit", "debit"], (
        f"Entry order should be server-receive order (credit then debit), got: {entry_types}"
    )
