"""Offline synchronization API router (Push & Pull)."""

import contextlib
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
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
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    collector_id = current_user.collector_id or str(current_user.id)
    return await SyncService.push_batch(collector_id, data.operations, db)


@router.get(
    "/pull",
    response_model=SyncPullResponse,
    summary="Delta download updated master data, prices, recyclers, and collector records",
)
async def sync_pull(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    since: Annotated[str | None, Query(description="ISO-8601 timestamp cursor")] = None,
):
    since_dt = None
    if since:
        with contextlib.suppress(ValueError):
            since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))

    return await SyncService.pull_delta(
        collector_id=current_user.collector_id,
        since=since_dt,
        db=db,
    )
