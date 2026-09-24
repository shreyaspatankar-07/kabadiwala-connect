"""Tests for Authentication endpoints (OTP, PIN, Email/Password, Roles)."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_otp_request_and_verify(async_client: AsyncClient):
    # 1. Request OTP
    req_resp = await async_client.post(
        "/api/v1/auth/otp/request",
        json={"phone": "+919811122233", "language": "mr"},
    )
    assert req_resp.status_code == 200
    data = req_resp.json()
    assert data["status"] == "otp_sent"
    assert data["mock_otp"] == "123456"

    # 2. Verify OTP
    verify_resp = await async_client.post(
        "/api/v1/auth/otp/verify",
        json={
            "phone": "+919811122233",
            "otp": "123456",
            "operating_area": "Pune",
        },
    )
    assert verify_resp.status_code == 200
    verify_data = verify_resp.json()
    assert "access_token" in verify_data
    assert verify_data["role"] == "collector"
    assert verify_data["collector_id"].startswith("KC-C-")
    assert verify_data["has_pin"] is False

    # 3. Verify /auth/me
    token = verify_data["access_token"]
    me_resp = await async_client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert me_resp.status_code == 200
    me_data = me_resp.json()
    assert me_data["phone"] == "+919811122233"
    assert me_data["role"] == "collector"


@pytest.mark.asyncio
async def test_pin_setup_and_login(async_client: AsyncClient, test_collector):
    _, token = test_collector
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Setup PIN
    setup_resp = await async_client.post(
        "/api/v1/auth/pin/setup",
        headers=headers,
        json={"pin": "4321"},
    )
    assert setup_resp.status_code == 200
    assert setup_resp.json() == {"status": "pin_set"}

    # 2. Login with PIN
    login_resp = await async_client.post(
        "/api/v1/auth/pin/login",
        json={"phone": "+919876543210", "pin": "4321"},
    )
    assert login_resp.status_code == 200
    data = login_resp.json()
    assert data["role"] == "collector"
    assert data["has_pin"] is True

    # 3. Invalid PIN fails
    fail_resp = await async_client.post(
        "/api/v1/auth/pin/login",
        json={"phone": "+919876543210", "pin": "9999"},
    )
    assert fail_resp.status_code == 401


@pytest.mark.asyncio
async def test_email_register_and_login(async_client: AsyncClient):
    # 1. Register recycler user
    reg_resp = await async_client.post(
        "/api/v1/auth/register",
        json={
            "email": "testrecycler@kabadiwala.in",
            "password": "securepassword123",
            "role": "recycler",
            "recycler_id": "REC-TEST-REG",
        },
    )
    assert reg_resp.status_code == 201
    assert reg_resp.json()["role"] == "recycler"

    # 2. Login with email
    login_resp = await async_client.post(
        "/api/v1/auth/login",
        json={
            "email": "testrecycler@kabadiwala.in",
            "password": "securepassword123",
        },
    )
    assert login_resp.status_code == 200
    assert "access_token" in login_resp.json()

    # 3. Bad password fails
    bad_resp = await async_client.post(
        "/api/v1/auth/login",
        json={
            "email": "testrecycler@kabadiwala.in",
            "password": "wrongpassword",
        },
    )
    assert bad_resp.status_code == 401
