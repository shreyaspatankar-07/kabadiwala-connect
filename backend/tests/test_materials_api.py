"""Tests for Materials Catalog API and role enforcement."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_material_crud_and_permissions(async_client: AsyncClient, test_collector, test_admin):
    _, collector_token = test_collector
    _, admin_token = test_admin

    col_headers = {"Authorization": f"Bearer {collector_token}"}
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    payload = {
        "category": "pcb",
        "sub_category": "grade_a",
        "description": "High-grade gold-bearing motherboard PCB",
        "approx_weight_kg": 0.45,
        "condition": "working",
        "source_type": "office",
        "estimated_value": 165.0,
    }

    # 1. Collector cannot create material (Role guard)
    forbidden_resp = await async_client.post(
        "/api/v1/materials",
        headers=col_headers,
        json=payload,
    )
    assert forbidden_resp.status_code == 403

    # 2. Admin creates material
    create_resp = await async_client.post(
        "/api/v1/materials",
        headers=admin_headers,
        json=payload,
    )
    assert create_resp.status_code == 201
    mat_data = create_resp.json()
    mat_id = mat_data["id"]
    assert mat_data["category"] == "pcb"
    assert mat_data["estimated_value"] == 165.0

    # 3. Public / Authenticated list materials
    list_resp = await async_client.get("/api/v1/materials?category=pcb")
    assert list_resp.status_code == 200
    items = list_resp.json()
    assert len(items) >= 1
    assert items[0]["id"] == mat_id

    # 4. Get by ID
    get_resp = await async_client.get(f"/api/v1/materials/{mat_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["sub_category"] == "grade_a"

    # 5. Update material
    update_resp = await async_client.put(
        f"/api/v1/materials/{mat_id}",
        headers=admin_headers,
        json={"estimated_value": 180.0, "condition": "broken"},
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["estimated_value"] == 180.0
    assert update_resp.json()["condition"] == "broken"
