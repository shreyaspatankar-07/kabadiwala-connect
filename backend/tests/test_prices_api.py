"""Tests for Prices, Regional Price Board, Sparkline History, and Field Reporting API."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_prices_crud_and_price_board(async_client: AsyncClient, test_admin):
    _, admin_token = test_admin
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    price_payload = {
        "category": "pcb",
        "sub_category": "grade_a",
        "district": "Mumbai Suburban",
        "city": "Andheri East",
        "latitude": 19.1136,
        "longitude": 72.8697,
        "buying_price": 150.0,
        "selling_quoted_price": 165.0,
        "unit": "kg",
        "market_min": 140.0,
        "market_max": 170.0,
        "source": "synthetic",
    }

    # 1. Create price entry
    create_resp = await async_client.post(
        "/api/v1/prices",
        headers=admin_headers,
        json=price_payload,
    )
    assert create_resp.status_code == 201
    p_data = create_resp.json()
    price_id = p_data["id"]
    assert p_data["buying_price"] == 150.0

    # 2. List prices
    list_resp = await async_client.get("/api/v1/prices?district=Mumbai")
    assert list_resp.status_code == 200
    assert len(list_resp.json()) >= 1

    # 3. Get Price Board for district
    board_resp = await async_client.get("/api/v1/prices/board?district=Mumbai Suburban")
    assert board_resp.status_code == 200
    board = board_resp.json()
    assert board["district"] == "Mumbai Suburban"
    assert len(board["rates"]) >= 1
    rate = board["rates"][0]
    assert rate["category"] == "pcb"
    assert rate["min_rate_inr"] == 140.0
    assert rate["max_rate_inr"] == 170.0
    assert "current_buying_price" in rate
    assert "trend_7d" in rate
    assert "confidence_level" in rate
    assert "last_updated" in rate

    # 4. Get by ID
    get_resp = await async_client.get(f"/api/v1/prices/{price_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == price_id


@pytest.mark.asyncio
async def test_price_board_category_filter_and_metrics(async_client: AsyncClient, test_admin):
    """Test /prices/board?district=&category= returns rolling aggregation metrics."""
    _, admin_token = test_admin
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # Seed copper cable price
    await async_client.post(
        "/api/v1/prices",
        headers=admin_headers,
        json={
            "category": "cables (copper)",
            "sub_category": "thick",
            "district": "Palghar",
            "city": "Vasai",
            "latitude": 19.3919,
            "longitude": 72.8397,
            "buying_price": 680.0,
            "selling_quoted_price": 710.0,
            "unit": "kg",
            "market_min": 650.0,
            "market_max": 730.0,
            "source": "synthetic",
        },
    )

    resp = await async_client.get("/api/v1/prices/board?district=Palghar&category=cables (copper)")
    assert resp.status_code == 200
    data = resp.json()
    assert data["district"] == "Palghar"
    assert data["category"] == "cables (copper)"
    assert data["current_buying_price"] == 680.0
    assert data["market_min"] == 650.0
    assert data["market_max"] == 730.0
    assert data["recycler_offered_price"] == 710.0
    assert data["trend_7d"] in ("up", "down", "flat")
    assert isinstance(data["pct_change_7d"], (int, float))
    assert data["confidence_level"] in ("high", "medium", "low")
    assert data["last_updated"] is not None


@pytest.mark.asyncio
async def test_price_history_sparkline(async_client: AsyncClient):
    """Test /prices/history?district=&category=&days=30 returns daily points for sparkline."""
    resp = await async_client.get(
        "/api/v1/prices/history?district=Palghar&category=cables (copper)&days=30"
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["district"] == "Palghar"
    assert data["category"] == "cables (copper)"
    assert data["days"] == 30
    assert len(data["history"]) == 30

    first_point = data["history"][0]
    assert "date" in first_point
    assert "median_price" in first_point
    assert "min_price" in first_point
    assert "max_price" in first_point
    assert first_point["median_price"] > 0


@pytest.mark.asyncio
async def test_collector_price_reporting_flow(async_client: AsyncClient):
    """Test POST /prices/report allows collectors to report field prices with validation."""
    # 1. Valid collector report
    valid_report = {
        "category": "cables (copper)",
        "sub_category": "wire",
        "district": "Palghar",
        "city": "Dahanu",
        "latitude": 19.9700,
        "longitude": 72.7300,
        "offered_price": 670.0,
        "unit": "kg",
        "notes": "Offered by local scrap aggregator near station",
    }
    resp = await async_client.post("/api/v1/prices/report", json=valid_report)
    assert resp.status_code == 201
    rep_data = resp.json()
    assert rep_data["category"] == "cables (copper)"
    assert rep_data["offered_price"] == 670.0
    assert rep_data["source"] == "collector_report"
    assert rep_data["is_flagged_for_review"] is True
    assert rep_data["validation_status"] == "passed"

    # 2. Out-of-bounds geographic report (fails validation, routes to quarantine)
    invalid_geo_report = {
        "category": "cables (copper)",
        "district": "Palghar",
        "latitude": 0.5,  # Outside India geo bounds (8.0 to 37.5)
        "longitude": 10.0,
        "offered_price": 670.0,
        "unit": "kg",
    }
    resp_invalid = await async_client.post("/api/v1/prices/report", json=invalid_geo_report)
    assert resp_invalid.status_code == 201
    inv_data = resp_invalid.json()
    assert inv_data["validation_status"] == "quarantined"
    assert inv_data["is_flagged_for_review"] is True
    assert "boundaries" in inv_data["review_reason"].lower() or "india" in inv_data["review_reason"].lower()
