"""Pytest suite for Safety Guidance API endpoints using AsyncClient."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_get_all_safety_cards_multilingual(async_client: AsyncClient) -> None:
    """Verify safety guidance cards return in Marathi (default), Hindi, and English."""
    # 1. Marathi (default)
    res_mr = await async_client.get("/api/v1/safety?language=mr")
    assert res_mr.status_code == 200
    cards_mr = res_mr.json()
    assert len(cards_mr) >= 8
    first_mr = next(c for c in cards_mr if c["topic_id"] == "cables_burn")
    assert "तांब्यासाठी" in first_mr["title"]
    assert first_mr["hazard_level"] == "danger"
    assert len(first_mr["instructions"]) >= 3
    assert len(first_mr["dos"]) >= 2
    assert len(first_mr["donts"]) >= 2

    # Root alias /safety
    res_root = await async_client.get("/safety?language=mr")
    assert res_root.status_code == 200
    assert len(res_root.json()) >= 8

    # 2. Hindi
    res_hi = await async_client.get("/api/v1/safety?language=hi")
    assert res_hi.status_code == 200
    cards_hi = res_hi.json()
    first_hi = next(c for c in cards_hi if c["topic_id"] == "cables_burn")
    assert "तांबा" in first_hi["title"]

    # 3. English
    res_en = await async_client.get("/api/v1/safety?language=en")
    assert res_en.status_code == 200
    cards_en = res_en.json()
    first_en = next(c for c in cards_en if c["topic_id"] == "cables_burn")
    assert "Never burn cables" in first_en["title"]


@pytest.mark.asyncio
async def test_get_safety_card_by_topic_detail(async_client: AsyncClient) -> None:
    """Verify single topic detail retrieval and 404 handling."""
    # Test via topic_id
    res = await async_client.get("/api/v1/safety/crt_monitor?language=mr")
    assert res.status_code == 200
    data = res.json()
    assert data["topic_id"] == "crt_monitor"
    assert "CRT" in data["title"]
    assert data["category_trigger"] == "CRT"

    # Test via unique ID
    res2 = await async_client.get("/api/v1/safety/SAFE-BATT-01?language=en")
    assert res2.status_code == 200
    data2 = res2.json()
    assert data2["topic_id"] == "battery_crush"

    # Test invalid topic 404
    res_404 = await async_client.get("/api/v1/safety/non_existent_topic")
    assert res_404.status_code == 404


@pytest.mark.asyncio
async def test_filter_safety_cards_by_category(async_client: AsyncClient) -> None:
    """Verify filtering safety cards by scrap category."""
    res = await async_client.get("/api/v1/safety?category=batteries&language=mr")
    assert res.status_code == 200
    cards = res.json()
    assert len(cards) >= 2
    for card in cards:
        assert card["category"] == "batteries"


@pytest.mark.asyncio
async def test_acknowledge_safety_card(async_client: AsyncClient) -> None:
    """Verify collector 'I Understood' acknowledgement persistence."""
    payload = {
        "collector_id": "KC-C-7821",
        "topic_id": "cables_burn",
        "acknowledged_at": "2026-09-25T18:00:00Z",
    }
    res = await async_client.post("/api/v1/safety/acknowledged", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["topic_id"] == "cables_burn"
    assert data["collector_id"] == "KC-C-7821"


@pytest.mark.asyncio
async def test_seed_safety_endpoint(async_client: AsyncClient) -> None:
    """Verify admin seed endpoint."""
    res = await async_client.post("/api/v1/safety/seed")
    assert res.status_code == 201
    data = res.json()
    assert data["count"] >= 8
