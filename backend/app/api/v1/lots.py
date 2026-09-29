"""Lots (Transactions) API router."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db, get_optional_current_user
from app.models.schema import User
from app.schemas.lots import LotCreate, LotResponse, LotStatusUpdate
from app.services.lots_service import LotsService

router = APIRouter(prefix="/lots", tags=["Lots & Transactions"])


@router.get("", response_model=list[LotResponse], summary="List e-waste lots")
async def list_lots(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
    status: Annotated[str | None, Query(description="Filter by transaction status")] = None,
    payment_status: Annotated[str | None, Query(description="Filter by payment status")] = None,
    settled: Annotated[bool | None, Query(description="Filter by double confirmation settlement")] = None,
    collector_id: Annotated[str | None, Query(description="Filter by collector")] = None,
):
    effective_collector_id = collector_id
    effective_recycler_id = None
    if current_user:
        if current_user.role.value == "collector":
            effective_collector_id = current_user.collector_id or collector_id
        elif current_user.role.value == "recycler":
            effective_recycler_id = current_user.recycler_id

    return await LotsService.list_lots(
        db,
        collector_id=effective_collector_id,
        recycler_id=effective_recycler_id,
        status=status,
        payment_status=payment_status,
        settled=settled,
    )


@router.get("/{lot_id}", response_model=LotResponse, summary="Get lot details by ID")
async def get_lot(
    lot_id: str,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
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
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User | None, Depends(get_optional_current_user)] = None,
):
    effective_collector_id = "KC-C-7821"
    if current_user and current_user.collector_id:
        effective_collector_id = current_user.collector_id

    return await LotsService.create_or_get_lot(effective_collector_id, data, db)



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
