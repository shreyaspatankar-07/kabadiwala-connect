"""Tests for Recyclers API, admin approval workflow, and expired job."""

from datetime import date, timedelta

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_recycler_workflow_and_expiry_job(
    async_client: AsyncClient, test_admin, test_collector
):
    _, admin_token = test_admin
    _, col_token = test_collector
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    col_headers = {"Authorization": f"Bearer {col_token}"}

    # 1. Register a recycler
    valid_till = (date.today() + timedelta(days=365)).isoformat()
    recycler_payload = {
        "id": "REC-MH-TEST99",
        "name": "Sahyadri Eco Recyclers Pvt Ltd",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "materials_accepted": ["pcb_grade_a", "lithium_ion_battery"],
        "authorization_number": "CPCB/AUTH/2026/TEST99",
        "authorization_body": "CPCB",
        "authorization_valid_till": valid_till,
        "phone": "+912224445566",
        "offered_rates": {"pcb_grade_a": 155.0},
        "pickup_available": True,
        "pickup_radius_km": 25.0,
        "service_area": {"districts": ["Mumbai Suburban", "Thane"]},
    }

    create_resp = await async_client.post(
        "/api/v1/recyclers",
        headers=admin_headers,
        json=recycler_payload,
    )
    assert create_resp.status_code == 201
    r_data = create_resp.json()
    assert r_data["id"] == "REC-MH-TEST99"
    assert r_data["authorization_status"] == "pending"

    # 2. Collector cannot verify recycler
    forbid_resp = await async_client.post(
        "/api/v1/recyclers/REC-MH-TEST99/verify",
        headers=col_headers,
    )
    assert forbid_resp.status_code == 403

    # 3. Admin verifies recycler
    verify_resp = await async_client.post(
        "/api/v1/recyclers/REC-MH-TEST99/verify",
        headers=admin_headers,
    )
    assert verify_resp.status_code == 200
    assert verify_resp.json()["authorization_status"] == "verified"

    # 4. Admin suspends recycler
    suspend_resp = await async_client.post(
        "/api/v1/recyclers/REC-MH-TEST99/suspend",
        headers=admin_headers,
    )
    assert suspend_resp.status_code == 200
    assert suspend_resp.json()["authorization_status"] == "suspended"

    # 5. Create an expired recycler to test the audit job
    expired_till = (date.today() - timedelta(days=10)).isoformat()
    expired_payload = dict(recycler_payload)
    expired_payload["id"] = "REC-EXPIRED-01"
    expired_payload["authorization_number"] = "CPCB/EXPIRED/001"
    expired_payload["authorization_valid_till"] = expired_till

    await async_client.post(
        "/api/v1/recyclers",
        headers=admin_headers,
        json=expired_payload,
    )

    # 6. Run audit job
    job_resp = await async_client.post(
        "/api/v1/recyclers/jobs/audit-expired",
        headers=admin_headers,
    )
    assert job_resp.status_code == 200
    assert job_resp.json()["status"] == "audit_complete"
    assert job_resp.json()["expired_records_flagged"] >= 1
