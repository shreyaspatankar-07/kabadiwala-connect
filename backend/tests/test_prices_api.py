"""Tests for Prices and District Price Board API."""

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

    # 4. Get by ID
    get_resp = await async_client.get(f"/api/v1/prices/{price_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == price_id
