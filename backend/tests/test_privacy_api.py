"""Tests for Collector Privacy and Data Deletion (Right to be Forgotten)."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_delete_collector_data(async_client: AsyncClient):
    """Test purging collector records across tables on the backend."""
    collector_id = "KC-C-TEST-99"

    # Call DELETE endpoint
    response = await async_client.delete(f"/api/v1/collectors/{collector_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "deleted"
    assert data["collector_id"] == collector_id
    assert "purged" in data["message"]
