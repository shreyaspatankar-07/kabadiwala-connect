import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_endpoint(async_client: AsyncClient):
    response = await async_client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data


@pytest.mark.asyncio
async def test_ping_endpoint(async_client: AsyncClient):
    response = await async_client.get("/api/v1/ping")
    assert response.status_code == 200
    assert response.json() == {"message": "pong"}
