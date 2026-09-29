"""Offline synchronization API router (Push & Pull)."""

import contextlib
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_optional_current_user
from app.models.schema import User
from app.schemas.sync import (
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
)
from app.services.sync_service import SyncService

router = APIRouter(prefix="/sync", tags=["Offline Synchronization"])


@router.post(
    "/push",
    response_model=SyncPushResponse,
    status_code=status.HTTP_200_OK,
    summary="Batch upload offline client operations (Idempotent)",
)
async def sync_push(
    data: SyncPushRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
):
    collector_id = "KC-C-7821"
    if current_user:
        collector_id = current_user.collector_id or str(current_user.id)
    return await SyncService.push_batch(collector_id, data.operations, db)


@router.get(
    "/pull",
    response_model=SyncPullResponse,
    summary="Delta download updated master data, prices, recyclers, and collector records",
)
async def sync_pull(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
    since: Annotated[str | None, Query(description="ISO-8601 timestamp cursor")] = None,
):
    since_dt = None
    if since:
        with contextlib.suppress(ValueError):
            since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))

    collector_id = current_user.collector_id if current_user else None
    return await SyncService.pull_delta(
        collector_id=collector_id,
        since=since_dt,
        db=db,
    )

