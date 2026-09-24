"""Lots (Transactions) API router."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.errors import PermissionDeniedError
from app.models.schema import User
from app.schemas.lots import LotCreate, LotResponse, LotStatusUpdate
from app.services.lots_service import LotsService

router = APIRouter(prefix="/lots", tags=["Lots & Transactions"])


@router.get("", response_model=list[LotResponse], summary="List e-waste lots")
async def list_lots(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    status: Annotated[str | None, Query(description="Filter by transaction status")] = None,
    collector_id: Annotated[str | None, Query(description="Filter by collector")] = None,
):
    # Collectors can only view their own lots
    if current_user.role.value == "collector":
        effective_collector_id = current_user.collector_id
    else:
        effective_collector_id = collector_id

    return await LotsService.list_lots(
        db,
        collector_id=effective_collector_id,
        recycler_id=current_user.recycler_id,
        status=status,
    )


@router.get("/{lot_id}", response_model=LotResponse, summary="Get lot details by ID")
async def get_lot(
    lot_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    return await LotsService.get_lot(lot_id, db)


@router.post(
    "",
    response_model=LotResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create e-waste lot (idempotent via client_lot_id)",
)
async def create_lot(
    data: LotCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    if not current_user.collector_id:
        raise PermissionDeniedError("Only registered collectors can create e-waste lots.")

    return await LotsService.create_or_get_lot(current_user.collector_id, data, db)


@router.patch(
    "/{lot_id}/status", response_model=LotResponse, summary="Update lot state machine status"
)
async def update_lot_status(
    lot_id: str,
    data: LotStatusUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    return await LotsService.update_lot_status(lot_id, data, db)
